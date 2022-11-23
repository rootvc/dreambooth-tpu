rootvc/dreambooth
====================
Implements: https://towardsdatascience.com/how-to-fine-tune-stable-diffusion-using-dreambooth-dfa6694524ae

Server Provision
----------------
EC2 Instance
* AMI: Deep Learning with PyTorch 1.2
* Instance type: g5.xlarge
* Go to AWS Console: Security settings -> Change IAM role -> stable-diffusion

(Optional:)
* Get ssh to work nicely
 * add `PermitTunnel yes` with `sudo vim /etc/ssh/sshd_config`
 * reload ssh with `sudo service sshd reload`

Connect
-------
`ssh -i dreambooth.pem ec2-user@<IP-ADDRESS>`

Setup Environment
-----------------
Run `setup.sh`
If you get an error partway through the script, reboot the terminal.
(TODO: This is dumb, fix/work around this.)

Setup Accelerate
----------------
`accelerate config`

Answer the questions as follows:
(TODO: This is dumb, see if we can answer the Qs automatically.)

In which compute environment are you running? ([0] This machine, [1] AWS (Amazon SageMaker)): 0
Which type of machine are you using? ([0] No distributed training, [1] multi-CPU, [2] multi-GPU, [3] TPU [4] MPS): 0
Do you want to run your training on CPU only (even if a GPU is available)? [yes/NO]:no
Do you want to use DeepSpeed? [yes/NO]: no
Do you wish to use FP16 or BF16 (mixed precision)? [NO/fp16/bf16]: fp16

Login to HuggingFace
--------------------
`huggingface-cli login`
Enter huggingface credentials.
(TODO: See if we can answer this Q automatically.)
`git config --global credential.helper store`

(Development) Download Instance Images
--------------------------------------
Update the IAM role in AWS console to allow s3 sync.
This might help: https://gist.github.com/iandees/26c61b7f1e9a51dae91be41d53fc06d3
`aws s3 sync s3://rootvc-stable-diffusion/instance-images instance-images`

Training
--------
`./script/train.sh`

Inference
---------
`./script/infer.sh`

TODO
----
* Make training faster
 * get facebook/xformers to build
 * try more cores!
* Make it possible to train for multiple people
 * scripts take a unique identifer
 * use that for 'class' instead of zwx in both training and inference
 * subdirectories in input and output per person
* Expose web endpoint
* Obviously make the front-end for the photobooth itself...
