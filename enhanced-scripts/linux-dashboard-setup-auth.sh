#!/bin/bash
# Enhanced Dashboard Setup with Authentication
# Secure management interfaces for all databases and monitoring

set -e  # Exit on any error

# Load environment variables
if [ -f ".env" ]; then
    source .env
    echo "✅ Loaded environment variables from .env"
else
    echo "⚠️ No .env file found - using default values"
    DASHBOARD_USERNAME=${DASHBOARD_USERNAME:-"admin"}
    DASHBOARD_PASSWORD=${DASHBOARD_PASSWORD:-"admin"}
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎛️ Enhanced Dashboard Setup Starting...${NC}"

# Function to check if port is available
check_port() {
    local port=$1
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo -e "${YELLOW}⚠️ Port $port is already in use${NC}"
        return 1
    fi
    return 0
}

# Function to wait for container to be healthy
wait_for_container() {
    local container_name=$1
    local max_attempts=30
    local attempt=1
    
    echo -e "${BLUE}⏳ Waiting for $container_name to be ready...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if docker ps --filter "name=$container_name" --filter "status=running" --format "{{.Names}}" | grep -q "$container_name"; then
            echo -e "${GREEN}✅ $container_name is running${NC}"
            return 0
        fi
        
        echo -e "${YELLOW}Attempt $attempt/$max_attempts - waiting for $container_name...${NC}"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}❌ $container_name failed to start within expected time${NC}"
    return 1
}

# Pre-flight checks
echo -e "${BLUE}🔍 Running dashboard pre-flight checks...${NC}"

# Check if database containers are running
required_dbs=("postgres-db" "mariadb-db" "mongodb-db" "redis-db")
missing_dbs=()

for db in "${required_dbs[@]}"; do
    if ! docker ps --filter "name=$db" --filter "status=running" --format "{{.Names}}" | grep -q "$db"; then
        missing_dbs+=("$db")
    fi
done

