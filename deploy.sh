#!/bin/bash

if [ -f ".env" ]; then
echo "File exists"
else
echo "File does not exist"touch .env
echo "DOCKER_INFLUXDB_INIT_MODE=setup" >> .env
echo "Setting up admin user"
#read user
echo "DOCKER_INFLUXDB_INIT_USERNAME=admin" >> .env
echo "Enter Password (minimum 8 characters)"
read password
echo "DOCKER_INFLUXDB_INIT_PASSWORD=$password" >> .env
echo "Organisation?"
read org
echo "DOCKER_INFLUXDB_INIT_ORG=$org" >> .env
echo "DOCKER_INFLUXDB_INIT_BUCKET=ucmon" >> .env
echo "INFLUXDB_PORT=8086" >> .env
echo "Initial build - please wait"
docker-compose up -d
echo "InfluxDB runnning, getting keys"
sleep 30
influx_op=$(docker exec -it influxdb influx auth list)
echo "$influx_op"
testVar=$(echo $influx_op | sed -e 's/\r//g')
echo "$testVar"
token=$(echo $testVar | grep -o -P '(?<=s Token ).*(?= admin)')
echo "Token is $token"
echo "INFLUX_TOKEN=$token" >> .env
echo "INFLUX_HOST=http://influxdb:8086" >> .env
echo "INFLUX_ORG=$org" >> .env
echo "Restarting services"
docker-compose down
docker-compose up -d

fi
