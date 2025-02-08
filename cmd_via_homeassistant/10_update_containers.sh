#!/bin/bash


# ### blind update, no smart logging/updating

cd /opt/docker/gluetun_qbit
docker compose pull
docker compose up -d
docker image prune -af
docker volume prune -f





