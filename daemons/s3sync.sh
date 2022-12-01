#!/bin/bash
set -x
 
while true
do
    aws s3 sync s3://rootvc-dreambooth/input $DREAMBOOTH_DIR/s3/input
    aws s3 sync s3://rootvc-dreambooth/output $DREAMBOOTH_DIR/s3/output 

    sleep 10
done

set +x
