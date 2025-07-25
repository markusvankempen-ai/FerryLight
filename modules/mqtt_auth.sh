configure_mqtt_auth() {
    print_step "6" "Configuring MQTT authentication..."
    
    # Ensure container is running
    print_status "Ensuring Mosquitto container is running..."
    if ! docker ps | grep -q mosquitto-broker; then
        print_warning "Mosquitto container not running, starting..."
        docker-compose up -d mosquitto-broker
        sleep 5
    fi
    
    if docker ps | grep -q mosquitto-broker; then
        print_success "✅ Mosquitto container is running"
    else
        print_error "❌ Failed to start Mosquitto container"
        exit 1
    fi

    # Fix permissions
    print_status "Fixing permissions..."
    sudo chown -R $USER:$USER $PROJECT_DIR/mosquitto
    sudo chmod -R 755 $PROJECT_DIR/mosquitto
    sudo chmod 644 $PROJECT_DIR/mosquitto/config/mosquitto.conf

    # Create backup of current config
    print_status "Creating backup of current configuration..."
    cp $PROJECT_DIR/mosquitto/config/mosquitto.conf $PROJECT_DIR/mosquitto/config/mosquitto.conf.backup 2>/dev/null || true
    
    # Create comprehensive Mosquitto configuration
    print_status "Creating comprehensive Mosquitto configuration..."
    cat > $PROJECT_DIR/mosquitto/config/mosquitto.conf << EOF
# FerryLightV2 MQTT Broker Configuration
# Generated: $(date)

# Network settings
listener 1883 0.0.0.0
protocol mqtt

# WebSocket support
listener 9001 0.0.0.0
protocol websockets

# Security settings
allow_anonymous false
password_file /mosquitto/config/passwd

# Logging
log_type all
log_timestamp true

# Persistence
persistence true
persistence_location /mosquitto/data/

# Connection settings
max_connections 100
max_inflight_messages 20
max_queued_messages 100

# Keep alive
keepalive_interval 60

# Performance settings
max_packet_size 0
message_size_limit 0
EOF

    # Remove existing password file and create new one
    print_status "Creating password file..."
    docker exec mosquitto-broker rm -f /mosquitto/config/passwd
    
    # Create password file inside container
    docker exec mosquitto-broker sh -c "mosquitto_passwd -c /mosquitto/config/passwd \$MQTT_USERNAME << EOF
\$MQTT_PASSWORD
\$MQTT_PASSWORD
EOF"

    # Verify password file was created
    print_status "Verifying password file..."
    if docker exec mosquitto-broker test -f /mosquitto/config/passwd; then
        print_success "✅ Password file created"
        print_status "Password file contents:"
        docker exec mosquitto-broker cat /mosquitto/config/passwd
    else
        print_error "❌ Failed to create password file"
        exit 1
    fi

    # Restart Mosquitto with new configuration
    print_status "Restarting Mosquitto with new configuration..."
    docker-compose restart mosquitto-broker
    sleep 5

    # Check Mosquitto logs
    print_status "Checking Mosquitto logs..."
    echo "=== Recent Mosquitto logs ==="
    docker-compose logs mosquitto-broker --tail=5
    echo ""

    # Test authentication
    print_status "Testing MQTT authentication..."
    if mosquitto_pub -h mqtt.\$DOMAIN -p 1883 -t ferrylight/test -m "Auth test \$(date)" -u \$MQTT_USERNAME -P "\$MQTT_PASSWORD" -q 1; then
        print_success "✅ MQTT authentication test successful!"
    else
        print_warning "⚠️  MQTT authentication test failed - this is normal if DNS is not configured yet"
        print_status "Checking for common issues..."
        
        # Check if mosquitto is listening on the right interface
        print_status "Checking Mosquitto listening status..."
        docker exec mosquitto-broker netstat -tlnp | grep 1883 || print_warning "Mosquitto not listening on port 1883"
        
        # Check mosquitto config
        print_status "Current Mosquitto configuration:"
        docker exec mosquitto-broker cat /mosquitto/config/mosquitto.conf | grep -E "(allow_anonymous|password_file|listener)"
    fi

    print_success "MQTT authentication configured"
} 