# CLI Email Testing Guide - FerryLightV2

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 📧 **CLI Email Testing Methods**

### **1. 🐳 Using Docker Mail Server Container**

**Send email from within the mail server container:**
```bash
# Connect to mail server container
docker exec -it ferrylightv2-mailserver bash

# Send test email using sendmail
echo "Subject: Test Email from CLI" | sendmail markus@ferrylight.online

# Or using a more complete email
cat << EOF | sendmail markus@ferrylight.online
From: admin@ferrylight.online
To: markus@ferrylight.online
Subject: Test Email from FerryLightV2 Mail Server
Content-Type: text/plain

This is a test email sent from the CLI.
Date: $(date)
Server: ferrylightv2-mailserver
Domain: ferrylight.online
EOF
```

### **2. 🔧 Using External SMTP Client (swaks)**

**Install swaks (Swiss Army Knife for SMTP):**
```bash
# On Ubuntu/Debian
sudo apt-get install swaks

# On macOS
brew install swaks

# On CentOS/RHEL
sudo yum install swaks
```

**Send test email via SMTP:**
```bash
# Basic test email
swaks --to markus@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --tls \
      --body "This is a test email from CLI"

# More detailed test email
swaks --to markus@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --tls \
      --header "Subject: Test Email from CLI - $(date)" \
      --body "This is a test email sent from the command line.
      
Server: ferrylightv2-mailserver
Date: $(date)
Domain: ferrylight.online
Status: Testing SMTP functionality"
```

### **3. 📨 Using netcat (nc) for Raw SMTP**

**Send raw SMTP commands:**
```bash
# Connect to SMTP server
nc mail.ferrylight.online 25

# Then type these commands:
EHLO ferrylight.online
MAIL FROM: admin@ferrylight.online
RCPT TO: markus@ferrylight.online
DATA
Subject: Test Email from CLI
From: admin@ferrylight.online
To: markus@ferrylight.online

This is a test email sent via raw SMTP.
.
QUIT
```

### **4. 🐍 Using Python Script**

**Create a test email script:**
```bash
cat > test_email.py << 'EOF'
#!/usr/bin/env python3
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import datetime

# Email configuration
smtp_server = "mail.ferrylight.online"
smtp_port = 587
sender_email = "admin@ferrylight.online"
sender_password = "ferrylight@Connexts@99"
recipient_email = "markus@ferrylight.online"

# Create message
msg = MIMEMultipart()
msg['From'] = sender_email
msg['To'] = recipient_email
msg['Subject'] = f"Test Email from CLI - {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"

# Email body
body = f"""
This is a test email sent from the CLI using Python.

Server: ferrylightv2-mailserver
Domain: ferrylight.online
Date: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Status: Testing SMTP functionality

Best regards,
FerryLightV2 Mail Server
"""

msg.attach(MIMEText(body, 'plain'))

# Send email
try:
    server = smtplib.SMTP(smtp_server, smtp_port)
    server.starttls()
    server.login(sender_email, sender_password)
    text = msg.as_string()
    server.sendmail(sender_email, recipient_email, text)
    server.quit()
    print("✅ Test email sent successfully!")
except Exception as e:
    print(f"❌ Error sending email: {e}")
EOF

# Make executable and run
chmod +x test_email.py
python3 test_email.py
```

### **5. 🔍 Using curl for HTTP API (if available)**

**If your mail server has HTTP API enabled:**
```bash
# Send email via HTTP API
curl -X POST http://mail.ferrylight.online/api/v1/send \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ferrylight-api-key-2024" \
  -d '{
    "from": "admin@ferrylight.online",
    "to": "markus@ferrylight.online",
    "subject": "Test Email from CLI",
    "body": "This is a test email sent via HTTP API."
  }'
```

### **6. 📋 Quick Test Commands**

**One-liner test using sendmail:**
```bash
# Quick test from container
docker exec ferrylightv2-mailserver bash -c 'echo "Subject: Quick Test" | sendmail markus@ferrylight.online'
```

**Test with swaks (if installed):**
```bash
# Quick swaks test
swaks --to markus@ferrylight.online --from admin@ferrylight.online --server mail.ferrylight.online --port 587 --auth-user admin@ferrylight.online --auth-password "ferrylight@Connexts@99" --tls --body "Quick test email"
```

## 🔍 **Verification Commands**

### **Check if email was received:**
```bash
# Check mail logs
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log

# Check specific user's mailbox
docker exec ferrylightv2-mailserver doveadm quota get markus@ferrylight.online

# List recent emails (if using IMAP)
docker exec ferrylightv2-mailserver doveadm fetch -u markus@ferrylight.online "uid all"
```

### **Test SMTP connection:**
```bash
# Test SMTP port
telnet mail.ferrylight.online 25

# Test SMTP with STARTTLS
telnet mail.ferrylight.online 587
```

## 🚨 **Troubleshooting**

### **Common Issues:**

**Authentication failed:**
```bash
# Check if user exists
docker exec ferrylightv2-mailserver setup email list

# Add user if needed
docker exec ferrylightv2-mailserver setup email add markus@ferrylight.online "secure_password"
```

