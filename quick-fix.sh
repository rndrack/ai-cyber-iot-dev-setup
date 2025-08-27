#!/bin/bash
# Quick Fix for Docker Protocol Issues
# Immediate resolution for "protocol not available" errors

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}⚡ Quick Fix for Docker Protocol Issues${NC}"
echo -e "${BLUE}════════════════════════════════════${NC}"
echo ""

# Immediate fix steps
echo -e "${YELLOW}🔧 Step 1: Restart Docker service${NC}"
sudo systemctl restart docker
sleep 3

echo -e "${YELLOW}🔧 Step 2: Reset Docker networks${NC}"
docker network prune -f 2>/dev/null || true
docker network create dev-network 2>/dev/null || echo "dev-network exists"

echo -e "${YELLOW}🔧 Step 3: Test Docker functionality${NC}"
if timeout 30s docker run --rm hello-world >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker is now working!${NC}"
    echo ""
    echo -e "${CYAN}💡 You can now run:${NC}"
    echo "  ./dev-workflow/dev-env-start.sh"
else
    echo -e "${RED}❌ Quick fix unsuccessful${NC}"
    echo ""
    echo -e "${CYAN}💡 Try these comprehensive fixes:${NC}"
    echo "  1. ./docker-fixes/docker-network-resolver.sh"
    echo "  2. ./maintenance/wsl2-network-utilities.sh"
    echo "  3. WSL2 restart: wsl --shutdown && wsl"
fi