#!/usr/bin/env bash
set -x

echo Stopping all dreambooth daemons

sudo journalctl --vacuum-time=1s

sudo systemctl stop dreamwatcher.service
sudo systemctl status dreamwatcher.service

set +x
