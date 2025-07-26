# FerryLightV2 Complete Deployment Guide

**Author:** Markus van Kempen - markus.van.kempen@gmail.com  
**Date:** 24-July-2025  
**Version:** 2.0  
**Compatible:** Ubuntu 22.04 LTS  

## 🚀 Quick Start

### Prerequisites
- Ubuntu 22.04 LTS server
- SSH access with sudo privileges
- Domain name ([your-domain])
- Server IP (209.209.43.250)

### One-Command Setup
```bash
# Download and run the complete setup script
wget https://raw.githubusercontent.com/your-repo/FerryLightV2/main/ferrylightv2_complete_setup.sh
chmod +x ferrylightv2_complete_setup.sh
./ferrylightv2_complete_setup.sh
```

## 📋 What Gets Installed

### Core Services
- **Docker & Docker Compose** - Container platform
- **Traefik** - Reverse proxy with automatic SSL
- **Portainer** - Docker management UI
- **Node-RED** - Visual programming for IoT
- **Mosquitto** - MQTT broker (open access)
- **Nginx** - Web server for static content

### Features
- ✅ Automatic SSL certificates (Let's Encrypt)
- ✅ HTTP to HTTPS redirects
- ✅ Auto-start on boot (systemd service)
- ✅ Backup and restore functionality
- ✅ Update management
- ✅ MQTT open access (no authentication)
- ✅ Node-RED with authentication
- ✅ Traefik with authentication
- ✅ Comprehensive logging and monitoring

## 🌐 Service URLs

| Service | URL | Description | Authentication |
|---------|-----|-------------|----------------|
| Main Website | https://[your-domain] | Server dashboard | None |
| Portainer | https://portainer.[your-domain] | Docker management | Create on first visit |
| Traefik | https://traefik.[your-domain] | Reverse proxy dashboard | admin:[your-password] |
| Node-RED | https://nodered.[your-domain] | Visual programming | admin:[your-password] |
| MQTT Broker | mqtt.[your-domain]:1883 | MQTT messaging | Anonymous (open) |

## 🔐 Default Credentials

| Service | Username | Password | Notes |
|---------|----------|----------|-------|
| Traefik Dashboard | admin | [your-password] | Basic auth |
| Node-RED | admin | [your-password] | Web interface |
| Portainer | - | - | Create on first visit |
| MQTT | - | - | Anonymous access (open) |

## 📁 Project Structure

```
/opt/ferrylightv2/
├── docker-compose.yml          # Main configuration
├── traefik/                    # Traefik configuration
│   ├── traefik.yml            # Main Traefik config
│   ├── config/                # Dynamic configuration
│   │   └── dynamic.yml        # Middlewares and auth
│   └── acme/                  # SSL certificates
├── portainer/                 # Portainer data
├── website/                   # Website files
│   └── index.html            # Dashboard
├── nodered/                   # Node-RED data
│   └── settings.js           # Node-RED config
├── mosquitto/                 # MQTT configuration
│   ├── config/
│   │   └── mosquitto.conf    # MQTT broker config (open access)
│   ├── data/                 # MQTT data
│   └── log/                  # MQTT logs
├── backups/                   # Backup directory
├── nginx.conf                 # Nginx configuration
├── update.sh                  # Update script
├── backup.sh                  # Backup script
├── configure_mqtt.sh          # MQTT configuration
└── README.md                  # Documentation
```

## 🔧 Management Commands

### Service Management
```bash
cd /opt/ferrylightv2

# Check service status
docker-compose ps

# View logs
docker-compose logs
docker-compose logs [service-name]

# Restart services
docker-compose restart
docker-compose restart [service-name]

# Stop all services
docker-compose down

# Start all services
docker-compose up -d
```

### System Service Management
```bash
# Check systemd service status
sudo systemctl status ferrylightv2

# Start/stop systemd service
sudo systemctl start ferrylightv2
sudo systemctl stop ferrylightv2

# Enable/disable auto-start
sudo systemctl enable ferrylightv2
sudo systemctl disable ferrylightv2
```

### Update and Maintenance
```bash
cd /opt/ferrylightv2

# Update all services
./update.sh

# Create backup
./backup.sh

# Configure MQTT authentication (optional)
./configure_mqtt.sh
```

## 📋 DNS Configuration

### Required DNS Records
Add these A records in your DNS provider:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 209.209.43.250 | 300 |
| A | www | 209.209.43.250 | 300 |
| A | portainer | 209.209.43.250 | 300 |
| A | traefik | 209.209.43.250 | 300 |
| A | nodered | 209.209.43.250 | 300 |
| A | mqtt | 209.209.43.250 | 300 |

### Namecheap DNS Setup
1. Log into Namecheap account
2. Go to Domain List → Manage for [your-domain]
3. Click on "Advanced DNS"
4. Remove any existing CNAME records for these subdomains
5. Add the A records above
6. Set TTL to "Automatic" or "300"
7. Save changes

### DNS Testing
```bash
# Test DNS resolution
nslookup [your-domain]
nslookup www.[your-domain]
nslookup portainer.[your-domain]
nslookup traefik.[your-domain]
nslookup nodered.[your-domain]
nslookup mqtt.[your-domain]
```

## 🔒 SSL Certificate Management

### Automatic SSL
- SSL certificates are automatically generated by Let's Encrypt
- Certificates are stored in `/opt/ferrylightv2/traefik/acme/`
- Automatic renewal is enabled
- HTTP to HTTPS redirect is configured

### Manual SSL Troubleshooting
```bash
# Check certificate status
ls -la /opt/ferrylightv2/traefik/acme/

# Clear certificates (force regeneration)
sudo rm -f /opt/ferrylightv2/traefik/acme/acme.json
docker-compose restart traefik

# Check Traefik logs for SSL issues
docker-compose logs traefik | grep -i ssl
docker-compose logs traefik | grep -i certificate
```

## 🔌 MQTT Configuration

### Default Configuration (Open Access)
- **Broker**: mqtt.[your-domain]
- **Port**: 1883 (TCP) / 9001 (WebSocket)
- **Authentication**: Anonymous (open access)
- **External Access**: Enabled
- **Listener**: 0.0.0.0 (accessible from anywhere)

### MQTT Configuration File
```bash
# /opt/ferrylightv2/mosquitto/config/mosquitto.conf
listener 1883 0.0.0.0          # External TCP access
allow_anonymous true            # No authentication required
listener 9001 0.0.0.0          # External WebSocket access
protocol websockets
allow_anonymous true
```

### MQTT Testing
```bash
# Test MQTT connection (install mosquitto-clients first)
sudo apt install mosquitto-clients

# Subscribe to test topic
mosquitto_sub -h mqtt.[your-domain] -t test/topic

# Publish to test topic
mosquitto_pub -h mqtt.[your-domain] -t test/topic -m "Hello MQTT"

# Test WebSocket connection
mosquitto_sub -h mqtt.[your-domain] -p 9001 -t test/topic
```

### Optional MQTT Authentication
```bash
cd /opt/ferrylightv2
./configure_mqtt.sh

# Options:
# 1. Anonymous access (default - open)
# 2. Username/password authentication
# 3. Advanced ACL configuration
```

## 🔴 Node-RED Configuration

### Authentication
- **Username**: admin
- **Password**: [your-password]
- **Access**: https://nodered.[your-domain]

### Configuration File
```bash
# /opt/ferrylightv2/nodered/settings.js
adminAuth: {
    type: "credentials",
    users: [{
        username: "admin",
        password: "bcrypt-hash",
        permissions: "*"
    }]
}
```

### Node-RED Features
- Visual programming interface
- MQTT integration (connects to local mosquitto broker)
- HTTP endpoints
- Dashboard capabilities
- Flow management

## 🔧 Traefik Configuration

### Authentication
- **Username**: admin
- **Password**: [your-password]
- **Access**: https://traefik.[your-domain]

### Features
- Automatic SSL certificate generation
- HTTP to HTTPS redirects
- Load balancing
- Request routing
- Middleware support

## 🐛 Troubleshooting

### Common Issues

#### 1. 404 Errors
**Symptoms**: Website returns 404, but containers are running
**Solutions**:
```bash
# Check Traefik routing
docker-compose logs traefik

# Verify DNS resolution
nslookup [your-domain]

# Check container connectivity
docker-compose exec website curl -I http://localhost

# Restart Traefik
docker-compose restart traefik
```

#### 2. SSL Certificate Errors
**Symptoms**: SSL certificate errors, HTTPS not working
**Solutions**:
```bash
# Clear SSL certificates
sudo rm -f /opt/ferrylightv2/traefik/acme/acme.json

# Restart Traefik
docker-compose restart traefik

# Wait 5-10 minutes for certificate generation
# Check Traefik logs for certificate status
docker-compose logs traefik | grep -i acme
```

#### 3. Docker Permission Issues
**Symptoms**: "permission denied while trying to connect to the Docker daemon"
**Solutions**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Or log out and log back in
# Then restart Docker service
sudo systemctl restart docker
```

#### 4. Container Restart Loops
**Symptoms**: Containers keep restarting
**Solutions**:
```bash
# Check container logs
docker-compose logs [container-name]

# Check resource usage
docker stats

# Restart with fresh state
docker-compose down
docker-compose up -d

# Check for port conflicts
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443
```

#### 5. Network Issues
**Symptoms**: Containers can't communicate
**Solutions**:
```bash
# Check Docker networks
docker network ls

# Recreate networks
docker network rm traefik-public web
docker network create traefik-public
docker network create web

# Restart services
docker-compose down
docker-compose up -d
```

### Diagnostic Commands

#### System Health Check
```bash
# Check all services
docker-compose ps

# Check system resources
df -h
free -h
top

# Check Docker status
docker info
docker system df

# Check firewall
sudo ufw status
```

#### Log Analysis
```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs traefik
docker-compose logs website
docker-compose logs portainer
docker-compose logs nodered
docker-compose logs mosquitto

# Follow logs in real-time
docker-compose logs -f traefik

# Check system logs
sudo journalctl -u docker
sudo journalctl -u ferrylightv2
```

#### Network Diagnostics
```bash
# Test internal connectivity
docker-compose exec website ping portainer
docker-compose exec website ping traefik

# Test external connectivity
curl -I http://[your-domain]
curl -I https://[your-domain]

# Check DNS resolution
dig [your-domain]
nslookup [your-domain]

# Test MQTT connectivity
mosquitto_pub -h mqtt.[your-domain] -t test -m "test"
```

## 🔄 Backup and Restore

### Creating Backups
```bash
cd /opt/ferrylightv2

# Automatic backup
./backup.sh

# Manual backup
BACKUP_DIR="/opt/ferrylightv2/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup Portainer data
docker run --rm -v portainer_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/portainer_$DATE.tar.gz -C /data .

# Backup Traefik certificates
tar czf $BACKUP_DIR/traefik_$DATE.tar.gz traefik/acme

# Backup Node-RED data
tar czf $BACKUP_DIR/nodered_$DATE.tar.gz nodered

# Backup MQTT data
tar czf $BACKUP_DIR/mosquitto_$DATE.tar.gz mosquitto
```

### Restoring from Backup
```bash
cd /opt/ferrylightv2

# Stop services
docker-compose down

# Restore Portainer data
docker run --rm -v portainer_data:/data -v /path/to/backup:/backup alpine tar xzf /backup/portainer_YYYYMMDD_HHMMSS.tar.gz -C /data

# Restore Traefik certificates
tar xzf /path/to/backup/traefik_YYYYMMDD_HHMMSS.tar.gz

# Restore Node-RED data
tar xzf /path/to/backup/nodered_YYYYMMDD_HHMMSS.tar.gz

# Restore MQTT data
tar xzf /path/to/backup/mosquitto_YYYYMMDD_HHMMSS.tar.gz

# Start services
docker-compose up -d
```

## 📊 Monitoring

### Traefik Dashboard
- **URL**: https://traefik.[your-domain]
- **Credentials**: admin:[your-password]
- **Features**: 
  - HTTP routers and services
  - SSL certificate status
  - Request logs
  - Middleware configuration

### Portainer Dashboard
- **URL**: https://portainer.[your-domain]
- **Features**:
  - Container management
  - Image management
  - Volume management
  - Network management

### Node-RED Dashboard
- **URL**: https://nodered.[your-domain]
- **Credentials**: admin:[your-password]
- **Features**:
  - Visual programming
  - Flow management
  - MQTT integration
  - Dashboard creation

### Log Monitoring
```bash
# Real-time log monitoring
docker-compose logs -f

# Log filtering
docker-compose logs traefik | grep ERROR
docker-compose logs website | grep 404
docker-compose logs mosquitto | grep connection

# Log rotation (add to crontab)
0 0 * * * find /opt/ferrylightv2/mosquitto/log -name "*.log" -mtime +7 -delete
```

## 🔧 Advanced Configuration

### Custom Nginx Configuration
Edit `/opt/ferrylightv2/nginx.conf` and restart the website container:
```bash
docker-compose restart website
```

### Custom Traefik Configuration
Edit `/opt/ferrylightv2/traefik/traefik.yml` and restart Traefik:
```bash
docker-compose restart traefik
```

### Custom MQTT Configuration
Edit `/opt/ferrylightv2/mosquitto/config/mosquitto.conf` and restart Mosquitto:
```bash
docker-compose restart mosquitto
```

### Custom Node-RED Configuration
Edit `/opt/ferrylightv2/nodered/settings.js` and restart Node-RED:
```bash
docker-compose restart nodered
```

### Environment Variables
Create `.env` file in `/opt/ferrylightv2/` for custom configurations:
```bash
# Example .env file
TZ=UTC
NODE_ENV=production
MQTT_USERNAME=your_username
MQTT_PASSWORD=your_password
```

## 🆘 Emergency Procedures

### Complete Reset
```bash
# Stop all services
cd /opt/ferrylightv2
docker-compose down -v

# Remove all data
sudo rm -rf /opt/ferrylightv2

# Re-run setup script
./ferrylightv2_complete_setup.sh
```

### Service Recovery
```bash
# Restart specific service
docker-compose restart [service-name]

# Recreate specific service
docker-compose up -d --force-recreate [service-name]

# Check service health
docker-compose ps
docker-compose logs [service-name]
```

### Network Recovery
```bash
# Recreate Docker networks
docker network rm traefik-public web
docker network create traefik-public
docker network create web

# Restart all services
docker-compose down
docker-compose up -d
```

## 📞 Support

### Getting Help
1. Check this documentation first
2. Review logs: `docker-compose logs`
3. Check service status: `docker-compose ps`
4. Verify DNS configuration
5. Check firewall settings

### Useful Commands for Support
```bash
# System information
uname -a
docker version
docker-compose version

# Service status
docker-compose ps
sudo systemctl status ferrylightv2

# Recent logs
docker-compose logs --tail=50

# Network connectivity
ping [your-domain]
curl -I https://[your-domain]

# Resource usage
docker stats
df -h
free -h

# MQTT connectivity
mosquitto_pub -h mqtt.[your-domain] -t test -m "test"
```

---

**Author:** Markus van Kempen - markus.van.kempen@gmail.com  
**Last Updated:** 24-July-2025  
**Version:** 2.0  
**Compatible:** Ubuntu 22.04 LTS 