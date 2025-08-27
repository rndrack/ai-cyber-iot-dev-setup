#!/bin/bash
# Backup Current Environment State
# For WSL2 Root User Environment

echo "🔄 Backing up current environment state..."

# Create backup directory with timestamp
BACKUP_DIR="backups/env-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"/{docker,root-config,containers,data}

# Backup root user configurations
echo "📝 Backing up root configurations..."
cp /root/.bashrc "$BACKUP_DIR/root-config/" 2>/dev/null || echo "No .bashrc found"
cp /root/.profile "$BACKUP_DIR/root-config/" 2>/dev/null || echo "No .profile found"
cp /root/.docker/config.json "$BACKUP_DIR/root-config/" 2>/dev/null || echo "No Docker config found"

# Check if Docker is working
echo "🐳 Checking Docker status..."
if command -v docker &> /dev/null; then
    echo "Docker CLI found - checking functionality..."
    
    # Test Docker without causing segfault
    timeout 10s docker --version > "$BACKUP_DIR/docker/docker-version.txt" 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Docker CLI working"
        
        # Backup Docker state
        docker ps -a > "$BACKUP_DIR/docker/containers.txt" 2>/dev/null || echo "Could not list containers"
        docker images > "$BACKUP_DIR/docker/images.txt" 2>/dev/null || echo "Could not list images"
        docker network ls > "$BACKUP_DIR/docker/networks.txt" 2>/dev/null || echo "Could not list networks"
        docker volume ls > "$BACKUP_DIR/docker/volumes.txt" 2>/dev/null || echo "Could not list volumes"
        
        # Export container data if containers exist
        echo "💾 Checking for existing containers to backup..."
        for container in postgres-db mariadb-db mongodb-db redis-db; do
            if docker ps -a --filter "name=$container" --format "{{.Names}}" | grep -q "$container"; then
                echo "Found container: $container - creating backup..."
                case $container in
                    postgres-db)
                        docker exec $container pg_dumpall -U postgres > "$BACKUP_DIR/data/${container}.sql" 2>/dev/null || echo "Could not backup $container"
                        ;;
                    mariadb-db)
                        docker exec $container mysqldump --all-databases -uroot -proot > "$BACKUP_DIR/data/${container}.sql" 2>/dev/null || echo "Could not backup $container"
                        ;;
                    mongodb-db)
                        docker exec $container mongodump --archive > "$BACKUP_DIR/data/${container}.archive" 2>/dev/null || echo "Could not backup $container"
                        ;;
                    redis-db)
                        docker exec $container redis-cli BGSAVE > "$BACKUP_DIR/data/${container}.rdb" 2>/dev/null || echo "Could not backup $container"
                        ;;
                esac
            else
                echo "Container $container not found - skipping backup"
            fi
        done
    else
        echo "❌ Docker CLI segmentation fault detected!"
        echo "Docker segfault detected at $(date)" > "$BACKUP_DIR/docker/segfault-detected.txt"
    fi
else
    echo "⚠️ Docker not installed or not in PATH"
fi

# Backup conda environment if exists
if [ -d "/root/miniconda" ]; then
    echo "🐍 Backing up conda environment..."
    /root/miniconda/bin/conda env list > "$BACKUP_DIR/root-config/conda-envs.txt" 2>/dev/null || echo "Could not list conda envs"
    if /root/miniconda/bin/conda env list | grep -q "ai-dev"; then
        /root/miniconda/bin/conda env export -n ai-dev > "$BACKUP_DIR/root-config/ai-dev-environment.yml" 2>/dev/null || echo "Could not export ai-dev environment"
    fi
fi

# System information
echo "💻 Gathering system information..."
echo "Backup created: $(date)" > "$BACKUP_DIR/backup-info.txt"
echo "System: $(uname -a)" >> "$BACKUP_DIR/backup-info.txt"
echo "WSL Version: $(wsl --version 2>/dev/null || echo 'WSL version not available')" >> "$BACKUP_DIR/backup-info.txt"
echo "Memory: $(free -h)" >> "$BACKUP_DIR/backup-info.txt"
echo "Disk: $(df -h)" >> "$BACKUP_DIR/backup-info.txt"
echo "User: $(whoami)" >> "$BACKUP_DIR/backup-info.txt"

# Create restoration instructions
cat > "$BACKUP_DIR/RESTORE-INSTRUCTIONS.md" << 'EOF'
# Environment Restoration Instructions

## To Restore This Backup:

1. **Restore Root Configurations:**
   ```bash
   cp root-config/.bashrc /root/ 2>/dev/null
   cp root-config/.profile /root/ 2>/dev/null
   source /root/.bashrc
   ```

2. **Restore Docker State (if Docker was working):**
   ```bash
   # Import container data after recreating containers
   # See data/ folder for database backups
   ```

3. **Restore Conda Environment:**
   ```bash
   conda env create -f root-config/ai-dev-environment.yml
   ```

4. **Restore Container Data:**
   - PostgreSQL: `psql -U postgres < data/postgres-db.sql`
   - MariaDB: `mysql -uroot -proot < data/mariadb-db.sql`
   - MongoDB: `mongorestore --archive=data/mongodb-db.archive`

## Backup Information:
See backup-info.txt for system details at time of backup.
EOF

echo "✅ Backup completed successfully!"
echo "📁 Backup location: $BACKUP_DIR"
echo "📖 Restoration instructions: $BACKUP_DIR/RESTORE-INSTRUCTIONS.md"