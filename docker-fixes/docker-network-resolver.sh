#!/bin/bash
# Docker Network Protocol Resolver
# Comprehensive fix for "protocol not available" and WSL2 Docker networking issues

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔧 Docker Network Protocol Resolver${NC}"
echo -e "${BLUE}═══════════════════════════════════${NC}"
echo "Fixing 'protocol not available' and networking issues..."
echo ""

# Function to test Docker functionality
test_docker() {
    local test_name=$1
    echo -e "${BLUE}🧪 Testing: $test_name${NC}"
    
    case $test_name in
        "version")
            if timeout 10s docker --version >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Docker CLI working${NC}"
                return 0
            else
                echo -e "${RED}❌ Docker CLI failed${NC}"
                return 1
            fi
            ;;
        "daemon")
            if timeout 10s docker info >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Docker daemon accessible${NC}"
                return 0
            else
                echo -e "${RED}❌ Docker daemon not accessible${NC}"
                return 1
            fi
            ;;
        "network")
            if timeout 10s docker network ls >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Docker networking functional${NC}"
                return 0
            else
                echo -e "${RED}❌ Docker networking failed${NC}"
                return 1
            fi
            ;;
        "container")
            if timeout 30s docker run --rm hello-world >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Container operations working${NC}"
                return 0
            else
                echo -e "${RED}❌ Container operations failed${NC}"
                return 1
            fi
            ;;
    esac
}

