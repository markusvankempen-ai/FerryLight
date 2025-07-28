# Authentication Fix Guide - FerryLightV2 Mail Server

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 🔐 **Fix Authentication Issue**

### **Problem:**
```
535 5.7.8 Error: authentication failed: (reason unavailable)
*** No authentication type succeeded
```

### **Root Cause:**
The mail user `admin@ferrylight.online` either doesn't exist or has incorrect credentials.

## 🔧 **Step-by-Step Fix**

### **Step 1: Check Existing Mail Users**

```bash
# List all mail users
docker exec ferrylightv2-mailserver setup email list

# Check if admin user exists
docker exec ferrylightv2-mailserver setup email list | grep admin@ferrylight.online
```

### **Step 2: Add/Update Admin User**

```bash
# Add admin user with correct password
docker exec ferrylightv2-mailserver setup email add admin@ferrylight.online "ferrylight@Connexts@99"

# Or update existing user password
docker exec ferrylightv2-mailserver setup email update admin@ferrylight.online "ferrylight@Connexts@99"
```

### **Step 3: Add Test User**

```bash
# Add test user for markus
docker exec ferrylightv2-mailserver setup email add markus@ferrylight.online "secure_password_123"
```

### **Step 4: Verify User Creation**

```bash
# List all users again
docker exec ferrylightv2-mailserver setup email list

# Check user details
docker exec ferrylightv2-mailserver setup email list | grep -E "(admin|markus)"
```

## 🔍 **Alternative Authentication Methods**

### **Method 1: Use Different Authentication**

```bash
# Try with AUTH PLAIN instead of AUTH LOGIN
swaks --to markus.van.kempen@gmail.com \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --auth-plain \
      --body "AUTH PLAIN test email"
```

### **Method 2: Use Different Port**

```bash
# Try port 25 (no authentication required for local delivery)
swaks --to markus@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 25 \
      --body "Port 25 test email"
```

### **Method 3: Test from Container**

```bash
# Send email directly from container (bypasses authentication)
docker exec ferrylightv2-mailserver bash -c 'echo "Subject: Test from Container" | sendmail markus@ferrylight.online'
```

## 🚨 **Troubleshooting Authentication**

### **Check Authentication Configuration:**

```bash
# Check SASL configuration
docker exec ferrylightv2-mailserver setup config sasl

# Check Postfix authentication settings
docker exec ferrylightv2-mailserver postconf -n | grep -i auth

# Check Dovecot authentication
docker exec ferrylightv2-mailserver setup config dovecot
```

### **Check User Database:**

```bash
# Check user accounts file
docker exec ferrylightv2-mailserver cat /tmp/docker-mailserver/postfix-accounts.cf

# Check if user exists in database
docker exec ferrylightv2-mailserver setup email list | grep admin
```

### **Check Mail Server Logs:**

```bash
# Check authentication logs
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log | grep -i auth

# Check Dovecot logs
docker exec ferrylightv2-mailserver tail -f /var/log/mail/dovecot.log

# Check Postfix logs
docker exec ferrylightv2-mailserver tail -f /var/log/mail/postfix.log
```

## 🔧 **Manual User Management**

### **Create User Manually:**

```bash
# Connect to mail server container
docker exec -it ferrylightv2-mailserver bash

# Inside container, create user manually
setup email add admin@ferrylight.online "ferrylight@Connexts@99"

# Exit container
exit
```

### **Check User Password:**

```bash
# Test user password
docker exec ferrylightv2-mailserver setup email test admin@ferrylight.online "ferrylight@Connexts@99"
```

## 📊 **Complete Authentication Test**

### **Create authentication test script:**

