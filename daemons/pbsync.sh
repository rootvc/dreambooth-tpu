#!/bin/bash
set -x

source ~/.bashrc

export PB_INPUT_BUCKET=photobooth-input
export PB_OUTPUT_DIR=pb-output
 
while true
do
    aws s3 sync s3://rootvc-dreambooth/$PB_INPUT_BUCKET $DREAMBOOTH_DIR/s3/$PB_OUTPUT_DIR
    aws s3 sync s3://rootvc-dreambooth/input $DREAMBOOTH_DIR/s3/input # make sure we are at lastest
    conda run -n db --no-capture-output python $DREAMBOOTH_DIR/daemons/src/pbsync.py # outputs to s3/input
    aws s3 sync $DREAMBOOTH_DIR/s3/input s3://rootvc-dreambooth/input
    sleep 10
done

set +x
