# External Email Delivery Fix - FerryLightV2

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 📧 **Fix External Email Delivery Issues**

### **Current Status:**
- ✅ **Authentication:** Working perfectly
- ✅ **Local SMTP:** Email queued successfully (`250 2.0.0 Ok: queued as D7A00E19E7`)
- ❌ **External Delivery:** Email not reaching Gmail

### **Root Cause:**
External email delivery issues are typically caused by:
1. **Missing DNS records** (MX, SPF, DKIM, DMARC)
2. **PTR record** not set by hosting provider
3. **Port 25 blocked** by ISP
4. **DNS propagation** delays

## 🔧 **Step-by-Step Fix**

### **Step 1: Check DNS Records**

```bash
# Check if DNS records are properly set
dig ferrylight.online MX
dig ferrylight.online TXT | grep spf
dig _dmarc.ferrylight.online TXT
dig mail._domainkey.ferrylight.online TXT

# Check if mail server resolves
dig mail.ferrylight.online A
nslookup mail.ferrylight.online
```

### **Step 2: Check Mail Server Logs**

```bash
# Check if email was processed
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log | grep -i "D7A00E19E7"

# Check for delivery attempts
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log | grep -i "gmail"

# Check for DNS resolution issues
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log | grep -i "dns"

# Check for connection issues
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log | grep -i "connect"
```

### **Step 3: Check Mail Queue**

```bash
# Check if email is still in queue
docker exec ferrylightv2-mailserver postqueue -p

# Check queue size
docker exec ferrylightv2-mailserver postqueue -p | wc -l

# Check specific email status
docker exec ferrylightv2-mailserver postcat -q D7A00E19E7
```

### **Step 4: Test Local Delivery First**

```bash
# Test sending to local user first
swaks --to markus@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 25 \
      --helo ferrylight.online \
      --body "Local delivery test - $(date)"
```

## 🔍 **DNS Configuration Check**

### **Required DNS Records:**

**1. MX Record:**
```bash
dig ferrylight.online MX
# Should show: ferrylight.online. MX 10 mail.ferrylight.online.
```

**2. SPF Record:**
```bash
dig ferrylight.online TXT | grep spf
# Should show: "v=spf1 mx a ip4:209.209.43.250 ~all"
```

**3. DMARC Record:**
```bash
dig _dmarc.ferrylight.online TXT
# Should show: "v=DMARC1; p=quarantine; rua=mailto:dmarc@ferrylight.online;"
```

**4. DKIM Record:**
```bash
dig mail._domainkey.ferrylight.online TXT
# Should show: "v=DKIM1; k=rsa; p=YOUR_DKIM_KEY"
```

### **PTR Record (Reverse DNS):**
```bash
# Check PTR record (set by hosting provider)
dig -x 209.209.43.250
# Should show: 209.209.43.250.in-addr.arpa. PTR mail.ferrylight.online.
```

## 🚨 **Common External Delivery Issues**

### **Issue 1: Port 25 Blocked by ISP**

```bash
# Test if port 25 is accessible from outside
telnet gmail-smtp-in.l.google.com 25

# If blocked, use port 587 with authentication
swaks --to markus.van.kempen@gmail.com \
      --from admin@ferrylight.online \
      --server gmail-smtp-in.l.google.com \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --tls \
      --body "Test via Gmail relay"
```

### **Issue 2: Missing PTR Record**

**Contact your hosting provider to set:**
```
PTR Record: 209.209.43.250 → mail.ferrylight.online
```

### **Issue 3: DNS Propagation Delay**

```bash
# Check DNS propagation
nslookup ferrylight.online 8.8.8.8
nslookup ferrylight.online 1.1.1.1
nslookup ferrylight.online 208.67.222.222
```

## 🔧 **Alternative Solutions**

### **Solution 1: Use External SMTP Relay**

