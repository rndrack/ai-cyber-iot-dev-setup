# 🌐 Service Access Reference Guide

**Complete Database and Service Connection Guide**

This guide provides all connection strings, credentials, and access methods for every service in your development environment.

---

## 🗄️ Database Services

### PostgreSQL Database
**Connection Details:**
- **Host**: `127.0.0.1`
- **Port**: `5433`
- **Database**: `devdb`
- **Username**: `postgres`
- **Password**: `SecurePostgres2024!`

**Connection Strings:**
```bash
# Command Line
psql -h 127.0.0.1 -p 5433 -U postgres -d devdb

# Environment Variable
export DATABASE_URL="postgresql://postgres:SecurePostgres2024!@127.0.0.1:5433/devdb"
```

**Application Examples:**
```python
# Python (psycopg2)
import psycopg2
conn = psycopg2.connect(
    host="127.0.0.1",
    port="5433",
    database="devdb",
    user="postgres",
    password="SecurePostgres2024!"
)

# Python (SQLAlchemy)
from sqlalchemy import create_engine
engine = create_engine('postgresql://postgres:SecurePostgres2024!@127.0.0.1:5433/devdb')
```

```javascript
// Node.js (pg)
const { Pool } = require('pg');
const pool = new Pool({
    host: '127.0.0.1',
    port: 5433,
    database: 'devdb',
    user: 'postgres',
    password: 'SecurePostgres2024!'
});
```

```java
// Java (JDBC)
String url = "jdbc:postgresql://127.0.0.1:5433/devdb";
String user = "postgres";
String password = "SecurePostgres2024!";
Connection conn = DriverManager.getConnection(url, user, password);
```

---

### MariaDB/MySQL Database
**Connection Details:**
- **Host**: `127.0.0.1`
- **Port**: `3307`
- **Database**: `devdb`
- **Username**: `root`
- **Password**: `SecureMySQL2024!`

**Connection Strings:**
```bash
# Command Line
mysql -h 127.0.0.1 -P 3307 -u root -p devdb

# MySQL URI
mysql://root:SecureMySQL2024!@127.0.0.1:3307/devdb
```

**Application Examples:**
```python
# Python (PyMySQL)
import pymysql
connection = pymysql.connect(
    host='127.0.0.1',
    port=3307,
    user='root',
    password='SecureMySQL2024!',
    database='devdb'
)
```

```javascript
// Node.js (mysql2)
const mysql = require('mysql2');
const connection = mysql.createConnection({
    host: '127.0.0.1',
    port: 3307,
    user: 'root',
    password: 'SecureMySQL2024!',
    database: 'devdb'
});
```

---

### MongoDB Database
**Connection Details:**
- **Host**: `127.0.0.1`
- **Port**: `27018`
- **Database**: `devdb`
- **Username**: `admin`
- **Password**: `SecureMongo2024!`

**Connection Strings:**
```bash
# Command Line
mongo mongodb://admin:SecureMongo2024!@127.0.0.1:27018/devdb

# MongoDB URI
mongodb://admin:SecureMongo2024!@127.0.0.1:27018/devdb
```

**Application Examples:**
```python
# Python (PyMongo)
from pymongo import MongoClient
client = MongoClient('mongodb://admin:SecureMongo2024!@127.0.0.1:27018/devdb')
db = client.devdb
```

```javascript
// Node.js (mongodb)
const { MongoClient } = require('mongodb');
const uri = "mongodb://admin:SecureMongo2024!@127.0.0.1:27018/devdb";
const client = new MongoClient(uri);
```

```java
// Java (MongoDB Driver)
String uri = "mongodb://admin:SecureMongo2024!@127.0.0.1:27018/devdb";
MongoClient mongoClient = MongoClients.create(uri);
```

---

### Redis Cache/Database
**Connection Details:**
- **Host**: `127.0.0.1`
- **Port**: `6380`
- **Password**: `SecureRedis2024!`
- **Database**: `0` (default)

**Connection Strings:**
```bash
# Command Line
redis-cli -h 127.0.0.1 -p 6380 -a SecureRedis2024!

# Redis URI
redis://:SecureRedis2024!@127.0.0.1:6380/0
```

**Application Examples:**
```python
# Python (redis-py)
import redis
r = redis.Redis(
    host='127.0.0.1',
    port=6380,
    password='SecureRedis2024!',
    db=0
)
```

```javascript
// Node.js (redis)
const redis = require('redis');
const client = redis.createClient({
    host: '127.0.0.1',
    port: 6380,
    password: 'SecureRedis2024!'
});
```

---

## 🌐 Web Management Interfaces

### Adminer - Database Management
- **URL**: http://127.0.0.1:8080
- **Purpose**: Universal database management interface
- **Login**: Use database credentials

**Access Instructions:**
1. Open browser to http://127.0.0.1:8080
2. Select database system (PostgreSQL, MySQL, etc.)
3. Enter database connection details
4. Use credentials from database section above

**Features:**
- SQL query execution
- Table management
- Data import/export
- Database schema visualization

---

### Mongo Express - MongoDB Management
- **URL**: http://127.0.0.1:8082
- **Purpose**: MongoDB web-based admin interface
- **Login**: admin / admin

**Access Instructions:**
1. Open browser to http://127.0.0.1:8082
2. Login with admin/admin
3. Browse databases and collections
4. Execute MongoDB queries

---

### Redis Commander - Redis Management
- **URL**: http://127.0.0.1:8083
- **Purpose**: Redis key-value store management
- **Login**: admin / admin

