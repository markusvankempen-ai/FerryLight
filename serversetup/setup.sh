#!/bin/bash
# FerryLightV2 Server Setup Launcher
# Author: Markus van Kempen
# Date: July 24, 2025
# Email: markus.van.kempen@gmail.com

set -e

echo "🚀 FerryLightV2 Server Setup Launcher"
echo "======================================"
echo "Author: Markus van Kempen"
echo "Date: July 24, 2025"
echo ""

# Check if running from correct directory
if [ ! -f "setup_ferrylightv2_complete.sh" ]; then
    echo "❌ Error: Please run this script from the serversetup directory"
    echo "   cd serversetup"
    echo "   ./setup.sh"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found"
    echo "   Please copy env.example to .env and configure your settings:"
    echo "   cp env.example .env"
    echo "   nano .env"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Make main setup script executable
chmod +x setup_ferrylightv2_complete.sh

# Make all module scripts executable
chmod +x modules/*.sh

echo "✅ Starting FerryLightV2 complete setup..."
echo ""

# Run the complete setup
./setup_ferrylightv2_complete.sh

echo ""
echo "🎉 Setup completed successfully!"
echo "📚 Check the documentation in this directory for more information."
echo "🔐 Remember to keep your .env file secure and never commit it to version control." 