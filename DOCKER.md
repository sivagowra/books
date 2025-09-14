# Frappe Books Docker Setup

This repository contains Docker configuration files for running Frappe Books in containerized environments.

## Files Created

- `Dockerfile` - Multi-stage Docker build configuration
- `docker-compose.yml` - Docker Compose configuration for easy deployment
- `.dockerignore` - Optimizes Docker build context by excluding unnecessary files

## Quick Start

### Production Deployment

```bash
# Build and start the production container
docker-compose up -d frappe-books

# View logs
docker-compose logs -f frappe-books

# Stop the application
docker-compose down
```

### Development Environment

```bash
# Start development environment with hot reloading
docker-compose --profile dev up frappe-books-dev

# Access the application at http://localhost:6969
```

### With Database Support

```bash
# Start with PostgreSQL database
docker-compose --profile database up -d

# Start with Redis caching
docker-compose --profile cache up -d

# Start with both database and cache
docker-compose --profile database --profile cache up -d
```

## Docker Commands

### Build the Image

```bash
# Build production image
docker build -t frappe-books:latest .

# Build development image
docker build --target development -t frappe-books:dev .
```

### Run Container

```bash
# Run production container
docker run -d \
  --name frappe-books \
  -p 3000:3000 \
  -v frappe-books-data:/app/data \
  frappe-books:latest

# Run development container
docker run -d \
  --name frappe-books-dev \
  -p 6969:6969 \
  -p 5858:5858 \
  -v $(pwd):/app \
  -v /app/node_modules \
  frappe-books:dev
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Node environment | `production` |
| `ELECTRON_DISABLE_SECURITY_WARNINGS` | Disable Electron security warnings | `true` |
| `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD` | Skip Chromium download | `true` |
| `PUPPETEER_EXECUTABLE_PATH` | Path to Chromium executable | `/usr/bin/chromium-browser` |
| `VITE_HOST` | Vite dev server host | `0.0.0.0` |
| `VITE_PORT` | Vite dev server port | `6969` |

## Volumes

- `frappe-books-data` - Persistent storage for application data
- `frappe-books-logs` - Application logs
- `postgres-data` - PostgreSQL database data (if using database profile)
- `redis-data` - Redis cache data (if using cache profile)

## Ports

- `3000` - Production application port
- `6969` - Development server port (Vite)
- `5858` - Electron debug port
- `5432` - PostgreSQL port (if using database profile)
- `6379` - Redis port (if using cache profile)

## Profiles

- `dev` - Development environment with hot reloading
- `database` - Includes PostgreSQL database
- `cache` - Includes Redis for caching

## Health Checks

The containers include health checks that verify the application is running properly:

```bash
# Check container health
docker-compose ps

# View health check logs
docker inspect frappe-books | grep -A 10 Health
```

## Troubleshooting

### Common Issues

1. **Permission Issues**: Ensure the application user has proper permissions
2. **Port Conflicts**: Check if ports are already in use
3. **Memory Issues**: Electron applications may require more memory

### Debug Commands

```bash
# Access container shell
docker-compose exec frappe-books sh

# View container logs
docker-compose logs frappe-books

# Check container resource usage
docker stats frappe-books

# Restart container
docker-compose restart frappe-books
```

## Security Notes

- The application runs as a non-root user (`frappe`)
- Security warnings are disabled for containerized environments
- Data is persisted in Docker volumes for security and backup purposes

## Production Considerations

- Use Docker secrets for sensitive data
- Set up proper logging and monitoring
- Configure backup strategies for volumes
- Use reverse proxy (nginx) for production deployments
- Consider using Docker Swarm or Kubernetes for orchestration
