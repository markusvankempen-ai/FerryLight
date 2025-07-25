# PostgreSQL Access Guide - FerryLightV2

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

This guide provides comprehensive instructions for accessing and managing the PostgreSQL database in your FerryLightV2 system.

## 🔍 **PostgreSQL Access Methods**

### **1. 🖥️ pgAdmin Web Interface (Recommended)**

**URL:** `https://pgadmin.ferrylight.online`

**Login Credentials:**
- **Email:** `admin@ferrylight.online`
- **Password:** `ferrylight2024`

**Steps:**
1. Open your browser
2. Go to `https://pgadmin.ferrylight.online`
3. Login with the credentials above
4. Add PostgreSQL server connection:
   - **Host:** `postgres` (Docker service name)
   - **Port:** `5432`
   - **Database:** `ferrylight`
   - **Username:** `ferrylight`
   - **Password:** `ferrylight@Connexts@99`

### **2. 🖥️ Command Line via Docker**

**Connect directly to PostgreSQL container:**
```bash
# Navigate to project directory
cd /opt/ferrylightv2

# Connect to PostgreSQL
docker exec -it postgres psql -U ferrylight -d ferrylight
```

**Run SQL commands:**
```bash
# List all tables
docker exec postgres psql -U ferrylight -d ferrylight -c '\dt'

# Query sample data
docker exec postgres psql -U ferrylight -d ferrylight -c 'SELECT * FROM traffic_events ORDER BY timestamp DESC LIMIT 5;'

# Check database size
docker exec postgres psql -U ferrylight -d ferrylight -c 'SELECT pg_size_pretty(pg_database_size("ferrylight"));'
```

### **3. 🖥️ External Client Connection**

**From another machine/container:**
```bash
# Connect from another container
docker run --rm -it --network traefik-public postgres:15-alpine psql -h postgres -U ferrylight -d ferrylight
```

**Connection Details:**
- **Host:** `postgres` (internal Docker network)
- **Port:** `5432`
- **Database:** `ferrylight`
- **Username:** `ferrylight`
- **Password:** `ferrylight@Connexts@99`

### **4. 🖥️ Using the Test Script**

**Run the built-in test script:**
```bash
# Navigate to project directory
cd /opt/ferrylightv2

# Run PostgreSQL test script
./test_postgres.sh
```

This script will show you:
- Connection details
- Quick test commands
- pgAdmin access information

### **5. 🔧 Management Commands**

**Check PostgreSQL status:**
```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# View PostgreSQL logs
docker-compose logs postgres

# Restart PostgreSQL
docker-compose restart postgres
```

## 📊 **Database Information**

### **Default Database:**
- **Name:** `ferrylight`
- **Owner:** `ferrylight`
- **Encoding:** UTF8
- **Collation:** en_US.utf8
- **Ctype:** en_US.utf8

### **Sample Tables (Created by init script):**
- `traffic_events` - Traffic light event data
- `mqtt_messages` - MQTT message logs

### **Sample Queries:**
```sql
-- List all tables
\dt

-- View table structure
\d traffic_events

-- Query recent traffic events
SELECT * FROM traffic_events ORDER BY timestamp DESC LIMIT 10;

-- Count total events
SELECT COUNT(*) FROM traffic_events;

-- Check database size
SELECT pg_size_pretty(pg_database_size('ferrylight'));
```

## 🔐 **Security Notes**

### **Internal Access Only:**
- PostgreSQL is **NOT** exposed to the internet
- Only accessible within the Docker network
- Secure authentication required
- SSL/TLS encryption available

### **Connection String:**
```
postgresql://ferrylight:ferrylight@Connexts@99@postgres:5432/ferrylight
```

## 🚨 **Troubleshooting**

### **If PostgreSQL is not accessible:**

1. **Check if container is running:**
   ```bash
   docker-compose ps postgres
   ```

2. **Check logs:**
   ```bash
   docker-compose logs postgres
   ```

3. **Restart PostgreSQL:**
   ```bash
   docker-compose restart postgres
   ```

4. **Check network connectivity:**
   ```bash
   docker exec postgres pg_isready -U ferrylight -d ferrylight
   ```

## 📱 **Quick Access Summary**

**For Web Interface:**
- **URL:** `https://pgadmin.ferrylight.online`
- **Email:** `admin@ferrylight.online`
- **Password:** `ferrylight2024`

**For Command Line:**
```bash
cd /opt/ferrylightv2
docker exec -it postgres psql -U ferrylight -d ferrylight
```

**For Testing:**
```bash
cd /opt/ferrylightv2
./test_postgres.sh
```

## 🔧 **Database Management**

