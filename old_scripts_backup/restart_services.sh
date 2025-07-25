#!/bin/bash

# FerryLightV2 Service Restart Script
# Author: Markus van Kempen - markus.van.kempen@gmail.com
# Date: 24-July-2025

set -e

PROJECT_DIR="/opt/ferrylightv2"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

echo "🔄 Restarting FerryLightV2 Services"
echo "=================================="
echo ""

if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    print_warning "Docker Compose file not found!"
    print_warning "Please run the setup scripts first."
    exit 1
fi

cd $PROJECT_DIR

print_status "Stopping all services..."
docker-compose down

print_status "Starting all services..."
docker-compose up -d

print_status "Waiting for services to start..."
sleep 15

print_status "Checking service status..."
docker-compose ps

print_success "Services restarted!"
echo ""
echo "🌐 Test URLs:"
echo "============="
echo "• Main Website: https://ferrylight.online"
echo "• Traefik Dashboard: https://traefik.ferrylight.online"
echo "• Portainer: https://portainer.ferrylight.online"
echo "• Node-RED: https://nodered.ferrylight.online"
echo ""
echo "🔧 Direct IP Access (if DNS not configured):"
echo "============================================="
echo "• Traefik Dashboard: http://209.209.43.250:8080"
echo "• Website: http://209.209.43.250"
echo ""
print_warning "If you still get 404 errors, run: ./troubleshoot_404.sh" 