#!/bin/bash

# FerryLightV2 Namecheap DNS Fix Script

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

echo "🌐 FerryLightV2 Namecheap DNS Fix"
echo "================================="

echo ""
print_warning "DNS CONFIGURATION ISSUES DETECTED:"
echo "=========================================="
echo ""
echo "❌ PROBLEM: You have conflicting CNAME and A records"
echo "   - CNAME records for www, portainer pointing to ferrylight.online"
echo "   - A records for the same subdomains pointing to 209.209.43.250"
echo ""
echo "✅ SOLUTION: Remove CNAME records and use only A records"
echo ""

echo "📋 CORRECT DNS CONFIGURATION FOR NAMECHEAP:"
echo "==========================================="
echo ""
echo "Remove these CNAME records:"
echo "  ❌ www → ferrylight.online (CNAME)"
echo "  ❌ portainer → ferrylight.online (CNAME)"
echo ""
echo "Keep/Add these A records:"
echo "  ✅ @ → 209.209.43.250 (A Record)"
echo "  ✅ www → 209.209.43.250 (A Record)"
echo "  ✅ portainer → 209.209.43.250 (A Record)"
echo "  ✅ traefik → 209.209.43.250 (A Record)"
echo "  ✅ nodered → 209.209.43.250 (A Record)"
echo "  ✅ mqtt → 209.209.43.250 (A Record)"
echo ""

print_status "Step-by-step instructions for Namecheap:"
echo ""
echo "1. Log into your Namecheap account"
echo "2. Go to 'Domain List' → 'Manage' for ferrylight.online"
echo "3. Click on 'Advanced DNS'"
echo "4. Remove these CNAME records:"
echo "   - www → ferrylight.online"
echo "   - portainer → ferrylight.online"
echo "5. Ensure these A records exist:"
echo "   - @ → 209.209.43.250"
echo "   - www → 209.209.43.250"
echo "   - portainer → 209.209.43.250"
echo "   - traefik → 209.209.43.250"
echo "   - nodered → 209.209.43.250"
echo "   - mqtt → 209.209.43.250"
echo "6. Set TTL to 'Automatic' or '300'"
echo "7. Save changes"
echo ""

print_warning "After fixing DNS, wait 5-15 minutes for propagation"
echo ""

print_status "Testing DNS resolution..."
echo ""

# Test DNS resolution
echo "Testing DNS resolution:"
echo "======================="

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
print_status "SSL Certificate Fix:"
echo "=========================="
echo ""
echo "The SSL error occurs because:"
echo "1. DNS conflicts prevent proper certificate generation"
echo "2. Let's Encrypt can't verify domain ownership"
echo ""
echo "After fixing DNS, restart services:"
echo ""

PROJECT_DIR="/opt/ferrylightv2"
if [ -d "$PROJECT_DIR" ]; then
    echo "cd $PROJECT_DIR"
    echo "docker-compose down"
    echo "docker-compose up -d"
    echo ""
    echo "This will trigger new SSL certificate generation."
    echo ""
    print_warning "SSL certificates will be generated automatically once DNS is correct"
else
    print_error "Project directory not found. Please run setup_ferrylight.sh first."
fi

echo ""
print_status "Final Test URLs (after DNS fix):"
echo "======================================="
echo "🌐 Main Website: https://ferrylight.online"
echo "🐳 Portainer: https://portainer.ferrylight.online"
echo "🔧 Traefik: https://traefik.ferrylight.online"
echo "🔴 Node-RED: https://nodered.ferrylight.online"
echo "🔌 MQTT Broker: mqtt.ferrylight.online:1883"
echo ""
print_warning "Remember: DNS changes can take 5-15 minutes to propagate globally" 