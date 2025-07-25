#!/bin/bash

# FerryLightV2 Master Setup Script
# Author: Markus van Kempen - markus.van.kempen@gmail.com
# Date: 24-July-2025

set -e

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

# Function to check if script exists
check_script() {
    local script=$1
    if [ ! -f "$script" ]; then
        print_error "Script not found: $script"
        exit 1
    fi
}

# Function to make scripts executable
make_executable() {
    print_status "Making scripts executable..."
    chmod +x setup_part1_docker.sh
    chmod +x setup_part2_config.sh
    chmod +x setup_part3_services.sh
    print_success "Scripts made executable"
}

# Function to run part 1
run_part1() {
    print_step "1" "Running Part 1: Docker Installation"
    echo "============================================="
    ./setup_part1_docker.sh
    print_success "Part 1 completed"
}

# Function to run part 2
run_part2() {
    print_step "2" "Running Part 2: Configuration Files"
    echo "============================================="
    ./setup_part2_config.sh
    print_success "Part 2 completed"
}

# Function to run part 3
run_part3() {
    print_step "3" "Running Part 3: Services and Deployment"
    echo "================================================="
    ./setup_part3_services.sh
    print_success "Part 3 completed"
}

# Function to show final instructions
show_final_instructions() {
    print_header "🎉 FerryLightV2 Complete Setup Finished!"
    echo ""
    echo "📋 Setup Summary:"
    echo "=================="
    echo "✅ Part 1: Docker Installation - COMPLETED"
    echo "✅ Part 2: Configuration Files - COMPLETED"
    echo "✅ Part 3: Services and Deployment - COMPLETED"
    echo ""
    echo "🌐 Your Services:"
    echo "================"
    echo "🌐 Main Website: https://ferrylight.online"
    echo "🐳 Portainer: https://portainer.ferrylight.online"
    echo "🔧 Traefik: https://traefik.ferrylight.online"
    echo "🔴 Node-RED: https://nodered.ferrylight.online"
    echo "🔌 MQTT Broker: mqtt.ferrylight.online:1883"
    echo ""
    echo "🔐 Service Credentials:"
    echo "======================="
    echo "Traefik Dashboard: admin:ferrylight2024"
    echo "Node-RED: admin:ferrylight2024"
    echo "Portainer: Create admin account on first visit"
    echo "MQTT: Anonymous access (open)"
    echo ""
    echo "⚠️  IMPORTANT: Configure DNS Records"
    echo "===================================="
    echo "Add these A records in your DNS provider:"
    echo "  - ferrylight.online → 209.209.43.250"
    echo "  - www.ferrylight.online → 209.209.43.250"
    echo "  - portainer.ferrylight.online → 209.209.43.250"
    echo "  - traefik.ferrylight.online → 209.209.43.250"
    echo "  - nodered.ferrylight.online → 209.209.43.250"
    echo "  - mqtt.ferrylight.online → 209.209.43.250"
    echo ""
    echo "📄 Documentation:"
    echo "================="
    echo "• Complete guide: DEPLOYMENT_GUIDE.md"
    echo "• Server docs: /opt/ferrylightv2/README.md"
    echo ""
    print_warning "Please reboot the system to ensure all changes take effect."
    print_warning "After DNS configuration, SSL certificates will be automatically generated."
}

# Main execution
main() {
    print_header "🚀 FerryLightV2 Master Setup Script"
    echo "=========================================="
    echo ""
    echo "This script will run the complete FerryLightV2 setup in three parts:"
    echo ""
    echo "Part 1: Docker Installation"
    echo "  • Install Docker and Docker Compose"
    echo "  • Set up project structure"
    echo "  • Create Docker networks"
    echo ""
    echo "Part 2: Configuration Files"
    echo "  • Create Traefik configuration"
    echo "  • Create Mosquitto MQTT configuration (open access)"
    echo "  • Create Node-RED configuration (with authentication)"
    echo "  • Create Nginx configuration"
    echo "  • Create website dashboard"
    echo ""
    echo "Part 3: Services and Deployment"
    echo "  • Create Docker Compose configuration"
    echo "  • Create management scripts"
    echo "  • Create systemd service"
    echo "  • Start all services"
    echo "  • Create documentation"
    echo ""
    echo "Configuration:"
    echo "• Domain: ferrylight.online"
    echo "• IP Address: 209.209.43.250"
    echo "• Email: admin@ferrylight.online"
    echo "• Traefik: admin:ferrylight2024"
    echo "• Node-RED: admin:ferrylight2024"
    echo "• MQTT: Anonymous access (open)"
    echo ""
    
    read -p "Do you want to continue with the complete setup? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
    
    # Check if all scripts exist
    print_status "Checking setup scripts..."
    check_script "setup_part1_docker.sh"
    check_script "setup_part2_config.sh"
    check_script "setup_part3_services.sh"
    print_success "All setup scripts found"
    
    # Make scripts executable
    make_executable
    
    # Run all parts
    run_part1
    echo ""
    run_part2
    echo ""
    run_part3
    echo ""
    
    # Show final instructions
    show_final_instructions
}

# Run main function
main "$@" 