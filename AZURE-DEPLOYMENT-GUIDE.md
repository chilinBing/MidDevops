# ☁️ Azure AKS Deployment Guide

## 🎯 Current Status
✅ Application running locally  
✅ Docker image built and tested  
✅ Image pushed to Docker Hub: `faizanazam/inventory-management:latest`  
🔄 **Next: Deploy to Azure Kubernetes Service (AKS)**

## 📋 Prerequisites for Azure Deployment

### Required Tools
- **Azure CLI** - [Install here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- **kubectl** - [Install here](https://kubernetes.io/docs/tasks/tools/)
- **Azure Account** - [Free account](https://azure.microsoft.com/free/)

### Check if Tools are Installed
```bash
# Check Azure CLI
az --version

# Check kubectl
kubectl version --client

# Check Docker (already confirmed working)
docker --version
```

## 🚀 Step-by-Step Azure AKS Deployment

### Step 1: Login to Azure
```bash
az login
```

### Step 2: Create Resource Group
```bash
az group create --name inventory-rg --location eastus
```

### Step 3: Create AKS Cluster
```bash
az aks create \
  --resource-group inventory-rg \
  --name inventory-aks \
  --node-count 2 \
  --node-vm-size Standard_B2s \
  --enable-addons monitoring \
  --generate-ssh-keys
```

### Step 4: Get AKS Credentials
```bash
az aks get-credentials --resource-group inventory-rg --name inventory-aks
```

### Step 5: Deploy to Kubernetes
```bash
# Apply all Kubernetes manifests
kubectl apply -f k8s/

# Check deployment status
kubectl get pods -n inventory-system --watch
```

### Step 6: Get Service URL
```bash
# Get external IP (may take a few minutes)
kubectl get service inventory-app-service -n inventory-system
```

## 📁 Kubernetes Files Ready for Deployment

### 1. Namespace (`k8s/namespace.yaml`)
- Creates isolated environment: `inventory-system`

### 2. MongoDB Deployment (`k8s/mongodb-deployment.yaml`)
- MongoDB 7.0 with persistent storage
- Authentication configured
- Health checks enabled

### 3. Application Deployment (`k8s/app-deployment.yaml`)
- Your Docker image: `faizanazam/inventory-management:latest`
- 3 replicas for high availability
- Environment variables configured
- Health checks (liveness/readiness probes)

### 4. Ingress (`k8s/ingress.yaml`)
- HTTPS/SSL ready
- Domain routing configured

## 🧪 Testing Deployment

### Check Cluster Status
```bash
# View all resources
kubectl get all -n inventory-system

# Check pod logs
kubectl logs -f deployment/inventory-app -n inventory-system

# Check MongoDB logs
kubectl logs -f deployment/mongodb -n inventory-system
```

### Test Application
```bash
# Get external IP
EXTERNAL_IP=$(kubectl get service inventory-app-service -n inventory-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test health endpoint
curl http://$EXTERNAL_IP/health

# Test API
curl http://$EXTERNAL_IP/api/inventory
```

## 💰 Cost Estimation

### Azure AKS Costs (East US)
- **Standard_B2s nodes (2x)**: ~$60/month
- **Load Balancer**: ~$20/month
- **Storage**: ~$5/month
- **Total**: ~$85/month

### Free Tier Options
- **Azure Free Account**: $200 credit for 30 days
- **AKS Control Plane**: Free (you only pay for nodes)

## 🔧 Troubleshooting

### Common Issues

#### 1. Pods Not Starting
```bash
kubectl describe pod <pod-name> -n inventory-system
kubectl logs <pod-name> -n inventory-system
```

#### 2. Service Not Accessible
```bash
kubectl get svc -n inventory-system
kubectl describe svc inventory-app-service -n inventory-system
```

#### 3. MongoDB Connection Issues
```bash
kubectl exec -it deployment/mongodb -n inventory-system -- mongosh -u admin -p password123 --authenticationDatabase admin
```

## 🔄 Alternative: Local Kubernetes Testing

If you want to test Kubernetes locally first:

### Using Docker Desktop Kubernetes
```bash
# Enable Kubernetes in Docker Desktop settings
# Then deploy locally:
kubectl apply -f k8s/
kubectl port-forward svc/inventory-app-service 3000:80 -n inventory-system
```

### Using Minikube
```bash
# Install and start Minikube
minikube start
kubectl apply -f k8s/
minikube service inventory-app-service -n inventory-system
```

## 📊 Deployment Checklist

- [ ] Azure CLI installed and configured
- [ ] kubectl installed
- [ ] Azure account with sufficient credits
- [ ] Resource group created
- [ ] AKS cluster created and configured
- [ ] Kubernetes manifests applied
- [ ] Pods running successfully
- [ ] Services accessible externally
- [ ] Application tested and working

## 🎯 Success Criteria

Your deployment is successful when:
1. ✅ All pods show "Running" status
2. ✅ LoadBalancer service has external IP
3. ✅ Health endpoint returns 200 OK
4. ✅ API endpoints respond correctly
5. ✅ Web interface loads and functions
6. ✅ CRUD operations work end-to-end

## 🔗 Useful Commands Reference

```bash
# Quick status check
kubectl get all -n inventory-system

# Scale application
kubectl scale deployment inventory-app --replicas=5 -n inventory-system

# Update image
kubectl set image deployment/inventory-app inventory-app=faizanazam/inventory-management:v2.0 -n inventory-system

# Rollback deployment
kubectl rollout undo deployment/inventory-app -n inventory-system

# Delete everything
kubectl delete namespace inventory-system
```

## 🎉 Next Steps After AKS Deployment

1. **Domain Setup**: Configure custom domain with DNS
2. **SSL/TLS**: Set up HTTPS with Let's Encrypt
3. **Monitoring**: Add Prometheus/Grafana
4. **CI/CD**: Automate deployments with GitHub Actions
5. **Backup**: Set up automated database backups
6. **Scaling**: Configure horizontal pod autoscaling