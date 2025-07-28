# Spam Deliverability Fix - FerryLightV2

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 📧 **Fix Spam Deliverability Issues**

### **Current Status:**
- ✅ **Authentication:** Working perfectly
- ✅ **Email Delivery:** Successfully reaching Gmail
- ⚠️ **Deliverability:** Going to spam folder

### **Root Cause:**
New mail servers often go to spam due to:
1. **Missing or incomplete DNS records** (SPF, DKIM, DMARC)
2. **No PTR record** (reverse DNS)
3. **New IP reputation** (server IP not trusted yet)
4. **Missing or incorrect email headers**
5. **Content filtering** (spam keywords, formatting)

## 🔧 **Step-by-Step Fix**

### **Step 1: Set Up Complete DNS Records**

**In Namecheap DNS settings, add these records:**

#### **1. MX Record:**
```
Type: MX
Host: @ (or leave blank)
Value: mail.ferrylight.online
Priority: 10
TTL: 300
```

#### **2. SPF Record:**
```
Type: TXT
Host: @ (or leave blank)
Value: "v=spf1 mx a ip4:209.209.43.250 ~all"
TTL: 300
```

#### **3. DMARC Record:**
```
Type: TXT
Host: _dmarc
Value: "v=DMARC1; p=quarantine; rua=mailto:dmarc@ferrylight.online; ruf=mailto:dmarc@ferrylight.online;"
TTL: 300
```

#### **4. DKIM Record:**
```bash
# Generate DKIM key first
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain ferrylight.online selector mail

# Then add the TXT record with the generated key
Type: TXT
Host: mail._domainkey
Value: "v=DKIM1; k=rsa; p=YOUR_GENERATED_DKIM_KEY"
TTL: 300
```

### **Step 2: Request PTR Record from Hosting Provider**

**Contact your hosting provider (Vultr) to set:**
```
PTR Record: 209.209.43.250 → mail.ferrylight.online
```

**Email template:**
```
Subject: PTR Record Request for IP 209.209.43.250

Hello,

I need to set up a PTR (reverse DNS) record for my mail server:

IP Address: 209.209.43.250
Hostname: mail.ferrylight.online

This is required for proper email deliverability and to prevent emails from going to spam.

Please set the PTR record:
209.209.43.250.in-addr.arpa. PTR mail.ferrylight.online.

Thank you,
Markus van Kempen
```

### **Step 3: Improve Email Headers**

**Update mail server configuration for better headers:**

```bash
# Edit dms.conf to add proper headers
cat >> /opt/ferrylightv2/mailserver/config/dms.conf << 'EOF'

# Improve email headers for better deliverability
ENABLE_HEADER_CHECKS=1
HEADER_CHECKS=regexp:/tmp/docker-mailserver/header_checks.pcre

# Add proper message size limits
POSTFIX_MESSAGE_SIZE_LIMIT=10485760

# Improve TLS settings
ENABLE_TLS=1
TLS_LEVEL=intermediate
SSL_TYPE=letsencrypt
SSL_DOMAIN=mail.ferrylight.online

# Add proper authentication
ENABLE_SASLAUTHD=1
SASLAUTHD_MECHANISMS=pam
EOF
```

### **Step 4: Create Header Checks File**

```bash
# Create header checks for better email formatting
cat > /opt/ferrylightv2/mailserver/config/header_checks.pcre << 'EOF'
# Add proper headers for better deliverability
/^From:/ REPLACE From: FerryLightV2 <admin@ferrylight.online>
/^Message-ID:/ REPLACE Message-ID: <${message_id}@ferrylight.online>
/^X-Mailer:/ REPLACE X-Mailer: FerryLightV2 Mail Server
/^X-Priority:/ REPLACE X-Priority: 3
/^X-MSMail-Priority:/ REPLACE X-MSMail-Priority: Normal
EOF
```

### **Step 5: Restart Mail Server**

```bash
# Restart mail server to apply changes
docker-compose restart mailserver

# Wait for restart
sleep 30

# Check if mail server is running
docker-compose ps mailserver
```

