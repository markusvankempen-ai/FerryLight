#!/bin/bash

# FerryLightV2 Complete Setup Script
# Author: Markus van Kempen
# Date: July 24, 2025
# Email: markus.van.kempen@gmail.com - Main Orchestrator
# All-in-one solution for Ubuntu 22.04 with Docker, Portainer, Traefik, Node-RED, and Mosquitto
# Updated for current environment with MQTT authentication

set -e

# Load environment variables if .env file exists
if [ -f ".env" ]; then
    print_status "Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
fi

# Configuration
DOMAIN="${DOMAIN:-ferrylight.online}"
SERVER_IP="${SERVER_IP:-209.209.43.250}"
EMAIL="${EMAIL:-admin@ferrylight.online}"
PROJECT_DIR="${PROJECT_DIR:-/opt/ferrylightv2}"
BACKUP_DIR="${BACKUP_DIR:-/opt/ferrylightv2/backups}"

# Authentication credentials
TRAEFIK_USERNAME="${TRAEFIK_USERNAME:-admin}"
TRAEFIK_PASSWORD="${TRAEFIK_PASSWORD:-your-secure-password}"
NODERED_USERNAME="${NODERED_USERNAME:-admin}"
NODERED_PASSWORD="${NODERED_PASSWORD:-your-secure-password}"
MQTT_USERNAME="${MQTT_USERNAME:-ferrylight}"
MQTT_PASSWORD="${MQTT_PASSWORD:-your-secure-mqtt-password}"

# Mail Server Configuration
MAIL_ADMIN_PASSWORD="${MAIL_ADMIN_PASSWORD:-your-secure-mail-password}"
MAIL_API_KEY="${MAIL_API_KEY:-your-secure-api-key}"

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

# Function to create backup
create_backup() {
    local backup_name="backup_$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    print_status "Creating backup: $backup_name"
    mkdir -p "$backup_path"
    
    if [ -d "$PROJECT_DIR" ]; then
        cp -r "$PROJECT_DIR"/* "$backup_path/" 2>/dev/null || true
        print_success "Backup created at: $backup_path"
    else
        print_warning "No existing project to backup"
    fi
}

# Function to load modules
load_modules() {
    print_status "Loading setup modules..."
    
    # Check if modules exist
    if [ ! -f "modules/system_setup.sh" ]; then
        print_error "❌ Modules not found!"
        print_error "Please run the setup from the FerryLightV2 project directory."
        print_error "Modules should be in the 'modules/' directory."
        exit 1
    fi
    
    # Source all modules
    source modules/system_setup.sh
    source modules/docker_install.sh
    source modules/project_setup.sh
    source modules/docker_compose.sh
    source modules/services.sh
    source modules/mqtt_auth.sh
    source modules/mail_server.sh
    source modules/final_config.sh
    source modules/results.sh
    
    print_success "All modules loaded"
}

# Main setup function
main() {
    print_header "🚀 FerryLightV2 Complete Setup"
    print_header "=============================="
    echo ""
    print_status "Configuration:"
    print_status "Domain: $DOMAIN"
    print_status "IP Address: $SERVER_IP"
    print_status "Email: $EMAIL"
    print_status "Project Directory: $PROJECT_DIR"
    echo ""

    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi

    # Create backup
    create_backup

    # Load modular functions
    load_modules

    # Step 1: System preparation
    setup_system

    # Step 2: Docker installation
    install_docker

    # Step 3: Project setup
    setup_project

    # Step 4: Create Docker Compose
    create_docker_compose

    # Step 5: Start services
    start_services

    # Step 6: Configure MQTT authentication
    configure_mqtt_auth

    # Step 7: Setup mail server
    setup_mail_server

    # Step 8: Final configuration
    final_configuration

    # Step 9: Show results
    show_results
}

# Run main function
main "$@" 