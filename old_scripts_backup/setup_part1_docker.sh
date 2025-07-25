#!/bin/bash

# FerryLightV2 Setup - Part 1: Docker Installation
# Author: Markus van Kempen - markus.van.kempen@gmail.com
# Date: 24-July-2025

set -e

# Configuration
DOMAIN="ferrylight.online"
SERVER_IP="209.209.43.250"
EMAIL="admin@ferrylight.online"
PROJECT_DIR="/opt/ferrylightv2"
BACKUP_DIR="/opt/ferrylightv2/backups"

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
    
    # Backup old scripts to backup directory
    print_status "Backing up old scripts..."
    mkdir -p "$backup_path/old_scripts"
    
    # List of old scripts to backup
    old_scripts=(
        "setup_server.sh"
        "setup_ferrylight.sh"
        "configure_domains.sh"
        "fix_docker_permissions.sh"
        "fix_networks.sh"
        "troubleshoot.sh"
        "enable_ip_access.sh"
        "fix_namecheap_dns.sh"
        "fix_domain_config.sh"
        "manual_fix.sh"
        "diagnose_ssl.sh"
        "fix_containers.sh"
        "quick_fix_404.sh"
        "fix_https_routing.sh"
    )
    
    for script in "${old_scripts[@]}"; do
        if [ -f "$script" ]; then
            cp "$script" "$backup_path/old_scripts/"
            print_status "Backed up: $script"
        fi
    done
    
    print_success "Old scripts backed up to: $backup_path/old_scripts/"
}

# Function to check prerequisites
check_prerequisites() {
    print_step "1" "Checking prerequisites"
    
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        print_status "Installing curl..."
        sudo apt update && sudo apt install -y curl
    fi
    
    print_success "Prerequisites check completed"
}

# Function to install Docker
install_docker() {
    print_step "2" "Installing Docker and Docker Compose"
    
    if ! command -v docker &> /dev/null; then
        print_status "Installing Docker..."
        
        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        # Add Docker repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Install Docker
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        # Add user to docker group
        sudo usermod -aG docker $USER
        print_success "Docker installed successfully"
        print_warning "You may need to log out and back in for Docker permissions to take effect"
    else
        print_status "Docker is already installed"
    fi
    
    # Install Docker Compose if not present
    if ! command -v docker-compose &> /dev/null; then
        print_status "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        print_success "Docker Compose installed"
    fi
    
    # Check if user is in docker group
    if ! groups $USER | grep -q docker; then
        print_warning "User is not in docker group. Adding user to docker group..."
        sudo usermod -aG docker $USER
        print_warning "Please run: newgrp docker"
        print_warning "Or log out and log back in"
    fi
}

# Function to setup project structure
setup_project() {
    print_step "3" "Setting up project structure"
    
    # Create project directory
    sudo mkdir -p $PROJECT_DIR
    sudo chown $USER:$USER $PROJECT_DIR
    
    # Create backup directory
    mkdir -p $BACKUP_DIR
    
    # Create Docker networks
    print_status "Creating Docker networks..."
    docker network create traefik-public 2>/dev/null || print_status "Traefik network already exists"
    docker network create web 2>/dev/null || print_status "Web network already exists"
    
    # Create directories for persistent data
    print_status "Creating directories for persistent data..."
    mkdir -p $PROJECT_DIR/traefik/acme
    mkdir -p $PROJECT_DIR/traefik/config
    mkdir -p $PROJECT_DIR/portainer
    mkdir -p $PROJECT_DIR/website
    mkdir -p $PROJECT_DIR/nodered
    mkdir -p $PROJECT_DIR/mosquitto/config
    mkdir -p $PROJECT_DIR/mosquitto/data
    mkdir -p $PROJECT_DIR/mosquitto/log
    
    print_success "Project structure created"
}

# Main execution
main() {
    print_header "🚀 FerryLightV2 Setup - Part 1: Docker Installation"
    echo "========================================================="
    echo ""
    echo "This script will install Docker and set up the project structure."
    echo ""
    echo "Configuration:"
    echo "• Domain: $DOMAIN"
    echo "• IP Address: $SERVER_IP"
    echo "• Email: $EMAIL"
    echo ""
    
    read -p "Do you want to continue? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
    
    # Create backup of existing setup
    create_backup
    
    # Execute setup steps
    check_prerequisites
    install_docker
    setup_project
    
    print_success "Part 1 completed! Docker is installed and project structure is ready."
    echo ""
    echo "Next steps:"
    echo "1. Run: newgrp docker (or log out and back in)"
    echo "2. Run: ./setup_part2_config.sh"
    echo ""
}

# Run main function
main "$@" 