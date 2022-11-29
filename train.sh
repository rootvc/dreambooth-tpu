#!/usr/bin/env bash

echo Downloading from AWS S3 bucket...
mkdir -p ./s3/input/$1
aws s3 sync s3://rootvc-dreambooth/input/$1 ./s3/input/$1

echo Learning stable diffusion model for $1 using Dreambooth...
time conda run -n db --no-capture-output \
  accelerate launch --num_cpu_threads_per_process=96 ./src/training.py \
  --pretrained_model_name_or_path="runwayml/stable-diffusion-v1-5" \
  --pretrained_vae_name_or_path="stabilityai/sd-vae-ft-mse" \
  --instance_data_dir="./s3/input/$1" \
  --class_data_dir="./s3/class/" \
  --output_dir="./models/" \
  --with_prior_preservation --prior_loss_weight=1.0 \
  --instance_prompt="photo of $1 person" \
  --class_prompt="photo of person" \
  --resolution=512 \
  --train_batch_size=1 \
  --train_text_encoder \
  --mixed_precision="fp16" \
  --use_8bit_adam \
  --gradient_accumulation_steps=1 \
  --gradient_checkpointing \
  --learning_rate=1e-6 \
  --lr_scheduler="constant" \
  --lr_warmup_steps=200 \
  --num_class_images=300 \
  --max_train_steps=1000 \
  --save_interval=250
  