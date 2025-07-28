# FerryLight Server Integration Guide

## 📋 Table of Contents
1. [Overview](#overview)
2. [Integration Options](#integration-options)
3. [Prerequisites](#prerequisites)
4. [Quick Deployment](#quick-deployment)
5. [Advanced Integration](#advanced-integration)
6. [Monitoring & Maintenance](#monitoring--maintenance)
7. [Troubleshooting](#troubleshooting)

## 👨‍💻 Author Information

**Author**: Markus van Kempen  
**Email**: markus.van.kempen@gmail.com  
**Project**: FerryLight V2  
**Created**: July 28, 2025  
**Version**: 1.0.0

## 🚀 Overview

FerryLight is a modern React web application with an Express.js backend that provides real-time ferry status and weather information. This guide shows you how to integrate it into your existing Docker infrastructure.

### Architecture
```
Internet → Nginx Proxy → FerryLight Express.js Server → External APIs
                      ↓
                   React App (Static Files)
```

### Key Features
- **Express.js Server**: API proxy with authentication
- **React Frontend**: Modern responsive web app
- **Docker Ready**: Complete containerization
- **SSL/HTTPS**: Secure communication
- **Health Checks**: Built-in monitoring
- **Rate Limiting**: API protection

## 🔧 Integration Options

### Option 1: Standalone Deployment (Recommended)
Deploy FerryLight as a separate service with its own nginx proxy.

### Option 2: Integrate with Existing Nginx
Add FerryLight as a location in your existing nginx configuration.

### Option 3: Traefik Integration
Use Traefik labels for automatic service discovery.

### Option 4: Kubernetes Deployment
Deploy using Kubernetes manifests (for advanced setups).

## 📋 Prerequisites

### System Requirements
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **Memory**: 512MB minimum, 1GB recommended
- **Storage**: 1GB minimum
- **Network**: Outbound HTTPS access for APIs

### Required Environment Variables
```bash
# API Credentials (Required)
REACT_APP_API_USERNAME=your_api_username
REACT_APP_API_PASSWORD=your_api_password

# API Endpoints (Optional - defaults provided)
REACT_APP_FERRY_API_URL=https://nodered.ferrylight.online/rbferry
REACT_APP_WEATHER_API_URL=https://nodered.ferrylight.online/rbweather

# Admin Credentials (Optional - defaults provided)
REACT_APP_ADMIN_USERNAME=admin
REACT_APP_ADMIN_PASSWORD=ferrylight2025
```

## 🚀 Quick Deployment

### Step 1: Clone Repository
```bash
git clone <repository-url>
cd FerryLightV2
```

### Step 2: Setup Environment
```bash
# Copy environment template
cp env.example .env

# Edit with your credentials
nano .env
```

### Step 3: Deploy
```bash
# Run deployment script
chmod +x deploy.sh
./deploy.sh
```

### Step 4: Verify
```bash
# Check services
docker-compose ps

# Test endpoints
curl -k https://localhost/api/health
curl -k https://localhost
```

## 🏗️ Advanced Integration

### Option 1: Standalone with Custom Domain

1. **Update docker-compose.yml**:
```yaml
services:
  nginx-proxy:
    ports:
      - "80:80"
      - "443:443"
    environment:
      - VIRTUAL_HOST=ferrylight.yourdomain.com
      - LETSENCRYPT_HOST=ferrylight.yourdomain.com
      - LETSENCRYPT_EMAIL=admin@yourdomain.com
```

2. **Add SSL certificates**:
```bash
# Place certificates in ssl/ directory
cp /path/to/cert.pem ssl/
cp /path/to/key.pem ssl/
```

### Option 2: Integrate with Existing Nginx

1. **Add to your nginx.conf**:
```nginx
# Upstream for FerryLight
upstream ferrylight_backend {
    server localhost:3001;
}

# Add location block to your existing server
location /ferrylight/ {
    proxy_pass http://ferrylight_backend/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

2. **Update docker-compose.yml**:
```yaml
services:
  ferrylight-app:
    ports:
      - "3001:3001"  # Expose port directly
    # Remove nginx-proxy service
```

### Option 3: Traefik Integration

1. **Add labels to docker-compose.yml**:
```yaml
services:
  ferrylight-app:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.ferrylight.rule=Host(`ferrylight.yourdomain.com`)"
      - "traefik.http.routers.ferrylight.tls=true"
      - "traefik.http.routers.ferrylight.tls.certresolver=letsencrypt"
      - "traefik.http.services.ferrylight.loadbalancer.server.port=3001"
    networks:
      - traefik
```

### Option 4: Behind Existing Load Balancer

1. **Configure health checks**:
```yaml
# Health check endpoint: /api/health
# Returns: {"status":"healthy","timestamp":"..."}
```

2. **Setup monitoring**:
```bash
# Monitor with curl
curl http://localhost:3001/api/health

# Monitor with Docker
docker-compose ps
docker-compose logs -f ferrylight-app
```

## 📊 Monitoring & Maintenance

### Health Checks
```bash
# Application health
curl http://localhost:3001/api/health

# Nginx health
curl http://localhost/nginx-health

# Docker health
docker-compose ps
```

### Log Management
```bash
# View application logs
docker-compose logs -f ferrylight-app

# View nginx logs
docker-compose logs -f nginx-proxy

# View system logs
tail -f logs/nginx/access.log
tail -f logs/nginx/error.log
```

### Backup & Updates
```bash
# Backup configuration
tar -czf ferrylight-backup-$(date +%Y%m%d).tar.gz .env ssl/ logs/

# Update application
git pull
docker-compose down
./deploy.sh

# Rollback if needed
docker-compose down
git checkout previous-commit
./deploy.sh
```

### Performance Monitoring
```bash
# Resource usage
docker stats ferrylight-website

# API response times
curl -w "@curl-format.txt" -k https://localhost/api/health

# Database queries (if using analytics)
docker-compose exec postgres-analytics psql -U ferrylight -c "SELECT * FROM requests ORDER BY timestamp DESC LIMIT 10;"
```

## 🔧 Configuration Options

### Environment Variables
```bash
# Server Configuration
NODE_ENV=production
PORT=3001

# API Configuration
REACT_APP_API_USERNAME=your_username
REACT_APP_API_PASSWORD=your_password
REACT_APP_FERRY_API_URL=https://api.example.com/ferry
REACT_APP_WEATHER_API_URL=https://api.example.com/weather

# Admin Configuration
REACT_APP_ADMIN_USERNAME=admin
REACT_APP_ADMIN_PASSWORD=secure_password

# Optional: Database
POSTGRES_PASSWORD=secure_db_password
```

### Docker Compose Profiles
```bash
# Basic deployment
docker-compose up -d

# With Redis caching
docker-compose --profile cache up -d

# With analytics database
docker-compose --profile analytics up -d

# Full deployment
docker-compose --profile cache --profile analytics up -d
```

### Nginx Configuration
```nginx
# Rate limiting
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

# Caching
location ~* \.(js|css|png|jpg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Security headers
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
```

## 🚨 Troubleshooting

### Common Issues

#### Service Won't Start
```bash
# Check logs
docker-compose logs ferrylight-app

# Check environment
docker-compose exec ferrylight-app env | grep REACT_APP

# Rebuild container
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

#### API Errors (401 Unauthorized)
```bash
# Verify credentials in .env
cat .env | grep API_USERNAME

# Test API directly
curl -u "username:password" https://nodered.ferrylight.online/rbferry

# Check server logs
docker-compose logs ferrylight-app | grep "API"
```

#### SSL Certificate Issues
```bash
# Check certificate files
ls -la ssl/
openssl x509 -in ssl/cert.pem -text -noout

# Generate new self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/key.pem -out ssl/cert.pem
```

#### Performance Issues
```bash
# Check resource usage
docker stats

# Increase memory limit
docker-compose.yml:
  ferrylight-app:
    deploy:
      resources:
        limits:
          memory: 1G
```

### Debug Mode
```bash
# Enable debug logging
echo "REACT_APP_DEBUG_MODE=true" >> .env
docker-compose restart ferrylight-app

# View debug logs
docker-compose logs -f ferrylight-app | grep DEBUG
```

### Network Issues
```bash
# Test network connectivity
docker-compose exec ferrylight-app curl https://nodered.ferrylight.online/rbferry

# Check DNS resolution
docker-compose exec ferrylight-app nslookup nodered.ferrylight.online

# Test internal networking
docker-compose exec nginx-proxy curl http://ferrylight-app:3001/api/health
```

## 🔗 Integration with Existing Services

### Prometheus Monitoring
```yaml
# Add to your prometheus.yml
- job_name: 'ferrylight'
  static_configs:
    - targets: ['ferrylight-app:3001']
  metrics_path: '/api/metrics'
```

### Grafana Dashboard
```json
{
  "dashboard": {
    "title": "FerryLight Monitoring",
    "panels": [
      {
        "title": "API Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "http_request_duration_seconds{job=\"ferrylight\"}"
          }
        ]
      }
    ]
  }
}
```

### Log Aggregation (ELK Stack)
```yaml
# Add to your docker-compose.yml
services:
  ferrylight-app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service=ferrylight"
```

### Backup Integration
```bash
#!/bin/bash
# Add to your backup scripts
tar -czf /backup/ferrylight-$(date +%Y%m%d).tar.gz \
    /opt/ferrylight/.env \
    /opt/ferrylight/ssl/ \
    /opt/ferrylight/logs/
```

## 📈 Scaling Considerations

### Horizontal Scaling
```yaml
# docker-compose.yml
services:
  ferrylight-app:
    deploy:
      replicas: 3
    labels:
      - "traefik.http.services.ferrylight.loadbalancer.healthcheck.path=/api/health"
```

### Load Balancing
```nginx
upstream ferrylight_cluster {
    server ferrylight-app-1:3001;
    server ferrylight-app-2:3001;
    server ferrylight-app-3:3001;
    keepalive 32;
}
```

### Caching Strategy
```yaml
# Add Redis for caching
services:
  redis-cache:
    image: redis:7-alpine
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
```

---

**Last Updated**: July 28, 2025  
**Version**: 1.0.0  
**Maintainer**: Markus van Kempen (markus.van.kempen@gmail.com) 