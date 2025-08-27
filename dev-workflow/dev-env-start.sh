#!/bin/bash
# Development Environment Startup Script
# One-command startup for complete AI-IoT-Cyber-Dev environment

set -e

# Load environment variables
if [ -f ".env" ]; then
    source .env
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 AI-IoT-Cyber Development Environment Starting...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"

# Function to check if container is running
is_container_running() {
    docker ps --filter "name=$1" --filter "status=running" --format "{{.Names}}" | grep -q "$1"
}

# Function to start container if not running
start_container_if_needed() {
    local container_name=$1
    local display_name=$2
    
    if is_container_running "$container_name"; then
        echo -e "${GREEN}✅ $display_name is already running${NC}"
    else
        echo -e "${YELLOW}⏳ Starting $display_name...${NC}"
        if docker start "$container_name" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $display_name started successfully${NC}"
        else
            echo -e "${RED}❌ Failed to start $display_name${NC}"
            return 1
        fi
    fi
}

# Function to wait for service to be ready
wait_for_service() {
    local service_name=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    echo -e "${BLUE}⏳ Waiting for $service_name to be ready...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $service_name is ready${NC}"
            return 0
        fi
        
        if [ $((attempt % 5)) -eq 0 ]; then
            echo -e "${YELLOW}   Still waiting for $service_name ($attempt/$max_attempts)...${NC}"
        fi
        
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}❌ $service_name failed to become ready${NC}"
    return 1
}

# Pre-flight checks
echo -e "${BLUE}🔍 Running pre-flight checks...${NC}"

# Enhanced Docker checks with automatic troubleshooting
if ! docker --version >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker CLI is not working properly${NC}"
    echo -e "${YELLOW}💡 Attempting automatic Docker recovery...${NC}"
    if [ -f "./docker-fixes/docker-wsl2-recovery.sh" ]; then
        ./docker-fixes/docker-wsl2-recovery.sh
        # Re-test after recovery
        if ! docker --version >/dev/null 2>&1; then
            echo -e "${RED}❌ Docker recovery failed${NC}"
            exit 1
        fi
        echo -e "${GREEN}✅ Docker recovery successful${NC}"
    else
        echo -e "${RED}❌ Docker recovery script not found${NC}"
        exit 1
    fi
fi

# Check Docker daemon connectivity
if ! docker info >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ Docker daemon connectivity issues detected${NC}"
    echo -e "${BLUE}🔧 Attempting network protocol fix...${NC}"
    
    if [ -f "./docker-fixes/docker-network-resolver.sh" ]; then
        ./docker-fixes/docker-network-resolver.sh
        # Re-test after network fix
        sleep 5
        if ! docker info >/dev/null 2>&1; then
            echo -e "${RED}❌ Docker network fix failed${NC}"
            echo -e "${YELLOW}💡 Try manual WSL2 restart: wsl --shutdown && wsl${NC}"
            exit 1
        fi
        echo -e "${GREEN}✅ Docker network fix successful${NC}"
    else
        echo -e "${RED}❌ Network resolver script not found${NC}"
        exit 1
    fi
fi

# Test Docker container operations
echo -e "${BLUE}🧪 Testing Docker container operations...${NC}"
if ! timeout 30s docker run --rm hello-world >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker container operations failed${NC}"
    echo -e "${YELLOW}💡 This indicates protocol/network issues${NC}"
    echo -e "${BLUE}🔧 Running comprehensive network fix...${NC}"
    
    if [ -f "./docker-fixes/docker-network-resolver.sh" ]; then
        ./docker-fixes/docker-network-resolver.sh
        sleep 5
        # Final test
        if ! timeout 30s docker run --rm hello-world >/dev/null 2>&1; then
            echo -e "${RED}❌ Container operations still failing${NC}"
            echo -e "${YELLOW}💡 Manual intervention required:${NC}"
            echo "  1. WSL2 restart: wsl --shutdown && wsl"
            echo "  2. Check Windows Docker Desktop"
            echo "  3. Run: ./maintenance/wsl2-network-utilities.sh"
            exit 1
        fi
        echo -e "${GREEN}✅ Container operations now working${NC}"
    fi
else
    echo -e "${GREEN}✅ Docker container operations working${NC}"
fi

# Check available memory
available_memory=$(free -g | awk 'NR==2{printf "%.0f", $7}')
if [ "$available_memory" -lt 4 ]; then
    echo -e "${YELLOW}⚠️ Available memory is ${available_memory}GB - some services may not start${NC}"
fi

echo -e "${GREEN}✅ Pre-flight checks passed${NC}"
echo ""

# Start databases
echo -e "${PURPLE}🗄️ Starting Database Services...${NC}"
echo -e "${BLUE}───────────────────────────────────${NC}"

start_container_if_needed "postgres-db" "PostgreSQL Database"
start_container_if_needed "mariadb-db" "MariaDB Database"  
start_container_if_needed "mongodb-db" "MongoDB Database"
start_container_if_needed "redis-db" "Redis Database"

