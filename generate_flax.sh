#!/usr/bin/env bash
set -e

if [[ $# -eq 0 ]]; then
    echo "ERROR: Provide an argument for the subject's unique identifier"
    exit 1
fi

export RETRAIN_STEP=400
cd $DREAMBOOTH_DIR

echo Generating images for $1
echo Transfer learning beginning at step: $RETRAIN_STEP

mkdir -p ./s3/tmp/output/$1
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
    --prompt "cartoon disney animation" \
    --prompt "comic book superhero character" \
    --prompt "cartoon anime character" \
    --prompt "Hokusai artist" \
    --prompt "Andy Warhol painting"
# --prompt "sneaky ninja, dark, bleak, cyberpunk" \
# --prompt "Studio Ghibli film, sketch" \
# --prompt "50mm, sharp, muscular" \
# --prompt "winter gothic, leather, gothic jewellery, flowing cloak, elegant pose" \
# --prompt "impressionist painting, Daniel F Gerhartz, nature" \
# --prompt "pencil sketch, greg rutkowski, in the style of kentaro miura, 4 k, 8 k, absolute detail, black and white drawing" \
# --prompt "supermario with glasses, mustache, blue overall, red short" \
# --prompt "Film still from Avatar, cinematograp by James Cameron, 2020, dramatic lighting, bokeh" \
# --prompt "stopmotion character, Kubo and the Two Strings, ParaNorman, Aardman, Laika Studios, grainy" \
# --prompt "detailed ink drawing, Lone Wolf and Cub manga panel 4 k, full body, sword slash, manga" \
# --prompt "masterpiece, best quality, flowers, sun, water, butterflies" \
# --prompt "Retro comic style artwork, highly detailed James Bond, comic book cover, symmetrical, vibrant"

# pushd CodeFormer
# numactl --cpunodebind=0 \
#     python inference_codeformer.py \
#     -w 0.7 --input_path ../s3/tmp/output/$1 \
#     --face_upsample \
#     --output_path ../s3/output/$1
# popd

# mv ../s3/output/$1/final_results/*.jpg ../s3/output/$1/
# rm -r ../s3/output/$1/{restored_faces,final_results,cropped_faces}