# Function to restart Docker with network reset
restart_docker_with_network_reset() {
    echo -e "${YELLOW}🔄 Restarting Docker with network reset...${NC}"
    
    # Stop Docker service
    systemctl stop docker.service 2>/dev/null || true
    systemctl stop docker.socket 2>/dev/null || true
    
    # Clear Docker network state
    rm -rf /var/lib/docker/network/* 2>/dev/null || true
    
    # Reset iptables for Docker
    iptables -t nat -F DOCKER 2>/dev/null || true
    iptables -t filter -F DOCKER 2>/dev/null || true
    iptables -t filter -F DOCKER-ISOLATION-STAGE-1 2>/dev/null || true
    iptables -t filter -F DOCKER-ISOLATION-STAGE-2 2>/dev/null || true
    
    # Start Docker service
    systemctl start docker.service
    sleep 5
    
    echo -e "${GREEN}✅ Docker restarted with network reset${NC}"
}

# Function to fix WSL2 specific networking issues
fix_wsl2_networking() {
    echo -e "${YELLOW}🔧 Applying WSL2 networking fixes...${NC}"
    
    # Enable IP forwarding
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf 2>/dev/null || true
    sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || true
    
    # Fix Docker bridge networking
    cat > /etc/docker/daemon.json << 'EOF'
{
    "storage-driver": "overlay2",
    "hosts": ["unix:///var/run/docker.sock"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "experimental": false,
    "features": {
        "buildkit": true
    },
    "bridge": "docker0",
    "iptables": true,
    "ip-forward": true,
    "ip-masq": true,
    "userland-proxy": true,
    "default-address-pools": [
        {
            "base": "172.17.0.0/16",
            "size": 24
        }
    ]
}
EOF

    echo -e "${GREEN}✅ WSL2 networking configuration applied${NC}"
}

# Function to reset and recreate Docker networks
reset_docker_networks() {
    echo -e "${YELLOW}🌐 Resetting Docker networks...${NC}"
    
    # Remove custom networks (but keep default ones)
    docker network ls --filter type=custom -q | xargs -r docker network rm 2>/dev/null || true
    
    # Recreate development network
    docker network create dev-network --driver bridge 2>/dev/null || echo "dev-network already exists or creation failed"
    
    # Verify network creation
    if docker network ls | grep -q "dev-network"; then
        echo -e "${GREEN}✅ Development network recreated${NC}"
    else
        echo -e "${YELLOW}⚠️ Development network creation failed - will retry${NC}"
    fi
}

# Function to check and fix common WSL2 issues
fix_wsl2_common_issues() {
    echo -e "${YELLOW}🔧 Fixing common WSL2 Docker issues...${NC}"
    
    # Ensure Docker group exists and root is member
    groupadd docker 2>/dev/null || true
    usermod -aG docker root 2>/dev/null || true
    
    # Fix Docker socket permissions
    chmod 666 /var/run/docker.sock 2>/dev/null || true
    
    # Clear Docker temporary files
    rm -rf /tmp/docker* 2>/dev/null || true
    
    # Fix systemd issues in WSL2
    if ! systemctl is-active --quiet docker; then
        echo -e "${YELLOW}⚠️ Docker service not running - attempting to start${NC}"
        systemctl enable docker
        systemctl start docker
        sleep 3
    fi
    
    echo -e "${GREEN}✅ WSL2 common issues addressed${NC}"
}

# Main resolution process
echo -e "${BLUE}📋 Phase 1: Initial Diagnosis${NC}"
echo -e "${BLUE}─────────────────────────────${NC}"

# Test current state
if test_docker "version" && test_docker "daemon" && test_docker "network"; then
    echo -e "${GREEN}✅ Docker appears to be working - testing containers...${NC}"
    if test_docker "container"; then
        echo -e "${GREEN}🎉 Docker is fully functional! No fixes needed.${NC}"
        exit 0
    fi
fi

echo ""
echo -e "${BLUE}📋 Phase 2: Network Protocol Fix${NC}"
echo -e "${BLUE}─────────────────────────────────${NC}"

# Apply fixes
fix_wsl2_common_issues
fix_wsl2_networking
restart_docker_with_network_reset
reset_docker_networks

echo ""
echo -e "${BLUE}📋 Phase 3: Verification${NC}"
echo -e "${BLUE}──────────────────────────${NC}"

# Wait for Docker to stabilize
echo -e "${YELLOW}⏳ Waiting for Docker to stabilize...${NC}"
sleep 10

# Test all functionality
all_tests_passed=true

test_docker "version" || all_tests_passed=false
test_docker "daemon" || all_tests_passed=false
test_docker "network" || all_tests_passed=false
test_docker "container" || all_tests_passed=false

echo ""

if [ "$all_tests_passed" = true ]; then
    echo -e "${GREEN}🎉 Docker Network Protocol Resolution Complete!${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}✅ All Systems Operational:${NC}"
    echo "  • Docker CLI: Working"
    echo "  • Docker Daemon: Running" 
    echo "  • Docker Networks: Functional"
    echo "  • Container Operations: Working"
    echo ""
    echo -e "${CYAN}💡 Next Steps:${NC}"
    echo "  1. Run: ./dev-workflow/dev-env-start.sh"
    echo "  2. Check status: ./dev-workflow/dev-env-status.sh"
    echo ""
else
    echo -e "${RED}❌ Some issues persist${NC}"
    echo -e "${YELLOW}💡 Additional troubleshooting may be required:${NC}"
    echo "  1. Try WSL2 restart: wsl --shutdown && wsl"
    echo "  2. Check Windows Docker Desktop is running"
    echo "  3. Run full Docker recovery: ./docker-fixes/docker-wsl2-recovery.sh"
    exit 1
fi

# Create monitoring script for ongoing network health
cat > /usr/local/bin/docker-network-monitor << 'EOF'
#!/bin/bash
# Docker Network Health Monitor

check_network_health() {
    # Test Docker networking
    if ! timeout 5s docker network ls >/dev/null 2>&1; then
        echo "❌ Docker network issue detected at $(date)"
        return 1
    fi
    
    # Test container connectivity
    if ! timeout 10s docker run --rm --network dev-network alpine:latest ping -c 1 google.com >/dev/null 2>&1; then
        echo "⚠️ Container network connectivity issue at $(date)"
        return 1
    fi
    
    echo "✅ Docker networking healthy at $(date)"
    return 0
}

check_network_health
EOF

chmod +x /usr/local/bin/docker-network-monitor

echo -e "${CYAN}📊 Network Health Monitor installed: /usr/local/bin/docker-network-monitor${NC}"
echo -e "${GREEN}✨ Resolution Complete! ✨${NC}"