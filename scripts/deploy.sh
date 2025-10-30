#!/bin/bash

# Inventory Management System Deployment Script
set -e

echo "🚀 Starting deployment process..."

# Configuration
DOCKER_IMAGE="your-dockerhub-username/inventory-management"
RESOURCE_GROUP="inventory-rg"
AKS_CLUSTER="inventory-aks"
LOCATION="eastus"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed"
        exit 1
    fi
    
    print_status "Prerequisites check passed ✓"
}

# Build and push Docker image
build_and_push() {
    print_status "Building Docker image..."
    docker build -t $DOCKER_IMAGE:latest .
    
    print_status "Pushing to Docker Hub..."
    docker push $DOCKER_IMAGE:latest
    
    print_status "Docker image pushed successfully ✓"
}

# Create Azure resources
create_azure_resources() {
    print_status "Creating Azure resources..."
    
    # Create resource group
    az group create --name $RESOURCE_GROUP --location $LOCATION
    
    # Create AKS cluster
    az aks create \
        --resource-group $RESOURCE_GROUP \
        --name $AKS_CLUSTER \
        --node-count 2 \
        --node-vm-size Standard_B2s \
        --enable-addons monitoring \
        --generate-ssh-keys
    
    # Get AKS credentials
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER
    
    print_status "Azure resources created successfully ✓"
}

# Deploy to Kubernetes
deploy_to_k8s() {
    print_status "Deploying to Kubernetes..."
    
    # Update image in deployment file
    sed -i "s|your-dockerhub-username/inventory-management:latest|$DOCKER_IMAGE:latest|g" k8s/app-deployment.yaml
    
    # Apply Kubernetes manifests
    kubectl apply -f k8s/
    
    # Wait for deployment to be ready
    kubectl rollout status deployment/inventory-app -n inventory-system --timeout=300s
    
    print_status "Kubernetes deployment completed ✓"
}

# Get service information
get_service_info() {
    print_status "Getting service information..."
    
    echo "Waiting for LoadBalancer IP..."
    kubectl get service inventory-app-service -n inventory-system --watch
}

# Main deployment function
main() {
    echo "🏗️  Inventory Management System Deployment"
    echo "=========================================="
    
    check_prerequisites
    
    read -p "Do you want to build and push Docker image? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        build_and_push
    fi
    
    read -p "Do you want to create Azure resources? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_azure_resources
    fi
    
    read -p "Do you want to deploy to Kubernetes? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        deploy_to_k8s
        get_service_info
    fi
    
    print_status "Deployment process completed! 🎉"
}

# Run main function
main "$@"