#!/bin/bash
 
while true
do
    aws s3 sync s3://rootvc-dreambooth/input /home/ec2-user/rootvc/dreambooth/s3/input
    aws s3 sync /home/ec2-user/rootvc/dreambooth/s3/output s3://rootvc-dreambooth/output
    sleep 10
done
