# Multi-stage build for FerryLight React app with Express.js server
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci

# Copy all source files (excluding what's in .dockerignore)
COPY . .

# Debug: List what files we actually have
RUN echo "=== DEBUG: Files in /app ===" && ls -la
RUN echo "=== DEBUG: Files in /app/public ===" && ls -la public/ || echo "Public directory not found!"
RUN echo "=== DEBUG: Check for index.html ===" && test -f public/index.html && echo "index.html found" || echo "index.html NOT found"

# Build the React app (skip favicon generation for Docker)
RUN npm run build:docker

# Production stage
FROM node:18-alpine

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create app directory
WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S ferrylight -u 1001

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy built React app from builder stage
COPY --from=builder /app/build ./build

# Copy server files
COPY server.js ./
COPY nginx.conf ./

# Copy environment example (don't copy actual .env)
COPY env.example ./

# Change ownership to non-root user
RUN chown -R ferrylight:nodejs /app
USER ferrylight

# Expose port 3001 for Express server
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start the Express server using dumb-init
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"] 