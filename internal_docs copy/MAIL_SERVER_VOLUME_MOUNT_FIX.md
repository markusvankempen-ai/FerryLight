# Mail Server Volume Mount Fix - FerryLightV2

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 🚨 **Critical Issue: Read-Only File System Error**

### **Error Message:**
```
/usr/local/bin/helpers/database/db.sh: line 110: /tmp/docker-mailserver/postfix-accounts.cf: Read-only file system
```

### **Root Cause:**
The Docker Mail Server configuration volume is mounted as read-only (`:ro`), preventing user management operations.

## 🔧 **Complete Fix**

### **Step 1: Stop Mail Server**
```bash
cd /opt/ferrylightv2
docker-compose stop mailserver
```

### **Step 2: Backup Current Configuration**
```bash
cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
```

### **Step 3: Edit docker-compose.yml**
```bash
nano docker-compose.yml
```

### **Step 4: Fix Volume Mount**

**Find this line:**
```yaml
- ./mailserver/dms/config:/tmp/docker-mailserver:ro
```

**Change it to:**
```yaml
- ./mailserver/config:/tmp/docker-mailserver
```

**Complete corrected mailserver section:**
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

### **Step 5: Create Directory Structure**
```bash
mkdir -p mailserver/config
mkdir -p mailserver/mail-data
mkdir -p mailserver/mail-state
mkdir -p mailserver/mail-logs
sudo chown -R $USER:$USER mailserver/
```

### **Step 6: Create Configuration File**
```bash
cat > mailserver/config/dms.conf << 'EOF'
# Docker Mail Server Configuration
DMS_DOMAINNAME=ferrylight.online
DMS_HOSTNAME=mail.ferrylight.online
DMS_ADMIN_EMAIL=admin@ferrylight.online
DMS_ADMIN_PASSWORD=ferrylight@Connexts@99
DMS_MAILNAME=mail.ferrylight.online
DMS_SSL_TYPE=letsencrypt
DMS_SSL_DOMAIN=mail.ferrylight.online
DMS_SPAMASSASSIN_SPAM_TO_INBOX=1
DMS_CLAMAV=1
DMS_ONE_DIR=1
DMS_API=1
DMS_API_KEY=ferrylight-api-key-2024
EOF
```

### **Step 7: Remove Old Container**
```bash
docker-compose rm -f mailserver
```

### **Step 8: Start Mail Server**
```bash
docker-compose up -d mailserver
```

### **Step 9: Wait for Startup**
```bash
sleep 30
```

### **Step 10: Test User Management**
```bash
# Add a test user
docker exec ferrylightv2-mailserver setup email add markus@ferrylight.online "secure_password_123"

# List users
docker exec ferrylightv2-mailserver setup email list
```

## ✅ **Verification**

### **Check Container Status:**
```bash
docker-compose ps mailserver
```

### **Check Logs:**
```bash
docker-compose logs mailserver
```

### **Test User Management:**
```bash
# Add user
docker exec ferrylightv2-mailserver setup email add test@ferrylight.online "test123"

# List users
docker exec ferrylightv2-mailserver setup email list

# Delete user
docker exec ferrylightv2-mailserver setup email del test@ferrylight.online
```

## 🔍 **Why This Fix Works**

### **Volume Mount Explanation:**

**❌ Incorrect (Read-only):**
```yaml
- ./mailserver/config:/tmp/docker-mailserver:ro
```
- `:ro` flag makes the volume read-only
- Docker Mail Server cannot write to `/tmp/docker-mailserver/postfix-accounts.cf`
- User management operations fail with "Read-only file system" error

**✅ Correct (Writable):**
```yaml
- ./mailserver/config:/tmp/docker-mailserver
```
- No `:ro` flag means the volume is writable
- Docker Mail Server can write to configuration files
- User management operations work correctly

### **Files That Need Write Access:**
- `/tmp/docker-mailserver/postfix-accounts.cf` - User accounts
- `/tmp/docker-mailserver/postfix-virtual.cf` - Virtual aliases
- `/tmp/docker-mailserver/dovecot-quotas.cf` - User quotas
- `/tmp/docker-mailserver/dovecot-masters.cf` - Master users

## 🚨 **Common Mistakes**

### **1. Using Wrong Directory Path:**
```yaml
# ❌ Wrong
- ./mailserver/dms/config:/tmp/docker-mailserver

# ✅ Correct
- ./mailserver/config:/tmp/docker-mailserver
```

### **2. Keeping Read-Only Flag:**
```yaml
# ❌ Wrong
- ./mailserver/config:/tmp/docker-mailserver:ro

# ✅ Correct
- ./mailserver/config:/tmp/docker-mailserver
```

### **3. Wrong Permissions:**
```bash
# ❌ Wrong
sudo chown root:root mailserver/

# ✅ Correct
sudo chown $USER:$USER mailserver/
```

## 📋 **Quick Fix Commands**

### **One-Liner Fix:**
```bash
cd /opt/ferrylightv2 && \
docker-compose stop mailserver && \
sed -i 's|./mailserver/dms/config:/tmp/docker-mailserver:ro|./mailserver/config:/tmp/docker-mailserver|g' docker-compose.yml && \
mkdir -p mailserver/config && \
sudo chown -R $USER:$USER mailserver/ && \
docker-compose up -d mailserver
```

### **Test After Fix:**
```bash
sleep 30 && \
docker exec ferrylightv2-mailserver setup email add test@ferrylight.online "test123" && \
docker exec ferrylightv2-mailserver setup email list
```

## 🎯 **Expected Results**

After applying this fix:
- ✅ User creation works without errors
- ✅ User listing works correctly
- ✅ User deletion works properly
- ✅ Password updates work
- ✅ No more "Read-only file system" errors

## 📞 **Support**

If you still encounter issues after applying this fix:
1. Check container logs: `docker-compose logs mailserver`
2. Verify volume mounts: `docker inspect ferrylightv2-mailserver | grep -A 10 "Mounts"`
3. Check file permissions: `ls -la mailserver/config/`

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 