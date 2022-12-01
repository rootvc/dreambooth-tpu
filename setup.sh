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
conda run -n db --no-capture-output pip install git+https://github.com/ShivamShrirao/diffusers.git
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
mkdir -p s3 s3/class s3/models s3/input s3/output
aws s3 sync s3://rootvc-dreambooth/class s3/class # Only needed to speed up first run
aws s3 sync s3://rootvc-dreambooth/input s3/input # Start with up to date input history
aws s3 sync s3://rootvc-dreambooth/output s3/output # Start with up to date output history (to prevent repeat jobs)

# Setting up services
sudo cp daemons/*.sh /usr/bin/
sudo cp daemons/*.service /lib/systemd/system/
sudo systemctl daemon-reload

# Setting up S3 Sync Service
sudo systemctl enable s3sync.service
sudo systemctl start s3sync.service

# Setting up Dreamwatcher Service
sudo systemctl enable dreamwatcher.service
sudo systemctl start dreamwatcher.service

# Show status of daemons
sudo systemctl status s3sync.service
sudo systemctl status dreamwatcher.service

echo You are ready to train!
echo (Optional) Run ./setup-optional.sh for memory performance improvement

set -x
