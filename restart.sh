#!/usr/bin/env bash
set -x

echo Updating and restarting daemons

sudo cp daemons/*.sh /usr/bin/
sudo cp daemons/*.service /lib/systemd/system/
sudo systemctl daemon-reload

sudo systemctl restart s3sync.service
sudo systemctl restart dreamwatcher.service

sudo systemctl status s3sync.service
sudo systemctl status dreamwatcher.service

set +x