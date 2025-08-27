#!/bin/bash
# Enhanced Database Setup with CosmosDB Emulator
# Secure configuration for WSL2 root user environment

set -e  # Exit on any error

# Load environment variables
if [ -f ".env" ]; then
    source .env
    echo "✅ Loaded environment variables from .env"
else
    echo "⚠️ No .env file found - using default values"
    POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-"postgres"}
    MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-"root"}
    REDIS_PASSWORD=${REDIS_PASSWORD:-""}
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Enhanced Database Setup Starting...${NC}"

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
echo -e "${BLUE}🔍 Running pre-flight checks...${NC}"

# Check Docker functionality
if ! docker --version >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not working properly${NC}"
    echo -e "${YELLOW}💡 Run docker-fixes/docker-wsl2-recovery.sh first${NC}"
    exit 1
fi

# Check available memory
available_memory=$(free -g | awk 'NR==2{printf "%.0f", $7}')
if [ "$available_memory" -lt 4 ]; then
    echo -e "${YELLOW}⚠️ Available memory is ${available_memory}GB - CosmosDB may not start (requires 3GB+)${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Remove existing containers if they exist (with data backup option)
echo -e "${BLUE}🔄 Checking for existing containers...${NC}"
for container in postgres-db mariadb-db mongodb-db redis-db cosmosdb-emulator; do
    if docker ps -a --filter "name=$container" --format "{{.Names}}" | grep -q "$container"; then
        echo -e "${YELLOW}Found existing container: $container${NC}"
        read -p "Remove existing $container? Data will be lost unless backed up (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}🗑️ Removing $container...${NC}"
            docker stop "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
        else
            echo -e "${BLUE}ℹ️ Skipping $container - will attempt to start alongside${NC}"
        fi
    fi
done

# Create Docker network for inter-container communication
echo -e "${BLUE}🌐 Setting up Docker network...${NC}"
docker network create dev-network 2>/dev/null || echo "Network dev-network already exists"

echo -e "${BLUE}📦 Starting enhanced database containers...${NC}"

# PostgreSQL with enhanced security
echo -e "${BLUE}🐘 Starting PostgreSQL...${NC}"
if check_port ${POSTGRES_PORT:-5432}; then
    docker run -d \
        --name postgres-db \
        --network dev-network \
        -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
        -e POSTGRES_DB=${POSTGRES_DB:-devdb} \
        -p ${BIND_ADDRESS:-127.0.0.1}:${POSTGRES_PORT:-5432}:5432 \
        --restart unless-stopped \
        --memory=${POSTGRES_MAX_MEMORY:-512m} \
        -v postgres-data:/var/lib/postgresql/data \
        postgres:15
    
    wait_for_container "postgres-db"
else
    echo -e "${YELLOW}⚠️ PostgreSQL port in use - skipping${NC}"
fi

# MariaDB with enhanced security
echo -e "${BLUE}🐬 Starting MariaDB...${NC}"
if check_port ${MARIADB_PORT:-3306}; then
    docker run -d \
        --name mariadb-db \
        --network dev-network \
        -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
        -e MYSQL_DATABASE=${MYSQL_DATABASE:-devdb} \
        -e MYSQL_USER=${MYSQL_USER:-devuser} \
        -e MYSQL_PASSWORD=${MYSQL_PASSWORD:-devpass} \
        -p ${BIND_ADDRESS:-127.0.0.1}:${MARIADB_PORT:-3306}:3306 \
        --restart unless-stopped \
        --memory=${MARIADB_MAX_MEMORY:-512m} \
        -v mariadb-data:/var/lib/mysql \
        mariadb:10.11
    
    wait_for_container "mariadb-db"
else
    echo -e "${YELLOW}⚠️ MariaDB port in use - skipping${NC}"
fi

# MongoDB with authentication
echo -e "${BLUE}🍃 Starting MongoDB...${NC}"
if check_port ${MONGODB_PORT:-27017}; then
    docker run -d \
        --name mongodb-db \
        --network dev-network \
        -e MONGO_INITDB_ROOT_USERNAME=${MONGODB_ROOT_USER:-admin} \
        -e MONGO_INITDB_ROOT_PASSWORD=${MONGODB_ROOT_PASSWORD:-admin} \
        -e MONGO_INITDB_DATABASE=${MONGODB_DATABASE:-devdb} \
        -p ${BIND_ADDRESS:-127.0.0.1}:${MONGODB_PORT:-27017}:27017 \
        --restart unless-stopped \
        --memory=${MONGODB_MAX_MEMORY:-1g} \
        -v mongodb-data:/data/db \
        mongo:7
    
    wait_for_container "mongodb-db"
else
    echo -e "${YELLOW}⚠️ MongoDB port in use - skipping${NC}"
fi

