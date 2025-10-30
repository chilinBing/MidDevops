# Check Prerequisites for Azure Kubernetes Deployment

Write-Host "🔍 CHECKING PREREQUISITES FOR AZURE DEPLOYMENT" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

$allGood = $true

# Check 1: Azure CLI
Write-Host "`n1️⃣ Checking Azure CLI..." -ForegroundColor Yellow
try {
    $azVersion = az --version 2>$null | Select-String "azure-cli" | Select-Object -First 1
    if ($azVersion) {
        Write-Host "✅ Azure CLI: $($azVersion.ToString().Trim())" -ForegroundColor Green
    } else {
        throw "Not found"
    }
} catch {
    Write-Host "❌ Azure CLI: NOT INSTALLED" -ForegroundColor Red
    Write-Host "💡 Install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    $allGood = $false
}

# Check 2: kubectl
Write-Host "`n2️⃣ Checking kubectl..." -ForegroundColor Yellow
try {
    $kubectlVersion = kubectl version --client --short 2>$null
    if ($kubectlVersion) {
        Write-Host "✅ kubectl: $kubectlVersion" -ForegroundColor Green
    } else {
        throw "Not found"
    }
} catch {
    Write-Host "❌ kubectl: NOT INSTALLED" -ForegroundColor Red
    Write-Host "💡 Install from: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Yellow
    $allGood = $false
}

# Check 3: Docker
Write-Host "`n3️⃣ Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
    } else {
        throw "Not found"
    }
} catch {
    Write-Host "❌ Docker: NOT INSTALLED" -ForegroundColor Red
    Write-Host "💡 Install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    $allGood = $false
}

# Check 4: PowerShell Version
Write-Host "`n4️⃣ Checking PowerShell..." -ForegroundColor Yellow
$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 5) {
    Write-Host "✅ PowerShell: $($psVersion.ToString())" -ForegroundColor Green
} else {
    Write-Host "⚠️ PowerShell: $($psVersion.ToString()) (recommend 5.1 or higher)" -ForegroundColor Yellow
}

# Check 5: Internet Connectivity
Write-Host "`n5️⃣ Checking Internet Connectivity..." -ForegroundColor Yellow
try {
    $response = Test-NetConnection -ComputerName "azure.microsoft.com" -Port 443 -InformationLevel Quiet -ErrorAction Stop
    if ($response) {
        Write-Host "✅ Internet: Connected to Azure" -ForegroundColor Green
    } else {
        throw "Connection failed"
    }
} catch {
    Write-Host "❌ Internet: Cannot reach Azure services" -ForegroundColor Red
    Write-Host "💡 Check your internet connection and firewall settings" -ForegroundColor Yellow
    $allGood = $false
}

# Check 6: Docker Hub Image
Write-Host "`n6️⃣ Checking Docker Hub Image..." -ForegroundColor Yellow
try {
    # Try to inspect the image (this will work if image exists locally or can be pulled)
    $imageInfo = docker image inspect faizanazam/inventory-management:latest 2>$null
    if ($imageInfo) {
        Write-Host "✅ Docker Image: faizanazam/inventory-management:latest (available locally)" -ForegroundColor Green
    } else {
        # Try to pull the image to verify it exists on Docker Hub
        Write-Host "🔄 Checking Docker Hub..." -ForegroundColor Gray
        docker pull faizanazam/inventory-management:latest 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker Image: faizanazam/inventory-management:latest (pulled from Docker Hub)" -ForegroundColor Green
        } else {
            throw "Image not accessible"
        }
    }
} catch {
    Write-Host "❌ Docker Image: Cannot access faizanazam/inventory-management:latest" -ForegroundColor Red
    Write-Host "💡 Make sure the image is pushed to Docker Hub and is public" -ForegroundColor Yellow
    $allGood = $false
}

# Check 7: Kubernetes Files
Write-Host "`n7️⃣ Checking Kubernetes Files..." -ForegroundColor Yellow
$k8sFiles = @(
    "k8s/namespace.yaml",
    "k8s/mongodb-deployment.yaml", 
    "k8s/app-deployment.yaml"
)

$missingFiles = @()
foreach ($file in $k8sFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file (missing)" -ForegroundColor Red
        $missingFiles += $file
        $allGood = $false
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "💡 Missing Kubernetes files. Make sure you're in the project root directory." -ForegroundColor Yellow
}

# Check 8: Azure Subscription (if logged in)
Write-Host "`n8️⃣ Checking Azure Authentication..." -ForegroundColor Yellow
try {
    $subscription = az account show --query "name" -o tsv 2>$null
    if ($subscription) {
        Write-Host "✅ Azure: Logged in to '$subscription'" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Azure: Not logged in (will prompt during deployment)" -ForegroundColor Yellow
        Write-Host "💡 You can login now with: az login" -ForegroundColor Cyan
    }
} catch {
    Write-Host "⚠️ Azure: Not logged in (will prompt during deployment)" -ForegroundColor Yellow
}

# Final Summary
Write-Host "`n📊 PREREQUISITE CHECK SUMMARY" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

if ($allGood) {
    Write-Host "🎉 ALL PREREQUISITES MET!" -ForegroundColor Green
    Write-Host "✅ You're ready to deploy to Azure Kubernetes Service" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Run: .\complete-azure-deployment.ps1 (full deployment)" -ForegroundColor White
    Write-Host "   OR" -ForegroundColor Gray
    Write-Host "2. Run individual scripts:" -ForegroundColor White
    Write-Host "   • .\create-aks-cluster.ps1" -ForegroundColor White
    Write-Host "   • .\deploy-app-to-aks.ps1" -ForegroundColor White
    Write-Host "   • .\expose-app-public.ps1" -ForegroundColor White
} else {
    Write-Host "⚠️ SOME PREREQUISITES ARE MISSING" -ForegroundColor Red
    Write-Host "Please install the missing tools before proceeding with deployment." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Installation Links:" -ForegroundColor Cyan
    Write-Host "• Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor White
    Write-Host "• kubectl: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor White
    Write-Host "• Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor White
}

Write-Host "`n💰 Cost Estimate:" -ForegroundColor Yellow
Write-Host "• AKS Cluster (2 nodes): ~$60/month" -ForegroundColor White
Write-Host "• LoadBalancer: ~$20/month" -ForegroundColor White
Write-Host "• Storage: ~$5/month" -ForegroundColor White
Write-Host "• Total: ~$85/month" -ForegroundColor White
Write-Host "💡 Use Azure Free Account ($200 credit) for testing" -ForegroundColor Cyan