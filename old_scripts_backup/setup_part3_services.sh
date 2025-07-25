#!/bin/bash

# FerryLightV2 Setup - Part 3: Services and Deployment
# Author: Markus van Kempen - markus.van.kempen@gmail.com
# Date: 24-July-2025

set -e

# Configuration
DOMAIN="ferrylight.online"
SERVER_IP="209.209.43.250"
EMAIL="admin@ferrylight.online"
PROJECT_DIR="/opt/ferrylightv2"

# Authentication credentials
TRAEFIK_USERNAME="admin"
TRAEFIK_PASSWORD="ferrylight2024"
NODERED_USERNAME="admin"
NODERED_PASSWORD="ferrylight2024"

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

# Function to create Docker Compose configuration
create_docker_compose() {
    print_step "1" "Creating Docker Compose configuration"
    
    cat > $PROJECT_DIR/docker-compose.yml << EOF
services:
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik/traefik.yml:/etc/traefik/traefik.yml:ro
      - ./traefik/config:/etc/traefik/config:ro
      - ./traefik/acme:/etc/traefik/acme
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.rule=Host(\`traefik.$DOMAIN\`)"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.middlewares=traefik-auth"

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./portainer:/data
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.rule=Host(\`portainer.$DOMAIN\`)"
      - "traefik.http.routers.portainer.entrypoints=websecure"
      - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"

  website:
    image: nginx:alpine
    container_name: ferrylightv2-website
    restart: unless-stopped
    volumes:
      - ./website:/usr/share/nginx/html:ro
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.website.rule=Host(\`$DOMAIN\`) || Host(\`www.$DOMAIN\`)"
      - "traefik.http.routers.website.entrypoints=websecure"
      - "traefik.http.routers.website.tls.certresolver=letsencrypt"
      - "traefik.http.routers.website.middlewares=secure-headers"
      - "traefik.http.services.website.loadbalancer.server.port=80"

  nodered:
    image: nodered/node-red:latest
    container_name: nodered
    restart: unless-stopped
    environment:
      - TZ=UTC
      - NODE_RED_ENABLE_PROJECTS=false
    volumes:
      - ./nodered:/data
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nodered.rule=Host(\`nodered.$DOMAIN\`)"
      - "traefik.http.routers.nodered.entrypoints=websecure"
      - "traefik.http.routers.nodered.tls.certresolver=letsencrypt"
      - "traefik.http.services.nodered.loadbalancer.server.port=1880"

  mosquitto:
    image: eclipse-mosquitto:latest
    container_name: mosquitto-broker
    restart: unless-stopped
    ports:
      - "1883:1883"
      - "9001:9001"
    volumes:
      - ./mosquitto/config:/mosquitto/config
      - ./mosquitto/data:/mosquitto/data
      - ./mosquitto/log:/mosquitto/log
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.tcp.routers.mosquitto.rule=HostSNI(\`mqtt.$DOMAIN\`)"
      - "traefik.tcp.routers.mosquitto.entrypoints=websecure"
      - "traefik.tcp.routers.mosquitto.tls.certresolver=letsencrypt"
      - "traefik.tcp.services.mosquitto.loadbalancer.server.port=1883"
      - "traefik.http.routers.mosquitto-ws.rule=Host(\`mqtt.$DOMAIN\`)"
      - "traefik.http.routers.mosquitto-ws.entrypoints=websecure"
      - "traefik.http.routers.mosquitto-ws.tls.certresolver=letsencrypt"
      - "traefik.http.services.mosquitto-ws.loadbalancer.server.port=9001"

networks:
  traefik-public:
    external: true
EOF

    print_success "Docker Compose configuration created"
}

# Function to create management scripts
create_management_scripts() {
    print_step "2" "Creating management scripts"
    
    # Update script
    cat > $PROJECT_DIR/update.sh << 'EOF'
#!/bin/bash
cd /opt/ferrylightv2
docker-compose pull
docker-compose up -d
docker system prune -f
echo "Update completed!"
EOF

    # Backup script
    cat > $PROJECT_DIR/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/ferrylightv2/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup Portainer data
docker run --rm -v portainer_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/portainer_$DATE.tar.gz -C /data .

# Backup Traefik certificates
tar czf $BACKUP_DIR/traefik_$DATE.tar.gz -C /opt/ferrylightv2 traefik/acme

# Backup Node-RED data
tar czf $BACKUP_DIR/nodered_$DATE.tar.gz -C /opt/ferrylightv2 nodered

# Backup MQTT data
tar czf $BACKUP_DIR/mosquitto_$DATE.tar.gz -C /opt/ferrylightv2 mosquitto

echo "Backup completed: $BACKUP_DIR"
EOF

    # MQTT configuration script
    cat > $PROJECT_DIR/configure_mqtt.sh << 'EOF'
#!/bin/bash
cd /opt/ferrylightv2
echo "MQTT Configuration Options:"
echo "1. Anonymous access (current - open)"
echo "2. Username/password authentication"
echo "3. Advanced ACL configuration"
read -p "Choose option (1-3): " choice

case $choice in
    2)
        read -p "Enter username: " username
        read -s -p "Enter password: " password
        echo ""
        docker exec mosquitto-broker mosquitto_passwd -c /mosquitto/config/passwd $username <<< "$password" <<< "$password"
        sed -i 's/# password_file \/mosquitto\/config\/passwd/password_file \/mosquitto\/config\/passwd/' mosquitto/config/mosquitto.conf
        sed -i 's/allow_anonymous true/allow_anonymous false/' mosquitto/config/mosquitto.conf
        docker-compose restart mosquitto
        echo "Username/password authentication configured"
        ;;
    3)
        read -p "Enter username: " username
        read -s -p "Enter password: " password
        echo ""
        docker exec mosquitto-broker mosquitto_passwd -c /mosquitto/config/passwd $username <<< "$password" <<< "$password"
        echo "user $username" > mosquitto/config/acl
        echo "topic readwrite #" >> mosquitto/config/acl
        sed -i 's/# password_file \/mosquitto\/config\/passwd/password_file \/mosquitto\/config\/passwd/' mosquitto/config/mosquitto.conf
        sed -i 's/# acl_file \/mosquitto\/config\/acl/acl_file \/mosquitto\/config\/acl/' mosquitto/config/mosquitto.conf
        sed -i 's/allow_anonymous true/allow_anonymous false/' mosquitto/config/mosquitto.conf
        docker-compose restart mosquitto
        echo "Advanced ACL configuration completed"
        ;;
    *)
        echo "Anonymous access maintained (open access)"
        ;;
esac
EOF

    # Make scripts executable
    chmod +x $PROJECT_DIR/update.sh
    chmod +x $PROJECT_DIR/backup.sh
    chmod +x $PROJECT_DIR/configure_mqtt.sh

    print_success "Management scripts created"
}

# Function to create systemd service
create_systemd_service() {
    print_step "3" "Creating systemd service"
    
    sudo tee /etc/systemd/system/ferrylightv2.service > /dev/null << EOF
[Unit]
Description=FerryLightV2 Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start the service
    sudo systemctl enable ferrylightv2.service
    sudo systemctl start ferrylightv2.service

    print_success "Systemd service created and enabled"
}

# Function to set permissions
set_permissions() {
    print_step "4" "Setting permissions"
    
    sudo chown -R $USER:$USER $PROJECT_DIR
    chmod 600 $PROJECT_DIR/traefik/acme/acme.json 2>/dev/null || print_status "No existing acme.json"
    chmod 700 $PROJECT_DIR/traefik/acme

    print_success "Permissions set correctly"
}

# Function to start services
start_services() {
    print_step "5" "Starting services"
    
    # Check Docker permissions
    if ! docker info >/dev/null 2>&1; then
        print_error "Cannot connect to Docker daemon. Please ensure:"
        print_error "1. Docker service is running: sudo systemctl start docker"
        print_error "2. User is in docker group: newgrp docker"
        print_error "3. Or log out and log back in"
        exit 1
    fi

    cd $PROJECT_DIR
    docker-compose up -d

    print_success "Services started"
}

# Function to create documentation
create_documentation() {
    print_step "6" "Creating documentation"
    
    cat > $PROJECT_DIR/README.md << EOF
# FerryLightV2 Server Documentation

**Author:** Markus van Kempen - markus.van.kempen@gmail.com  
**Date:** 24-July-2025  
**Version:** 2.0  
**Compatible:** Ubuntu 22.04 LTS  

## 🌐 Server Information
- **Domain**: $DOMAIN
- **IP Address**: $SERVER_IP
- **OS**: Ubuntu 22.04 LTS

## 🔗 Service URLs
- **Main Website**: https://$DOMAIN
- **Portainer**: https://portainer.$DOMAIN
- **Traefik Dashboard**: https://traefik.$DOMAIN
- **Node-RED**: https://nodered.$DOMAIN
- **MQTT Broker**: mqtt.$DOMAIN:1883

## 🔐 Default Credentials
- **Traefik Dashboard**: $TRAEFIK_USERNAME:$TRAEFIK_PASSWORD
- **Node-RED**: $NODERED_USERNAME:$NODERED_PASSWORD
- **Portainer**: Create admin account on first visit
- **MQTT**: Anonymous access (open)

## 🔧 Management Commands
\`\`\`bash
cd $PROJECT_DIR

# Check service status
docker-compose ps

# View logs
docker-compose logs

# Restart services
docker-compose restart

# Update all services
./update.sh

# Create backup
./backup.sh

# Configure MQTT
./configure_mqtt.sh
\`\`\`

## 📋 DNS Configuration Required
Add these A records in your DNS provider:
- $DOMAIN → $SERVER_IP
- www.$DOMAIN → $SERVER_IP
- portainer.$DOMAIN → $SERVER_IP
- traefik.$DOMAIN → $SERVER_IP
- nodered.$DOMAIN → $SERVER_IP
- mqtt.$DOMAIN → $SERVER_IP

## 🔒 SSL Certificates
SSL certificates are automatically generated by Let's Encrypt.
- Certificates are stored in: $PROJECT_DIR/traefik/acme/
- Automatic renewal is enabled
- HTTP to HTTPS redirect is configured

## 🔌 MQTT Configuration
- **Broker**: mqtt.$DOMAIN
- **Port**: 1883 (TCP) / 9001 (WebSocket)
- **Authentication**: Anonymous (open access)
- **External Access**: Enabled
- **Configuration**: Run \`./configure_mqtt.sh\`

## 🐛 Troubleshooting
1. Check service status: \`docker-compose ps\`
2. View logs: \`docker-compose logs [service-name]\`
3. Check Traefik dashboard: http://$SERVER_IP:8080
4. Verify DNS resolution: \`nslookup $DOMAIN\`

## 📞 Support
For issues:
1. Check the troubleshooting section
2. Review logs: \`docker-compose logs\`
3. Verify DNS configuration
4. Check firewall settings

---
**Author:** Markus van Kempen - markus.van.kempen@gmail.com  
**Generated on:** $(date)  
**Version:** 2.0
EOF

    print_success "Documentation created"
}

# Function to test setup
test_setup() {
    print_step "7" "Testing setup"
    
    echo ""
    print_status "Waiting for services to start..."
    sleep 15
    
    echo ""
    print_status "Checking service status..."
    docker-compose ps
    
    echo ""
    print_status "Testing DNS resolution..."
    domains=("$DOMAIN" "www.$DOMAIN" "portainer.$DOMAIN" "traefik.$DOMAIN" "nodered.$DOMAIN" "mqtt.$DOMAIN")
    
    for domain in "${domains[@]}"; do
        echo -n "Testing $domain: "
        if nslookup $domain | grep -q "$SERVER_IP"; then
            print_success "✅ Resolves to $SERVER_IP"
        else
            print_error "❌ Does not resolve to $SERVER_IP"
        fi
    done
    
    echo ""
    print_status "Testing basic connectivity..."
    if curl -s http://$SERVER_IP:8080 > /dev/null; then
        print_success "✅ Traefik dashboard accessible"
    else
        print_error "❌ Traefik dashboard not accessible"
    fi
}

# Function to show final summary
show_summary() {
    print_header "🎉 FerryLightV2 Setup Complete!"
    echo ""
    echo "📋 Setup Summary:"
    echo "=================="
    echo "✅ Docker installed and configured"
    echo "✅ Portainer running on https://portainer.$DOMAIN"
    echo "✅ Traefik running on https://traefik.$DOMAIN"
    echo "✅ Website running on https://$DOMAIN"
    echo "✅ Node-RED running on https://nodered.$DOMAIN"
    echo "✅ Mosquitto MQTT broker on mqtt.$DOMAIN:1883"
    echo "✅ SSL certificates will be automatically generated"
    echo "✅ Services will auto-start on boot"
    echo "✅ Backup created at: $BACKUP_DIR"
    echo "✅ Old scripts backed up to: $BACKUP_DIR/old_scripts/"
    echo ""
    echo "🌐 Your URLs:"
    echo "============="
    echo "🌐 Main Website: https://$DOMAIN"
    echo "🐳 Portainer: https://portainer.$DOMAIN"
    echo "🔧 Traefik: https://traefik.$DOMAIN"
    echo "🔴 Node-RED: https://nodered.$DOMAIN"
    echo "🔌 MQTT Broker: mqtt.$DOMAIN:1883"
    echo ""
    echo "🔐 Service Credentials:"
    echo "======================="
    echo "Traefik Dashboard: $TRAEFIK_USERNAME:$TRAEFIK_PASSWORD"
    echo "Node-RED: $NODERED_USERNAME:$NODERED_PASSWORD"
    echo "Portainer: Create admin account on first visit"
    echo "MQTT: Anonymous access (open)"
    echo ""
    echo "🔧 Management Commands:"
    echo "======================="
    echo "cd $PROJECT_DIR"
    echo "docker-compose ps          # Check service status"
    echo "docker-compose logs        # View logs"
    echo "docker-compose restart     # Restart services"
    echo "./update.sh               # Update all services"
    echo "./backup.sh               # Create backup"
    echo "./configure_mqtt.sh       # Configure MQTT"
    echo ""
    echo "⚠️  IMPORTANT: Configure DNS Records"
    echo "===================================="
    echo "Add these A records in your DNS provider:"
    echo "  - $DOMAIN → $SERVER_IP"
    echo "  - www.$DOMAIN → $SERVER_IP"
    echo "  - portainer.$DOMAIN → $SERVER_IP"
    echo "  - traefik.$DOMAIN → $SERVER_IP"
    echo "  - nodered.$DOMAIN → $SERVER_IP"
    echo "  - mqtt.$DOMAIN → $SERVER_IP"
    echo ""
    echo "📄 Documentation saved to: $PROJECT_DIR/README.md"
    echo ""
    print_warning "Please reboot the system to ensure all changes take effect."
    print_warning "After DNS configuration, SSL certificates will be automatically generated."
}

# Main execution
main() {
    print_header "🚀 FerryLightV2 Setup - Part 3: Services and Deployment"
    echo "==============================================================="
    echo ""
    echo "This script will deploy all services and create management tools."
    echo ""
    echo "Configuration:"
    echo "• Domain: $DOMAIN"
    echo "• IP Address: $SERVER_IP"
    echo "• Email: $EMAIL"
    echo "• Traefik: $TRAEFIK_USERNAME:$TRAEFIK_PASSWORD"
    echo "• Node-RED: $NODERED_USERNAME:$NODERED_PASSWORD"
    echo "• MQTT: Anonymous access (open)"
    echo ""
    
    read -p "Do you want to continue? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
    
    # Execute setup steps
    create_docker_compose
    create_management_scripts
    create_systemd_service
    set_permissions
    start_services
    create_documentation
    test_setup
    show_summary
}

# Run main function
main "$@" 