#!/usr/bin/env bash + x

# Creating conda environment
conda update -n base conda
conda create -n "db" python=3.9 ipython

# Installing required packages
conda run -n db pip install git+https://github.com/ShivamShrirao/diffusers.git
conda run -n db pip install -r requirements.txt
conda run -n db pip install bitsandbytes

# Configuring accelerate
echo Answer: 0, 0, no, no, fp16
conda run -n db --no-capture-output accelerate config

# Logging into Hugging Face
echo Paste your Hugging Face token here, and say Y to the prompt
conda run -n db --no-capture-output huggingface-cli login
git config --global credential.helper store

# Making required directories
mkdir instance-images class-images output-models output-images

# Downloading instance-images
# Only needed for debugging
aws s3 sync s3://rootvc-stable-diffusion/instance-images instance-images

echo You are ready to train!
