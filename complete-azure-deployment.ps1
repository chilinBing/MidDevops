# Complete Azure Kubernetes Deployment Script
# Executes all three Azure tasks in sequence

param(
    [string]$ResourceGroup = "inventory-rg",
    [string]$ClusterName = "inventory-aks",
    [string]$Location = "eastus",
    [switch]$SkipClusterCreation = $false
)

Write-Host "🚀 COMPLETE AZURE KUBERNETES DEPLOYMENT" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "This script will complete all Azure Kubernetes tasks:" -ForegroundColor Cyan
Write-Host "✅ Task 1: Create AKS Cluster (3 marks)" -ForegroundColor White
Write-Host "✅ Task 2: Deploy App from Docker Hub (4 marks)" -ForegroundColor White
Write-Host "✅ Task 3: Expose App with Public IP (3 marks)" -ForegroundColor White
Write-Host "🎯 Total: 10 marks" -ForegroundColor Yellow
Write-Host ""

# Confirmation prompt
if (-not $SkipClusterCreation) {
    Write-Host "⚠️ IMPORTANT NOTES:" -ForegroundColor Yellow
    Write-Host "• This will create Azure resources that incur costs (~$60/month)" -ForegroundColor Red
    Write-Host "• The process will take 15-20 minutes total" -ForegroundColor Yellow
    Write-Host "• You need an active Azure subscription" -ForegroundColor Yellow
    Write-Host ""
    
    $confirmation = Read-Host "Do you want to proceed? (y/N)"
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-Host "❌ Deployment cancelled by user" -ForegroundColor Red
        exit 0
    }
}

$startTime = Get-Date
$taskResults = @{}