```bash
# Configure external SMTP relay in mail server
# Add to docker-compose.yml environment:
- RELAY_HOST=smtp.gmail.com
- RELAY_PORT=587
- RELAY_USER=your-email@gmail.com
- RELAY_PASSWORD=your-app-password
```

### **Solution 2: Test with Different External Provider**

```bash
# Test with Outlook
swaks --to your-email@outlook.com \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --helo ferrylight.online \
      --body "Test to Outlook - $(date)"
```

### **Solution 3: Check Gmail Spam Folder**

The email might be in your Gmail spam folder. Check:
1. Gmail Spam folder
2. Gmail All Mail folder
3. Gmail filters

## 📊 **Diagnostic Commands**

### **Check Mail Server Status:**

```bash
# Check if mail server is running
docker-compose ps mailserver

# Check mail server configuration
docker exec ferrylightv2-mailserver setup config

# Check SSL certificates
docker exec ferrylightv2-mailserver setup config ssl
```

### **Check Network Connectivity:**

```bash
# Test connectivity to Gmail
telnet gmail-smtp-in.l.google.com 25

# Test DNS resolution
nslookup gmail-smtp-in.l.google.com

# Test port 25 from server
nc -zv gmail-smtp-in.l.google.com 25
```

### **Check Mail Logs in Detail:**

```bash
# Monitor all mail activity
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log

# Search for specific email ID
docker exec ferrylightv2-mailserver grep -i "D7A00E19E7" /var/log/mail/mail.log

# Check for delivery attempts
docker exec ferrylightv2-mailserver grep -i "gmail" /var/log/mail/mail.log
```

## 🎯 **Quick Diagnostic Script**

### **Create diagnostic script:**

```bash
cat > diagnose_email_delivery.sh << 'EOF'
#!/bin/bash
# FerryLightV2 Email Delivery Diagnostic Script
# Author: Markus van Kempen
# Date: July 24, 2025

set -e

echo "🔍 Diagnosing Email Delivery Issues..."

# Configuration
DOMAIN="ferrylight.online"
MAIL_SERVER="mail.ferrylight.online"
SERVER_IP="209.209.43.250"

echo "📋 Step 1: Checking DNS records..."
echo "MX Record:"
dig $DOMAIN MX +short

echo "SPF Record:"
dig $DOMAIN TXT +short | grep spf

echo "DMARC Record:"
dig _dmarc.$DOMAIN TXT +short

echo "DKIM Record:"
dig mail._domainkey.$DOMAIN TXT +short

echo "PTR Record:"
dig -x $SERVER_IP +short

echo "📧 Step 2: Checking mail server status..."
docker-compose ps mailserver

echo "📊 Step 3: Checking mail queue..."
docker exec ferrylightv2-mailserver postqueue -p | head -10

echo "📄 Step 4: Checking recent mail logs..."
docker exec ferrylightv2-mailserver tail -20 /var/log/mail/mail.log | grep -E "(sent|delivered|error|reject)"

echo "🌐 Step 5: Testing external connectivity..."
if nc -z gmail-smtp-in.l.google.com 25; then
    echo "✅ Port 25 to Gmail is open"
else
    echo "❌ Port 25 to Gmail is blocked"
fi

echo "✅ Email delivery diagnosis completed!"
EOF

chmod +x diagnose_email_delivery.sh
```

## 📝 **Expected Results**

### **After fixing DNS and connectivity:**

```bash
# Mail logs should show:
2025-07-25T23:23:04.712937+00:00 mail postfix/smtp[12345]: D7A00E19E7: to=<markus.van.kempen@gmail.com>, relay=gmail-smtp-in.l.google.com[142.250.185.26]:25, delay=1.2, delays=0.1/0.1/0.8/0.2, dsn=2.0.0, status=sent (250 2.0.0 OK 1234567890abcdef)
```

## 🚨 **Next Steps**

1. **Check DNS records** in Namecheap
2. **Contact hosting provider** for PTR record
3. **Check Gmail spam folder**
4. **Wait for DNS propagation** (up to 48 hours)
5. **Test with different external provider**

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 