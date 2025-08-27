#!/bin/bash
# Development Environment Status Checker
# Comprehensive health monitoring for all services

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

echo -e "${CYAN}📊 AI-IoT-Cyber Development Environment Status${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo "Status check at: $(date)"
echo ""

# Function to check if container is running and healthy
check_container_status() {
    local container_name=$1
    local display_name=$2
    local port=$3
    local protocol=${4:-http}
    
    if docker ps --filter "name=$container_name" --filter "status=running" --format "{{.Names}}" | grep -q "$container_name"; then
        # Container is running, check if service is responsive
        if [ -n "$port" ]; then
            local url="${protocol}://127.0.0.1:${port}"
            if [ "$protocol" = "tcp" ]; then
                # For TCP services like databases
                if timeout 3 nc -z 127.0.0.1 "$port" 2>/dev/null; then
                    echo -e "  ✅ ${display_name} - Running & Accessible"
                else
                    echo -e "  🟡 ${display_name} - Running but not accessible on port $port"
                fi
            else
                # For HTTP services
                if timeout 5 curl -s "$url" >/dev/null 2>&1; then
                    echo -e "  ✅ ${display_name} - Running & Accessible"
                else
                    echo -e "  🟡 ${display_name} - Running but HTTP not responding"
                fi
            fi
        else
            echo -e "  ✅ ${display_name} - Running"
        fi
        return 0
    else
        if docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "$container_name"; then
            echo -e "  ❌ ${display_name} - Stopped"
        else
            echo -e "  ➖ ${display_name} - Not installed"
        fi
        return 1
    fi
}

# Function to check service resource usage
check_container_resources() {
    local container_name=$1
    
    if docker ps --filter "name=$container_name" --filter "status=running" --format "{{.Names}}" | grep -q "$container_name"; then
        local stats=$(docker stats --no-stream --format "table {{.CPUPerc}}\t{{.MemUsage}}" "$container_name" 2>/dev/null | tail -1)
        if [ -n "$stats" ]; then
            echo "    Resources: $stats"
        fi
    fi
}

# System overview
echo -e "${PURPLE}🖥️ System Overview:${NC}"
echo -e "${BLUE}─────────────────────${NC}"
echo "  OS: $(uname -s) $(uname -r)"
echo "  User: $(whoami)"
echo "  Uptime: $(uptime -p 2>/dev/null || echo 'N/A')"
echo ""

# Memory and disk usage
echo -e "${PURPLE}💾 Resource Usage:${NC}"
echo -e "${BLUE}─────────────────────${NC}"
free -h | head -2 | while read line; do
    echo "  $line"
done
echo ""
df -h / | while read line; do
    if [[ $line == *"/"* ]] || [[ $line == *"Filesystem"* ]]; then
        echo "  $line"
    fi
done
echo ""

# Docker status
echo -e "${PURPLE}🐳 Docker Status:${NC}"
echo -e "${BLUE}───────────────────${NC}"
if docker --version >/dev/null 2>&1; then
    echo -e "  ✅ Docker CLI: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
    
    if docker info >/dev/null 2>&1; then
        echo -e "  ✅ Docker Daemon: Running"
        local containers_running=$(docker ps -q | wc -l)
        local containers_total=$(docker ps -a -q | wc -l)
        echo "  Containers: $containers_running running, $containers_total total"
    else
        echo -e "  ❌ Docker Daemon: Not accessible"
    fi
else
    echo -e "  ❌ Docker: Not installed or not working"
fi
echo ""

# Database services
echo -e "${PURPLE}🗄️ Database Services:${NC}"
echo -e "${BLUE}────────────────────────${NC}"
check_container_status "postgres-db" "PostgreSQL" "${POSTGRES_PORT:-5432}" "tcp"
check_container_status "mariadb-db" "MariaDB" "${MARIADB_PORT:-3306}" "tcp"
check_container_status "mongodb-db" "MongoDB" "${MONGODB_PORT:-27017}" "tcp"
check_container_status "redis-db" "Redis" "${REDIS_PORT:-6379}" "tcp"
check_container_status "cosmosdb-emulator" "CosmosDB Emulator" "8081" "https"
echo ""

# Management dashboards
echo -e "${PURPLE}🎛️ Management Dashboards:${NC}"
echo -e "${BLUE}──────────────────────────${NC}"
check_container_status "adminer" "Adminer" "${ADMINER_PORT:-8080}"
check_container_status "mongo-express" "Mongo Express" "${MONGO_EXPRESS_PORT:-8082}"
check_container_status "redis-commander" "Redis Commander" "${REDIS_COMMANDER_PORT:-8083}"
check_container_status "portainer" "Portainer" "${PORTAINER_PORT:-9000}"
check_container_status "dozzle" "Dozzle" "${DOZZLE_PORT:-9999}"
echo ""

