# AI Workflow Toolkit

[中文说明](README.zh-CN.md)

---

A practical toolkit for improving human–AI collaboration workflows. Currently includes a **task handoff notification system** for Windows; more tools planned.

## 📦 Modules

### [notify-done](notify-done/) — AI Task Handoff Notification

When an AI agent finishes its work, you're often away — grabbing coffee, browsing another tab, or deep in thought. **notify-done** makes sure you never miss the handoff:

- 🔔 **Sci-fi alert tone** — Pure PowerShell sample-by-sample WAV synthesis, no external audio files. Two sound profiles: a cyberpunk bell chime (`notify-tone-boot.ps1`) and a distant foghorn alert (`notify-tone.ps1`).
- 🗣️ **Bilingual TTS** — Reads the handoff report aloud in both Chinese and English, using the appropriate system voice for each language.
- 🪟 **Persistent popup** — A dark-themed, draggable WinForms popup that stays on screen until you actively dismiss it. Supports snooze (10 / 30 min) and one-click copy.
- ⚡ **Non-blocking** — The main script spawns a background worker and exits immediately, never stalling the AI execution chain.
- 🎛️ **Fully configurable** — Colors, fonts, volumes, tone duration, TTS rate — all tunable via a user config override file.

#### Quick Start

```powershell
powershell -ExecutionPolicy Bypass -File notify-done/notify-done.ps1 "Done: refactored export module. Review: performance with large datasets."
```

#### AI Agent Integration

Drop the included `.mdc` rule files ([English](notify-done/remind.mdc) / [中文](notify-done/remind_zh.mdc)) into your AI coding assistant's rules directory. The rules instruct the agent to call `notify-done.ps1` with a structured handoff report (what was done / trade-offs / review points / risks) after every task.

### File Structure

```
notify-done/
  notify-done.ps1            # Main entry (non-blocking launcher + worker)
  notify-done.config.ps1     # Default config (colors, fonts, volumes, etc.)
  notify-popup.ps1            # Persistent popup (separate WinForms process)
  notify-tone.ps1             # Alert tone — sci-fi distant foghorn style
  notify-tone-boot.ps1        # Notification tone — cyberpunk bell chime style
  remind.mdc                  # AI handoff rules (English)
  remind_zh.mdc               # AI handoff rules (Chinese)
  PITFALL.md                  # PowerShell 5.1 + WinForms gotchas
  音效设计探索记录.md            # Sound design exploration log
```

## 🛠️ Requirements

- **Windows** with PowerShell 5.1+ (ships with Windows 10/11)
- No external dependencies — everything is pure PowerShell + .NET Framework

## 📜 License

[MIT](LICENSE) © 2026 tobenot