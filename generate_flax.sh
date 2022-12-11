#!/usr/bin/env bash
set -e

if [[ $# -eq 0 ]]; then
    echo "ERROR: Provide an argument for the subject's unique identifier"
    exit 1
fi

export RETRAIN_STEP=600
cd $DREAMBOOTH_DIR

echo Generating images for $1
echo Transfer learning beginning at step: $RETRAIN_STEP

mkdir -p ./s3/output/$1

accelerate launch --num_cpu_threads_per_process=96 --dynamo_backend=ofi \
    src/inference_flax.py \
    --model_dir="./models" \
    --output_dir="./s3/output" \
    --id $1 \
    --num-images 4 \
    --step $RETRAIN_STEP \
    --prompt "disney style animation of one sks person as protagonist in a disney film" \
    --prompt "cartoon of one sks person as comic book superhero" \
    --prompt "a cartoon drawing of an sks person in the style of the Simpsons by Matt Groenig" \
    --prompt "anime style cartoon of sks person as anime character" \
    --prompt "a painting of sks person in the style of Hokusai" \
    --prompt "a silk screen of sks person in the style of Andy Warhol" \
    --prompt "a realistic rendering of one sks person made from lego" \
    --prompt "a Japanese anime drawing of sks person using ninja techniques" \
    --prompt "a cartoon drawing of sks person in the style of a Studio Ghibli anime film" \
    --prompt "a realistic oil painting of sks person wearing stylish middle ages attire"
