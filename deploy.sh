#!/bin/bash
clear
if [ -f ".env" ]; then
echo "Configuration already exists in .env"
else
echo "Creating new configuration"
touch .env

#Get configuration information

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
echo "INFLUX_PORT=8086" >> .env
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
echo "GRAFANA_PORT=3000" >> .env
echo "GRAFANA_USER=$user" >> .env
echo "GRAFANA_PASSWORD=$password" >> .env
echo "GRAFANA_PLUGINS_ENABLED=true" >> .env
echo "GRAFANA_PLUGINS=grafana-piechart-panel" >> .env
docker exec -it influxdb influx bucket create --name ucmon
docker exec -it influxdb influx telegrafs create --name telegraf -f /etc/influxdb2/telegraf.conf


#Restart all containers
echo "Restarting services"
docker-compose down
rm docker-compose.yml
cp docker-compose.yml.2 docker-compose.yml
docker-compose up -d
echo "Waiting 30 seconds for services to start...."
sleep 30
#Configure grafana
curl -X POST -H "Content-Type: application/json" -d "{\"name\":\"$org\"}" http://admin:admin@localhost:3000/api/orgs
curl -X POST http://admin:admin@localhost:3000/api/user/using/2
curl -X POST --insecure -H "Content-Type: application/json" -d "{\"orgId\":2,\"name\":\"InfluxDB\",\"type\":\"influxdb\",\"typeLogoUrl\":\"\",\"access\":\"proxy\",\"url\":\"http://influxdb:8086\",\"password\":\"\",\"user\":\"\",\"database\":\"\",\"basicAuth\":false,\"basicAuthUser\":\"\",\"basicAuthPassword\":\"\",\"withCredentials\":false,\"isDefault\":false,\"jsonData\:{\"defaultBucket\":\"telegraf\",\"httpMode\":\"POST\",\"organization\":\"$org\",\"version\":\"Flux\"},\"secureJsonData\":{\"token\":\"$token\"},\"version\":2,\"readOnly\":false}" http://admin:admin@localhost:3000/api/datasources
if [ "$user" = "foo" ]; then
echo "Setting password for admin user"
curl -X PUT -H "Content-Type: application/json" -d "{\"oldPassword\":\"admin\",\"newPassword\":\"$password\"}" http://admin:admin@localhost:3000/api/user/password
else
echo "Creating grafana user"
curl -X POST -H "Content-Type: application/json" -d "{\"name\":\"$user\",\"email\":\"$user@graf.com\",\"login\":\"$user\",\"password\":\"$password\",\"OrgId\": 2}" http://admin:admin@localhost:3000/api/admin/users
curl -X PUT -H "Content-Type: application/json" -d '{"isGrafanaAdmin": true}' http://admin:admin@localhost:3000/api/admin/users/2/permissions
curl -X PATCH -H "Content-Type: application/json" -d '{"role":"Admin"}' http://admin:admin@localhost:3000/api/org/users/2
fi

fi
