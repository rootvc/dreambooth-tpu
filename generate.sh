#!/usr/bin/env bash

export STEP=750
echo Generating images for $1
echo Transfer learning beginning at step: $STEP

echo Creating subject as Disney protagonist...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "disney style animation of $1 person as protagonist in a disney film" \
    --name disney \
    --id $1 \
    --num 4 \
    --step $STEP

echo Creating subject as comic book superhero...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "cartoon of $1 person as comic book superhero" \
    --name comicbook \
    --id $1 \
    --num 4 \
    --step $STEP

echo Creating subject as renaissance painting knight...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "detailed oil painting high quality of $1 person in medieval knight armor" \
    --name oilpainting \
    --id $1 \
    --num 4 \
    --step $STEP

echo Creating subject in cubist style...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "cubist artwork of $1 person" \
    --name cubist \
    --id $1 \
    --num 4 \
    --step $STEP

echo Creating subject as anime character...
conda run -n db --no-capture-output python ./src/inference.py \
    --prompt "anime style cartoon of $1 person as anime character" \
    --name anime \
    --id $1 \
    --num 4 \
    --step $STEP

echo Uploading to AWS S3 bucket...
conda run -n db --no-capture-output aws s3 sync ./s3/output s3://rootvc-stable-diffusion/output
