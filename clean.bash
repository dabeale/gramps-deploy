#!/usr/bin/env bash

# Enter the script directory
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

# remove running containers
docker compose down

# Remove non persistent containers
docker volume rm $(docker volume ls -q)
