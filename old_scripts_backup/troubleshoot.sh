#!/bin/bash

# FerryLightV2 Troubleshooting Script

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

echo "🔍 FerryLightV2 Troubleshooting"
echo "==============================="

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
print_status "2. Checking Traefik logs..."
docker-compose logs traefik --tail=20

echo ""
print_status "3. Checking if services are accessible internally..."

# Test website container
if docker exec ferrylightv2-website curl -s http://localhost > /dev/null; then
    print_success "Website container is responding internally"
else
    print_error "Website container is not responding internally"
fi

# Test Portainer container
if docker exec portainer wget -qO- http://localhost:9000 > /dev/null 2>&1; then
    print_success "Portainer container is responding internally"
else
    print_error "Portainer container is not responding internally"
fi

echo ""
print_status "4. Checking Traefik dashboard..."
echo "Traefik dashboard should be available at: http://209.209.43.250:8080"
echo "Username: admin, Password: admin"

echo ""
print_status "5. Testing direct access to containers..."

# Test website on port 80
if curl -s http://209.209.43.250 > /dev/null; then
    print_success "Website accessible via IP on port 80"
else
    print_error "Website not accessible via IP on port 80"
fi

# Test Traefik dashboard
if curl -s http://209.209.43.250:8080 > /dev/null; then
    print_success "Traefik dashboard accessible via IP on port 8080"
else
    print_error "Traefik dashboard not accessible via IP on port 8080"
fi

echo ""
print_status "6. Checking DNS resolution..."
echo "Testing DNS resolution for ferrylight.online:"
nslookup ferrylight.online || print_warning "DNS resolution failed"

echo ""
print_status "7. Checking firewall status..."
sudo ufw status

echo ""
print_status "8. Checking port status..."
sudo netstat -tlnp | grep -E ':(80|443|8080|1883)' || print_warning "No services found on expected ports"

echo ""
print_status "9. Checking Traefik configuration..."
echo "=== Traefik Configuration ==="
cat traefik/traefik.yml

echo ""
print_status "10. Checking Docker Compose configuration..."
echo "=== Docker Compose Labels ==="
grep -A 5 "traefik.enable=true" docker-compose.yml

echo ""
print_warning "TROUBLESHOOTING STEPS:"
echo "============================"
echo ""
echo "1. DNS Configuration:"
echo "   - Add A records pointing to 209.209.43.250:"
echo "     * ferrylight.online"
echo "     * www.ferrylight.online"
echo "     * portainer.ferrylight.online"
echo "     * traefik.ferrylight.online"
echo "     * nodered.ferrylight.online"
echo "     * mqtt.ferrylight.online"
echo ""
echo "2. Test with IP address first:"
echo "   - Website: http://209.209.43.250"
echo "   - Traefik Dashboard: http://209.209.43.250:8080"
echo ""
echo "3. Check Traefik dashboard for routing issues:"
echo "   - Visit http://209.209.43.250:8080"
echo "   - Check HTTP routers and services"
echo ""
echo "4. If DNS is configured, wait 5-15 minutes for propagation"
echo ""
echo "5. Check container logs for specific errors:"
echo "   docker-compose logs traefik"
echo "   docker-compose logs portainer"
echo "   docker-compose logs ferrylightv2-website" 