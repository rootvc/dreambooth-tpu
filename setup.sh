#!/usr/bin/env bash

echo Creating conda environment...
conda update -n base conda
conda create -n "db" python=3.9 ipython

echo Installing required packages...
conda run -n db pip install git+https://github.com/ShivamShrirao/diffusers.git
conda run -n db pip install -r requirements.txt
conda run -n db pip install bitsandbytes

echo Configuring accelerate...
echo Answer: 0, 0, no, no, fp16
accelerate config

echo Logging into Hugging Face...
echo Paste your Hugging Face token here, and say Y to the prompt
huggingface-cli login
git config --global credential.helper store

echo Syncing to AWS S3 bucket...
aws s3 sync s3://rootvc-stable-diffusion/instance-images instance-images

echo You are ready to train!
