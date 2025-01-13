#!/bin/bash

set -e

script_full_path=$(dirname "$0")

echo "docker compose up"
docker compose up -d

echo "sleep 5 sec"
sleep 5

echo "init data"
bash "$script_full_path/mongo-init.sh"


echo "sleep 5 sec"
sleep 5

echo "app - get root"
curl -s -X 'GET' \
  'http://localhost:8080/' \
  -H 'accept: application/json' | jq

echo "app - first get doc count"
curl -o /dev/null -s -w 'Total: %{time_total}s\n'  http://localhost:8080/helloDoc/users
echo "app - second get doc count"
curl -o /dev/null -s -w 'Total: %{time_total}s\n'  http://localhost:8080/helloDoc/users


echo "app - get document count"
curl -s -X 'GET' \
  'http://localhost:8080/helloDoc/count' \
  -H 'accept: application/json' | jq

 