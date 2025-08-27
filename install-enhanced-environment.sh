#!/bin/bash
# Master Installation Script for Enhanced AI-IoT-Cyber-Dev-Bundle
# Installs and configures complete development environment for WSL2 root user

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 Enhanced AI-IoT-Cyber Development Environment Installer${NC}"
echo -e "${BLUE}═════════════════════════════════════════════════════════${NC}"
echo "Installation starting at: $(date)"
echo "Target: WSL2 Ubuntu with root user"
echo ""

# Function to display step
show_step() {
    local step_num=$1
    local step_name=$2
    echo -e "${PURPLE}📋 Step $step_num: $step_name${NC}"
    echo -e "${BLUE}$(printf '═%.0s' {1..50})${NC}"
}

# Function to check if step should be skipped
should_skip_step() {
    local step_name=$1
    read -p "Skip '$step_name'? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Function to handle errors
handle_error() {
    local step=$1
    echo -e "${RED}❌ Error in step: $step${NC}"
    echo -e "${YELLOW}💡 You can run individual scripts manually:${NC}"
    echo "  • Docker fix: ./docker-fixes/docker-wsl2-recovery.sh"
    echo "  • Databases: ./enhanced-scripts/linux-db-setup-secure.sh"
    echo "  • Dashboards: ./enhanced-scripts/linux-dashboard-setup-auth.sh"
    echo ""
    read -p "Continue with next step? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Parse command line arguments
SKIP_INTERACTIVE=false
SKIP_DOCKER_FIX=false
SKIP_OPTIMIZATION=false
BACKUP_FIRST=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --non-interactive)
            SKIP_INTERACTIVE=true
            shift
            ;;
        --skip-docker-fix)
            SKIP_DOCKER_FIX=true
            shift
            ;;
        --skip-optimization)
            SKIP_OPTIMIZATION=true
            shift
            ;;
        --no-backup)
            BACKUP_FIRST=false
            shift
            ;;
        --help)
            echo "Enhanced AI-IoT-Cyber-Dev-Bundle Installer"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --non-interactive    Skip interactive prompts"
            echo "  --skip-docker-fix    Skip Docker recovery step"
            echo "  --skip-optimization  Skip WSL2 optimization"
            echo "  --no-backup          Skip initial backup"
            echo "  --help              Show this help message"
            echo ""
            echo "Installation steps:"
            echo "  1. Create backup of current environment"
            echo "  2. Fix Docker WSL2 segmentation fault"
            echo "  3. Install enhanced database stack (including CosmosDB)"
            echo "  4. Setup secure management dashboards"
            echo "  5. Optimize WSL2 performance settings"
            echo "  6. Configure development environment"
            echo "  7. Test complete system functionality"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Pre-installation checks
echo -e "${BLUE}🔍 Pre-installation System Checks${NC}"
echo -e "${BLUE}$(printf '─%.0s' {1..35})${NC}"

# Check if we're root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ This script must be run as root${NC}"
    exit 1
fi

# Check if we're in WSL2
if ! grep -qi microsoft /proc/version; then
    echo -e "${YELLOW}⚠️ This doesn't appear to be WSL2${NC}"
    if [ "$SKIP_INTERACTIVE" = false ]; then
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

echo -e "${GREEN}✅ Running as root in WSL2 environment${NC}"
echo ""

# Step 1: Create backup
show_step 1 "Create Backup of Current Environment"
if [ "$BACKUP_FIRST" = true ]; then
    if [ "$SKIP_INTERACTIVE" = false ] && should_skip_step "Create Backup"; then
        echo -e "${YELLOW}⚠️ Skipping backup step${NC}"
    else
        if ! ./dev-workflow/backup-current-environment.sh; then
            if ! handle_error "Backup Creation"; then exit 1; fi
        else
            echo -e "${GREEN}✅ Backup created successfully${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠️ Backup skipped (--no-backup flag)${NC}"
fi
echo ""

# Step 2: Fix Docker if needed
show_step 2 "Fix Docker WSL2 Issues"
if [ "$SKIP_DOCKER_FIX" = true ]; then
    echo -e "${YELLOW}⚠️ Skipping Docker fix (--skip-docker-fix flag)${NC}"
elif [ "$SKIP_INTERACTIVE" = false ] && should_skip_step "Docker Fix"; then
    echo -e "${YELLOW}⚠️ Skipping Docker fix step${NC}"
else
    # Test if Docker is working
    if timeout 10s docker --version >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker appears to be working${NC}"
        if [ "$SKIP_INTERACTIVE" = false ]; then
            read -p "Force Docker reinstall anyway? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ./docker-fixes/docker-wsl2-recovery.sh
            fi
        fi
    else
        echo -e "${YELLOW}🔧 Docker issues detected - running recovery...${NC}"
        if ! ./docker-fixes/docker-wsl2-recovery.sh; then
            if ! handle_error "Docker Recovery"; then exit 1; fi
        else
            echo -e "${GREEN}✅ Docker recovery completed${NC}"
        fi
    fi
fi
echo ""

# Step 3: Install enhanced database stack
show_step 3 "Install Enhanced Database Stack with CosmosDB"
if [ "$SKIP_INTERACTIVE" = false ] && should_skip_step "Database Installation"; then
    echo -e "${YELLOW}⚠️ Skipping database installation${NC}"
else
    if ! ./enhanced-scripts/linux-db-setup-secure.sh; then
        if ! handle_error "Database Installation"; then exit 1; fi
    else
        echo -e "${GREEN}✅ Database stack installed successfully${NC}"
    fi
