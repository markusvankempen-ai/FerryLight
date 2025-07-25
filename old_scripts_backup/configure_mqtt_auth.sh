#!/bin/bash

# Configure MQTT Authentication Script
# Author: Markus van Kempen - markus.van.kempen@gmail.com
# Date: 24-July-2025

set -e

PROJECT_DIR="/opt/ferrylightv2"
MQTT_USERNAME="ferrylight"
MQTT_PASSWORD="ferrylight@Connexts@99"  # 15-digit password

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

echo "🔐 Configuring MQTT Authentication"
echo "================================="
echo ""
echo "Username: $MQTT_USERNAME"
echo "Password: $MQTT_PASSWORD"
echo ""

# Check if we're in the right directory
if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    print_error "Docker Compose file not found!"
    print_error "Please run this script from the FerryLightV2 project directory."
    exit 1
fi

cd $PROJECT_DIR

# Check if mosquitto container is running
if ! docker ps | grep -q mosquitto-broker; then
    print_error "Mosquitto container is not running!"
    print_error "Please start the services first: docker-compose up -d"
    exit 1
fi

print_status "Step 1: Creating password file..."
# Create password file using a different approach to handle special characters
docker exec mosquitto-broker sh -c "mosquitto_passwd -c /mosquitto/config/passwd $MQTT_USERNAME << EOF
$MQTT_PASSWORD
$MQTT_PASSWORD
EOF"

print_status "Step 2: Updating Mosquitto configuration..."
# Update mosquitto.conf to enable password authentication
sed -i 's/allow_anonymous true/allow_anonymous false/' mosquitto/config/mosquitto.conf
sed -i 's/# password_file \/mosquitto\/config\/passwd/password_file \/mosquitto\/config\/passwd/' mosquitto/config/mosquitto.conf

print_status "Step 3: Restarting Mosquitto container..."
docker-compose restart mosquitto

print_status "Step 4: Waiting for service to start..."
sleep 5

print_status "Step 5: Testing authentication..."
# Test the authentication
if mosquitto_pub -h mqtt.ferrylight.online -p 1883 -t ferrylight/test -m "Auth test" -u $MQTT_USERNAME -P $MQTT_PASSWORD -q 1; then
    print_success "✅ Authentication test successful!"
else
    print_error "❌ Authentication test failed!"
    print_warning "Check the Mosquitto logs: docker-compose logs mosquitto"
    exit 1
fi

echo ""
print_success "🎉 MQTT Authentication Configured Successfully!"
echo ""
echo "📋 Configuration Summary:"
echo "========================"
echo "• Username: $MQTT_USERNAME"
echo "• Password: $MQTT_PASSWORD"
echo "• Broker: mqtt.ferrylight.online"
echo "• Port: 1883"
echo "• Authentication: Enabled"
echo ""
echo "🔧 Test Commands:"
echo "================"
echo "Publish message:"
echo "mosquitto_pub -h mqtt.ferrylight.online -p 1883 -t ferrylight/test -m 'Hello' -u $MQTT_USERNAME -P $MQTT_PASSWORD"
echo ""
echo "Subscribe to topic:"
echo "mosquitto_sub -h mqtt.ferrylight.online -p 1883 -t ferrylight/test -u $MQTT_USERNAME -P $MQTT_PASSWORD"
echo ""
echo "📱 MQTT Client Configuration:"
echo "============================="
echo "• Host: mqtt.ferrylight.online"
echo "• Port: 1883"
echo "• Username: $MQTT_USERNAME"
echo "• Password: $MQTT_PASSWORD"
echo ""
print_warning "Note: Anonymous access is now disabled. All clients must use authentication." 