#!/usr/bin/env bash
set -e

echo Learning stable diffusion model for $1 using Dreambooth...

if [[ $# -eq 0 ]]; then
  echo "ERROR: Provide an argument for the subject's unique identifier"
  exit 1
fi

export STEPS=400
export INTERVAL=150

cd $DREAMBOOTH_DIR
mkdir -p ./input/$1
rm -rf ./models/*
cp ./s3/photobooth-input/$2*.jpg ./input/$1

conda run -n db --no-capture-output \
  accelerate launch --num_cpu_threads_per_process=96 \
  diffusers/examples/dreambooth/train_dreambooth.py \
  --pretrained_model_name_or_path="runwayml/stable-diffusion-v1-5" \
  --instance_data_dir="./input/$1" \
  --class_data_dir="./s3/class/" \
  --output_dir="./models/" \
  --with_prior_preservation --prior_loss_weight=1.0 \
  --instance_prompt="a photo of sks person" \
  --class_prompt="a photo of person" \
  --train_batch_size=2 \
  --gradient_accumulation_steps=2 \
  --learning_rate=5e-6 \
  --lr_scheduler="constant" \
  --lr_warmup_steps=0 \
  --num_class_images=300 \
  --max_train_steps=$STEPS \
  --use_8bit_adam \
  --gradient_checkpointing \
  --mixed_precision=bf16 \
  --save_interval=$INTERVAL
