#!/bin/bash

# FerryLightV2 Setup - Part 2: Configuration Files
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

# Function to create Traefik configuration
create_traefik_config() {
    print_step "1" "Creating Traefik configuration"
    
    # Ensure proper permissions for all directories
    print_status "Setting up permissions..."
    sudo chown -R $USER:$USER $PROJECT_DIR
    sudo chmod -R 755 $PROJECT_DIR
    
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
    print_step "2" "Creating Mosquitto configuration"
    
    # Ensure proper permissions
    sudo chown -R $USER:$USER $PROJECT_DIR/mosquitto
    chmod 755 $PROJECT_DIR/mosquitto/config
    
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
    print_step "3" "Creating Node-RED configuration"
    
    # Ensure proper permissions
    sudo chown -R $USER:$USER $PROJECT_DIR/nodered
    chmod 755 $PROJECT_DIR/nodered
    
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
    print_step "4" "Creating Nginx configuration"
    
    # Ensure proper permissions
    sudo chown -R $USER:$USER $PROJECT_DIR
    chmod 644 $PROJECT_DIR/nginx.conf 2>/dev/null || true
    
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
    print_step "5" "Creating website"
    
    # Ensure proper permissions
    sudo chown -R $USER:$USER $PROJECT_DIR/website
    chmod 755 $PROJECT_DIR/website
    
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

# Main execution
main() {
    print_header "🔧 FerryLightV2 Setup - Part 2: Configuration Files"
    echo "========================================================="
    echo ""
    echo "This script will create all configuration files."
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
    create_traefik_config
    create_mosquitto_config
    create_nodered_config
    create_nginx_config
    create_website
    
    print_success "Part 2 completed! All configuration files are created."
    echo ""
    echo "Next steps:"
    echo "1. Run: ./setup_part3_services.sh"
    echo ""
}

# Run main function
main "$@" 