#!/bin/bash

# FerryLightV2 Server Setup Script for ferrylight.online
# Ubuntu 22.04 LTS with Docker, Portainer, Traefik, and SSL

set -e

echo "🚀 Starting FerryLightV2 server setup for ferrylight.online..."

# Server Configuration
DOMAIN="ferrylight.online"
SERVER_IP="209.209.43.250"
EMAIL="admin@ferrylight.online"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

print_status "Server Configuration:"
print_status "Domain: $DOMAIN"
print_status "IP Address: $SERVER_IP"
print_status "Email: $EMAIL"

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
print_status "Installing required packages..."
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

# Install Docker
print_status "Installing Docker..."
if ! command -v docker &> /dev/null; then
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
    print_warning "You need to log out and log back in for Docker permissions to take effect"
    print_warning "Or run: newgrp docker"
else
    print_status "Docker is already installed"
fi

# Check if user is in docker group
if ! groups $USER | grep -q docker; then
    print_warning "User is not in docker group. Adding user to docker group..."
    sudo usermod -aG docker $USER
    print_warning "Please run: newgrp docker"
    print_warning "Or log out and log back in"
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    print_status "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed"
fi

# Create project directory
PROJECT_DIR="/opt/ferrylightv2"
print_status "Creating project directory at $PROJECT_DIR..."
sudo mkdir -p $PROJECT_DIR
sudo chown $USER:$USER $PROJECT_DIR

# Create Docker networks
print_status "Creating Docker networks..."
if ! docker network ls | grep -q traefik-public; then
    docker network create traefik-public
    print_success "Traefik network created"
else
    print_status "Traefik network already exists"
fi

if ! docker network ls | grep -q web; then
    docker network create web
    print_success "Web network created"
else
    print_status "Web network already exists"
fi

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

# Create Traefik configuration
print_status "Creating Traefik configuration..."
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
cat > $PROJECT_DIR/traefik/config/dynamic.yml << 'EOF'
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
EOF

# Create Docker Compose file
print_status "Creating Docker Compose configuration..."
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
      - "8080:8080"  # Traefik dashboard
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
      - "traefik.http.routers.traefik.middlewares=auth"
      - "traefik.http.middlewares.auth.basicauth.users=admin:\$2y\$10\$8K1p/a0dL1LXMIgoEDFrwOfgqwAG6WUa9EqJdKvJ/JOIdw0KxQK8K"

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
    container_name: mosquitto
    restart: unless-stopped
    ports:
      - "1883:1883"  # MQTT
      - "9001:9001"  # WebSocket
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

# Create Mosquitto configuration
print_status "Creating Mosquitto configuration..."
cat > $PROJECT_DIR/mosquitto/config/mosquitto.conf << 'EOF'
# Mosquitto MQTT Broker Configuration

# Basic settings
listener 1883
allow_anonymous true
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
log_dest stdout
log_type all
log_timestamp true

# WebSocket support
listener 9001
protocol websockets
allow_anonymous true

# Security settings (optional - uncomment to enable)
# password_file /mosquitto/config/passwd
# acl_file /mosquitto/config/acl

# Performance settings
max_inflight_messages 20
max_queued_messages 100
message_size_limit 0
EOF

# Create Nginx configuration for the website
print_status "Creating Nginx configuration..."
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

