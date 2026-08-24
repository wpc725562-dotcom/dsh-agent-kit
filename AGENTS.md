# AGENTS.md — dsh-agent-kit 项目规范

> 本文件是所有 AI agent（DSH、Claude Code、Cursor 等）操作此仓库时的行为准则。
> 每次 agent 操作前请先读取本文件。

## 项目概述

- **项目名**：dsh-agent-kit — 自用 Agent 工具集
- **技术栈**：YAML（MCP 配置）/ Markdown（Skills / 文档）/ PowerShell（安装脚本）
- **用途**：把 DSH Desktop 上验证过的插件/MCP/Skills/预设封装成可移植工具集
- **仓库地址**：GitHub 上的公开仓库

## 构建与验证

- 语法检查：`scripts/verify.ps1`（校验 YAML 语法、MCP 配置格式、Skill 目录完整性）
- 无构建步骤（纯配置/脚本仓库，无代码编译）
- 提交前必须运行 `verify.ps1` 通过

## 文件规范

| 文件类型 | 规则 |
|:---|:---|
| `mcp/*.yml` | 符合 dsh-mcp-client 的 `cordis.patch.yml` insert 格式 |
| `skills/*/SKILL.md` | 必须含 frontmatter（name/description） |
| `presets/*.yml` | 符合 cordis 预设格式 |
| `scripts/*.ps1` | PowerShell 5.1+ UTF-8 BOM，`cmd /c` 绕开执行策略 |
| `docs/*.md` | 中文正文，代码/命令保留英文 |

## 禁止事项（硬约束）

1. **禁止提交任何 API key、Token、密码**（包括测试值、占位符中的真实值）
2. **禁止引入未验证的第三方包**——先通过 npm registry 或 GitHub API 验证包名/仓库真实存在
3. **禁止修改 DSH 运行配置**（`settings.yaml` / `cordis.patch.yml`）除非用户明确要求
4. **禁止 push 到 main 前不拉取** —— 先 `git pull --rebase origin main`
5. **禁止编造 BV 号 / npm 包名 / 仓库名**——所有外部引用必须实测核实

## 已知坑点（实测验证，勿重蹈）

### api.b.ai 网关路径（重要！）
- api.b.ai **只允许推理路径**：`/v1/chat/completions`、`/v1/messages`、`/v1/responses`、`/v1/models`、`/v1/images/*`
- 请求裸 `/v1` 会返回 **HTTP 403**：
  `{"message":"HTTP node only allows access to inference API paths (...)", "success":false}`
- **配置 provider 时必须写完整路径**：
  - ✅ `base_url = "https://api.b.ai/v1"` + `request_url = "https://api.b.ai/v1/chat/completions"`
  - ❌ `request_url = "https://api.b.ai/v1"`（裸路径，403）
- 验证命令：`curl -X POST https://api.b.ai/v1/chat/completions -H "Authorization: Bearer $KEY" -d '{"model":"deepseek-v4-flash","messages":[{"role":"user","content":"hi"}]}'`

### PowerShell 5.1 中文脚本
- `.ps1` 含中文必须 **UTF-8 BOM**，否则解析为 GBK 报"字符串缺少终止符"
- 正则 `{20,}` 在 PS 5.1 字符串中解析崩溃 → 用 `{20}` 或避免花括号量词

### MCP 首次启动
- npx 首次运行下载包较慢（120s 超时属正常）
- anki-mcp-server 仅在 Anki 运行时注册工具；bilibili-mcp 需先 `config` 配 Cookie

## Git 规范

- commit 格式：Conventional Commits（`feat:` / `fix:` / `docs:` / `chore:`）
- 分支：个人项目直接 main，谨慎提交
- 发布：打 tag `v1.0.0` 并创建 GitHub Release

## 安全规则

- 安装脚本 `install.ps1` 必须先备份目标文件（`*.bak-<timestamp>`）
- 所有对外网络请求必须通过 HTTPS，不发送本地密钥
- CI 工作流使用 GitHub Secrets，不硬编码密钥

## 触发条件

- 用户说"安装"/"部署"/"恢复环境" → 运行 `scripts/install.ps1`
- 用户说"校验"/"检查" → 运行 `scripts/verify.ps1`
- 用户说"导出当前配置" → 运行 `scripts/export.ps1`
- 用户说"发布"/"release" → 打 tag + GitHub Release