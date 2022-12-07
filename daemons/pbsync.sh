#!/bin/bash
set -x

source ~/.bashrc
 
while true
do
    aws s3 sync s3://rootvc-dreambooth/photobooth-input $DREAMBOOTH_DIR/s3/photobooth-input
    aws s3 sync s3://rootvc-dreambooth/input $DREAMBOOTH_DIR/s3/input # make sure we are at lastest
    aws s3 sync s3://rootvc-dreambooth/photobooth-layouts/prompts.txt $DREAMBOOTH_DIR/s3/photobooth-input
    conda run -n db --no-capture-output python $DREAMBOOTH_DIR/daemons/src/pbsync.py # outputs to s3/input
    aws s3 sync $DREAMBOOTH_DIR/s3/input s3://rootvc-dreambooth/input
    sleep 10
done

set +x
