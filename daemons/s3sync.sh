#!/bin/bash
set -x

source ~/.bashrc
 
while true
do
    aws s3 sync s3://rootvc-dreambooth/input $DREAMBOOTH_DIR/s3/input
    aws s3 sync $DREAMBOOTH_DIR/s3/output s3://rootvc-dreambooth/output
    sleep 10
done

set +x