if [ ${#missing_dbs[@]} -ne 0 ]; then
    echo -e "${YELLOW}⚠️ Some database containers are not running: ${missing_dbs[*]}${NC}"
    echo -e "${BLUE}💡 Run ./enhanced-scripts/linux-db-setup-secure.sh first${NC}"
    read -p "Continue with dashboard setup anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Ensure network exists
docker network create dev-network 2>/dev/null || echo "Network dev-network already exists"

echo -e "${BLUE}🎛️ Starting enhanced dashboard containers...${NC}"

# Adminer (SQL Database Management) with authentication
echo -e "${BLUE}🗄️ Starting Adminer (SQL Database UI)...${NC}"
if check_port ${ADMINER_PORT:-8080}; then
    docker run -d \
        --name adminer \
        --network dev-network \
        -p ${BIND_ADDRESS:-127.0.0.1}:${ADMINER_PORT:-8080}:8080 \
        --restart unless-stopped \
        --memory=256m \
        -e ADMINER_DEFAULT_SERVER=postgres-db \
        -e ADMINER_DESIGN=pepa-linha \
        adminer:4
    
    wait_for_container "adminer"
else
    echo -e "${YELLOW}⚠️ Adminer port in use - skipping${NC}"
fi

# Mongo Express (MongoDB Management) with authentication
echo -e "${BLUE}🍃 Starting Mongo Express (MongoDB UI)...${NC}"
if check_port ${MONGO_EXPRESS_PORT:-8082}; then
    docker run -d \
        --name mongo-express \
        --network dev-network \
        -p ${BIND_ADDRESS:-127.0.0.1}:${MONGO_EXPRESS_PORT:-8082}:8081 \
        --restart unless-stopped \
        --memory=256m \
        -e ME_CONFIG_MONGODB_SERVER=mongodb-db \
        -e ME_CONFIG_MONGODB_PORT=27017 \
        -e ME_CONFIG_MONGODB_ADMINUSERNAME=${MONGODB_ROOT_USER:-admin} \
        -e ME_CONFIG_MONGODB_ADMINPASSWORD=${MONGODB_ROOT_PASSWORD:-admin} \
        -e ME_CONFIG_BASICAUTH_USERNAME=${DASHBOARD_USERNAME:-admin} \
        -e ME_CONFIG_BASICAUTH_PASSWORD=${DASHBOARD_PASSWORD:-admin} \
        mongo-express:1.0.0
    
    wait_for_container "mongo-express"
else
    echo -e "${YELLOW}⚠️ Mongo Express port in use - skipping${NC}"
fi

# Redis Commander (Redis Management)
echo -e "${BLUE}🔴 Starting Redis Commander (Redis UI)...${NC}"
if check_port ${REDIS_COMMANDER_PORT:-8083}; then
    redis_url="redis://redis-db:6379"
    if [ -n "$REDIS_PASSWORD" ]; then
        redis_url="redis://:$REDIS_PASSWORD@redis-db:6379"
    fi
    
    docker run -d \
        --name redis-commander \
        --network dev-network \
        -p ${BIND_ADDRESS:-127.0.0.1}:${REDIS_COMMANDER_PORT:-8083}:8081 \
        --restart unless-stopped \
        --memory=256m \
        -e REDIS_HOSTS=default:$redis_url \
        -e HTTP_USER=${DASHBOARD_USERNAME:-admin} \
        -e HTTP_PASSWORD=${DASHBOARD_PASSWORD:-admin} \
        rediscommander/redis-commander:latest
    
    wait_for_container "redis-commander"
else
    echo -e "${YELLOW}⚠️ Redis Commander port in use - skipping${NC}"
fi

# Portainer (Docker Management)
echo -e "${BLUE}🐳 Starting Portainer (Docker UI)...${NC}"
if check_port ${PORTAINER_PORT:-9000}; then
    docker volume create portainer-data 2>/dev/null || true
    
    docker run -d \
        --name portainer \
        --network dev-network \
        -p ${BIND_ADDRESS:-127.0.0.1}:${PORTAINER_PORT:-9000}:9000 \
        --restart unless-stopped \
        --memory=512m \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer-data:/data \
        portainer/portainer-ce:latest
    
    wait_for_container "portainer"
else
    echo -e "${YELLOW}⚠️ Portainer port in use - skipping${NC}"
fi

# Dozzle (Docker Log Viewer)
echo -e "${BLUE}📝 Starting Dozzle (Docker Logs UI)...${NC}"
if check_port ${DOZZLE_PORT:-9999}; then
    docker run -d \
        --name dozzle \
        --network dev-network \
        -p ${BIND_ADDRESS:-127.0.0.1}:${DOZZLE_PORT:-9999}:8080 \
        --restart unless-stopped \
        --memory=256m \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -e DOZZLE_USERNAME=${DASHBOARD_USERNAME:-admin} \
        -e DOZZLE_PASSWORD=${DASHBOARD_PASSWORD:-admin} \
        amir20/dozzle:latest
    
    wait_for_container "dozzle"
else
    echo -e "${YELLOW}⚠️ Dozzle port in use - skipping${NC}"
fi

# InfluxDB (Time Series Database for metrics)
echo -e "${BLUE}📈 Starting InfluxDB (Metrics Storage)...${NC}"
if check_port ${INFLUXDB_PORT:-8086}; then
    docker run -d \
        --name influxdb \
        --network dev-network \
        -p ${BIND_ADDRESS:-127.0.0.1}:${INFLUXDB_PORT:-8086}:8086 \
        --restart unless-stopped \
        --memory=512m \
        -v influxdb-data:/var/lib/influxdb2 \
        -e DOCKER_INFLUXDB_INIT_MODE=setup \
        -e DOCKER_INFLUXDB_INIT_USERNAME=${DASHBOARD_USERNAME:-admin} \
        -e DOCKER_INFLUXDB_INIT_PASSWORD=${DASHBOARD_PASSWORD:-admin} \
        -e DOCKER_INFLUXDB_INIT_ORG=dev-org \
        -e DOCKER_INFLUXDB_INIT_BUCKET=dev-metrics \
        -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=dev-token-2024 \
        influxdb:2.7
    
    wait_for_container "influxdb"
else
    echo -e "${YELLOW}⚠️ InfluxDB port in use - skipping${NC}"
fi

# Grafana (Visualization Dashboard)
echo -e "${BLUE}📊 Starting Grafana (Visualization Dashboard)...${NC}"
if check_port ${GRAFANA_PORT:-3000}; then
    docker run -d \
        --name grafana \
        --network dev-network \
        -p ${BIND_ADDRESS:-127.0.0.1}:${GRAFANA_PORT:-3000}:3000 \
        --restart unless-stopped \
        --memory=512m \
        -v grafana-data:/var/lib/grafana \
        -e GF_SECURITY_ADMIN_USER=${DASHBOARD_USERNAME:-admin} \
        -e GF_SECURITY_ADMIN_PASSWORD=${DASHBOARD_PASSWORD:-admin} \
        -e GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource \
        grafana/grafana:10.2.0
    
    wait_for_container "grafana"
else
    echo -e "${YELLOW}⚠️ Grafana port in use - skipping${NC}"
fi

# Create dashboard access summary
echo -e "${GREEN}🎉 Enhanced Dashboard Setup Complete!${NC}"
echo ""
echo -e "${BLUE}🎛️ Dashboard Access Information:${NC}"
echo ""
echo -e "${GREEN}Database Management:${NC}"
echo "  🗄️  Adminer (SQL DBs):      http://127.0.0.1:${ADMINER_PORT:-8080}"
echo "  🍃  Mongo Express:          http://127.0.0.1:${MONGO_EXPRESS_PORT:-8082} (user: ${DASHBOARD_USERNAME:-admin})"
echo "  🔴  Redis Commander:        http://127.0.0.1:${REDIS_COMMANDER_PORT:-8083} (user: ${DASHBOARD_USERNAME:-admin})"
echo ""
echo -e "${GREEN}System Management:${NC}"
echo "  🐳  Portainer (Docker):     http://127.0.0.1:${PORTAINER_PORT:-9000}"
echo "  📝  Dozzle (Logs):          http://127.0.0.1:${DOZZLE_PORT:-9999} (user: ${DASHBOARD_USERNAME:-admin})"
echo ""
echo -e "${GREEN}Monitoring & Analytics:${NC}"
echo "  📈  InfluxDB:               http://127.0.0.1:${INFLUXDB_PORT:-8086} (user: ${DASHBOARD_USERNAME:-admin})"
echo "  📊  Grafana:                http://127.0.0.1:${GRAFANA_PORT:-3000} (user: ${DASHBOARD_USERNAME:-admin})"
echo ""
echo -e "${GREEN}Development Databases:${NC}"
echo "  🌌  CosmosDB Data Explorer: https://127.0.0.1:8081/_explorer/index.html"
echo ""
echo -e "${BLUE}🔐 Security Notes:${NC}"
echo "  • All services bound to localhost (127.0.0.1) only"
echo "  • Default credentials: ${DASHBOARD_USERNAME:-admin}/${DASHBOARD_PASSWORD:-admin}"
echo "  • Change passwords in .env file for production use"
echo ""
echo -e "${BLUE}💡 Next steps:${NC}"
echo "  1. Access dashboards using the URLs above"
echo "  2. Configure Grafana data sources (InfluxDB, databases)"
echo "  3. Use ./dev-workflow/dev-env-status.sh to monitor all services"
echo "  4. Start development with ./dev-workflow/dev-env-start.sh"