# FerryLightV2 Server Setup

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 🚀 **Quick Start**

### **1. Prerequisites**
- Ubuntu 20.04+ server
- Domain name with DNS access
- Root or sudo access
- Docker and Docker Compose installed

### **2. Setup Environment**
```bash
# Copy environment template
cp env.example .env

# Edit with your real values
nano .env
```

### **3. Run Complete Setup**
```bash
# Make setup script executable
chmod +x setup.sh

# Run complete setup
./setup.sh
```

## 📁 **File Structure**

```
serversetup/
├── setup.sh                          # Main launcher script
├── setup_ferrylightv2_complete.sh    # Complete setup orchestrator
├── modules/                          # Modular setup components
│   ├── system_setup.sh              # System preparation
│   ├── project_setup.sh             # Project structure
│   ├── docker_compose.sh            # Docker Compose generation
│   ├── mqtt_auth.sh                 # MQTT authentication
│   ├── mail_server.sh               # Mail server setup
│   ├── final_config.sh              # Final configurations
│   └── results.sh                   # Setup results display
├── env.example                       # Environment variables template
├── README.md                        # This file
├── MAIL_SERVER_SETUP.md             # Mail server manual setup
├── POSTGRESQL_SETUP.md              # PostgreSQL manual setup
├── POSTGRESQL_ACCESS_GUIDE.md       # PostgreSQL access guide
├── DEPLOYMENT_GUIDE.md              # Deployment instructions
├── MODULAR_SETUP.md                 # Modular setup guide
└── GITHUB_SETUP.md                  # GitHub deployment guide
```

## 🔧 **Services Included**

### **Core Services:**
- **Docker & Docker Compose** - Containerization
- **Traefik** - Reverse proxy with SSL
- **Portainer** - Docker management UI
- **Node-RED** - Flow-based programming
- **Mosquitto MQTT** - Message broker

### **Database Services:**
- **PostgreSQL** - Relational database
- **pgAdmin** - Database administration UI

### **Mail Services:**
- **Docker Mail DMS** - Complete email server
- **SMTP/IMAP** - Email protocols
- **Spam/Antivirus** - Email protection

## 📋 **Setup Process**

### **Phase 1: System Preparation**
- System updates
- Package installation
- Docker setup
- Network configuration

### **Phase 2: Project Structure**
- Directory creation
- Docker networks
- Configuration files

### **Phase 3: Service Deployment**
- Docker Compose generation
- Service containers
- Authentication setup

### **Phase 4: Final Configuration**
- Permissions setup
- Systemd services
- Management scripts

## 🔐 **Security Features**

- **SSL/TLS** - Let's Encrypt certificates
- **Authentication** - All services secured
- **Environment Variables** - No hardcoded secrets
- **Network Isolation** - Docker networks
- **Firewall** - UFW configuration

## 🌐 **Access URLs**

After setup, access services at:

- **Traefik Dashboard:** `https://traefik.[your-domain]`
- **Portainer:** `https://portainer.[your-domain]`
- **Node-RED:** `https://nodered.[your-domain]`
- **pgAdmin:** `https://pgadmin.[your-domain]`
- **Mail Server:** `https://mail.[your-domain]`

## 📧 **Email Configuration**

### **DNS Records Required:**
- **MX:** `mail.[your-domain]`
- **SPF:** `v=spf1 mx a ip4:[your-ip] ~all`
- **DMARC:** `v=DMARC1; p=quarantine; rua=mailto:dmarc@[your-domain];`
- **DKIM:** Generated during setup

### **PTR Record:**
Contact your hosting provider to set:
`[your-ip] → mail.[your-domain]`

## 🗄️ **Database Access**

### **PostgreSQL:**
- **Host:** `localhost` or `[your-domain]`
- **Port:** `5432`
- **Database:** `ferrylightv2`
- **Username:** `ferrylight_user`
- **Password:** Set in `.env`

### **pgAdmin:**
- **URL:** `https://pgadmin.[your-domain]`
- **Email:** `admin@[your-domain]`
- **Password:** Set in `.env`

## 🔧 **Management Scripts**

Generated during setup:
- `backup.sh` - System backup
- `test_mqtt.sh` - MQTT testing
- `test_postgres.sh` - Database testing
- `manage_mail.sh` - Mail server management

## 🚨 **Troubleshooting**

### **Common Issues:**
1. **Port conflicts** - Check if ports are in use
2. **DNS issues** - Verify DNS propagation
3. **SSL errors** - Check Let's Encrypt setup
4. **Permission errors** - Verify file permissions

### **Logs:**
```bash
# Check service logs
docker-compose logs [service-name]

# Check system logs
journalctl -u docker
```

## 📚 **Documentation**

- **MAIL_SERVER_SETUP.md** - Detailed mail server setup
- **POSTGRESQL_SETUP.md** - Database setup guide
- **POSTGRESQL_ACCESS_GUIDE.md** - Database access
- **DEPLOYMENT_GUIDE.md** - Deployment instructions
- **MODULAR_SETUP.md** - Modular setup explanation
- **GITHUB_SETUP.md** - GitHub deployment

## 🔄 **Updates**

### **Update System:**
```bash
# Pull latest changes
git pull

# Restart services
docker-compose down && docker-compose up -d
```

### **Update Scripts:**
```bash
# Re-run setup (non-destructive)
./setup.sh
```

## 📞 **Support**

For issues and questions:
- **Email:** markus.van.kempen@gmail.com
- **Project:** FerryLightV2
- **Repository:** https://github.com/markusvankempen-ai/FerryLight

---

**⚠️ SECURITY NOTE:** Never commit `.env` files or files containing real credentials to version control!

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 