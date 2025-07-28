#!/bin/bash

# FerryLightV2 Manual Mail Server Setup Script
# Author: Markus van Kempen
# Date: July 24, 2025
# Email: markus.van.kempen@gmail.com

# ⚠️ INTERNAL USE ONLY - NEVER COMMIT TO GITHUB
# This script contains REAL credentials and domain information

set -e

# Real Configuration
DOMAIN="ferrylight.online"
SERVER_IP="209.209.43.250"
EMAIL="admin@ferrylight.online"
PROJECT_DIR="/opt/ferrylightv2"

# Real Mail Server Credentials
MAIL_ADMIN_EMAIL="admin@ferrylight.online"
MAIL_ADMIN_PASSWORD="ferrylight@Connexts@99"
MAIL_API_KEY="ferrylight-api-key-2024"

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

# Main setup function
setup_mail_server() {
    print_header "🚀 FerryLightV2 Manual Mail Server Setup"
    print_header "=========================================="
    echo ""
    print_status "Configuration:"
    echo "• Domain: $DOMAIN"
    echo "• Server IP: $SERVER_IP"
    echo "• Admin Email: $MAIL_ADMIN_EMAIL"
    echo "• Admin Password: $MAIL_ADMIN_PASSWORD"
    echo "• API Key: $MAIL_API_KEY"
    echo "• Project Directory: $PROJECT_DIR"
    echo ""

    # Step 1: Create directories
    print_step "1" "Creating mail server directories..."
    mkdir -p $PROJECT_DIR/mailserver/mail-data
    mkdir -p $PROJECT_DIR/mailserver/mail-state
    mkdir -p $PROJECT_DIR/mailserver/mail-logs
    mkdir -p $PROJECT_DIR/mailserver/config
    mkdir -p $PROJECT_DIR/mailserver/dms/config
    
    # Set proper permissions
    sudo chown -R $USER:$USER $PROJECT_DIR/mailserver
    print_success "Mail server directories created"

    # Step 2: Create mail server configuration
    print_step "2" "Creating mail server configuration..."
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
DMS_API_KEY=$MAIL_API_KEY
EOF

    print_success "Mail server configuration created"

    # Step 3: Add mail server to docker-compose.yml
    print_step "3" "Adding mail server to docker-compose.yml..."
    print_status "⚠️  CRITICAL: Volume mounts must NOT be read-only for user management!"
    print_status "✅ Using writable volume mount: ./mailserver/config:/tmp/docker-mailserver"
    print_status "❌ NOT using read-only mount: ./mailserver/config:/tmp/docker-mailserver:ro"
    echo ""
    print_step "3" "Adding mail server to docker-compose.yml..."
    
    # Check if docker-compose.yml exists
    if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
        print_error "docker-compose.yml not found at $PROJECT_DIR"
        print_status "Creating basic docker-compose.yml..."
        cat > $PROJECT_DIR/docker-compose.yml << EOF
version: '3.8'

networks:
  traefik-public:
    external: true

services:
EOF
    fi

    # Add mail server service to docker-compose.yml
    cat >> $PROJECT_DIR/docker-compose.yml << EOF

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
      - ./mailserver/config:/tmp/docker-mailserver
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
      - DMS_API_KEY=$MAIL_API_KEY
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

    print_success "Mail server added to docker-compose.yml"

    # Step 4: Create mail server management script
    print_step "4" "Creating mail server management script..."
    cat > $PROJECT_DIR/manage_mail.sh << 'EOF'
#!/bin/bash

# FerryLightV2 Mail Server Management Script
# Author: Markus van Kempen
# Date: July 24, 2025
# Email: markus.van.kempen@gmail.com

PROJECT_DIR="/opt/ferrylightv2"

echo "📧 FerryLightV2 Mail Server Management"
echo "======================================"
echo ""

case "$1" in
    "start")
        echo "Starting mail server..."
        cd $PROJECT_DIR
        docker-compose up -d mailserver
        ;;
    "stop")
        echo "Stopping mail server..."
        cd $PROJECT_DIR
        docker-compose stop mailserver
        ;;
    "restart")
        echo "Restarting mail server..."
        cd $PROJECT_DIR
        docker-compose restart mailserver
        ;;
    "logs")
        echo "Showing mail server logs..."
        cd $PROJECT_DIR
        docker-compose logs -f mailserver
        ;;
    "status")
        echo "Mail server status:"
        cd $PROJECT_DIR
        docker-compose ps mailserver
        ;;
    "add-user")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 add-user <email> <password>"
            exit 1
        fi
        echo "Adding mail user: $2"
        cd $PROJECT_DIR
        docker exec ferrylightv2-mailserver setup email add $2 $3
        ;;
    "del-user")
        if [ -z "$2" ]; then
            echo "Usage: $0 del-user <email>"
            exit 1
        fi
        echo "Deleting mail user: $2"
        cd $PROJECT_DIR
        docker exec ferrylightv2-mailserver setup email del $2
        ;;
    "list-users")
        echo "Listing mail users:"
        cd $PROJECT_DIR
        docker exec ferrylightv2-mailserver setup email list
        ;;
    "test")
        echo "Testing mail server..."
        cd $PROJECT_DIR
        docker exec ferrylightv2-mailserver setup test
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs|status|add-user|del-user|list-users|test}"
        echo ""
        echo "Examples:"
        echo "  $0 start                    # Start mail server"
        echo "  $0 stop                     # Stop mail server"
        echo "  $0 restart                  # Restart mail server"
        echo "  $0 logs                     # Show logs"
        echo "  $0 status                   # Show status"
        echo "  $0 add-user user@domain.com password  # Add mail user"
        echo "  $0 del-user user@domain.com           # Delete mail user"
        echo "  $0 list-users               # List all users"
        echo "  $0 test                     # Test mail server"
        exit 1
        ;;
