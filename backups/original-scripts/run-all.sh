#!/bin/bash
# Restart all project containers

docker start postgres-db mariadb-db mongodb-db redis-db \
  adminer mongo-express redis-commander \
  portainer dozzle influxdb grafana

echo "✅ All services started."
