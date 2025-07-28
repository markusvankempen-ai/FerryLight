#!/bin/bash

# FerryLight Deployment Script
# Author: Markus van Kempen (markus.van.kempen@gmail.com)
# Updated: July 28, 2025

set -e

echo "🚀 Starting FerryLight deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
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
if [ "$EUID" -eq 0 ]; then
    print_warning "Running as root. Consider using a non-root user for security."
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    print_warning ".env file not found. Creating from template..."
    if [ -f env.example ]; then
        cp env.example .env
        print_warning "Please edit .env file with your API credentials before running again."
        print_warning "Required variables: REACT_APP_API_USERNAME, REACT_APP_API_PASSWORD"
        exit 1
    else
        print_error "env.example file not found. Cannot create .env file."
        exit 1
    fi
fi

# Validate required environment variables
print_status "Validating environment variables..."
source .env

if [ -z "$REACT_APP_API_USERNAME" ] || [ -z "$REACT_APP_API_PASSWORD" ]; then
    print_error "Missing required API credentials in .env file."
    print_error "Please set REACT_APP_API_USERNAME and REACT_APP_API_PASSWORD"
    exit 1
fi

print_success "Environment variables validated."

# Create necessary directories
print_status "Creating directories..."
mkdir -p logs/nginx
mkdir -p ssl
print_success "Directories created."

# Check for SSL certificates
if [ ! -f ssl/cert.pem ] || [ ! -f ssl/key.pem ]; then
    print_warning "SSL certificates not found. Creating self-signed certificates..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/key.pem \
        -out ssl/cert.pem \
        -subj "/C=CA/ST=NS/L=Sydney/O=FerryLight/CN=ferrylight.local"
    print_warning "Self-signed certificates created. Replace with proper SSL certificates for production."
fi

# Stop existing containers
print_status "Stopping existing containers..."
docker-compose down --remove-orphans || true

# Build and start services
print_status "Building and starting services..."
docker-compose build --no-cache

# Start core services
print_status "Starting FerryLight services..."
docker-compose up -d ferrylight-app nginx-proxy

# Wait for services to be healthy
print_status "Waiting for services to be ready..."
timeout=60
counter=0

while [ $counter -lt $timeout ]; do
    if docker-compose ps | grep -q "healthy"; then
        break
    fi
    echo -n "."
    sleep 2
    counter=$((counter + 2))
done

if [ $counter -ge $timeout ]; then
    print_error "Services failed to start within $timeout seconds."
    docker-compose logs
    exit 1
fi

print_success "Services are running!"

# Test endpoints
print_status "Testing endpoints..."

# Test HTTP redirect
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "301"; then
    print_success "HTTP to HTTPS redirect working"
else
    print_warning "HTTP redirect may not be working correctly"
fi

# Test HTTPS (ignore SSL certificate for self-signed)
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost | grep -q "200"; then
    print_success "HTTPS endpoint responding"
else
    print_warning "HTTPS endpoint may not be working correctly"
fi

# Test API health
if curl -k -s https://localhost/api/health | grep -q "healthy"; then
    print_success "API health check passed"
else
    print_warning "API health check failed"
fi

# Show status
print_status "Deployment complete! Service status:"
docker-compose ps

print_success "🎉 FerryLight is now running!"
echo ""
echo "📡 Endpoints:"
echo "  - Main app: https://localhost"
echo "  - API health: https://localhost/api/health"
echo "  - Ferry data: https://localhost/api/ferry"
echo "  - Weather data: https://localhost/api/weather"
echo ""
echo "📋 Management commands:"
echo "  - View logs: docker-compose logs -f"
echo "  - Stop services: docker-compose down"
echo "  - Restart: docker-compose restart"
echo "  - Update: git pull && ./deploy.sh"
echo ""

# Optional services prompt
echo "🔧 Optional services available:"
echo "  - Redis cache: docker-compose --profile cache up -d redis-cache"
echo "  - Analytics DB: docker-compose --profile analytics up -d postgres-analytics"
echo ""

print_success "Deployment completed successfully!" 