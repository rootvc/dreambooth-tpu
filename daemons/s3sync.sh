#!/bin/bash
set -x
 
while true
do
    sudo -u ec2-user aws s3 sync s3://rootvc-dreambooth/input /home/ec2-user/rootvc/dreambooth/s3/input
    sudo -u ec2-user aws s3 sync s3://rootvc-dreambooth/output /home/ec2-user/rootvc/dreambooth/s3/output 

    sleep 10
done

set +x
