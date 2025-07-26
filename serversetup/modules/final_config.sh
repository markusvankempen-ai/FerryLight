final_configuration() {
    print_step "7" "Final configuration..."
    
    # Set proper permissions
    print_status "Setting proper permissions..."
    sudo chown -R $USER:$USER $PROJECT_DIR
    chmod 600 $PROJECT_DIR/traefik/acme

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

    # Create management scripts
    print_status "Creating management scripts..."
    
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
    cat > $PROJECT_DIR/backup.sh << EOF
#!/bin/bash
BACKUP_DIR="$BACKUP_DIR"
DATE=\$(date +%Y%m%d_%H%M%S)

mkdir -p \$BACKUP_DIR

# Backup Portainer data
docker run --rm -v portainer_data:/data -v \$BACKUP_DIR:/backup alpine tar czf /backup/portainer_\$DATE.tar.gz -C /data .

# Backup Node-RED data
tar czf \$BACKUP_DIR/nodered_\$DATE.tar.gz -C $PROJECT_DIR nodered

# Backup PostgreSQL data
docker exec postgres pg_dump -U \${POSTGRES_USER:-ferrylight} \${POSTGRES_DB:-ferrylight} > \$BACKUP_DIR/postgres_\$DATE.sql
gzip \$BACKUP_DIR/postgres_\$DATE.sql

# Backup Traefik certificates
tar czf \$BACKUP_DIR/traefik_\$DATE.tar.gz -C $PROJECT_DIR traefik/acme

echo "Backup completed: \$BACKUP_DIR"
EOF

    # MQTT test script
    cat > $PROJECT_DIR/test_mqtt.sh << 'EOF'
#!/bin/bash

# FerryLightV2 MQTT Test Script
# Author: Markus van Kempen - markus.van.kempen@gmail.com

DOMAIN="\${DOMAIN:-ferrylight.online}"
MQTT_USERNAME="\${MQTT_USERNAME:-ferrylight}"
MQTT_PASSWORD="\${MQTT_PASSWORD:-your-secure-mqtt-password}"

echo "🔧 MQTT Configuration:"
echo "======================"
echo "• Broker: mqtt.\$DOMAIN"
echo "• Port: 1883"
echo "• Username: \$MQTT_USERNAME"
echo "• Password: \$MQTT_PASSWORD"
echo "• Authentication: Required"
echo "• WebSocket: ws://mqtt.\$DOMAIN:9001"
echo ""
echo "📱 Test with MQTT Client Apps:"
echo "=============================="
echo "• Use any MQTT client app"
echo "• Connect to: mqtt.\$DOMAIN:1883"
echo "• Username: \$MQTT_USERNAME"
echo "• Password: \$MQTT_PASSWORD"
echo "• Subscribe to: ferrylight/test"
echo ""
echo "🧪 Quick Test Commands:"
echo "======================"
echo "# Publish a message:"
echo "mosquitto_pub -h mqtt.\$DOMAIN -p 1883 -t ferrylight/test -m 'Hello' -u \$MQTT_USERNAME -P '\$MQTT_PASSWORD'"
echo ""
echo "# Subscribe to topic:"
echo "mosquitto_sub -h mqtt.\$DOMAIN -p 1883 -t ferrylight/test -u \$MQTT_USERNAME -P '\$MQTT_PASSWORD'"
echo ""
echo "[WARNING] Note: Anonymous access is now disabled. All clients must use authentication."
EOF

    # PostgreSQL test script
    cat > $PROJECT_DIR/test_postgres.sh << 'EOF'
#!/bin/bash

# FerryLightV2 PostgreSQL Test Script
# Author: Markus van Kempen - markus.van.kempen@gmail.com

echo "🐘 PostgreSQL Configuration:"
echo "============================"
echo "• Host: postgres"
echo "• Port: 5432"
echo "• Database: \${POSTGRES_DB:-ferrylight}"
echo "• Username: \${POSTGRES_USER:-ferrylight}"
echo "• Password: \${POSTGRES_PASSWORD:-your-secure-database-password}"
echo "• pgAdmin: https://pgadmin.\${DOMAIN:-ferrylight.online}"
echo ""
echo "🧪 Quick Test Commands:"
echo "======================"
echo "# Connect to PostgreSQL:"
echo "docker exec -it postgres psql -U \${POSTGRES_USER:-ferrylight} -d \${POSTGRES_DB:-ferrylight}"
echo ""
echo "# List tables:"
echo "docker exec postgres psql -U \${POSTGRES_USER:-ferrylight} -d \${POSTGRES_DB:-ferrylight} -c '\dt'"
echo ""
echo "# Query sample data:"
echo "docker exec postgres psql -U \${POSTGRES_USER:-ferrylight} -d \${POSTGRES_DB:-ferrylight} -c 'SELECT * FROM traffic_events ORDER BY timestamp DESC LIMIT 5;'"
echo ""
echo "# Check database size:"
echo "docker exec postgres psql -U \${POSTGRES_USER:-ferrylight} -d \${POSTGRES_DB:-ferrylight} -c 'SELECT pg_size_pretty(pg_database_size(\"\${POSTGRES_DB:-ferrylight}\"));'"
echo ""
echo "📊 pgAdmin Access:"
echo "=================="
echo "• URL: https://pgadmin.\${DOMAIN:-ferrylight.online}"
echo "• Email: \${PGADMIN_EMAIL:-admin@ferrylight.online}"
echo "• Password: \${PGADMIN_PASSWORD:-your-secure-password}"
EOF

    chmod +x $PROJECT_DIR/update.sh
    chmod +x $PROJECT_DIR/backup.sh
    chmod +x $PROJECT_DIR/test_mqtt.sh
    chmod +x $PROJECT_DIR/test_postgres.sh

    print_success "Final configuration completed"
} 