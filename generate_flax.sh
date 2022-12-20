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
    --prompt "scene from an animated tv show, disney short, colorful" \
    --prompt "anime character, naruto, scene from an anime cartoon" \
    --prompt "ninja, thief, cyberpunk, synthwave, retro, bold, sneaky pose" \
    --prompt "winter gothic, leather, gothic jewellery, flowing cloak, elegant pose" \
    --prompt "impressionist painting, Daniel F Gerhartz, nature" \
    --prompt "pencil sketch, 4 k, 8 k, absolute detail, black and white drawing" \
    --prompt "Film still from Avatar, cinematography by James Cameron, 2020, dramatic lighting, bokeh" \
    --prompt "detailed ink drawing, Lone Wolf and Cub manga panel 4 k, full body, sword slash, manga" \
    --prompt "hallucination from 1970, hippie, tripping, acid, rainbow, daydream" \
    --prompt "cinematic still, person with glasses as rugged warrior, threatening xenomorph, alien movie" \
    --prompt "colorful cinematic still of sksxvs2 man with glasses, armor, cyberpunk, with a xenonorph, in alien movie (1986),background made of brain cells, organic, ultrarealistic, leic 30mm" \
    --prompt "teampunk warrior, neon organic vines, glasses, digital painting" \
    --prompt "soldier in world war one, dreary, depressing, grey, raining" \
    --prompt "person in advanced organic armor, biological filigree, flowing hair, neon details, intricate, elegant, highly detailed, digital painting, artstation, concept art, smooth, sharp focus, octane, art by Krenz Cushart , Artem Demura, Alphonse Mucha, digital cgi art 8K HDR by Yuanyuan Wang photorealistic" \
    --prompt "Retro comic style artwork, highly detailed James Bond, comic book cover, symmetrical, vibrant"

# pushd CodeFormer
# numactl --cpunodebind=0 \
#     python inference_codeformer.py \
#     -w 0.7 --input_path ../s3/tmp/output/$1 \
#     --face_upsample \
#     --output_path ../s3/output/$1
# popd

# mv ../s3/output/$1/final_results/*.jpg ../s3/output/$1/
# rm -r ../s3/output/$1/{restored_faces,final_results,cropped_faces}
