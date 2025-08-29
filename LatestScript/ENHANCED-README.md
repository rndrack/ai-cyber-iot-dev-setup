# 🚀 Enhanced AI-IoT-Cyber Development Environment

Complete, secure, and optimized development environment for **AI, IoT, and Cybersecurity** on **WSL2 Ubuntu** with **root user configuration**.

---

## 🆕 What's New in Enhanced Version

### 🔧 **Docker WSL2 Fix**
- Automatic Docker segmentation fault recovery
- WSL2-optimized Docker daemon configuration
- Comprehensive Docker health monitoring

### 🔐 **Enhanced Security**
- Custom passwords for all databases (configurable in `.env`)
- Localhost-only binding for all services
- Basic authentication for management dashboards
- Secure credential management

### 🌌 **Azure CosmosDB Emulator**
- Local CosmosDB development environment
- Full Azure compatibility without cloud costs
- Python SDK examples and templates
- Data Explorer web interface

### ⚡ **WSL2 Performance Optimization**
- Optimized memory and CPU allocation
- Enhanced Docker performance for WSL2
- System kernel parameter tuning
- Development tool path configuration

### 🎛️ **Advanced Management**
- Comprehensive health monitoring
- One-command environment startup/shutdown
- Flexible reset options with data preservation
- Resource usage monitoring

---

## 🏗️ Architecture Overview

```
Windows Host + WSL2 Ubuntu (Root User)
├── 🗄️ Database Layer (Docker Containers)
│   ├── PostgreSQL (5432) - Relational data
│   ├── MariaDB (3306) - Alternative SQL
│   ├── MongoDB (27017) - Document store
│   ├── Redis (6379) - Cache/messaging
│   └── CosmosDB Emulator (8081) - Azure NoSQL
├── 🎛️ Management Layer (Web UIs)
│   ├── Adminer (8080) - SQL database management
│   ├── Mongo Express (8082) - MongoDB UI
│   ├── Redis Commander (8083) - Redis UI
│   ├── Portainer (9000) - Docker management
│   └── Dozzle (9999) - Container logs
└── 📊 Monitoring Layer
    ├── InfluxDB (8086) - Time-series metrics
    └── Grafana (3000) - Visualization dashboards
```

---

## ⚡ Quick Installation

### Prerequisites
- **Windows 10/11** with WSL2 enabled
- **Ubuntu 24.04** in WSL2
- **Root user access**
- **4GB+ available memory** (8GB+ recommended for CosmosDB)

### One-Command Installation

```bash
# Clone or download the enhanced bundle
cd AI-IoT-Cyber-Dev-Bundle

# Run the complete installation
chmod +x install-enhanced-environment.sh
./install-enhanced-environment.sh
```

### Manual Step-by-Step Installation

```bash
# 1. Create backup of current environment
./dev-workflow/backup-current-environment.sh

# 2. Fix Docker WSL2 issues (if needed)
./docker-fixes/docker-wsl2-recovery.sh

# 3. Install enhanced database stack
./enhanced-scripts/linux-db-setup-secure.sh

# 4. Setup management dashboards
./enhanced-scripts/linux-dashboard-setup-auth.sh

# 5. Optimize WSL2 performance
./enhanced-scripts/wsl2-optimization.sh
```

---

## 🎮 Daily Usage

### Start Development Environment
```bash
./dev-workflow/dev-env-start.sh
```

### Check System Status
```bash
./dev-workflow/dev-env-status.sh
```

### Stop All Services
```bash
./dev-workflow/dev-env-stop.sh
```

### Reset Environment
```bash
./maintenance/quick-reset.sh
```

---

## 🌐 Service Access

| Service | URL | Credentials | Purpose |
|---------|-----|-------------|---------|
| **PostgreSQL** | `127.0.0.1:5432` | postgres/SecurePostgres2024! | Relational database |
| **MariaDB** | `127.0.0.1:3306` | root/SecureMySQL2024! | Alternative SQL database |
| **MongoDB** | `127.0.0.1:27017` | admin/SecureMongo2024! | Document database |
| **Redis** | `127.0.0.1:6379` | SecureRedis2024! | Cache/messaging |
| **CosmosDB** | `https://127.0.0.1:8081/_explorer/` | Emulator key | Azure NoSQL emulator |
| **Adminer** | `http://127.0.0.1:8080` | - | SQL database UI |
| **Mongo Express** | `http://127.0.0.1:8082` | admin/admin | MongoDB UI |
| **Redis Commander** | `http://127.0.0.1:8083` | admin/admin | Redis UI |
| **Portainer** | `http://127.0.0.1:9000` | - | Docker management |
| **Dozzle** | `http://127.0.0.1:9999` | admin/admin | Container logs |
| **Grafana** | `http://127.0.0.1:3000` | admin/admin | Dashboards |
| **InfluxDB** | `http://127.0.0.1:8086` | admin/admin | Metrics storage |

---

## 🔐 Security Configuration

### Default Credentials
All default credentials are stored in `.env` file:

```bash
# Database passwords (change these!)
POSTGRES_PASSWORD=SecurePostgres2024!
MYSQL_ROOT_PASSWORD=SecureMySQL2024!
MONGODB_ROOT_PASSWORD=SecureMongo2024!
REDIS_PASSWORD=SecureRedis2024!

# Dashboard credentials
DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=admin
```