## 🔍 **DNS Verification Commands**

### **Check DNS Records:**

```bash
# Check MX record
dig ferrylight.online MX

# Check SPF record
dig ferrylight.online TXT | grep spf

# Check DMARC record
dig _dmarc.ferrylight.online TXT

# Check DKIM record
dig mail._domainkey.ferrylight.online TXT

# Check PTR record
dig -x 209.209.43.250
```

### **Expected Results:**

```bash
# MX Record should show:
ferrylight.online. MX 10 mail.ferrylight.online.

# SPF Record should show:
ferrylight.online. TXT "v=spf1 mx a ip4:209.209.43.250 ~all"

# DMARC Record should show:
_dmarc.ferrylight.online. TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc@ferrylight.online;"

# PTR Record should show:
209.209.43.250.in-addr.arpa. PTR mail.ferrylight.online.
```

## 📊 **Email Content Best Practices**

### **Good Email Content:**

```bash
# Test with proper email content
swaks --to markus.van.kempen@gmail.com \
      --from "FerryLightV2 <admin@ferrylight.online>" \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --helo ferrylight.online \
      --header "Subject: FerryLightV2 System Notification" \
      --header "X-Priority: 3" \
      --header "X-MSMail-Priority: Normal" \
      --body "This is a test email from the FerryLightV2 system.

Best regards,
FerryLightV2 Mail Server
mail.ferrylight.online"
```

### **Avoid Spam Keywords:**

❌ **Avoid these words in subject/body:**
- Free, Free!, FREE
- Act now, Limited time
- Buy now, Click here
- Make money, Earn money
- Guaranteed, Promise
- No risk, No obligation
- Special offer, Limited offer

✅ **Use professional language:**
- System notification
- Status update
- Configuration change
- Test message
- Alert, Warning, Info

## 🎯 **Reputation Building**

### **Step 1: Send Regular Test Emails**

```bash
# Send daily test emails to build reputation
cat > /opt/ferrylightv2/test_email_daily.sh << 'EOF'
#!/bin/bash
# Daily email test script
# Author: Markus van Kempen
# Date: July 24, 2025

swaks --to markus.van.kempen@gmail.com \
      --from "FerryLightV2 <admin@ferrylight.online>" \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --helo ferrylight.online \
      --header "Subject: FerryLightV2 Daily Status Check" \
      --body "FerryLightV2 system is running normally.

Date: $(date)
Server: ferrylight.online
Status: Online

Best regards,
FerryLightV2 System"
EOF

chmod +x /opt/ferrylightv2/test_email_daily.sh
```

### **Step 2: Mark as Not Spam**

**In Gmail:**
1. Open the email from spam folder
2. Click "Not spam" button
3. Move to inbox
4. Add `admin@ferrylight.online` to contacts

### **Step 3: Create Gmail Filter**

**In Gmail settings:**
1. Go to Settings → Filters and Blocked Addresses
2. Create new filter
3. From: `admin@ferrylight.online`
4. Never send it to Spam
5. Always mark it as important

## 🔧 **Alternative Solutions**

### **Solution 1: Use External SMTP Relay**

```bash
# Configure Gmail SMTP relay for better deliverability
# Add to docker-compose.yml environment:
- RELAY_HOST=smtp.gmail.com
- RELAY_PORT=587
- RELAY_USER=your-email@gmail.com
- RELAY_PASSWORD=your-app-password
- RELAY_TLS=yes
```

### **Solution 2: Use Professional Email Service**

Consider using services like:
- **SendGrid** (free tier available)
- **Mailgun** (free tier available)
- **Amazon SES** (very cheap)

### **Solution 3: Warm Up IP Address**

**Gradual email volume increase:**
- Day 1-7: 10 emails/day
- Day 8-14: 50 emails/day
- Day 15-30: 100 emails/day
- Day 31+: Normal volume

## 📊 **Monitoring and Testing**

### **Check Email Reputation:**

```bash
# Check IP reputation
curl -s "https://api.senderbase.org/v2/query?ip=209.209.43.250"

# Check domain reputation
curl -s "https://api.senderbase.org/v2/query?domain=ferrylight.online"
```

