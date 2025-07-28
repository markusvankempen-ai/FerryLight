# Internal Documentation - FerryLightV2

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

This folder contains internal documentation with **REAL credentials, IP addresses, and hostnames** that should **NEVER** be committed to GitHub or any public repository.

## 📁 **Internal Documentation Files**

### **🔐 Credentials and Access**
- **`INTERNAL_CREDENTIALS.md`** - Complete system credentials with real values
- **`INTERNAL_POSTGRESQL_ACCESS.md`** - PostgreSQL access with real credentials
- **`INTERNAL_MAIL_SERVER_ACCESS.md`** - Mail server access with real credentials
- **`CLI_EMAIL_TESTING_GUIDE.md`** - Complete CLI email testing guide with real credentials
- **`DNS_SETUP_GUIDE.md`** - Complete DNS setup guide for mail server with real domain/IP
- **`DKIM_KEY_GENERATION_GUIDE.md`** - DKIM key generation and troubleshooting guide
- **`EMAIL_VERIFICATION_GUIDE.md`** - Comprehensive email testing and verification guide
- **`TLS_CONFIGURATION_FIX.md`** - TLS/SSL configuration fix guide
- **`AUTHENTICATION_FIX_GUIDE.md`** - Authentication fix guide

### **📋 What's Included**
- **Real domain names** (ferrylight.online)
- **Real IP addresses** (209.209.43.250)
- **Real usernames and passwords**
- **Real connection strings**
- **Real DNS records**
- **Real file paths**

## 🔒 **Security Warning**

### **⚠️ NEVER COMMIT THESE FILES:**
- These files contain **sensitive information**
- **Real credentials** and **IP addresses**
- **Internal network details**
- **Server configurations**

### **✅ Safe for GitHub:**
- `README.md` (uses placeholders)
- `POSTGRESQL_ACCESS_GUIDE.md` (uses placeholders)
- `MAIL_SERVER_SETUP.md` (uses placeholders)
- All other documentation with `[your-domain]` placeholders

## 📖 **Documentation Structure**

### **Public Documentation (GitHub Safe):**
```
FerryLightV2/
├── 📄 README.md                      # Main documentation (placeholders)
├── 📄 POSTGRESQL_ACCESS_GUIDE.md     # PostgreSQL guide (placeholders)
├── 📄 MAIL_SERVER_SETUP.md           # Mail server guide (placeholders)
├── 📄 POSTGRESQL_SETUP.md            # PostgreSQL setup (placeholders)
├── 📄 GITHUB_SETUP.md                # GitHub deployment guide
├── 📄 MODULAR_SETUP.md               # Modular setup guide
├── 📄 DEPLOYMENT_GUIDE.md            # Deployment guide (placeholders)
├── 📄 env.example                    # Environment template
└── 📄 .gitignore                     # Git ignore rules
```

### **Internal Documentation (Never Commit):**
```
FerryLightV2/
├── 🔐 internal_docs/
│   ├── 📄 README.md                          # This file
│   ├── 📄 INTERNAL_CREDENTIALS.md            # Real credentials
│   ├── 📄 INTERNAL_POSTGRESQL_ACCESS.md      # Real PostgreSQL access
│   ├── 📄 INTERNAL_MAIL_SERVER_ACCESS.md     # Real mail server access
│   ├── 📄 CLI_EMAIL_TESTING_GUIDE.md         # CLI email testing guide
│   ├── 📄 MANUAL_MAIL_SERVER_SETUP.sh        # Manual mail server setup
│   ├── 📄 MAIL_SERVER_DOCKER_COMPOSE_FIX.yml # Docker Compose fix
│   ├── 📄 MAIL_SERVER_USER_FIX.sh            # User management fix
│   ├── 📄 MAIL_SERVER_VOLUME_MOUNT_FIX.md    # Volume mount troubleshooting
│   ├── 📄 DNS_SETUP_GUIDE.md                 # DNS setup guide
│   ├── 📄 DKIM_KEY_GENERATION_GUIDE.md       # DKIM key generation guide
│   ├── 📄 EMAIL_VERIFICATION_GUIDE.md        # Email verification guide
│   ├── 📄 TLS_CONFIGURATION_FIX.md           # TLS configuration fix guide
│   └── 📄 AUTHENTICATION_FIX_GUIDE.md        # Authentication fix guide
├── 🔐 CREDENTIALS.md                         # Real credentials (root level)
└── 🔐 SECURITY_SUMMARY.md                    # Security summary (root level)
```

## 🚨 **Git Protection**

### **Files Excluded from Git:**
- `internal_docs/` (entire folder)
- `CREDENTIALS.md`
- `SECURITY_SUMMARY.md`
- `.env` (if created)
- All SSL certificates
- All database files
- All backup files

### **Git Ignore Rules:**
```gitignore
# Internal documentation
internal_docs/
CREDENTIALS.md
SECURITY_SUMMARY.md

# Environment files
*.env
.env.local
.env.production

# SSL certificates
traefik/acme/
*.pem
*.key
*.crt

# Database files
postgres/data/
pgadmin/

# Backup files
backups/
*.backup
*.sql
*.sql.gz
```

## 📱 **Quick Access**

### **For Real Credentials:**
- **Main Credentials:** `CREDENTIALS.md`
- **PostgreSQL Access:** `internal_docs/INTERNAL_POSTGRESQL_ACCESS.md`
- **Mail Server Access:** `internal_docs/INTERNAL_MAIL_SERVER_ACCESS.md`

### **For Public Documentation:**
- **Main Guide:** `README.md`
- **PostgreSQL Guide:** `POSTGRESQL_ACCESS_GUIDE.md`
- **Mail Server Guide:** `MAIL_SERVER_SETUP.md`

## 🔧 **Usage Guidelines**

### **For Your Use:**
1. **Keep internal docs locally** (never commit)
2. **Use real credentials** from internal docs
3. **Reference public docs** for GitHub users
4. **Update both** when making changes

### **For Other Users:**
1. **Use public documentation** (GitHub)
2. **Replace placeholders** with their values
3. **Create their own** internal docs if needed
4. **Follow security best practices**

## 📞 **Support**

For questions about internal documentation:
- **Email:** markus.van.kempen@gmail.com
- **Project:** FerryLightV2
- **Security:** All internal docs are for authorized personnel only

---

**⚠️ SECURITY WARNING: This folder contains REAL credentials and should NEVER be committed to version control!**

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 