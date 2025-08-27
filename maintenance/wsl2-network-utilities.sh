#!/bin/bash
# WSL2 Network Utilities
# Comprehensive WSL2 networking tools and diagnostics

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🌐 WSL2 Network Utilities${NC}"
echo -e "${BLUE}═══════════════════════${NC}"
echo ""

# Function to show menu
show_menu() {
    echo -e "${YELLOW}Select network utility:${NC}"
    echo ""
    echo "1. 🔍 Network Diagnostics"
    echo "2. 🔧 Fix Docker Networking Issues" 
    echo "3. 🔄 Reset WSL2 Network Stack"
    echo "4. 📊 Network Performance Test"
    echo "5. 🌉 WSL2 Bridge Configuration"
    echo "6. 🐳 Docker Network Troubleshoot"
    echo "7. 📱 Container Connectivity Test"
    echo "8. ❌ Exit"
    echo ""
}

# Function to run network diagnostics
network_diagnostics() {
    echo -e "${BLUE}🔍 Running Network Diagnostics...${NC}"
    echo ""
    
    # Basic connectivity
    echo "=== Basic Connectivity ==="
    echo -n "Internet connectivity: "
    if ping -c 1 google.com >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Working${NC}"
    else
        echo -e "${RED}❌ Failed${NC}"
    fi
    
    echo -n "DNS resolution: "
    if nslookup google.com >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Working${NC}"
    else
        echo -e "${RED}❌ Failed${NC}"
    fi
    
    # WSL2 specific
    echo ""
    echo "=== WSL2 Network Info ==="
    echo "WSL2 IP: $(hostname -I | awk '{print $1}')"
    echo "Default Gateway: $(ip route show default | awk '{print $3}')"
    echo "DNS Servers: $(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | tr '\n' ' ')"
    
    # Docker networking
    echo ""
    echo "=== Docker Network Status ==="
    if command -v docker >/dev/null 2>&1; then
        if docker info >/dev/null 2>&1; then
            echo -e "${GREEN}Docker Daemon: Running${NC}"
            echo "Docker Networks:"
            docker network ls --format "  {{.Name}} ({{.Driver}})"
            
            echo ""
            echo "Docker Bridge Info:"
            ip addr show docker0 2>/dev/null | grep -E "(inet|state)" || echo "  Docker bridge not found"
        else
            echo -e "${RED}Docker Daemon: Not accessible${NC}"
        fi
    else
        echo -e "${YELLOW}Docker: Not installed${NC}"
    fi
    
    # Port usage
    echo ""
    echo "=== Active Ports ==="
    echo "Listening ports on localhost:"
    netstat -tuln 2>/dev/null | grep "127.0.0.1" | grep "LISTEN" | awk '{print "  " $4}' | head -10
}

# Function to fix Docker networking
fix_docker_networking() {
    echo -e "${BLUE}🔧 Fixing Docker Networking Issues...${NC}"
    ./docker-fixes/docker-network-resolver.sh
}

# Function to reset WSL2 network stack
reset_wsl2_network() {
    echo -e "${YELLOW}🔄 WSL2 Network Stack Reset${NC}"
    echo "This will reset WSL2 networking configuration"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Resetting network stack...${NC}"
        
        # Clear network configuration
        sudo ip addr flush dev eth0 2>/dev/null || true
        sudo ip route flush table main 2>/dev/null || true
        
        # Reset resolv.conf
        sudo rm -f /etc/resolv.conf
        
        # Restart networking service
        sudo service networking restart 2>/dev/null || true
        
        echo -e "${YELLOW}⚠️ WSL2 restart recommended: wsl --shutdown && wsl${NC}"
        echo -e "${GREEN}✅ Network stack reset completed${NC}"
    fi
}

# Function to test network performance
network_performance_test() {
    echo -e "${BLUE}📊 Network Performance Test...${NC}"
    echo ""
    
    # Ping test
    echo "=== Latency Test ==="
    echo "Ping to Google DNS:"
    ping -c 5 8.8.8.8 | tail -1 | awk '{print "  " $0}'
    
    echo ""
    echo "Ping to Docker bridge:"
    if ip route show | grep -q docker0; then
        docker_gateway=$(ip route show | grep docker0 | awk '{print $9}' | head -1)
        ping -c 3 "$docker_gateway" 2>/dev/null | tail -1 | awk '{print "  " $0}' || echo "  Docker bridge unreachable"
    else
        echo "  Docker bridge not found"
    fi
    
    # Download test (small file)
    echo ""
    echo "=== Download Speed Test ==="
    echo "Downloading small test file..."
    if timeout 10s curl -s -o /dev/null -w "Speed: %{speed_download} bytes/sec\nTime: %{time_total}s\n" http://speedtest.ftp.otenet.gr/files/test1Mb.db 2>/dev/null; then
        echo "  Download test completed"
    else
        echo "  Download test failed"
    fi
}

