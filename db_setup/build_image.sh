#!/bin/bash

# creates env variable with absolute path to physionet raw data and then
# calls docke compose command to run container

project_root="$(dirname "$(dirname "$(readlink -fm "$0")")")"
export MIMICIII_CSV_DIR=$project_root/data/physionet.org/files/mimiciii/1.4
docker compose -f $project_root/db_setup/docker-compose.yml build --no-cache