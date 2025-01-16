#!/bin/bash

#set -x
set -e

echo "docker compose down volumes"

docker compose down --volumes

echo "docker compose ps"

docker compose ps