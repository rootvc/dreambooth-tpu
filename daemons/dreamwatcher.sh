#!/bin/bash

source ~/.bashrc

while true
do
    # Execute python script that checks for new inputs and processing
    conda run -n db --no-capture-output python $DREAMBOOTH_DIR/daemons/src/process.py
    echo Finished processing last input
    sleep 10
done
