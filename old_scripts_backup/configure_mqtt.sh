#!/bin/bash

# FerryLightV2 MQTT Configuration Script

set -e

PROJECT_DIR="/opt/ferrylightv2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

echo "🔌 FerryLightV2 MQTT Configuration"
echo "=================================="

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory not found. Please run setup_ferrylight.sh first."
    exit 1
fi

# Check if Mosquitto is running
if ! docker ps | grep -q mosquitto; then
    print_error "Mosquitto container is not running. Please start the services first."
    exit 1
fi

echo ""
echo "Choose MQTT configuration option:"
echo "1. Anonymous access (current default)"
echo "2. Username/password authentication"
echo "3. Advanced ACL configuration"
echo "4. View current configuration"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        print_status "Configuring anonymous access..."
        # This is already the default configuration
        print_success "Anonymous access is already configured"
        ;;
    2)
        print_status "Setting up username/password authentication..."
        
        read -p "Enter username: " username
        read -s -p "Enter password: " password
        echo ""
        
        # Create password file
        docker exec mosquitto mosquitto_passwd -c /mosquitto/config/passwd $username <<< "$password" <<< "$password"
        
        # Update mosquitto.conf
        sed -i 's/# password_file \/mosquitto\/config\/passwd/password_file \/mosquitto\/config\/passwd/' $PROJECT_DIR/mosquitto/config/mosquitto.conf
        sed -i 's/allow_anonymous true/allow_anonymous false/' $PROJECT_DIR/mosquitto/config/mosquitto.conf
        
        print_success "Username/password authentication configured"
        print_status "Username: $username"
        ;;
    3)
        print_status "Setting up advanced ACL configuration..."
        
        read -p "Enter username: " username
        read -s -p "Enter password: " password
        echo ""
        
        # Create password file
        docker exec mosquitto mosquitto_passwd -c /mosquitto/config/passwd $username <<< "$password" <<< "$password"
        
        # Create ACL file
        cat > $PROJECT_DIR/mosquitto/config/acl << EOF
# Access Control List for Mosquitto MQTT Broker

# User: $username
user $username
topic readwrite #

# Anonymous users (if needed)
# topic read public/#
# topic write public/#

# Deny all other access
pattern readwrite #
EOF
        
        # Update mosquitto.conf
        sed -i 's/# password_file \/mosquitto\/config\/passwd/password_file \/mosquitto\/config\/passwd/' $PROJECT_DIR/mosquitto/config/mosquitto.conf
        sed -i 's/# acl_file \/mosquitto\/config\/acl/acl_file \/mosquitto\/config\/acl/' $PROJECT_DIR/mosquitto/config/mosquitto.conf
        sed -i 's/allow_anonymous true/allow_anonymous false/' $PROJECT_DIR/mosquitto/config/mosquitto.conf
        
        print_success "Advanced ACL configuration completed"
        print_status "Username: $username"
        print_status "ACL file created with full read/write access"
        ;;
    4)
        print_status "Current MQTT configuration:"
        echo ""
        echo "=== Mosquitto Configuration ==="
        cat $PROJECT_DIR/mosquitto/config/mosquitto.conf
        echo ""
        
        if [ -f "$PROJECT_DIR/mosquitto/config/passwd" ]; then
            echo "=== Users ==="
            docker exec mosquitto mosquitto_passwd -U /mosquitto/config/passwd
        fi
        
        if [ -f "$PROJECT_DIR/mosquitto/config/acl" ]; then
            echo ""
            echo "=== ACL Configuration ==="
            cat $PROJECT_DIR/mosquitto/config/acl
        fi
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

# Restart Mosquitto if configuration was changed
if [ "$choice" = "2" ] || [ "$choice" = "3" ]; then
    print_status "Restarting Mosquitto to apply new configuration..."
    cd $PROJECT_DIR
    docker-compose restart mosquitto
    
    print_success "Mosquitto restarted with new configuration"
    echo ""
    echo "🔌 MQTT Connection Details:"
    echo "==========================="
    echo "Broker: mqtt.ferrylight.online"
    echo "Port: 1883 (TCP) / 9001 (WebSocket)"
    if [ "$choice" = "2" ] || [ "$choice" = "3" ]; then
        echo "Username: $username"
        echo "Authentication: Required"
    else
        echo "Authentication: Anonymous"
    fi
    echo ""
    echo "📝 Test with mosquitto_pub/sub:"
    echo "mosquitto_pub -h mqtt.ferrylight.online -t test/topic -m 'Hello World'"
    echo "mosquitto_sub -h mqtt.ferrylight.online -t test/topic"
fi 