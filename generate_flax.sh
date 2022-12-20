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
    --prompt "anime character, naruto, scene from an anime cartoon, japanese anime, shonen jump" \
    --prompt "an assassin sneaking through a dilapidated alley, movie still, 30mm" \
    --prompt "gorgeous, ((stunning)), black straight hair, tight silver jacket, samadhi loving serene, ((35mm head and shoulders portrait, looking into camera)), intricate, 8k, highly detailed, volumetric lighting, digital painting, intense gaze, sharp focus, ((Alena Aenami)), I merged so completely with Love, and was so fused, that I became Love and Love became me" \
    --prompt "winter gothic, leather, gothic jewellery, flowing cloak, elegant pose, outdoors, winter, snow, close up" \
    --prompt "impressionist painting, Daniel F Gerhartz, nature" \
    --prompt "pencil sketch, 4 k, 8 k, absolute detail, black and white drawing" \
    --prompt "detailed ink drawing, Lone Wolf and Cub manga panel 4 k, full body, sword slash, manga" \
    --prompt "colorful cinematic still with glasses, armor, cyberpunk, with a xenonorph, in alien movie (1986),background made of brain cells, organic, ultrarealistic, leic 30mm" \
    --prompt "dying soldier in the trenches of world war one, army uniform, depressing, grey, morose" \
    --prompt "advanced organic armor, biological filigree, flowing hair, neon details, intricate, elegant, highly detailed, digital painting, artstation, concept art, smooth, sharp focus, octane, art by Krenz Cushart , Artem Demura, Alphonse Mucha, digital cgi art 8K HDR by Yuanyuan Wang photorealistic" \
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
