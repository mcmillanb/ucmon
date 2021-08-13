#!/bin/bash

if [ -f ".env" ]; then
echo "File exists"
else
echo "File does not exist"
touch .env
echo "DOCKER_INFLUXDB_INIT_MODE=setup" >> .env
echo "Enter username"
read user
echo "DOCKER_INFLUXDB_INIT_USERNAME=$user" >> .env
echo "Enter Password (minimum 8 cahracters)"
read password
echo "DOCKER_INFLUXDB_INIT_PASSWORD=$password" >> .env
echo "Organisation?"
read org
echo "DOCKER_INFLUXDB_INIT_ORG=$org" >> .env
echo "DOCKER_INFLUXDB_INIT_BUCKET=telegraf" >> .env
echo "INFLUXDB_PORT=8086" >> .env
echo "Initial build - please wait"
docker-compose up -d
echo "InfluxDB runnning, getting keys"
influx_op=""
while influx_op=""
do
    sleep 2
    influx_op=$(docker exec -it influxdb influx auth list)
done
testVar=$(echo $influx_op | sed -e 's/\r//g')
token=$(echo $testVar | grep -o -P '(?<=s Token ).*(?= admin)')
echo "Token is $token"
echo "INFLUX_TOKEN=$token" >> .env
echo "INFLUX_HOST=http://influxdb:8086" >> .env
echo "INFLUX_ORG=$org" >> .env



#docker run -d -p 8086:8086 --network ucmon --name=influxdb -v $PWD/influxdb2/data:/var/lib/influxdb2 -v $PWD/influxdb2/config:/etc/influxdb2 -e DOCKER_INFLUXDB_INIT_MODE=setup -e DOCKER_INFLUXDB_INIT_USERNAME=$user -e DOCKER_INFLUXDB_INIT_PASSWORD=$password -e DOCKER_INFLUXDB_INIT_ORG=$org -e DOCKER_INFLUXDB_INIT_BUCKET=ucmon influxdb:2.0.7-alpine
fi