# Start CosmosDB (if available)
if docker ps -a --filter "name=cosmosdb-emulator" --format "{{.Names}}" | grep -q "cosmosdb-emulator"; then
    start_container_if_needed "cosmosdb-emulator" "CosmosDB Emulator"
else
    echo -e "${YELLOW}ℹ️ CosmosDB Emulator not installed - skipping${NC}"
fi

echo ""

# Start management dashboards
echo -e "${PURPLE}🎛️ Starting Management Dashboards...${NC}"
echo -e "${BLUE}───────────────────────────────────────${NC}"

start_container_if_needed "adminer" "Adminer (SQL UI)"
start_container_if_needed "mongo-express" "Mongo Express"
start_container_if_needed "redis-commander" "Redis Commander"
start_container_if_needed "portainer" "Portainer (Docker UI)"
start_container_if_needed "dozzle" "Dozzle (Logs UI)"

echo ""

# Start monitoring stack
echo -e "${PURPLE}📊 Starting Monitoring Stack...${NC}"
echo -e "${BLUE}─────────────────────────────────${NC}"

start_container_if_needed "influxdb" "InfluxDB (Metrics DB)"
start_container_if_needed "grafana" "Grafana (Dashboards)"

echo ""

# Health checks
echo -e "${PURPLE}🩺 Performing Health Checks...${NC}"
echo -e "${BLUE}─────────────────────────────────${NC}"

# Wait for key services to be ready
wait_for_service "Adminer" "http://127.0.0.1:${ADMINER_PORT:-8080}" || true
wait_for_service "Grafana" "http://127.0.0.1:${GRAFANA_PORT:-3000}" || true

# Check CosmosDB if running
if is_container_running "cosmosdb-emulator"; then
    echo -e "${BLUE}⏳ CosmosDB Emulator takes longer to initialize (2-3 minutes)...${NC}"
fi

echo ""

# Display service status
echo -e "${GREEN}🎉 Development Environment Started!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}📊 Service Status Dashboard:${NC}"
echo ""

echo -e "${GREEN}🗄️ Databases:${NC}"
is_container_running "postgres-db" && echo "  ✅ PostgreSQL     → 127.0.0.1:${POSTGRES_PORT:-5432}" || echo "  ❌ PostgreSQL (not running)"
is_container_running "mariadb-db" && echo "  ✅ MariaDB        → 127.0.0.1:${MARIADB_PORT:-3306}" || echo "  ❌ MariaDB (not running)"
is_container_running "mongodb-db" && echo "  ✅ MongoDB        → 127.0.0.1:${MONGODB_PORT:-27017}" || echo "  ❌ MongoDB (not running)"
is_container_running "redis-db" && echo "  ✅ Redis          → 127.0.0.1:${REDIS_PORT:-6379}" || echo "  ❌ Redis (not running)"
is_container_running "cosmosdb-emulator" && echo "  ✅ CosmosDB       → https://127.0.0.1:8081/_explorer/" || echo "  ℹ️ CosmosDB (not installed/running)"

echo ""
echo -e "${GREEN}🎛️ Management UIs:${NC}"
is_container_running "adminer" && echo "  ✅ Adminer        → http://127.0.0.1:${ADMINER_PORT:-8080}" || echo "  ❌ Adminer (not running)"
is_container_running "mongo-express" && echo "  ✅ Mongo Express  → http://127.0.0.1:${MONGO_EXPRESS_PORT:-8082}" || echo "  ❌ Mongo Express (not running)"
is_container_running "redis-commander" && echo "  ✅ Redis Commander → http://127.0.0.1:${REDIS_COMMANDER_PORT:-8083}" || echo "  ❌ Redis Commander (not running)"
is_container_running "portainer" && echo "  ✅ Portainer      → http://127.0.0.1:${PORTAINER_PORT:-9000}" || echo "  ❌ Portainer (not running)"
is_container_running "dozzle" && echo "  ✅ Dozzle         → http://127.0.0.1:${DOZZLE_PORT:-9999}" || echo "  ❌ Dozzle (not running)"

echo ""
echo -e "${GREEN}📊 Monitoring:${NC}"
is_container_running "influxdb" && echo "  ✅ InfluxDB       → http://127.0.0.1:${INFLUXDB_PORT:-8086}" || echo "  ❌ InfluxDB (not running)"
is_container_running "grafana" && echo "  ✅ Grafana        → http://127.0.0.1:${GRAFANA_PORT:-3000}" || echo "  ❌ Grafana (not running)"

echo ""
echo -e "${CYAN}🔐 Default Credentials:${NC}"
echo "  Username: ${DASHBOARD_USERNAME:-admin}"
echo "  Password: ${DASHBOARD_PASSWORD:-admin}"
echo ""

echo -e "${CYAN}💡 Quick Commands:${NC}"
echo "  Check status:     ./dev-workflow/dev-env-status.sh"
echo "  Stop all:         ./dev-workflow/dev-env-stop.sh"
echo "  Reset env:        ./dev-workflow/dev-env-reset.sh"
echo "  Activate AI env:  conda activate ${CONDA_ENV_NAME:-ai-dev-enhanced}"
echo ""

echo -e "${GREEN}✨ Happy Development! ✨${NC}"