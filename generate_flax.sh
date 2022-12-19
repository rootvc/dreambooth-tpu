#!/usr/bin/env bash
set -e

if [[ $# -eq 0 ]]; then
    echo "ERROR: Provide an argument for the subject's unique identifier"
    exit 1
fi

export RETRAIN_STEP=1000
cd $DREAMBOOTH_DIR

echo Generating images for $1
echo Transfer learning beginning at step: $RETRAIN_STEP

mkdir -p ./s3/output/$1

numactl --cpunodebind=0 \
    accelerate launch --num_cpu_threads_per_process=96 --dynamo_backend=ofi \
    src/inference_flax.py \
    --input_dir="./input" \
    --model_dir="./models" \
    --output_dir="./s3/output" \
    --id $1 \
    --num-images 4 \
    --step $RETRAIN_STEP \
    --prompt "a cartoon disney animation" \
    --prompt "a comic book superhero character" \
    --prompt "the Simpsons show animation" \
    --prompt "cartoon Japanese anime character" \
    --prompt "the Hokusai artist" \
    --prompt "a Andy Warhol painting" \
    --prompt "lego bricks" \
    --prompt "a sneaky ninja" \
    --prompt "a Studio Ghibli anime cartoon" \
    --prompt "a famous oil painting"
