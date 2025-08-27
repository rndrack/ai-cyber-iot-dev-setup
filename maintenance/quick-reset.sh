#!/bin/bash
# Quick Reset Options for Development Environment
# Provides multiple reset strategies for different scenarios

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔄 AI-IoT-Cyber Development Environment Reset${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""

# Function to show menu
show_menu() {
    echo -e "${YELLOW}Select reset option:${NC}"
    echo ""
    echo "1. 🔄 Restart All Services (containers only)"
    echo "2. 🧹 Clean Reset (stop + remove containers, keep data)"
    echo "3. 🗑️ Full Reset (remove containers + data volumes)"
    echo "4. 🐳 Docker Only Reset (fix Docker issues)"
    echo "5. 💾 Reset with Backup (backup data first)"
    echo "6. 🎯 Selective Reset (choose specific services)"
    echo "7. ⚡ Space Cleanup (remove unused Docker resources)"
    echo "8. ❌ Cancel"
    echo ""
}

# Function to restart services
restart_services() {
    echo -e "${BLUE}🔄 Restarting all services...${NC}"
    ./dev-workflow/dev-env-stop.sh
    sleep 3
    ./dev-workflow/dev-env-start.sh
}

# Function to clean reset
clean_reset() {
    echo -e "${YELLOW}🧹 Performing clean reset...${NC}"
    echo "This will stop and remove containers but preserve data volumes"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./dev-workflow/dev-env-stop.sh --remove-containers
        echo -e "${GREEN}✅ Clean reset completed${NC}"
        echo -e "${BLUE}💡 Run ./dev-workflow/dev-env-start.sh to recreate containers${NC}"
    fi
}

# Function to full reset
full_reset() {
    echo -e "${RED}🗑️ FULL RESET - THIS WILL DELETE ALL DATA!${NC}"
    echo -e "${YELLOW}⚠️ This will permanently delete:${NC}"
    echo "   • All containers"
    echo "   • All data volumes"
    echo "   • Database contents"
    echo "   • Configuration data"
    echo ""
    echo -e "${RED}THIS CANNOT BE UNDONE!${NC}"
    echo ""
    read -p "Type 'DELETE ALL DATA' to continue: " confirmation
    
    if [ "$confirmation" = "DELETE ALL DATA" ]; then
        echo -e "${RED}🗑️ Performing full reset...${NC}"
        
        # Stop all containers
        ./dev-workflow/dev-env-stop.sh --remove-containers
        
        # Remove all volumes
        echo -e "${RED}🗑️ Removing data volumes...${NC}"
        docker volume rm -f postgres-data mariadb-data mongodb-data redis-data cosmosdb-data grafana-data influxdb-data portainer-data 2>/dev/null || true
        
        # Clean up everything
        docker system prune -af --volumes >/dev/null 2>&1 || true
        
        echo -e "${GREEN}✅ Full reset completed${NC}"
        echo -e "${BLUE}💡 Run ./enhanced-scripts/linux-db-setup-secure.sh to reinstall${NC}"
    else
        echo -e "${BLUE}ℹ️ Full reset cancelled${NC}"
    fi
}

# Function to Docker reset
docker_reset() {
    echo -e "${BLUE}🐳 Docker reset (fix Docker issues)...${NC}"
    ./docker-fixes/docker-wsl2-recovery.sh
}

# Function to reset with backup
reset_with_backup() {
    echo -e "${BLUE}💾 Reset with backup...${NC}"
    ./dev-workflow/backup-current-environment.sh
    echo ""
    echo "Backup completed. Choose reset type:"
    echo "1. Clean reset (keep data volumes)"
    echo "2. Full reset (remove everything)"
    read -p "Choice (1/2): " -n 1 -r
    echo
    
    case $REPLY in
        1) clean_reset ;;
        2) full_reset ;;
        *) echo "Invalid choice" ;;
    esac
}

