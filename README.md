# dsh-agent-kit

**自用 Agent 工具集** — 把 DeepSeek Harness (DSH) Desktop 上验证过好用的插件、MCP、Skills、Agent 预设封装成一套可移植、可安装、可复用的个人开发环境。

> 目标：在一台新机器上，用一条命令恢复你熟悉的整套 AI 开发环境（浏览器自动化、Anki 错题、B站字幕、代码沙盒、学习教练、代码审查……）。

---

## 这是什么

这套工具集源自本人在 DSH Desktop 上的实际配置，全部经过真实使用验证（非网传/编造）。它包含：

| 模块 | 内容 | 数量 |
|:---|:---|:---|
| `mcp/` | MCP 服务器配置模板（cloakbrowser / anki / bilibili / code-runner） | 4 |
| `skills/` | 学习型 + 工程型 Skills（study-coach、web-research、verification-before-completion 等） | 12 |
| `presets/` | Agent 预设（个人学习模式、开发模式） | 2 |
| `scripts/` | 一键安装 / 校验 / 导出脚本 | 3 |
| `docs/` | 使用手册与配置说明 | — |

## 快速开始

```bash
# 1. 克隆
git clone https://github.com/<your-name>/dsh-agent-kit.git
cd dsh-agent-kit

# 2. 一键安装到 DSH
powershell -ExecutionPolicy Bypass -File scripts/install.ps1

# 3. 校验是否装好
powershell -File scripts/verify.ps1

# 4. 重启 DSH Desktop，/mcp list 确认 4 个 MCP 均 Active
```

## 目录结构

```
dsh-agent-kit/
├── mcp/                    # MCP 服务器配置（dsh-mcp-client 格式）
│   ├── cloakbrowser.yml
│   ├── anki.yml
│   ├── bilibili.yml
│   └── code-runner.yml
├── skills/                 # 技能定义（每个一个目录 + SKILL.md）
│   ├── study-coach/
│   ├── web-research/
│   └── ...
├── presets/                # Agent 预设（cordis 风格）
│   ├── personal-learning.yml
│   └── software-dev.yml
├── scripts/
│   ├── install.ps1         # 安装到 DSH（备份 + 复制 + 提示重启）
│   ├── verify.ps1          # 校验安装完整性
│   └── export.ps1          # 从当前 DSH 导出配置（反向同步）
├── docs/
│   ├── mcp-setup.md
│   ├── skills-guide.md
│   └── troubleshooting.md
├── AGENTS.md               # AI agent 项目规范（本仓库）
├── LICENSE                 # MIT
└── README.md
```

## 系统要求

- Windows 10/11（DSH Desktop）
- Node.js 18+（npm 全局可用）
- 已安装 DeepSeek Harness Desktop

## 安全说明

- **仓库内不含任何 API key**，全部通过环境变量注入（参考 `docs/mcp-setup.md`）
- MCP 配置使用 `failOnStartupError: false`，单个失败不影响整体启动
- 安装脚本会先备份目标文件（`*.bak-<timestamp>`），可安全回滚

## 许可证

MIT © 2026 wpc725562-dotcom
