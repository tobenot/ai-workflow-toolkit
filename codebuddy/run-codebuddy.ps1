# ============================================================
#  🤖 CodeBuddy 项目启动器 🚀
#  放置位置: <ProjectRoot>\tools\codebuddy\launch.ps1
# ============================================================

# 0. 管理员权限（已禁用 —— codebuddy 运行在用户态，无需提权）
# if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
#     Write-Warning "Requesting Administrator privileges..."
#     Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
#     exit
# }

# 1. 修复 Emoji 和中文乱码问题
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

# --- Banner ---
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║                                                  ║" -ForegroundColor Magenta
Write-Host "  ║   🤖  C o d e B u d d y   L a u n c h e r  🚀  ║" -ForegroundColor Magenta
Write-Host "  ║                                                  ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# 2. 从脚本位置向上退两级，定位到项目根目录
$ProjectDir = (Get-Item $PSScriptRoot).Parent.Parent.FullName

# 3. 设置项目专属配置目录
$env:CODEBUDDY_CONFIG_DIR = Join-Path $ProjectDir ".codebuddy_conf"

# 4. 找到 CodeBuddy（优先原生二进制，其次 PATH 中的全局安装）
$NativePath = Join-Path $env:LOCALAPPDATA "codebuddy\bin\codebuddy.exe"
if (Test-Path $NativePath) {
    $CodeBuddyPath = $NativePath
} else {
    $FromPath = Get-Command "codebuddy" -ErrorAction SilentlyContinue
    if ($FromPath) {
        $CodeBuddyPath = $FromPath.Source
    } else {
        $CodeBuddyPath = $null
    }
}

# ============================================================
#  🔍 自检开始
# ============================================================

$StepTotal = 6
$StepCurrent = 0

Write-Host "  ┌──────────────────────────────────────────────────┐" -ForegroundColor Yellow
Write-Host "  │  🔍  P r e - F l i g h t   C h e c k s          │" -ForegroundColor Yellow
Write-Host "  └──────────────────────────────────────────────────┘" -ForegroundColor Yellow
Write-Host ""

$AllPassed = $true

# ---- 检查 1：项目根目录存在 ----
$StepCurrent++
Write-Host "  [$StepCurrent/$StepTotal] 📂 Project Root" -ForegroundColor White
if (Test-Path $ProjectDir) {
    Write-Host "         ✅ $ProjectDir" -ForegroundColor Green
} else {
    Write-Host "         ❌ NOT FOUND: $ProjectDir" -ForegroundColor Red
    $AllPassed = $false
}