```bash
cat > test_auth.sh << 'EOF'
#!/bin/bash
# FerryLightV2 Authentication Test Script
# Author: Markus van Kempen
# Date: July 24, 2025

set -e

echo "🔐 Testing FerryLightV2 Mail Server Authentication..."

# Configuration
DOMAIN="ferrylight.online"
MAIL_SERVER="mail.ferrylight.online"
ADMIN_EMAIL="admin@ferrylight.online"
ADMIN_PASSWORD="ferrylight@Connexts@99"
TEST_EMAIL="markus@ferrylight.online"

echo "📋 Step 1: Checking existing users..."
docker exec ferrylightv2-mailserver setup email list

echo "👤 Step 2: Adding/updating admin user..."
docker exec ferrylightv2-mailserver setup email add $ADMIN_EMAIL "$ADMIN_PASSWORD"

echo "👤 Step 3: Adding test user..."
docker exec ferrylightv2-mailserver setup email add $TEST_EMAIL "secure_password_123"

echo "✅ Step 4: Verifying users..."
docker exec ferrylightv2-mailserver setup email list

echo "🔐 Step 5: Testing authentication..."
if swaks --to $TEST_EMAIL \
         --from $ADMIN_EMAIL \
         --server $MAIL_SERVER \
         --port 587 \
         --auth-user $ADMIN_EMAIL \
         --auth-password "$ADMIN_PASSWORD" \
         --body "Authentication test email" \
         --quit-after AUTH; then
    echo "✅ Authentication successful"
else
    echo "❌ Authentication failed"
fi

echo "✅ Authentication testing completed!"
EOF

chmod +x test_auth.sh
```

## 🎯 **Quick Fix Commands**

### **One-liner authentication fix:**

```bash
# Add admin user and test authentication
docker exec ferrylightv2-mailserver setup email add admin@ferrylight.online "ferrylight@Connexts@99" && \
docker exec ferrylightv2-mailserver setup email add markus@ferrylight.online "secure_password_123" && \
swaks --to markus@ferrylight.online --from admin@ferrylight.online --server mail.ferrylight.online --port 587 --auth-user admin@ferrylight.online --auth-password "ferrylight@Connexts@99" --body "Authentication test"
```

### **Test without authentication (local delivery):**

```bash
# Send to local user without authentication
swaks --to markus@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 25 \
      --body "Local delivery test"
```

## 📝 **Expected Results**

### **After fixing authentication:**

```bash
# User list should show:
admin@ferrylight.online
markus@ferrylight.online

# Authentication should succeed:
=== Trying mail.ferrylight.online:587...
=== Connected to mail.ferrylight.online.
<-  220 mail.ferrylight.online ESMTP
 -> EHLO ferrylight.online
<-  250-mail.ferrylight.online
<-  250-PIPELINING
<-  250-SIZE 10240000
<-  250-ETRN
<-  250-AUTH PLAIN LOGIN
<-  250-AUTH=PLAIN LOGIN
<-  250-ENHANCEDSTATUSCODES
<-  250-8BITMIME
<-  250-DSN
<-  250 CHUNKING
 -> AUTH LOGIN
<-  334 VXNlcm5hbWU6
 -> YWRtaW5AZmVycnlsaWdodC5vbmxpbmU=
<-  334 UGFzc3dvcmQ6
 -> ZmVycnlsaWdodEBDb25uZXh0c0A5OQ==
<-  235 2.7.0 Authentication successful
 -> MAIL FROM:<admin@ferrylight.online>
<-  250 2.1.0 Ok
 -> RCPT TO:<markus.van.kempen@gmail.com>
<-  250 2.1.5 Ok
 -> DATA
<-  354 End data with <CR><LF>.<CR><LF>
 -> .
<-  250 2.0.0 Ok: queued as ABC123DEF
 -> QUIT
<-  221 2.0.0 Bye
=== Connection closed with remote host.
```

## 🚨 **Common Issues and Solutions**

### **Issue 1: User doesn't exist**
**Solution:** Add the user with `setup email add`

### **Issue 2: Wrong password**
**Solution:** Update password with `setup email update`

### **Issue 3: Authentication mechanism not supported**
**Solution:** Try different auth methods (PLAIN vs LOGIN)

### **Issue 4: SASL configuration issues**
**Solution:** Check SASL configuration and restart mail server

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 