esac
EOF

    chmod +x $PROJECT_DIR/manage_mail.sh
    print_success "Mail server management script created"

    # Step 5: Configure firewall
    print_step "5" "Configuring firewall..."
    print_status "Opening mail ports on firewall..."
    sudo ufw allow 25/tcp   # SMTP
    sudo ufw allow 143/tcp  # IMAP
    sudo ufw allow 465/tcp  # SMTPS
    sudo ufw allow 587/tcp  # SMTP submission
    sudo ufw allow 993/tcp  # IMAPS
    
    print_status "Firewall status:"
    sudo ufw status | grep -E "(25|143|465|587|993)"
    print_success "Firewall configured"

    # Step 6: Start mail server
    print_step "6" "Starting mail server..."
    cd $PROJECT_DIR
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

    # Step 7: Test mail server
    print_step "7" "Testing mail server..."
    print_status "Running mail server tests..."
    docker exec ferrylightv2-mailserver setup test
    
    print_success "Mail server tests completed"

    # Step 8: Show results
    print_step "8" "Setup complete!"
    print_header "📧 Mail Server Setup Results"
    echo ""
    print_success "✅ Mail server is running!"
    echo ""
    print_status "Access Information:"
    echo "• Web Interface: https://mail.$DOMAIN"
    echo "• Admin Email: $MAIL_ADMIN_EMAIL"
    echo "• Admin Password: $MAIL_ADMIN_PASSWORD"
    echo "• API Key: $MAIL_API_KEY"
    echo ""
    print_status "Email Client Configuration:"
    echo "• IMAP Server: mail.$DOMAIN"
    echo "• IMAP Port: 993 (SSL) or 143 (STARTTLS)"
    echo "• SMTP Server: mail.$DOMAIN"
    echo "• SMTP Port: 587 (STARTTLS) or 465 (SSL)"
    echo "• Username: your-email@$DOMAIN"
    echo "• Password: your-password"
    echo ""
    print_status "Management Commands:"
    echo "• Start: ./manage_mail.sh start"
    echo "• Stop: ./manage_mail.sh stop"
    echo "• Restart: ./manage_mail.sh restart"
    echo "• Logs: ./manage_mail.sh logs"
    echo "• Status: ./manage_mail.sh status"
    echo "• Add User: ./manage_mail.sh add-user email@$DOMAIN password"
    echo "• List Users: ./manage_mail.sh list-users"
    echo "• Test: ./manage_mail.sh test"
    echo ""
    print_status "DNS Records Required:"
    echo "• A Record: mail.$DOMAIN → $SERVER_IP"
    echo "• MX Record: $DOMAIN → mail.$DOMAIN (priority 10)"
    echo "• SPF Record: $DOMAIN TXT \"v=spf1 mx a ip4:$SERVER_IP ~all\""
    echo "• DKIM Record: mail._domainkey.$DOMAIN TXT \"v=DKIM1; k=rsa; p=YOUR_DKIM_KEY\""
    echo "• DMARC Record: _dmarc.$DOMAIN TXT \"v=DMARC1; p=quarantine; rua=mailto:dmarc@$DOMAIN\""
    echo ""
    print_warning "⚠️  IMPORTANT: Configure DNS records before using mail server!"
    print_warning "⚠️  IMPORTANT: Some ISPs block port 25 - check with your provider!"
    echo ""
    print_success "🎉 Mail server setup completed successfully!"
}

