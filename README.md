rootvc/dreambooth
====================
Implements: https://towardsdatascience.com/how-to-fine-tune-stable-diffusion-using-dreambooth-dfa6694524ae

Server Provision
----------------
EC2 Instance
* AMI: Deep Learning with PyTorch 1.13
* Instance type: g5.xlarge
* IAM role: stable-diffusion

Connect
-------
`ssh -i dreambooth.pem ec2-user@<IP-ADDRESS>`

(Optional:)
* Get ssh to work nicely
 * add `PermitTunnel yes` with `sudo vim /etc/ssh/sshd_config`
 * reload ssh with `sudo service sshd reload`

SSH Config & Git Clone
----------------------
* `ssh-keygen -t rsa -C "your-email@gmail.com"`
* `eval "$(ssh-agent -s)" && \
ssh-add ~/.ssh/id_rsa && \
ssh-add -l -E sha256 && \
cat ~/.ssh/id_rsa.pub`

Copy that output and paste it into GitHub as an SSH key under Settings.
https://github.com/settings/keys

`mkdir rootvc && cd rootvc && git clone git@github.com:rootvc/dreambooth.git && cd dreambooth`

Setup Environment
-----------------
`./setup.sh`

Note: Setup Accelerate
----------------
`accelerate config`

Answer the questions as follows:
(TODO: This is dumb, see if we can answer the Qs automatically.)

In which compute environment are you running? ([0] This machine, [1] AWS (Amazon SageMaker)): 0
Which type of machine are you using? ([0] No distributed training, [1] multi-CPU, [2] multi-GPU, [3] TPU [4] MPS): 0
Do you want to run your training on CPU only (even if a GPU is available)? [yes/NO]:no
Do you want to use DeepSpeed? [yes/NO]: no
Do you wish to use FP16 or BF16 (mixed precision)? [NO/fp16/bf16]: fp16

Note: Login to HuggingFace
--------------------
`huggingface-cli login`
Enter huggingface credentials.
(TODO: See if we can answer this Q automatically.)
`git config --global credential.helper store`

Training
--------
`./train.sh`

Inference
---------
`./generate.sh`
