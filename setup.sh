#!/usr/bin/env bash
set -x

# IMPORTANT: this script must be run while current working directory is the Dreambooth git repo
export DREAMBOOTH_DIR=`pwd`
echo 'export DREAMBOOTH_DIR'=$DREAMBOOTH_DIR >> ~/.bashrc

# Creating conda environment
conda update -n base conda
conda create -n "db" python=3.10 ipython

# Installing required packages
# TODO: Try moving two of these into requirements.txt

git clone https://github.com/huggingface/diffusers.git
pushd diffusers
conda run -n db pip install -e .
cd examples/dreambooth
conda run -n db --no-capture-output pip install -r requirements.txt
popd

conda run -n db --no-capture-output pip install -r requirements.txt
conda run -n db --no-capture-output pip install bitsandbytes

# Configuring accelerate
# TODO: Can this be done non-interactively?
echo Answer: 0, 0, no, no, fp16
conda run -n db --no-capture-output accelerate config

# Logging into Hugging Face
# TODO: Can this be done non-interactively?
echo Paste your Hugging Face token here, and say Y to the prompt
conda run -n db --no-capture-output huggingface-cli login
git config --global credential.helper store

# Making required directories
mkdir -p s3 s3/class s3/models s3/input s3/output s3/photobooth-input s3/data
aws s3 sync s3://rootvc-dreambooth/class s3/class # Only needed to speed up first run
aws s3 sync s3://rootvc-dreambooth/input s3/input # Start with up to date input history
aws s3 sync s3://rootvc-dreambooth/output s3/output # Start with up to date output history (to prevent repeat jobs)

# Setting up services
sudo cp daemons/*.sh /usr/bin/
sudo cp daemons/*.service /lib/systemd/system/
sudo systemctl daemon-reload

# Setting up Dreamwatcher Service
sudo systemctl enable dreamwatcher.service
sudo systemctl start dreamwatcher.service

# Show status of daemons
sudo systemctl status s3sync.service
sudo systemctl status dreamwatcher.service
sudo systemctl status pbsync.service

# Environment variables
cp .env.example .env

echo You're almost ready to train!
echo Edit .env and insert your Twilio credentials to enable SMS
echo (Optional) Run ./setup-optional.sh for memory performance improvement

set -x
