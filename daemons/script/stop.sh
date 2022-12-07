#!/usr/bin/env bash
set -x

echo Stopping all dreambooth daemons

sudo journalctl --vacuum-time=1s

sudo systemctl stop s3sync.service
sudo systemctl stop dreamwatcher.service
sudo systemctl stop pbsync.service

sudo systemctl status s3sync.service
sudo systemctl status dreamwatcher.service
sudo systemctl status pbsync.service

set +x
