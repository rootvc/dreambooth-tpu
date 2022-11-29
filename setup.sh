#!/usr/bin/env bash
set -x

# TODO: Can I get confirm and also pre-filled answers in these commands?

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
aws s3 sync s3://rootvc-dreambooth/class s3/class # Only needed to speed up setup
aws s3 sync s3://rootvc-dreambooth/input s3/input # Only needed for debugging

echo You are ready to train!
echo (Optional) Run ./setup-optional.sh for memory performance improvement
set -x
