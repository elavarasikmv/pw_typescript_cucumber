param([string]$Type = "latest")

Write-Host "=== Log Viewer ===" -ForegroundColor Cyan

if (!(Test-Path "./logs")) {
    Write-Host "No logs found" -ForegroundColor Red
    exit
}

if ($Type -eq "list") {
    Write-Host "Log Files:" -ForegroundColor Blue
    Get-ChildItem "./logs/*.log" | ForEach-Object {
        $sizeKB = [math]::Round($_.Length / 1KB, 1)
        Write-Host "$($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))  $($sizeKB) KB  $($_.Name)"
    }
} elseif ($Type -eq "latest") {
    $latest = Get-ChildItem "./logs/*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latest) {
        Write-Host "Latest: $($latest.Name)" -ForegroundColor Green
        Get-Content $latest.FullName -Tail 20
    }
} elseif ($Type -eq "app") {
    Get-ChildItem "./logs/application-*.log" | ForEach-Object {
        Write-Host "--- $($_.Name) ---" -ForegroundColor Yellow
        Get-Content $_.FullName -Tail 15
    }
} else {
    Write-Host "Usage: .\logs.ps1 [latest|list|app]" -ForegroundColor Yellow
}
