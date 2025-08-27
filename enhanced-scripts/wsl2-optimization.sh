#!/bin/bash
# WSL2 Optimization Script for Root User
# Optimizes WSL2 performance for development workloads

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}⚡ WSL2 Optimization Starting...${NC}"

# Load environment variables
if [ -f ".env" ]; then
    source .env
    echo "✅ Loaded environment variables from .env"
fi

# Function to create .wslconfig in Windows user directory
create_wslconfig() {
    local windows_user_dir="/mnt/c/Users/$1"
    local wslconfig_path="$windows_user_dir/.wslconfig"
    
    echo -e "${BLUE}📝 Creating optimized .wslconfig...${NC}"
    
    cat > "$wslconfig_path" << EOF
[wsl2]
# WSL2 Optimization Configuration
# Memory allocation (default: 50% of total RAM, max 8GB recommended)
memory=${WSL2_MEMORY_LIMIT:-8GB}

# Processor allocation (default: same as logical processor count)
processors=${WSL2_PROCESSORS:-4}

# Swap allocation (default: 25% of memory size)
swap=${WSL2_SWAP:-2GB}

# Additional memory to be assigned to WSL2 VM
# This is in addition to memory limit
localhostForwarding=true

# Boolean specifying if ports bound to wildcard or localhost in the WSL 2 VM should be connectable from the host via localhost:port
localhostForwarding=true

# Boolean to turn on or off nested virtualization (for Docker)
nestedVirtualization=true

# Boolean to turn on or off support for GUI applications
guiApplications=false

# The number of milliseconds that a VM is idle, before it is shut down
vmIdleTimeout=60000

# Boolean to turn on an output console Window that shows the contents of dmesg upon start of a WSL 2 distro instance
debugConsole=false
EOF

    echo -e "${GREEN}✅ .wslconfig created at: $wslconfig_path${NC}"
    echo -e "${YELLOW}⚠️ Restart WSL2 for changes to take effect: wsl --shutdown${NC}"
}

# Function to optimize Docker for WSL2
optimize_docker_wsl2() {
    echo -e "${BLUE}🐳 Optimizing Docker for WSL2...${NC}"
    
    # Create Docker daemon configuration optimized for WSL2
    mkdir -p /etc/docker
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
    "default-ulimits": {
        "memlock": {
            "Hard": -1,
            "Name": "memlock",
            "Soft": -1
        },
        "nofile": {
            "Hard": 655360,
            "Name": "nofile",
            "Soft": 655360
        }
    },
    "max-concurrent-downloads": 3,
    "max-concurrent-uploads": 3,
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ]
}
EOF

    echo -e "${GREEN}✅ Docker daemon optimized for WSL2${NC}"
}

# Function to optimize system kernel parameters
optimize_kernel_parameters() {
    echo -e "${BLUE}⚙️ Optimizing kernel parameters...${NC}"
    
    # Backup existing sysctl.conf
    cp /etc/sysctl.conf /etc/sysctl.conf.backup 2>/dev/null || true
    
    # Add WSL2 optimizations to sysctl.conf
    cat >> /etc/sysctl.conf << 'EOF'

# WSL2 Development Environment Optimizations
# Network optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# File system optimizations
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512

# Memory management optimizations
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# Security optimizations (for development)
kernel.dmesg_restrict = 0
EOF

    # Apply sysctl changes
    sysctl -p /etc/sysctl.conf >/dev/null 2>&1 || echo "Some sysctl changes require reboot"
    
    echo -e "${GREEN}✅ Kernel parameters optimized${NC}"
}

# Function to optimize root user environment
optimize_root_environment() {
    echo -e "${BLUE}👤 Optimizing root user environment...${NC}"
    
    # Backup existing .bashrc
    cp /root/.bashrc /root/.bashrc.backup 2>/dev/null || true
    
    # Add optimizations to .bashrc
    cat >> /root/.bashrc << 'EOF'

# WSL2 Development Environment Optimizations
# Docker optimizations
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Development tool optimizations
export NODE_OPTIONS="--max_old_space_size=4096"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# History optimizations
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups

# Enhanced aliases for development
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dlog='docker logs'
alias dexec='docker exec -it'

# Development environment aliases
alias dev-start='./dev-workflow/dev-env-start.sh'
alias dev-stop='./dev-workflow/dev-env-stop.sh'
alias dev-status='./dev-workflow/dev-env-status.sh'
alias dev-reset='./dev-workflow/dev-env-reset.sh'

# Quick navigation
alias cddev='cd /root/AI-IoT-Cyber-Dev-Bundle'

# Resource monitoring
alias meminfo='free -h && echo && df -h'
alias sysinfo='uname -a && echo && free -h && echo && df -h'
EOF

    # Source the updated .bashrc
    source /root/.bashrc 2>/dev/null || true
    
    echo -e "${GREEN}✅ Root environment optimized${NC}"
}

