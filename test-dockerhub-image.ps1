# Test Docker Hub Image Script
Write-Host "🧪 Testing Docker Hub Image: faizanazam/inventory-management:latest" -ForegroundColor Green

# Stop existing containers to avoid conflicts
Write-Host "🛑 Stopping existing containers..." -ForegroundColor Yellow
docker stop inventory-app-container 2>$null
docker rm inventory-app-container 2>$null

# Pull latest image from Docker Hub
Write-Host "📥 Pulling image from Docker Hub..." -ForegroundColor Yellow
docker pull faizanazam/inventory-management:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to pull image from Docker Hub" -ForegroundColor Red
    exit 1
}

# Run container from Docker Hub image
Write-Host "🚀 Running container from Docker Hub image..." -ForegroundColor Yellow
docker run -d --name inventory-app-test --network inventory-network -p 3001:3000 -e MONGODB_URI="mongodb://admin:password123@inventory-mongodb:27017/inventory?authSource=admin" faizanazam/inventory-management:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to run container" -ForegroundColor Red
    exit 1
}

# Wait for container to start
Write-Host "⏳ Waiting for container to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test the application
Write-Host "🧪 Testing application endpoints..." -ForegroundColor Yellow

try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:3001/health" -Method Get -TimeoutSec 10
    Write-Host "✅ Health Check: SUCCESS" -ForegroundColor Green
    Write-Host "   Response: $($healthResponse | ConvertTo-Json -Compress)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Health Check: FAILED" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    $inventoryResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/inventory" -Method Get -TimeoutSec 10
    Write-Host "✅ API Endpoint: SUCCESS" -ForegroundColor Green
    Write-Host "   Items found: $($inventoryResponse.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ API Endpoint: FAILED" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Show container status
Write-Host "`n📊 Container Status:" -ForegroundColor Green
docker ps | Select-String "inventory-app-test"

Write-Host "`n🎉 Docker Hub image test completed!" -ForegroundColor Green
Write-Host "🌐 Test application running at: http://localhost:3001" -ForegroundColor Cyan

Write-Host "`n🧹 To clean up test container:" -ForegroundColor Yellow
Write-Host "docker stop inventory-app-test && docker rm inventory-app-test" -ForegroundColor Cyan