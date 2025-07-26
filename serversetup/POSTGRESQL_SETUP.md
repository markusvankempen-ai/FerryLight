# PostgreSQL & pgAdmin Setup Guide

This guide provides manual steps to add PostgreSQL and pgAdmin to your FerryLightV2 environment.

## 🐘 PostgreSQL Configuration

### 1. Create PostgreSQL Directories

```bash
# Create PostgreSQL data directories
mkdir -p /opt/ferrylightv2/postgres/data
mkdir -p /opt/ferrylightv2/postgres/init
mkdir -p /opt/ferrylightv2/pgadmin

# Set proper permissions
sudo chown -R $USER:$USER /opt/ferrylightv2/postgres
sudo chown -R $USER:$USER /opt/ferrylightv2/pgadmin
```

### 2. Create PostgreSQL Initialization Script (Optional)

```bash
# Create a sample initialization script
cat > /opt/ferrylightv2/postgres/init/01-init.sql << 'EOF'
-- FerryLightV2 Database Initialization
-- This script runs when PostgreSQL starts for the first time

-- Create additional databases if needed
-- CREATE DATABASE ferrylight_app;

-- Create additional users if needed
-- CREATE USER app_user WITH PASSWORD 'app_password';

-- Grant permissions
-- GRANT ALL PRIVILEGES ON DATABASE ferrylight_app TO app_user;

-- Create sample tables for traffic light data
CREATE TABLE IF NOT EXISTS traffic_events (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_type VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    status VARCHAR(20),
    data JSONB
);

CREATE TABLE IF NOT EXISTS mqtt_messages (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    topic VARCHAR(200) NOT NULL,
    message TEXT,
    client_id VARCHAR(100)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_traffic_events_timestamp ON traffic_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_mqtt_messages_timestamp ON mqtt_messages(timestamp);
CREATE INDEX IF NOT EXISTS idx_mqtt_messages_topic ON mqtt_messages(topic);

-- Insert sample data
INSERT INTO traffic_events (event_type, location, status, data) VALUES
('LIGHT_CHANGE', 'Main Intersection', 'GREEN', '{"duration": 30, "sensor_data": {"vehicle_count": 5}}'),
('SENSOR_TRIGGER', 'Side Street', 'YELLOW', '{"pedestrian_detected": true}'),
('SYSTEM_STATUS', 'All Lights', 'OPERATIONAL', '{"uptime": 86400, "errors": 0}');

EOF
```

### 3. Add PostgreSQL Service to Docker Compose

Add these services to your `docker-compose.yml`:

```yaml
  postgres:
    image: postgres:15-alpine
    container_name: postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: \${POSTGRES_DB:-ferrylight}
      POSTGRES_USER: \${POSTGRES_USER:-ferrylight}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD:-your-secure-password}
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - ./postgres/data:/var/lib/postgresql/data
      - ./postgres/init:/docker-entrypoint-initdb.d
    networks:
      - traefik-public
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${POSTGRES_USER:-ferrylight} -d \${POSTGRES_DB:-ferrylight}"]
      interval: 30s
      timeout: 10s
      retries: 3

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: pgadmin
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: \${PGADMIN_EMAIL:-admin@your-domain.com}
      PGADMIN_DEFAULT_PASSWORD: \${PGADMIN_PASSWORD:-your-secure-password}
      PGADMIN_CONFIG_SERVER_MODE: 'False'
      PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: 'False'
    volumes:
      - ./pgadmin:/var/lib/pgadmin
    networks:
      - traefik-public
    depends_on:
      - postgres
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.pgadmin.rule=Host(`pgadmin.[your-domain]`)"
      - "traefik.http.routers.pgadmin.entrypoints=websecure"
      - "traefik.http.routers.pgadmin.tls.certresolver=letsencrypt"
      - "traefik.http.services.pgadmin.loadbalancer.server.port=80"
```

### 4. Start PostgreSQL Services

```bash
# Navigate to project directory
cd /opt/ferrylightv2

# Start PostgreSQL and pgAdmin
docker-compose up -d postgres pgadmin

# Check service status
docker-compose ps postgres pgadmin

# View logs
docker-compose logs postgres
docker-compose logs pgadmin
```

## 📊 pgAdmin Configuration

### 1. Access pgAdmin

1. **Open your browser** and go to: `https://pgadmin.[your-domain]`
2. **Login with:**
   - Email: `[your-pgadmin-email]`
   - Password: `[your-pgadmin-password]`

### 2. Add PostgreSQL Server

1. **Right-click on "Servers"** → **"Register"** → **"Server..."**
2. **General Tab:**
   - Name: `FerryLightV2 PostgreSQL`
3. **Connection Tab:**
   - Host: `postgres` (Docker service name)
   - Port: `5432`
   - Database: `[your-database-name]`
   - Username: `[your-database-user]`
   - Password: `[your-database-password]`
