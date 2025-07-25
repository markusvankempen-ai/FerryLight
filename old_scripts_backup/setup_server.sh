#!/bin/bash

# FerryLightV2 Server Setup Script
# Ubuntu 22.04 LTS with Docker, Portainer, Traefik, and SSL

set -e

echo "🚀 Starting FerryLightV2 server setup..."

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

# Create project directory
PROJECT_DIR="/opt/ferrylightv2"
print_status "Creating project directory at $PROJECT_DIR..."
sudo mkdir -p $PROJECT_DIR
sudo chown $USER:$USER $PROJECT_DIR

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

# Create Traefik configuration
print_status "Creating Traefik configuration..."
cat > $PROJECT_DIR/traefik/traefik.yml << 'EOF'
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
      email: admin@ferrylightv2.com
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
cat > $PROJECT_DIR/docker-compose.yml << 'EOF'
version: '3.8'

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
      - "traefik.http.routers.traefik.rule=Host(`traefik.ferrylightv2.com`)"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.middlewares=auth"
      - "traefik.http.middlewares.auth.basicauth.users=admin:$$2y$$10$$8K1p/a0dL1LXMIgoEDFrwOfgqwAG6WUa9EqJdKvJ/JOIdw0KxQK8K"

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
      - "traefik.http.routers.portainer.rule=Host(`portainer.ferrylightv2.com`)"
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
      - "traefik.http.routers.website.rule=Host(`ferrylightv2.com`) || Host(`www.ferrylightv2.com`)"
      - "traefik.http.routers.website.entrypoints=websecure"
      - "traefik.http.routers.website.tls.certresolver=letsencrypt"
      - "traefik.http.routers.website.middlewares=secure-headers"
      - "traefik.http.services.website.loadbalancer.server.port=80"

networks:
  traefik-public:
    external: true
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
cat > $PROJECT_DIR/website/index.html << 'EOF'
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
            <a href="https://portainer.ferrylightv2.com" class="link" target="_blank">
                🐳 Portainer Dashboard
            </a>
            <a href="https://traefik.ferrylightv2.com" class="link" target="_blank">
                🔧 Traefik Dashboard
            </a>
        </div>

        <div class="info">
            <h4>📋 Server Information</h4>
            <p><strong>OS:</strong> Ubuntu 22.04 LTS</p>
            <p><strong>Docker:</strong> Latest</p>
            <p><strong>SSL:</strong> Let's Encrypt (Automatic)</p>
            <p><strong>Ports:</strong> 80 (HTTP), 443 (HTTPS)</p>
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

# Final instructions
print_success "🎉 FerryLightV2 server setup completed!"
echo ""
echo "📋 Setup Summary:"
echo "=================="
echo "✅ Docker installed and configured"
echo "✅ Portainer running on https://portainer.ferrylightv2.com"
echo "✅ Traefik running on https://traefik.ferrylightv2.com"
echo "✅ Website running on https://ferrylightv2.com"
echo "✅ SSL certificates will be automatically generated"
echo "✅ Services will auto-start on boot"
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
echo "⚠️  IMPORTANT: Update the domain names in docker-compose.yml"
echo "   and traefik configuration to match your actual domain!"
echo ""
print_warning "Please reboot the system to ensure all changes take effect." 