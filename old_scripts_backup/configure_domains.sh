#!/bin/bash

# FerryLightV2 Domain Configuration Script

set -e

PROJECT_DIR="/opt/ferrylightv2"

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

echo "🌐 FerryLightV2 Domain Configuration"
echo "===================================="

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found. Please run setup_server.sh first."
    exit 1
fi

# Get domain information
echo ""
echo "Please provide your domain information:"
echo ""

read -p "Enter your main domain (e.g., example.com): " MAIN_DOMAIN
read -p "Enter subdomain for Portainer (default: portainer): " PORTAINER_SUBDOMAIN
read -p "Enter subdomain for Traefik (default: traefik): " TRAEFIK_SUBDOMAIN
read -p "Enter email for Let's Encrypt (default: admin@$MAIN_DOMAIN): " EMAIL

# Set defaults
PORTAINER_SUBDOMAIN=${PORTAINER_SUBDOMAIN:-portainer}
TRAEFIK_SUBDOMAIN=${TRAEFIK_SUBDOMAIN:-traefik}
EMAIL=${EMAIL:-admin@$MAIN_DOMAIN}

print_status "Configuring domains..."
print_status "Main domain: $MAIN_DOMAIN"
print_status "Portainer: $PORTAINER_SUBDOMAIN.$MAIN_DOMAIN"
print_status "Traefik: $TRAEFIK_SUBDOMAIN.$MAIN_DOMAIN"
print_status "Email: $EMAIL"

# Update Traefik configuration
print_status "Updating Traefik configuration..."
sed -i "s/admin@ferrylightv2.com/$EMAIL/g" $PROJECT_DIR/traefik/traefik.yml

# Update Docker Compose file
print_status "Updating Docker Compose configuration..."
cd $PROJECT_DIR

# Create backup
cp docker-compose.yml docker-compose.yml.backup

# Update the docker-compose.yml with new domains
sed -i "s/traefik\.ferrylightv2\.com/$TRAEFIK_SUBDOMAIN.$MAIN_DOMAIN/g" docker-compose.yml
sed -i "s/portainer\.ferrylightv2\.com/$PORTAINER_SUBDOMAIN.$MAIN_DOMAIN/g" docker-compose.yml
sed -i "s/ferrylightv2\.com/$MAIN_DOMAIN/g" docker-compose.yml
sed -i "s/www\.ferrylightv2\.com/www.$MAIN_DOMAIN/g" docker-compose.yml

# Update website links
print_status "Updating website links..."
sed -i "s/portainer\.ferrylightv2\.com/$PORTAINER_SUBDOMAIN.$MAIN_DOMAIN/g" website/index.html
sed -i "s/traefik\.ferrylightv2\.com/$TRAEFIK_SUBDOMAIN.$MAIN_DOMAIN/g" website/index.html

# Restart services
print_status "Restarting services with new configuration..."
docker-compose down
docker-compose up -d

print_success "Domain configuration completed!"
echo ""
echo "📋 Updated URLs:"
echo "================"
echo "🌐 Main Website: https://$MAIN_DOMAIN"
echo "🐳 Portainer: https://$PORTAINER_SUBDOMAIN.$MAIN_DOMAIN"
echo "🔧 Traefik: https://$TRAEFIK_SUBDOMAIN.$MAIN_DOMAIN"
echo ""
echo "⚠️  IMPORTANT: Make sure your DNS records point to this server:"
echo "   - A record for $MAIN_DOMAIN"
echo "   - A record for $PORTAINER_SUBDOMAIN.$MAIN_DOMAIN"
echo "   - A record for $TRAEFIK_SUBDOMAIN.$MAIN_DOMAIN"
echo "   - A record for www.$MAIN_DOMAIN"
echo ""
print_warning "SSL certificates will be automatically generated once DNS is configured." 