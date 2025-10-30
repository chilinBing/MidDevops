# Azure AKS Deployment Script for Inventory Management System
param(
    [string]$ResourceGroup = "inventory-rg",
    [string]$ClusterName = "inventory-aks",
    [string]$Location = "eastus"
)

Write-Host "🚀 Starting Azure AKS Deployment..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Check prerequisites
Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow

# Check Azure CLI
try {
    $azVersion = az --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Azure CLI is installed" -ForegroundColor Green
    } else {
        throw "Azure CLI not found"
    }
} catch {
    Write-Host "❌ Azure CLI is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Check kubectl
try {
    $kubectlVersion = kubectl version --client 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ kubectl is installed" -ForegroundColor Green
    } else {
        throw "kubectl not found"
    }
} catch {
    Write-Host "❌ kubectl is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Yellow
    exit 1
}

# Login to Azure
Write-Host "🔐 Logging into Azure..." -ForegroundColor Yellow
az login
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Azure login failed" -ForegroundColor Red
    exit 1
}

# Create Resource Group
Write-Host "📦 Creating resource group: $ResourceGroup..." -ForegroundColor Yellow
az group create --name $ResourceGroup --location $Location
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create resource group" -ForegroundColor Red
    exit 1
}

# Create AKS Cluster
Write-Host "☸️ Creating AKS cluster: $ClusterName (this may take 10-15 minutes)..." -ForegroundColor Yellow
az aks create `
    --resource-group $ResourceGroup `
    --name $ClusterName `
    --node-count 2 `
    --node-vm-size Standard_B2s `
    --enable-addons monitoring `
    --generate-ssh-keys

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create AKS cluster" -ForegroundColor Red
    exit 1
}

# Get AKS credentials
Write-Host "🔑 Getting AKS credentials..." -ForegroundColor Yellow
az aks get-credentials --resource-group $ResourceGroup --name $ClusterName --overwrite-existing
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get AKS credentials" -ForegroundColor Red
    exit 1
}

# Deploy to Kubernetes
Write-Host "🚀 Deploying to Kubernetes..." -ForegroundColor Yellow
kubectl apply -f k8s/
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to deploy to Kubernetes" -ForegroundColor Red
    exit 1
}

# Wait for deployment
Write-Host "⏳ Waiting for deployment to be ready..." -ForegroundColor Yellow
kubectl rollout status deployment/inventory-app -n inventory-system --timeout=300s
kubectl rollout status deployment/mongodb -n inventory-system --timeout=300s

# Get service information
Write-Host "📊 Getting service information..." -ForegroundColor Yellow
Write-Host "Waiting for LoadBalancer IP (this may take a few minutes)..." -ForegroundColor Yellow

$timeout = 300
$elapsed = 0
$externalIP = ""

while ($elapsed -lt $timeout -and $externalIP -eq "") {
    Start-Sleep -Seconds 10
    $elapsed += 10
    
    $serviceInfo = kubectl get service inventory-app-service -n inventory-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
    if ($serviceInfo -and $serviceInfo -ne "") {
        $externalIP = $serviceInfo
    }
    
    Write-Host "Checking for external IP... ($elapsed/$timeout seconds)" -ForegroundColor Gray
}

# Display results
Write-Host "`n🎉 Deployment completed!" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

kubectl get all -n inventory-system

if ($externalIP -ne "") {
    Write-Host "`n🌐 Application URLs:" -ForegroundColor Green
    Write-Host "Health Check: http://$externalIP/health" -ForegroundColor Cyan
    Write-Host "Application: http://$externalIP" -ForegroundColor Cyan
    Write-Host "API: http://$externalIP/api/inventory" -ForegroundColor Cyan
} else {
    Write-Host "`n⏳ LoadBalancer IP not yet assigned. Check later with:" -ForegroundColor Yellow
    Write-Host "kubectl get service inventory-app-service -n inventory-system" -ForegroundColor Cyan
}

Write-Host "`n📋 Useful commands:" -ForegroundColor Green
Write-Host "View pods: kubectl get pods -n inventory-system" -ForegroundColor Cyan
Write-Host "View logs: kubectl logs -f deployment/inventory-app -n inventory-system" -ForegroundColor Cyan
Write-Host "Scale app: kubectl scale deployment inventory-app --replicas=5 -n inventory-system" -ForegroundColor Cyan

Write-Host "`n✅ Azure AKS deployment completed successfully!" -ForegroundColor Green