#!/bin/bash

# FerryLightV2 Domain Configuration Fix Script

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

echo "🌐 FerryLightV2 Domain Configuration Fix"
echo "========================================"

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

# Domain configuration
OLD_DOMAIN="ferrylightv2.com"
NEW_DOMAIN="ferrylight.online"

print_status "Fixing domain configuration..."
print_status "Old domain: $OLD_DOMAIN"
print_status "New domain: $NEW_DOMAIN"

# Create backup
print_status "Creating backup of current configuration..."
cp docker-compose.yml docker-compose.yml.backup
cp traefik/traefik.yml traefik/traefik.yml.backup

# Fix docker-compose.yml
print_status "Updating docker-compose.yml..."
sed -i "s/$OLD_DOMAIN/$NEW_DOMAIN/g" docker-compose.yml

# Fix Traefik configuration
print_status "Updating Traefik configuration..."
sed -i "s/$OLD_DOMAIN/$NEW_DOMAIN/g" traefik/traefik.yml

# Fix website links
print_status "Updating website links..."
sed -i "s/$OLD_DOMAIN/$NEW_DOMAIN/g" website/index.html

# Clear old SSL certificates
print_status "Clearing old SSL certificates..."
if [ -f "traefik/acme/acme.json" ]; then
    sudo rm -f traefik/acme/acme.json
    print_success "Old SSL certificates cleared"
else
    print_status "No existing SSL certificates found"
fi

# Fix permissions on acme directory
print_status "Fixing permissions on SSL certificate directory..."
sudo chown -R $USER:$USER traefik/acme
chmod 600 traefik/acme/acme.json 2>/dev/null || print_status "No existing acme.json to set permissions"

# Fix the secure-headers middleware issue
print_status "Fixing secure-headers middleware configuration..."

# Update the dynamic configuration
cat > traefik/config/dynamic.yml << 'EOF'
http:
  middlewares:
    secure-headers:
      headers:
        frameDeny: true
        sslRedirect: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 31536000
        customFrameOptionsValue: "SAMEORIGIN"
        customRequestHeaders:
          X-Forwarded-Proto: "https"
EOF

# Fix Mosquitto container name issue
print_status "Fixing Mosquitto container configuration..."

# Update docker-compose.yml to fix Mosquitto
sed -i 's/container_name: mosquitto/container_name: mosquitto-broker/' docker-compose.yml

# Restart services
print_status "Restarting services with corrected configuration..."
docker-compose down
docker-compose up -d

print_success "Domain configuration fixed!"
echo ""
echo "📋 Updated Configuration:"
echo "========================"
echo "✅ Domain: $NEW_DOMAIN"
echo "✅ SSL certificates will be regenerated"
echo "✅ Mosquitto container name fixed"
echo "✅ Secure-headers middleware fixed"
echo ""

print_status "Testing DNS resolution..."
echo ""

# Test DNS resolution
domains=("$NEW_DOMAIN" "www.$NEW_DOMAIN" "portainer.$NEW_DOMAIN" "traefik.$NEW_DOMAIN" "nodered.$NEW_DOMAIN" "mqtt.$NEW_DOMAIN")

for domain in "${domains[@]}"; do
    echo -n "Testing $domain: "
    if nslookup $domain | grep -q "209.209.43.250"; then
        print_success "✅ Resolves to 209.209.43.250"
    else
        print_error "❌ Does not resolve to 209.209.43.250"
    fi
done

echo ""
print_status "Service Status:"
echo "==================="
docker-compose ps

echo ""
print_status "Final URLs (after DNS propagation):"
echo "=========================================="
echo "🌐 Main Website: https://$NEW_DOMAIN"
echo "🐳 Portainer: https://portainer.$NEW_DOMAIN"
echo "🔧 Traefik: https://traefik.$NEW_DOMAIN"
echo "🔴 Node-RED: https://nodered.$NEW_DOMAIN"
echo "🔌 MQTT Broker: mqtt.$NEW_DOMAIN:1883"
echo ""
print_warning "SSL certificates will be generated automatically once DNS is correct"
print_warning "This may take a few minutes after DNS propagation" 