# Log Monitor PowerShell Script for Playwright Cucumber Framework
# This script provides log monitoring and management functions for Windows

param(
    [Parameter(Position=0)]
    [ValidateSet("view", "tail", "clean", "size", "list", "backup", "help")]
    [string]$Command = "help",
    
    [Parameter(Position=1)]
    [ValidateSet("all", "app", "application", "error", "test", "latest")]
    [string]$LogType = "all"
)

$LogDir = "./logs"
$ScriptName = Split-Path -Leaf $PSCommandPath

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Magenta = "Magenta"
    Cyan = "Cyan"
    White = "White"
}

function Write-Header {
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "   Log Monitor for Playwright   " -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Usage {
    Write-Host "Usage: $ScriptName [COMMAND] [TYPE]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Blue
    Write-Host "  view [TYPE]     View logs (all|app|error|test|latest)"
    Write-Host "  tail [TYPE]     Monitor logs in real-time"
    Write-Host "  clean           Clean old logs"
    Write-Host "  size            Show log directory size"
    Write-Host "  list            List all log files"
    Write-Host "  backup          Backup current logs"
    Write-Host "  help            Show this help message"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Blue
    Write-Host "  .\log-monitor.ps1 view latest    # View latest log file"
    Write-Host "  .\log-monitor.ps1 tail test      # Monitor test execution logs"
    Write-Host "  .\log-monitor.ps1 clean          # Clean logs older than 7 days"
    Write-Host ""
}

function Test-LogsDirectory {
    if (!(Test-Path $LogDir)) {
        Write-Host "⚠️  Logs directory not found. Creating it..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        Write-Host "✅ Logs directory created." -ForegroundColor Green
        Write-Host ""
    }
}

function Show-Logs {
    param([string]$Type)
    
    switch ($Type) {
        {$_ -in "app", "application"} {
            Write-Host "📋 Application Logs:" -ForegroundColor Blue
            $appLogs = Get-ChildItem "$LogDir\application-*.log" -ErrorAction SilentlyContinue
            if ($appLogs) {
                foreach ($log in $appLogs) {
                    Write-Host "=== $($log.Name) ===" -ForegroundColor Magenta
                    Get-Content $log.FullName -Tail 50
                }
            } else {
                Write-Host "No application logs found"
            }
        }
        "error" {
            Write-Host "❌ Error Logs:" -ForegroundColor Red
            $errorLogs = Get-ChildItem "$LogDir\error-*.log" -ErrorAction SilentlyContinue
            if ($errorLogs) {
                foreach ($log in $errorLogs) {
                    Write-Host "=== $($log.Name) ===" -ForegroundColor Magenta
                    Get-Content $log.FullName
                }
            } else {
                Write-Host "No error logs found"
            }
        }
        "test" {
            Write-Host "🧪 Test Execution Logs:" -ForegroundColor Green
            $testLogs = Get-ChildItem "$LogDir\test-execution-*.log" -ErrorAction SilentlyContinue
            if ($testLogs) {
                foreach ($log in $testLogs) {
                    Write-Host "=== $($log.Name) ===" -ForegroundColor Magenta
                    Get-Content $log.FullName -Tail 50
                }
            } else {
                Write-Host "No test execution logs found"
            }
        }
        "latest" {
            Write-Host "📊 Latest Log File:" -ForegroundColor Cyan
            $latestLog = Get-ChildItem "$LogDir\*.log" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($latestLog) {
                Write-Host "=== $($latestLog.Name) ===" -ForegroundColor Magenta
                Get-Content $latestLog.FullName -Tail 50
            } else {
                Write-Host "No log files found"
            }
        }
        default {
            Write-Host "📋 All Recent Logs:" -ForegroundColor Cyan
            $allLogs = Get-ChildItem "$LogDir\*.log" -ErrorAction SilentlyContinue
            if ($allLogs) {
                foreach ($log in $allLogs) {
                    Write-Host "=== $($log.Name) ===" -ForegroundColor Magenta
                    Get-Content $log.FullName -Tail 20
                }
            } else {
                Write-Host "No logs found"
            }
        }
    }
}

function Start-LogTailing {
    param([string]$Type)
    
    Write-Host "Starting log monitoring (Press Ctrl+C to exit)..." -ForegroundColor Yellow
    Write-Host ""
    
    $logFiles = switch ($Type) {
        {$_ -in "app", "application"} { Get-ChildItem "$LogDir\application-*.log" -ErrorAction SilentlyContinue }
        "error" { Get-ChildItem "$LogDir\error-*.log" -ErrorAction SilentlyContinue }
        "test" { Get-ChildItem "$LogDir\test-execution-*.log" -ErrorAction SilentlyContinue }
        default { Get-ChildItem "$LogDir\*.log" -ErrorAction SilentlyContinue }
    }
    
    if ($logFiles) {
        Write-Host "Monitoring files:" -ForegroundColor Blue
        $logFiles | ForEach-Object { Write-Host "  - $($_.Name)" }
        Write-Host ""
        
        # Simple file monitoring (PowerShell doesn't have built-in tail -f)
        $lastSizes = @{}
        $logFiles | ForEach-Object { $lastSizes[$_.FullName] = $_.Length }
        
        try {
            while ($true) {
                Start-Sleep -Seconds 2
                
                foreach ($logFile in $logFiles) {
                    if (Test-Path $logFile.FullName) {
                        $currentSize = (Get-Item $logFile.FullName).Length
                        $lastSize = $lastSizes[$logFile.FullName]
                        
                        if ($currentSize -gt $lastSize) {
                            $newContent = Get-Content $logFile.FullName -Tail 10
                            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $($logFile.Name):" -ForegroundColor Yellow
                            $newContent | ForEach-Object { Write-Host "  $_" }
                            $lastSizes[$logFile.FullName] = $currentSize
                        }
                    }
                }
            }
        } catch {
            Write-Host "Log monitoring stopped." -ForegroundColor Yellow
        }
    } else {
        Write-Host "No log files found to monitor" -ForegroundColor Yellow
    }
}

function Remove-OldLogs {
    Write-Host "🧹 Cleaning old logs..." -ForegroundColor Yellow
    
    $cutoffDate = (Get-Date).AddDays(-7)
    $oldLogs = Get-ChildItem "$LogDir\*.log" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoffDate }
    
    if ($oldLogs) {
        $oldLogs | Remove-Item -Force
        Write-Host "✅ Removed $($oldLogs.Count) old log files." -ForegroundColor Green
    } else {
        Write-Host "No old logs to clean." -ForegroundColor Green
    }
    
    # Remove empty log files
    $emptyLogs = Get-ChildItem "$LogDir\*.log" -ErrorAction SilentlyContinue | Where-Object { $_.Length -eq 0 }
    if ($emptyLogs) {
        $emptyLogs | Remove-Item -Force
        Write-Host "✅ Removed $($emptyLogs.Count) empty log files." -ForegroundColor Green
    }
    
    Show-LogSize
}

