#!/usr/bin/env bash
set -e

if [[ $# -eq 0 ]]; then
    echo "ERROR: Provide an argument for the subject's unique identifier"
    exit 1
fi

export RETRAIN_STEP=450
cd $DREAMBOOTH_DIR

echo Generating images for $1
echo Transfer learning beginning at step: $RETRAIN_STEP

mkdir -p ./s3/output/$1

echo Creating subject as Disney protagonist...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "disney style animation of one sks person as protagonist in a disney film" \
    --name disney \
    --id $1 \
    --num 4 \
    --step $RETRAIN_STEP

echo Creating subject as comic book superhero...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "cartoon of one sks person as comic book superhero" \
    --name comicbook \
    --id $1 \
    --num 4 \
    --step $RETRAIN_STEP

# echo Creating subject as Simpsons character...
# conda run -n db --no-capture-output python ./src/inference.py \
#     --prompt "a Simpsons cartoon drawing of sks person in the style of the Simpsons by Matt Groenig" \
#     --name simpsons \
#     --id $1 \
#     --num 4 \
#     --step $RETRAIN_STEP

echo Creating subject as anime character...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "anime style cartoon of sks person as anime character" \
    --name anime \
    --id $1 \
    --num 4 \
    --step $RETRAIN_STEP

echo Creating subject as Roy Lichtenstein poster...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "a Lichtenstein poster of sks person in the style of Roy Lichtenstein" \
    --name lichenstein \
    --id $1 \
    --num 4 \
    --step $RETRAIN_STEP

echo Creating subject as Hokusai painting...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "a painting of sks person in the style of Hokusai" \
    --name hokusai \
    --id $1 \
    --num 4 \
    --step $RETRAIN_STEP

echo Creating subject as an Andy Warhol print...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "a silk screen of sks person in the style of Andy Warhol" \
    --name warhol \
    --id $1 \
    --num 4 \
    --step $RETRAIN_STEP

echo Creating subject as a Lego figure...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "a realistic photo of sks person made from lego" \
    --name lego \
    --id $1 \
    --num 4 \
    --step $RETRAIN_STEP

echo Creating subject as anime action hero...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "a Japanese anime drawing of sks person using ninja techniques" \
    --name animeaction \
    --id $1 \
    --num 4 \
    --step $RETRAIN_STEP

echo Creating subject as a Studio Ghibli character...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "a cartoon drawing of sks person in the style of a Studio Ghibli anime film" \
    --name ghibli \
    --id $1 \
    --num 4 \
    --step $RETRAIN_STEP

echo Creating subject as an oil painting...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "a realistic oil painting of sks person wearing stylish middle ages attire" \
    --name oilpaintingstylish \
    --id $1 \
    --num 4 \
    --step $RETRAIN_STEP

echo Uploading to AWS S3 bucket...
aws s3 sync ./s3/output/$1 s3://rootvc-dreambooth/output/$1
