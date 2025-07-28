# HELO Hostname and Authentication Fix - FerryLightV2

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 🔧 **Fix HELO Hostname and Authentication Issues**

### **Problems:**
1. **Authentication failed:** `535 5.7.8 Error: authentication failed`
2. **HELO hostname rejected:** `504 5.5.2 <ferrylight>: Helo command rejected: need fully-qualified hostname`

## 🔧 **Step-by-Step Fix**

### **Step 1: Fix HELO Hostname Issue**

**The issue is that swaks is using `ferrylight` instead of `ferrylight.online`**

```bash
# Test with proper HELO hostname
swaks --to markus@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 25 \
      --helo ferrylight.online \
      --body "Local delivery test with proper HELO"
```

### **Step 2: Fix Authentication Issue**

**The admin user exists but authentication is failing. Let's update the password:**

```bash
# Update admin user password
docker exec ferrylightv2-mailserver setup email update admin@ferrylight.online "ferrylight@Connexts@99"

# Verify the user
docker exec ferrylightv2-mailserver setup email list | grep admin
```

### **Step 3: Test Authentication with Different Methods**

```bash
# Test with AUTH PLAIN
swaks --to markus.van.kempen@gmail.com \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --auth-plain \
      --helo ferrylight.online \
      --body "AUTH PLAIN test email"
```

### **Step 4: Test Local Delivery (No Authentication)**

```bash
# Test local delivery with proper HELO
swaks --to markus@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 25 \
      --helo ferrylight.online \
      --body "Local delivery test with proper HELO hostname"
```

## 🔍 **Alternative Solutions**

### **Solution 1: Use Container Sendmail (Bypass Authentication)**

```bash
# Send email directly from container
docker exec ferrylightv2-mailserver bash -c 'echo "Subject: Test from Container" | sendmail markus@ferrylight.online'

# Or with more details
docker exec ferrylightv2-mailserver bash -c 'cat << EOF | sendmail markus@ferrylight.online
From: admin@ferrylight.online
To: markus@ferrylight.online
Subject: Test Email from Container
Content-Type: text/plain

This is a test email sent directly from the container.
Date: $(date)
Container: ferrylightv2-mailserver
EOF'
```

### **Solution 2: Check User Password Hash**

```bash
# Check the user password hash
docker exec ferrylightv2-mailserver cat /tmp/docker-mailserver/postfix-accounts.cf

# Look for the admin@ferrylight.online line
docker exec ferrylightv2-mailserver cat /tmp/docker-mailserver/postfix-accounts.cf | grep admin
```

### **Solution 3: Recreate User with Different Password**

```bash
# Delete and recreate admin user
docker exec ferrylightv2-mailserver setup email del admin@ferrylight.online
docker exec ferrylightv2-mailserver setup email add admin@ferrylight.online "admin123"

# Test with new password
swaks --to markus.van.kempen@gmail.com \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "admin123" \
      --helo ferrylight.online \
      --body "Test with new password"
```

## 🚨 **Troubleshooting**

### **Check Authentication Configuration:**

```bash
# Check SASL configuration
docker exec ferrylightv2-mailserver setup config sasl

# Check Postfix authentication settings
docker exec ferrylightv2-mailserver postconf -n | grep -i auth

# Check Dovecot authentication
docker exec ferrylightv2-mailserver setup config dovecot
```

### **Check Mail Server Logs:**

```bash
# Check authentication logs
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log | grep -i auth

# Check for specific authentication errors
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log | grep -i "535"
```

### **Check User Database:**

```bash
# Check user accounts file
docker exec ferrylightv2-mailserver cat /tmp/docker-mailserver/postfix-accounts.cf

# Check if user exists in database
docker exec ferrylightv2-mailserver setup email list | grep admin
```

## 📊 **Complete Test Script**

### **Create comprehensive test script:**

```bash
cat > test_complete_email.sh << 'EOF'
#!/bin/bash
# FerryLightV2 Complete Email Test Script
# Author: Markus van Kempen
# Date: July 24, 2025

set -e

echo "🧪 Complete Email Testing for FerryLightV2..."

# Configuration
DOMAIN="ferrylight.online"
MAIL_SERVER="mail.ferrylight.online"
ADMIN_EMAIL="admin@ferrylight.online"
ADMIN_PASSWORD="ferrylight@Connexts@99"
TEST_EMAIL="markus@ferrylight.online"

echo "📋 Step 1: Checking users..."
docker exec ferrylightv2-mailserver setup email list

echo "🔐 Step 2: Testing local delivery (port 25)..."
if swaks --to $TEST_EMAIL \
         --from $ADMIN_EMAIL \
         --server $MAIL_SERVER \
         --port 25 \
         --helo $DOMAIN \
         --body "Local delivery test - $(date)"; then
    echo "✅ Local delivery successful"
else
    echo "❌ Local delivery failed"
fi

echo "🔐 Step 3: Testing authentication (port 587)..."
if swaks --to $TEST_EMAIL \
         --from $ADMIN_EMAIL \
         --server $MAIL_SERVER \
         --port 587 \
         --auth-user $ADMIN_EMAIL \
         --auth-password "$ADMIN_PASSWORD" \
         --helo $DOMAIN \
         --body "Authentication test - $(date)"; then
    echo "✅ Authentication successful"
else
    echo "❌ Authentication failed"
fi

echo "📨 Step 4: Testing container sendmail..."
if docker exec ferrylightv2-mailserver bash -c 'echo "Subject: Container Test" | sendmail markus@ferrylight.online'; then
    echo "✅ Container sendmail successful"
else
    echo "❌ Container sendmail failed"
fi

echo "📊 Step 5: Checking mail queue..."
docker exec ferrylightv2-mailserver postqueue -p | head -5

echo "✅ Complete email testing finished!"
EOF

chmod +x test_complete_email.sh
```

## 🎯 **Quick Fix Commands**

### **Fix HELO and test local delivery:**

```bash
# Test local delivery with proper HELO
swaks --to markus@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 25 \
      --helo ferrylight.online \
      --body "Local delivery test with proper HELO"
```

### **Fix authentication and test:**

```bash
# Update password and test authentication
docker exec ferrylightv2-mailserver setup email update admin@ferrylight.online "ferrylight@Connexts@99" && \
swaks --to markus.van.kempen@gmail.com \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --helo ferrylight.online \
      --body "Authentication test with proper HELO"
```

### **Test container sendmail:**

```bash
# Send email directly from container
docker exec ferrylightv2-mailserver bash -c 'echo "Subject: Test from Container" | sendmail markus@ferrylight.online'
```

## 📝 **Expected Results**

### **After fixing HELO hostname:**

```bash
# Local delivery should work:
=== Trying mail.ferrylight.online:25...
=== Connected to mail.ferrylight.online.
<-  220 mail.ferrylight.online ESMTP
 -> EHLO ferrylight.online
<-  250-mail.ferrylight.online
<-  250-PIPELINING
<-  250-SIZE 10240000
<-  250-ETRN
<-  250-ENHANCEDSTATUSCODES
<-  250-8BITMIME
<-  250 CHUNKING
 -> MAIL FROM:<admin@ferrylight.online>
<-  250 2.1.0 Ok
 -> RCPT TO:<markus@ferrylight.online>
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

### **Issue 1: HELO hostname rejected**
**Solution:** Use `--helo ferrylight.online` instead of default

### **Issue 2: Authentication still failing**
**Solution:** Try container sendmail or update user password

### **Issue 3: Local delivery works but external doesn't**
**Solution:** Check DNS records and external mail server configuration

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 