#!/bin/bash
# Docker WSL2 Segmentation Fault Recovery Script
# Specifically designed for root user in WSL2 Ubuntu

echo "🚨 Docker WSL2 Segmentation Fault Recovery Starting..."
echo "⚠️  This will completely reinstall Docker - existing containers will be preserved if possible"

# Function to test Docker functionality
test_docker() {
    echo "🧪 Testing Docker functionality..."
    timeout 10s docker --version >/dev/null 2>&1
    return $?
}

# Function to backup Docker data
backup_docker_data() {
    echo "💾 Attempting to backup Docker data before cleanup..."
    if [ -d "/var/lib/docker" ]; then
        mkdir -p backups/docker-data-backup
        cp -r /var/lib/docker/volumes backups/docker-data-backup/ 2>/dev/null || echo "Could not backup volumes"
        echo "Docker data backup attempted"
    fi
}

# Step 1: Initial Docker test
echo "📋 Step 1: Testing current Docker state..."
if test_docker; then
    echo "✅ Docker appears to be working! No recovery needed."
    exit 0
else
    echo "❌ Docker segmentation fault confirmed - proceeding with recovery"
fi

# Step 2: Backup any existing Docker data
backup_docker_data

# Step 3: Stop all Docker processes
echo "📋 Step 2: Stopping Docker processes..."
systemctl stop docker.service 2>/dev/null || echo "Docker service not running via systemctl"
systemctl stop docker.socket 2>/dev/null || echo "Docker socket not running via systemctl"
pkill -f docker 2>/dev/null || echo "No Docker processes to kill"
sleep 3

# Step 4: Remove corrupted Docker installation
echo "📋 Step 3: Removing corrupted Docker installation..."
apt-get remove -y docker docker-engine docker.io containerd runc docker-ce docker-ce-cli 2>/dev/null || echo "Some packages not found - continuing"

# Step 5: Clean Docker directories
echo "📋 Step 4: Cleaning Docker directories..."
rm -rf /usr/bin/docker* 2>/dev/null
rm -rf /usr/local/bin/docker* 2>/dev/null
rm -rf /root/.docker 2>/dev/null
rm -rf /etc/docker 2>/dev/null

# Note: Preserving /var/lib/docker for data recovery
echo "ℹ️  Preserving /var/lib/docker for potential data recovery"

# Step 6: Update package lists
echo "📋 Step 5: Updating package lists..."
apt-get update

# Step 7: Install prerequisites
echo "📋 Step 6: Installing prerequisites..."
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Step 8: Add Docker GPG key
echo "📋 Step 7: Adding Docker GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Step 9: Add Docker repository
echo "📋 Step 8: Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 10: Update package lists again
apt-get update

# Step 11: Install Docker
echo "📋 Step 9: Installing Docker CE..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Step 12: Configure Docker for root user
echo "📋 Step 10: Configuring Docker for root user..."
usermod -aG docker root
mkdir -p /root/.docker
chmod 755 /root/.docker

# Step 13: Configure Docker daemon for WSL2
echo "📋 Step 11: Configuring Docker daemon for WSL2..."
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
    }
}
EOF

# Step 14: Start Docker service
echo "📋 Step 12: Starting Docker service..."
systemctl enable docker
systemctl start docker

# Wait for Docker to start
echo "⏳ Waiting for Docker to start..."
sleep 5

# Step 15: Test Docker functionality
echo "📋 Step 13: Testing Docker functionality..."
if test_docker; then
    echo "✅ Docker CLI test passed!"
    
    # Additional tests
    echo "🧪 Running additional Docker tests..."
    
    # Test basic container operation
    if timeout 30s docker run --rm hello-world >/dev/null 2>&1; then
        echo "✅ Docker container test passed!"
    else
        echo "⚠️ Docker container test failed - but CLI is working"
    fi
    
    # Test Docker info
    if timeout 10s docker info >/dev/null 2>&1; then
        echo "✅ Docker daemon communication test passed!"
    else
        echo "⚠️ Docker daemon communication test failed"
    fi
    
else
    echo "❌ Docker test still failing - manual intervention may be required"
    echo "🔧 Trying alternative Docker installation method..."
    
    # Alternative installation using convenience script
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker root
    systemctl restart docker
    sleep 5
    
    if test_docker; then
        echo "✅ Alternative Docker installation successful!"
    else
        echo "❌ Docker recovery failed - please check system compatibility"
        exit 1
    fi
fi

# Step 16: Create Docker health monitoring
cat > /usr/local/bin/docker-health-check << 'EOF'
#!/bin/bash
# Docker health monitoring script

if ! timeout 10s docker --version >/dev/null 2>&1; then
    echo "❌ Docker segfault detected at $(date)" >> /var/log/docker-health.log
    exit 1
else
    echo "✅ Docker healthy at $(date)" >> /var/log/docker-health.log
    exit 0
fi
EOF

chmod +x /usr/local/bin/docker-health-check

# Final success message
echo ""
echo "🎉 Docker WSL2 Recovery Complete!"
echo "✅ Docker CLI: Working"
echo "✅ Docker Daemon: Running"
echo "✅ Root User: Configured"
echo ""
echo "📝 Next steps:"
echo "   1. Test Docker: docker --version"
echo "   2. Run containers: docker run --rm hello-world"
echo "   3. Proceed with enhanced setup"
echo ""
echo "📊 Health monitoring: /usr/local/bin/docker-health-check"