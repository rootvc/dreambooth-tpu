#!/usr/bin/env bash
set -e

if [[ $# -eq 0 ]]; then
    echo "ERROR: Provide an argument for the subject's unique identifier"
    exit 1
fi

export RETRAIN_STEP=800
cd $DREAMBOOTH_DIR

echo Generating images for $1
echo Transfer learning beginning at step: $RETRAIN_STEP

mkdir -p ./s3/output/$1

numactl --cpunodebind=0 \
    accelerate launch --num_cpu_threads_per_process=96 --dynamo_backend=ofi \
    src/inference_flax.py \
    --model_dir="./models" \
    --output_dir="./s3/output" \
    --id $1 \
    --num-images 4 \
    --step $RETRAIN_STEP \
    --prompt "disney-style-animation of one sks person, protagonist, disney film" \
    --prompt "cartoon of one sks person, comic book superhero" \
    --prompt "drawing of one sks person, cartoon, style of the Simpsons by Matt Groenig" \
    --prompt "anime-style cartoon of one sks person, anime character" \
    --prompt "painting of one sks person, style of Hokusai" \
    --prompt "silk screen of one sks person, style of Andy Warhol" \
    --prompt "rendering of one sks person made from lego blocks" \
    --prompt "Japanese anime drawing of sks person, ninja techniques" \
    --prompt "cartoon drawing of sks person, style of a Studio Ghibli anime film" \
    --prompt "oil painting of sks person wearing stylish middle ages attire, realistic"
