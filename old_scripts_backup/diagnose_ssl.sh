#!/bin/bash

# FerryLightV2 SSL and Routing Diagnostic Script

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

echo "🔍 FerryLightV2 SSL and Routing Diagnostic"
echo "=========================================="

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

echo ""
print_status "1. Checking container status..."
docker-compose ps

echo ""
print_status "2. Checking Traefik logs (last 20 lines)..."
docker-compose logs traefik --tail=20

echo ""
print_status "3. Checking if SSL certificates exist..."
if [ -f "traefik/acme/acme.json" ]; then
    print_success "SSL certificate file exists"
    ls -la traefik/acme/
else
    print_warning "No SSL certificate file found yet"
fi

echo ""
print_status "4. Testing HTTP to HTTPS redirect..."
echo "Testing http://ferrylight.online (should redirect to https):"
curl -I http://ferrylight.online 2>/dev/null | head -5 || print_error "HTTP request failed"

echo ""
print_status "5. Testing HTTPS connection..."
echo "Testing https://ferrylight.online:"
curl -I https://ferrylight.online 2>/dev/null | head -5 || print_error "HTTPS request failed"

echo ""
print_status "6. Checking Traefik dashboard..."
echo "Testing http://209.209.43.250:8080:"
curl -I http://209.209.43.250:8080 2>/dev/null | head -3 || print_error "Traefik dashboard not accessible"

echo ""
print_status "7. Checking container network connectivity..."
echo "Testing if containers can reach each other:"

# Test if Traefik can reach the website container
if docker exec traefik wget -qO- http://ferrylightv2-website:80 > /dev/null 2>&1; then
    print_success "Traefik can reach website container"
else
    print_error "Traefik cannot reach website container"
fi

# Test if Traefik can reach the portainer container
if docker exec traefik wget -qO- http://portainer:9000 > /dev/null 2>&1; then
    print_success "Traefik can reach portainer container"
else
    print_error "Traefik cannot reach portainer container"
fi

echo ""
print_status "8. Checking Traefik configuration..."
echo "=== Traefik Configuration ==="
cat traefik/traefik.yml

echo ""
print_status "9. Checking Docker Compose labels..."
echo "=== Service Labels ==="
grep -A 10 "traefik.enable=true" docker-compose.yml

echo ""
print_status "10. Testing direct container access..."
echo "Testing website container directly:"
if docker exec ferrylightv2-website curl -s http://localhost > /dev/null; then
    print_success "Website container is responding internally"
else
    print_error "Website container is not responding internally"
fi

echo ""
print_warning "DIAGNOSIS AND SOLUTIONS:"
echo "=============================="
echo ""
echo "If you're getting 404 errors:"
echo "1. Check if Traefik dashboard shows the routes"
echo "2. Verify SSL certificates are being generated"
echo "3. Check if containers are healthy"
echo ""
echo "If you're getting SSL errors:"
echo "1. SSL certificates may still be generating"
echo "2. Wait 5-10 minutes for Let's Encrypt"
echo "3. Check Traefik logs for certificate errors"
echo ""
echo "Quick fixes to try:"
echo "1. Check Traefik dashboard: http://209.209.43.250:8080"
echo "2. Wait for SSL certificate generation"
echo "3. Try accessing via IP first: http://209.209.43.250"
echo "4. Check if firewall is blocking ports 80/443" 