# Monitoring services
echo -e "${PURPLE}📊 Monitoring Services:${NC}"
echo -e "${BLUE}─────────────────────────${NC}"
check_container_status "influxdb" "InfluxDB" "${INFLUXDB_PORT:-8086}"
check_container_status "grafana" "Grafana" "${GRAFANA_PORT:-3000}"
echo ""

# Port usage overview
echo -e "${PURPLE}🌐 Port Usage:${NC}"
echo -e "${BLUE}─────────────────${NC}"
echo "  Active ports on 127.0.0.1:"
netstat -tuln 2>/dev/null | grep "127.0.0.1" | grep "LISTEN" | awk '{print "    " $4}' | sort -n -t: -k2 | head -20
echo ""

# Network connectivity test
echo -e "${PURPLE}🔗 Network Connectivity:${NC}"
echo -e "${BLUE}──────────────────────────${NC}"

# Test key service ports
key_services=(
    "PostgreSQL:${POSTGRES_PORT:-5432}"
    "MariaDB:${MARIADB_PORT:-3306}"
    "MongoDB:${MONGODB_PORT:-27017}"
    "Redis:${REDIS_PORT:-6379}"
    "Adminer:${ADMINER_PORT:-8080}"
    "Grafana:${GRAFANA_PORT:-3000}"
)

for service in "${key_services[@]}"; do
    IFS=':' read -r name port <<< "$service"
    if timeout 2 nc -z 127.0.0.1 "$port" 2>/dev/null; then
        echo -e "  ✅ $name (port $port)"
    else
        echo -e "  ❌ $name (port $port)"
    fi
done
echo ""

# Development environment status
echo -e "${PURPLE}🛠️ Development Environment:${NC}"
echo -e "${BLUE}────────────────────────────${NC}"

# Check conda
if command -v conda &> /dev/null; then
    echo -e "  ✅ Conda: $(conda --version 2>/dev/null | cut -d' ' -f2)"
    
    # Check AI dev environment
    if conda env list | grep -q "${CONDA_ENV_NAME:-ai-dev-enhanced}"; then
        echo -e "  ✅ AI Dev Environment: ${CONDA_ENV_NAME:-ai-dev-enhanced} (available)"
    elif conda env list | grep -q "ai-dev"; then
        echo -e "  ✅ AI Dev Environment: ai-dev (available)"
    else
        echo -e "  ❌ AI Dev Environment: Not found"
    fi
else
    echo -e "  ➖ Conda: Not installed"
fi

# Check Node.js
if command -v node &> /dev/null; then
    echo -e "  ✅ Node.js: $(node --version)"
else
    echo -e "  ➖ Node.js: Not installed"
fi

# Check Python
if command -v python3 &> /dev/null; then
    echo -e "  ✅ Python: $(python3 --version | cut -d' ' -f2)"
else
    echo -e "  ➖ Python: Not installed"
fi
echo ""

# Service recommendations
echo -e "${PURPLE}💡 Recommendations:${NC}"
echo -e "${BLUE}─────────────────────${NC}"

stopped_containers=()
if ! docker ps --filter "name=postgres-db" --filter "status=running" -q | grep -q .; then
    stopped_containers+=("postgres-db")
fi
if ! docker ps --filter "name=mariadb-db" --filter "status=running" -q | grep -q .; then
    stopped_containers+=("mariadb-db")
fi
if ! docker ps --filter "name=mongodb-db" --filter "status=running" -q | grep -q .; then
    stopped_containers+=("mongodb-db")
fi

if [ ${#stopped_containers[@]} -gt 0 ]; then
    echo -e "  🔄 Start stopped services: ${YELLOW}./dev-workflow/dev-env-start.sh${NC}"
fi

if ! docker --version >/dev/null 2>&1; then
    echo -e "  🔧 Fix Docker issues: ${YELLOW}./docker-fixes/docker-wsl2-recovery.sh${NC}"
fi

if [ ${#stopped_containers[@]} -eq 0 ] && docker --version >/dev/null 2>&1; then
    echo -e "  ✨ All systems operational! Ready for development."
fi

echo ""
echo -e "${CYAN}📈 Quick Commands:${NC}"
echo "  Full restart:     ./dev-workflow/dev-env-start.sh"
echo "  Stop all:         ./dev-workflow/dev-env-stop.sh"
echo "  Reset environment: ./dev-workflow/dev-env-reset.sh"
echo "  Docker recovery:  ./docker-fixes/docker-wsl2-recovery.sh"
echo ""
echo -e "${GREEN}Status check completed at $(date)${NC}"