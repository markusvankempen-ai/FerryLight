# DNS Setup Guide - FerryLightV2 Mail Server

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 🌐 **DNS Provider Setup for Mail Server**

### **Domain Information:**
- **Domain:** `ferrylight.online`
- **Server IP:** `209.209.43.250`
- **Mail Server:** `mail.ferrylight.online`
- **DNS Provider:** Namecheap (based on previous configuration)

## 📋 **Required DNS Records**

### **1. A Records**

**Main Domain:**
```
Type: A
Name: @
Value: 209.209.43.250
TTL: 300 (5 minutes)
```

**Mail Server:**
```
Type: A
Name: mail
Value: 209.209.43.250
TTL: 300 (5 minutes)
```

**Web Services:**
```
Type: A
Name: www
Value: 209.209.43.250
TTL: 300 (5 minutes)

Type: A
Name: portainer
Value: 209.209.43.250
TTL: 300 (5 minutes)

Type: A
Name: traefik
Value: 209.209.43.250
TTL: 300 (5 minutes)

Type: A
Name: nodered
Value: 209.209.43.250
TTL: 300 (5 minutes)

Type: A
Name: pgadmin
Value: 209.209.43.250
TTL: 300 (5 minutes)
```

### **2. MX Record (Mail Exchange)**

**Primary MX Record:**
```
Type: MX
Name: @
Value: mail.ferrylight.online
Priority: 10
TTL: 300 (5 minutes)
```

### **3. SPF Record (Sender Policy Framework)**

**SPF Record:**
```
Type: TXT
Name: @
Value: "v=spf1 mx a ip4:209.209.43.250 ~all"
TTL: 300 (5 minutes)
```

### **4. DKIM Record (DomainKeys Identified Mail)**

**DKIM Record (will be generated after mail server setup):**
```
Type: TXT
Name: mail._domainkey
Value: "v=DKIM1; k=rsa; p=YOUR_DKIM_PUBLIC_KEY"
TTL: 300 (5 minutes)
```

**To generate DKIM key:**
```bash
# Generate DKIM key
docker exec ferrylightv2-mailserver setup config dkim

# View the generated key
docker exec ferrylightv2-mailserver setup config dkim keysize 2048
```

### **5. DMARC Record (Domain-based Message Authentication)**

**DMARC Record:**
```
Type: TXT
Name: _dmarc
Value: "v=DMARC1; p=quarantine; rua=mailto:dmarc@ferrylight.online; ruf=mailto:dmarc@ferrylight.online; sp=quarantine; adkim=r; aspf=r;"
TTL: 300 (5 minutes)
```

### **6. PTR Record (Reverse DNS)**

**PTR Record (set by your hosting provider):**
```
Type: PTR
Name: 209.209.43.250
Value: mail.ferrylight.online
```

## 🔧 **Step-by-Step DNS Setup**

### **Step 1: Access Namecheap DNS Management**

1. Log into your Namecheap account
2. Go to **Domain List**
3. Click **Manage** next to `ferrylight.online`
4. Go to **Advanced DNS** tab

### **Step 2: Add A Records**

**Add these A records one by one:**

1. **Main Domain A Record:**
   - Type: `A Record`
   - Host: `@`
   - Value: `209.209.43.250`
   - TTL: `5 min`

2. **Mail Server A Record:**
   - Type: `A Record`
   - Host: `mail`
   - Value: `209.209.43.250`
   - TTL: `5 min`

3. **WWW A Record:**
   - Type: `A Record`
   - Host: `www`
   - Value: `209.209.43.250`
   - TTL: `5 min`

4. **Portainer A Record:**
   - Type: `A Record`
   - Host: `portainer`
   - Value: `209.209.43.250`
   - TTL: `5 min`

5. **Traefik A Record:**
   - Type: `A Record`
   - Host: `traefik`
   - Value: `209.209.43.250`
   - TTL: `5 min`

6. **Node-RED A Record:**
   - Type: `A Record`
   - Host: `nodered`
   - Value: `209.209.43.250`
   - TTL: `5 min`

7. **pgAdmin A Record:**
   - Type: `A Record`
   - Host: `pgadmin`
   - Value: `209.209.43.250`
   - TTL: `5 min`

### **Step 3: Add MX Record**

**Mail Exchange Record:**
- Type: `MX Record`
- Host: `@`
- Value: `mail.ferrylight.online`
- Priority: `10`
- TTL: `5 min`

### **Step 4: Add SPF Record**

**Sender Policy Framework:**
- Type: `TXT Record`
- Host: `@`
- Value: `"v=spf1 mx a ip4:209.209.43.250 ~all"`
- TTL: `5 min`

### **Step 5: Add DMARC Record**

**Domain-based Message Authentication:**
- Type: `TXT Record`
- Host: `_dmarc`
- Value: `"v=DMARC1; p=quarantine; rua=mailto:dmarc@ferrylight.online; ruf=mailto:dmarc@ferrylight.online; sp=quarantine; adkim=r; aspf=r;"`
- TTL: `5 min`

