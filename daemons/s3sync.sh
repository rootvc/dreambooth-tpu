#!/bin/bash
 
while true
do
    sudo -u ec2-user aws s3 sync s3://rootvc-dreambooth/input /home/ec2-user/rootvc/dreambooths3/input
    sudo -u ec2-user aws s3 sync /home/ec2-user/rootvc/dreambooth/s3/output s3://rootvc-dreambooth/output
    sleep 10
done
