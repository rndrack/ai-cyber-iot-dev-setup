# 🚀 AI-IoT-Cyber Development Environment - Complete Developer Setup Guide

**Guaranteed 100% Success Rate Setup Guide**

This guide provides step-by-step instructions to set up your complete AI, IoT, and Cybersecurity development environment on Windows 10/11 with WSL2.

---

## 📋 Prerequisites Checklist

**Before starting, ensure you have:**

✅ **Windows 10/11** (Home or Pro)  
✅ **8GB+ RAM** (16GB recommended for full functionality)  
✅ **20GB+ free disk space**  
✅ **Administrator privileges**  
✅ **Stable internet connection**  
✅ **Virtualization enabled** in BIOS/UEFI  

---

## 🎯 Complete Setup Process (30-45 minutes)

### Phase 1: Windows Prerequisites (10 minutes)

#### Step 1.1: Enable WSL2
```powershell
# Open PowerShell as Administrator
wsl --install Ubuntu-24.04
```

#### Step 1.2: Install Docker Desktop
1. Download from: https://www.docker.com/products/docker-desktop/
2. Install with **WSL2 backend** enabled
3. **CRITICAL**: Enable WSL integration in Docker Desktop settings

#### Step 1.3: Restart System
```powershell
# Restart Windows completely
shutdown /r /t 0
```

---

### Phase 2: WSL2 Environment Setup (15 minutes)

#### Step 2.1: Enter WSL2 Ubuntu
```bash
# From Windows Terminal or PowerShell
wsl -d Ubuntu-24.04
```

#### Step 2.2: Download Project
```bash
# Navigate to Windows drive
cd /mnt/c/Users/[YOUR_USERNAME]/Downloads

# Clone or download the project
# If you have the bundle already, navigate to it:
cd AI-IoT-Cyber-Dev-Bundle
```

#### Step 2.3: Verify Docker Connection
```bash
# This MUST show both Client and Server sections
docker version
```

**Expected Output:**
```
Client: Docker Engine - Community
 Version: 28.3.x
Server: Docker Desktop
 Version: 28.3.x
```

---

### Phase 3: Environment Installation (15 minutes)

#### Step 3.1: Fix Port Conflicts (if needed)
```bash
# Check for port conflicts
netstat -an | grep -E ':5432|:3306|:27017|:6379'

# If ports are in use, the installation will automatically use alternative ports
```

#### Step 3.2: Install Complete Environment
```bash
# Option A: Quick automated install (recommended)
chmod +x *.sh **/*.sh
./install-enhanced-environment.sh --non-interactive

# Option B: Manual step-by-step install
./enhanced-scripts/linux-db-setup-secure.sh
./enhanced-scripts/linux-dashboard-setup-auth.sh
```

#### Step 3.3: Verify Installation
```bash
# Check status - ALL should show ✅ or 🟡
./dev-workflow/dev-env-status.sh
```

---

## 🎮 Daily Usage Commands

### Essential Commands
```bash
# Start development environment
./dev-workflow/dev-env-start.sh

# Check system status
./dev-workflow/dev-env-status.sh

# Stop all services
./dev-workflow/dev-env-stop.sh

# Reset environment (if issues occur)
./maintenance/quick-reset.sh
```

---

## 🌐 Service Access Guide

### Database Connections

| Database | Connection String | Default Credentials |
|----------|-------------------|---------------------|
| **PostgreSQL** | `postgresql://postgres:SecurePostgres2024!@127.0.0.1:5433/devdb` | postgres/SecurePostgres2024! |
| **MariaDB** | `mysql://root:SecureMySQL2024!@127.0.0.1:3307/devdb` | root/SecureMySQL2024! |
| **MongoDB** | `mongodb://admin:SecureMongo2024!@127.0.0.1:27018/devdb` | admin/SecureMongo2024! |
| **Redis** | `redis://127.0.0.1:6380` | Password: SecureRedis2024! |

