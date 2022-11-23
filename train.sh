#!/usr/bin/env bash

conda run -n db accelerate launch ./src/training.py \
  --pretrained_model_name_or_path="runwayml/stable-diffusion-v1-5" \
  --pretrained_vae_name_or_path="stabilityai/sd-vae-ft-mse" \
  --instance_data_dir="./instance-images/" \
  --class_data_dir="./class-images/" \
  --output_dir="./output-models/" \
  --with_prior_preservation --prior_loss_weight=1.0 \
  --instance_prompt="photo of zwx person" \
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
  --max_train_steps=2000 \
  --save_interval=500 \
  --with_prior_preservation --prior_loss_weight=1.0 \
  --train_text_encoder
  
