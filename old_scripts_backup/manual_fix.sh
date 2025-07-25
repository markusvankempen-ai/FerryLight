#!/bin/bash

# FerryLightV2 Manual Fix Script

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

echo "🔧 FerryLightV2 Manual Fix"
echo "=========================="

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

print_status "Fixing permissions and completing domain configuration..."

# Fix permissions
print_status "Fixing file permissions..."
sudo chown -R $USER:$USER .
sudo chmod -R 755 .
sudo chmod 600 traefik/acme/acme.json 2>/dev/null || print_status "No existing acme.json"

# Clear SSL certificates with proper permissions
print_status "Clearing old SSL certificates..."
if [ -f "traefik/acme/acme.json" ]; then
    sudo rm -f traefik/acme/acme.json
    print_success "Old SSL certificates cleared"
else
    print_status "No existing SSL certificates found"
fi

# Ensure acme directory has correct permissions
print_status "Setting up SSL certificate directory..."
sudo chown -R $USER:$USER traefik/acme
chmod 700 traefik/acme

# Verify domain configuration
print_status "Verifying domain configuration..."
if grep -q "ferrylight.online" docker-compose.yml; then
    print_success "Domain configuration looks correct"
else
    print_error "Domain configuration still has issues"
    print_status "Running domain fix again..."
    sed -i "s/ferrylightv2\.com/ferrylight.online/g" docker-compose.yml
    sed -i "s/ferrylightv2\.com/ferrylight.online/g" traefik/traefik.yml
    sed -i "s/ferrylightv2\.com/ferrylight.online/g" website/index.html
fi

# Fix Mosquitto container name
print_status "Fixing Mosquitto container configuration..."
sed -i 's/container_name: mosquitto/container_name: mosquitto-broker/' docker-compose.yml

# Restart services
print_status "Restarting services..."
docker-compose down
docker-compose up -d

print_success "Manual fix completed!"
echo ""
echo "📋 Service Status:"
echo "=================="
docker-compose ps

echo ""
print_status "Testing DNS resolution..."
echo ""

# Test DNS resolution
domains=("ferrylight.online" "www.ferrylight.online" "portainer.ferrylight.online" "traefik.ferrylight.online" "nodered.ferrylight.online" "mqtt.ferrylight.online")

for domain in "${domains[@]}"; do
    echo -n "Testing $domain: "
    if nslookup $domain | grep -q "209.209.43.250"; then
        print_success "✅ Resolves to 209.209.43.250"
    else
        print_error "❌ Does not resolve to 209.209.43.250"
    fi
done

echo ""
print_status "Final URLs (after DNS propagation):"
echo "=========================================="
echo "🌐 Main Website: https://ferrylight.online"
echo "🐳 Portainer: https://portainer.ferrylight.online"
echo "🔧 Traefik: https://traefik.ferrylight.online"
echo "🔴 Node-RED: https://nodered.ferrylight.online"
echo "🔌 MQTT Broker: mqtt.ferrylight.online:1883"
echo ""
print_warning "SSL certificates will be generated automatically once DNS is correct"
print_warning "This may take a few minutes after DNS propagation" 