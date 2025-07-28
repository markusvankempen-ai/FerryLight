# DKIM Key Generation Guide - FerryLightV2

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 🔑 **DKIM Key Generation for Mail Server**

### **Domain Information:**
- **Domain:** `ferrylight.online`
- **Mail Server:** `mail.ferrylight.online`
- **Container:** `ferrylightv2-mailserver`

## 🔧 **Correct DKIM Key Generation Commands**

### **Method 1: Generate and View DKIM Key**

```bash
# Step 1: Generate DKIM key
docker exec ferrylightv2-mailserver setup config dkim

# Step 2: View the generated key
docker exec ferrylightv2-mailserver setup config dkim keysize 2048

# Step 3: Check if key was created
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain ferrylight.online
```

### **Method 2: Direct Key Generation with Output**

```bash
# Generate DKIM key and show output
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain ferrylight.online selector mail
```

### **Method 3: Check Existing Keys**

```bash
# List all DKIM keys
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain ferrylight.online

# Check specific selector
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain ferrylight.online selector mail
```

### **Method 4: Manual Key Generation**

```bash
# Connect to mail server container
docker exec -it ferrylightv2-mailserver bash

# Inside container, generate DKIM key
setup config dkim keysize 2048 domain ferrylight.online selector mail

# Exit container
exit
```

## 🔍 **Alternative Ways to View DKIM Key**

### **Check DKIM Configuration Files:**

```bash
# Check if DKIM key files exist
docker exec ferrylightv2-mailserver ls -la /tmp/docker-mailserver/opendkim/keys/ferrylight.online/

# View the public key file
docker exec ferrylightv2-mailserver cat /tmp/docker-mailserver/opendkim/keys/ferrylight.online/mail.txt

# View the private key file
docker exec ferrylightv2-mailserver cat /tmp/docker-mailserver/opendkim/keys/ferrylight.online/mail.private
```

### **Check DKIM Configuration:**

```bash
# Check DKIM configuration
docker exec ferrylightv2-mailserver setup config dkim

# Check DKIM status
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain ferrylight.online
```

## 📋 **Complete DKIM Setup Process**

### **Step 1: Generate DKIM Key**

```bash
# Navigate to project directory
cd /opt/ferrylightv2

# Generate DKIM key
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain ferrylight.online selector mail
```

### **Step 2: Extract the Public Key**

```bash
# Get the public key content
docker exec ferrylightv2-mailserver cat /tmp/docker-mailserver/opendkim/keys/ferrylight.online/mail.txt
```

### **Step 3: Format for DNS**

The output should look like this:
```
mail._domainkey.ferrylight.online. IN TXT "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC..."
```

### **Step 4: Add to DNS**

In your Namecheap DNS management:

**DKIM TXT Record:**
- **Type:** `TXT Record`
- **Host:** `mail._domainkey`
- **Value:** `"v=DKIM1; k=rsa; p=YOUR_GENERATED_PUBLIC_KEY"`
- **TTL:** `5 min`

## 🚨 **Troubleshooting DKIM Generation**

### **If DKIM key generation fails:**

```bash
# Check if mail server is running
docker-compose ps mailserver

# Check mail server logs
docker-compose logs mailserver

# Restart mail server if needed
docker-compose restart mailserver

# Try generating DKIM again
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain ferrylight.online selector mail
```

### **If no output is shown:**

```bash
# Check if DKIM directory exists
docker exec ferrylightv2-mailserver ls -la /tmp/docker-mailserver/opendkim/

# Create DKIM directory if it doesn't exist
docker exec ferrylightv2-mailserver mkdir -p /tmp/docker-mailserver/opendkim/keys/ferrylight.online/

# Set proper permissions
docker exec ferrylightv2-mailserver chown -R 500:500 /tmp/docker-mailserver/opendkim/

# Try generating DKIM again
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain ferrylight.online selector mail
```

### **Alternative DKIM generation:**

