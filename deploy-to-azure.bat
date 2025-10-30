@echo off
echo ========================================
echo Azure Kubernetes Deployment
echo ========================================

echo.
echo Step 1: Checking Azure CLI...
az --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Azure CLI not installed
    echo Please install from: https://aka.ms/installazurecliwindows
    pause
    exit /b 1
)
echo Azure CLI is installed

echo.
echo Step 2: Logging into Azure...
az login
if %errorlevel% neq 0 (
    echo ERROR: Azure login failed
    pause
    exit /b 1
)

echo.
echo Step 3: Creating Resource Group...
az group create --name inventory-rg --location eastus
if %errorlevel% neq 0 (
    echo ERROR: Failed to create resource group
    pause
    exit /b 1
)

echo.
echo Step 4: Creating AKS Cluster (this will take 10-15 minutes)...
az aks create --resource-group inventory-rg --name inventory-aks --node-count 2 --node-vm-size Standard_B2s --enable-addons monitoring --generate-ssh-keys
if %errorlevel% neq 0 (
    echo ERROR: Failed to create AKS cluster
    pause
    exit /b 1
)

echo.
echo Step 5: Getting AKS credentials...
az aks get-credentials --resource-group inventory-rg --name inventory-aks
if %errorlevel% neq 0 (
    echo ERROR: Failed to get AKS credentials
    pause
    exit /b 1
)

echo.
echo Step 6: Verifying cluster...
kubectl get nodes
if %errorlevel% neq 0 (
    echo ERROR: Cannot connect to cluster
    pause
    exit /b 1
)

echo.
echo Step 7: Creating namespace...
kubectl create namespace inventory-system

echo.
echo Step 8: Deploying MongoDB...
kubectl apply -f k8s/mongodb-deployment.yaml
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy MongoDB
    pause
    exit /b 1
)

echo.
echo Step 9: Deploying Application...
kubectl apply -f k8s/app-deployment.yaml
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy application
    pause
    exit /b 1
)

echo.
echo Step 10: Waiting for deployments...
kubectl rollout status deployment/mongodb -n inventory-system --timeout=300s
kubectl rollout status deployment/inventory-app -n inventory-system --timeout=300s

echo.
echo Step 11: Getting service information...
kubectl get services -n inventory-system

echo.
echo ========================================
echo Deployment completed!
echo ========================================
echo.
echo Your application is being deployed.
echo Run the following command to get the external IP:
echo kubectl get service inventory-app-service -n inventory-system
echo.
echo Once you have the external IP, test your application:
echo http://EXTERNAL_IP/health
echo http://EXTERNAL_IP/api/inventory
echo.
pause