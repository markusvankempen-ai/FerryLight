# Internal Mail Server Access Guide - FerryLightV2

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

This guide provides comprehensive instructions for accessing and managing the Docker Mail DMS in your FerryLightV2 system with REAL credentials.

## 📧 **Mail Server Access Methods**

### **1. 🖥️ Web Interface**

**URL:** `https://mail.ferrylight.online`

**Login Credentials:**
- **Admin Email:** `admin@ferrylight.online`
- **Admin Password:** `ferrylight@Connexts@99`

### **2. 🔧 Management Script**

**Run the built-in management script:**
```bash
# Navigate to project directory
cd /opt/ferrylightv2

# Run mail server management script
./manage_mail.sh
```

**Available Commands:**
```bash
# Start mail server
./manage_mail.sh start

# Stop mail server
./manage_mail.sh stop

# Restart mail server
./manage_mail.sh restart

# View logs
./manage_mail.sh logs

# Check status
./manage_mail.sh status

# Add mail user
./manage_mail.sh add-user user@ferrylight.online password

# Delete mail user
./manage_mail.sh del-user user@ferrylight.online

# List users
./manage_mail.sh list-users

# Test mail server
./manage_mail.sh test
```

### **3. 🖥️ Direct Container Access**

**Access mail server container:**
```bash
# Connect to mail server container
docker exec -it ferrylightv2-mailserver bash

# Run mail server commands
docker exec ferrylightv2-mailserver setup email list
docker exec ferrylightv2-mailserver setup email add user@ferrylight.online password
docker exec ferrylightv2-mailserver setup config dkim
docker exec ferrylightv2-mailserver setup test
```

### **4. 🔧 Volume Mount Configuration (CRITICAL)**

**⚠️ IMPORTANT: Volume mounts must NOT be read-only for user management to work!**

**Correct Volume Mount:**
```yaml
volumes:
  - ./mailserver/config:/tmp/docker-mailserver    # ✅ Correct - writable
```

**Incorrect Volume Mount:**
```yaml
volumes:
  - ./mailserver/config:/tmp/docker-mailserver:ro  # ❌ Wrong - read-only
```

**Why This Matters:**
- Docker Mail Server needs to write to `/tmp/docker-mailserver/postfix-accounts.cf` for user management
- Read-only mounts cause "Read-only file system" errors when adding users
- The `:ro` flag prevents user creation, deletion, and password updates
```

## 📧 **Email Client Configuration**

### **IMAP Settings:**
```
Incoming Mail (IMAP):
- Server: mail.ferrylight.online
- Port: 993 (SSL/TLS) or 143 (STARTTLS)
- Username: your-email@ferrylight.online
- Password: your-password
- Security: SSL/TLS or STARTTLS
```

### **SMTP Settings:**
```
Outgoing Mail (SMTP):
- Server: mail.ferrylight.online
- Port: 587 (STARTTLS) or 465 (SSL/TLS)
- Username: your-email@ferrylight.online
- Password: your-password
- Security: STARTTLS or SSL/TLS
- Authentication: Required
```

## 🔐 **Real Credentials**

### **Admin Access:**
- **Email:** `admin@ferrylight.online`
- **Password:** `ferrylight@Connexts@99`
- **API Key:** `ferrylight-api-key-2024`

### **Connection Details:**
- **Host:** `mail.ferrylight.online`
- **Domain:** `ferrylight.online`
- **Server IP:** `209.209.43.250`

## 📊 **DNS Records (Real)**

### **Required DNS Records:**
```
# A Record
mail.ferrylight.online  A  209.209.43.250

# MX Record
ferrylight.online  MX  10  mail.ferrylight.online

# SPF Record
ferrylight.online  TXT  "v=spf1 mx a ip4:209.209.43.250 ~all"

# DKIM Record (will be generated after setup)
mail._domainkey.ferrylight.online  TXT  "v=DKIM1; k=rsa; p=YOUR_DKIM_KEY"

# DMARC Record
_dmarc.ferrylight.online  TXT  "v=DMARC1; p=quarantine; rua=mailto:dmarc@ferrylight.online"
```

## 🔧 **Port Configuration**

### **Required Open Ports:**
```bash
# Open mail ports on firewall
sudo ufw allow 25/tcp   # SMTP
sudo ufw allow 143/tcp  # IMAP
sudo ufw allow 465/tcp  # SMTPS
sudo ufw allow 587/tcp  # SMTP submission
sudo ufw allow 993/tcp  # IMAPS

