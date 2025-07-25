# FerryLightV2 - MQTT Traffic Light System

A comprehensive MQTT-based traffic light management system with authentication and real-time monitoring.

## 🚦 Overview

FerryLightV2 is a modern traffic light control system that uses MQTT (Message Queuing Telemetry Transport) for real-time communication between traffic lights and a central management system. The system includes secure authentication, web-based monitoring, and automated traffic flow management.

## 📋 Features

- **🔐 Secure MQTT Authentication** - Username/password protected MQTT broker
- **🌐 Web Dashboard** - Real-time traffic light status monitoring
- **📱 Mobile Support** - Responsive design for mobile devices
- **🔔 Real-time Notifications** - Instant status updates
- **📊 Data Logging** - Historical traffic data and analytics
- **🔄 Auto-recovery** - Automatic system recovery and health monitoring
- **🔒 SSL/TLS Support** - Encrypted communication (optional)

## 🏗️ Architecture

```
┌─────────────────┐    MQTT    ┌─────────────────┐
│   Traffic Light │ ────────── │  MQTT Broker    │
│   Controller    │            │  (Mosquitto)    │
└─────────────────┘            └─────────────────┘
                                       │
                                       │ MQTT
                                       ▼
┌─────────────────┐            ┌─────────────────┐
│   Web Dashboard │ ◄───────── │  Node-RED       │
│   (Monitoring)  │   HTTP     │  (Logic Engine) │
└─────────────────┘            └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Linux/macOS system
- Internet connection for domain access

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd FerryLightV2
   ```

2. **Run the setup script:**
   ```bash
   # Quick setup (recommended)
   ./setup.sh
   
   # Or run directly
   ./setup_ferrylightv2_complete.sh
   ```

3. **Access the system:**
   - Web Dashboard: `https://[your-domain]`
   - MQTT Broker: `mqtt.[your-domain]:1883`

## 🔧 Configuration

### MQTT Settings

| Setting | Value |
|---------|-------|
| Broker | `mqtt.[your-domain]` |
| Port | `1883` |
| Username | `[your-mqtt-username]` |
| Password | `[your-mqtt-password]` |
| Authentication | Required |
| Anonymous Access | Disabled |

### WebSocket Support

For web-based MQTT clients:
- **WebSocket URL:** `ws://mqtt.[your-domain]:9001`
- **Same credentials as MQTT**

## 📱 MQTT Topics

### System Topics

| Topic | Description | Direction |
|-------|-------------|-----------|
| `ferrylight/status` | System status updates | Both |
| `ferrylight/health` | Health check responses | Both |
| `ferrylight/test` | Test messages | Both |

### Traffic Light Topics

| Topic | Description | Direction |
|-------|-------------|-----------|
| `traffic/light/{id}/status` | Light status | Both |
| `traffic/light/{id}/command` | Light commands | Out |
| `traffic/light/{id}/sensor` | Sensor data | In |

## 🛠️ Scripts

### `fix_mqtt_auth.sh`

Complete MQTT authentication setup and configuration script.

**Features:**
- ✅ Container management
- ✅ Permission fixing
- ✅ Configuration setup
- ✅ Password file creation
- ✅ Authentication testing
- ✅ Diagnostic tools

**Usage:**
```bash
./fix_mqtt_auth.sh
```

### `test_mqtt_auth.sh`

Quick MQTT authentication test script.

**Usage:**
```bash
./test_mqtt_auth.sh
```

## 🔍 Testing

### Command Line Testing

**Publish a message:**
```bash
mosquitto_pub -h mqtt.[your-domain] -p 1883 \
  -t ferrylight/test \
  -m "Hello from FerryLightV2" \
  -u [your-mqtt-username] \
  -P "[your-mqtt-password]"
```

**Subscribe to topic:**
```bash
mosquitto_sub -h mqtt.[your-domain] -p 1883 \
  -t ferrylight/test \
  -u [your-mqtt-username] \
  -P "[your-mqtt-password]"
```

### MQTT Client Apps

Use any MQTT client app with these settings:
- **Broker:** `mqtt.[your-domain]`
- **Port:** `1883`
- **Username:** `[your-mqtt-username]`
- **Password:** `[your-mqtt-password]`
- **Topic:** `ferrylight/test`

## 📊 Monitoring

### Web Dashboard

Access the real-time monitoring dashboard at:
```
https://[your-domain]
```

**Features:**
- Real-time traffic light status
- System health monitoring
- Historical data visualization
- Alert management

### Logs

View system logs:
```bash
# MQTT Broker logs
docker-compose logs mosquitto

# Node-RED logs
docker-compose logs nodered

# All services
docker-compose logs
```

## 🔒 Security

### Authentication

- **Required for all MQTT connections**
- **Username/password authentication**
- **Anonymous access disabled**
- **Secure password handling**

### Network Security

- **Firewall protection**
- **Port restrictions**
- **SSL/TLS encryption (optional)**
- **Regular security updates**

## 🚨 Troubleshooting

### Common Issues

**1. Authentication Failed**
```bash
# Check if container is running
docker ps | grep mosquitto

# Check logs
docker-compose logs mosquitto

# Run fix script
./fix_mqtt_auth.sh
```

**2. Connection Refused**
```bash
# Check if port is open
telnet mqtt.[your-domain] 1883

# Check firewall
sudo ufw status
```

**3. Permission Denied**
```bash
# Fix permissions
sudo chown -R $USER:$USER /opt/ferrylightv2
sudo chmod -R 755 /opt/ferrylightv2
```

### Diagnostic Commands

```bash
# Check container status
docker-compose ps

# Check network connectivity
ping mqtt.ferrylight.online

# Test MQTT connection
mosquitto_pub -h mqtt.ferrylight.online -p 1883 -t test -m "test"

# View real-time logs
docker-compose logs -f
```

## 📈 Performance

### System Requirements

- **CPU:** 1 core minimum, 2 cores recommended
- **RAM:** 512MB minimum, 1GB recommended
- **Storage:** 1GB available space
- **Network:** Stable internet connection

### Optimization

- **Connection pooling**
- **Message queuing**
- **Automatic cleanup**
- **Resource monitoring**

## 🔄 Maintenance

### Regular Tasks

1. **Log rotation** - Automatic log cleanup
2. **Security updates** - Regular system updates
3. **Backup** - Configuration and data backup
4. **Health checks** - System monitoring

### Update Process

```bash
# Pull latest changes
git pull

# Restart services
docker-compose down
docker-compose up -d

# Run authentication fix
./fix_mqtt_auth.sh
```

## 📞 Support

### Contact Information

- **Author:** Markus van Kempen
- **Email:** markus.van.kempen@gmail.com
- **Project:** FerryLightV2

### Documentation

- **This README** - Basic setup and usage
- **Script comments** - Detailed script documentation
- **MQTT documentation** - Protocol-specific information

## 📄 License

This project is proprietary software developed for specific traffic management needs.

---

**Last Updated:** 24-July-2025  
**Version:** 2.0  
**Status:** Production Ready 