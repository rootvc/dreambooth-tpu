#!/usr/bin/env bash
set -e

echo Learning stable diffusion model for $1 using Dreambooth...

if [[ $# -eq 0 ]]; then
  echo "ERROR: Provide an argument for the subject's unique identifier"
  exit 1
fi

export STEPS=800

cd $DREAMBOOTH_DIR
mkdir -p ./input/$1
rm -rf ./models/*
cp ./s3/photobooth-input/$2*.jpg ./input/$1

conda run -n db --no-capture-output \
  accelerate launch diffusers/examples/dreambooth/train_dreambooth.py \
  --pretrained_model_name_or_path="runwayml/stable-diffusion-v1-5" \
  --pretrained_vae_name_or_path="stabilityai/sd-vae-ft-mse" \
  --instance_data_dir="./input/$1" \
  --class_data_dir="./s3/class/" \
  --output_dir="./models/" \
  --with_prior_preservation --prior_loss_weight=1.0 \
  --instance_prompt="a photo of sks person" \
  --class_prompt="a photo of person" \
  --resolution=550 \
  --train_batch_size=1 \
  --gradient_accumulation_steps=1 \
  --learning_rate=5e-6 \
  --lr_scheduler="constant" \
  --lr_warmup_steps=0 \
  --num_class_images=300 \
  --max_train_steps=$STEPS \
  --train_text_encoder \
  --use_8bit_adam \
  --gradient_checkpointing
