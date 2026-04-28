# notify-done.ps1 - AI 工作交接提醒系统（非阻塞）
# Usage:
#   powershell -ExecutionPolicy Bypass -File notify-done.ps1 ["message"] [-Volume 0-100] [-NoBeep] [-NoPopup]
#
# 设计：
# - 默认模式：立即拉起后台 worker 子进程并立刻退出（不阻塞调用方）
# - worker 模式：真正执行 Beep / 任务栏闪烁 / TTS / 持久浮窗

param(
    [string]$Message = "任务完成！",
    [ValidateRange(0, 100)]
    [int]$Volume = 100,
    [switch]$NoBeep,
    [switch]$NoPopup,
    [switch]$Worker
)

# =============================
# 启动器模式（默认）：非阻塞
# =============================
if (-not $Worker) {
    try {
        $scriptPath = $PSCommandPath
        if ([string]::IsNullOrWhiteSpace($scriptPath)) {
            $scriptPath = $MyInvocation.MyCommand.Path
        }

        if (-not [string]::IsNullOrWhiteSpace($scriptPath) -and (Test-Path $scriptPath)) {
            $escapedMessage = $Message -replace '"', '\"'

            $argList = @(
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-WindowStyle", "Hidden",
                "-File", "`"$scriptPath`"",
                "-Worker",
                "-Message", "`"$escapedMessage`"",
                "-Volume", "$Volume"
            )

            if ($NoBeep) { $argList += "-NoBeep" }
            if ($NoPopup) { $argList += "-NoPopup" }

            Start-Process powershell.exe -ArgumentList $argList -WindowStyle Hidden | Out-Null
            return
        }
    } catch {
        # 启动后台失败则降级为同步执行（继续往下走）
    }
}

# =============================
# worker 模式：执行提醒逻辑
# =============================

# --- Step 1: Professional notification tone ---
if (-not $NoBeep) {
    try {
        [Console]::Beep(784, 100)
        Start-Sleep -Milliseconds 60
        [Console]::Beep(988, 200)
        Start-Sleep -Milliseconds 150
    } catch {
        # Best-effort
    }
}

# --- Step 2: Flash taskbar window ---
try {
    $flashCode = @"
using System;
using System.Runtime.InteropServices;
public class TaskbarFlash {
    [StructLayout(LayoutKind.Sequential)]
    public struct FLASHWINFO {
        public uint cbSize; public IntPtr hwnd; public uint dwFlags;
        public uint uCount; public uint dwTimeout;
    }
    [DllImport("user32.dll")] public static extern bool FlashWindowEx(ref FLASHWINFO pwfi);
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    public static void Flash() {
        IntPtr hwnd = GetConsoleWindow();
        if (hwnd == IntPtr.Zero) return;
        FLASHWINFO fInfo = new FLASHWINFO();
        fInfo.cbSize = (uint)Marshal.SizeOf(fInfo);
        fInfo.hwnd = hwnd; fInfo.dwFlags = 3 | 12; fInfo.uCount = 5; fInfo.dwTimeout = 0;
        FlashWindowEx(ref fInfo);
    }
}
"@
    Add-Type -TypeDefinition $flashCode -Language CSharp -ErrorAction SilentlyContinue
    [TaskbarFlash]::Flash()
} catch {
    # Best-effort
}

# --- Step 3: 持久浮窗提醒（独立子进程，先于 TTS 启动以同时出现） ---
if (-not $NoPopup) {
    try {
        $popupScript = Join-Path $PSScriptRoot "notify-popup.ps1"
        if (Test-Path $popupScript) {
            $escapedMessage = $Message -replace '"', '\"'
            Start-Process powershell.exe -ArgumentList @(
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-WindowStyle", "Hidden",
                "-File", "`"$popupScript`"",
                "-Message", "`"$escapedMessage`""
            ) -WindowStyle Hidden | Out-Null
        } else {
            Write-Host "[浮窗脚本未找到] $popupScript"
        }
    } catch {
        Write-Host "[浮窗启动失败] $($_.Exception.Message)"
    }
}

# --- Step 4: TTS 双语语音播报（中文用中文语音，英文用英文语音） ---
try {
    Add-Type -AssemblyName System.Speech
    $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $synth.Volume = $Volume
    $synth.Rate = 0

    # 查找可用的中文和英文语音
    $allVoices = $synth.GetInstalledVoices()
    $zhVoice = $allVoices | Where-Object {
        $_.VoiceInfo.Culture.Name -like 'zh-*'
    } | Select-Object -First 1
    $enVoice = $allVoices | Where-Object {
        $_.VoiceInfo.Culture.Name -like 'en-*'
    } | Select-Object -First 1

    $zhVoiceName = if ($zhVoice) { $zhVoice.VoiceInfo.Name } else { $null }
    $enVoiceName = if ($enVoice) { $enVoice.VoiceInfo.Name } else { $null }

    # 尝试按 [中文]...[EN]... 或 | 分隔符拆分双语消息
    $zhText = $null
    $enText = $null

    if ($Message -match '\[中文\]\s*(.+?)\s*\|\s*\[EN\]\s*(.+)$') {
        $zhText = $Matches[1].Trim()
        $enText = $Matches[2].Trim()
    } elseif ($Message -match '\[中文\]\s*(.+?)\s*\[EN\]\s*(.+)$') {
        $zhText = $Matches[1].Trim()
        $enText = $Matches[2].Trim()
    }

    if ($zhText -and $enText) {
        # 双语模式：分别用对应语音朗读
        if ($zhVoiceName) { $synth.SelectVoice($zhVoiceName) }
        $synth.Speak($zhText)

        Start-Sleep -Milliseconds 400

        if ($enVoiceName) { $synth.SelectVoice($enVoiceName) }
        $synth.Speak($enText)
    } else {
        # 单语模式（fallback）：用中文语音读全部
        if ($zhVoiceName) { $synth.SelectVoice($zhVoiceName) }
        $synth.Speak("AI工作完成。$Message")
    }

    $synth.Dispose()
} catch {
    Write-Host "[TTS 不可用] $Message"
}

# --- Step 5: Console output ---
$timestamp = Get-Date -Format "HH:mm:ss"
Write-Host ""
Write-Host "[$timestamp] 完成 - $Message" -ForegroundColor Green
Write-Host ""
