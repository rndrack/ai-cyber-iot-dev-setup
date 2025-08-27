#!/bin/bash
# Fix Docker Permissions for Regular User
# Adds current user to docker group and fixes permissions

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🔧 Fixing Docker Permissions for User: $(whoami)${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""

# Get current user
CURRENT_USER=$(whoami)

echo -e "${BLUE}Step 1: Adding user to docker group${NC}"
sudo groupadd docker 2>/dev/null || echo "Docker group already exists"
sudo usermod -aG docker $CURRENT_USER
echo -e "${GREEN}✅ User $CURRENT_USER added to docker group${NC}"

echo ""
echo -e "${BLUE}Step 2: Setting Docker socket permissions${NC}"
sudo chmod 666 /var/run/docker.sock
echo -e "${GREEN}✅ Docker socket permissions set${NC}"

echo ""
echo -e "${BLUE}Step 3: Restarting Docker service${NC}"
sudo systemctl restart docker
sleep 3
echo -e "${GREEN}✅ Docker service restarted${NC}"

echo ""
echo -e "${BLUE}Step 4: Testing Docker access${NC}"
if docker --version >/dev/null 2>&1 && docker ps >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker is now accessible without sudo${NC}"
    echo ""
    echo -e "${CYAN}🎉 Docker permissions fixed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}You can now run:${NC}"
    echo "  ./dev-workflow/dev-env-start.sh"
else
    echo -e "${RED}❌ Docker still not accessible${NC}"
    echo ""
    echo -e "${YELLOW}⚠️ You may need to restart your WSL2 session:${NC}"
    echo "  1. Exit WSL2: exit"
    echo "  2. From Windows: wsl --shutdown"
    echo "  3. From Windows: wsl"
    echo "  4. Try again: ./dev-workflow/dev-env-start.sh"
fi

echo ""
echo -e "${BLUE}💡 Alternative: Run with explicit group${NC}"
echo "If still having issues, try: newgrp docker"