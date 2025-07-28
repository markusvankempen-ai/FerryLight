#!/bin/bash

# FerryLight Development Startup Script
# This script starts both the Express server and React development server

echo "🚀 Starting FerryLight Development Environment..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found!"
    echo "   Please copy env.example to .env and configure your API credentials:"
    echo "   cp env.example .env"
    echo "   nano .env"
    echo ""
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Start the Express server in the background
echo "🔧 Starting Express server on port 3001..."
npm run server &
SERVER_PID=$!

# Wait a moment for server to start
sleep 2

# Check if server started successfully
if curl -s http://localhost:3001/api/health > /dev/null; then
    echo "✅ Server is running on http://localhost:3001"
else
    echo "❌ Server failed to start. Check the logs above."
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

# Start the React development server
echo "⚛️  Starting React development server on port 3000..."
echo "🌐 Open your browser to: http://localhost:3000"
echo ""
echo "📡 API Endpoints:"
echo "   - http://localhost:3001/api/ferry"
echo "   - http://localhost:3001/api/weather"
echo "   - http://localhost:3001/api/all"
echo "   - http://localhost:3001/api/health"
echo ""
echo "🛑 Press Ctrl+C to stop both servers"

# Start React app
npm start

# Cleanup: kill server when React app stops
echo "🧹 Stopping server..."
kill $SERVER_PID 2>/dev/null
echo "✅ Development environment stopped." 