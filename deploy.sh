#!/bin/bash

if [ -f ".env" ]; then
echo "File exists"
else
echo "File does not exist"touch .env
echo "DOCKER_INFLUXDB_INIT_MODE=setup" >> .env
echo "Setting up admin user, enter username"
read user
echo "DOCKER_INFLUXDB_INIT_USERNAME=$user" >> .env
echo "Enter Password (minimum 8 characters)"
read password
echo "DOCKER_INFLUXDB_INIT_PASSWORD=$password" >> .env
echo "Organisation?"
read org
echo "DOCKER_INFLUXDB_INIT_ORG=$org" >> .env
echo "DOCKER_INFLUXDB_INIT_BUCKET=telegraf" >> .env
echo "INFLUXDB_PORT=8086" >> .env
echo "Initial build - please wait"
cp docker-compose.yml.1 docker-compose.yml
docker-compose up -d
echo "Waiting 30 seconds to get API key...."
sleep 30
influx_op=$(docker exec -it influxdb influx auth list)
testVar=$(echo $influx_op | sed -e 's/\r//g')
token=$(echo $testVar | grep -o -P "(?<=s Token ).*(?= $user)")
echo "Token is $token"
echo "Setting up initial parameters"
echo "INFLUX_TOKEN=$token" >> .env
echo "INFLUX_HOST=influxdb" >> .env
echo "INFLUX_ORG=$org" >> .env
docker exec -it influxdb influx bucket create --name ucmon
docker exec -it influxdb influx telegrafs create --name telegraf -f /etc/influxdb2/telegraf.conf

echo "Restarting services"
docker-compose down
rm docker-compose.yml
cp docker-compose.yml.2 docker-compose.yml
docker-compose up -d

fi
