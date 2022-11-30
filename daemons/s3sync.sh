#!/bin/bash
 
while true
do
    aws s3 sync s3://rootvc-dreambooth/input ~/dreambooth/s3/input
    aws s3 sync s3://rootvc-dreambooth/output ~/dreambooth/s3/output
    sleep 10
done