**Features:**
- Key browsing and editing
- Redis CLI interface
- Memory usage monitoring
- Key pattern search

---

### Portainer - Docker Management
- **URL**: http://127.0.0.1:9000
- **Purpose**: Complete Docker container management
- **Login**: Create admin account on first visit

**Setup Instructions:**
1. Open browser to http://127.0.0.1:9000
2. Create admin username and password
3. Select "Docker" environment
4. Use local Docker socket

**Features:**
- Container start/stop/restart
- Image management
- Volume and network management
- Container logs and statistics
- Container terminal access

---

### Grafana - Metrics and Monitoring
- **URL**: http://127.0.0.1:3000
- **Purpose**: System metrics and custom dashboards
- **Login**: admin / admin

**Initial Setup:**
1. Login with admin/admin
2. Change password when prompted
3. Add InfluxDB data source: http://influxdb:8086
4. Import pre-built dashboards

---

## 🔧 Container Direct Access

### Execute Commands in Containers
```bash
# PostgreSQL
docker exec -it postgres-db psql -U postgres -d devdb

# MariaDB
docker exec -it mariadb-db mysql -u root -p devdb

# MongoDB
docker exec -it mongodb-db mongo -u admin -p

# Redis
docker exec -it redis-db redis-cli -a SecureRedis2024!

# Get shell access to any container
docker exec -it [container_name] bash
# or
docker exec -it [container_name] sh
```

### View Container Logs
```bash
# Real-time logs
docker logs -f postgres-db
docker logs -f mariadb-db
docker logs -f mongodb-db
docker logs -f redis-db

# Last 100 lines
docker logs --tail 100 [container_name]
```

---

## 📊 Environment Configuration

### Current Port Mapping
| Service | Internal Port | External Port | Access URL |
|---------|---------------|---------------|------------|
| PostgreSQL | 5432 | 5433 | 127.0.0.1:5433 |
| MariaDB | 3306 | 3307 | 127.0.0.1:3307 |
| MongoDB | 27017 | 27018 | 127.0.0.1:27018 |
| Redis | 6379 | 6380 | 127.0.0.1:6380 |
| Adminer | 8080 | 8080 | http://127.0.0.1:8080 |
| Mongo Express | 8081 | 8082 | http://127.0.0.1:8082 |
| Redis Commander | 8081 | 8083 | http://127.0.0.1:8083 |
| Portainer | 9000 | 9000 | http://127.0.0.1:9000 |
| Grafana | 3000 | 3000 | http://127.0.0.1:3000 |

### Environment Variables (.env)
```bash
# View all environment variables
cat .env

# Key configuration variables:
POSTGRES_PASSWORD=SecurePostgres2024!
MYSQL_ROOT_PASSWORD=SecureMySQL2024!
MONGODB_ROOT_PASSWORD=SecureMongo2024!
REDIS_PASSWORD=SecureRedis2024!
DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=SecureDashboard2024!
```

---

## 🔐 Security Best Practices

### Change Default Passwords
```bash
# Edit .env file to change passwords
nano .env

# Restart services after password changes
./dev-workflow/dev-env-stop.sh
./dev-workflow/dev-env-start.sh
```

### Network Security
- All services bound to 127.0.0.1 (localhost only)
- No external network access by default
- Use strong passwords for production deployments
- Consider VPN for remote access instead of exposing ports

### Regular Maintenance
```bash
# Backup data regularly
./dev-workflow/backup-current-environment.sh

# Monitor system resources
./dev-workflow/dev-env-status.sh

# Update container images
docker pull postgres:15
docker pull mariadb:10.11
docker pull mongo:7
docker pull redis:7-alpine
```

---

## 🧪 Testing Connections

### Quick Connection Tests
```bash
# Test all database ports
nc -zv 127.0.0.1 5433    # PostgreSQL
nc -zv 127.0.0.1 3307    # MariaDB  
nc -zv 127.0.0.1 27018   # MongoDB
nc -zv 127.0.0.1 6380    # Redis

# Test web interfaces
curl -s http://127.0.0.1:8080 > /dev/null && echo "Adminer OK"
curl -s http://127.0.0.1:8082 > /dev/null && echo "Mongo Express OK"
curl -s http://127.0.0.1:9000 > /dev/null && echo "Portainer OK"
```

### Database Connection Tests
```bash
# Test database connections
docker exec postgres-db pg_isready -U postgres
docker exec mariadb-db mysqladmin ping -u root -p
docker exec mongodb-db mongo --eval "db.runCommand({ping: 1})"
docker exec redis-db redis-cli -a SecureRedis2024! ping
```

---

## 📱 Application Integration Examples

### Environment Variables for Applications
```bash
# .env file for your applications
DATABASE_URL=postgresql://postgres:SecurePostgres2024!@127.0.0.1:5433/devdb
MYSQL_URL=mysql://root:SecureMySQL2024!@127.0.0.1:3307/devdb
MONGODB_URL=mongodb://admin:SecureMongo2024!@127.0.0.1:27018/devdb
REDIS_URL=redis://:SecureRedis2024!@127.0.0.1:6380/0
```

### Docker Compose Integration
```yaml
version: '3.8'
services:
  your-app:
    build: .
    environment:
      - DATABASE_URL=postgresql://postgres:SecurePostgres2024!@host.docker.internal:5433/devdb
      - REDIS_URL=redis://:SecureRedis2024!@host.docker.internal:6380/0
    networks:
      - dev-network

networks:
  dev-network:
    external: true
```

---

**🎯 All services are now documented and accessible. Use this reference for 100% successful connections!**