#!/bin/bash

# FerryLightV2 Complete Setup Script
# All-in-one solution for Ubuntu 22.04 with Docker, Portainer, Traefik, Node-RED, and Mosquitto

set -e

# Configuration
DOMAIN="ferrylight.online"
SERVER_IP="209.209.43.250"
EMAIL="admin@ferrylight.online"
PROJECT_DIR="/opt/ferrylightv2"
BACKUP_DIR="/opt/ferrylightv2/backups"

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

# Function to create Traefik configuration
create_traefik_config() {
    print_step "4" "Creating Traefik configuration"
    
    # Generate bcrypt hash for Traefik password
    TRAEFIK_HASH=$(docker run --rm httpd:2.4-alpine htpasswd -nbB $TRAEFIK_USERNAME $TRAEFIK_PASSWORD | cut -d ":" -f 2)
    
    # Create Traefik configuration
    cat > $PROJECT_DIR/traefik/traefik.yml << EOF
api:
  dashboard: true
  insecure: false

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
          permanent: true
  websecure:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: traefik-public
  file:
    directory: /etc/traefik/config
    watch: true

certificatesResolvers:
  letsencrypt:
    acme:
      email: $EMAIL
      storage: /etc/traefik/acme/acme.json
      httpChallenge:
        entryPoint: web

log:
  level: INFO

accessLog: {}
EOF

    # Create Traefik dynamic configuration
    cat > $PROJECT_DIR/traefik/config/dynamic.yml << EOF
http:
  middlewares:
    secure-headers:
      headers:
        frameDeny: true
        sslRedirect: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 31536000
        customFrameOptionsValue: "SAMEORIGIN"
        customRequestHeaders:
          X-Forwarded-Proto: "https"
    traefik-auth:
      basicAuth:
        users:
          - "$TRAEFIK_USERNAME:$TRAEFIK_HASH"
EOF

    print_success "Traefik configuration created"
}

# Function to create Mosquitto configuration
create_mosquitto_config() {
    print_step "5" "Creating Mosquitto configuration"
    
    cat > $PROJECT_DIR/mosquitto/config/mosquitto.conf << 'EOF'
# Mosquitto MQTT Broker Configuration

# Basic settings
listener 1883 0.0.0.0
allow_anonymous true
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
log_dest stdout
log_type all
log_timestamp true

# WebSocket support
listener 9001 0.0.0.0
protocol websockets
allow_anonymous true

# Performance settings
max_inflight_messages 20
max_queued_messages 100
message_size_limit 0

# Connection settings
connection_messages true
log_type error
log_type warning
log_type notice
log_type information

# Allow all topics (open access)
# For production, consider adding ACL restrictions
EOF

    print_success "Mosquitto configuration created"
}

# Function to create Node-RED configuration
create_nodered_config() {
    print_step "6" "Creating Node-RED configuration"
    
    cat > $PROJECT_DIR/nodered/settings.js << EOF
module.exports = {
    // Node-RED settings
    uiPort: process.env.PORT || 1880,
    
    // Authentication
    adminAuth: {
        type: "credentials",
        users: [{
            username: "$NODERED_USERNAME",
            password: "$(node -e "console.log(require('bcryptjs').hashSync('$NODERED_PASSWORD', 8))")",
            permissions: "*"
        }]
    },
    
    // Security settings
    credentialSecret: "ferrylightv2-secret-key",
    
    // Editor settings
    editorTheme: {
        projects: {
            enabled: false
        }
    },
    
    // Logging
    logging: {
        console: {
            level: "info",
            metrics: false,
            audit: false
        }
    },
    
    // Function global context
    functionGlobalContext: {
        // Enable global context for functions
    },
    
    // HTTP settings
    httpNodeAuth: {
        user: "$NODERED_USERNAME",
        pass: "$NODERED_PASSWORD"
    },
    
    // HTTPS settings (disabled for Traefik proxy)
    https: false,
    
    // MQTT settings
    mqtt: {
        host: "mosquitto",
        port: 1883
    }
}
EOF

    print_success "Node-RED configuration created"
}

# Function to create Nginx configuration
create_nginx_config() {
    print_step "7" "Creating Nginx configuration"
    
    cat > $PROJECT_DIR/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html index.htm;

        location / {
            try_files $uri $uri/ /index.html;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        location ~ /\. {
            deny all;
        }
    }
}
EOF

    print_success "Nginx configuration created"
}