# Function to optimize file system permissions
optimize_filesystem() {
    echo -e "${BLUE}📁 Optimizing file system...${NC}"
    
    # Set appropriate permissions for development files
    find /root/AI-IoT-Cyber-Dev-Bundle -type f -name "*.sh" -exec chmod +x {} \;
    chmod 600 .env 2>/dev/null || true
    
    # Create development directories if they don't exist
    mkdir -p /root/dev/{projects,temp,logs} 2>/dev/null || true
    mkdir -p /root/.local/{bin,share} 2>/dev/null || true
    
    echo -e "${GREEN}✅ File system optimized${NC}"
}

# Function to setup development tools paths
setup_development_paths() {
    echo -e "${BLUE}🛠️ Setting up development paths...${NC}"
    
    # Add common development tool paths
    cat >> /root/.bashrc << 'EOF'

# Development tool paths
export PATH="/root/.local/bin:$PATH"
export PATH="/root/miniconda/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export PATH="/root/.cargo/bin:$PATH"

# Python development
export PYTHONPATH="/root/dev/projects:$PYTHONPATH"

# Node.js development  
export NODE_PATH="/usr/local/lib/node_modules:$NODE_PATH"

# Go development
export GOPATH="/root/dev/go"
export GOBIN="$GOPATH/bin"
EOF

    echo -e "${GREEN}✅ Development paths configured${NC}"
}

# Main execution
echo -e "${BLUE}🔍 Detecting Windows user for .wslconfig setup...${NC}"

# Try to detect Windows username
windows_username=""
if [ -d "/mnt/c/Users" ]; then
    for user_dir in /mnt/c/Users/*/; do
        username=$(basename "$user_dir")
        if [ "$username" != "Public" ] && [ "$username" != "Default" ] && [ "$username" != "All Users" ]; then
            windows_username="$username"
            break
        fi
    done
fi

if [ -n "$windows_username" ]; then
    echo -e "${GREEN}Found Windows user: $windows_username${NC}"
    create_wslconfig "$windows_username"
else
    echo -e "${YELLOW}Could not detect Windows username - .wslconfig setup skipped${NC}"
    echo -e "${BLUE}💡 Manually create .wslconfig in C:\\Users\\YourUsername\\.wslconfig${NC}"
fi

# Run optimizations
optimize_docker_wsl2
optimize_kernel_parameters
optimize_root_environment
optimize_filesystem
setup_development_paths

# Create system monitoring script
cat > /usr/local/bin/wsl2-monitor << 'EOF'
#!/bin/bash
# WSL2 System Monitor

echo "=== WSL2 System Status ==="
echo "Date: $(date)"
echo ""
echo "=== Memory Usage ==="
free -h
echo ""
echo "=== Disk Usage ==="
df -h / /tmp
echo ""
echo "=== Docker Status ==="
if command -v docker &> /dev/null; then
    docker version --format '{{.Server.Version}}' 2>/dev/null && echo "Docker: Running" || echo "Docker: Not running"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers running"
else
    echo "Docker: Not installed"
fi
echo ""
echo "=== Network Ports ==="
netstat -tuln 2>/dev/null | grep LISTEN | head -10
EOF

chmod +x /usr/local/bin/wsl2-monitor

# Final summary
echo ""
echo -e "${GREEN}🎉 WSL2 Optimization Complete!${NC}"
echo ""
echo -e "${BLUE}📋 Applied Optimizations:${NC}"
echo "  ✅ .wslconfig created with memory/CPU limits"
echo "  ✅ Docker daemon optimized for WSL2"
echo "  ✅ Kernel parameters tuned for development"
echo "  ✅ Root environment enhanced with aliases"
echo "  ✅ File system permissions optimized"
echo "  ✅ Development tool paths configured"
echo "  ✅ System monitoring script installed"
echo ""
echo -e "${BLUE}💡 Next Steps:${NC}"
echo "  1. Restart WSL2: wsl --shutdown (from Windows)"
echo "  2. Restart WSL2: wsl (from Windows)"
echo "  3. Run system monitor: wsl2-monitor"
echo "  4. Start development: ./dev-workflow/dev-env-start.sh"
echo ""
echo -e "${YELLOW}⚠️ Some changes require WSL2 restart to take effect${NC}"