# Function to selective reset
selective_reset() {
    echo -e "${YELLOW}🎯 Selective Reset${NC}"
    echo ""
    echo "Select services to reset:"
    echo ""
    
    services=(
        "postgres-db:PostgreSQL Database"
        "mariadb-db:MariaDB Database"
        "mongodb-db:MongoDB Database"
        "redis-db:Redis Database"
        "cosmosdb-emulator:CosmosDB Emulator"
        "adminer:Adminer SQL UI"
        "mongo-express:Mongo Express"
        "redis-commander:Redis Commander"
        "portainer:Portainer"
        "dozzle:Dozzle"
        "grafana:Grafana"
        "influxdb:InfluxDB"
    )
    
    selected_services=()
    
    for i in "${!services[@]}"; do
        IFS=':' read -r container_name display_name <<< "${services[$i]}"
        echo -n "$((i+1)). $display_name "
        
        if docker ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "$container_name"; then
            if docker ps --filter "name=$container_name" --filter "status=running" --format "{{.Names}}" | grep -q "$container_name"; then
                echo -e "${GREEN}(running)${NC}"
            else
                echo -e "${YELLOW}(stopped)${NC}"
            fi
        else
            echo -e "${RED}(not installed)${NC}"
        fi
    done
    
    echo ""
    echo "Enter service numbers separated by spaces (e.g., '1 3 5'), or 'all' for all services:"
    read -r selection
    
    if [ "$selection" = "all" ]; then
        selected_services=("${services[@]}")
    else
        for num in $selection; do
            if [[ $num =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#services[@]} ]; then
                selected_services+=("${services[$((num-1))]}")
            fi
        done
    fi
    
    if [ ${#selected_services[@]} -eq 0 ]; then
        echo -e "${YELLOW}No valid services selected${NC}"
        return
    fi
    
    echo ""
    echo "Selected services:"
    for service in "${selected_services[@]}"; do
        IFS=':' read -r container_name display_name <<< "$service"
        echo "  • $display_name"
    done
    
    echo ""
    read -p "Reset selected services? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for service in "${selected_services[@]}"; do
            IFS=':' read -r container_name display_name <<< "$service"
            echo -e "${YELLOW}🔄 Resetting $display_name...${NC}"
            
            # Stop container
            docker stop "$container_name" >/dev/null 2>&1 || true
            
            # Remove container
            docker rm "$container_name" >/dev/null 2>&1 || true
            
            echo -e "${GREEN}✅ $display_name reset${NC}"
        done
        
        echo ""
        echo -e "${GREEN}✅ Selective reset completed${NC}"
        echo -e "${BLUE}💡 Run ./dev-workflow/dev-env-start.sh to recreate services${NC}"
    fi
}

# Function to space cleanup
space_cleanup() {
    echo -e "${BLUE}⚡ Docker space cleanup...${NC}"
    
    echo "Current Docker disk usage:"
    docker system df
    echo ""
    
    echo "This will remove:"
    echo "  • Stopped containers"
    echo "  • Unused networks"
    echo "  • Dangling images"
    echo "  • Build cache"
    echo ""
    
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🧹 Cleaning up Docker resources...${NC}"
        
        # Remove stopped containers
        docker container prune -f
        
        # Remove unused networks
        docker network prune -f
        
        # Remove dangling images
        docker image prune -f
        
        # Remove build cache
        docker builder prune -f
        
        echo ""
        echo "Disk usage after cleanup:"
        docker system df
        
        echo -e "${GREEN}✅ Space cleanup completed${NC}"
    fi
}

# Main menu loop
while true; do
    show_menu
    read -p "Enter your choice (1-8): " choice
    echo ""
    
    case $choice in
        1) restart_services; break ;;
        2) clean_reset; break ;;
        3) full_reset; break ;;
        4) docker_reset; break ;;
        5) reset_with_backup; break ;;
        6) selective_reset; break ;;
        7) space_cleanup; break ;;
        8) echo -e "${BLUE}ℹ️ Reset cancelled${NC}"; break ;;
        *) echo -e "${RED}Invalid choice. Please enter 1-8.${NC}"; echo ;;
    esac
done

echo ""
echo -e "${GREEN}✨ Reset operation completed! ✨${NC}"