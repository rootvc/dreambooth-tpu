#!/usr/bin/env bash
set -x

echo Building facebook/xformers
echo This is a bit dicey on a lot of systems and requires install from source

export TORCH_CUDA_ARCH_LIST=8.6
export FORCE_CUDA=1
export CUDA_VISIBLE_DEVICES=0
export CUDACXX=${CUDA_INSTALL_PATH}/bin/nvcc

conda install -n db ninja
conda run -n db --no-capture-output pip install git+https://github.com/facebookresearch/xformers.git@main#egg=xformers

cd ~
git clone https://github.com/openai/triton.git
cd triton/python
conda run -n db --no-capture-output pip install -e .
cd ~/rootvc/dreambooth

conda run -n db python -m xformers.info

echo xformers memory optimization worked if the above table shows features enabled.

set -x
