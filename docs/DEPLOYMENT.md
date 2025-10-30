# Deployment Guide

This guide covers the complete deployment pipeline for the Inventory Management System from local development to Azure Kubernetes Service (AKS).

## 🏗️ Architecture Overview

```
Local Development → Docker Container → Docker Hub → Azure AKS → Production
```

## 📋 Prerequisites

### Required Tools
- **Node.js** (v18 or higher)
- **Docker** (v20 or higher)
- **kubectl** (Kubernetes CLI)
- **Azure CLI** (v2.40 or higher)
- **Git** (for version control)

### Required Accounts
- **GitHub** account for version control
- **Docker Hub** account for container registry
- **Azure** account for cloud deployment

## 🚀 Deployment Stages

### Stage 1: Local Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd inventory-management-system
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Setup local MongoDB**
   ```bash
   # Using Docker
   docker run -d --name mongodb-local -p 27017:27017 mongo:7.0
   ```

4. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your local settings
   ```

5. **Start development server**
   ```bash
   npm run dev
   ```

6. **Access application**
   - Open http://localhost:3000
   - Test CRUD operations

### Stage 2: Containerization

1. **Build Docker image**
   ```bash
   docker build -t inventory-management .
   ```

2. **Test container locally**
   ```bash
   # Start MongoDB
   docker run -d --name mongodb-test -p 27017:27017 mongo:7.0
   
   # Run application container
   docker run -d -p 3000:3000 --link mongodb-test:mongodb inventory-management
   ```

3. **Verify container health**
   ```bash
   curl http://localhost:3000/health
   ```

### Stage 3: Docker Hub Publishing

1. **Login to Docker Hub**
   ```bash
   docker login
   ```

2. **Tag and push image**
   ```bash
   docker tag inventory-management your-username/inventory-management:latest
   docker push your-username/inventory-management:latest
   ```

### Stage 4: Azure AKS Deployment

1. **Login to Azure**
   ```bash
   az login
   ```

2. **Create resource group**
   ```bash
   az group create --name inventory-rg --location eastus
   ```

3. **Create AKS cluster**
   ```bash
   az aks create \
     --resource-group inventory-rg \
     --name inventory-aks \
     --node-count 2 \
     --node-vm-size Standard_B2s \
     --enable-addons monitoring \
     --generate-ssh-keys
   ```

4. **Get AKS credentials**
   ```bash
   az aks get-credentials --resource-group inventory-rg --name inventory-aks
   ```

5. **Update deployment configuration**
   ```bash
   # Edit k8s/app-deployment.yaml
   # Replace 'your-dockerhub-username' with your actual username
   ```

6. **Deploy to Kubernetes**
   ```bash
   kubectl apply -f k8s/
   ```

7. **Monitor deployment**
   ```bash
   kubectl get pods -n inventory-system --watch
   kubectl rollout status deployment/inventory-app -n inventory-system
   ```

8. **Get service URL**
   ```bash
   kubectl get service inventory-app-service -n inventory-system
   ```

### Stage 5: GitHub Integration

1. **Initialize Git repository**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

2. **Create GitHub repository**
   - Create new repository on GitHub
   - Add remote origin

3. **Configure GitHub Secrets**
   - `DOCKERHUB_USERNAME`: Your Docker Hub username
   - `DOCKERHUB_TOKEN`: Your Docker Hub access token
   - `AZURE_CREDENTIALS`: Azure service principal credentials

4. **Push to GitHub**
   ```bash
   git remote add origin <github-repo-url>
   git push -u origin main
   ```

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automatically:

1. **On Pull Request**: Runs tests and builds
2. **On Main Branch Push**:
   - Builds and pushes Docker image
   - Deploys to AKS
   - Updates running services

## 🛠️ Quick Deployment Scripts

### Automated Local Setup
```bash
chmod +x scripts/local-dev.sh
./scripts/local-dev.sh
```

### Automated Cloud Deployment
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

## 📊 Monitoring and Maintenance

### Health Checks
- Application: `http://your-service-ip/health`
- Kubernetes: `kubectl get pods -n inventory-system`

### Scaling
```bash
kubectl scale deployment inventory-app --replicas=5 -n inventory-system
```

### Updates
```bash
# Update image
kubectl set image deployment/inventory-app inventory-app=your-username/inventory-management:new-tag -n inventory-system

# Rollback if needed
kubectl rollout undo deployment/inventory-app -n inventory-system
```

## 🔧 Troubleshooting

### Common Issues

1. **MongoDB Connection Issues**
   - Check service connectivity: `kubectl get svc -n inventory-system`
   - Verify environment variables in deployment

2. **Image Pull Errors**
   - Ensure Docker Hub image is public or credentials are configured
   - Check image tag in deployment file

3. **Pod Startup Issues**
   - Check logs: `kubectl logs -f deployment/inventory-app -n inventory-system`
   - Verify resource limits and requests

### Useful Commands
```bash
# View all resources
kubectl get all -n inventory-system

# Describe pod issues
kubectl describe pod <pod-name> -n inventory-system

# Access pod shell
kubectl exec -it <pod-name> -n inventory-system -- /bin/sh

# Port forward for debugging
kubectl port-forward svc/inventory-app-service 3000:80 -n inventory-system
```

## 🔒 Security Considerations

- Use secrets for sensitive data
- Implement network policies
- Regular security updates
- Monitor access logs
- Use HTTPS in production

## 📈 Performance Optimization

- Configure resource limits
- Implement horizontal pod autoscaling
- Use persistent volumes for database
- Enable monitoring and alerting
- Optimize Docker image size