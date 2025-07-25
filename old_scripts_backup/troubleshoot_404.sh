#!/bin/bash

# FerryLightV2 404 Troubleshooting Script
# Author: Markus van Kempen - markus.van.kempen@gmail.com
# Date: 24-July-2025

set -e

# Configuration
DOMAIN="ferrylight.online"
SERVER_IP="209.209.43.250"
PROJECT_DIR="/opt/ferrylightv2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

print_step() {
    echo -e "${CYAN}Step $1: $2${NC}"
}

# Function to check Docker services
check_docker_services() {
    print_step "1" "Checking Docker Services"
    echo "================================"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        return 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Cannot connect to Docker daemon!"
        print_error "Run: sudo systemctl start docker"
        print_error "Then: newgrp docker"
        return 1
    fi
    
    print_status "Docker is running"
    
    if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
        print_error "Docker Compose file not found at $PROJECT_DIR/docker-compose.yml"
        print_error "Run the setup scripts first!"
        return 1
    fi
    
    cd $PROJECT_DIR
    print_status "Checking service status..."
    docker-compose ps
    
    print_status "Checking service logs..."
    echo "=== Traefik Logs ==="
    docker-compose logs traefik --tail=10
    echo ""
    echo "=== Website Logs ==="
    docker-compose logs website --tail=5
}

# Function to check DNS resolution
check_dns() {
    print_step "2" "Checking DNS Resolution"
    echo "============================="
    
    domains=("$DOMAIN" "www.$DOMAIN" "traefik.$DOMAIN" "portainer.$DOMAIN" "nodered.$DOMAIN" "mqtt.$DOMAIN")
    
    for domain in "${domains[@]}"; do
        echo -n "Testing $domain: "
        if nslookup $domain | grep -q "$SERVER_IP"; then
            print_success "✅ Resolves to $SERVER_IP"
        else
            print_error "❌ Does not resolve to $SERVER_IP"
            print_warning "Add A record: $domain → $SERVER_IP"
        fi
    done
}

# Function to check network connectivity
check_connectivity() {
    print_step "3" "Checking Network Connectivity"
    echo "====================================="
    
    print_status "Testing direct IP access..."
    
    # Test Traefik dashboard on port 8080
    if curl -s http://$SERVER_IP:8080 > /dev/null; then
        print_success "✅ Traefik dashboard accessible at http://$SERVER_IP:8080"
    else
        print_error "❌ Traefik dashboard not accessible at http://$SERVER_IP:8080"
    fi
    
    # Test HTTP port 80
    if curl -s http://$SERVER_IP > /dev/null; then
        print_success "✅ HTTP port 80 accessible"
    else
        print_error "❌ HTTP port 80 not accessible"
    fi
    
    # Test HTTPS port 443
    if curl -s -k https://$SERVER_IP > /dev/null; then
        print_success "✅ HTTPS port 443 accessible"
    else
        print_error "❌ HTTPS port 443 not accessible"
    fi
}

# Function to check Traefik configuration
check_traefik_config() {
    print_step "4" "Checking Traefik Configuration"
    echo "======================================"
    
    if [ ! -f "$PROJECT_DIR/traefik/traefik.yml" ]; then
        print_error "Traefik configuration not found!"
        return 1
    fi
    
    print_status "Traefik configuration file exists"
    
    if [ ! -f "$PROJECT_DIR/traefik/config/dynamic.yml" ]; then
        print_error "Traefik dynamic configuration not found!"
        return 1
    fi
    
    print_status "Traefik dynamic configuration exists"
    
    # Check if acme.json exists and has correct permissions
    if [ -f "$PROJECT_DIR/traefik/acme/acme.json" ]; then
        print_success "✅ ACME file exists"
        ls -la $PROJECT_DIR/traefik/acme/acme.json
    else
        print_warning "⚠️  ACME file does not exist (will be created when SSL is generated)"
    fi
}

# Function to check website files
check_website_files() {
    print_step "5" "Checking Website Files"
    echo "============================="
    
    if [ ! -f "$PROJECT_DIR/website/index.html" ]; then
        print_error "Website index.html not found!"
        return 1
    fi
    
    print_success "✅ Website index.html exists"
    
    if [ ! -f "$PROJECT_DIR/nginx.conf" ]; then
        print_error "Nginx configuration not found!"
        return 1
    fi
    
    print_success "✅ Nginx configuration exists"
}

# Function to restart services
restart_services() {
    print_step "6" "Restarting Services"
    echo "========================"
    
    cd $PROJECT_DIR
    
    print_status "Stopping all services..."
    docker-compose down
    
    print_status "Starting all services..."
    docker-compose up -d
    
    print_status "Waiting for services to start..."
    sleep 10
    
    print_status "Checking service status..."
    docker-compose ps
}

# Function to check firewall
check_firewall() {
    print_step "7" "Checking Firewall"
    echo "====================="
    
    if command -v ufw &> /dev/null; then
        print_status "UFW status:"
        sudo ufw status
    else
        print_warning "UFW not installed"
    fi
    
    print_status "Checking if ports are listening..."
    netstat -tlnp | grep -E ':(80|443|8080)' || print_warning "No services listening on ports 80, 443, or 8080"
}

# Function to provide solutions
provide_solutions() {
    print_step "8" "Solutions"
    echo "==========="
    
    echo ""
    print_header "🔧 Quick Fixes to Try:"
    echo ""
    echo "1. Restart services:"
    echo "   cd $PROJECT_DIR"
    echo "   docker-compose restart"
    echo ""
    echo "2. Check DNS configuration:"
    echo "   Add these A records in your DNS provider:"
    echo "   - $DOMAIN → $SERVER_IP"
    echo "   - www.$DOMAIN → $SERVER_IP"
    echo "   - traefik.$DOMAIN → $SERVER_IP"
    echo "   - portainer.$DOMAIN → $SERVER_IP"
    echo "   - nodered.$DOMAIN → $SERVER_IP"
    echo "   - mqtt.$DOMAIN → $SERVER_IP"
    echo ""
    echo "3. Test direct IP access:"
    echo "   http://$SERVER_IP:8080 (Traefik dashboard)"
    echo "   http://$SERVER_IP (Website)"
    echo ""
    echo "4. Check service logs:"
    echo "   docker-compose logs traefik"
    echo "   docker-compose logs website"
    echo ""
    echo "5. Re-run setup if needed:"
    echo "   ./setup_master.sh"
    echo ""
}

# Main execution
main() {
    print_header "🔍 FerryLightV2 404 Troubleshooting"
    echo "=========================================="
    echo ""
    echo "This script will help diagnose why you're getting 404 errors."
    echo ""
    
    # Run all checks
    check_docker_services
    echo ""
    check_dns
    echo ""
    check_connectivity
    echo ""
    check_traefik_config
    echo ""
    check_website_files
    echo ""
    check_firewall
    echo ""
    provide_solutions
    
    print_header "🎯 Next Steps:"
    echo "1. Check the output above for errors"
    echo "2. Try the quick fixes listed"
    echo "3. If issues persist, run: ./restart_services.sh"
    echo "4. For complete reset: ./setup_master.sh"
}

# Run main function
main "$@" 