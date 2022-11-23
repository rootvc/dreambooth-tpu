#!/usr/bin/env bash

conda create -n db
conda init

conda update -n base conda
conda activate db
conda install -c anaconda python=3.9
pip install git+https://github.com/ShivamShrirao/diffusers.git
pip install -r requirements.txt
pip install bitsandbytes

accelerate config

huggingface-cli login
git config --global credential.helper store

aws s3 sync s3://rootvc-stable-diffusion/instance-images instance-images