### Security Features
- ✅ All services bound to localhost only (127.0.0.1)
- ✅ Custom passwords for all databases
- ✅ Basic authentication for web dashboards
- ✅ Docker container isolation
- ✅ Secure environment variable management

---

## 🛠️ Development Examples

### AI/ML Development
```bash
# Activate enhanced AI environment
conda activate ai-dev-enhanced

# Start Jupyter Lab
jupyter lab --ip=0.0.0.0 --port=8888 --allow-root

# Example: Store ML results in PostgreSQL
python templates/ai-project/ml-postgres-example.py
```

### IoT Development with CosmosDB
```bash
# Navigate to CosmosDB examples
cd templates/cosmosdb-project/python-cosmos

# Install dependencies
pip install -r requirements.txt

# Run CosmosDB example
python cosmos_client.py
```

### Cybersecurity Analysis
```bash
# Use databases for security data storage
# MongoDB for vulnerability scans
# PostgreSQL for audit logs
# Redis for real-time threat intelligence
```

---

## 🔄 Reset & Recovery Options

### Quick Reset Menu
```bash
./maintenance/quick-reset.sh
```

Reset options:
1. **Restart Services** - Restart containers only
2. **Clean Reset** - Remove containers, keep data
3. **Full Reset** - Remove everything (⚠️ DATA LOSS)
4. **Docker Reset** - Fix Docker issues only
5. **Backup & Reset** - Backup data first
6. **Selective Reset** - Choose specific services
7. **Space Cleanup** - Remove unused resources

### Manual Recovery
```bash
# Restore from backup
ls backups/  # Find your backup
./dev-workflow/restore-environment.sh backup_name

# Fix specific issues
./docker-fixes/docker-wsl2-recovery.sh        # Docker problems
./enhanced-scripts/wsl2-optimization.sh       # Performance issues
```

---

## 📊 Monitoring & Troubleshooting

### System Health Check
```bash
./dev-workflow/dev-env-status.sh
```

### Resource Monitoring
```bash
# WSL2 system monitor
wsl2-monitor

# Docker resource usage
docker stats

# Container logs
docker logs container_name
```

### Common Issues

#### Docker Segmentation Fault
```bash
./docker-fixes/docker-wsl2-recovery.sh
```

#### CosmosDB Won't Start
- Check available memory (requires 3GB+)
- Restart WSL2: `wsl --shutdown` then `wsl`
- Check port conflicts: `netstat -tuln | grep 8081`

#### Service Not Accessible
- Verify container is running: `docker ps`
- Check port binding: `netstat -tuln | grep PORT`
- Review container logs: `docker logs container_name`

---

## 🎯 Project Templates

### Available Templates
- **AI Project** - Machine learning with database integration
- **IoT Project** - Sensor data with MQTT and time-series storage
- **Cyber Project** - Security analysis with data storage
- **CosmosDB Project** - Azure NoSQL development examples

### Create New Project
```bash
# Copy template
cp -r templates/cosmosdb-project/python-cosmos my-new-project
cd my-new-project

# Install dependencies
pip install -r requirements.txt

# Start development
python cosmos_client.py
```

---

## 🆙 Updates & Maintenance

### Update Container Images
```bash
# Update all images
docker images --format "table {{.Repository}}:{{.Tag}}" | grep -v REPOSITORY | xargs -I {} docker pull {}

# Restart with new images
./dev-workflow/dev-env-stop.sh
./dev-workflow/dev-env-start.sh
```

### Backup Schedule
```bash
# Manual backup
./dev-workflow/backup-current-environment.sh

# Automated backup (add to crontab)
0 2 * * * /root/AI-IoT-Cyber-Dev-Bundle/dev-workflow/backup-current-environment.sh
```

---

## 🤝 Contributing & Customization

### Customize Configuration
1. **Edit `.env` file** - Change passwords, ports, resource limits
2. **Modify scripts** - Enhance functionality in `enhanced-scripts/`
3. **Add templates** - Create new project templates in `templates/`

### Environment Variables
```bash
# Resource limits
WSL2_MEMORY_LIMIT=8GB
COSMOSDB_MAX_MEMORY=3g
POSTGRES_MAX_MEMORY=512m

# Network configuration
BIND_ADDRESS=127.0.0.1
POSTGRES_PORT=5432

# Security settings
ENABLE_BASIC_AUTH=true
DASHBOARD_USERNAME=admin
```

---

## 📄 License & Support

This enhanced development environment uses **only open-source components**:
- PostgreSQL, MariaDB, MongoDB, Redis (Database Engines)
- Adminer, Mongo Express, Redis Commander (Management UIs)
- Grafana, InfluxDB (Monitoring Stack)
- Azure CosmosDB Emulator (Microsoft, free for development)

### Getting Help
- Check `./dev-workflow/dev-env-status.sh` for system status
- Review container logs: `docker logs container_name`
- Use reset tools: `./maintenance/quick-reset.sh`
- Create GitHub issues for bugs/features

---

## ✨ What's Next?

- 🔬 **Add Jupyter Hub** for multi-user AI development
- 🔍 **Elasticsearch Integration** for log analysis
- 🚀 **Kubernetes Support** for container orchestration
- 🔒 **Advanced Security** with SSL certificates
- 📱 **Mobile Development** tools integration

---

**🎉 Happy Development with Enhanced AI-IoT-Cyber Environment! 🎉**

*Complete, secure, and optimized for WSL2 root user development.*