# Check firewall status
sudo ufw status
```

## 📧 **Mail Server Management**

### **User Management:**
```bash
# Add new mail user
./manage_mail.sh add-user user@ferrylight.online secure_password

# Delete mail user
./manage_mail.sh del-user user@ferrylight.online

# List all users
./manage_mail.sh list-users

# Change user password
docker exec ferrylightv2-mailserver setup email update user@ferrylight.online new_password
```

### **Server Management:**
```bash
# Start mail server
./manage_mail.sh start

# Stop mail server
./manage_mail.sh stop

# Restart mail server
./manage_mail.sh restart

# Check status
./manage_mail.sh status

# View logs
./manage_mail.sh logs
```

### **Configuration Management:**
```bash
# Generate DKIM key
docker exec ferrylightv2-mailserver setup config dkim

# Check SSL certificates
docker exec ferrylightv2-mailserver setup config ssl

# Test mail server
./manage_mail.sh test

# Check mail server configuration
docker exec ferrylightv2-mailserver setup config
```

## 📊 **Monitoring and Logs**

### **View Logs:**
```bash
# View mail server logs
docker-compose logs mailserver

# View specific log files
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log
docker exec ferrylightv2-mailserver tail -f /var/log/mail/clamav.log
docker exec ferrylightv2-mailserver tail -f /var/log/mail/spamassassin.log
```

### **Statistics:**
```bash
# Check mail statistics
docker exec ferrylightv2-mailserver setup config dkim

# Check SSL certificates
docker exec ferrylightv2-mailserver setup config ssl

# Check mail queue
docker exec ferrylightv2-mailserver postqueue -p
```

## 🔒 **Security Features**

### **Spam Protection:**
- **SpamAssassin** integration
- **Configurable thresholds**
- **Spam quarantine**
- **Bayesian filtering**

### **Antivirus:**
- **ClamAV** integration
- **Real-time scanning**
- **Automatic quarantine**

### **SSL/TLS:**
- **Let's Encrypt** certificates
- **Automatic renewal**
- **Strong encryption**

### **Authentication:**
- **SMTP authentication**
- **IMAP authentication**
- **Secure passwords**

## 🚨 **Troubleshooting**

### **Common Issues:**

**Port 25 blocked by ISP:**
```bash
# Check if port 25 is blocked
telnet mail.ferrylight.online 25

# Use alternative port or contact ISP
# Configure relay through external SMTP
```

**SSL certificate issues:**
```bash
# Check DNS records
nslookup mail.ferrylight.online

# Verify domain configuration
docker exec ferrylightv2-mailserver setup config ssl

# Check Let's Encrypt logs
docker-compose logs mailserver | grep -i ssl
```

**Authentication failed:**
```bash
# Check user credentials
./manage_mail.sh list-users

# Verify user exists
docker exec ferrylightv2-mailserver setup email list

# Check mail server logs
./manage_mail.sh logs
```

### **Testing:**
```bash
# Test SMTP
telnet mail.ferrylight.online 25

# Test IMAP
telnet mail.ferrylight.online 143

# Test SSL
openssl s_client -connect mail.ferrylight.online:993

# Test mail server
./manage_mail.sh test
```

## 📱 **Quick Access Summary**

**For Web Interface:**
- **URL:** `https://mail.ferrylight.online`
- **Email:** `admin@ferrylight.online`
- **Password:** `ferrylight@Connexts@99`

**For Management:**
```bash
cd /opt/ferrylightv2
./manage_mail.sh
```

**For Testing:**
```bash
cd /opt/ferrylightv2
./manage_mail.sh test
```

## 🎯 **Quick Start Checklist**

- [ ] **Web Interface:** `https://mail.ferrylight.online`
- [ ] **Management Script:** `./manage_mail.sh`
- [ ] **Check Status:** `./manage_mail.sh status`
- [ ] **View Logs:** `./manage_mail.sh logs`
- [ ] **Add User:** `./manage_mail.sh add-user email@ferrylight.online password`
- [ ] **Test Server:** `./manage_mail.sh test`
- [ ] **DNS Records:** Configure A, MX, SPF, DKIM, DMARC
- [ ] **Firewall:** Open ports 25, 143, 465, 587, 993

## 📞 **Support**

For additional help:
- **Docker Mail DMS Documentation:** https://docker-mailserver.github.io/docker-mailserver/
- **GitHub Repository:** https://github.com/docker-mailserver/docker-mailserver
- **Community Forum:** https://github.com/docker-mailserver/docker-mailserver/discussions

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 