# Function to configure WSL2 bridge
configure_wsl2_bridge() {
    echo -e "${BLUE}🌉 WSL2 Bridge Configuration...${NC}"
    echo ""
    
    echo "Current network interfaces:"
    ip addr show | grep -E "^[0-9]+:" | awk '{print "  " $2}'
    
    echo ""
    echo "Current routing table:"
    ip route show | head -5 | awk '{print "  " $0}'
    
    echo ""
    echo "WSL2 bridge configuration is managed by Windows."
    echo "For advanced configuration, modify .wslconfig in Windows user directory."
    
    echo ""
    read -p "Show current .wslconfig? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        windows_user=$(ls /mnt/c/Users/ | grep -v -E "(Public|Default|All Users)" | head -1)
        if [ -f "/mnt/c/Users/$windows_user/.wslconfig" ]; then
            echo "Current .wslconfig:"
            cat "/mnt/c/Users/$windows_user/.wslconfig"
        else
            echo "No .wslconfig found"
        fi
    fi
}

# Function to troubleshoot Docker network
troubleshoot_docker_network() {
    echo -e "${BLUE}🐳 Docker Network Troubleshoot...${NC}"
    echo ""
    
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker not installed${NC}"
        return
    fi
    
    # Test Docker daemon
    echo "=== Docker Daemon Test ==="
    if docker info >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker daemon accessible${NC}"
    else
        echo -e "${RED}❌ Docker daemon not accessible${NC}"
        echo "Try: sudo systemctl restart docker"
        return
    fi
    
    # Test Docker networks
    echo ""
    echo "=== Docker Networks ==="
    docker network ls
    
    # Test dev-network specifically
    echo ""
    echo "=== Development Network Test ==="
    if docker network ls | grep -q "dev-network"; then
        echo -e "${GREEN}✅ dev-network exists${NC}"
        docker network inspect dev-network --format "  Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}}"
        docker network inspect dev-network --format "  Gateway: {{range .IPAM.Config}}{{.Gateway}}{{end}}"
    else
        echo -e "${YELLOW}⚠️ dev-network missing${NC}"
        read -p "Create dev-network? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker network create dev-network
            echo -e "${GREEN}✅ dev-network created${NC}"
        fi
    fi
    
    # Test container networking
    echo ""
    echo "=== Container Network Test ==="
    echo "Testing container connectivity..."
    if timeout 30s docker run --rm --network dev-network alpine:latest ping -c 2 google.com >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Container networking working${NC}"
    else
        echo -e "${RED}❌ Container networking failed${NC}"
        echo "This may indicate network protocol issues"
    fi
}

# Function to test container connectivity
test_container_connectivity() {
    echo -e "${BLUE}📱 Container Connectivity Test...${NC}"
    echo ""
    
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker not installed${NC}"
        return
    fi
    
    # Test basic container run
    echo "=== Basic Container Test ==="
    if timeout 30s docker run --rm hello-world >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Basic container operations working${NC}"
    else
        echo -e "${RED}❌ Basic container operations failed${NC}"
        return
    fi
    
    # Test network connectivity from container
    echo ""
    echo "=== Container Network Connectivity ==="
    echo "Testing external connectivity from container..."
    if timeout 30s docker run --rm alpine:latest ping -c 3 google.com >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Container external connectivity working${NC}"
    else
        echo -e "${RED}❌ Container external connectivity failed${NC}"
    fi
    
    # Test dev-network connectivity
    echo ""
    echo "=== Development Network Connectivity ==="
    if docker network ls | grep -q "dev-network"; then
        echo "Testing dev-network connectivity..."
        if timeout 30s docker run --rm --network dev-network alpine:latest ping -c 2 google.com >/dev/null 2>&1; then
            echo -e "${GREEN}✅ dev-network connectivity working${NC}"
        else
            echo -e "${RED}❌ dev-network connectivity failed${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ dev-network not found${NC}"
    fi
    
    # Test port binding
    echo ""
    echo "=== Port Binding Test ==="
    echo "Testing port binding capability..."
    if timeout 15s docker run --rm -p 8999:80 nginx:alpine >/dev/null 2>&1 & 
       sleep 5 && curl -s http://localhost:8999 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Port binding working${NC}"
    else
        echo -e "${RED}❌ Port binding failed${NC}"
    fi
    
    # Clean up any test containers
    docker stop $(docker ps -q --filter "ancestor=nginx:alpine") 2>/dev/null || true
}

# Main menu loop
while true; do
    show_menu
    read -p "Enter your choice (1-8): " choice
    echo ""
    
    case $choice in
        1) network_diagnostics; echo; read -p "Press Enter to continue..."; echo ;;
        2) fix_docker_networking; echo; read -p "Press Enter to continue..."; echo ;;
        3) reset_wsl2_network; echo; read -p "Press Enter to continue..."; echo ;;
        4) network_performance_test; echo; read -p "Press Enter to continue..."; echo ;;
        5) configure_wsl2_bridge; echo; read -p "Press Enter to continue..."; echo ;;
        6) troubleshoot_docker_network; echo; read -p "Press Enter to continue..."; echo ;;
        7) test_container_connectivity; echo; read -p "Press Enter to continue..."; echo ;;
        8) echo -e "${BLUE}👋 Exiting WSL2 Network Utilities${NC}"; break ;;
        *) echo -e "${RED}Invalid choice. Please enter 1-8.${NC}"; echo ;;
    esac
done