[English](#english) | [中文](#中文)

---

<a id="english"></a>

# AI Workflow Toolkit

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

---

<a id="中文"></a>

# AI 工作流工具箱

一套提升人类与 AI 协作效率的实用工具箱。目前包含 **Windows 平台的任务交接通知系统**，更多工具持续开发中。

## 📦 模块

### [notify-done](notify-done/) — AI 任务交接提醒

AI 干完活的时候，你往往不在电脑前——泡咖啡、切到别的标签页、或者正在思考问题。**notify-done** 确保你不会错过任何一次交接：

- 🔔 **科幻提示音** — 纯 PowerShell 逐采样合成 WAV，零外部依赖。两套音色：赛博朋克金属叮咚 (`notify-tone-boot.ps1`) + 远方雾中警报 (`notify-tone.ps1`)。
- 🗣️ **中英双语语音播报** — 自动识别并用对应语音分别朗读中文和英文部分。
- 🪟 **持久浮窗** — 深色主题、可拖拽的 WinForms 浮窗，不点不消失。支持延后提醒（10/30 分钟）和一键复制。
- ⚡ **不阻塞** — 主脚本拉起后台子进程后立即退出，绝不卡住 AI 执行链路。
- 🎛️ **完全可配置** — 颜色、字体、音量、音效时长、TTS 语速等均可通过用户配置文件覆盖。

#### 快速上手

```powershell
powershell -ExecutionPolicy Bypass -File notify-done/notify-done.ps1 "完成：导出模块重构完毕。需要你看：大数据量下的性能表现。"
```

#### AI 编程助手集成

将附带的 `.mdc` 规则文件（[English](notify-done/remind.mdc) / [中文](notify-done/remind_zh.mdc)）放到你的 AI 编程助手规则目录中。规则会指导 AI 在每次任务完成后，调用 `notify-done.ps1` 并附上结构化交接报告（做了什么 / 我的判断 / 需要审查的点 / 风险）。

### 文件结构

```
notify-done/
  notify-done.ps1            # 主入口（非阻塞启动器 + worker）
  notify-done.config.ps1     # 默认配置（颜色、字体、音量等）
  notify-popup.ps1            # 持久浮窗（独立 WinForms 进程）
  notify-tone.ps1             # 警报音效 — 科幻远方雾笛风格
  notify-tone-boot.ps1        # 通知音效 — 赛博朋克金属叮咚风格
  remind.mdc                  # AI 交接提醒规则（英文）
  remind_zh.mdc               # AI 交接提醒规则（中文）
  PITFALL.md                  # PowerShell 5.1 + WinForms 踩坑记录
  音效设计探索记录.md            # 音效设计探索与迭代记录
```

## 🛠️ 环境要求

- **Windows** + PowerShell 5.1+（Windows 10/11 自带）
- 无外部依赖 — 全部基于纯 PowerShell + .NET Framework

## 📜 许可证

[MIT](LICENSE) © 2026 tobenot
