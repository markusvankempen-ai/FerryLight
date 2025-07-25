# FerryLightV2 Server Setup

A complete Docker-based server setup for Ubuntu 22.04 LTS with Portainer, Traefik, and automatic SSL certificates.

## 🚀 Features

- **Docker & Docker Compose**: Latest versions with automatic installation
- **Portainer**: Web-based Docker management interface
- **Traefik**: Reverse proxy with automatic SSL certificates via Let's Encrypt
- **Nginx**: Web server for hosting static websites
- **Automatic SSL**: Let's Encrypt certificates with automatic renewal
- **Systemd Service**: Auto-start on boot
- **Backup & Update Scripts**: Easy maintenance

## 📋 Prerequisites

- Ubuntu 22.04 LTS server
- Root or sudo access
- Domain name (for SSL certificates)
- DNS access to configure A records

## 🛠️ Quick Setup

### 1. Download and Run Setup Script

```bash
# Download the setup script
wget https://raw.githubusercontent.com/your-repo/FerryLightV2/main/setup_server.sh

# Make it executable
chmod +x setup_server.sh

# Run the setup (as non-root user with sudo privileges)
./setup_server.sh
```

### 2. Configure Your Domain

```bash
# Run the domain configuration script
chmod +x configure_domains.sh
./configure_domains.sh
```

### 3. Configure DNS Records

Add the following A records in your DNS provider:

```
A    yourdomain.com          → Your server IP
A    www.yourdomain.com      → Your server IP
A    portainer.yourdomain.com → Your server IP
A    traefik.yourdomain.com  → Your server IP
```

## 📁 Project Structure

```
/opt/ferrylightv2/
├── docker-compose.yml      # Main Docker Compose configuration
├── traefik/
│   ├── traefik.yml         # Traefik main configuration
│   ├── config/
│   │   └── dynamic.yml     # Traefik dynamic configuration
│   └── acme/               # SSL certificates storage
├── portainer/              # Portainer data
├── website/                # Website files
│   └── index.html          # Main website
├── nginx.conf              # Nginx configuration
├── update.sh               # Update script
├── backup.sh               # Backup script
└── backups/                # Backup storage
```

## 🔧 Management Commands

### Service Management

```bash
cd /opt/ferrylightv2

# Check service status
docker-compose ps

# View logs
docker-compose logs

# View logs for specific service
docker-compose logs traefik
docker-compose logs portainer
docker-compose logs website

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Start services
docker-compose up -d

# Update all services
./update.sh

# Create backup
./backup.sh
```

### System Service Management

```bash
# Check service status
sudo systemctl status ferrylightv2

# Enable auto-start
sudo systemctl enable ferrylightv2

# Disable auto-start
sudo systemctl disable ferrylightv2

# Start service
sudo systemctl start ferrylightv2

# Stop service
sudo systemctl stop ferrylightv2
```

## 🌐 Access URLs

After setup and DNS configuration:

- **Main Website**: `https://yourdomain.com`
- **Portainer**: `https://portainer.yourdomain.com`
- **Traefik Dashboard**: `https://traefik.yourdomain.com`

## 🔐 Default Credentials

- **Traefik Dashboard**: `admin:admin`
- **Portainer**: Create admin account on first visit

## 🔒 Security Features

- Automatic HTTP to HTTPS redirect
- Security headers (HSTS, XSS protection, etc.)
- Docker containers run with security options
- Traefik dashboard protected with basic auth
- SSL certificates automatically managed

## 📊 Monitoring

### Check Service Health

```bash
# Check all containers
docker ps

# Check resource usage
docker stats

# Check Traefik logs
docker-compose logs -f traefik

# Check SSL certificate status
docker exec traefik cat /etc/traefik/acme/acme.json | jq .
```

### Log Locations

- **Traefik**: `docker-compose logs traefik`
- **Portainer**: `docker-compose logs portainer`
- **Website**: `docker-compose logs website`
- **System**: `sudo journalctl -u ferrylightv2`

## 🔄 Updates

### Automatic Updates

```bash
# Update all services to latest versions
./update.sh
```

### Manual Updates

```bash
cd /opt/ferrylightv2

# Pull latest images
docker-compose pull

# Restart with new images
docker-compose up -d

# Clean up old images
docker system prune -f
```

## 💾 Backup & Restore

### Create Backup

```bash
# Create full backup
./backup.sh
```

### Restore from Backup

```bash
# Stop services
docker-compose down

# Restore Portainer data
docker run --rm -v portainer_data:/data -v /path/to/backup:/backup alpine tar xzf /backup/portainer_YYYYMMDD_HHMMSS.tar.gz -C /data

# Restore Traefik certificates
tar xzf /path/to/backup/traefik_YYYYMMDD_HHMMSS.tar.gz -C /opt/ferrylightv2

# Start services
docker-compose up -d
```

## 🐛 Troubleshooting

### Common Issues

1. **SSL Certificate Issues**
   ```bash
   # Check Traefik logs
   docker-compose logs traefik
   
   # Verify DNS records
   nslookup yourdomain.com
   ```

2. **Portainer Not Accessible**
   ```bash
   # Check Portainer logs
   docker-compose logs portainer
   
   # Restart Portainer
   docker-compose restart portainer
   ```

3. **Website Not Loading**
   ```bash
   # Check website logs
   docker-compose logs website
   
   # Verify website files
   ls -la /opt/ferrylightv2/website/
   ```

### Reset Everything

```bash
# Stop and remove everything
cd /opt/ferrylightv2
docker-compose down -v
sudo rm -rf /opt/ferrylightv2

# Re-run setup
./setup_server.sh
```

## 📝 Customization

### Add New Services

1. Add service to `docker-compose.yml`
2. Add Traefik labels for routing
3. Update DNS records
4. Restart services

### Custom Website

Replace `/opt/ferrylightv2/website/index.html` with your own website files.

### Custom Traefik Configuration

Edit `/opt/ferrylightv2/traefik/traefik.yml` for advanced Traefik settings.

## 🤝 Support

For issues and questions:

1. Check the troubleshooting section
2. Review logs: `docker-compose logs`
3. Verify DNS configuration
4. Check firewall settings

## 📄 License

This project is open source and available under the MIT License.

---

**Note**: Remember to replace `yourdomain.com` with your actual domain name throughout the setup process. 