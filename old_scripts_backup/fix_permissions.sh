#!/bin/bash

# Quick Permission Fix Script
# Author: Markus van Kempen - markus.van.kempen@gmail.com
# Date: 24-July-2025

set -e

PROJECT_DIR="/opt/ferrylightv2"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

echo "🔧 Fixing Permissions for FerryLightV2"
echo "======================================"
echo ""

print_status "Setting ownership to current user..."
sudo chown -R $USER:$USER $PROJECT_DIR

print_status "Setting proper permissions..."
sudo chmod -R 755 $PROJECT_DIR

print_status "Setting specific permissions for sensitive files..."
chmod 600 $PROJECT_DIR/traefik/acme/acme.json 2>/dev/null || print_status "No existing acme.json"
chmod 700 $PROJECT_DIR/traefik/acme

print_status "Verifying permissions..."
ls -la $PROJECT_DIR/mosquitto/config/
ls -la $PROJECT_DIR/nodered/
ls -la $PROJECT_DIR/website/

print_success "Permissions fixed! You can now continue with the setup."
echo ""
echo "Next steps:"
echo "1. Run: ./setup_part2_config.sh (if you were on that step)"
echo "2. Or run: ./setup_master.sh (to start from the beginning)"
echo "" 