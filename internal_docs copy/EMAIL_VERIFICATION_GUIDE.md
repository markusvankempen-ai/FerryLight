# Email Verification and Testing Guide - FerryLightV2

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 📧 **Email Testing and Verification Methods**

### **Domain Information:**
- **Domain:** `ferrylight.online`
- **Mail Server:** `mail.ferrylight.online`
- **Admin Email:** `admin@ferrylight.online`
- **Admin Password:** `ferrylight@Connexts@99`
- **Test Email:** `markus@ferrylight.online`

## 🔧 **Method 1: Send Test Email with swaks**

### **Install swaks (if not installed):**
```bash
# On Ubuntu/Debian
sudo apt-get install swaks

# On macOS
brew install swaks
```

### **Send Test Email:**
```bash
# Basic test email
swaks --to markus@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --tls \
      --body "Test email from FerryLightV2 - $(date)"

# Detailed test email
swaks --to markus@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --tls \
      --header "Subject: FerryLightV2 Email Test - $(date)" \
      --body "This is a test email sent from the FerryLightV2 mail server.

Server: ferrylightv2-mailserver
Domain: ferrylight.online
Date: $(date)
Status: Testing email functionality

Best regards,
FerryLightV2 Mail Server"
```

## 🐳 **Method 2: Send Email from Docker Container**

### **Using sendmail from container:**
```bash
# Quick test email
docker exec ferrylightv2-mailserver bash -c 'echo "Subject: Test Email from Container" | sendmail markus@ferrylight.online'

# Detailed test email
docker exec ferrylightv2-mailserver bash -c 'cat << EOF | sendmail markus@ferrylight.online
From: admin@ferrylight.online
To: markus@ferrylight.online
Subject: Test Email from Docker Container
Content-Type: text/plain

This is a test email sent from the Docker container.
Date: $(date)
Container: ferrylightv2-mailserver
EOF'
```

## 🔍 **Method 3: Check Email Logs**

### **Monitor mail server logs in real-time:**
```bash
# View all mail logs
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log

# View specific log files
docker exec ferrylightv2-mailserver tail -f /var/log/mail/clamav.log
docker exec ferrylightv2-mailserver tail -f /var/log/mail/spamassassin.log

# View recent logs
docker-compose logs --tail=50 mailserver
```

### **Search for specific email activity:**
```bash
# Search for sent emails
docker exec ferrylightv2-mailserver grep -i "sent" /var/log/mail/mail.log

# Search for specific email address
docker exec ferrylightv2-mailserver grep -i "markus@ferrylight.online" /var/log/mail/mail.log

# Search for SMTP activity
docker exec ferrylightv2-mailserver grep -i "smtp" /var/log/mail/mail.log
```

## 📊 **Method 4: Check Email Queue and Status**

### **Check mail queue:**
```bash
# Check if emails are in queue
docker exec ferrylightv2-mailserver postqueue -p

# Check mail queue size
docker exec ferrylightv2-mailserver postqueue -p | wc -l

# Flush mail queue (if needed)
docker exec ferrylightv2-mailserver postqueue -f
```

### **Check mail server status:**
```bash
# Check if mail server is running
docker-compose ps mailserver

# Check mail server processes
docker exec ferrylightv2-mailserver ps aux | grep -E "(postfix|dovecot|opendkim)"

# Check mail server configuration
docker exec ferrylightv2-mailserver setup config
```

## 🌐 **Method 5: Test External Email Delivery**

### **Send email to external provider (Gmail, Outlook, etc.):**
```bash
# Send to Gmail
swaks --to your-email@gmail.com \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --tls \
      --body "Test email from FerryLightV2 to external provider"

# Send to Outlook
swaks --to your-email@outlook.com \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --tls \
      --body "Test email from FerryLightV2 to external provider"
```

## 🔧 **Method 6: Test SMTP Connection**

### **Test SMTP ports:**
```bash
# Test SMTP port 25
telnet mail.ferrylight.online 25

# Test SMTP submission port 587
telnet mail.ferrylight.online 587

# Test SSL SMTP port 465
telnet mail.ferrylight.online 465
```

### **Test SMTP with SSL:**
```bash
# Test SSL connection
openssl s_client -connect mail.ferrylight.online:587 -starttls smtp

# Test SSL SMTP
openssl s_client -connect mail.ferrylight.online:465
```

## 📋 **Method 7: Check Email Reception**

### **Check if emails were received:**
```bash
# Check user's mailbox
docker exec ferrylightv2-mailserver doveadm quota get markus@ferrylight.online

# List recent emails (if using IMAP)
docker exec ferrylightv2-mailserver doveadm fetch -u markus@ferrylight.online "uid all"

# Check mail directory
docker exec ferrylightv2-mailserver ls -la /var/mail/ferrylight.online/markus/
```

## 🧪 **Method 8: Comprehensive Testing Script**

