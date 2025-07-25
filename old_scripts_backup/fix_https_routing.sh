#!/bin/bash

# FerryLightV2 HTTPS Routing Fix Script

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

echo "🔒 FerryLightV2 HTTPS Routing Fix"
echo "================================="

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

print_status "Analysis: Traefik logs show HTTP→HTTPS redirects but HTTPS 404 errors"
print_status "This indicates SSL certificate or HTTPS routing issues"

echo ""
print_status "Step 1: Checking SSL certificate status..."
if [ -f "traefik/acme/acme.json" ]; then
    cert_size=$(stat -c%s "traefik/acme/acme.json")
    if [ $cert_size -gt 100 ]; then
        print_success "SSL certificates exist (${cert_size} bytes)"
    else
        print_warning "SSL certificate file is too small (${cert_size} bytes)"
    fi
else
    print_error "No SSL certificate file found"
fi

echo ""
print_status "Step 2: Creating temporary HTTP-only configuration..."

# Backup current configuration
cp docker-compose.yml docker-compose.yml.backup-$(date +%s)

# Create HTTP-only configuration
cat > docker-compose-http.yml << 'EOF'
services:
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - traefik-public
    command:
      - "--api.dashboard=true"
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--providers.docker.network=traefik-public"
      - "--entrypoints.web.address=:80"
      - "--log.level=INFO"

  website:
    image: nginx:alpine
    container_name: ferrylightv2-website
    restart: unless-stopped
    volumes:
      - ./website:/usr/share/nginx/html:ro
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.website.rule=Host(`ferrylight.online`) || Host(`www.ferrylight.online`) || Host(`209.209.43.250`)"
      - "traefik.http.routers.website.entrypoints=web"
      - "traefik.http.services.website.loadbalancer.server.port=80"

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./portainer:/data
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.rule=Host(`portainer.ferrylight.online`)"
      - "traefik.http.routers.portainer.entrypoints=web"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"

networks:
  traefik-public:
    external: true
EOF

echo ""
print_status "Step 3: Testing with HTTP-only configuration..."
docker-compose down
docker-compose -f docker-compose-http.yml up -d

echo ""
print_status "Step 4: Waiting for services to start..."
sleep 10

echo ""
print_status "Step 5: Testing HTTP access..."

# Test different ways to access the site
test_urls=(
    "http://ferrylight.online"
    "http://www.ferrylight.online"
    "http://209.209.43.250"
)

for url in "${test_urls[@]}"; do
    echo -n "Testing $url: "
    if curl -s -I "$url" | grep -q "HTTP.*200"; then
        print_success "✅ Working"
    else
        print_error "❌ Not working"
    fi
done

echo ""
print_status "Step 6: Checking Traefik dashboard..."
if curl -s http://209.209.43.250:8080 | grep -q "Traefik"; then
    print_success "✅ Traefik dashboard accessible at http://209.209.43.250:8080"
else
    print_error "❌ Traefik dashboard not accessible"
fi

echo ""
print_status "Step 7: Showing current routing status..."
echo "Visit http://209.209.43.250:8080 to see:"
echo "- HTTP Routers section"
echo "- Services section"
echo "- Any error messages"

read -p "Press Enter after checking the dashboard to continue..."

echo ""
print_status "Step 8: Restoring HTTPS configuration with fixes..."

# Create improved HTTPS configuration
cat > docker-compose-https.yml << EOF
services:
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik/traefik.yml:/etc/traefik/traefik.yml:ro
      - ./traefik/acme:/etc/traefik/acme
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.rule=Host(\`traefik.ferrylight.online\`)"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik.service=api@internal"

  website:
    image: nginx:alpine
    container_name: ferrylightv2-website
    restart: unless-stopped
    volumes:
      - ./website:/usr/share/nginx/html:ro
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.website.rule=Host(\`ferrylight.online\`) || Host(\`www.ferrylight.online\`)"
      - "traefik.http.routers.website.entrypoints=websecure"
      - "traefik.http.routers.website.tls.certresolver=letsencrypt"
      - "traefik.http.services.website.loadbalancer.server.port=80"

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./portainer:/data
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.rule=Host(\`portainer.ferrylight.online\`)"
      - "traefik.http.routers.portainer.entrypoints=websecure"
      - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"

networks:
  traefik-public:
    external: true
EOF

# Update the main configuration
cp docker-compose-https.yml docker-compose.yml

echo ""
print_status "Step 9: Clearing SSL certificates and restarting..."
sudo rm -f traefik/acme/acme.json
docker-compose -f docker-compose-http.yml down
docker-compose up -d

echo ""
print_success "HTTPS routing fix completed!"
echo ""
echo "🔧 Test Results:"
echo "================"
echo "1. HTTP access should work now"
echo "2. HTTPS certificates will regenerate (5-10 minutes)"
echo "3. Check Traefik dashboard for routing status"
echo ""
echo "🌐 Test URLs:"
echo "============="
echo "🔧 Traefik Dashboard: http://209.209.43.250:8080"
echo "🌐 Website (HTTP): http://ferrylight.online"
echo "🌐 Website (HTTPS): https://ferrylight.online (wait for certificates)"
echo "🐳 Portainer: https://portainer.ferrylight.online (wait for certificates)"
echo ""
print_warning "SSL certificates will be generated automatically"
print_warning "Check Traefik dashboard for certificate generation progress" 