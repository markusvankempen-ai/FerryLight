# FerryLightV2 Project Structure

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 📁 **Consolidated Project Structure**

The FerryLightV2 project has been reorganized for better organization and security. All server setup files are now consolidated in the `serversetup/` folder, and sensitive information is properly isolated.

## 🗂️ **Directory Structure**

```
FerryLightV2/
├── serversetup/                    # 🚀 Server setup scripts and documentation
│   ├── setup.sh                   # Main setup launcher
│   ├── setup_ferrylightv2_complete.sh
│   ├── modules/                   # Modular setup components
│   │   ├── system_setup.sh       # System preparation
│   │   ├── project_setup.sh      # Project structure
│   │   ├── docker_compose.sh     # Docker Compose generation
│   │   ├── mqtt_auth.sh          # MQTT authentication
│   │   ├── mail_server.sh        # Mail server setup
│   │   ├── final_config.sh       # Final configurations
│   │   └── results.sh            # Setup results display
│   ├── env.example               # Environment variables template
│   ├── README.md                 # Server setup guide
│   ├── MAIL_SERVER_SETUP.md      # Mail server manual setup
│   ├── POSTGRESQL_SETUP.md       # PostgreSQL manual setup
│   ├── POSTGRESQL_ACCESS_GUIDE.md
│   ├── DEPLOYMENT_GUIDE.md       # Deployment instructions
│   ├── MODULAR_SETUP.md          # Modular setup guide
│   └── GITHUB_SETUP.md           # GitHub deployment guide
├── internal_docs/                 # 🔐 Internal documentation (NOT pushed to GitHub)
│   ├── INTERNAL_CREDENTIALS.md   # Real credentials
│   ├── INTERNAL_POSTGRESQL_ACCESS.md
│   ├── INTERNAL_MAIL_SERVER_ACCESS.md
│   ├── CLI_EMAIL_TESTING_GUIDE.md
│   ├── DNS_SETUP_GUIDE.md
│   ├── DKIM_KEY_GENERATION_GUIDE.md
│   ├── EMAIL_VERIFICATION_GUIDE.md
│   ├── TLS_CONFIGURATION_FIX.md
│   ├── AUTHENTICATION_FIX_GUIDE.md
│   ├── EXTERNAL_EMAIL_DELIVERY_FIX.md
│   ├── SPAM_DELIVERABILITY_FIX.md
│   └── README.md
├── README.md                      # Main project README
├── .gitignore                     # Git ignore rules
├── CREDENTIALS.md                 # Credentials template (NOT pushed)
├── SECURITY_SUMMARY.md            # Security summary (NOT pushed)
└── old_scripts_backup/            # Backup of old scripts
```

## 🔐 **Security Structure**

### **GitHub-Safe Files (Pushed to Repository):**
- `serversetup/` - All setup scripts and documentation (no real credentials)
- `README.md` - Main project documentation
- `.gitignore` - Git ignore rules
- `PROJECT_STRUCTURE.md` - This file

### **Local-Only Files (NOT Pushed to GitHub):**
- `internal_docs/` - Contains all real credentials and sensitive information
- `CREDENTIALS.md` - Real system credentials
- `SECURITY_SUMMARY.md` - Security implementation details

## 🚀 **Quick Start Guide**

### **For New Users:**
```bash
# 1. Clone the repository
git clone https://github.com/markusvankempen-ai/FerryLight.git
cd FerryLight

# 2. Navigate to server setup
cd serversetup

# 3. Configure environment
cp env.example .env
nano .env  # Edit with your real values

# 4. Run setup
./setup.sh
```

### **For Existing Users:**
```bash
# 1. Pull latest changes
git pull

# 2. Navigate to server setup
cd serversetup

# 3. Run setup (non-destructive)
./setup.sh
```

## 📋 **File Descriptions**

### **Server Setup Files:**

#### **Core Scripts:**
- `setup.sh` - Main launcher script with environment checks
- `setup_ferrylightv2_complete.sh` - Complete setup orchestrator
- `env.example` - Environment variables template

#### **Modular Components:**
- `modules/system_setup.sh` - System preparation and updates
- `modules/project_setup.sh` - Project directory structure
- `modules/docker_compose.sh` - Docker Compose generation
- `modules/mqtt_auth.sh` - MQTT authentication setup
- `modules/mail_server.sh` - Mail server configuration
- `modules/final_config.sh` - Final system configuration
- `modules/results.sh` - Setup results and summary