### **Create comprehensive test script:**
```bash
cat > test_email_comprehensive.sh << 'EOF'
#!/bin/bash
# FerryLightV2 Comprehensive Email Testing Script
# Author: Markus van Kempen
# Date: July 24, 2025

set -e

echo "🧪 Comprehensive Email Testing for FerryLightV2..."

# Configuration
DOMAIN="ferrylight.online"
MAIL_SERVER="mail.ferrylight.online"
ADMIN_EMAIL="admin@ferrylight.online"
ADMIN_PASSWORD="ferrylight@Connexts@99"
TEST_EMAIL="markus@ferrylight.online"

echo "📧 Step 1: Testing SMTP connection..."
if nc -z $MAIL_SERVER 25; then
    echo "✅ SMTP port 25 is open"
else
    echo "❌ SMTP port 25 is closed"
fi

if nc -z $MAIL_SERVER 587; then
    echo "✅ SMTP submission port 587 is open"
else
    echo "❌ SMTP submission port 587 is closed"
fi

echo "🔐 Step 2: Testing authentication..."
if swaks --to $TEST_EMAIL \
         --from $ADMIN_EMAIL \
         --server $MAIL_SERVER \
         --port 587 \
         --auth-user $ADMIN_EMAIL \
         --auth-password "$ADMIN_PASSWORD" \
         --tls \
         --body "Authentication test" \
         --quit-after AUTH; then
    echo "✅ Authentication successful"
else
    echo "❌ Authentication failed"
fi

echo "📨 Step 3: Sending test email..."
if swaks --to $TEST_EMAIL \
         --from $ADMIN_EMAIL \
         --server $MAIL_SERVER \
         --port 587 \
         --auth-user $ADMIN_EMAIL \
         --auth-password "$ADMIN_PASSWORD" \
         --tls \
         --body "Comprehensive test email from FerryLightV2 - $(date)"; then
    echo "✅ Test email sent successfully"
else
    echo "❌ Failed to send test email"
fi

echo "📊 Step 4: Checking mail server status..."
docker-compose ps mailserver

echo "📋 Step 5: Checking mail queue..."
docker exec ferrylightv2-mailserver postqueue -p | head -10

echo "📄 Step 6: Checking recent logs..."
docker-compose logs --tail=20 mailserver | grep -E "(sent|delivered|error)"

echo "✅ Comprehensive email testing completed!"
EOF

chmod +x test_email_comprehensive.sh
```

## 🚨 **Troubleshooting Email Issues**

### **Common Issues and Solutions:**

**1. Authentication Failed:**
```bash
# Check if user exists
docker exec ferrylightv2-mailserver setup email list

# Add user if needed
docker exec ferrylightv2-mailserver setup email add markus@ferrylight.online "secure_password"
```

**2. Connection Refused:**
```bash
# Check if mail server is running
docker-compose ps mailserver

# Check port status
netstat -tlnp | grep :25
netstat -tlnp | grep :587

# Restart mail server if needed
docker-compose restart mailserver
```

**3. SSL/TLS Issues:**
```bash
# Test SSL connection
openssl s_client -connect mail.ferrylight.online:587 -starttls smtp

# Check SSL certificates
docker exec ferrylightv2-mailserver setup config ssl
```

**4. DNS Issues:**
```bash
# Check DNS resolution
nslookup mail.ferrylight.online
dig mail.ferrylight.online

# Check MX record
dig ferrylight.online MX

# Check SPF record
dig ferrylight.online TXT | grep spf
```

## 📊 **Email Statistics and Monitoring**

### **Check email statistics:**
```bash
# Check mail server statistics
docker exec ferrylightv2-mailserver setup config

# Check user quotas
docker exec ferrylightv2-mailserver doveadm quota get -A

# Check mail server performance
docker exec ferrylightv2-mailserver top
```

### **Monitor email activity:**
```bash
# Real-time monitoring
watch -n 5 'docker exec ferrylightv2-mailserver postqueue -p | wc -l'

# Monitor logs in real-time
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log | grep -E "(sent|delivered|error|reject)"
```

## 🎯 **Quick Verification Commands**

### **Essential verification commands:**
```bash
# Quick email test
swaks --to markus@ferrylight.online --from admin@ferrylight.online --server mail.ferrylight.online --port 587 --auth-user admin@ferrylight.online --auth-password "ferrylight@Connexts@99" --tls --body "Quick test"

# Check mail server status
docker-compose ps mailserver

# View recent logs
docker-compose logs --tail=20 mailserver

# Check mail queue
docker exec ferrylightv2-mailserver postqueue -p

# Test SMTP connection
telnet mail.ferrylight.online 587
```

## 📝 **Expected Results**

### **Successful email sending should show:**
- ✅ SMTP connection established
- ✅ Authentication successful
- ✅ Email accepted for delivery
- ✅ Email appears in mail queue
- ✅ Email delivered to recipient
- ✅ No errors in mail logs

### **Check for these in logs:**
- `status=sent` - Email sent successfully
- `status=delivered` - Email delivered to recipient
- `relay=local` - Email delivered locally
- `dsn=2.0.0` - Successful delivery status

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 