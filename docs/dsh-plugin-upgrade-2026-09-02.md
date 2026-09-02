# DSH Desktop 插件升级评估报告 2026-09-02

## 一、环境快照

| 项目 | 值 |
|------|------|
| DSH CLI | 0.1.1-rc.2 |
| 安装目录 | `C:\Users\Administrator\AppData\Local\Programs\DSH Desktop\` |
| 配置目录 | `~/.dsh/` |
| Profile | `desktop` |
| 插件数量 | 17 个依赖，14 个实际安装 |
| 市场缓存 | 2026-08-21 生成，含 4299 个插件 |
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

## 三、核心发现：DSH 生态版本锁定

### 问题

当前 DSH 0.1.1-rc.2 被锁定在现有插件组合中——**既不能升级已装插件，也不能安装新插件**。

### 根因

DSH 社区插件作者的 peerDependencies 声明了**稳定版范围**（如 `@deepseek-ai/dsh-tools@>=0.1.2 <0.2.0-0`），但 DSH 官方只发布了 **rc/alpha 版本**（如 `0.0.1-rc.1`、`0.1.1-rc.2`）。

semver 规则下 `0.1.1-rc.2 < 0.1.1`，因此 npm 上**不存在任何满足稳定版范围的版本**。

### 具体表现

| 尝试 | 结果 | 原因 |
|------|------|------|
| `pnpm update` 升级 7 个已装插件 | ❌ 失败 | 新版本要求 `@deepseek-ai/dsh-settings@>=0.1.1` |
| `dsh plugin add` 安装 dsh-mcp-panel | ❌ 失败 | 要求 `@deepseek-ai/dsh-tools@>=0.1.2` |
| 安装任何新 cordis-plugin | ❌ 预期失败 | 所有社区插件都踩同样的坑 |

### 什么时候能解决

等 DSH 官方发布核心包的稳定版（>=0.1.1）或社区插件改用 rc 范围。这是 DSH 生态的早期阶段阵痛。

---

## 四、精选新插件推荐（等解锁后装）

### 4.1 MCP 管理类

| 推荐 | 仓库 | Stars | 说明 |
|------|------|-------|------|
| ⭐ **dsh-mcp-panel** | `PerryLink/dsh-mcp-panel` | 52 | MCP 管理控制台：`/mcp` 命令 + 健康诊断 + 设置页 GUI |
| **Jnpz** | `pazz11/Jnpz` | 14 | 设置页粘贴 JSON 即连 MCP，热加载免重启 |

### 4.2 界面体验类

| 推荐 | 仓库 | Stars | 说明 |
|------|------|-------|------|
| ⭐ **DSH-better-sidebar** | `omdsh-dev/DSH-better-sidebar` | 2463 | 侧边栏增强：文件渲染/终端/Git/subagents |
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

## 六、市场缓存刷新

方式一：通过 DSH Web UI 市场面板（dshmarket 插件提供），点击刷新按钮
方式二：等 DSH 核心包升级后，升级 dshmarket 到最新版，自动获取最新缓存

---

## 七、安装新插件命令（等解锁后执行）

```bash
# 先停 DSH Desktop
taskkill //F //IM "DSH Desktop.exe"

# 安装 dsh-mcp-panel
dsh plugin --profile desktop add github:PerryLink/dsh-mcp-panel

# 安装 DSH-better-sidebar
dsh plugin --profile desktop add github:omdsh-dev/DSH-better-sidebar

# 装完后重启 DSH
```

如遇到 `ERR_PNPM_GIT_DEP_PREPARE_NOT_ALLOWED`，把 pnpm 打印的精确 key 加进 `~/.dsh/profiles/desktop/pnpm-workspace.yaml`

```yaml
allowBuilds:
  <精确的 key>: true
```

---

## 八、依赖树修复记录

每次 `pnpm update` 或 `dsh plugin add` 失败，pnpm 都会把已装插件移到 `node_modules/.ignored`。恢复命令：

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

---

*本报告由 Reasonix 自动生成，数据来源：DSH 本地市场缓存 + GitHub 实时搜索 + 实际安装验证*
*最后更新：2026-09-02*