#!/bin/bash

while true
do
    # Use the .processing empty file as a way to know if the system is occupied
    # I'm not sure if this is necessary. Does the service runner let this process block, or does it launch new ones while this process is blocked?
    
    if [ -f /home/ec2-user/rootvc/dreambooth/daemons/.processing ]
    then
        echo 'waiting for existing job to finish'
    else
        echo 'checking for new jobs'
        touch /home/ec2-user/rootvc/dreambooth/daemons/.processing
        sudo ec2-user conda run -n db --no-capture-output python -m /home/ec2-user/rootvc/dreambooth/daemons/src/process.py
        rm /home/ec2-user/rootvc/dreambooth/daemons/.processing  
    fi
    
    sleep 10
done
