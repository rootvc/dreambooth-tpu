#!/usr/bin/env bash
set -ex

sudo rm /usr/bin/python
sudo ln -s /usr/bin/python3 /usr/bin/python

sudo add-apt-repository ppa:keithw/mosh-dev
sudo apt update

# sudo apt-get install mosh
sudo apt-get install numactl ffmpeg libsm6 libxext6 -y

cat >~/.tmux.conf <<-EOF
	new-session
	set-window-option -g mouse on
	set -g history-limit 30000
EOF

mkdir -p ~/.cache/huggingface/accelerate
cat >~/.cache/huggingface/accelerate/default_config.yaml <<-EOF
	command_file: null
	commands: null
	compute_environment: LOCAL_MACHINE
	distributed_type: TPU
	downcast_bf16: no
	dynamo_backend: INDUCTOR
	fsdp_config: {}
	gpu_ids: null
	machine_rank: 0
	main_process_ip: null
	main_process_port: null
	main_training_function: main
	megatron_lm_config: {}
	mixed_precision: bf16
	num_machines: 1
	num_processes: 4
	rdzv_backend: static
	same_network: true
	tpu_name: null
	tpu_zone: null
	use_cpu: false
EOF

# IMPORTANT: this script must be run while current working directory is the Dreambooth git repo
export DREAMBOOTH_DIR=$(pwd)
echo 'export DREAMBOOTH_DIR'=$DREAMBOOTH_DIR >>~/.bashrc

export PATH=~/.local/bin${PATH:+:${PATH}}
echo 'export PATH=~/.local/bin${PATH:+:${PATH}}' >>~/.bashrc

export XRT_TPU_CONFIG="localservice;0;localhost:51011"
echo "export XRT_TPU_CONFIG='$XRT_TPU_CONFIG'" >>~/.bashrc

export TPU_NUM_DEVICES=4
echo "export TPU_NUM_DEVICES='$TPU_NUM_DEVICES'" >>~/.bashrc

export ALLOW_MULTIPLE_LIBTPU_LOAD=1
echo "export ALLOW_MULTIPLE_LIBTPU_LOAD='$ALLOW_MULTIPLE_LIBTPU_LOAD'" >>~/.bashrc

# Installing required packages

git clone https://github.com/yasyf/diffusers
pushd diffusers
git checkout stable-diffusion
pip install -e .
cd examples/dreambooth
pip install -r requirements.txt
pip install -U -r requirements_flax.txt
popd

pip install -r requirements.txt
pip install bitsandbytes
pip install git+https://github.com/microsoft/DeepSpeed
pip install "jax[tpu]>=0.2.16" -f https://storage.googleapis.com/jax-releases/libtpu_releases.html
pip install git+https://github.com/huggingface/accelerate

pip install ninja
pip install -v -U git+https://github.com/facebookresearch/xformers.git@main#egg=xformers
pip install triton

# Logging into Hugging Face
# TODO: Can this be done non-interactively?
echo Paste your Hugging Face token here, and say Y to the prompt
git config --global credential.helper store
pip install huggingface_hub
huggingface-cli login

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip ./aws

pip install markupsafe==2.0.1

pip install deepface

git clone https://github.com/sczhou/CodeFormer
pushd CodeFormer
pip install -r requirements.txt
python basicsr/setup.py develop || true
python -c "import basicsr"
mv scripts/download_pretrained_models.py download_pretrained_models.py
python download_pretrained_models.py CodeFormer
popd

echo 'Run: `gcloud compute tpus tpu-vm scp --recurse  ~/.aws tpu-$tpu_id:`'
read -n 1 -p "SCP your ~/.aws folder and hit enter"

# Making required directories
mkdir -p s3 s3/class s3/models s3/input s3/output s3/photobooth-input s3/data
aws s3 sync s3://rootvc-dreambooth/class s3/class   # Only needed to speed up first run
aws s3 sync s3://rootvc-dreambooth/input s3/input   # Start with up to date input history
aws s3 sync s3://rootvc-dreambooth/output s3/output # Start with up to date output history (to prevent repeat jobs)

# Setting up services
sudo cp daemons/*.sh /usr/bin/
sudo cp daemons/*.service /lib/systemd/system/
sudo systemctl daemon-reload

# Setting up Dreamwatcher Service
sudo systemctl enable dreamwatcher.service
sudo systemctl start dreamwatcher.service

# Show status of daemons
sudo systemctl status dreamwatcher.service

# Environment variables
cp .env.example .env

exec bash --login
