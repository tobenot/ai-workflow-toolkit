# ai-workflow-toolkit
A practical AI workflow toolkit: handoff notifications, rule templates, automation scripts, and productivity playbooks.

ai-workflow-toolkit/
  notify-done/                    # AI 工作完成提醒系统
    notify-done.ps1               # 主脚本（非阻塞，含提示音 + 语音 + 浮窗）
    notify-popup.ps1              # 持久浮窗（被 notify-done 调用）
    notify-tone.ps1               # 提示音合成器（纯 PowerShell 逐采样生成 WAV）
    音效设计探索记录.md             # 音效设计探索与迭代记录
    PITFALL.md                    # PowerShell 5.1 + WinForms 踩坑记录
    remind.mdc                    # AI 交接提醒规则（英文）
    remind_zh.mdc                 # AI 交接提醒规则（中文）
