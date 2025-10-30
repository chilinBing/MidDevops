# 📦 Inventory Management System

A complete cloud-deployed inventory management system with CRUD operations running on Azure Kubernetes Service (AKS).

## 🚀 Live Application
- **Public URL**: http://4.144.249.110
- **Health Check**: http://4.144.249.110/health
- **API Endpoint**: http://4.144.249.110/api/inventory

## 🏗️ Architecture
- **Frontend**: Responsive HTML/CSS/JavaScript
- **Backend**: Node.js/Express REST API
- **Database**: MongoDB with persistent storage
- **Containerization**: Docker
- **Cloud Platform**: Azure Kubernetes Service (AKS)
- **Container Registry**: Docker Hub (`faizanazam/inventory-management:latest`)

## ✨ Features
- ✅ Create inventory items
- ✅ View all inventory items
- ✅ Update item details
- ✅ Delete items
- ✅ Responsive web interface
- ✅ RESTful API
- ✅ Cloud-deployed and scalable

## 🛠️ Local Development
```bash
# Install dependencies
npm install

# Start local development (requires MongoDB)
npm run dev

# Access application
# http://localhost:3002
```

## 🐳 Docker Deployment
```bash
# Build image
docker build -t inventory-app .

# Run with Docker Compose
docker compose up -d

# Access application
# http://localhost:3000
```

## ☁️ Cloud Deployment (Azure AKS)
The application is deployed on Azure Kubernetes Service with:
- 1 AKS cluster in Southeast Asia
- 3 application replicas for high availability
- MongoDB with persistent storage
- LoadBalancer service with public IP

```bash
# Deploy to existing AKS cluster
kubectl apply -f k8s/

# Check deployment status
kubectl get pods -n inventory-system
kubectl get services -n inventory-system
```

## 📁 Project Structure
```
inventory-management-system/
├── 📄 README.md                    # This file
├── 📄 package.json                 # Node.js dependencies
├── 📄 server.js                    # Express.js backend
├── 📄 Dockerfile                   # Container configuration
├── 📄 docker-compose.yml           # Local Docker setup
├── 📄 healthcheck.js               # Container health check
├── 📁 public/                      # Frontend files
│   ├── 📄 index.html               # Web interface
│   ├── 📄 styles.css               # Styling
│   └── 📄 script.js                # Frontend logic
├── 📁 k8s/                         # Kubernetes manifests
│   ├── 📄 namespace.yaml           # K8s namespace
│   ├── 📄 mongodb-deployment.yaml  # MongoDB deployment
│   ├── 📄 app-deployment.yaml      # App deployment
│   └── 📄 ingress.yaml             # Ingress configuration
├── 📁 mongo-init/                  # Database initialization
│   └── 📄 init-db.js               # Sample data script
├── 📁 docs/                        # Documentation
│   ├── 📄 API.md                   # API documentation
│   └── 📄 DEPLOYMENT.md            # Deployment guide
└── 📁 .github/workflows/           # CI/CD pipeline
    └── 📄 ci-cd.yml                # GitHub Actions
```

## 🔧 Management Commands
```bash
# View application status
kubectl get all -n inventory-system

# View application logs
kubectl logs -f deployment/inventory-app -n inventory-system

# Scale application
kubectl scale deployment inventory-app --replicas=5 -n inventory-system

# Access MongoDB shell
kubectl exec -it deployment/mongodb -n inventory-system -- mongosh -u admin -p password123 --authenticationDatabase admin
```

## 📊 API Endpoints
- `GET /health` - Health check
- `GET /api/inventory` - Get all items
- `GET /api/inventory/:id` - Get single item
- `POST /api/inventory` - Create new item
- `PUT /api/inventory/:id` - Update item
- `DELETE /api/inventory/:id` - Delete item

## 🎯 Deployment Pipeline Completed
✅ Local Development & Testing  
✅ Docker Containerization  
✅ Docker Hub Publishing  
✅ Azure Kubernetes Service Deployment  
✅ Public IP Exposure  
✅ CI/CD Pipeline Setup