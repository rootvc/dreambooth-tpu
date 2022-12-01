NOTES
=====
Install xformers
------------------
export TORCH_CUDA_ARCH_LIST=8.6 && \
export FORCE_CUDA=1 && \
export CUDA_VISIBLE_DEVICES=0
export CUDACXX=${CUDA_INSTALL_PATH}/bin/nvcc && \

conda install -n db ninja
conda run -n db --no-capture-output pip install git+https://github.com/facebookresearch/xformers.git@main#egg=xformers

cd ~ && \
git clone https://github.com/openai/triton.git && \
cd triton/python/ && \
pip install -e . && \
cd ~/rootvc/dreambooth

TODO:
-----
* Try 4 GPUs and highest memory possible - set PYTORCH_CUDA_ALLOC_CONF
* Mess with hyperparams
* abandon training after 3rd bucket




JUNK
----
(Python 3.10)
conda install -n db ninja

trying
conda install -n db triton
export TORCH_CUDA_ARCH_LIST=7.0,8.0,11.7 && \
export FORCE_CUDA=1 && \
export CUDA_VISIBLE_DEVICES=0 && \
conda install -n db xformers -c xformers/label/dev

conda run -n db --no-capture-output pip install git+https://github.com/facebookresearch/xformers.git#egg=xformers
> conda install -n db xformers -c xformers/label/dev
conda run -n db python -m xformers.info

conda install -n db cutlass

ALL FROM SOURCE
xformers and deps
--------

`conda install -n db ninja && \

git clone https://github.com/openai/triton.git && \
git clone https://github.com/NVIDIA/cutlass.git && \
// export TORCH_CUDA_ARCH_LIST=7.0,8.6,11.1,11.7 && \
export TORCH_CUDA_ARCH_LIST=8.6 && \
export FORCE_CUDA=1 && \
export CUDA_VISIBLE_DEVICES=0
export CUDACXX=${CUDA_INSTALL_PATH}/bin/nvcc && \

cd triton/python/ && \
pip install -e . && \

cd ../../cutlass && \
mkdir -p build && cd build && \
cmake .. -DCUTLASS_NVCC_ARCHS=80
(Optional) make test_unit -j

cd ../../ && \
conda install -n db xformers -c xformers/label/dev
OR
pip install git+https://github.com/facebookresearch/xformers.git@main#egg=xformers
`