```bash
# Use different selector
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain ferrylight.online selector default

# Or use default settings
docker exec ferrylightv2-mailserver setup config dkim
```

## 🔧 **DKIM Verification Script**

### **Create DKIM verification script:**

```bash
cat > check_dkim.sh << 'EOF'
#!/bin/bash
# FerryLightV2 DKIM Verification Script
# Author: Markus van Kempen
# Date: July 24, 2025

set -e

echo "🔑 Checking DKIM configuration for ferrylight.online..."

DOMAIN="ferrylight.online"
SELECTOR="mail"

echo "📋 Checking if DKIM keys exist..."
if docker exec ferrylightv2-mailserver ls -la /tmp/docker-mailserver/opendkim/keys/$DOMAIN/ > /dev/null 2>&1; then
    echo "✅ DKIM keys directory exists"
else
    echo "❌ DKIM keys directory not found"
    echo "Generating DKIM keys..."
    docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain $DOMAIN selector $SELECTOR
fi

echo "📄 Checking public key file..."
if docker exec ferrylightv2-mailserver test -f /tmp/docker-mailserver/opendkim/keys/$DOMAIN/$SELECTOR.txt; then
    echo "✅ Public key file exists"
    echo "📋 Public key content:"
    docker exec ferrylightv2-mailserver cat /tmp/docker-mailserver/opendkim/keys/$DOMAIN/$SELECTOR.txt
else
    echo "❌ Public key file not found"
fi

echo "🔐 Checking private key file..."
if docker exec ferrylightv2-mailserver test -f /tmp/docker-mailserver/opendkim/keys/$DOMAIN/$SELECTOR.private; then
    echo "✅ Private key file exists"
else
    echo "❌ Private key file not found"
fi

echo "🌐 Checking DNS record..."
echo "Expected DNS record:"
echo "Type: TXT"
echo "Host: $SELECTOR._domainkey"
echo "Value: (from public key file above)"

echo "✅ DKIM verification completed!"
EOF

chmod +x check_dkim.sh
```

## 📊 **DKIM Testing**

### **Test DKIM DNS Record:**

```bash
# Check if DKIM DNS record is propagated
dig mail._domainkey.ferrylight.online TXT

# Test with online tools
# https://mxtoolbox.com/dkim.aspx
# https://dnschecker.org/
```

### **Test DKIM Signing:**

```bash
# Send test email and check DKIM signature
swaks --to test@ferrylight.online \
      --from admin@ferrylight.online \
      --server mail.ferrylight.online \
      --port 587 \
      --auth-user admin@ferrylight.online \
      --auth-password "ferrylight@Connexts@99" \
      --tls \
      --body "DKIM test email"
```

## 🎯 **Quick DKIM Setup Commands**

### **One-liner DKIM generation:**

```bash
# Generate and view DKIM key in one command
docker exec ferrylightv2-mailserver setup config dkim keysize 2048 domain ferrylight.online selector mail && docker exec ferrylightv2-mailserver cat /tmp/docker-mailserver/opendkim/keys/ferrylight.online/mail.txt
```

### **Check DKIM status:**

```bash
# Quick DKIM status check
docker exec ferrylightv2-mailserver setup config dkim
```

## 📝 **Expected Output Format**

When DKIM generation is successful, you should see output like:

```
# DKIM configuration
DKIM_SELECTOR=mail
DKIM_KEY_LENGTH=2048
DKIM_DOMAIN=ferrylight.online

# Public key (for DNS TXT record)
mail._domainkey.ferrylight.online. IN TXT "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC..."
```

## 🚨 **Common Issues and Solutions**

### **Issue 1: No output from DKIM generation**
**Solution:** Check if mail server is running and try different commands

### **Issue 2: Permission denied**
**Solution:** Check volume mount permissions and restart mail server

### **Issue 3: DKIM directory not found**
**Solution:** Create the directory manually and set proper permissions

### **Issue 4: DNS record not working**
**Solution:** Wait for DNS propagation and verify the TXT record format

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 