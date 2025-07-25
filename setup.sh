#!/bin/bash

# FerryLightV2 Quick Setup Script
# Downloads and runs the complete setup

echo "🚀 FerryLightV2 Quick Setup"
echo "==========================="
echo ""

# Check if main script exists
if [ ! -f "setup_ferrylightv2_complete.sh" ]; then
    echo "❌ Main setup script not found!"
    echo "Please ensure setup_ferrylightv2_complete.sh is in the current directory."
    exit 1
fi

# Make main script executable
chmod +x setup_ferrylightv2_complete.sh

# Run the main setup
echo "✅ Starting FerryLightV2 setup..."
./setup_ferrylightv2_complete.sh 