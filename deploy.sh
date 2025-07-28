#!/bin/bash

# FerryLight App Deployment Script
# This script builds and deploys the FerryLight React app using Docker

set -e

echo "🚢 FerryLight App Deployment"
echo "============================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Build the Docker image
echo "🔨 Building Docker image..."
docker build -t ferrylight-app .

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down || true

# Start the application
echo "🚀 Starting FerryLight app..."
docker-compose up -d

# Wait for the container to be ready
echo "⏳ Waiting for app to be ready..."
sleep 10

# Check if the app is running
if curl -f http://localhost/health &> /dev/null; then
    echo "✅ FerryLight app is running successfully!"
    echo "🌐 Access the app at: http://localhost"
    echo "📊 Health check: http://localhost/health"
else
    echo "❌ App failed to start. Check logs with: docker-compose logs"
    exit 1
fi

echo ""
echo "📋 Useful commands:"
echo "  View logs: docker-compose logs -f"
echo "  Stop app: docker-compose down"
echo "  Restart app: docker-compose restart"
echo "  Update app: ./deploy.sh"
echo ""
echo "🎉 Deployment complete!" 