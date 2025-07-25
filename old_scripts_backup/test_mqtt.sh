#!/bin/bash

# MQTT Test Script for FerryLightV2
# Author: Markus van Kempen - markus.van.kempen@gmail.com
# Date: 24-July-2025

set -e

MQTT_HOST="mqtt.ferrylight.online"
MQTT_PORT="1883"
TEST_TOPIC="ferrylight/test"
TEST_MESSAGE="Hello from FerryLightV2 MQTT Test - $(date)"

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

echo "🔌 MQTT Test for FerryLightV2"
echo "============================="
echo ""
echo "Testing connection to: $MQTT_HOST:$MQTT_PORT"
echo "Test topic: $TEST_TOPIC"
echo "Test message: $TEST_MESSAGE"
echo ""

# Check if mosquitto_pub is available
if ! command -v mosquitto_pub &> /dev/null; then
    print_error "mosquitto_pub not found. Installing mosquitto-clients..."
    sudo apt update
    sudo apt install -y mosquitto-clients
fi

# Test 1: Basic connectivity
print_status "Test 1: Testing basic connectivity..."
if ping -c 1 $MQTT_HOST > /dev/null 2>&1; then
    print_success "✅ Host is reachable"
else
    print_error "❌ Host is not reachable"
    print_warning "Check DNS resolution: nslookup $MQTT_HOST"
    exit 1
fi

# Test 2: Port connectivity
print_status "Test 2: Testing port connectivity..."
if nc -z $MQTT_HOST $MQTT_PORT 2>/dev/null; then
    print_success "✅ Port $MQTT_PORT is open"
else
    print_error "❌ Port $MQTT_PORT is not accessible"
    print_warning "Check if MQTT broker is running and port is open"
    exit 1
fi

# Test 3: Send test message
print_status "Test 3: Sending test message..."
if mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -t $TEST_TOPIC -m "$TEST_MESSAGE" -q 1; then
    print_success "✅ Message sent successfully"
else
    print_error "❌ Failed to send message"
    print_warning "Check MQTT broker configuration and authentication"
    exit 1
fi

# Test 4: Subscribe and receive message
print_status "Test 4: Testing message reception..."
print_status "Subscribing to topic: $TEST_TOPIC"
print_status "Waiting for messages (timeout: 10 seconds)..."
echo ""

# Send another message and try to receive it
mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -t $TEST_TOPIC -m "Test message $(date)" -q 1 &
sleep 1

# Subscribe and listen for messages
timeout 10 mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -t $TEST_TOPIC -C 1 || {
    print_warning "⚠️  No messages received (this might be normal if no other clients are publishing)"
}

echo ""
print_success "🎉 MQTT Test Completed!"
echo ""
echo "📋 Test Summary:"
echo "================"
echo "✅ Host connectivity: $MQTT_HOST"
echo "✅ Port accessibility: $MQTT_PORT"
echo "✅ Message publishing: $TEST_TOPIC"
echo ""
echo "🔧 MQTT Configuration:"
echo "======================"
echo "• Broker: $MQTT_HOST"
echo "• Port: $MQTT_PORT"
echo "• Authentication: Anonymous (open access)"
echo "• WebSocket: ws://$MQTT_HOST:9001"
echo ""
echo "📱 Test with MQTT Client Apps:"
echo "=============================="
echo "• Use any MQTT client app"
echo "• Connect to: $MQTT_HOST:$MQTT_PORT"
echo "• Subscribe to: $TEST_TOPIC"
echo "• No username/password required (anonymous access)"
echo ""
print_warning "Note: If you want to test WebSocket connection, use port 9001" 