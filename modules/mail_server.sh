# FerryLightV2 Mail Server Module
# Author: Markus van Kempen
# Date: July 24, 2025
# Email: markus.van.kempen@gmail.com

setup_mail_server() {
    print_step "8" "Setting up Docker Mail DMS..."
    
    # Create mail server directories
    print_status "Creating mail server directories..."
    mkdir -p $PROJECT_DIR/mailserver/mail-data
    mkdir -p $PROJECT_DIR/mailserver/mail-state
    mkdir -p $PROJECT_DIR/mailserver/mail-logs
    mkdir -p $PROJECT_DIR/mailserver/config
    mkdir -p $PROJECT_DIR/mailserver/dms/config
    
    # Set proper permissions
    sudo chown -R $USER:$USER $PROJECT_DIR/mailserver
    
    # Create mail server configuration
    print_status "Creating mail server configuration..."
    cat > $PROJECT_DIR/mailserver/dms/config/dms.conf << EOF
# Docker Mail Server Configuration
# Author: Markus van Kempen
# Date: July 24, 2025

# Domain configuration
DMS_DOMAINNAME=\${DOMAIN}
DMS_HOSTNAME=mail.\${DOMAIN}

# Admin user
DMS_ADMIN_EMAIL=admin@\${DOMAIN}
DMS_ADMIN_PASSWORD=\${MAIL_ADMIN_PASSWORD:-your-secure-mail-password}

# Mail settings
DMS_MAILNAME=mail.\${DOMAIN}
DMS_MAIL_HOSTNAME=mail.\${DOMAIN}

# SSL/TLS settings
DMS_SSL_TYPE=letsencrypt
DMS_SSL_DOMAIN=mail.\${DOMAIN}

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
DMS_OVERRIDE_HOSTNAME=mail.\${DOMAIN}
DMS_REJECT_UNLISTED_RECIPIENT=0
DMS_REJECT_UNLISTED_SENDER=0

# Web interface
DMS_WEBROOT_PATH=/web
DMS_WEBROOT_PATH_OVERRIDE=/web

# API
DMS_API=1
DMS_API_KEY=\${MAIL_API_KEY:-your-secure-api-key}
EOF

    # Create docker-compose mail service
    print_status "Adding mail server to docker-compose.yml..."
    cat >> $PROJECT_DIR/docker-compose.yml << EOF

  mailserver:
    image: docker.io/mailserver/docker-mailserver:latest
    container_name: ferrylightv2-mailserver
    restart: unless-stopped
    hostname: mail.\${DOMAIN}
    domainname: \${DOMAIN}
    ports:
      - "25:25"    # SMTP
      - "143:143"  # IMAP
      - "465:465"  # SMTPS
      - "587:587"  # SMTP submission
      - "993:993"  # IMAPS
    volumes:
      - ./mailserver/dms/config:/tmp/docker-mailserver:ro
      - ./mailserver/mail-data:/var/mail
      - ./mailserver/mail-state:/var/mail-state
      - ./mailserver/mail-logs:/var/log/mail
      - /etc/localtime:/etc/localtime:ro
    environment:
      - DMS_DOMAINNAME=\${DOMAIN}
      - DMS_HOSTNAME=mail.\${DOMAIN}
      - DMS_ADMIN_EMAIL=admin@\${DOMAIN}
      - DMS_ADMIN_PASSWORD=\${MAIL_ADMIN_PASSWORD:-your-secure-mail-password}
      - DMS_MAILNAME=mail.\${DOMAIN}
      - DMS_SSL_TYPE=letsencrypt
      - DMS_SSL_DOMAIN=mail.\${DOMAIN}
      - DMS_SPAMASSASSIN_SPAM_TO_INBOX=1
      - DMS_CLAMAV=1
      - DMS_ONE_DIR=1
      - DMS_API=1
      - DMS_API_KEY=\${MAIL_API_KEY:-your-secure-api-key}
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.mail.rule=Host(\`mail.\${DOMAIN}\`)"
      - "traefik.http.routers.mail.entrypoints=websecure"
      - "traefik.http.routers.mail.tls.certresolver=letsencrypt"
      - "traefik.http.services.mail.loadbalancer.server.port=80"
    depends_on:
      - traefik
EOF

    # Create mail server management script
    print_status "Creating mail server management script..."
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
    
    print_success "Mail server setup completed"
} 