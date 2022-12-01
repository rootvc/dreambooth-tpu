#!/bin/bash

while true
do
    # Use the .processing empty file as a way to know if the system is occupied
    # I'm not sure if this is necessary. Does the service runner let this process block, or does it launch new ones while this process is blocked?
    
    if [ -f $DREAMBOOTH_DIR/daemons/.processing ]
    then
        echo 'Waiting for existing job to finish...'
    else
        echo 'Checking for new jobs...'
        touch $DREAMBOOTH_DIR/.processing
        conda run -n db --no-capture-output python $DREAMBOOTH_DIR/daemons/src/process.py
        rm $DREAMBOOTH_DIR/daemons/.processing  
    fi
    
    sleep 10
done
