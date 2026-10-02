#!/bin/sh
set -eu

LOCAL_UID=$(id -u)
LOCAL_GID=$(id -g)
export LOCAL_UID LOCAL_GID

docker compose --progress plain build
docker compose up