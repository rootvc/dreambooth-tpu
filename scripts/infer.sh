#!/usr/bin/env bash

conda activate db
python ../src/inference.py "disney style animation of zwx person as protagonist in a disney film" 5
python ../src/inference.py "cartoon of zwx person as comic book superhero" 5
python ../src/inference.py "detailed oil painting high quality of zwx person in medieval knight armor" 5
python ../src/inference.py "cubist artwork of zwx person" 5
python ../src/inference.py "anime style cartoon of zwx person as anime character" 5

aws s3 sync ../output-images s3://rootvc-stable-diffusion/output-images
