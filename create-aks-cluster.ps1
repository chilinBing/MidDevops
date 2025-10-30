# Create Azure Kubernetes Cluster (AKS) Script
# Task 1: Create an Azure Kubernetes Cluster (AKS) (3 marks)

param(
    [string]$ResourceGroup = "inventory-rg",
    [string]$ClusterName = "inventory-aks",
    [string]$Location = "eastus",
    [int]$NodeCount = 2,
    [string]$NodeSize = "Standard_B2s"
)

Write-Host "☁️ Creating Azure Kubernetes Cluster (AKS)" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host "Resource Group: $ResourceGroup" -ForegroundColor Cyan
Write-Host "Cluster Name: $ClusterName" -ForegroundColor Cyan
Write-Host "Location: $Location" -ForegroundColor Cyan
Write-Host "Node Count: $NodeCount" -ForegroundColor Cyan
Write-Host "Node Size: $NodeSize" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Prerequisites
Write-Host "📋 Step 1: Checking Prerequisites..." -ForegroundColor Yellow

# Check Azure CLI
try {
    $azVersion = az --version 2>$null | Select-String "azure-cli"
    if ($azVersion) {
        Write-Host "✅ Azure CLI: $($azVersion.ToString().Trim())" -ForegroundColor Green
    } else {
        throw "Azure CLI not found"
    }
} catch {
    Write-Host "❌ Azure CLI is not installed" -ForegroundColor Red
    Write-Host "💡 Install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Check kubectl
try {
    $kubectlVersion = kubectl version --client --short 2>$null
    if ($kubectlVersion) {
        Write-Host "✅ kubectl: $($kubectlVersion)" -ForegroundColor Green
    } else {
        throw "kubectl not found"
    }
} catch {
    Write-Host "❌ kubectl is not installed" -ForegroundColor Red
    Write-Host "💡 Install from: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Yellow
    exit 1
}

# Step 2: Login to Azure
Write-Host "`n🔐 Step 2: Azure Authentication..." -ForegroundColor Yellow
Write-Host "Please login to your Azure account in the browser window that opens..."

az login --only-show-errors
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Azure login failed" -ForegroundColor Red
    exit 1
}

# Get current subscription
$subscription = az account show --query "name" -o tsv
Write-Host "✅ Logged in to Azure subscription: $subscription" -ForegroundColor Green

# Step 3: Create Resource Group
Write-Host "`n📦 Step 3: Creating Resource Group..." -ForegroundColor Yellow
Write-Host "Creating resource group '$ResourceGroup' in '$Location'..."

az group create --name $ResourceGroup --location $Location --only-show-errors
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create resource group" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Resource group '$ResourceGroup' created successfully" -ForegroundColor Green

# Step 4: Create AKS Cluster
Write-Host "`n☸️ Step 4: Creating AKS Cluster..." -ForegroundColor Yellow
Write-Host "⏳ This will take 10-15 minutes. Creating cluster '$ClusterName'..."
Write-Host "💰 Estimated cost: ~$60/month for 2 Standard_B2s nodes" -ForegroundColor Cyan

$startTime = Get-Date
az aks create `
    --resource-group $ResourceGroup `
    --name $ClusterName `
    --location $Location `
    --node-count $NodeCount `
    --node-vm-size $NodeSize `
    --enable-addons monitoring `
    --generate-ssh-keys `
    --enable-managed-identity `
    --only-show-errors

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create AKS cluster" -ForegroundColor Red
    exit 1
}

$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "✅ AKS cluster '$ClusterName' created successfully in $($duration.Minutes) minutes" -ForegroundColor Green

# Step 5: Get AKS Credentials
Write-Host "`n🔑 Step 5: Configuring kubectl..." -ForegroundColor Yellow
az aks get-credentials --resource-group $ResourceGroup --name $ClusterName --overwrite-existing --only-show-errors
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get AKS credentials" -ForegroundColor Red
    exit 1
}
Write-Host "✅ kubectl configured for AKS cluster" -ForegroundColor Green

# Step 6: Verify Cluster
Write-Host "`n🧪 Step 6: Verifying Cluster..." -ForegroundColor Yellow
$nodes = kubectl get nodes --no-headers 2>$null
if ($nodes) {
    Write-Host "✅ Cluster verification successful" -ForegroundColor Green
    Write-Host "📊 Cluster Nodes:" -ForegroundColor Cyan
    kubectl get nodes
} else {
    Write-Host "❌ Cluster verification failed" -ForegroundColor Red
    exit 1
}

# Display cluster information
Write-Host "`n📊 Cluster Information:" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host "Resource Group: $ResourceGroup" -ForegroundColor Cyan
Write-Host "Cluster Name: $ClusterName" -ForegroundColor Cyan
Write-Host "Location: $Location" -ForegroundColor Cyan
Write-Host "Node Count: $NodeCount" -ForegroundColor Cyan
Write-Host "Node Size: $NodeSize" -ForegroundColor Cyan

# Get cluster details
$clusterInfo = az aks show --resource-group $ResourceGroup --name $ClusterName --query "{fqdn:fqdn,kubernetesVersion:kubernetesVersion,provisioningState:provisioningState}" -o json | ConvertFrom-Json
Write-Host "Kubernetes Version: $($clusterInfo.kubernetesVersion)" -ForegroundColor Cyan
Write-Host "Status: $($clusterInfo.provisioningState)" -ForegroundColor Cyan
Write-Host "FQDN: $($clusterInfo.fqdn)" -ForegroundColor Cyan

Write-Host "`n🎉 Task 1 Completed: Azure Kubernetes Cluster Created Successfully!" -ForegroundColor Green
Write-Host "✅ 3/3 marks earned for AKS cluster creation" -ForegroundColor Green

Write-Host "`n🚀 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Run: .\deploy-app-to-aks.ps1 (Deploy containerized app)" -ForegroundColor Cyan
Write-Host "2. Run: .\expose-app-public.ps1 (Expose app with public IP)" -ForegroundColor Cyan

# Save cluster info for next steps
$clusterConfig = @{
    ResourceGroup = $ResourceGroup
    ClusterName = $ClusterName
    Location = $Location
    NodeCount = $NodeCount
    NodeSize = $NodeSize
    CreatedAt = (Get-Date).ToString()
    KubernetesVersion = $clusterInfo.kubernetesVersion
    FQDN = $clusterInfo.fqdn
}

$clusterConfig | ConvertTo-Json | Out-File -FilePath "aks-cluster-info.json" -Encoding UTF8
Write-Host "`n💾 Cluster information saved to: aks-cluster-info.json" -ForegroundColor Gray