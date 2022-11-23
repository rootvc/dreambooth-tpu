#!/usr/bin/env bash

echo Installing Python and required packages...

conda update -n base conda
conda activate db
conda install -c anaconda python=3.9
pip install git+https://github.com/ShivamShrirao/diffusers.git
pip install -r requirements.txt
pip install bitsandbytes

echo Answer 0 0 no no fp16
accelerate config

echo Paste your Hugging Face token here
huggingface-cli login
git config --global credential.helper store

echo Syncing to AWS S3 bucket...
aws s3 sync s3://rootvc-stable-diffusion/instance-images instance-images

echo You are ready to train!
