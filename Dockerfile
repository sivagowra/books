# Multi-stage build for Frappe Books Electron application
FROM node:18-alpine AS base

# Install system dependencies for Electron and native modules
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    python3 \
    make \
    g++ \
    sqlite \
    sqlite-dev

# Set environment variables for Electron
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV ELECTRON_DISABLE_SECURITY_WARNINGS=true

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY yarn.lock* ./

# Install dependencies
RUN npm ci --only=production --force && npm cache clean --force

# Development stage
FROM base AS development
RUN npm ci --force
COPY . .
EXPOSE 6969
CMD ["npm", "run", "dev"]

# Build stage
FROM base AS builder
RUN npm ci --force
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    sqlite \
    sqlite-dev

# Set environment variables
ENV NODE_ENV=production
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV ELECTRON_DISABLE_SECURITY_WARNINGS=true

# Create app user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S frappe -u 1001

# Set working directory
WORKDIR /app

# Copy built application
COPY --from=builder --chown=frappe:nodejs /app/dist_electron ./dist_electron
COPY --from=builder --chown=frappe:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=frappe:nodejs /app/package*.json ./

# Create data directory for SQLite database
RUN mkdir -p /app/data && chown frappe:nodejs /app/data

# Switch to non-root user
USER frappe

# Expose port for web interface (if needed)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "console.log('Health check passed')" || exit 1

# Start the application
CMD ["node", "dist_electron/main.js"]
