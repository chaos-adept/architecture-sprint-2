#!/bin/bash

set -x
set -e

script_full_path=$(dirname "$0")
cd $script_full_path

echo "docker compose down volumes"

docker compose down --volumes


echo "docker compose ps"

docker compose ps