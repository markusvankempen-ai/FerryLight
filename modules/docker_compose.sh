create_docker_compose() {
    print_step "4" "Creating Docker Compose configuration..."
    
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
      - "traefik.http.routers.traefik.rule=Host(\`traefik.$DOMAIN\`)"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.middlewares=auth"
      - "traefik.http.middlewares.auth.basicauth.users=\${TRAEFIK_USERNAME}:\$\$2y\$\$10\$\$8K1p/a0dL1LXMIgoEDFrwOfgqwAG6WUa9EqJdKvJ/JOIdw0KxQK8K"

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

  postgres:
    image: postgres:15-alpine
    container_name: postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: \${POSTGRES_DB:-ferrylight}
      POSTGRES_USER: \${POSTGRES_USER:-ferrylight}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD:-your-secure-database-password}
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - ./postgres/data:/var/lib/postgresql/data
      - ./postgres/init:/docker-entrypoint-initdb.d
    networks:
      - traefik-public
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ferrylight -d ferrylight"]
      interval: 30s
      timeout: 10s
      retries: 3

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: pgadmin
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: \${PGADMIN_EMAIL:-admin@ferrylight.online}
      PGADMIN_DEFAULT_PASSWORD: \${PGADMIN_PASSWORD:-your-secure-password}
      PGADMIN_CONFIG_SERVER_MODE: 'False'
      PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: 'False'
    volumes:
      - ./pgadmin:/var/lib/pgadmin
    networks:
      - traefik-public
    depends_on:
      - postgres
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.pgadmin.rule=Host(\`pgadmin.$DOMAIN\`)"
      - "traefik.http.routers.pgadmin.entrypoints=websecure"
      - "traefik.http.routers.pgadmin.tls.certresolver=letsencrypt"
      - "traefik.http.services.pgadmin.loadbalancer.server.port=80"

  mosquitto-broker:
    image: eclipse-mosquitto:latest
    container_name: mosquitto-broker
    restart: unless-stopped
    ports:
      - "1883:1883"  # MQTT
      - "9001:9001"  # WebSocket
    volumes:
      - ./mosquitto/config:/mosquitto/config:ro
      - ./mosquitto/data:/mosquitto/data
      - ./mosquitto/logs:/mosquitto/logs
    networks:
      - traefik-public
    labels:
      - "traefik.enable=true"
      - "traefik.tcp.routers.mqtt.rule=HostSNI(\`mqtt.$DOMAIN\`)"
      - "traefik.tcp.routers.mqtt.entrypoints=websecure"
      - "traefik.tcp.routers.mqtt.tls.certresolver=letsencrypt"
      - "traefik.tcp.services.mqtt.loadbalancer.server.port=1883"
      - "traefik.tcp.routers.mqtt-ws.rule=HostSNI(\`mqtt.$DOMAIN\`)"
      - "traefik.tcp.routers.mqtt-ws.entrypoints=websecure"
      - "traefik.tcp.routers.mqtt-ws.tls.certresolver=letsencrypt"
      - "traefik.tcp.services.mqtt-ws.loadbalancer.server.port=9001"

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

networks:
  traefik-public:
    external: true
EOF

    # Create Nginx configuration
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

    # Create website
    print_status "Creating website..."
    cat > $PROJECT_DIR/website/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FerryLightV2 - Traffic Light Management System</title>
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

        .services {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }

        .service {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            border-left: 4px solid #667eea;
        }

        .service h4 {
            color: #333;
            margin-bottom: 10px;
        }

        .service p {
            color: #666;
            margin-bottom: 15px;
        }

        .service a {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            padding: 10px 20px;
            border-radius: 5px;
            display: inline-block;
            transition: transform 0.3s ease;
        }

        .service a:hover {
            transform: translateY(-2px);
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
        <div class="subtitle">Traffic Light Management System</div>
        
        <div class="status">
            <h3>✅ System Status: Online</h3>
            <p>All services are running successfully</p>
        </div>

        <div class="services">
            <div class="service">
                <h4>🐳 Portainer</h4>
                <p>Docker container management</p>
                <a href="https://portainer.$DOMAIN" target="_blank">Access Dashboard</a>
            </div>
            
            <div class="service">
                <h4>🔧 Traefik</h4>
                <p>Reverse proxy and load balancer</p>
                <a href="https://traefik.$DOMAIN" target="_blank">Access Dashboard</a>
            </div>
            
            <div class="service">
                <h4>🔴 Node-RED</h4>
                <p>Flow-based programming</p>
                <a href="https://nodered.$DOMAIN" target="_blank">Access Dashboard</a>
            </div>
            
            <div class="service">
                <h4>🐘 PostgreSQL</h4>
                <p>Database server</p>
                <p><strong>Host:</strong> postgres</p>
                <p><strong>Port:</strong> 5432</p>
            </div>
            
            <div class="service">
                <h4>📊 pgAdmin</h4>
                <p>Database administration</p>
                <a href="https://pgadmin.$DOMAIN" target="_blank">Access Dashboard</a>
            </div>
            
            <div class="service">
                <h4>📡 MQTT Broker</h4>
                <p>Message queuing for IoT</p>
                <p><strong>Broker:</strong> mqtt.$DOMAIN:1883</p>
                <p><strong>WebSocket:</strong> ws://mqtt.$DOMAIN:9001</p>
            </div>
        </div>

        <div class="info">
            <h4>📋 System Information</h4>
            <p><strong>Domain:</strong> $DOMAIN</p>
            <p><strong>IP Address:</strong> $SERVER_IP</p>
            <p><strong>SSL:</strong> Let's Encrypt (Automatic)</p>
            <p><strong>MQTT Authentication:</strong> Required (configure via environment variables)</p>
<p><strong>PostgreSQL:</strong> Configure via environment variables</p>
            <p><strong>pgAdmin:</strong> Configure via environment variables</p>
        </div>
    </div>
</body>
</html>
EOF

    # Create PostgreSQL initialization script
    print_status "Creating PostgreSQL initialization script..."
    cat > $PROJECT_DIR/postgres/init/01-init.sql << 'EOF'
-- FerryLightV2 Database Initialization
-- This script runs when PostgreSQL starts for the first time

-- Create sample tables for traffic light data
CREATE TABLE IF NOT EXISTS traffic_events (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_type VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    status VARCHAR(20),
    data JSONB
);

CREATE TABLE IF NOT EXISTS mqtt_messages (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    topic VARCHAR(200) NOT NULL,
    message TEXT,
    client_id VARCHAR(100)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_traffic_events_timestamp ON traffic_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_mqtt_messages_timestamp ON mqtt_messages(timestamp);
CREATE INDEX IF NOT EXISTS idx_mqtt_messages_topic ON mqtt_messages(topic);

-- Insert sample data
INSERT INTO traffic_events (event_type, location, status, data) VALUES
('LIGHT_CHANGE', 'Main Intersection', 'GREEN', '{"duration": 30, "sensor_data": {"vehicle_count": 5}}'),
('SENSOR_TRIGGER', 'Side Street', 'YELLOW', '{"pedestrian_detected": true}'),
('SYSTEM_STATUS', 'All Lights', 'OPERATIONAL', '{"uptime": 86400, "errors": 0}');
EOF

    print_success "Docker Compose configuration created"
} 