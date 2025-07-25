#!/bin/bash

# FerryLightV2 Container Fix Script

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

echo "🐳 FerryLightV2 Container Fix"
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

print_status "Fixing container issues..."

# Stop all containers and remove orphans
print_status "Stopping all containers and removing orphans..."
docker-compose down --remove-orphans

# Clean up any dangling containers
print_status "Cleaning up dangling containers..."
docker container prune -f

# Check if all required images are available
print_status "Checking Docker images..."
docker images | grep -E "(traefik|portainer|nginx|nodered|mosquitto)" || print_warning "Some images may be missing"

# Start services with proper configuration
print_status "Starting services with proper configuration..."
docker-compose up -d

# Wait for services to start
print_status "Waiting for services to start..."
sleep 10

# Check service status
print_status "Checking service status..."
docker-compose ps

echo ""
print_status "Checking container logs for errors..."

# Check each service's logs
services=("traefik" "portainer" "website" "nodered" "mosquitto")

for service in "${services[@]}"; do
    echo ""
    print_status "=== $service logs (last 5 lines) ==="
    docker-compose logs $service --tail=5 2>/dev/null || print_warning "No logs for $service"
done

echo ""
print_status "Testing basic connectivity..."

# Test if Traefik is responding
if curl -s http://209.209.43.250:8080 > /dev/null; then
    print_success "Traefik dashboard is accessible"
else
    print_error "Traefik dashboard is not accessible"
fi

# Test if website is responding via Traefik
if curl -s http://209.209.43.250 > /dev/null; then
    print_success "Website is accessible via IP"
else
    print_error "Website is not accessible via IP"
fi

echo ""
print_status "SSL Certificate Status:"
echo "============================"

# Check if SSL certificates exist
if [ -f "traefik/acme/acme.json" ]; then
    print_success "SSL certificate file exists"
    echo "Certificate file size: $(ls -lh traefik/acme/acme.json | awk '{print $5}')"
else
    print_warning "No SSL certificate file found yet"
    print_status "SSL certificates will be generated automatically"
fi

echo ""
print_status "Testing domain access..."

# Test domain access
domains=("ferrylight.online" "www.ferrylight.online" "portainer.ferrylight.online")

for domain in "${domains[@]}"; do
    echo -n "Testing $domain: "
    if curl -s -I http://$domain | grep -q "HTTP"; then
        print_success "✅ Responding"
    else
        print_error "❌ Not responding"
    fi
done

echo ""
print_success "Container fix completed!"
echo ""
echo "🌐 Test URLs:"
echo "============="
echo "🔧 Traefik Dashboard: http://209.209.43.250:8080 (admin:admin)"
echo "🌐 Website (IP): http://209.209.43.250"
echo "🌐 Website (Domain): http://ferrylight.online"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. Check Traefik dashboard for routing issues"
echo "2. Wait 5-10 minutes for SSL certificate generation"
echo "3. Test HTTPS access once certificates are ready"
echo "4. If issues persist, check firewall settings" 