# ---- 检查 2：项目根目录不是系统目录 ----
$StepCurrent++
Write-Host "  [$StepCurrent/$StepTotal] 🛡️  Safety Check" -ForegroundColor White
$Dangerous = @(
    $env:SystemRoot,
    (Join-Path $env:SystemRoot "system32"),
    "$env:SystemDrive\",
    $env:SystemDrive
)
$NormalizedProject = $ProjectDir.TrimEnd('\')
$IsDangerous = $Dangerous | Where-Object { $NormalizedProject -ieq $_.TrimEnd('\') }
if ($IsDangerous) {
    Write-Host "         ❌ Project root points to SYSTEM directory! 🚫" -ForegroundColor Red
    Write-Host "            Resolved: $ProjectDir" -ForegroundColor Red
    Write-Host "            Expected: <ProjectRoot>\tools\codebuddy\" -ForegroundColor Red
    $AllPassed = $false
} else {
    Write-Host "         ✅ Not a system directory — safe to proceed" -ForegroundColor Green
}

# ---- 检查 3：反向验证 tools\codebuddy 子目录存在 ----
$StepCurrent++
Write-Host "  [$StepCurrent/$StepTotal] 📜 Script Location" -ForegroundColor White
$ExpectedScriptDir = Join-Path $ProjectDir "tools\codebuddy"
if (Test-Path $ExpectedScriptDir) {
    Write-Host "         ✅ $PSScriptRoot" -ForegroundColor Green
} else {
    Write-Host "         ⚠️  Expected subfolder missing: $ExpectedScriptDir" -ForegroundColor DarkYellow
    Write-Host "            Script is at: $PSScriptRoot" -ForegroundColor DarkYellow
    Write-Host "            Parent.Parent may not point to the real project root." -ForegroundColor DarkYellow
}

# ---- 检查 4：项目标志文件/目录（仅提示，不阻塞） ----
$StepCurrent++
Write-Host "  [$StepCurrent/$StepTotal] 🏗️  Project Landmarks" -ForegroundColor White
$LandmarkExact = @(
    # 通用
    ".git", ".hg", ".svn",
    # JavaScript / TypeScript
    "package.json", "pnpm-lock.yaml", "yarn.lock", "package-lock.json",
    # Python
    "pyproject.toml", "requirements.txt", "Pipfile", "poetry.lock", "uv.lock", "setup.py",
    # Java / JVM
    "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts",
    # .NET / C#
    "global.json", "Directory.Build.props", "Directory.Build.targets", "nuget.config",
    # C/C++
    "CMakeLists.txt", "Makefile", "meson.build", "BUILD.bazel", "WORKSPACE", "WORKSPACE.bazel",
    # Go / Rust / PHP / Ruby
    "go.mod", "Cargo.toml", "composer.json", "Gemfile",
    # Unity 目录/文件
    "Assets", "ProjectSettings", "Packages", "ProjectSettings/ProjectVersion.txt", "Packages/manifest.json"
)

$LandmarkWildcard = @(
    # .NET / C# / C++
    "*.sln", "*.csproj", "*.vbproj", "*.fsproj", "*.vcxproj",
    # Unreal Engine
    "*.uproject", "*.uplugin",
    # Apple 生态
    "*.xcodeproj", "*.xcworkspace"
)

$FoundLandmark = @()

foreach ($item in $LandmarkExact) {
    if (Test-Path (Join-Path $ProjectDir $item)) {
        $FoundLandmark += $item
    }
}

foreach ($pattern in $LandmarkWildcard) {
    $matched = Get-ChildItem -Path $ProjectDir -Filter $pattern -ErrorAction SilentlyContinue
    if ($matched) {
        $FoundLandmark += $pattern
    }
}

$FoundLandmark = $FoundLandmark | Sort-Object -Unique

if ($FoundLandmark) {
    $LandmarkList = ($FoundLandmark | ForEach-Object { $_ }) -join ", "
    Write-Host "         ✅ Found: $LandmarkList" -ForegroundColor Green
} else {
    Write-Host "         ⚠️  No common project landmarks found (e.g. .git, *.sln, *.uproject, package.json...)" -ForegroundColor DarkYellow
    Write-Host "            This may not be a real project root. Proceeding anyway... 🤷" -ForegroundColor DarkYellow
}

# ---- 检查 5：CodeBuddy 可执行文件 ----
$StepCurrent++
Write-Host "  [$StepCurrent/$StepTotal] 🤖 CodeBuddy Executable" -ForegroundColor White
if ($CodeBuddyPath -and (Test-Path $CodeBuddyPath)) {
    $VersionOutput = & $CodeBuddyPath --version 2>&1
    Write-Host "         ✅ $CodeBuddyPath" -ForegroundColor Green
    Write-Host "            📦 Version: $VersionOutput" -ForegroundColor DarkGray
} elseif ($CodeBuddyPath) {
    Write-Host "         ❌ NOT FOUND: $CodeBuddyPath" -ForegroundColor Red
    $AllPassed = $false
} else {
    Write-Host "         ❌ CodeBuddy not found anywhere! 😱" -ForegroundColor Red
    Write-Host "            Native binary : $NativePath (not found)" -ForegroundColor Red
    Write-Host "            PATH lookup   : not found" -ForegroundColor Red
    Write-Host "" 
    Write-Host "         💡 Install it with:" -ForegroundColor Yellow
    Write-Host "            irm https://www.codebuddy.cn/cli/install.ps1 | iex" -ForegroundColor Yellow
    Write-Host "            or: npm install -g @tencent-ai/codebuddy-code" -ForegroundColor Yellow
    $AllPassed = $false
}

# ---- 检查 6：配置目录（不存在则自动创建） ----
$StepCurrent++
Write-Host "  [$StepCurrent/$StepTotal] ⚙️  Config Directory" -ForegroundColor White
if (Test-Path $env:CODEBUDDY_CONFIG_DIR) {
    Write-Host "         ✅ $env:CODEBUDDY_CONFIG_DIR" -ForegroundColor Green
} else {
    Write-Host "         ⚠️  Not found, creating..." -ForegroundColor DarkYellow
    New-Item -ItemType Directory -Path $env:CODEBUDDY_CONFIG_DIR -Force | Out-Null
    if (Test-Path $env:CODEBUDDY_CONFIG_DIR) {
        Write-Host "         ✅ Created: $env:CODEBUDDY_CONFIG_DIR" -ForegroundColor Green
    } else {
        Write-Host "         ❌ Failed to create config dir! 💥" -ForegroundColor Red
        $AllPassed = $false
    }
}

Write-Host ""
Write-Host "  ┌──────────────────────────────────────────────────┐" -ForegroundColor Yellow
Write-Host "  │  📊  R e s u l t s                               │" -ForegroundColor Yellow
Write-Host "  └──────────────────────────────────────────────────┘" -ForegroundColor Yellow
Write-Host ""

# ============================================================
#  🏁 自检结束
# ============================================================
if (-not $AllPassed) {
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "  ║  ❌  Pre-flight check FAILED!                   ║" -ForegroundColor Red
    Write-Host "  ║  🔧  Fix the errors above before launching.     ║" -ForegroundColor Red
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Pause
    exit 1
}

Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  ✅  All checks passed!  ($StepTotal/$StepTotal)                    ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# --- 启动动画 ---
$frames = @("⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏")
Write-Host ""
Write-Host "  🚀 Igniting CodeBuddy..." -ForegroundColor Cyan -NoNewline
for ($i = 0; $i -lt 10; $i++) {
    Write-Host "`r  $($frames[$i % $frames.Count]) Igniting CodeBuddy..." -ForegroundColor Cyan -NoNewline
    Start-Sleep -Milliseconds 100
}
Write-Host "`r  🚀 Igniting CodeBuddy... GO!    " -ForegroundColor Cyan

Write-Host ""
Write-Host "  ┌──────────────────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "  │  🎯 Project : $($ProjectDir | Split-Path -Leaf)" -ForegroundColor Cyan
Write-Host "  │  📁 Working : $ProjectDir" -ForegroundColor Cyan
Write-Host "  │  ⚙️  Config  : $env:CODEBUDDY_CONFIG_DIR" -ForegroundColor Cyan
Write-Host "  └──────────────────────────────────────────────────┘" -ForegroundColor Cyan
Write-Host ""

# 5. 切到项目根目录并启动
Set-Location $ProjectDir
& $CodeBuddyPath .

# 6. 异常退出时暂停，方便排查
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "  ║  💥 CodeBuddy exited with code $LASTEXITCODE" -ForegroundColor Red
    Write-Host "  ║  🔍 Check the output above for details.         ║" -ForegroundColor Red
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Red
    Pause
} else {
    Write-Host ""
    Write-Host "  👋 CodeBuddy session ended. See you next time! ✨" -ForegroundColor Magenta
    Write-Host ""
}