### **Test Email Deliverability:**

```bash
# Test with different providers
swaks --to your-email@outlook.com \
      --from "FerryLightV2 <admin@ferrylight.online>" \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --helo ferrylight.online \
      --header "Subject: FerryLightV2 Test to Outlook" \
      --body "Testing deliverability to Outlook."
```

## 🎯 **Quick Fix Script**

### **Create comprehensive fix script:**

```bash
cat > fix_spam_deliverability.sh << 'EOF'
#!/bin/bash
# FerryLightV2 Spam Deliverability Fix Script
# Author: Markus van Kempen
# Date: July 24, 2025

set -e

echo "🔧 Fixing Spam Deliverability Issues..."

# Configuration
DOMAIN="ferrylight.online"
MAIL_SERVER="mail.ferrylight.online"
SERVER_IP="209.209.43.250"

echo "📋 Step 1: Checking current DNS records..."
echo "MX Record:"
dig $DOMAIN MX +short

echo "SPF Record:"
dig $DOMAIN TXT +short | grep spf || echo "❌ SPF record missing"

echo "DMARC Record:"
dig _dmarc.$DOMAIN TXT +short || echo "❌ DMARC record missing"

echo "PTR Record:"
dig -x $SERVER_IP +short || echo "❌ PTR record missing"

echo "📧 Step 2: Generating DKIM key..."
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain $DOMAIN selector mail

echo "📄 Step 3: Updating mail server configuration..."
# Add header checks
cat >> /opt/ferrylightv2/mailserver/config/dms.conf << 'DMS_EOF'

# Improve email headers for better deliverability
ENABLE_HEADER_CHECKS=1
HEADER_CHECKS=regexp:/tmp/docker-mailserver/header_checks.pcre
POSTFIX_MESSAGE_SIZE_LIMIT=10485760
ENABLE_TLS=1
TLS_LEVEL=intermediate
SSL_TYPE=letsencrypt
SSL_DOMAIN=mail.ferrylight.online
ENABLE_SASLAUTHD=1
SASLAUTHD_MECHANISMS=pam
DMS_EOF

echo "🔄 Step 4: Restarting mail server..."
docker-compose restart mailserver

echo "⏳ Waiting for restart..."
sleep 30

echo "✅ Step 5: Testing email delivery..."
swaks --to markus.van.kempen@gmail.com \
      --from "FerryLightV2 <admin@ferrylight.online>" \
      --server $MAIL_SERVER \
      --port 587 \
      --auth-user admin@$DOMAIN \
      --auth-password "ferrylight@Connexts@99" \
      --helo $DOMAIN \
      --header "Subject: FerryLightV2 Deliverability Test" \
      --body "Testing improved email deliverability.

Date: $(date)
Server: $DOMAIN

Best regards,
FerryLightV2 System"

echo "✅ Spam deliverability fix completed!"
echo "📝 Next steps:"
echo "1. Set up DNS records in Namecheap"
echo "2. Contact hosting provider for PTR record"
echo "3. Mark emails as 'Not spam' in Gmail"
echo "4. Add admin@$DOMAIN to Gmail contacts"
echo "5. Create Gmail filter to never send to spam"
EOF

chmod +x fix_spam_deliverability.sh
```

## 📝 **Expected Timeline**

### **Immediate (0-24 hours):**
- Set up DNS records
- Request PTR record
- Mark emails as "Not spam"

### **Short term (1-7 days):**
- Send regular test emails
- Monitor spam folder
- Build Gmail reputation

### **Medium term (1-4 weeks):**
- IP reputation improves
- Emails start going to inbox
- Reduce spam folder placement

## 🚨 **Next Steps**

1. **Set up DNS records** in Namecheap (MX, SPF, DMARC, DKIM)
2. **Contact Vultr** for PTR record
3. **Mark emails as "Not spam"** in Gmail
4. **Add to Gmail contacts**
5. **Create Gmail filter**
6. **Send regular test emails**

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 