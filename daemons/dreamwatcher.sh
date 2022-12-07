#!/bin/bash

source ~/.bashrc
cd $DREAMBOOTH_DIR

while true; do
    aws s3 sync s3://rootvc-dreambooth/photobooth-input ./s3/photobooth-input
    aws s3 cp s3://rootvc-dreambooth/data/prompts.txt ./s3/data/prompts.tsv
    conda run -n db --no-capture-output python daemons/src/process
    aws s3 sync ./s3/output s3://rootvc-dreambooth/output
    sleep 10
done
