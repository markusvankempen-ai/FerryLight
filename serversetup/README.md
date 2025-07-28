# FerryLightV2

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

A comprehensive IoT and automation platform with Docker containerization, MQTT messaging, Node-RED flows, PostgreSQL database, and complete email server capabilities.

## 🚀 **Quick Start**

### **Server Setup**
```bash
# Navigate to server setup directory
cd serversetup

# Copy environment template
cp env.example .env

# Edit with your real values
nano .env

# Run complete setup
./setup.sh
```

### **Client Setup**
```bash
# Install MQTT client
pip install paho-mqtt

# Test MQTT connection
python -c "
import paho.mqtt.client as mqtt
client = mqtt.Client()
client.username_pw_set('[your-mqtt-username]', '[your-mqtt-password]')
client.connect('[your-domain]', 1883, 60)
client.publish('test/topic', 'Hello FerryLightV2!')
client.disconnect()
print('MQTT test completed!')
"
```

## 📁 **Project Structure**

```
FerryLightV2/
├── serversetup/                    # Server setup scripts and docs
│   ├── setup.sh                   # Main setup launcher
│   ├── setup_ferrylightv2_complete.sh
│   ├── modules/                   # Modular setup components
│   ├── env.example                # Environment template
│   ├── README.md                  # Server setup guide
│   ├── MAIL_SERVER_SETUP.md       # Mail server setup
│   ├── POSTGRESQL_SETUP.md        # Database setup
│   ├── POSTGRESQL_ACCESS_GUIDE.md # Database access
│   ├── DEPLOYMENT_GUIDE.md        # Deployment guide
│   ├── MODULAR_SETUP.md           # Modular setup
│   └── GITHUB_SETUP.md            # GitHub deployment
├── internal_docs/                  # Internal documentation (not pushed to GitHub)
│   ├── INTERNAL_CREDENTIALS.md    # Real credentials
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
├── README.md                       # This file
├── .gitignore                      # Git ignore rules
├── CREDENTIALS.md                  # Credentials template (not pushed)
└── SECURITY_SUMMARY.md             # Security summary (not pushed)
```

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

## 📧 **MQTT Configuration**

### **Connection Details:**
- **Broker:** `[your-domain]`
- **Port:** `1883` (MQTT) / `8883` (MQTTS)
- **WebSocket:** `ws://[your-domain]:9001`
- **Username:** `[your-mqtt-username]`
- **Password:** `[your-mqtt-password]`

### **Test Connection:**
```bash
# Using telnet
telnet [your-domain] 1883

# Using mosquitto_pub
mosquitto_pub -h [your-domain] -p 1883 -u [your-mqtt-username] -P [your-mqtt-password] -t "test/topic" -m "Hello FerryLightV2!"
```

## 🗄️ **Database Access**

### **PostgreSQL:**
- **Host:** `[your-domain]`
- **Port:** `5432`
- **Database:** `ferrylightv2`
- **Username:** `ferrylight_user`
- **Password:** Set in environment

### **pgAdmin:**
- **URL:** `https://pgadmin.[your-domain]`
- **Email:** `admin@[your-domain]`
- **Password:** Set in environment

## 📧 **Email Server**

### **SMTP Configuration:**
- **Server:** `mail.[your-domain]`
- **Port:** `587` (SMTP) / `465` (SMTPS)
- **Authentication:** Required
- **TLS:** Enabled

### **IMAP Configuration:**
- **Server:** `mail.[your-domain]`
- **Port:** `993` (IMAPS)
- **Authentication:** Required
- **TLS:** Enabled

## 🔐 **Security Features**

- **SSL/TLS** - Let's Encrypt certificates
- **Authentication** - All services secured
- **Environment Variables** - No hardcoded secrets
- **Network Isolation** - Docker networks
- **Firewall** - UFW configuration

## 🚨 **Important Notes**

### **Security:**
- Never commit `.env` files or files with real credentials
- Keep `internal_docs/` folder local (not pushed to GitHub)
- Use environment variables for all sensitive data

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

## 📚 **Documentation**

### **Server Setup:**
- `serversetup/README.md` - Complete setup guide
- `serversetup/MAIL_SERVER_SETUP.md` - Mail server setup
- `serversetup/POSTGRESQL_SETUP.md` - Database setup
- `serversetup/DEPLOYMENT_GUIDE.md` - Deployment guide

### **Internal Documentation:**
- `internal_docs/` - Contains real credentials and detailed guides
- **Never pushed to GitHub** - Keep local only

## 🔄 **Updates**

### **Update System:**
```bash
# Pull latest changes
git pull

# Restart services
cd /opt/ferrylightv2
docker-compose down && docker-compose up -d
```

### **Update Scripts:**
```bash
# Re-run setup (non-destructive)
cd serversetup
./setup.sh
```

## 🛠️ **Development**

### **Adding New Services:**
1. Add service to `serversetup/modules/docker_compose.sh`
2. Update environment variables in `serversetup/env.example`
3. Add documentation in `serversetup/`
4. Test thoroughly before deployment

### **Customizing Flows:**
1. Access Node-RED at `https://nodered.[your-domain]`
2. Import/export flows as needed
3. Use MQTT nodes for IoT communication
4. Connect to PostgreSQL for data storage

## 📞 **Support**

For issues and questions:
- **Email:** markus.van.kempen@gmail.com
- **Project:** FerryLightV2
- **Repository:** https://github.com/markusvankempen-ai/FerryLight

## 📄 **License**

This project is for internal use. All rights reserved.

---

**⚠️ SECURITY WARNING:** Never commit files containing real credentials to version control!

**Project:** FerryLightV2  
**Author:** Markus van Kempen  
**Email:** markus.van.kempen@gmail.com 