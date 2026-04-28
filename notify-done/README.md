**English** | [中文](README_zh.md)

# notify-done

AI task handoff reminder: **notification tone + bilingual TTS + persistent popup**.

The popup runs in a separate process and never blocks the AI execution chain. It stays on screen until manually dismissed.

## Usage

```powershell
powershell -ExecutionPolicy Bypass -File notify-done.ps1 "Your handoff message"
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `-Message <string>` | Reminder text (default: "任务完成！") |
| `-Volume <0-100>` | TTS volume (default: 100) |
| `-NoBeep` | Skip the notification tone |
| `-NoPopup` | Skip the persistent popup |

## Popup Buttons

- **Got it** — Dismiss the reminder
- **10 / 30 min later** — Snooze and re-popup after delay
- **Copy** — Copy the message body to clipboard

## File Structure

| File | Purpose |
|------|---------|
| `notify-done.ps1` | Main script (tone + taskbar flash + TTS + launches popup) |
| `notify-popup.ps1` | Popup script (separate process, WinForms UI) |
| `notify-tone.ps1` | Alert tone synthesizer (pure PowerShell WAV generation) |
| `音效设计探索记录.md` | Sound design exploration log (Chinese) |

## Recommended Message Format

Structure your message as **Result / Risk / Next Step** so the popup becomes an actionable handoff card:

```text
Done: User export module refactored, supports CSV and Excel.
Risk: Not yet stress-tested with large datasets.
Next: Please run an export validation with production data.
```
