#!/bin/bash

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io
    sudo usermod -aG docker $USER
    newgrp docker
    sudo systemctl enable docker
    sudo systemctl start docker
fi

# PostgreSQL
docker run -d --name postgres-db -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres

# MariaDB
docker run -d --name mariadb-db -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 mariadb

# MongoDB
docker run -d --name mongodb-db -p 27017:27017 mongo

# Redis
docker run -d --name redis-db -p 6379:6379 redis

# Adminer
docker run -d --name adminer -p 8080:8080 adminer

# Mongo Express
docker run -d --name mongo-express -e ME_CONFIG_MONGODB_SERVER=host.docker.internal -p 8081:8081 mongo-express

# Redis Commander
docker run -d --name redis-commander -p 8082:8082 rediscommander/redis-commander

echo "✅ All databases and dashboards are running via Docker."