# Function to show DNS configuration
show_dns_config() {
    print_header "📊 DNS Configuration for Mail Server"
    echo ""
    print_status "Required DNS Records for $DOMAIN:"
    echo ""
    echo "1. A Record:"
    echo "   Name: mail.$DOMAIN"
    echo "   Value: $SERVER_IP"
    echo "   TTL: 300"
    echo ""
    echo "2. MX Record:"
    echo "   Name: $DOMAIN"
    echo "   Value: mail.$DOMAIN"
    echo "   Priority: 10"
    echo "   TTL: 300"
    echo ""
    echo "3. SPF Record:"
    echo "   Name: $DOMAIN"
    echo "   Type: TXT"
    echo "   Value: \"v=spf1 mx a ip4:$SERVER_IP ~all\""
    echo "   TTL: 300"
    echo ""
    echo "4. DKIM Record (will be generated after setup):"
    echo "   Name: mail._domainkey.$DOMAIN"
    echo "   Type: TXT"
    echo "   Value: \"v=DKIM1; k=rsa; p=YOUR_DKIM_KEY\""
    echo "   TTL: 300"
    echo ""
    echo "5. DMARC Record:"
    echo "   Name: _dmarc.$DOMAIN"
    echo "   Type: TXT"
    echo "   Value: \"v=DMARC1; p=quarantine; rua=mailto:dmarc@$DOMAIN\""
    echo "   TTL: 300"
    echo ""
    print_status "DNS Configuration Steps:"
    echo "1. Log into your domain registrar (Namecheap, GoDaddy, etc.)"
    echo "2. Go to DNS management for $DOMAIN"
    echo "3. Add the above records"
    echo "4. Wait 5-10 minutes for DNS propagation"
    echo "5. Test with: nslookup mail.$DOMAIN"
    echo ""
}

# Function to show email client configuration
show_email_config() {
    print_header "📧 Email Client Configuration"
    echo ""
    print_status "IMAP Settings (Incoming Mail):"
    echo "• Server: mail.$DOMAIN"
    echo "• Port: 993 (SSL/TLS) or 143 (STARTTLS)"
    echo "• Username: your-email@$DOMAIN"
    echo "• Password: your-password"
    echo "• Security: SSL/TLS or STARTTLS"
    echo ""
    print_status "SMTP Settings (Outgoing Mail):"
    echo "• Server: mail.$DOMAIN"
    echo "• Port: 587 (STARTTLS) or 465 (SSL/TLS)"
    echo "• Username: your-email@$DOMAIN"
    echo "• Password: your-password"
    echo "• Security: STARTTLS or SSL/TLS"
    echo "• Authentication: Required"
    echo ""
    print_status "Supported Email Clients:"
    echo "• Thunderbird"
    echo "• Outlook"
    echo "• Apple Mail"
    echo "• Gmail (as external account)"
    echo "• Mobile apps (iOS Mail, Gmail app, etc.)"
    echo ""
}

# Function to show troubleshooting
show_troubleshooting() {
    print_header "🔧 Mail Server Troubleshooting"
    echo ""
    print_status "Common Issues and Solutions:"
    echo ""
    echo "1. Port 25 blocked by ISP:"
    echo "   • Contact your ISP to unblock port 25"
    echo "   • Use alternative SMTP relay service"
    echo "   • Configure external SMTP relay"
    echo ""
    echo "2. SSL certificate issues:"
    echo "   • Check DNS records are correct"
    echo "   • Wait for Let's Encrypt certificate generation"
    echo "   • Check logs: ./manage_mail.sh logs"
    echo ""
    echo "3. Authentication failed:"
    echo "   • Verify user exists: ./manage_mail.sh list-users"
    echo "   • Check password is correct"
    echo "   • Verify email client settings"
    echo ""
    echo "4. Mail not sending/receiving:"
    echo "   • Check firewall settings"
    echo "   • Verify DNS records"
    echo "   • Check mail server logs"
    echo "   • Test connectivity: telnet mail.$DOMAIN 25"
    echo ""
    print_status "Useful Commands:"
    echo "• Check status: ./manage_mail.sh status"
    echo "• View logs: ./manage_mail.sh logs"
    echo "• Test server: ./manage_mail.sh test"
    echo "• List users: ./manage_mail.sh list-users"
    echo "• Check DNS: nslookup mail.$DOMAIN"
    echo "• Test SMTP: telnet mail.$DOMAIN 25"
    echo "• Test IMAP: telnet mail.$DOMAIN 143"
    echo ""
}

# Main script execution
case "$1" in
    "setup")
        setup_mail_server
        ;;
    "dns")
        show_dns_config
        ;;
    "email")
        show_email_config
        ;;
    "troubleshoot")
        show_troubleshooting
        ;;
    "help"|"")
        echo "FerryLightV2 Manual Mail Server Setup Script"
        echo "============================================="
        echo ""
        echo "Usage: $0 {setup|dns|email|troubleshoot|help}"
        echo ""
        echo "Commands:"
        echo "  setup        - Complete mail server setup"
        echo "  dns          - Show DNS configuration"
        echo "  email        - Show email client configuration"
        echo "  troubleshoot - Show troubleshooting guide"
        echo "  help         - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 setup        # Run complete setup"
        echo "  $0 dns          # Show DNS records needed"
        echo "  $0 email        # Show email client settings"
        echo "  $0 troubleshoot # Show troubleshooting guide"
        echo ""
        echo "Configuration:"
        echo "  Domain: $DOMAIN"
        echo "  Server IP: $SERVER_IP"
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