# TLS Configuration Fix for FerryLight Mail Server

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 🚨 **Problem: STARTTLS Not Supported Error**

**Error Message:** `"STARTTLS not supported and the user requires enforcement. For more information, go to https://support.google.com/a/answer/2520500, code: 504"`

**Root Cause:** The FerryLight mail server is not properly configured to advertise STARTTLS support, which Gmail requires for secure connections.

## 🔧 **Solution: Fix TLS Configuration**

### **Step 1: Update Docker Compose Configuration**

The current mail server configuration in `docker-compose.yml` is missing critical TLS environment variables. Here's the fix:

```bash
# Navigate to project directory
cd /opt/ferrylightv2

# Stop mail server
docker-compose stop mailserver
```

### **Step 2: Update Mail Server Environment Variables**

Edit your `docker-compose.yml` file and update the mailserver service environment section:

```yaml
  mailserver:
    image: docker.io/mailserver/docker-mailserver:latest
    container_name: ferrylightv2-mailserver
    restart: unless-stopped
    hostname: mail.ferrylight.online
    domainname: ferrylight.online
    ports:
      - "25:25"    # SMTP
      - "143:143"  # IMAP
      - "465:465"  # SMTPS
      - "587:587"  # SMTP submission
      - "993:993"  # IMAPS
    volumes:
      - ./mailserver/config:/tmp/docker-mailserver    # ✅ Writable - required for user management
      - ./mailserver/mail-data:/var/mail
      - ./mailserver/mail-state:/var/mail-state
      - ./mailserver/mail-logs:/var/log/mail
      - /etc/localtime:/etc/localtime:ro
    environment:
      - DMS_DOMAINNAME=ferrylight.online
      - DMS_HOSTNAME=mail.ferrylight.online
      - DMS_ADMIN_EMAIL=admin@ferrylight.online
      - DMS_ADMIN_PASSWORD=ferrylight@Connexts@99
      - DMS_MAILNAME=mail.ferrylight.online
      - DMS_SSL_TYPE=letsencrypt
      - DMS_SSL_DOMAIN=mail.ferrylight.online
      - DMS_SPAMASSASSIN_SPAM_TO_INBOX=1
      - DMS_CLAMAV=1
      - DMS_ONE_DIR=1
      - DMS_API=1
      - DMS_API_KEY=ferrylight-api-key-2024
      # 🔧 CRITICAL TLS CONFIGURATION ADDITIONS
      - ENABLE_TLS=1
      - TLS_LEVEL=intermediate
      - SSL_TYPE=letsencrypt
      - SSL_DOMAIN=mail.ferrylight.online
      - ENABLE_SRS=1
      - SRS_DOMAIN=ferrylight.online
      - ENABLE_OPENDKIM=1
      - ENABLE_OPENDMARC=1
      - ENABLE_SPAMASSASSIN=1
      - ENABLE_CLAMAV=1
      - ENABLE_FAIL2BAN=1
      - ENABLE_POSTGREY=1
      - ENABLE_SASLAUTHD=1
      - SASLAUTHD_MECHANISMS=plain
      - ENABLE_MANAGESIEVE=1
      - ENABLE_FETCHMAIL=1
      - ENABLE_ENCRYPTION=1
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mail.rule=Host(`mail.ferrylight.online`)"
      - "traefik.http.routers.mail.entrypoints=websecure"
      - "traefik.http.routers.mail.tls.certresolver=letsencrypt"
      - "traefik.http.services.mail.loadbalancer.server.port=80"
    depends_on:
      - traefik
```

### **Step 3: Create Mail Server Configuration File**

Create a proper DMS configuration file:

