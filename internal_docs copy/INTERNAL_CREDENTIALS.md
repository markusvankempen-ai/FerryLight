# Internal Credentials - FerryLightV2

**⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB**

**Author:** Markus van Kempen  
**Date:** July 24, 2025  
**Email:** markus.van.kempen@gmail.com

## 🔐 Real System Credentials

### Domain Configuration
- **Domain:** `ferrylight.online`
- **Server IP:** `209.209.43.250`
- **Email:** `admin@ferrylight.online`

### Traefik Dashboard
- **URL:** `https://traefik.ferrylight.online`
- **Username:** `admin`
- **Password:** `ferrylight2024`

### Portainer
- **URL:** `https://portainer.ferrylight.online`
- **Username:** Create admin account on first visit
- **Password:** Set during first-time setup

### Node-RED
- **URL:** `https://nodered.ferrylight.online`
- **Username:** `admin`
- **Password:** `ferrylight2024`

### PostgreSQL Database
- **Host:** `postgres` (Docker service name)
- **Port:** `5432`
- **Database:** `ferrylight`
- **Username:** `ferrylight`
- **Password:** `ferrylight@Connexts@99`

### pgAdmin
- **URL:** `https://pgadmin.ferrylight.online`
- **Email:** `admin@ferrylight.online`
- **Password:** `ferrylight2024`

### Mail Server (Docker Mail DMS)
- **URL:** `https://mail.ferrylight.online`
- **Admin Email:** `admin@ferrylight.online`
- **Admin Password:** `ferrylight@Connexts@99`
- **API Key:** `ferrylight-api-key-2024`

### MQTT Broker
- **Broker:** `mqtt.ferrylight.online`
- **Port:** `1883`
- **WebSocket:** `ws://mqtt.ferrylight.online:9001`
- **Username:** `ferrylight`
- **Password:** `ferrylight@Connexts@99`

## 🔧 Real Connection Strings

### PostgreSQL Connection String
```
postgresql://ferrylight:ferrylight@Connexts@99@postgres:5432/ferrylight
```

### MQTT Connection String
```
mqtt://ferrylight:ferrylight@Connexts@99@mqtt.ferrylight.online:1883
```

## 📁 Real File Locations

### Project Directory
- **Main Directory:** `/opt/ferrylightv2`
- **Backup Directory:** `/opt/ferrylightv2/backups`

### Data Directories
- **Traefik:** `/opt/ferrylightv2/traefik`
- **Portainer:** `/opt/ferrylightv2/portainer`
- **Node-RED:** `/opt/ferrylightv2/nodered`
- **PostgreSQL:** `/opt/ferrylightv2/postgres`
- **pgAdmin:** `/opt/ferrylightv2/pgadmin`
- **Mail Server:** `/opt/ferrylightv2/mailserver`
- **Mosquitto:** `/opt/ferrylightv2/mosquitto`
- **Website:** `/opt/ferrylightv2/website`

## 🔒 Real Security Notes

### SSL Certificates
- **Provider:** Let's Encrypt
- **Auto-renewal:** Enabled via Traefik
- **Storage:** `/opt/ferrylightv2/traefik/acme/acme.json`

### Network Security
- **Docker Network:** `traefik-public`
- **PostgreSQL:** Internal network only
- **MQTT:** External access via port 1883
- **Web Services:** HTTPS only via Traefik

### Backup Strategy
- **Location:** `/opt/ferrylightv2/backups`
- **Frequency:** Manual via `./backup.sh`
- **Retention:** 7 days (configurable)

## 🚨 Emergency Access

### Direct Database Access
```bash
# Connect to PostgreSQL container
docker exec -it postgres psql -U ferrylight -d ferrylight

# Backup database
docker exec postgres pg_dump -U ferrylight ferrylight > backup.sql

# Restore database
docker exec -i postgres psql -U ferrylight ferrylight < backup.sql
```

### Container Management
```bash
# Check all services
cd /opt/ferrylightv2
docker-compose ps

# View logs
docker-compose logs [service_name]

# Restart services
docker-compose restart [service_name]
```

## 📞 Support Information

- **Created by:** Markus van Kempen
- **Email:** markus.van.kempen@gmail.com
- **Project:** FerryLightV2
- **Last Updated:** July 24, 2025

---

**⚠️ SECURITY WARNING: This file contains REAL credentials and should NEVER be committed to version control!** 