# Redis with password protection
echo -e "${BLUE}🔴 Starting Redis...${NC}"
if check_port ${REDIS_PORT:-6379}; then
    redis_cmd="redis-server"
    if [ -n "$REDIS_PASSWORD" ]; then
        redis_cmd="redis-server --requirepass $REDIS_PASSWORD"
    fi
    
    docker run -d \
        --name redis-db \
        --network dev-network \
        -p ${BIND_ADDRESS:-127.0.0.1}:${REDIS_PORT:-6379}:6379 \
        --restart unless-stopped \
        --memory=${REDIS_MAX_MEMORY:-256m} \
        -v redis-data:/data \
        redis:7-alpine \
        $redis_cmd
    
    wait_for_container "redis-db"
else
    echo -e "${YELLOW}⚠️ Redis port in use - skipping${NC}"
fi

# Azure CosmosDB Emulator
echo -e "${BLUE}🌌 Starting Azure CosmosDB Emulator...${NC}"
if check_port ${COSMOSDB_PORT:-8081}; then
    echo -e "${YELLOW}ℹ️ CosmosDB Emulator requires significant resources (3GB+ memory)${NC}"
    
    docker run -d \
        --name cosmosdb-emulator \
        --network dev-network \
        -p ${BIND_ADDRESS:-127.0.0.1}:8081:8081 \
        -p ${BIND_ADDRESS:-127.0.0.1}:10251:10251 \
        -p ${BIND_ADDRESS:-127.0.0.1}:10252:10252 \
        -p ${BIND_ADDRESS:-127.0.0.1}:10253:10253 \
        -p ${BIND_ADDRESS:-127.0.0.1}:10254:10254 \
        --memory=${COSMOSDB_MAX_MEMORY:-3g} \
        -e AZURE_COSMOS_EMULATOR_PARTITION_COUNT=${AZURE_COSMOS_EMULATOR_PARTITION_COUNT:-10} \
        -e AZURE_COSMOS_EMULATOR_ENABLE_DATA_PERSISTENCE=${AZURE_COSMOS_EMULATOR_ENABLE_DATA_PERSISTENCE:-true} \
        -e AZURE_COSMOS_EMULATOR_IP_ADDRESS_OVERRIDE=${AZURE_COSMOS_EMULATOR_IP_ADDRESS_OVERRIDE:-127.0.0.1} \
        -v cosmosdb-data:/tmp/cosmos/appdata \
        --restart unless-stopped \
        mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest
    
    echo -e "${YELLOW}⏳ CosmosDB Emulator takes 2-3 minutes to start...${NC}"
    
    # CosmosDB takes longer to start, so we'll check differently
    echo -e "${BLUE}⏳ Waiting for CosmosDB Emulator to initialize...${NC}"
    for i in {1..90}; do
        if docker ps --filter "name=cosmosdb-emulator" --filter "status=running" --format "{{.Names}}" | grep -q "cosmosdb-emulator"; then
            if curl -k https://127.0.0.1:8081/_explorer/index.html >/dev/null 2>&1; then
                echo -e "${GREEN}✅ CosmosDB Emulator is ready${NC}"
                break
            fi
        fi
        echo -e "${YELLOW}CosmosDB initialization attempt $i/90...${NC}"
        sleep 2
    done
else
    echo -e "${YELLOW}⚠️ CosmosDB port in use - skipping${NC}"
fi

# Display connection information
echo -e "${GREEN}🎉 Enhanced Database Setup Complete!${NC}"
echo ""
echo -e "${BLUE}📊 Database Connection Information:${NC}"
echo -e "${GREEN}PostgreSQL:${NC}"
echo "  Host: 127.0.0.1:${POSTGRES_PORT:-5432}"
echo "  User: postgres"
echo "  Password: $POSTGRES_PASSWORD"
echo "  Database: ${POSTGRES_DB:-devdb}"
echo ""
echo -e "${GREEN}MariaDB:${NC}"
echo "  Host: 127.0.0.1:${MARIADB_PORT:-3306}"
echo "  User: root"
echo "  Password: $MYSQL_ROOT_PASSWORD"
echo "  Database: ${MYSQL_DATABASE:-devdb}"
echo ""
echo -e "${GREEN}MongoDB:${NC}"
echo "  Host: 127.0.0.1:${MONGODB_PORT:-27017}"
echo "  User: ${MONGODB_ROOT_USER:-admin}"
echo "  Password: ${MONGODB_ROOT_PASSWORD:-admin}"
echo "  Database: ${MONGODB_DATABASE:-devdb}"
echo ""
echo -e "${GREEN}Redis:${NC}"
echo "  Host: 127.0.0.1:${REDIS_PORT:-6379}"
if [ -n "$REDIS_PASSWORD" ]; then
    echo "  Password: $REDIS_PASSWORD"
else
    echo "  Password: (none)"
fi
echo ""
echo -e "${GREEN}CosmosDB Emulator:${NC}"
echo "  Data Explorer: https://127.0.0.1:8081/_explorer/index.html"
echo "  Endpoint: https://127.0.0.1:8081"
echo "  Primary Key: C2y6yDjf5R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="
echo ""
echo -e "${BLUE}💡 Next steps:${NC}"
echo "  1. Run management dashboards: ./enhanced-scripts/linux-dashboard-setup-auth.sh"
echo "  2. Test connections with your applications"
echo "  3. Use ./dev-workflow/dev-env-status.sh to monitor health"