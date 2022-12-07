#!/usr/bin/env bash
set -x

echo Updating and restarting daemons

sudo journalctl --vacuum-time=1s

sudo cp daemons/*.sh /usr/bin/
sudo cp daemons/*.service /lib/systemd/system/
sudo systemctl daemon-reload

sudo systemctl restart s3sync.service
sudo systemctl restart dreamwatcher.service
sudo systemctl restart pbsync.service

sudo systemctl status s3sync.service
sudo systemctl status dreamwatcher.service
sudo systemctl status pbsync.service

set +x
