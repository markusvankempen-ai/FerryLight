#!/bin/bash

# Fix Traefik Middleware References Script
# Author: Markus van Kempen - markus.van.kempen@gmail.com
# Date: 24-July-2025

set -e

COMPOSE_FILE="/opt/ferrylightv2/docker-compose.yml"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "[ERROR] $COMPOSE_FILE not found!"
  exit 1
fi

# Patch traefik and website middleware references
sudo sed -i \
  -e 's/traefik.http.routers.traefik.middlewares=traefik-auth/traefik.http.routers.traefik.middlewares=traefik-auth@file/g' \
  -e 's/traefik.http.routers.website.middlewares=secure-headers/traefik.http.routers.website.middlewares=secure-headers@file/g' \
  "$COMPOSE_FILE"

echo "[SUCCESS] Middleware references updated in $COMPOSE_FILE"
echo ""
echo "Next steps:"
echo "1. Restart services:"
echo "   cd /opt/ferrylightv2"
echo "   docker-compose down"
echo "   docker-compose up -d"
echo "2. Test your site: https://ferrylight.online/ and https://traefik.ferrylight.online/"
echo "3. If you still get 404 errors, run: ./troubleshoot_404.sh" 