### **Step 6: Generate and Add DKIM Record**

**After mail server is running:**

1. **Generate DKIM key:**
```bash
cd /opt/ferrylightv2
docker exec ferrylightv2-mailserver setup config dkim
```

2. **View the generated key:**
```bash
docker exec ferrylightv2-mailserver setup config dkim keysize 2048
```

3. **Add DKIM TXT record:**
- Type: `TXT Record`
- Host: `mail._domainkey`
- Value: `"v=DKIM1; k=rsa; p=YOUR_GENERATED_DKIM_KEY"`
- TTL: `5 min`

## 🔍 **DNS Verification Commands**

### **Check DNS Propagation:**
```bash
# Check A records
dig ferrylight.online A
dig mail.ferrylight.online A
dig www.ferrylight.online A
dig portainer.ferrylight.online A

# Check MX record
dig ferrylight.online MX

# Check SPF record
dig ferrylight.online TXT

# Check DMARC record
dig _dmarc.ferrylight.online TXT

# Check DKIM record (after setup)
dig mail._domainkey.ferrylight.online TXT
```

### **Online DNS Checkers:**
- **MXToolbox:** https://mxtoolbox.com/
- **DNS Checker:** https://dnschecker.org/
- **What's My DNS:** https://www.whatsmydns.net/

## 🚨 **Common DNS Issues**

### **1. DNS Propagation Delay**
- DNS changes can take up to 48 hours to propagate globally
- Use `dig` or online tools to check propagation status
- TTL of 300 seconds (5 minutes) helps with faster updates

### **2. Incorrect PTR Record**
- Contact your hosting provider to set PTR record
- PTR should point `209.209.43.250` to `mail.ferrylight.online`
- Many mail servers reject emails without proper PTR

### **3. SPF Record Issues**
- Ensure SPF record includes your server IP
- Don't use `-all` (hard fail) initially, use `~all` (soft fail)
- Test SPF with: `dig ferrylight.online TXT | grep spf`

### **4. Missing DMARC Record**
- Some mail providers require DMARC for better deliverability
- Start with `p=quarantine` for monitoring
- Gradually move to `p=reject` after confirming everything works

## 📧 **Mail Server DNS Testing**

### **Test Email Deliverability:**
```bash
# Test with swaks
swaks --to test@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --tls \
      --body "DNS test email"
```

### **Check Mail Server Logs:**
```bash
# Monitor mail logs for DNS-related issues
docker exec ferrylightv2-mailserver tail -f /var/log/mail/mail.log | grep -i dns
```

## 🔧 **DNS Management Script**

### **Create DNS verification script:**
```bash
cat > check_dns.sh << 'EOF'
#!/bin/bash
# FerryLightV2 DNS Verification Script
# Author: Markus van Kempen
# Date: July 24, 2025

set -e

echo "🔍 Checking DNS records for ferrylight.online..."

DOMAIN="ferrylight.online"
MAIL_SERVER="mail.ferrylight.online"
SERVER_IP="209.209.43.250"

echo "📋 Checking A records..."
echo "Main domain:"
dig $DOMAIN A +short

echo "Mail server:"
dig $MAIL_SERVER A +short

echo "📧 Checking MX record..."
dig $DOMAIN MX +short

echo "🛡️ Checking SPF record..."
dig $DOMAIN TXT +short | grep spf

echo "🔐 Checking DMARC record..."
dig _dmarc.$DOMAIN TXT +short

echo "🔑 Checking DKIM record..."
dig mail._domainkey.$DOMAIN TXT +short

echo "✅ DNS verification completed!"
EOF

chmod +x check_dns.sh
```

## 📞 **DNS Provider Support**

### **Namecheap Support:**
- **Live Chat:** Available 24/7
- **Knowledge Base:** https://www.namecheap.com/support/
- **DNS Management Guide:** https://www.namecheap.com/support/knowledgebase/article.aspx/319/2237/

### **Common Namecheap Issues:**
1. **DNS propagation delay** - Can take up to 48 hours
2. **TTL settings** - Use 300 seconds for faster updates
3. **Record conflicts** - Remove conflicting records first
4. **Case sensitivity** - DNS records are case-insensitive

## 🎯 **Quick DNS Setup Checklist**

- [ ] A record for `@` pointing to `209.209.43.250`
- [ ] A record for `mail` pointing to `209.209.43.250`
- [ ] A record for `www` pointing to `209.209.43.250`
- [ ] A record for `portainer` pointing to `209.209.43.250`
- [ ] A record for `traefik` pointing to `209.209.43.250`
- [ ] A record for `nodered` pointing to `209.209.43.250`
- [ ] A record for `pgadmin` pointing to `209.209.43.250`
- [ ] MX record for `@` pointing to `mail.ferrylight.online`
- [ ] SPF TXT record for `@`
- [ ] DMARC TXT record for `_dmarc`
- [ ] DKIM TXT record for `mail._domainkey` (after mail server setup)
- [ ] PTR record for `209.209.43.250` (contact hosting provider)

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 