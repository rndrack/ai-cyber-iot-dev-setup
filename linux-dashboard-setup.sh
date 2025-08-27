#!/bin/bash

# Install Portainer (Docker UI)
docker run -d --name portainer -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce

# Install Dozzle (Real-time container logs UI)
docker run -d --name dozzle -p 9999:8080 -v /var/run/docker.sock:/var/run/docker.sock amir20/dozzle

# Install InfluxDB (for metrics collection)
docker run -d --name influxdb -p 8086:8086 influxdb

# Install Grafana (dashboard for IoT/metrics)
docker run -d --name grafana -p 3000:3000 grafana/grafana

echo "✅ Dashboards installed:"
echo "Portainer     → http://localhost:9000"
echo "Dozzle        → http://localhost:9999"
echo "InfluxDB      → http://localhost:8086"
echo "Grafana       → http://localhost:3000"
