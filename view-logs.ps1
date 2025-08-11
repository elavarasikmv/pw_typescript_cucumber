# Simple Log Viewer for Playwright Cucumber Framework
param(
    [string]$Type = "latest"
)

$LogDir = "./logs"

Write-Host "=== Playwright Cucumber Log Viewer ===" -ForegroundColor Cyan
Write-Host ""

if (!(Test-Path $LogDir)) {
    Write-Host "❌ No logs directory found" -ForegroundColor Red
    exit
}

switch ($Type.ToLower()) {
    "latest" {
        $latestLog = Get-ChildItem "$LogDir\*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latestLog) {
            Write-Host "📊 Latest Log: $($latestLog.Name)" -ForegroundColor Green
            Write-Host "---" -ForegroundColor Gray
            Get-Content $latestLog.FullName -Tail 30
        }
    }
    "all" {
        Get-ChildItem "$LogDir\*.log" | ForEach-Object {
            Write-Host "📋 $($_.Name)" -ForegroundColor Yellow
            Write-Host "---" -ForegroundColor Gray
            Get-Content $_.FullName -Tail 10
            Write-Host ""
        }
    }
    "app" {
        $appLogs = Get-ChildItem "$LogDir\application-*.log"
        if ($appLogs) {
            Write-Host "📋 Application Logs:" -ForegroundColor Blue
            $appLogs | ForEach-Object {
                Write-Host "--- $($_.Name) ---" -ForegroundColor Gray
                Get-Content $_.FullName -Tail 20
            }
        }
    }
    "test" {
        $testLogs = Get-ChildItem "$LogDir\test-execution-*.log"
        if ($testLogs) {
            Write-Host "🧪 Test Execution Logs:" -ForegroundColor Green
            $testLogs | ForEach-Object {
                Write-Host "--- $($_.Name) ---" -ForegroundColor Gray
                Get-Content $_.FullName
            }
        }
    }
    "list" {
        Write-Host "📂 Available Log Files:" -ForegroundColor Blue
        Get-ChildItem "$LogDir\*.log" | ForEach-Object {
            $sizeKB = [math]::Round($_.Length / 1KB, 1)
            Write-Host "$($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))  $($sizeKB.ToString().PadLeft(6)) KB  $($_.Name)"
        }
    }
    "clean" {
        Write-Host "🧹 Cleaning logs..." -ForegroundColor Yellow
        Get-ChildItem "$LogDir\*.log" | Remove-Item -Force
        Write-Host "✅ Logs cleaned" -ForegroundColor Green
    }
    default {
        Write-Host "❓ Usage: .\view-logs.ps1 [latest|all|app|test|list|clean]" -ForegroundColor Yellow
    }
}
}
