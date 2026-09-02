# DSH Desktop 插件升级评估报告 2026-09-02

## 一、环境快照

| 项目 | 值 |
|------|------|
| DSH CLI | 0.1.1-rc.2 |
| 安装目录 | `C:\Users\Administrator\AppData\Local\Programs\DSH Desktop\` |
| 配置目录 | `~/.dsh/` |
| Profile | `desktop` |
| 插件数量 | 17 个依赖，14 个实际安装 |
| 市场缓存 | 2026-08-21 生成，含 4299 个插件（4175 cordis-plugin + 124 skill） |
| MCP 服务器 | 8 个已配置 |

---

## 二、已装插件清单

| 包名 | 版本 | 类别 |
|------|------|------|
| `@huiliyi37/dsh-mcp-client` | — | MCP 客户端框架 |
| `@huiliyi37/dsh-subprocess` | — | 子进程管理 |
| `@huiliyi37/dsh-tools` | — | 工具集 |
| `@liustack/modlens` | ^3.24.1 | 视觉插件 |
| `@liustack/modsearch` | 5.9.0 | 搜索增强 |
| `@nanmicoder/dsh-agent-teams` | ^0.1.14 | 多智能体团队 |
| `@openviking/dsh-memory-plugin` | 0.2.1 | 记忆插件 |
| `dsh-at-file` | 0.6.3 | @file 引用 |
| `dsh-bookmarks` | 0.1.2 | 书签 |
| `dsh-context` | 0.27.0 | 上下文面板 |
| `dsh-cost-meter` | 1.5.38 | 费用统计 |
| `dsh-github-intelligence` | 2.9.0 | GitHub 智能 |
| `dsh-ha-orchestrator` | 0.12.2 | 高可用编排 |
| `dsh-plugin-bridge` | 0.2.10 | 插件桥接 |
| `dsh-pocket` | 1.13.4 | 口袋版（手机访问） |
| `dsh-popout-sidebar` | 1.0.1 | 弹出侧边栏 |
| `dshmarket` | 1.21.0 | 插件市场 |

已装 Bundle 层：`dsh-base`、`dsh-web-app`、`dshmarket`、`modlens`、`modsearch`、`dsh-bookmarks`、`dsh-context`、`dsh-github-intelligence`、`dsh-ha-orchestrator`、`dsh-pocket`

---

## 三、兼容性发现：DSH 核心版本漂移

### 可升级但冲突的插件

`pnpm outdated` 发现 7 个插件有新版本，但升级时遇到 **DSH 核心包版本漂移**：

| 包名 | 当前 | 最新 | 冲突原因 |
|------|------|------|----------|
| dshmarket | 1.18.0 | 1.39.0 | 依赖 `@deepseek-ai/dsh-settings@>=0.1.1`，但 npm 最高只有 0.1.1-rc.2（rc < stable） |
| dsh-pocket | 1.13.4 | 2.10.0 | 同上 |
| dsh-context | 0.27.0 | 0.40.1 | 同上 |
| dsh-cost-meter | 1.5.38 | 1.7.6 | 同上 |
| @openviking/dsh-memory-plugin | 0.2.1 | 0.3.0 | 同上 |
| @liustack/modsearch | 5.9.0 | 5.10.0 | 同上 |
| dsh-plugin-bridge | 0.2.10 | 0.3.1 | 同上 |

### 根因

DSH 社区插件作者的 peerDependencies 声明了稳定版范围（如 `>=0.1.1 <0.2.0`），但 DSH 官方只发布了 rc/alpha 版本（如 `0.1.1-rc.2`、`0.1.2-alpha.4`）。semver 规则下 `0.1.1-rc.2 < 0.1.1`，因此 npm 上**不存在任何满足稳定版范围**的版本。

**结论：当前 DSH 0.1.1-rc.2 生态下，不建议升级已装插件，否则可能破坏兼容性导致 DSH 无法启动。**

---

## 四、精选新插件推荐

### 4.1 MCP 管理类

| 推荐 | 仓库 | Stars | 说明 |
|------|------|-------|------|
| ⭐ **dsh-mcp-panel** | `PerryLink/dsh-mcp-panel` | 52 | MCP 管理控制台：`/mcp` 命令 + 健康诊断 + 设置页 GUI 管理 + 工具试用管道 |
| **Jnpz** | `pazz11/Jnpz` | 14 | 设置页粘贴 JSON 即连 MCP 服务器，热加载免重启 |

### 4.2 界面体验类

| 推荐 | 仓库 | Stars | 说明 |
|------|------|-------|------|
| ⭐ **DSH-better-sidebar** | `omdsh-dev/DSH-better-sidebar` | 2463 | 侧边栏增强：文件渲染/终端/Git/subagents/自定义 API |
| **dsh-TUI** | `ccch1mneyyy/dsh-TUI` | 2183 | 类 Claude Code 全屏终端界面 |

### 4.3 生态清单参考

| 推荐 | 仓库 | Stars | 说明 |
|------|------|-------|------|
| ⭐ **awesome-dsh-plugin** | `awesome-dsh-plugin/awesome-dsh-plugin` | 14k | DSH 插件精选列表 |

---

## 五、MCP 现状

### 已配置的 8 个 MCP 服务器

| 名称 | 实现 | 用途 |
|------|------|------|
| cloakbrowser | `cloakbrowser-mcp` | 浏览器自动化 |
| anki | `@iantay/anki-mcp-server` | Anki 记忆卡片 |
| bilibili | `@xzxzzx/bilibili-mcp` | B站内容 |
| code-runner | `mcp-server-code-runner` | 代码运行 |
| bili-note | 本地 Python 脚本 | B站笔记 |
| zsb-agent-kit | 本地 Python MCP | 专升本工具包 |
| playwright | `playwright-mcp-server` | 浏览器自动化 |
| windows-mcp | `windows-mcp` (uvx) | Windows 系统控制 |

配置位置：`~/.dsh/profiles/desktop/cordis.patch.yml`

---

## 六、安装新插件命令

```bash
dsh plugin --profile desktop add @perrylink/dsh-mcp-panel
# 或
dsh plugin --profile desktop add @omdsh-dev/dsh-better-sidebar
```

⚠️ 安装前请确保 DSH Desktop 已关闭，安装后重启生效。

---

## 七、依赖树修复记录

2026-09-02 `pnpm update` 因核心版本冲突失败，导致 `node_modules/.ignored` 产生。已手动恢复，命令：

```bash
cd ~/.dsh/profiles/desktop/node_modules
for p in dsh-at-file dsh-bookmarks dsh-context dsh-cost-meter dsh-github-intelligence dsh-ha-orchestrator dsh-plugin-bridge dsh-pocket dsh-popout-sidebar dshmarket; do
  [ -d ".ignored/$p" ] && mv ".ignored/$p" "./$p"
done
for sc in @huiliyi37 @liustack @nanmicoder @openviking; do
  [ -d ".ignored/$sc" ] && { mkdir -p "$sc"; for sub in .ignored/$sc/*; do [ -d "$sub" ] && mv "$sub" "$sc/"; done; }
done
rm -rf .ignored
```