### **Backup Database:**
```bash
# Create backup
docker exec postgres pg_dump -U ferrylight ferrylight > backup_$(date +%Y%m%d_%H%M%S).sql

# Create compressed backup
docker exec postgres pg_dump -U ferrylight ferrylight | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

### **Restore Database:**
```bash
# Restore from backup
docker exec -i postgres psql -U ferrylight ferrylight < backup_file.sql

# Restore from compressed backup
gunzip -c backup_file.sql.gz | docker exec -i postgres psql -U ferrylight ferrylight
```

### **Create New Database:**
```bash
# Create new database
docker exec postgres createdb -U ferrylight new_database_name

# Create new user
docker exec postgres createuser -U ferrylight new_username
```

### **Database Maintenance:**
```bash
# Vacuum database
docker exec postgres psql -U ferrylight -d ferrylight -c 'VACUUM;'

# Analyze database
docker exec postgres psql -U ferrylight -d ferrylight -c 'ANALYZE;'

# Reindex database
docker exec postgres psql -U ferrylight -d ferrylight -c 'REINDEX DATABASE ferrylight;'
```

## 📊 **Monitoring and Statistics**

### **Database Statistics:**
```bash
# Check database size
docker exec postgres psql -U ferrylight -d ferrylight -c 'SELECT pg_size_pretty(pg_database_size("ferrylight"));'

# Check table sizes
docker exec postgres psql -U ferrylight -d ferrylight -c 'SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||"."||tablename)) AS size FROM pg_tables WHERE schemaname = "public" ORDER BY pg_total_relation_size(schemaname||"."||tablename) DESC;'

# Check active connections
docker exec postgres psql -U ferrylight -d ferrylight -c 'SELECT count(*) FROM pg_stat_activity;'
```

### **Performance Monitoring:**
```bash
# Check slow queries
docker exec postgres psql -U ferrylight -d ferrylight -c 'SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;'

# Check index usage
docker exec postgres psql -U ferrylight -d ferrylight -c 'SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch FROM pg_stat_user_indexes ORDER BY idx_scan DESC;'
```

## 🔒 **Security Best Practices**

### **Password Management:**
```bash
# Change user password
docker exec postgres psql -U ferrylight -d ferrylight -c "ALTER USER ferrylight PASSWORD 'new_secure_password';"

# Create read-only user
docker exec postgres psql -U ferrylight -d ferrylight -c "CREATE USER readonly WITH PASSWORD 'readonly_password';"
docker exec postgres psql -U ferrylight -d ferrylight -c "GRANT CONNECT ON DATABASE ferrylight TO readonly;"
docker exec postgres psql -U ferrylight -d ferrylight -c "GRANT USAGE ON SCHEMA public TO readonly;"
docker exec postgres psql -U ferrylight -d ferrylight -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;"
```

### **SSL Configuration:**
```bash
# Check SSL status
docker exec postgres psql -U ferrylight -d ferrylight -c 'SHOW ssl;'

# Check SSL certificates
docker exec postgres psql -U ferrylight -d ferrylight -c 'SHOW ssl_cert_file;'
```

## 📋 **Common Commands Reference**

### **PostgreSQL Commands:**
```sql
-- Connect to database
\c ferrylight

-- List databases
\l

-- List tables
\dt

-- Describe table
\d table_name

-- List users
\du

-- Show current user
SELECT current_user;

-- Show current database
SELECT current_database();

-- Show version
SELECT version();

-- Exit PostgreSQL
\q
```

### **Docker Commands:**
```bash
# Start PostgreSQL
docker-compose up -d postgres

# Stop PostgreSQL
docker-compose stop postgres

# Restart PostgreSQL
docker-compose restart postgres

# View logs
docker-compose logs postgres

# Execute command in container
docker exec postgres command

# Access container shell
docker exec -it postgres bash
```

## 🎯 **Quick Start Checklist**

- [ ] **pgAdmin Web Interface:** `https://pgadmin.ferrylight.online`
- [ ] **Command Line Access:** `docker exec -it postgres psql -U ferrylight -d ferrylight`
- [ ] **Test Script:** `./test_postgres.sh`
- [ ] **Check Status:** `docker-compose ps postgres`
- [ ] **View Logs:** `docker-compose logs postgres`
- [ ] **Backup Database:** `docker exec postgres pg_dump -U ferrylight ferrylight > backup.sql`

## 📞 **Support**

For additional help:
- **PostgreSQL Documentation:** https://www.postgresql.org/docs/
- **pgAdmin Documentation:** https://www.pgadmin.org/docs/
- **Docker PostgreSQL:** https://hub.docker.com/_/postgres

---

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 