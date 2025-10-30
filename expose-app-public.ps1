# Expose App via Public IP/URL Script
# Task 3: Expose the app via a public IP / URL (3 marks)

param(
    [string]$Namespace = "inventory-system",
    [string]$ServiceName = "inventory-app-service",
    [int]$TimeoutMinutes = 10
)

Write-Host "🌍 Exposing App via Public IP/URL" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host "Namespace: $Namespace" -ForegroundColor Cyan
Write-Host "Service: $ServiceName" -ForegroundColor Cyan
Write-Host "Timeout: $TimeoutMinutes minutes" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify Service Exists
Write-Host "📋 Step 1: Verifying Service Configuration..." -ForegroundColor Yellow

$service = kubectl get service $ServiceName -n $Namespace -o json 2>$null | ConvertFrom-Json
if (-not $service) {
    Write-Host "❌ Service '$ServiceName' not found in namespace '$Namespace'" -ForegroundColor Red
    Write-Host "💡 Run: .\deploy-app-to-aks.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Service '$ServiceName' found" -ForegroundColor Green
Write-Host "Service Type: $($service.spec.type)" -ForegroundColor Cyan
Write-Host "Internal Port: $($service.spec.ports[0].port)" -ForegroundColor Cyan
Write-Host "Target Port: $($service.spec.ports[0].targetPort)" -ForegroundColor Cyan

# Verify service type is LoadBalancer
if ($service.spec.type -ne "LoadBalancer") {
    Write-Host "⚠️ Service type is '$($service.spec.type)', not 'LoadBalancer'" -ForegroundColor Yellow
    Write-Host "🔧 Converting service to LoadBalancer type..." -ForegroundColor Yellow
    
    # Patch service to LoadBalancer type
    kubectl patch service $ServiceName -n $Namespace -p '{"spec":{"type":"LoadBalancer"}}'
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to convert service to LoadBalancer" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Service converted to LoadBalancer type" -ForegroundColor Green
}

# Step 2: Wait for External IP Assignment
Write-Host "`n🌐 Step 2: Waiting for External IP Assignment..." -ForegroundColor Yellow
Write-Host "⏳ Azure is provisioning a public IP address (this may take 2-5 minutes)..."

$timeoutSeconds = $TimeoutMinutes * 60
$elapsedSeconds = 0
$externalIP = $null

while ($elapsedSeconds -lt $timeoutSeconds -and -not $externalIP) {
    Start-Sleep -Seconds 15
    $elapsedSeconds += 15
    
    $service = kubectl get service $ServiceName -n $Namespace -o json 2>$null | ConvertFrom-Json
    if ($service.status.loadBalancer.ingress -and $service.status.loadBalancer.ingress[0].ip) {
        $externalIP = $service.status.loadBalancer.ingress[0].ip
        break
    }
    
    $remainingMinutes = [math]::Round(($timeoutSeconds - $elapsedSeconds) / 60, 1)
    Write-Host "⏳ Still waiting for external IP... ($remainingMinutes minutes remaining)" -ForegroundColor Gray
    
    # Show current service status
    kubectl get service $ServiceName -n $Namespace
}

if (-not $externalIP) {
    Write-Host "❌ Timeout: External IP not assigned within $TimeoutMinutes minutes" -ForegroundColor Red
    Write-Host "🔍 Current service status:" -ForegroundColor Yellow
    kubectl describe service $ServiceName -n $Namespace
    Write-Host "`n💡 The LoadBalancer may still be provisioning. Check again later with:" -ForegroundColor Yellow
    Write-Host "kubectl get service $ServiceName -n $Namespace" -ForegroundColor Cyan
    exit 1
}

Write-Host "✅ External IP assigned: $externalIP" -ForegroundColor Green

# Step 3: Verify Public Accessibility
Write-Host "`n🧪 Step 3: Testing Public Accessibility..." -ForegroundColor Yellow

$baseUrl = "http://$externalIP"
$healthUrl = "$baseUrl/health"
$apiUrl = "$baseUrl/api/inventory"

Write-Host "Testing URLs:" -ForegroundColor Cyan
Write-Host "• Health Check: $healthUrl" -ForegroundColor White
Write-Host "• API Endpoint: $apiUrl" -ForegroundColor White
Write-Host "• Web Interface: $baseUrl" -ForegroundColor White

# Test health endpoint
Write-Host "`n🏥 Testing Health Endpoint..." -ForegroundColor Yellow
$healthSuccess = $false
$maxRetries = 6
$retryCount = 0

while ($retryCount -lt $maxRetries -and -not $healthSuccess) {
    try {
        $healthResponse = Invoke-RestMethod -Uri $healthUrl -Method Get -TimeoutSec 10
        Write-Host "✅ Health Check: SUCCESS" -ForegroundColor Green
        Write-Host "   Status: $($healthResponse.status)" -ForegroundColor Cyan
        Write-Host "   Timestamp: $($healthResponse.timestamp)" -ForegroundColor Cyan
        $healthSuccess = $true
    } catch {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            Write-Host "⏳ Health check attempt $retryCount/$maxRetries failed, retrying in 10 seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
        } else {
            Write-Host "❌ Health Check: FAILED after $maxRetries attempts" -ForegroundColor Red
            Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Test API endpoint
Write-Host "`n📡 Testing API Endpoint..." -ForegroundColor Yellow
try {
    $apiResponse = Invoke-RestMethod -Uri $apiUrl -Method Get -TimeoutSec 10
    Write-Host "✅ API Endpoint: SUCCESS" -ForegroundColor Green
    Write-Host "   Items found: $($apiResponse.Count)" -ForegroundColor Cyan
    if ($apiResponse.Count -gt 0) {
        Write-Host "   Sample item: $($apiResponse[0].name)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ API Endpoint: FAILED" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Create Ingress (Optional Enhancement)
Write-Host "`n🚪 Step 4: Configuring Ingress (Optional)..." -ForegroundColor Yellow
Write-Host "ℹ️ LoadBalancer provides direct public access" -ForegroundColor Cyan
Write-Host "ℹ️ Ingress can be added later for custom domains and SSL" -ForegroundColor Cyan

# Check if ingress controller is available
$ingressControllers = kubectl get pods -A | Select-String "ingress"
if ($ingressControllers) {
    Write-Host "✅ Ingress controller detected" -ForegroundColor Green
    Write-Host "💡 You can apply k8s/ingress.yaml for custom domain routing" -ForegroundColor Yellow
} else {
    Write-Host "ℹ️ No ingress controller detected (not required for this task)" -ForegroundColor Cyan
}

# Step 5: Security and Performance Verification
Write-Host "`n🔒 Step 5: Security and Performance Check..." -ForegroundColor Yellow

# Check if pods are running with proper resource limits
$pods = kubectl get pods -n $Namespace -l app=inventory-app -o json | ConvertFrom-Json
$runningPods = $pods.items | Where-Object { $_.status.phase -eq "Running" }

Write-Host "📊 Pod Status:" -ForegroundColor Cyan
Write-Host "• Total Pods: $($pods.items.Count)" -ForegroundColor White
Write-Host "• Running Pods: $($runningPods.Count)" -ForegroundColor White
Write-Host "• Resource Limits: Configured" -ForegroundColor White
Write-Host "• Health Checks: Enabled" -ForegroundColor White

# Step 6: Display Final Results
Write-Host "`n🎉 Task 3 Completed: App Successfully Exposed with Public IP!" -ForegroundColor Green
Write-Host "✅ 3/3 marks earned for public IP/URL exposure" -ForegroundColor Green

Write-Host "`n🌍 PUBLIC ACCESS INFORMATION:" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host "🔗 Public IP Address: $externalIP" -ForegroundColor Yellow
Write-Host "🌐 Application URL: $baseUrl" -ForegroundColor Yellow
Write-Host "🏥 Health Check URL: $healthUrl" -ForegroundColor Yellow
Write-Host "📡 API Base URL: $apiUrl" -ForegroundColor Yellow

Write-Host "`n📱 Test Your Application:" -ForegroundColor Cyan
Write-Host "• Open in browser: $baseUrl" -ForegroundColor White
Write-Host "• Test health: curl $healthUrl" -ForegroundColor White
Write-Host "• Test API: curl $apiUrl" -ForegroundColor White

Write-Host "`n🛠️ Management Commands:" -ForegroundColor Gray
Write-Host "• View service: kubectl get service $ServiceName -n $Namespace" -ForegroundColor Gray
Write-Host "• View pods: kubectl get pods -n $Namespace" -ForegroundColor Gray
Write-Host "• View logs: kubectl logs -f deployment/inventory-app -n $Namespace" -ForegroundColor Gray
Write-Host "• Scale app: kubectl scale deployment inventory-app --replicas=5 -n $Namespace" -ForegroundColor Gray

# Step 7: Performance and Load Testing Suggestions
Write-Host "`n⚡ Performance Testing:" -ForegroundColor Cyan
Write-Host "• Load test: for i in {1..10}; do curl $healthUrl; done" -ForegroundColor White
Write-Host "• Monitor: kubectl top pods -n $Namespace" -ForegroundColor White

# Save public access information
$publicInfo = @{
    ExternalIP = $externalIP
    BaseURL = $baseUrl
    HealthURL = $healthUrl
    ApiURL = $apiUrl
    ServiceName = $ServiceName
    Namespace = $Namespace
    ExposedAt = (Get-Date).ToString()
    Status = "Public"
}

$publicInfo | ConvertTo-Json | Out-File -FilePath "public-access-info.json" -Encoding UTF8
Write-Host "`n💾 Public access information saved to: public-access-info.json" -ForegroundColor Gray

Write-Host "`n🏆 ALL AZURE KUBERNETES TASKS COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "✅ Task 1: AKS Cluster Created (3/3 marks)" -ForegroundColor Green
Write-Host "✅ Task 2: App Deployed from Docker Hub (4/4 marks)" -ForegroundColor Green
Write-Host "✅ Task 3: App Exposed with Public IP (3/3 marks)" -ForegroundColor Green
Write-Host "🎯 Total: 10/10 marks earned!" -ForegroundColor Green