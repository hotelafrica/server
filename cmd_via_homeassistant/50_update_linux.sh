#!/bin/bash
apt update
apt full-upgrade -y
apt autoremove -y

echo "$(date +'%Y/%m/%d') - $(date +'%r') : (Log) sys update done." >> /opt/shared_storage/server_sys_log.txt