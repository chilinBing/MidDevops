# 🐳 Docker MongoDB Setup Guide

This guide will help you connect your Inventory Management System with MongoDB using Docker.

## 🚀 Quick Start (Recommended)

### Option 1: Automated Setup Script
```bash
# Run the automated setup script
npm run docker:setup
```

### Option 2: Manual Docker Compose
```bash
# Start all services
npm run docker:up

# Or use docker compose directly
docker compose up --build -d
```

## 📋 What's Included

### Services
- **MongoDB 7.0**: Database with authentication and sample data
- **Node.js App**: Your inventory management application
- **Networking**: Isolated Docker network for secure communication
- **Volumes**: Persistent data storage for MongoDB

### Files Created
- `docker-compose.yml` - Development environment
- `docker-compose.prod.yml` - Production environment  
- `mongo-init/init-db.js` - Database initialization script
- `scripts/docker-setup.sh` - Automated setup script
- `test-mongodb-connection.js` - Connection testing utility

## 🔧 Configuration

### Environment Variables
The system uses these MongoDB connection settings:

**Development (Docker Compose):**
```bash
MONGODB_URI=mongodb://admin:password123@mongodb:27017/inventory?authSource=admin
```

**Local Development (without Docker):**
```bash
MONGODB_URI=mongodb://localhost:27017/inventory
```

### Default Credentials
- **Username**: `admin`
- **Password**: `password123`
- **Database**: `inventory`
- **Port**: `27017`

## 📊 Sample Data

The MongoDB container automatically creates sample inventory items:
- Laptop Computer ($999.99)
- Office Chair ($299.99)  
- Wireless Mouse ($49.99)
- Programming Book ($39.99)

## 🛠️ Available Commands

### NPM Scripts
```bash
npm run docker:setup    # Automated setup with script
npm run docker:up       # Start services
npm run docker:down     # Stop services
npm run docker:logs     # View logs
npm run docker:clean    # Stop and remove volumes
npm run docker:prod     # Start in production mode
```

### Direct Docker Commands
```bash
# Start services
docker compose up --build -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Remove everything including data
docker compose down -v
```

## 🧪 Testing the Connection

### Test MongoDB Connection
```bash
node test-mongodb-connection.js
```

### Test Application Endpoints
```bash
# Health check
curl http://localhost:3000/health

# Get inventory items
curl http://localhost:3000/api/inventory

# Create new item
curl -X POST http://localhost:3000/api/inventory \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Item",
    "description": "Test description", 
    "quantity": 10,
    "price": 29.99,
    "category": "Electronics"
  }'
```

## 🔍 Accessing Services

### Application
- **URL**: http://localhost:3000
- **Health Check**: http://localhost:3000/health
- **API**: http://localhost:3000/api/inventory

### MongoDB
- **Host**: localhost
- **Port**: 27017
- **Connection**: `mongodb://admin:password123@localhost:27017/inventory?authSource=admin`

### MongoDB Shell Access
```bash
# Connect to MongoDB shell
docker exec -it inventory-mongodb mongosh -u admin -p password123 --authenticationDatabase admin

# Use inventory database
use inventory

# View collections
show collections

# View all items
db.inventoryitems.find().pretty()
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Check what's using port 3000 or 27017
netstat -an | grep :3000
netstat -an | grep :27017

# Stop conflicting services
docker compose down
```

#### 2. MongoDB Connection Failed
```bash
# Check if MongoDB container is running
docker ps | grep mongodb

# View MongoDB logs
docker logs inventory-mongodb

# Restart MongoDB
docker compose restart mongodb
```

#### 3. Application Won't Start
```bash
# Check application logs
docker logs inventory-app

# Rebuild application
docker compose up --build app
```

#### 4. Permission Denied (Linux/Mac)
```bash
# Make scripts executable
chmod +x scripts/docker-setup.sh
chmod +x scripts/local-dev.sh
```

### Health Checks

#### Check Container Status
```bash
# View all containers
docker ps

# Check specific container health
docker inspect inventory-mongodb | grep Health
docker inspect inventory-app | grep Health
```

#### Test Database Connection
```bash
# Quick MongoDB ping
docker exec inventory-mongodb mongosh --eval "db.adminCommand('ping')" --quiet

# Test from application container
docker exec inventory-app node test-mongodb-connection.js
```

## 🔒 Security Notes

### Development vs Production

**Development (docker-compose.yml):**
- Uses default passwords
- Exposes MongoDB port 27017
- Includes development tools

**Production (docker-compose.prod.yml):**
- Uses environment variables for credentials
- Restricted network access
- Optimized for performance

### Changing Passwords
1. Update `docker-compose.yml`:
   ```yaml
   MONGO_INITDB_ROOT_PASSWORD: your-secure-password
   ```

2. Update `.env`:
   ```bash
   MONGODB_URI=mongodb://admin:your-secure-password@mongodb:27017/inventory?authSource=admin
   ```

3. Restart services:
   ```bash
   docker compose down -v
   docker compose up -d
   ```

## 📈 Performance Tips

### Development
- Use volume mounts for live code reloading
- Enable MongoDB logging for debugging
- Use development MongoDB settings

### Production
- Use production MongoDB configuration
- Implement connection pooling
- Enable MongoDB authentication
- Use Docker secrets for credentials

## 🔄 Data Management

### Backup Database
```bash
# Create backup
docker exec inventory-mongodb mongodump --username admin --password password123 --authenticationDatabase admin --db inventory --out /backup

# Copy backup from container
docker cp inventory-mongodb:/backup ./backup
```

### Restore Database
```bash
# Copy backup to container
docker cp ./backup inventory-mongodb:/backup

# Restore database
docker exec inventory-mongodb mongorestore --username admin --password password123 --authenticationDatabase admin --db inventory /backup/inventory
```

### Reset Database
```bash
# Remove all data and start fresh
docker compose down -v
docker compose up -d
```

## 🎯 Next Steps

1. **Test the setup**: Run `npm run docker:setup`
2. **Access the app**: Open http://localhost:3000
3. **Try CRUD operations**: Create, read, update, delete items
4. **Check the database**: Use MongoDB shell to verify data
5. **Deploy to production**: Use `docker-compose.prod.yml`

## 📚 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [MongoDB Docker Hub](https://hub.docker.com/_/mongo)
- [Mongoose Documentation](https://mongoosejs.com/docs/)
- [Node.js Docker Best Practices](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)

---

**🎉 Your inventory management system is now ready to run with Docker and MongoDB!**