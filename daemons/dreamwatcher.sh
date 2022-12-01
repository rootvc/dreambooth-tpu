#!/bin/bash
set -x

while true
do
    # Use the .processing empty file as a way to know if the system is occupied
    
    if test -f /home/ec2-user/rootvc/dreambooth/daemons/.processing; then
        touch /home/ec2-user/rootvc/dreambooth/daemons/.processing
        sudo ec2-user conda run -n db --no-capture-output python -m /home/ec2-user/rootvc/dreambooth/daemons/src/process.py
        rm /home/ec2-user/rootvc/dreambooth/daemons/.processing  
    fi
    sleep 10
done

set +x