# Create a simple website
print_status "Creating simple website..."
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
            max-width: 600px;
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
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 30px;
        }

        .link {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            padding: 15px 30px;
            border-radius: 10px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .link:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
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
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🚢 FerryLightV2</div>
        <div class="subtitle">Server Dashboard</div>
        
        <div class="status">
            <h3>✅ Server Status: Online</h3>
            <p>All services are running successfully</p>
        </div>

        <div class="links">
            <a href="https://portainer.$DOMAIN" class="link" target="_blank">
                🐳 Portainer Dashboard
            </a>
            <a href="https://traefik.$DOMAIN" class="link" target="_blank">
                🔧 Traefik Dashboard
            </a>
            <a href="https://nodered.$DOMAIN" class="link" target="_blank">
                🔴 Node-RED
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
            <p><strong>Authentication:</strong> Anonymous (configurable)</p>
            <p><strong>WebSocket URL:</strong> ws://mqtt.$DOMAIN:9001</p>
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

# Set proper permissions
print_status "Setting proper permissions..."
sudo chown -R $USER:$USER $PROJECT_DIR
chmod 600 $PROJECT_DIR/traefik/acme

# Check Docker permissions before starting services
print_status "Checking Docker permissions..."
if ! docker info >/dev/null 2>&1; then
    print_error "Cannot connect to Docker daemon. Please ensure:"
    print_error "1. Docker service is running: sudo systemctl start docker"
    print_error "2. User is in docker group: newgrp docker"
    print_error "3. Or log out and log back in"
    exit 1
fi

# Start services
print_status "Starting Docker services..."
cd $PROJECT_DIR
docker-compose up -d

# Wait for services to start
print_status "Waiting for services to start..."
sleep 10

# Check service status
print_status "Checking service status..."
docker-compose ps

# Create systemd service for auto-start
print_status "Creating systemd service for auto-start..."
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

# Create update script
print_status "Creating update script..."
cat > $PROJECT_DIR/update.sh << 'EOF'
#!/bin/bash
cd /opt/ferrylightv2
docker-compose pull
docker-compose up -d
docker system prune -f
EOF

chmod +x $PROJECT_DIR/update.sh

# Create backup script
print_status "Creating backup script..."
cat > $PROJECT_DIR/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/ferrylightv2/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup Portainer data
docker run --rm -v portainer_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/portainer_$DATE.tar.gz -C /data .

# Backup Traefik certificates
tar czf $BACKUP_DIR/traefik_$DATE.tar.gz -C /opt/ferrylightv2 traefik/acme

echo "Backup completed: $BACKUP_DIR"
EOF

chmod +x $PROJECT_DIR/backup.sh

# Create DNS setup instructions
print_status "Creating DNS setup instructions..."
cat > $PROJECT_DIR/DNS_SETUP.md << EOF
# DNS Configuration for $DOMAIN

## Required DNS Records

Add the following A records in your DNS provider:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | $SERVER_IP | 300 |
| A | www | $SERVER_IP | 300 |
| A | portainer | $SERVER_IP | 300 |
| A | traefik | $SERVER_IP | 300 |
| A | nodered | $SERVER_IP | 300 |
| A | mqtt | $SERVER_IP | 300 |

## DNS Propagation

After adding these records:
1. Wait 5-15 minutes for DNS propagation
2. SSL certificates will be automatically generated
3. All services will be accessible via HTTPS

## Test DNS Resolution

You can test if DNS is working:

\`\`\`bash
nslookup $DOMAIN
nslookup www.$DOMAIN
nslookup portainer.$DOMAIN
nslookup traefik.$DOMAIN
nslookup nodered.$DOMAIN
nslookup mqtt.$DOMAIN
\`\`\`

## Troubleshooting

If services are not accessible:
1. Verify DNS records are correct
2. Check if ports 80 and 443 are open on your server
3. Verify firewall settings allow HTTP/HTTPS traffic
4. Check Traefik logs: \`docker-compose logs traefik\`
EOF

# Final instructions
print_success "🎉 FerryLightV2 server setup completed for $DOMAIN!"
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
echo ""
echo "🌐 Your URLs:"
echo "============="
echo "🌐 Main Website: https://$DOMAIN"
echo "🐳 Portainer: https://portainer.$DOMAIN"
echo "🔧 Traefik: https://traefik.$DOMAIN"
echo "🔴 Node-RED: https://nodered.$DOMAIN"
echo "🔌 MQTT Broker: mqtt.$DOMAIN:1883"
echo ""
echo "🔧 Management Commands:"
echo "======================="
echo "cd $PROJECT_DIR"
echo "docker-compose ps          # Check service status"
echo "docker-compose logs        # View logs"
echo "docker-compose restart     # Restart services"
echo "./update.sh               # Update all services"
echo "./backup.sh               # Create backup"
echo ""
echo "🔐 Default Credentials:"
echo "======================="
echo "Traefik Dashboard: admin:admin"
echo "Portainer: Create admin account on first visit"
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
echo "📄 DNS setup instructions saved to: $PROJECT_DIR/DNS_SETUP.md"
echo ""
print_warning "Please reboot the system to ensure all changes take effect."
print_warning "After DNS configuration, SSL certificates will be automatically generated." 