#!/bin/bash

if [ -f ".env" ]; then
echo "File exists"
else
echo "File does not exist"
touch .env
echo "Enter username"
read user
echo "Enter Password (minimum 8 cahracters)"
read password
echo "Organisation?"
read org
docker network create --driver bridge ucmon
docker run -d -p 8086:8086 --network ucmon --name=influxdb -v $PWD/influxdb2/data:/var/lib/influxdb2 -v $PWD/influxdb2/config:/etc/influxdb2 -e DOCKER_INFLUXDB_INIT_MODE=setup -e DOCKER_INFLUXDB_INIT_USERNAME=$user -e DOCKER_INFLUXDB_INIT_PASSWORD=$password -e DOCKER_INFLUXDB_INIT_ORG=$org -e DOCKER_INFLUXDB_INIT_BUCKET=ucmon influxdb:2.0.7-alpine
fi
