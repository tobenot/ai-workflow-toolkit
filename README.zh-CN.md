# AI 工作流工具箱

[English](README.md)

---

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