```bash
# Create mail server config directory
mkdir -p /opt/ferrylightv2/mailserver/config

# Create DMS configuration file
cat > /opt/ferrylightv2/mailserver/config/dms.conf << 'EOF'
# Docker Mail Server Configuration
# Author: Markus van Kempen
# Date: July 24, 2025

# Domain configuration
DMS_DOMAINNAME=ferrylight.online
DMS_HOSTNAME=mail.ferrylight.online

# Admin user
DMS_ADMIN_EMAIL=admin@ferrylight.online
DMS_ADMIN_PASSWORD=ferrylight@Connexts@99

# Mail settings
DMS_MAILNAME=mail.ferrylight.online
DMS_MAIL_HOSTNAME=mail.ferrylight.online

# SSL/TLS settings
DMS_SSL_TYPE=letsencrypt
DMS_SSL_DOMAIN=mail.ferrylight.online

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
DMS_OVERRIDE_HOSTNAME=mail.ferrylight.online
DMS_REJECT_UNLISTED_RECIPIENT=0
DMS_REJECT_UNLISTED_SENDER=0

# Web interface
DMS_WEBROOT_PATH=/web
DMS_WEBROOT_PATH_OVERRIDE=/web

# API
DMS_API=1
DMS_API_KEY=ferrylight-api-key-2024

# 🔧 CRITICAL TLS CONFIGURATION
ENABLE_TLS=1
TLS_LEVEL=intermediate
SSL_TYPE=letsencrypt
SSL_DOMAIN=mail.ferrylight.online
ENABLE_SRS=1
SRS_DOMAIN=ferrylight.online
ENABLE_OPENDKIM=1
ENABLE_OPENDMARC=1
ENABLE_SPAMASSASSIN=1
ENABLE_CLAMAV=1
ENABLE_FAIL2BAN=1
ENABLE_POSTGREY=1
ENABLE_SASLAUTHD=1
SASLAUTHD_MECHANISMS=plain
ENABLE_MANAGESIEVE=1
ENABLE_FETCHMAIL=1
ENABLE_ENCRYPTION=1
EOF
```

### **Step 4: Restart Mail Server**

```bash
# Start mail server with new configuration
docker-compose up -d mailserver

# Check status
docker-compose ps mailserver

# View logs for any errors
docker-compose logs mailserver
```

### **Step 5: Verify TLS Configuration**

```bash
# Test SMTP with STARTTLS
swaks --to markus.van.kempen@gmail.com \
  --from admin@ferrylight.online \
  --server mail.ferrylight.online \
  --port 587 \
  --auth-user admin@ferrylight.online \
  --auth-password "ferrylight@Connexts@99" \
  --helo ferrylight.online \
  --body "TLS test email from FerryLight"

# Test SMTP with SSL/TLS
swaks --to markus.van.kempen@gmail.com \
  --from admin@ferrylight.online \
  --server mail.ferrylight.online \
  --port 465 \
  --auth-user admin@ferrylight.online \
  --auth-password "ferrylight@Connexts@99" \
  --tls \
  --helo ferrylight.online \
  --body "SMTPS test email from FerryLight"
```

### **Step 6: Test Gmail Connection**

Now try connecting Gmail again with these settings:

**SMTP Settings for Gmail:**
```
Email address: admin@ferrylight.online
SMTP server: mail.ferrylight.online
Port: 587
Username: admin@ferrylight.online
Password: ferrylight@Connexts@99
Security: STARTTLS
```

## 🔍 **Troubleshooting**

### **If STARTTLS Still Not Working:**

1. **Check Mail Server Logs:**
```bash
docker-compose logs mailserver | grep -i tls
docker-compose logs mailserver | grep -i ssl
```

2. **Test Port 587 Directly:**
```bash
telnet mail.ferrylight.online 587
```

3. **Check SSL Certificate:**
```bash
docker exec ferrylightv2-mailserver setup config ssl
```

4. **Verify DNS Records:**
```bash
nslookup mail.ferrylight.online
dig mail.ferrylight.online
```

### **Alternative: Use Port 465 (SMTPS)**

If STARTTLS still doesn't work, use SMTPS on port 465:

**Gmail SMTP Settings (Alternative):**
```
Email address: admin@ferrylight.online
SMTP server: mail.ferrylight.online
Port: 465
Username: admin@ferrylight.online
Password: ferrylight@Connexts@99
Security: SSL/TLS
```

## 📋 **Complete Fix Script**

Create a complete fix script:

```bash
cat > /opt/ferrylightv2/fix_tls_config.sh << 'EOF'
#!/bin/bash

# FerryLightV2 TLS Configuration Fix
# Author: Markus van Kempen
# Date: July 24, 2025

echo "🔧 Fixing TLS Configuration for FerryLight Mail Server"
echo "======================================================"

# Stop mail server
echo "Stopping mail server..."
cd /opt/ferrylightv2
docker-compose stop mailserver

# Create proper configuration
echo "Creating TLS configuration..."
mkdir -p mailserver/config

cat > mailserver/config/dms.conf << 'CONFIG_EOF'
# Docker Mail Server Configuration
# Author: Markus van Kempen
# Date: July 24, 2025

# Domain configuration
DMS_DOMAINNAME=ferrylight.online
DMS_HOSTNAME=mail.ferrylight.online

# Admin user
DMS_ADMIN_EMAIL=admin@ferrylight.online
DMS_ADMIN_PASSWORD=ferrylight@Connexts@99

# Mail settings
DMS_MAILNAME=mail.ferrylight.online
DMS_MAIL_HOSTNAME=mail.ferrylight.online

# SSL/TLS settings
DMS_SSL_TYPE=letsencrypt
DMS_SSL_DOMAIN=mail.ferrylight.online

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
DMS_OVERRIDE_HOSTNAME=mail.ferrylight.online
DMS_REJECT_UNLISTED_RECIPIENT=0
DMS_REJECT_UNLISTED_SENDER=0

# Web interface
DMS_WEBROOT_PATH=/web
DMS_WEBROOT_PATH_OVERRIDE=/web

# API
DMS_API=1
DMS_API_KEY=ferrylight-api-key-2024

# CRITICAL TLS CONFIGURATION
ENABLE_TLS=1
TLS_LEVEL=intermediate
SSL_TYPE=letsencrypt
SSL_DOMAIN=mail.ferrylight.online
ENABLE_SRS=1
SRS_DOMAIN=ferrylight.online
ENABLE_OPENDKIM=1
ENABLE_OPENDMARC=1
ENABLE_SPAMASSASSIN=1
ENABLE_CLAMAV=1
ENABLE_FAIL2BAN=1
ENABLE_POSTGREY=1
ENABLE_SASLAUTHD=1
SASLAUTHD_MECHANISMS=plain
ENABLE_MANAGESIEVE=1
ENABLE_FETCHMAIL=1
ENABLE_ENCRYPTION=1
CONFIG_EOF

# Start mail server
echo "Starting mail server with new configuration..."
docker-compose up -d mailserver

# Wait for startup
echo "Waiting for mail server to start..."
sleep 30

# Check status
echo "Checking mail server status..."
docker-compose ps mailserver

# Test TLS
echo "Testing TLS configuration..."
swaks --to markus.van.kempen@gmail.com \
  --from admin@ferrylight.online \
  --server mail.ferrylight.online \
  --port 587 \
  --auth-user admin@ferrylight.online \
  --auth-password "ferrylight@Connexts@99" \
  --helo ferrylight.online \
  --body "TLS fix test email from FerryLight"

echo "✅ TLS configuration fix completed!"
echo "📧 Try connecting Gmail again with:"
echo "   Server: mail.ferrylight.online"
echo "   Port: 587"
echo "   Security: STARTTLS"
echo "   Username: admin@ferrylight.online"
echo "   Password: ferrylight@Connexts@99"
EOF

chmod +x /opt/ferrylightv2/fix_tls_config.sh
```

## 🎯 **Quick Fix Commands**

```bash
# Run the complete fix
cd /opt/ferrylightv2
./fix_tls_config.sh

# Or manually:
docker-compose stop mailserver
# Edit docker-compose.yml to add TLS environment variables
docker-compose up -d mailserver
```

## 📞 **Support**

If the issue persists:
1. Check mail server logs: `docker-compose logs mailserver`
2. Verify DNS records are correct
3. Ensure ports 25, 587, 465 are open
4. Check SSL certificate generation

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 