#### **Documentation:**
- `README.md` - Complete server setup guide
- `MAIL_SERVER_SETUP.md` - Mail server manual setup
- `POSTGRESQL_SETUP.md` - Database manual setup
- `POSTGRESQL_ACCESS_GUIDE.md` - Database access guide
- `DEPLOYMENT_GUIDE.md` - Deployment instructions
- `MODULAR_SETUP.md` - Modular setup explanation
- `GITHUB_SETUP.md` - GitHub deployment guide

### **Internal Documentation:**

#### **Credentials and Access:**
- `INTERNAL_CREDENTIALS.md` - All real system credentials
- `INTERNAL_POSTGRESQL_ACCESS.md` - Database access with real credentials
- `INTERNAL_MAIL_SERVER_ACCESS.md` - Mail server access with real credentials

#### **Troubleshooting Guides:**
- `CLI_EMAIL_TESTING_GUIDE.md` - Email testing from command line
- `DNS_SETUP_GUIDE.md` - DNS configuration with real domain
- `DKIM_KEY_GENERATION_GUIDE.md` - DKIM key generation
- `EMAIL_VERIFICATION_GUIDE.md` - Email verification methods
- `TLS_CONFIGURATION_FIX.md` - TLS/SSL configuration fixes
- `AUTHENTICATION_FIX_GUIDE.md` - Authentication troubleshooting
- `EXTERNAL_EMAIL_DELIVERY_FIX.md` - External email delivery issues
- `SPAM_DELIVERABILITY_FIX.md` - Spam deliverability improvements

## 🔧 **Services Included**

### **Core Infrastructure:**
- **Docker & Docker Compose** - Containerization platform
- **Traefik** - Reverse proxy with automatic SSL
- **Portainer** - Docker management interface

### **IoT & Automation:**
- **Node-RED** - Visual programming for IoT
- **Mosquitto MQTT** - Lightweight messaging protocol
- **PostgreSQL** - Relational database
- **pgAdmin** - Database administration

### **Communication:**
- **Docker Mail DMS** - Complete email server
- **SMTP/IMAP** - Email protocols
- **Spam/Antivirus** - Email protection

## 🌐 **Access URLs**

After setup, access services at:

- **Traefik Dashboard:** `https://traefik.[your-domain]`
- **Portainer:** `https://portainer.[your-domain]`
- **Node-RED:** `https://nodered.[your-domain]`
- **pgAdmin:** `https://pgadmin.[your-domain]`
- **Mail Server:** `https://mail.[your-domain]`

## 🔐 **Security Features**

- **Environment Variables** - No hardcoded secrets in scripts
- **Git Ignore Rules** - Sensitive files excluded from version control
- **SSL/TLS** - Let's Encrypt certificates
- **Authentication** - All services secured
- **Network Isolation** - Docker networks
- **Firewall** - UFW configuration

## 📚 **Documentation Strategy**

### **Public Documentation (GitHub):**
- Setup instructions with placeholders
- Configuration guides with examples
- Troubleshooting with generic solutions
- No real credentials or sensitive information

### **Internal Documentation (Local Only):**
- Real credentials and passwords
- Domain-specific configurations
- Detailed troubleshooting with real examples
- Security implementation details

## 🚨 **Important Notes**

### **Security:**
- Never commit `.env` files or files with real credentials
- Keep `internal_docs/` folder local (not pushed to GitHub)
- Use environment variables for all sensitive data
- Regularly update passwords and credentials

### **DNS Requirements:**
- A records for all subdomains
- MX record for mail server
- SPF, DKIM, DMARC records for email
- PTR record (set by hosting provider)

### **Ports Required:**
- `80` - HTTP (redirect to HTTPS)
- `443` - HTTPS
- `1883` - MQTT
- `8883` - MQTTS
- `9001` - MQTT WebSocket
- `25` - SMTP
- `587` - SMTP submission
- `993` - IMAPS

## 🔄 **Maintenance**

### **Regular Tasks:**
1. **Security updates** - Keep system packages updated
2. **Backup** - Regular configuration and data backup
3. **Monitoring** - Check service health and logs
4. **DNS verification** - Ensure DNS records are correct

### **Update Process:**
```bash
# Pull latest changes
git pull

# Restart services
cd /opt/ferrylightv2
docker-compose down && docker-compose up -d

# Update scripts if needed
cd serversetup
./setup.sh
```

## 📞 **Support**

For issues and questions:
- **Email:** markus.van.kempen@gmail.com
- **Project:** FerryLightV2
- **Repository:** https://github.com/markusvankempen-ai/FerryLight

---

**⚠️ SECURITY WARNING:** Never commit files containing real credentials to version control!

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 