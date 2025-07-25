#!/bin/bash

# FerryLightV2 Quick 404 Fix Script

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

echo "🔧 FerryLightV2 Quick 404 Fix"
echo "============================="

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

print_status "Step 1: Checking current Traefik logs..."
echo "=== Traefik Logs (last 10 lines) ==="
docker-compose logs traefik --tail=10

echo ""
print_status "Step 2: Checking if Traefik dashboard is accessible..."
if curl -s http://209.209.43.250:8080 > /dev/null; then
    print_success "Traefik dashboard is accessible"
    echo "Visit: http://209.209.43.250:8080 (admin:admin)"
else
    print_error "Traefik dashboard is not accessible"
fi

echo ""
print_status "Step 3: Testing direct container access..."
echo "Testing website container:"
if docker exec ferrylightv2-website curl -s http://localhost > /dev/null; then
    print_success "Website container is working"
else
    print_error "Website container is not working"
fi

echo ""
print_status "Step 4: Checking Traefik configuration..."
echo "=== Current docker-compose.yml labels ==="
grep -A 5 "traefik.enable=true" docker-compose.yml

echo ""
print_status "Step 5: Creating simplified configuration for testing..."

# Create a simplified docker-compose file for testing
cat > docker-compose-simple.yml << 'EOF'
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
      - "traefik.http.routers.traefik.rule=Host(`209.209.43.250`)"
      - "traefik.http.routers.traefik.entrypoints=web"
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
      - "traefik.http.routers.website.rule=Host(`209.209.43.250`)"
      - "traefik.http.routers.website.entrypoints=web"
      - "traefik.http.services.website.loadbalancer.server.port=80"

networks:
  traefik-public:
    external: true
EOF

# Create simplified Traefik config
cat > traefik/traefik-simple.yml << 'EOF'
api:
  dashboard: true
  insecure: true

entryPoints:
  web:
    address: ":80"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: traefik-public

log:
  level: DEBUG

accessLog: {}
EOF

echo ""
print_status "Step 6: Testing with simplified configuration..."
docker-compose down
docker-compose -f docker-compose-simple.yml up -d

echo ""
print_status "Step 7: Waiting for services to start..."
sleep 5

echo ""
print_status "Step 8: Testing simplified setup..."
echo "Testing http://209.209.43.250:"
if curl -s http://209.209.43.250 | grep -q "FerryLightV2"; then
    print_success "✅ Website is working with simplified config!"
else
    print_error "❌ Website still not working"
fi

echo ""
print_status "Step 9: Restoring full configuration..."
docker-compose -f docker-compose-simple.yml down
docker-compose up -d

echo ""
print_success "Quick fix completed!"
echo ""
echo "🔧 Troubleshooting Results:"
echo "==========================="
echo "1. Check Traefik dashboard: http://209.209.43.250:8080"
echo "2. Look for routing errors in the dashboard"
echo "3. Check if SSL certificates are being generated"
echo ""
echo "🌐 Test URLs:"
echo "============="
echo "🔧 Traefik Dashboard: http://209.209.43.250:8080 (admin:admin)"
echo "🌐 Website (HTTP): http://209.209.43.250"
echo "🌐 Website (HTTPS): https://209.209.43.250 (may show SSL warning)"
echo ""
print_warning "If simplified config worked but full config doesn't, there's a routing issue"
print_warning "Check Traefik dashboard for specific error messages" 