4. **Click "Save"**

### 3. Test Connection

1. **Expand the server** in the left panel
2. **Expand "Databases"** → **"ferrylight"**
3. **Expand "Schemas"** → **"public"** → **"Tables"**
4. **You should see the sample tables** created by the init script

## 🔧 Database Management

### 1. Connect via Command Line

```bash
# Connect to PostgreSQL from host
docker exec -it postgres psql -U \${POSTGRES_USER:-ferrylight} -d \${POSTGRES_DB:-ferrylight}

# Or connect from another container
docker run --rm -it --network traefik-public postgres:15-alpine psql -h postgres -U \${POSTGRES_USER:-ferrylight} -d \${POSTGRES_DB:-ferrylight}
```

### 2. Basic PostgreSQL Commands

```sql
-- List all tables
\dt

-- Show table structure
\d traffic_events

-- Query sample data
SELECT * FROM traffic_events ORDER BY timestamp DESC LIMIT 10;

-- Create a new table
CREATE TABLE sensor_data (
    id SERIAL PRIMARY KEY,
    sensor_id VARCHAR(50),
    value DECIMAL(10,2),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exit PostgreSQL
\q
```

### 3. Backup and Restore

```bash
# Create backup
docker exec postgres pg_dump -U ferrylight ferrylight > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore from backup
docker exec -i postgres psql -U ferrylight ferrylight < backup_file.sql
```

## 🔗 Integration with Node-RED

### 1. Install PostgreSQL Node

1. **Open Node-RED:** `https://nodered.[your-domain]`
2. **Go to Manage Palette** → **Install**
3. **Search for:** `node-red-contrib-postgresql`
4. **Install the package**

### 2. Configure PostgreSQL Node

1. **Add a PostgreSQL node** to your flow
2. **Configure connection:**
   - Host: `postgres`
   - Port: `5432`
   - Database: `[your-database-name]`
   - Username: `[your-database-user]`
   - Password: `[your-database-password]`
3. **Test the connection**

### 3. Sample Node-RED Flow

```json
{
  "id": "postgres-example",
  "type": "tab",
  "label": "PostgreSQL Example",
  "nodes": [
    {
      "id": "inject",
      "type": "inject",
      "name": "Insert Data",
      "props": {
        "payload": {
          "event_type": "TEST_EVENT",
          "location": "Test Location",
          "status": "ACTIVE",
          "data": {"test": true}
        }
      }
    },
    {
      "id": "postgres",
      "type": "postgresql",
      "name": "Insert Event",
      "query": "INSERT INTO traffic_events (event_type, location, status, data) VALUES ($1, $2, $3, $4)",
      "params": ["{{payload.event_type}}", "{{payload.location}}", "{{payload.status}}", "{{JSON.stringify(payload.data)}}"]
    }
  ]
}
```

## 🔒 Security Considerations

### 1. Change Default Passwords

```bash
# Change PostgreSQL password
docker exec -it postgres psql -U ferrylight -d ferrylight -c "ALTER USER ferrylight PASSWORD 'new_secure_password';"

# Change pgAdmin password
# Go to pgAdmin → File → Change Password
```

### 2. Network Security

- PostgreSQL is only accessible within the Docker network
- pgAdmin is exposed via HTTPS with SSL certificates
- Consider using environment variables for sensitive data

### 3. Backup Strategy

```bash
# Create automated backup script
cat > /opt/ferrylightv2/backup_postgres.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/ferrylightv2/backups/postgres"

mkdir -p $BACKUP_DIR

# Create backup
docker exec postgres pg_dump -U ferrylight ferrylight > $BACKUP_DIR/ferrylight_$DATE.sql

# Compress backup
gzip $BACKUP_DIR/ferrylight_$DATE.sql

# Keep only last 7 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "PostgreSQL backup completed: $BACKUP_DIR/ferrylight_$DATE.sql.gz"
EOF

chmod +x /opt/ferrylightv2/backup_postgres.sh
```

## 📊 Monitoring

### 1. Check PostgreSQL Status

```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# Check PostgreSQL logs
docker-compose logs postgres

# Check database size
docker exec postgres psql -U ferrylight -d ferrylight -c "SELECT pg_size_pretty(pg_database_size('ferrylight'));"
```

### 2. Performance Monitoring

```sql
-- Check active connections
SELECT count(*) FROM pg_stat_activity;

-- Check slow queries
SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;

-- Check table sizes
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size 
FROM pg_tables WHERE schemaname = 'public' ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

## 🚀 Next Steps

1. **Test the connection** from pgAdmin
2. **Create your application tables** based on your needs
3. **Integrate with Node-RED** for data collection
4. **Set up automated backups**
5. **Monitor performance** and adjust as needed

---

**Created by:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com  
**Project:** FerryLightV2 