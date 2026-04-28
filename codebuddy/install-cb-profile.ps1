# ============================================================
#  安装/更新 PowerShell Profile 中的 cb 启动函数（项目可迁移）
#  用法:
#    powershell -ExecutionPolicy Bypass -File .\tools\codebuddy\install-cb-profile.ps1
# ============================================================

$ErrorActionPreference = "Stop"

$startMarker = "# >>> CodeBuddy cb launcher >>>"
$endMarker   = "# <<< CodeBuddy cb launcher <<<"

$block = @'
# >>> CodeBuddy cb launcher >>>
function cb {
    param(
        [Parameter(Position = 0)]
        [string]$Target
    )

    function Resolve-RunCodeBuddyPath {
        param([string]$InputTarget)

        if ($InputTarget) {
            $resolved = Resolve-Path -Path $InputTarget -ErrorAction SilentlyContinue
            if ($resolved) {
                $path = $resolved.Path

                if (Test-Path $path -PathType Leaf) {
                    if ([System.IO.Path]::GetFileName($path).ToLowerInvariant() -eq "run-codebuddy.ps1") {
                        return $path
                    }

                    if ([System.IO.Path]::GetExtension($path).ToLowerInvariant() -eq ".ps1") {
                        return $path
                    }
                }

                if (Test-Path $path -PathType Container) {
                    $candidate = Join-Path $path "tools\codebuddy\run-codebuddy.ps1"
                    if (Test-Path $candidate) { return $candidate }
                }
            }
        }

        $dir = (Get-Location).Path
        while ($true) {
            $candidate = Join-Path $dir "tools\codebuddy\run-codebuddy.ps1"
            if (Test-Path $candidate) { return $candidate }

            $parent = [System.IO.Directory]::GetParent($dir)
            if (-not $parent) { break }
            $dir = $parent.FullName
        }

        return $null
    }

    $scriptPath = Resolve-RunCodeBuddyPath -InputTarget $Target
    if (-not $scriptPath) {
        Write-Host "[cb] run-codebuddy.ps1 not found under tools\\codebuddy" -ForegroundColor Red
        Write-Host "[cb] Usage: cb" -ForegroundColor Yellow
        Write-Host "[cb]        cb E:\\YourProject" -ForegroundColor Yellow
        Write-Host "[cb]        cb E:\\YourProject\\tools\\codebuddy\\run-codebuddy.ps1" -ForegroundColor Yellow
        return
    }

    Start-Process powershell.exe -ArgumentList @(
        "-NoExit",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$scriptPath`""
    )
}
# <<< CodeBuddy cb launcher <<<
'@

function Update-ProfileFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProfilePath
    )

    $profileDir = Split-Path -Parent $ProfilePath
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    if (-not (Test-Path $ProfilePath)) {
        New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
    }

    try {
        $existing = Get-Content -Path $ProfilePath -Raw -ErrorAction Stop
    } catch {
        $existing = ""
    }
    if ($null -eq $existing) {
        $existing = ""
    }

    $pattern = [regex]::Escape($startMarker) + "[\\s\\S]*?" + [regex]::Escape($endMarker)


    # 移除旧块（包括可能重复的历史块），再追加一个新块
    $cleaned = [regex]::Replace($existing, $pattern, "")
    if ($cleaned -and -not $cleaned.EndsWith([Environment]::NewLine)) {
        $cleaned += [Environment]::NewLine
    }
    $updated = $cleaned + $block + [Environment]::NewLine

    Set-Content -Path $ProfilePath -Value $updated -Encoding UTF8
    Write-Host "[OK] cb installed/updated in: $ProfilePath" -ForegroundColor Green
}

$profileTargets = @(
    (Join-Path $HOME "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"),
    (Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"),
    $PROFILE
) | Sort-Object -Unique

foreach ($profilePath in $profileTargets) {
    Update-ProfileFile -ProfilePath $profilePath
}

Write-Host "[NEXT] reopen terminal, then run: cb" -ForegroundColor Cyan
Write-Host "[NEXT] for current shell, run: . `$PROFILE" -ForegroundColor Cyan
