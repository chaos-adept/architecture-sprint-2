#!/bin/bash

set -e

script_full_path=$(dirname "$0")

echo "docker compose up"
docker compose up -d

echo "init data"
bash "$script_full_path/mongo-init.sh"

echo "app - get root"
curl -s -X 'GET' \
  'http://localhost:8080/' \
  -H 'accept: application/json' | jq

echo "app - get document count"
curl -s -X 'GET' \
  'http://localhost:8080/helloDoc/count' \
  -H 'accept: application/json' | jq

 