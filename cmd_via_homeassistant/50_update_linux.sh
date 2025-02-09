#!/bin/bash
apt update
apt full-upgrade -y
apt autoremove -y

echo "$(date +'%Y/%m/%d') - $(date +'%r') : (Log) sys update done." >> /opt/XXX/XXX/server_sys_log.txt