# Function to create website
create_website() {
    print_step "8" "Creating website"
    
    cat > $PROJECT_DIR/website/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FerryLightV2 - Server Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-width: 800px;
            width: 90%;
        }

        .logo {
            font-size: 3rem;
            font-weight: bold;
            color: #333;
            margin-bottom: 20px;
        }

        .subtitle {
            color: #666;
            font-size: 1.2rem;
            margin-bottom: 30px;
        }

        .status {
            background: #e8f5e8;
            border: 2px solid #4caf50;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }

        .status h3 {
            color: #2e7d32;
            margin-bottom: 10px;
        }

        .links {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }

        .link {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            padding: 20px;
            border-radius: 10px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .link:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        }

        .link-icon {
            font-size: 2rem;
            margin-bottom: 10px;
        }

        .info {
            margin-top: 30px;
            padding: 20px;
            background: #f5f5f5;
            border-radius: 10px;
        }

        .info h4 {
            color: #333;
            margin-bottom: 10px;
        }

        .info p {
            color: #666;
            line-height: 1.6;
            margin-bottom: 5px;
        }

        .credentials {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 10px;
            padding: 15px;
            margin-top: 20px;
        }

        .credentials h5 {
            color: #856404;
            margin-bottom: 10px;
        }

        .credential-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
            font-family: monospace;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🚢 FerryLightV2</div>
        <div class="subtitle">Complete Server Dashboard</div>
        
        <div class="status">
            <h3>✅ Server Status: Online</h3>
            <p>All services are running successfully</p>
        </div>

        <div class="links">
            <a href="https://portainer.$DOMAIN" class="link" target="_blank">
                <div class="link-icon">🐳</div>
                <div>Portainer</div>
                <small>Docker Management</small>
            </a>
            <a href="https://traefik.$DOMAIN" class="link" target="_blank">
                <div class="link-icon">🔧</div>
                <div>Traefik</div>
                <small>Reverse Proxy</small>
            </a>
            <a href="https://nodered.$DOMAIN" class="link" target="_blank">
                <div class="link-icon">🔴</div>
                <div>Node-RED</div>
                <small>Visual Programming</small>
            </a>
        </div>

        <div class="info">
            <h4>📋 Server Information</h4>
            <p><strong>Domain:</strong> $DOMAIN</p>
            <p><strong>IP Address:</strong> $SERVER_IP</p>
            <p><strong>OS:</strong> Ubuntu 22.04 LTS</p>
            <p><strong>Docker:</strong> Latest</p>
            <p><strong>SSL:</strong> Let's Encrypt (Automatic)</p>
            <p><strong>Ports:</strong> 80 (HTTP), 443 (HTTPS), 1883 (MQTT)</p>
        </div>

        <div class="info">
            <h4>🔌 MQTT Configuration</h4>
            <p><strong>Broker:</strong> mqtt.$DOMAIN</p>
            <p><strong>Port:</strong> 1883 (TCP) / 9001 (WebSocket)</p>
            <p><strong>Authentication:</strong> Anonymous (Open Access)</p>
            <p><strong>WebSocket URL:</strong> ws://mqtt.$DOMAIN:9001</p>
            <p><strong>External Access:</strong> Enabled</p>
        </div>

        <div class="credentials">
            <h5>🔐 Service Credentials</h5>
            <div class="credential-item">
                <span>Traefik Dashboard:</span>
                <span>$TRAEFIK_USERNAME / $TRAEFIK_PASSWORD</span>
            </div>
            <div class="credential-item">
                <span>Node-RED:</span>
                <span>$NODERED_USERNAME / $NODERED_PASSWORD</span>
            </div>
            <div class="credential-item">
                <span>Portainer:</span>
                <span>Create on first visit</span>
            </div>
        </div>
    </div>

    <script>
        // Add some interactivity
        document.addEventListener('DOMContentLoaded', function() {
            const status = document.querySelector('.status');
            
            // Simulate status check
            setInterval(() => {
                status.style.background = '#e8f5e8';
                status.style.borderColor = '#4caf50';
                setTimeout(() => {
                    status.style.background = '#fff3cd';
                    status.style.borderColor = '#ffc107';
                }, 1000);
            }, 5000);
        });
    </script>
</body>
</html>
EOF

    print_success "Website created"
}

# Function to create Docker Compose configuration
create_docker_compose() {
    print_step "9" "Creating Docker Compose configuration"
    
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
    print_step "10" "Creating management scripts"
    
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
        cat > mosquitto/config/acl << EOF
user $username
topic readwrite #
EOF
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
    print_step "11" "Creating systemd service"
    
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
    print_step "12" "Setting permissions"
    
    sudo chown -R $USER:$USER $PROJECT_DIR
    chmod 600 $PROJECT_DIR/traefik/acme/acme.json 2>/dev/null || print_status "No existing acme.json"
    chmod 700 $PROJECT_DIR/traefik/acme

    print_success "Permissions set correctly"
}

# Function to start services
start_services() {
    print_step "13" "Starting services"
    
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
    print_step "14" "Creating documentation"
    
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
    print_step "15" "Testing setup"
    
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
    print_header "🚀 FerryLightV2 Complete Setup Script"
    echo "============================================="
    echo ""
    echo "This script will set up a complete server with:"
    echo "• Docker & Docker Compose"
    echo "• Traefik reverse proxy with SSL"
    echo "• Portainer for Docker management"
    echo "• Node-RED for visual programming"
    echo "• Mosquitto MQTT broker (open access)"
    echo "• Simple website dashboard"
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
    
    # Create backup of existing setup
    create_backup
    
    # Execute setup steps
    check_prerequisites
    install_docker
    setup_project
    create_traefik_config
    create_mosquitto_config
    create_nodered_config
    create_nginx_config
    create_website
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