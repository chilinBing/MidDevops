# Docker Commands Reference

## Quick Start Commands

### Start Everything (Recommended)
```bash
# Make script executable and run
chmod +x scripts/docker-setup.sh
./scripts/docker-setup.sh
```

### Manual Docker Compose Commands
```bash
# Start services in development mode
docker compose up --build -d

# Start services in production mode
docker compose -f docker-compose.prod.yml up --build -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Stop and remove volumes (clears database)
docker compose down -v
```

## Individual Container Commands

### MongoDB Container
```bash
# Run MongoDB only
docker run -d \
  --name inventory-mongodb \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password123 \
  -e MONGO_INITDB_DATABASE=inventory \
  -v mongodb_data:/data/db \
  mongo:7.0

# Connect to MongoDB shell
docker exec -it inventory-mongodb mongosh -u admin -p password123 --authenticationDatabase admin

# View MongoDB logs
docker logs inventory-mongodb -f
```

### Application Container
```bash
# Build application image
docker build -t inventory-app .

# Run application container (after MongoDB is running)
docker run -d \
  --name inventory-app \
  -p 3000:3000 \
  -e MONGODB_URI="mongodb://admin:password123@mongodb:27017/inventory?authSource=admin" \
  --link inventory-mongodb:mongodb \
  inventory-app

# View application logs
docker logs inventory-app -f

# Access application shell
docker exec -it inventory-app /bin/sh
```

## Database Operations

### MongoDB Shell Commands
```bash
# Connect to MongoDB
docker exec -it inventory-mongodb mongosh -u admin -p password123 --authenticationDatabase admin

# Switch to inventory database
use inventory

# View collections
show collections

# View all inventory items
db.inventoryitems.find().pretty()

# Count items
db.inventoryitems.countDocuments()

# Create index
db.inventoryitems.createIndex({name: 1})

# Drop collection (careful!)
db.inventoryitems.drop()
```

### Database Backup & Restore
```bash
# Backup database
docker exec inventory-mongodb mongodump --username admin --password password123 --authenticationDatabase admin --db inventory --out /backup

# Copy backup from container
docker cp inventory-mongodb:/backup ./backup

# Restore database
docker exec inventory-mongodb mongorestore --username admin --password password123 --authenticationDatabase admin --db inventory /backup/inventory
```

## Troubleshooting Commands

### Check Container Status
```bash
# List all containers
docker ps -a

# Check specific container
docker inspect inventory-mongodb
docker inspect inventory-app

# Check container resource usage
docker stats
```

### Network Debugging
```bash
# List Docker networks
docker network ls

# Inspect network
docker network inspect inventory-system_inventory-network

# Test connectivity between containers
docker exec inventory-app ping mongodb
```

### Volume Management
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect inventory-system_mongodb_data

# Remove volume (deletes data!)
docker volume rm inventory-system_mongodb_data
```

### Log Analysis
```bash
# View all logs
docker compose logs

# Follow logs for specific service
docker compose logs -f mongodb
docker compose logs -f app

# View last 100 lines
docker compose logs --tail=100 app
```

## Development Workflow

### Code Changes (Development Mode)
```bash
# The development compose file mounts your code
# Changes are automatically reflected (with nodemon)

# Restart just the app service
docker compose restart app

# Rebuild after package.json changes
docker compose up --build app
```

### Database Reset
```bash
# Stop services and remove volumes
docker compose down -v

# Start fresh (will run init script again)
docker compose up -d
```

### Production Deployment
```bash
# Use production compose file
docker compose -f docker-compose.prod.yml up --build -d

# Scale application
docker compose -f docker-compose.prod.yml up --scale app=3 -d
```

## Monitoring & Health Checks

### Application Health
```bash
# Check application health
curl http://localhost:3000/health

# Test API endpoints
curl http://localhost:3000/api/inventory

# Load test (if you have curl)
for i in {1..10}; do curl http://localhost:3000/health; done
```

### MongoDB Health
```bash
# MongoDB ping
docker exec inventory-mongodb mongosh --eval "db.adminCommand('ping')" --quiet

# Check MongoDB status
docker exec inventory-mongodb mongosh --eval "db.serverStatus()" --quiet
```

## Cleanup Commands

### Remove Everything
```bash
# Stop and remove containers, networks, volumes
docker compose down -v --remove-orphans

# Remove images
docker rmi $(docker images "inventory*" -q)

# Clean up Docker system
docker system prune -a
```

### Selective Cleanup
```bash
# Remove only containers
docker compose down

# Remove containers and networks (keep volumes)
docker compose down --remove-orphans

# Remove unused images
docker image prune
```

## Environment Variables

### Development (.env)
```bash
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://admin:password123@mongodb:27017/inventory?authSource=admin
```

### Production (.env.prod)
```bash
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb://admin:password123@mongodb:27017/inventory?authSource=admin
MONGO_USERNAME=admin
MONGO_PASSWORD=your-secure-password
```

## Security Notes

### Change Default Passwords
```bash
# Update in docker-compose.yml
MONGO_INITDB_ROOT_PASSWORD: your-secure-password

# Update in .env
MONGODB_URI=mongodb://admin:your-secure-password@mongodb:27017/inventory?authSource=admin
```

### Network Security
```bash
# Use custom networks (already configured)
# Containers can only communicate within the network
# External access only through exposed ports
```