# Task 1: Create AKS Cluster (3 marks)
if (-not $SkipClusterCreation) {
    Write-Host "`n🏗️ EXECUTING TASK 1: CREATE AKS CLUSTER" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    
    try {
        & .\create-aks-cluster.ps1 -ResourceGroup $ResourceGroup -ClusterName $ClusterName -Location $Location
        if ($LASTEXITCODE -eq 0) {
            $taskResults["Task1"] = "✅ SUCCESS (3/3 marks)"
            Write-Host "`n✅ Task 1 completed successfully!" -ForegroundColor Green
        } else {
            throw "AKS cluster creation failed"
        }
    } catch {
        $taskResults["Task1"] = "❌ FAILED (0/3 marks)"
        Write-Host "`n❌ Task 1 failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "🛑 Stopping deployment due to cluster creation failure" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⏭️ Skipping cluster creation (assuming cluster exists)" -ForegroundColor Yellow
    $taskResults["Task1"] = "⏭️ SKIPPED"
}

# Task 2: Deploy App from Docker Hub (4 marks)
Write-Host "`n🚀 EXECUTING TASK 2: DEPLOY APP FROM DOCKER HUB" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

try {
    & .\deploy-app-to-aks.ps1
    if ($LASTEXITCODE -eq 0) {
        $taskResults["Task2"] = "✅ SUCCESS (4/4 marks)"
        Write-Host "`n✅ Task 2 completed successfully!" -ForegroundColor Green
    } else {
        throw "App deployment failed"
    }
} catch {
    $taskResults["Task2"] = "❌ FAILED (0/4 marks)"
    Write-Host "`n❌ Task 2 failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "⚠️ Continuing to Task 3 (may still work if deployment partially succeeded)" -ForegroundColor Yellow
}

# Task 3: Expose App with Public IP (3 marks)
Write-Host "`n🌍 EXECUTING TASK 3: EXPOSE APP WITH PUBLIC IP" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

try {
    & .\expose-app-public.ps1
    if ($LASTEXITCODE -eq 0) {
        $taskResults["Task3"] = "✅ SUCCESS (3/3 marks)"
        Write-Host "`n✅ Task 3 completed successfully!" -ForegroundColor Green
    } else {
        throw "App exposure failed"
    }
} catch {
    $taskResults["Task3"] = "❌ FAILED (0/3 marks)"
    Write-Host "`n❌ Task 3 failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Final Summary
$endTime = Get-Date
$totalDuration = $endTime - $startTime

Write-Host "`n🏆 DEPLOYMENT SUMMARY" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host "Total Duration: $($totalDuration.Minutes) minutes $($totalDuration.Seconds) seconds" -ForegroundColor Cyan
Write-Host ""

$totalMarks = 0
foreach ($task in $taskResults.Keys) {
    $result = $taskResults[$task]
    Write-Host "$task : $result" -ForegroundColor $(if ($result -like "*SUCCESS*") { "Green" } elseif ($result -like "*FAILED*") { "Red" } else { "Yellow" })
    
    if ($result -like "*SUCCESS*") {
        if ($task -eq "Task1") { $totalMarks += 3 }
        elseif ($task -eq "Task2") { $totalMarks += 4 }
        elseif ($task -eq "Task3") { $totalMarks += 3 }
    }
}

Write-Host "`n🎯 TOTAL MARKS EARNED: $totalMarks/10" -ForegroundColor $(if ($totalMarks -eq 10) { "Green" } elseif ($totalMarks -ge 7) { "Yellow" } else { "Red" })

if ($totalMarks -eq 10) {
    Write-Host "🎉 PERFECT SCORE! All tasks completed successfully!" -ForegroundColor Green
} elseif ($totalMarks -ge 7) {
    Write-Host "👍 Good job! Most tasks completed successfully!" -ForegroundColor Yellow
} else {
    Write-Host "⚠️ Some tasks need attention. Check the logs above." -ForegroundColor Red
}

# Display final access information if available
if (Test-Path "public-access-info.json") {
    $publicInfo = Get-Content "public-access-info.json" | ConvertFrom-Json
    Write-Host "`n🌐 YOUR APPLICATION IS LIVE!" -ForegroundColor Green
    Write-Host "=============================" -ForegroundColor Green
    Write-Host "🔗 Public URL: $($publicInfo.BaseURL)" -ForegroundColor Yellow
    Write-Host "🏥 Health Check: $($publicInfo.HealthURL)" -ForegroundColor Yellow
    Write-Host "📡 API Endpoint: $($publicInfo.ApiURL)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📱 Open in your browser: $($publicInfo.BaseURL)" -ForegroundColor Cyan
}

# Cleanup and next steps
Write-Host "`n🧹 CLEANUP COMMANDS (when you're done testing):" -ForegroundColor Yellow
Write-Host "• Delete namespace: kubectl delete namespace inventory-system" -ForegroundColor Gray
Write-Host "• Delete cluster: az aks delete --resource-group $ResourceGroup --name $ClusterName --yes --no-wait" -ForegroundColor Gray
Write-Host "• Delete resource group: az group delete --name $ResourceGroup --yes --no-wait" -ForegroundColor Gray

Write-Host "`n📊 MONITORING COMMANDS:" -ForegroundColor Cyan
Write-Host "• View all resources: kubectl get all -n inventory-system" -ForegroundColor Gray
Write-Host "• View logs: kubectl logs -f deployment/inventory-app -n inventory-system" -ForegroundColor Gray
Write-Host "• Scale application: kubectl scale deployment inventory-app --replicas=5 -n inventory-system" -ForegroundColor Gray

# Save complete deployment summary
$deploymentSummary = @{
    StartTime = $startTime.ToString()
    EndTime = $endTime.ToString()
    Duration = "$($totalDuration.Minutes)m $($totalDuration.Seconds)s"
    TaskResults = $taskResults
    TotalMarks = $totalMarks
    ResourceGroup = $ResourceGroup
    ClusterName = $ClusterName
    Location = $Location
}

$deploymentSummary | ConvertTo-Json | Out-File -FilePath "deployment-summary.json" -Encoding UTF8
Write-Host "`n💾 Complete deployment summary saved to: deployment-summary.json" -ForegroundColor Gray

Write-Host "`n🎊 AZURE KUBERNETES DEPLOYMENT COMPLETED!" -ForegroundColor Green