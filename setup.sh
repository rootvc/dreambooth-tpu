#!/usr/bin/env bash
set -x

# IMPORTANT: this script must be run while current working directory is the Dreambooth git repo
export DREAMBOOTH_DIR=$(pwd)
echo 'export DREAMBOOTH_DIR'=$DREAMBOOTH_DIR >>~/.bashrc

export PATH=~/.local/bin${PATH:+:${PATH}}
echo 'export PATH=~/.local/bin${PATH:+:${PATH}}' >>~/.bashrc

export XRT_TPU_CONFIG="localservice;0;localhost:51011"
echo "export XRT_TPU_CONFIG='$XRT_TPU_CONFIG'" >>~/.bashrc

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

# Configuring accelerate
accelerate config

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
