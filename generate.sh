#!/usr/bin/env bash

if [[ $# -eq 0 ]]; then
    echo "ERROR: Provide an argument for the subject's unique identifier"
    exit 1
fi

export STEP=750
echo Generating images for $1
echo Transfer learning beginning at step: $STEP

mkdir -p s3/output/$1

echo Creating subject as Disney protagonist...
conda run -n db --no-capture-output python $DREAMBOOTH_DIR/src/inference.py \
    --prompt "disney style animation of $1 person as protagonist in a disney film" \
    --name disney \
    --id $1 \
    --num 4 \
    --step $STEP

echo Creating subject as comic book superhero...
conda run -n db --no-capture-output python $DREAMBOOTH_DIR/src/inference.py \
    --prompt "cartoon of $1 person as comic book superhero" \
    --name comicbook \
    --id $1 \
    --num 4 \
    --step $STEP

echo Creating subject as renaissance painting knight...
conda run -n db --no-capture-output python $DREAMBOOTH_DIR/src/inference.py \
    --prompt "detailed oil painting high quality of $1 person in medieval knight armor" \
    --name oilpainting \
    --id $1 \
    --num 4 \
    --step $STEP

echo Creating subject in cubist style...
conda run -n db --no-capture-output python $DREAMBOOTH_DIR/src/inference.py \
    --prompt "cubist artwork of $1 person" \
    --name cubist \
    --id $1 \
    --num 4 \
    --step $STEP

echo Creating subject as anime character...
conda run -n db --no-capture-output python $DREAMBOOTH_DIR/src/inference.py \
    --prompt "anime style cartoon of $1 person as anime character" \
    --name anime \
    --id $1 \
    --num 4 \
    --step $STEP

echo Uploading to AWS S3 bucket...
aws s3 sync s3://rootvc-dreambooth/output/$1 $DREAMBOOTH_DIR/s3/output/$1
