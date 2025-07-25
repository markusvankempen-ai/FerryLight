#!/bin/bash

# FerryLightV2 Network Fix Script

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

echo "🌐 FerryLightV2 Network Fix"
echo "==========================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Check if Docker is accessible
if ! docker info >/dev/null 2>&1; then
    print_error "Cannot connect to Docker daemon. Please run fix_docker_permissions.sh first."
    exit 1
fi

# Check if project directory exists
PROJECT_DIR="/opt/ferrylightv2"
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found. Please run setup_ferrylight.sh first."
    exit 1
fi

# Create Docker networks
print_status "Creating Docker networks..."

if ! docker network ls | grep -q traefik-public; then
    docker network create traefik-public
    print_success "Traefik network created"
else
    print_status "Traefik network already exists"
fi

if ! docker network ls | grep -q web; then
    docker network create web
    print_success "Web network created"
else
    print_status "Web network already exists"
fi

# List all networks
print_status "Available Docker networks:"
docker network ls

# Start services
print_status "Starting FerryLightV2 services..."
cd $PROJECT_DIR

# Remove obsolete version field from docker-compose.yml if it exists
if grep -q "^version:" docker-compose.yml; then
    print_status "Removing obsolete version field from docker-compose.yml..."
    sed -i '/^version:/d' docker-compose.yml
fi

# Start services
docker-compose up -d

print_success "Services started successfully!"
echo ""
echo "🔧 Service Status:"
echo "=================="
docker-compose ps

echo ""
echo "🌐 Your URLs:"
echo "============="
echo "🌐 Main Website: https://ferrylight.online"
echo "🐳 Portainer: https://portainer.ferrylight.online"
echo "🔧 Traefik: https://traefik.ferrylight.online"
echo "🔴 Node-RED: https://nodered.ferrylight.online"
echo "🔌 MQTT Broker: mqtt.ferrylight.online:1883"
echo ""
print_warning "Remember to configure DNS records pointing to 209.209.43.250" 