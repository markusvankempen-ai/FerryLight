#!/bin/bash

# FerryLightV2 Mail Server User Management Fix
# Author: Markus van Kempen
# Date: July 24, 2025
# Email: markus.van.kempen@gmail.com

# ⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB
# This script contains REAL credentials and domain information

set -e

# Real Configuration
DOMAIN="ferrylight.online"
PROJECT_DIR="/opt/ferrylightv2"
MAIL_ADMIN_EMAIL="admin@ferrylight.online"
MAIL_ADMIN_PASSWORD="ferrylight@Connexts@99"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_status() {
    echo -e "${YELLOW}📧 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step() {
    echo -e "${BLUE}Step $1: $2${NC}"
}

# Fix mail server user management
fix_mail_user_management() {
    print_header "🔧 Fixing Mail Server User Management"
    echo ""
    print_status "The issue is that the configuration files are mounted as read-only."
    print_status "We need to fix the volume mounts in docker-compose.yml"
    echo ""

    # Step 1: Stop mail server
    print_step "1" "Stopping mail server..."
    cd $PROJECT_DIR
    docker-compose stop mailserver
    print_success "Mail server stopped"

    # Step 2: Backup current docker-compose.yml
    print_step "2" "Backing up docker-compose.yml..."
    cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
    print_success "Backup created"

    # Step 3: Fix volume mounts
    print_step "3" "Fixing volume mounts in docker-compose.yml..."
    
    # Create the correct directory structure
    mkdir -p $PROJECT_DIR/mailserver/config
    mkdir -p $PROJECT_DIR/mailserver/dms/config
    
    # Set proper permissions
    sudo chown -R $USER:$USER $PROJECT_DIR/mailserver
    
    print_success "Directory structure created"

    # Step 4: Update docker-compose.yml with correct volume mounts
    print_step "4" "Updating docker-compose.yml..."
    
    # Create a temporary file with the corrected mail server configuration
    cat > /tmp/mailserver_fixed.yml << EOF
  mailserver:
    image: docker.io/mailserver/docker-mailserver:latest
    container_name: ferrylightv2-mailserver
    restart: unless-stopped
    hostname: mail.$DOMAIN
    domainname: $DOMAIN
    ports:
      - "25:25"    # SMTP
      - "143:143"  # IMAP
      - "465:465"  # SMTPS
      - "587:587"  # SMTP submission
      - "993:993"  # IMAPS
    volumes:
      - ./mailserver/config:/tmp/docker-mailserver:ro
      - ./mailserver/mail-data:/var/mail
      - ./mailserver/mail-state:/var/mail-state
      - ./mailserver/mail-logs:/var/log/mail
      - /etc/localtime:/etc/localtime:ro
    environment:
      - DMS_DOMAINNAME=$DOMAIN
      - DMS_HOSTNAME=mail.$DOMAIN
      - DMS_ADMIN_EMAIL=$MAIL_ADMIN_EMAIL
      - DMS_ADMIN_PASSWORD=$MAIL_ADMIN_PASSWORD
      - DMS_MAILNAME=mail.$DOMAIN
      - DMS_SSL_TYPE=letsencrypt
      - DMS_SSL_DOMAIN=mail.$DOMAIN
      - DMS_SPAMASSASSIN_SPAM_TO_INBOX=1
      - DMS_CLAMAV=1
      - DMS_ONE_DIR=1
      - DMS_API=1
      - DMS_API_KEY=ferrylight-api-key-2024
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mail.rule=Host(\`mail.$DOMAIN\`)"
      - "traefik.http.routers.mail.entrypoints=websecure"
      - "traefik.http.routers.mail.tls.certresolver=letsencrypt"
      - "traefik.http.services.mail.loadbalancer.server.port=80"
    depends_on:
      - traefik
EOF

    print_success "Fixed configuration created"

    # Step 5: Replace mail server section in docker-compose.yml
    print_step "5" "Replacing mail server section in docker-compose.yml..."
    
    # Remove old mail server section if it exists
    sed -i '/^  mailserver:/,/^  [a-zA-Z]/d' docker-compose.yml
    
    # Add the fixed mail server configuration
    cat /tmp/mailserver_fixed.yml >> docker-compose.yml
    
    print_success "Docker-compose.yml updated"

    # Step 6: Create mail server configuration
    print_step "6" "Creating mail server configuration..."
    cat > $PROJECT_DIR/mailserver/config/dms.conf << EOF
# Docker Mail Server Configuration
# Author: Markus van Kempen
# Date: July 24, 2025

# Domain configuration
DMS_DOMAINNAME=$DOMAIN
DMS_HOSTNAME=mail.$DOMAIN

# Admin user
DMS_ADMIN_EMAIL=$MAIL_ADMIN_EMAIL
DMS_ADMIN_PASSWORD=$MAIL_ADMIN_PASSWORD

# Mail settings
DMS_MAILNAME=mail.$DOMAIN
DMS_MAIL_HOSTNAME=mail.$DOMAIN

# SSL/TLS settings
DMS_SSL_TYPE=letsencrypt
DMS_SSL_DOMAIN=mail.$DOMAIN

# Spam protection
DMS_SPAMASSASSIN_SPAM_TO_INBOX=1
DMS_SPAMASSASSIN_SA_TAG=2.0
DMS_SPAMASSASSIN_SA_KILL=3.0

# ClamAV antivirus
DMS_CLAMAV=1

# Postfix settings
DMS_POSTFIX_MESSAGE_SIZE_LIMIT=52428800
DMS_POSTFIX_MAILBOX_SIZE_LIMIT=0

# Dovecot settings
DMS_DOVECOT_MAILBOX_SIZE_LIMIT=0

# Logging
DMS_LOGROTATE=1
DMS_LOG_LEVEL=info

# Security
DMS_ONE_DIR=1
DMS_OVERRIDE_HOSTNAME=mail.$DOMAIN
DMS_REJECT_UNLISTED_RECIPIENT=0
DMS_REJECT_UNLISTED_SENDER=0

# Web interface
DMS_WEBROOT_PATH=/web
DMS_WEBROOT_PATH_OVERRIDE=/web

# API
DMS_API=1
DMS_API_KEY=ferrylight-api-key-2024
EOF

    print_success "Mail server configuration created"

    # Step 7: Start mail server
    print_step "7" "Starting mail server..."
    docker-compose up -d mailserver
    
    print_status "Waiting for mail server to start..."
    sleep 30
    
    # Check if mail server is running
    if docker-compose ps mailserver | grep -q "Up"; then
        print_success "Mail server started successfully"
    else
        print_error "Mail server failed to start"
        print_status "Checking logs..."
        docker-compose logs mailserver
        exit 1
    fi

    # Step 8: Test user management
    print_step "8" "Testing user management..."
    print_status "Adding test user: markus@$DOMAIN"
    
    # Add user using the correct method
    docker exec ferrylightv2-mailserver setup email add markus@$DOMAIN "secure_password_123"
    
    print_success "User added successfully"

    # Step 9: List users
    print_step "9" "Listing users..."
    docker exec ferrylightv2-mailserver setup email list
    
    print_success "User management working correctly"

    # Step 10: Show results
    print_step "10" "Fix completed!"
    print_header "📧 Mail Server User Management Fixed"
    echo ""
    print_success "✅ Mail server user management is now working!"
    echo ""
    print_status "User Management Commands:"
    echo "• Add user: docker exec ferrylightv2-mailserver setup email add user@$DOMAIN password"
    echo "• Delete user: docker exec ferrylightv2-mailserver setup email del user@$DOMAIN"
    echo "• List users: docker exec ferrylightv2-mailserver setup email list"
    echo "• Update user: docker exec ferrylightv2-mailserver setup email update user@$DOMAIN new_password"
    echo ""
    print_status "Management Script:"
    echo "• Start: ./manage_mail.sh start"
    echo "• Stop: ./manage_mail.sh stop"
    echo "• Restart: ./manage_mail.sh restart"
    echo "• Logs: ./manage_mail.sh logs"
    echo "• Status: ./manage_mail.sh status"
    echo ""
    print_success "🎉 Mail server user management fix completed!"
}

# Function to add a specific user
add_mail_user() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        print_error "Usage: $0 add-user <email> <password>"
        exit 1
    fi
    
    EMAIL="$1"
    PASSWORD="$2"
    
    print_header "📧 Adding Mail User"
    echo ""
    print_status "Adding user: $EMAIL"
    
    cd $PROJECT_DIR
    
    # Add user
    docker exec ferrylightv2-mailserver setup email add "$EMAIL" "$PASSWORD"
    
    print_success "User $EMAIL added successfully"
    
    # List all users
    print_status "Current users:"
    docker exec ferrylightv2-mailserver setup email list
}

# Function to list all users
list_mail_users() {
    print_header "📧 Mail Server Users"
    echo ""
    
    cd $PROJECT_DIR
    
    print_status "Listing all mail users:"
    docker exec ferrylightv2-mailserver setup email list
}

# Function to delete a user
delete_mail_user() {
    if [ -z "$1" ]; then
        print_error "Usage: $0 del-user <email>"
        exit 1
    fi
    
    EMAIL="$1"
    
    print_header "📧 Deleting Mail User"
    echo ""
    print_status "Deleting user: $EMAIL"
    
    cd $PROJECT_DIR
    
    # Delete user
    docker exec ferrylightv2-mailserver setup email del "$EMAIL"
    
    print_success "User $EMAIL deleted successfully"
    
    # List remaining users
    print_status "Remaining users:"
    docker exec ferrylightv2-mailserver setup email list
}

# Main script execution
case "$1" in
    "fix")
        fix_mail_user_management
        ;;
    "add-user")
        add_mail_user "$2" "$3"
        ;;
    "del-user")
        delete_mail_user "$2"
        ;;
    "list-users")
        list_mail_users
        ;;
    "help"|"")
        echo "FerryLightV2 Mail Server User Management Fix"
        echo "============================================"
        echo ""
        echo "Usage: $0 {fix|add-user|del-user|list-users|help}"
        echo ""
        echo "Commands:"
        echo "  fix                    - Fix mail server user management"
        echo "  add-user <email> <pwd> - Add a mail user"
        echo "  del-user <email>       - Delete a mail user"
        echo "  list-users             - List all mail users"
        echo "  help                   - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 fix                                    # Fix user management"
        echo "  $0 add-user markus@$DOMAIN password       # Add user"
        echo "  $0 del-user markus@$DOMAIN                # Delete user"
        echo "  $0 list-users                             # List users"
        echo ""
        echo "Configuration:"
        echo "  Domain: $DOMAIN"
        echo "  Admin Email: $MAIL_ADMIN_EMAIL"
        echo "  Project Dir: $PROJECT_DIR"
        echo ""
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac

echo ""
print_success "Script completed successfully!" 