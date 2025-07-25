# Mail Server Setup Guide - Docker Mail DMS

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

This guide provides manual steps to add Docker Mail DMS (Docker Mail Server) to your FerryLightV2 environment.

## 📧 Overview

Docker Mail DMS provides a complete email server solution with:
- **SMTP/IMAP** email services
- **Spam protection** with SpamAssassin
- **Antivirus** with ClamAV
- **Web interface** for management
- **SSL/TLS** encryption
- **API** for automation

## 🚀 Quick Setup

### 1. Create Mail Server Directories

```bash
# Navigate to project directory
cd /opt/ferrylightv2

# Create mail server directories
mkdir -p mailserver/mail-data
mkdir -p mailserver/mail-state
mkdir -p mailserver/mail-logs
mkdir -p mailserver/config
mkdir -p mailserver/dms/config

# Set proper permissions
sudo chown -R $USER:$USER mailserver
```

### 2. Create Mail Server Configuration

```bash
# Create DMS configuration
cat > mailserver/dms/config/dms.conf << 'EOF'
# Docker Mail Server Configuration
# Author: Markus van Kempen
# Date: July 24, 2025

# Domain configuration
DMS_DOMAINNAME=your-domain.com
DMS_HOSTNAME=mail.your-domain.com

# Admin user
DMS_ADMIN_EMAIL=admin@your-domain.com
DMS_ADMIN_PASSWORD=your-secure-mail-password

# Mail settings
DMS_MAILNAME=mail.your-domain.com
DMS_MAIL_HOSTNAME=mail.your-domain.com

# SSL/TLS settings
DMS_SSL_TYPE=letsencrypt
DMS_SSL_DOMAIN=mail.your-domain.com

# Spam protection
DMS_SPAMASSASSIN_SPAM_TO_INBOX=1
DMS_SPAMASSASSIN_SA_TAG=2.0
DMS_SPAMASSASSIN_SA_KILL=3.0

# ClamAV antivirus
DMS_CLAMAV=1

# Postfix settings
DMS_POSTFIX_MESSAGE_SIZE_LIMIT=52428800
DMS_POSTFIX_MAILBOX_SIZE_LIMIT=0

# Dovecot settings
DMS_DOVECOT_MAILBOX_SIZE_LIMIT=0

# Logging
DMS_LOGROTATE=1
DMS_LOG_LEVEL=info

# Security
DMS_ONE_DIR=1
DMS_OVERRIDE_HOSTNAME=mail.your-domain.com
DMS_REJECT_UNLISTED_RECIPIENT=0
DMS_REJECT_UNLISTED_SENDER=0

# Web interface
DMS_WEBROOT_PATH=/web
DMS_WEBROOT_PATH_OVERRIDE=/web

# API
DMS_API=1
DMS_API_KEY=your-secure-api-key
EOF
```

### 3. Add Mail Server to Docker Compose

Add this service to your `docker-compose.yml`:

```yaml
  mailserver:
    image: docker.io/mailserver/docker-mailserver:latest
    container_name: ferrylightv2-mailserver
    restart: unless-stopped
    hostname: mail.your-domain.com
    domainname: your-domain.com
    ports:
      - "25:25"    # SMTP
      - "143:143"  # IMAP
      - "465:465"  # SMTPS
      - "587:587"  # SMTP submission
      - "993:993"  # IMAPS
    volumes:
      - ./mailserver/dms/config:/tmp/docker-mailserver:ro
      - ./mailserver/mail-data:/var/mail
      - ./mailserver/mail-state:/var/mail-state
      - ./mailserver/mail-logs:/var/log/mail
      - /etc/localtime:/etc/localtime:ro
    environment:
      - DMS_DOMAINNAME=your-domain.com
      - DMS_HOSTNAME=mail.your-domain.com
      - DMS_ADMIN_EMAIL=admin@your-domain.com
      - DMS_ADMIN_PASSWORD=your-secure-mail-password
      - DMS_MAILNAME=mail.your-domain.com
      - DMS_SSL_TYPE=letsencrypt
      - DMS_SSL_DOMAIN=mail.your-domain.com
      - DMS_SPAMASSASSIN_SPAM_TO_INBOX=1
      - DMS_CLAMAV=1
      - DMS_ONE_DIR=1
      - DMS_API=1
      - DMS_API_KEY=your-secure-api-key
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mail.rule=Host(`mail.your-domain.com`)"
      - "traefik.http.routers.mail.entrypoints=websecure"
      - "traefik.http.routers.mail.tls.certresolver=letsencrypt"
      - "traefik.http.services.mail.loadbalancer.server.port=80"
    depends_on:
      - traefik
```

### 4. Start Mail Server

```bash
# Start mail server
docker-compose up -d mailserver

# Check status
docker-compose ps mailserver

# View logs
docker-compose logs mailserver
```

## 📧 Mail Server Configuration

### 1. DNS Records

Add these DNS records to your domain:

```
# A Record
mail.your-domain.com  A  your-server-ip

# MX Record
your-domain.com  MX  10  mail.your-domain.com

# SPF Record
your-domain.com  TXT  "v=spf1 mx a ip4:your-server-ip ~all"

# DKIM Record (will be generated after setup)
mail._domainkey.your-domain.com  TXT  "v=DKIM1; k=rsa; p=YOUR_DKIM_KEY"

# DMARC Record
_dmarc.your-domain.com  TXT  "v=DMARC1; p=quarantine; rua=mailto:dmarc@your-domain.com"
```

### 2. Port Configuration

Ensure these ports are open on your firewall:

```bash
# Open mail ports
sudo ufw allow 25/tcp   # SMTP
sudo ufw allow 143/tcp  # IMAP
sudo ufw allow 465/tcp  # SMTPS
sudo ufw allow 587/tcp  # SMTP submission
sudo ufw allow 993/tcp  # IMAPS

# Check firewall status
sudo ufw status
```

## 🔧 Mail Server Management

### 1. Create Management Script

```bash
# Create management script
cat > /opt/ferrylightv2/manage_mail.sh << 'EOF'
#!/bin/bash

# FerryLightV2 Mail Server Management Script
# Author: Markus van Kempen
# Date: July 24, 2025

PROJECT_DIR="/opt/ferrylightv2"

echo "📧 FerryLightV2 Mail Server Management"
echo "======================================"
echo ""

case "$1" in
    "start")
        echo "Starting mail server..."
        cd $PROJECT_DIR
        docker-compose up -d mailserver
        ;;
    "stop")
        echo "Stopping mail server..."
        cd $PROJECT_DIR
        docker-compose stop mailserver
        ;;
    "restart")
        echo "Restarting mail server..."
        cd $PROJECT_DIR
        docker-compose restart mailserver
        ;;
    "logs")
        echo "Showing mail server logs..."
        cd $PROJECT_DIR
        docker-compose logs -f mailserver
        ;;
    "status")
        echo "Mail server status:"
        cd $PROJECT_DIR
        docker-compose ps mailserver
        ;;
    "add-user")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 add-user <email> <password>"
            exit 1
        fi
        echo "Adding mail user: $2"
        cd $PROJECT_DIR
        docker exec ferrylightv2-mailserver setup email add $2 $3
        ;;
    "del-user")
        if [ -z "$2" ]; then
            echo "Usage: $0 del-user <email>"
            exit 1
        fi
        echo "Deleting mail user: $2"
        cd $PROJECT_DIR
        docker exec ferrylightv2-mailserver setup email del $2
        ;;
    "list-users")
        echo "Listing mail users:"
        cd $PROJECT_DIR
        docker exec ferrylightv2-mailserver setup email list
        ;;
    "test")
        echo "Testing mail server..."
        cd $PROJECT_DIR
        docker exec ferrylightv2-mailserver setup test
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs|status|add-user|del-user|list-users|test}"
        echo ""
        echo "Examples:"
        echo "  $0 start                    # Start mail server"
        echo "  $0 stop                     # Stop mail server"
        echo "  $0 restart                  # Restart mail server"
        echo "  $0 logs                     # Show logs"
        echo "  $0 status                   # Show status"
        echo "  $0 add-user user@domain.com password  # Add mail user"
        echo "  $0 del-user user@domain.com           # Delete mail user"
        echo "  $0 list-users               # List all users"
        echo "  $0 test                     # Test mail server"
        exit 1
        ;;
esac
EOF

# Make executable
chmod +x /opt/ferrylightv2/manage_mail.sh
```

### 2. Mail Server Commands

```bash
# Start mail server
./manage_mail.sh start

# Check status
./manage_mail.sh status

# View logs
./manage_mail.sh logs

# Add mail user
./manage_mail.sh add-user user@your-domain.com password

# List users
./manage_mail.sh list-users

# Test mail server
./manage_mail.sh test
```

## 📱 Email Client Configuration

### 1. IMAP Settings

```
Incoming Mail (IMAP):
- Server: mail.your-domain.com
- Port: 993 (SSL/TLS) or 143 (STARTTLS)
- Username: your-email@your-domain.com
- Password: your-password
- Security: SSL/TLS or STARTTLS
```

### 2. SMTP Settings

```
Outgoing Mail (SMTP):
- Server: mail.your-domain.com
- Port: 587 (STARTTLS) or 465 (SSL/TLS)
- Username: your-email@your-domain.com
- Password: your-password
- Security: STARTTLS or SSL/TLS
- Authentication: Required
```

## 🔒 Security Features

### 1. Spam Protection

- **SpamAssassin** integration
- **Configurable thresholds**
- **Spam quarantine**
- **Bayesian filtering**

### 2. Antivirus

- **ClamAV** integration
- **Real-time scanning**
- **Automatic quarantine**

### 3. SSL/TLS

- **Let's Encrypt** certificates
- **Automatic renewal**
- **Strong encryption**

### 4. Authentication

- **SMTP authentication**
- **IMAP authentication**
- **Secure passwords**

## 📊 Monitoring

### 1. Web Interface

Access the mail server web interface at:
```
https://mail.your-domain.com
```

### 2. Logs

```bash
# View mail logs
docker-compose logs mailserver

# View specific log files
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log
docker exec ferrylightv2-mailserver tail -f /var/log/mail/clamav.log
```

### 3. Statistics

```bash
# Check mail statistics
docker exec ferrylightv2-mailserver setup config dkim

# Check SSL certificates
docker exec ferrylightv2-mailserver setup config ssl
```

## 🚨 Troubleshooting

### 1. Common Issues

**Port 25 blocked by ISP:**
```bash
# Use alternative port or contact ISP
# Configure relay through external SMTP
```

**SSL certificate issues:**
```bash
# Check DNS records
# Verify domain configuration
# Check Let's Encrypt logs
```

**Authentication failed:**
```bash
# Check user credentials
# Verify user exists
# Check mail server logs
```

### 2. Testing

```bash
# Test SMTP
telnet mail.your-domain.com 25

# Test IMAP
telnet mail.your-domain.com 143

# Test SSL
openssl s_client -connect mail.your-domain.com:993
```

## 📞 Support

For additional help:
- **Docker Mail DMS Documentation:** https://docker-mailserver.github.io/docker-mailserver/
- **GitHub Repository:** https://github.com/docker-mailserver/docker-mailserver
- **Community Forum:** https://github.com/docker-mailserver/docker-mailserver/discussions

---

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 