**Connection refused:**
```bash
# Check if mail server is running
docker-compose ps mailserver

# Check port status
netstat -tlnp | grep :25
netstat -tlnp | grep :587
```

**SSL/TLS issues:**
```bash
# Test SSL connection
openssl s_client -connect mail.ferrylight.online:587 -starttls smtp
```

## 📝 **Recommended Approach**

For FerryLightV2 setup, use **swaks** as it's the most reliable and feature-rich CLI email testing tool:

```bash
# Install swaks
sudo apt-get install swaks

# Send test email
swaks --to markus@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --tls \
      --body "Test email from FerryLightV2 CLI"
```

## 🔧 **Advanced Testing Scripts**

### **Comprehensive Test Script:**
```bash
cat > test_mail_server.sh << 'EOF'
#!/bin/bash
# FerryLightV2 Mail Server Test Script
# Author: Markus van Kempen
# Date: July 24, 2025

set -e

echo "🧪 Testing FerryLightV2 Mail Server..."

# Configuration
DOMAIN="ferrylight.online"
MAIL_SERVER="mail.ferrylight.online"
ADMIN_EMAIL="admin@ferrylight.online"
ADMIN_PASSWORD="ferrylight@Connexts@99"
TEST_EMAIL="markus@ferrylight.online"

echo "📧 Testing SMTP connection..."
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

echo "🔐 Testing authentication..."
if swaks --to $TEST_EMAIL \
         --from $ADMIN_EMAIL \
         --server $MAIL_SERVER \
         --port 587 \
         --auth-user $ADMIN_EMAIL \
         --auth-password "$ADMIN_PASSWORD" \
         --tls \
         --body "Test email from FerryLightV2" \
         --quit-after AUTH; then
    echo "✅ Authentication successful"
else
    echo "❌ Authentication failed"
fi

echo "📨 Sending test email..."
if swaks --to $TEST_EMAIL \
         --from $ADMIN_EMAIL \
         --server $MAIL_SERVER \
         --port 587 \
         --auth-user $ADMIN_EMAIL \
         --auth-password "$ADMIN_PASSWORD" \
         --tls \
         --body "Test email from FerryLightV2 CLI - $(date)"; then
    echo "✅ Test email sent successfully"
else
    echo "❌ Failed to send test email"
fi

echo "📊 Checking mail server status..."
docker-compose ps mailserver

echo "📋 Listing mail users..."
docker exec ferrylightv2-mailserver setup email list

echo "✅ Mail server testing completed!"
EOF

chmod +x test_mail_server.sh
```

### **Batch Email Testing:**
```bash
cat > batch_email_test.sh << 'EOF'
#!/bin/bash
# FerryLightV2 Batch Email Test Script
# Author: Markus van Kempen
# Date: July 24, 2025

set -e

echo "📧 Batch Email Testing for FerryLightV2..."

# Configuration
MAIL_SERVER="mail.ferrylight.online"
ADMIN_EMAIL="admin@ferrylight.online"
ADMIN_PASSWORD="ferrylight@Connexts@99"
RECIPIENTS=("markus@ferrylight.online" "admin@ferrylight.online")

for recipient in "${RECIPIENTS[@]}"; do
    echo "📨 Sending test email to $recipient..."
    
    swaks --to "$recipient" \
          --from "$ADMIN_EMAIL" \
          --server "$MAIL_SERVER" \
          --port 587 \
          --auth-user "$ADMIN_EMAIL" \
          --auth-password "$ADMIN_PASSWORD" \
          --tls \
          --header "Subject: Batch Test Email - $(date)" \
          --body "This is a batch test email sent to $recipient at $(date)"
    
    echo "✅ Email sent to $recipient"
    sleep 2
done

echo "✅ Batch email testing completed!"
EOF

chmod +x batch_email_test.sh
```

## 📊 **Monitoring and Logs**

### **Real-time Log Monitoring:**
```bash
# Monitor mail logs in real-time
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log

# Monitor specific log files
docker exec ferrylightv2-mailserver tail -f /var/log/mail/clamav.log
docker exec ferrylightv2-mailserver tail -f /var/log/mail/spamassassin.log
```

### **Email Statistics:**
```bash
# Check email statistics
docker exec ferrylightv2-mailserver setup config dkim
docker exec ferrylightv2-mailserver setup config ssl

# Check user quotas
docker exec ferrylightv2-mailserver doveadm quota get -A
```

## 🎯 **Quick Reference Commands**

### **Essential Commands:**
```bash
# Test SMTP connection
telnet mail.ferrylight.online 25

# Send quick test email
docker exec ferrylightv2-mailserver bash -c 'echo "Subject: Quick Test" | sendmail markus@ferrylight.online'

# Check mail server status
docker-compose ps mailserver

# View recent logs
docker-compose logs --tail=50 mailserver

# List mail users
docker exec ferrylightv2-mailserver setup email list
```

### **Troubleshooting Commands:**
```bash
# Check if ports are open
netstat -tlnp | grep :25
netstat -tlnp | grep :587

# Test SSL connection
openssl s_client -connect mail.ferrylight.online:587 -starttls smtp

# Check DNS resolution
nslookup mail.ferrylight.online
dig mail.ferrylight.online
```

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 