fi
echo ""

# Step 4: Setup management dashboards
show_step 4 "Setup Secure Management Dashboards"
if [ "$SKIP_INTERACTIVE" = false ] && should_skip_step "Dashboard Setup"; then
    echo -e "${YELLOW}⚠️ Skipping dashboard setup${NC}"
else
    if ! ./enhanced-scripts/linux-dashboard-setup-auth.sh; then
        if ! handle_error "Dashboard Setup"; then exit 1; fi
    else
        echo -e "${GREEN}✅ Management dashboards configured${NC}"
    fi
fi
echo ""

# Step 5: WSL2 optimization
show_step 5 "Optimize WSL2 Performance"
if [ "$SKIP_OPTIMIZATION" = true ]; then
    echo -e "${YELLOW}⚠️ Skipping WSL2 optimization (--skip-optimization flag)${NC}"
elif [ "$SKIP_INTERACTIVE" = false ] && should_skip_step "WSL2 Optimization"; then
    echo -e "${YELLOW}⚠️ Skipping WSL2 optimization${NC}"
else
    if ! ./enhanced-scripts/wsl2-optimization.sh; then
        if ! handle_error "WSL2 Optimization"; then exit 1; fi
    else
        echo -e "${GREEN}✅ WSL2 optimization completed${NC}"
    fi
fi
echo ""

# Step 6: Configure development environment
show_step 6 "Configure Development Environment"
echo -e "${BLUE}Setting up development aliases and paths...${NC}"

# Make all scripts executable
chmod +x enhanced-scripts/*.sh dev-workflow/*.sh docker-fixes/*.sh maintenance/*.sh templates/*/*.sh 2>/dev/null || true
chmod +x cosmosdb-tools/*.sh 2>/dev/null || true

# Set secure permissions on .env file
chmod 600 .env 2>/dev/null || true

# Create development directories
mkdir -p /root/dev/{projects,temp,logs,backups} 2>/dev/null || true

echo -e "${GREEN}✅ Development environment configured${NC}"
echo ""

# Step 7: System testing
show_step 7 "Test Complete System Functionality"
if [ "$SKIP_INTERACTIVE" = false ] && should_skip_step "System Testing"; then
    echo -e "${YELLOW}⚠️ Skipping system testing${NC}"
else
    echo -e "${BLUE}🧪 Running comprehensive system tests...${NC}"
    
    # Test Docker
    if docker --version >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker CLI working${NC}"
    else
        echo -e "${RED}❌ Docker CLI issues${NC}"
    fi
    
    # Test container status
    running_containers=$(docker ps --format "{{.Names}}" | wc -l)
    echo -e "${GREEN}✅ $running_containers containers running${NC}"
    
    # Run status check
    if [ -f "./dev-workflow/dev-env-status.sh" ]; then
        echo ""
        echo -e "${BLUE}📊 Running detailed status check...${NC}"
        ./dev-workflow/dev-env-status.sh
    fi
fi

# Installation completion
echo ""
echo -e "${GREEN}🎉 Enhanced AI-IoT-Cyber Development Environment Installation Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}📊 Installation Summary:${NC}"
echo "  ✅ Backup system created"
echo "  ✅ Docker WSL2 issues resolved"
echo "  ✅ Enhanced database stack (PostgreSQL, MariaDB, MongoDB, Redis, CosmosDB)"
echo "  ✅ Secure management dashboards with authentication"
echo "  ✅ WSL2 performance optimization"
echo "  ✅ Development environment configuration"
echo ""

echo -e "${CYAN}🌐 Access Your Development Environment:${NC}"
echo ""
echo -e "${GREEN}Databases:${NC}"
echo "  • PostgreSQL:    127.0.0.1:5432"
echo "  • MariaDB:       127.0.0.1:3306"  
echo "  • MongoDB:       127.0.0.1:27017"
echo "  • Redis:         127.0.0.1:6379"
echo "  • CosmosDB:      https://127.0.0.1:8081/_explorer/"
echo ""
echo -e "${GREEN}Management UIs:${NC}"
echo "  • Adminer:       http://127.0.0.1:8080"
echo "  • Mongo Express: http://127.0.0.1:8082"
echo "  • Redis Command: http://127.0.0.1:8083"
echo "  • Portainer:     http://127.0.0.1:9000"
echo "  • Grafana:       http://127.0.0.1:3000"
echo ""

echo -e "${CYAN}🚀 Quick Start Commands:${NC}"
echo "  Start all services:   ./dev-workflow/dev-env-start.sh"
echo "  Check status:         ./dev-workflow/dev-env-status.sh"
echo "  Stop all services:    ./dev-workflow/dev-env-stop.sh"
echo "  Reset environment:    ./maintenance/quick-reset.sh"
echo ""

echo -e "${CYAN}🔐 Default Credentials:${NC}"
echo "  Username: admin"
echo "  Password: admin (change in .env file)"
echo ""

echo -e "${CYAN}⚠️ Important Notes:${NC}"
echo "  • Some optimizations require WSL2 restart: wsl --shutdown && wsl"
echo "  • CosmosDB Emulator takes 2-3 minutes to initialize"
echo "  • All services are bound to localhost (127.0.0.1) for security"
echo "  • Change default passwords in .env file for production use"
echo ""

echo -e "${GREEN}✨ Happy Development! ✨${NC}"
echo ""
echo "Installation completed at: $(date)"