#!/usr/bin/env bash

echo Creating 5 images of subject as Disney protagonist...
conda run -n db bash -c 'python ./src/inference.py "disney style animation of zwx person as protagonist in a disney film" 5 > /dev/tty 2>&1'

echo Creating 5 images of subject as comic book superhero...
conda run -n db bash -c 'python ./src/inference.py "cartoon of zwx person as comic book superhero" 5 > /dev/tty 2>&1'

echo Creating 5 images of subject as renaissance painting knight...
conda run -n db bash -c 'python ./src/inference.py "detailed oil painting high quality of zwx person in medieval knight armor" 5 > /dev/tty 2>&1'

echo Creating 5 images of subject in cubist style...
conda run -n db bash -c 'python ./src/inference.py "cubist artwork of zwx person" 5 > /dev/tty 2>&1'

echo Creating 5 images of subject as anime character...
conda run -n db bash -c 'python ./src/inference.py "anime style cartoon of zwx person as anime character" 5 > /dev/tty 2>&1'

echo Uploading to AWS S3 bucket...
conda run -n db bash -c 'aws s3 sync ./output-images s3://rootvc-stable-diffusion/output-images > /dev/tty 2>&1'
