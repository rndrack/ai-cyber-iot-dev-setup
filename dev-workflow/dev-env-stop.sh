#!/bin/bash
# Development Environment Stop Script
# Gracefully stops all development services

# Load environment variables
if [ -f ".env" ]; then
    source .env
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🛑 AI-IoT-Cyber Development Environment Stopping...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"

# Function to stop container gracefully
stop_container() {
    local container_name=$1
    local display_name=$2
    local timeout=${3:-30}
    
    if docker ps --filter "name=$container_name" --filter "status=running" --format "{{.Names}}" | grep -q "$container_name"; then
        echo -e "${YELLOW}⏳ Stopping $display_name...${NC}"
        if timeout "$timeout" docker stop "$container_name" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $display_name stopped gracefully${NC}"
        else
            echo -e "${RED}⚠️ Force stopping $display_name...${NC}"
            docker kill "$container_name" >/dev/null 2>&1 || true
            echo -e "${YELLOW}🔄 $display_name force stopped${NC}"
        fi
    else
        echo -e "${BLUE}ℹ️ $display_name is not running${NC}"
    fi
}

# Parse command line arguments
REMOVE_CONTAINERS=false
BACKUP_DATA=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --remove-containers)
            REMOVE_CONTAINERS=true
            shift
            ;;
        --backup-data)
            BACKUP_DATA=true
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --remove-containers  Remove containers after stopping (data will be lost)"
            echo "  --backup-data        Backup container data before stopping"
            echo "  --help               Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Backup data if requested
if [ "$BACKUP_DATA" = true ]; then
    echo -e "${BLUE}💾 Backing up container data...${NC}"
    ./dev-workflow/backup-current-environment.sh
    echo ""
fi

# Stop monitoring services first (they depend on other services)
echo -e "${BLUE}📊 Stopping Monitoring Services...${NC}"
echo -e "${BLUE}─────────────────────────────────${NC}"
stop_container "grafana" "Grafana Dashboard" 15
stop_container "influxdb" "InfluxDB Metrics" 15
echo ""

# Stop management dashboards
echo -e "${BLUE}🎛️ Stopping Management Dashboards...${NC}"
echo -e "${BLUE}───────────────────────────────────────${NC}"
stop_container "dozzle" "Dozzle Logs" 10
stop_container "portainer" "Portainer Docker UI" 10
stop_container "redis-commander" "Redis Commander" 10
stop_container "mongo-express" "Mongo Express" 10
stop_container "adminer" "Adminer SQL UI" 10
echo ""

# Stop databases (give them more time to shutdown gracefully)
echo -e "${BLUE}🗄️ Stopping Database Services...${NC}"
echo -e "${BLUE}───────────────────────────────────${NC}"
stop_container "cosmosdb-emulator" "CosmosDB Emulator" 60
stop_container "redis-db" "Redis Database" 30
stop_container "mongodb-db" "MongoDB Database" 45
stop_container "mariadb-db" "MariaDB Database" 45
stop_container "postgres-db" "PostgreSQL Database" 45
echo ""

# Remove containers if requested
if [ "$REMOVE_CONTAINERS" = true ]; then
    echo -e "${RED}🗑️ Removing Containers (DATA WILL BE LOST)...${NC}"
    echo -e "${BLUE}─────────────────────────────────────────────${NC}"
    
    echo -e "${YELLOW}⚠️ This will permanently delete all container data!${NC}"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        containers=(
            "grafana:Grafana Dashboard"
            "influxdb:InfluxDB Metrics"
            "dozzle:Dozzle Logs"
            "portainer:Portainer Docker UI"
            "redis-commander:Redis Commander"
            "mongo-express:Mongo Express"
            "adminer:Adminer SQL UI"
            "cosmosdb-emulator:CosmosDB Emulator"
            "redis-db:Redis Database"
            "mongodb-db:MongoDB Database"
            "mariadb-db:MariaDB Database"
            "postgres-db:PostgreSQL Database"
        )
        
        for container_info in "${containers[@]}"; do
            IFS=':' read -r container_name display_name <<< "$container_info"
            if docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "$container_name"; then
                echo -e "${RED}🗑️ Removing $display_name...${NC}"
                docker rm -f "$container_name" >/dev/null 2>&1 || true
            fi
        done
        
        # Also remove volumes if requested
        echo ""
        read -p "Also remove data volumes? This will delete ALL data permanently (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}🗑️ Removing data volumes...${NC}"
            docker volume rm -f postgres-data mariadb-data mongodb-data redis-data cosmosdb-data grafana-data influxdb-data portainer-data 2>/dev/null || true
            echo -e "${RED}⚠️ All data volumes removed${NC}"
        fi
        
    else
        echo -e "${BLUE}ℹ️ Container removal cancelled${NC}"
    fi
    echo ""
fi

# Clean up unused Docker resources
echo -e "${BLUE}🧹 Cleaning up Docker resources...${NC}"
echo -e "${BLUE}─────────────────────────────────${NC}"

# Remove unused networks
docker network prune -f >/dev/null 2>&1 || true
echo -e "${GREEN}✅ Unused networks cleaned${NC}"

# Remove unused images (only dangling ones by default)
if docker image prune -f >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Unused images cleaned${NC}"
fi

echo ""

# Final status
echo -e "${GREEN}🏁 Environment Stop Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════${NC}"

# Check remaining containers
running_containers=$(docker ps --format "{{.Names}}" | wc -l)
total_containers=$(docker ps -a --format "{{.Names}}" | wc -l)

echo ""
echo -e "${CYAN}📊 Final Status:${NC}"
echo "  Running containers: $running_containers"
echo "  Total containers: $total_containers"

if [ "$running_containers" -eq 0 ]; then
    echo -e "${GREEN}  ✅ All development services stopped${NC}"
else
    echo -e "${YELLOW}  ⚠️ Some containers are still running:${NC}"
    docker ps --format "    {{.Names}} ({{.Status}})"
fi

echo ""
echo -e "${CYAN}💡 Next Steps:${NC}"
echo "  Restart environment:    ./dev-workflow/dev-env-start.sh"
echo "  Check status:           ./dev-workflow/dev-env-status.sh"
echo "  Reset environment:      ./dev-workflow/dev-env-reset.sh"

if [ "$BACKUP_DATA" = true ]; then
    echo "  Restore from backup:    ./dev-workflow/restore-environment.sh"
fi

echo ""
echo -e "${GREEN}✨ Environment stopped successfully! ✨${NC}"