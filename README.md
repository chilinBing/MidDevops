# Inventory Management System - Cloud Deployment Pipeline

A complete inventory management system with CRUD operations deployed through a comprehensive CI/CD pipeline.

## Architecture
- **Frontend**: HTML/CSS/JavaScript
- **Backend**: Node.js/Express
- **Database**: MongoDB
- **Containerization**: Docker
- **Cloud Platform**: Azure Kubernetes Service (AKS)
- **Version Control**: GitHub
- **Registry**: Docker Hub

## Pipeline Stages
1. Local Development & Testing
2. Containerization with Docker
3. Image Publishing to Docker Hub
4. Cloud Deployment on Azure AKS
5. Version Control with GitHub

## Quick Start
```bash
# Install dependencies
npm install

# Start local development
npm run dev

# Build Docker image
docker build -t inventory-app .

# Deploy to AKS
kubectl apply -f k8s/
```

## Operations
- Create inventory items
- Read/View inventory
- Update item details
- Delete items