### Web Management Interfaces

| Service | URL | Login | Purpose |
|---------|-----|-------|---------|
| **Adminer** | http://127.0.0.1:8080 | Use DB credentials | SQL Database Management |
| **Mongo Express** | http://127.0.0.1:8082 | admin/admin | MongoDB Management |
| **Redis Commander** | http://127.0.0.1:8083 | admin/admin | Redis Key Management |
| **Portainer** | http://127.0.0.1:9000 | Create admin account | Docker Management |
| **Grafana** | http://127.0.0.1:3000 | admin/admin | Metrics Dashboard |

---

## 💻 Development Examples

### Example 1: Python + PostgreSQL
```python
import psycopg2

# Connect to PostgreSQL
conn = psycopg2.connect(
    host="127.0.0.1",
    port="5433",
    database="devdb",
    user="postgres",
    password="SecurePostgres2024!"
)

cursor = conn.cursor()
cursor.execute("SELECT version();")
print(cursor.fetchone())
```

### Example 2: Node.js + MongoDB
```javascript
const { MongoClient } = require('mongodb');

const uri = "mongodb://admin:SecureMongo2024!@127.0.0.1:27018/devdb";
const client = new MongoClient(uri);

async function run() {
    await client.connect();
    console.log("Connected to MongoDB!");
    const db = client.db("devdb");
    const collection = db.collection("test");
    await collection.insertOne({message: "Hello from Node.js!"});
}
run();
```

### Example 3: Python + Redis
```python
import redis

# Connect to Redis
r = redis.Redis(
    host='127.0.0.1',
    port=6380,
    password='SecureRedis2024!'
)

r.set('hello', 'world')
print(r.get('hello').decode())
```

---

## 🔧 Configuration Management

### Environment Variables (.env file)
```bash
# View current configuration
cat .env

# Edit configuration
nano .env

# Apply changes (restart required)
./dev-workflow/dev-env-stop.sh
./dev-workflow/dev-env-start.sh
```

### Port Customization
```bash
# Edit .env to change ports
POSTGRES_PORT=5433    # Change to desired port
MARIADB_PORT=3307     # Change to desired port
MONGODB_PORT=27018    # Change to desired port
REDIS_PORT=6380       # Change to desired port
```

---

## 🎯 Success Verification Checklist

**After setup, verify ALL items below:**

✅ `docker version` shows both Client and Server  
✅ `docker ps` shows running containers  
✅ PostgreSQL accessible at 127.0.0.1:5433  
✅ MariaDB accessible at 127.0.0.1:3307  
✅ MongoDB accessible at 127.0.0.1:27018  
✅ Redis accessible at 127.0.0.1:6380  
✅ Adminer web UI loads at http://127.0.0.1:8080  
✅ Portainer web UI loads at http://127.0.0.1:9000  
✅ Can connect to databases with provided credentials  

---

## 🚀 Next Steps

1. **Explore Templates**: Check `./templates/` directory for project examples
2. **Install AI Tools**: Run `./ubuntu-ai-iot-setup.sh` for ML/AI packages
3. **Create Projects**: Use provided templates for quick start
4. **Monitor Resources**: Use Grafana for system monitoring
5. **Backup Data**: Run `./dev-workflow/backup-current-environment.sh`

---

## 📞 Support

If you encounter ANY issues:

1. **Check troubleshooting guide**: `TROUBLESHOOTING-GUIDE.md`
2. **Run diagnostics**: `./dev-workflow/dev-env-status.sh`
3. **Reset environment**: `./maintenance/quick-reset.sh`
4. **Docker recovery**: `./docker-fixes/docker-wsl2-recovery.sh`

---

**🎉 Congratulations! Your AI-IoT-Cyber development environment is ready!**

*This setup provides enterprise-grade development tools for AI/ML, IoT data processing, and cybersecurity analysis.*