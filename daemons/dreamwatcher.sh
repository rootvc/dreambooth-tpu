#!/bin/bash

source ~/.bashrc

while true
do    
    # Download metadata from photobooth
    aws s3 cp s3://rootvc-dreambooth/sparkbooth/prompts.txt s3://rootvc-dreambooth/data/prompts.txt
    aws s3 sync s3://rootvc-dreambooth/data $DREAMBOOTH_DIR/s3/data
    mv $DREAMBOOTH_DIR/s3/data/prompts.txt $DREAMBOOTH_DIR/s3/data/prompts.tsv
    
    # Execute python script that checks for new inputs and processing
    conda run -n db --no-capture-output python $DREAMBOOTH_DIR/daemons/src/dreamwatcher.py
    
    sleep 10
done
