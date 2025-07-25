#!/bin/bash

# FerryLightV2 Enable IP Access Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "🌐 FerryLightV2 Enable IP Access"
echo "================================"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

PROJECT_DIR="/opt/ferrylightv2"

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found. Please run setup_ferrylight.sh first."
    exit 1
fi

cd $PROJECT_DIR

print_status "Creating temporary configuration for IP-based access..."

# Create a temporary docker-compose file with IP-based routing
cat > docker-compose-temp.yml << 'EOF'
services:
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"  # Traefik dashboard
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik/traefik.yml:/etc/traefik/traefik.yml:ro
      - ./traefik/config:/etc/traefik/config:ro
      - ./traefik/acme:/etc/traefik/acme
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.rule=Host(`209.209.43.250`) || Host(`traefik.ferrylight.online`)"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.middlewares=auth"
      - "traefik.http.middlewares.auth.basicauth.users=admin:$2y$10$8K1p/a0dL1LXMIgoEDFrwOfgqwAG6WUa9EqJdKvJ/JOIdw0KxQK8K"

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./portainer:/data
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.rule=Host(`209.209.43.250`) || Host(`portainer.ferrylight.online`)"
      - "traefik.http.routers.portainer.entrypoints=websecure"
      - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"

  website:
    image: nginx:alpine
    container_name: ferrylightv2-website
    restart: unless-stopped
    volumes:
      - ./website:/usr/share/nginx/html:ro
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.website.rule=Host(`209.209.43.250`) || Host(`ferrylight.online`) || Host(`www.ferrylight.online`)"
      - "traefik.http.routers.website.entrypoints=websecure"
      - "traefik.http.routers.website.tls.certresolver=letsencrypt"
      - "traefik.http.routers.website.middlewares=secure-headers"
      - "traefik.http.services.website.loadbalancer.server.port=80"

  nodered:
    image: nodered/node-red:latest
    container_name: nodered
    restart: unless-stopped
    environment:
      - TZ=UTC
    volumes:
      - ./nodered:/data
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nodered.rule=Host(`209.209.43.250`) || Host(`nodered.ferrylight.online`)"
      - "traefik.http.routers.nodered.entrypoints=websecure"
      - "traefik.http.routers.nodered.tls.certresolver=letsencrypt"
      - "traefik.http.services.nodered.loadbalancer.server.port=1880"

  mosquitto:
    image: eclipse-mosquitto:latest
    container_name: mosquitto
    restart: unless-stopped
    ports:
      - "1883:1883"  # MQTT
      - "9001:9001"  # WebSocket
    volumes:
      - ./mosquitto/config:/mosquitto/config
      - ./mosquitto/data:/mosquitto/data
      - ./mosquitto/log:/mosquitto/log
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.tcp.routers.mosquitto.rule=HostSNI(`209.209.43.250`) || HostSNI(`mqtt.ferrylight.online`)"
      - "traefik.tcp.routers.mosquitto.entrypoints=websecure"
      - "traefik.tcp.routers.mosquitto.tls.certresolver=letsencrypt"
      - "traefik.tcp.services.mosquitto.loadbalancer.server.port=1883"
      - "traefik.http.routers.mosquitto-ws.rule=Host(`209.209.43.250`) || Host(`mqtt.ferrylight.online`)"
      - "traefik.http.routers.mosquitto-ws.entrypoints=websecure"
      - "traefik.http.routers.mosquitto-ws.tls.certresolver=letsencrypt"
      - "traefik.http.services.mosquitto-ws.loadbalancer.server.port=9001"

networks:
  traefik-public:
    external: true
EOF

# Stop current services
print_status "Stopping current services..."
docker-compose down

# Start with temporary configuration
print_status "Starting services with IP-based access..."
docker-compose -f docker-compose-temp.yml up -d

print_success "Services started with IP-based access!"
echo ""
echo "🌐 Test URLs (using IP address):"
echo "================================"
echo "🌐 Main Website: https://209.209.43.250"
echo "🐳 Portainer: https://209.209.43.250 (same IP, different path)"
echo "🔧 Traefik Dashboard: https://209.209.43.250 (admin:admin)"
echo "🔴 Node-RED: https://209.209.43.250 (same IP, different path)"
echo ""
echo "⚠️  Note: You may get SSL certificate warnings since we're using IP instead of domain"
echo "   This is normal and expected until DNS is configured."
echo ""
echo "🔧 To restore domain-only access after DNS is configured:"
echo "   docker-compose down"
echo "   docker-compose up -d" 