function Show-LogSize {
    Write-Host "📊 Log Directory Information:" -ForegroundColor Blue
    
    if (Test-Path $LogDir) {
        $logFiles = Get-ChildItem "$LogDir\*.log" -ErrorAction SilentlyContinue
        
        if ($logFiles) {
            $totalSize = ($logFiles | Measure-Object -Property Length -Sum).Sum
            $totalSizeMB = [math]::Round($totalSize / 1MB, 2)
            
            Write-Host "Total Size: $totalSizeMB MB" -ForegroundColor Cyan
            Write-Host "Log Files: $($logFiles.Count)" -ForegroundColor Cyan
            
            Write-Host ""
            Write-Host "File Breakdown:" -ForegroundColor Magenta
            $logFiles | Group-Object { $_.Name -replace '-\d{4}-\d{2}-\d{2}', '' } | ForEach-Object {
                Write-Host "  $($_.Count)x $($_.Name)"
            }
        } else {
            Write-Host "No log files found"
        }
    } else {
        Write-Host "Logs directory doesn't exist"
    }
    Write-Host ""
}

function Show-LogList {
    Write-Host "📂 Log Files:" -ForegroundColor Blue
    
    if (Test-Path $LogDir) {
        $logFiles = Get-ChildItem "$LogDir\*.log" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 20
        
        if ($logFiles) {
            $logFiles | ForEach-Object {
                $sizeKB = [math]::Round($_.Length / 1KB, 1)
                Write-Host "$($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))  $($sizeKB.ToString().PadLeft(8)) KB  $($_.Name)"
            }
            
            $totalFiles = (Get-ChildItem "$LogDir\*.log" -ErrorAction SilentlyContinue).Count
            if ($totalFiles -gt 20) {
                Write-Host ""
                Write-Host "... and $($totalFiles - 20) more files" -ForegroundColor Yellow
            }
        } else {
            Write-Host "No log files found"
        }
    } else {
        Write-Host "No logs directory found"
    }
    Write-Host ""
}

function Backup-Logs {
    $backupDir = "./logs-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    Write-Host "💾 Creating log backup..." -ForegroundColor Yellow
    
    if (Test-Path $LogDir) {
        Copy-Item -Path $LogDir -Destination $backupDir -Recurse -Force
        Write-Host "✅ Logs backed up to: $backupDir" -ForegroundColor Green
        
        $backupSize = (Get-ChildItem $backupDir -Recurse | Measure-Object -Property Length -Sum).Sum
        $backupSizeMB = [math]::Round($backupSize / 1MB, 2)
        Write-Host "Backup Size: $backupSizeMB MB" -ForegroundColor Cyan
    } else {
        Write-Host "❌ No logs directory found to backup" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}
}

# Main script logic
Write-Header
Test-LogsDirectory

switch ($Command) {
    "view" { Show-Logs -Type $LogType }
    "tail" { Start-LogTailing -Type $LogType }
    "clean" { Remove-OldLogs }
    "size" { Show-LogSize }
    "list" { Show-LogList }
    "backup" { Backup-Logs }
    default { Write-Usage }
}
