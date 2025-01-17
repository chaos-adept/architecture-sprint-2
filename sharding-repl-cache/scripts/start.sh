#!/bin/bash

set -x
set -e

script_full_path=$(dirname "$0")
cd $script_full_path

echo "docker compose up"
docker compose up -d

echo "init data"
./mongo-init.sh

docker compose ps

echo "app - get root"
curl -s -X 'GET' \
  'http://localhost:8080/' \
  -H 'accept: application/json' | jq

echo "check caching"
echo "app - first get doc count"
curl -o /dev/null -s -w 'Total: %{time_total}s\n'  http://localhost:8080/helloDoc/users
echo "app - second get doc count"
curl -o /dev/null -s -w 'Total: %{time_total}s\n'  http://localhost:8080/helloDoc/users


echo "app - get document count"
curl -s -X 'GET' \
  'http://localhost:8080/helloDoc/count' \
  -H 'accept: application/json' | jq

 