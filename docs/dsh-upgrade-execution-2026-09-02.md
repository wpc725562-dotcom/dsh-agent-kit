# DSH 升级执行记录 2026-09-02

## 执行总结

全自动执行以下升级项（用户授权「大量运行、自己判断」）：

## 1. MCP 新增（不受版本锁定影响）

在 `cordis.patch.yml` 新增 2 个 MCP 服务器，DSH 已重启生效：

| MCP | 包 | 功能 |
|-----|-----|------|
| **filesystem** | `@modelcontextprotocol/server-filesystem` | 文件系统访问（Documents/Desktop/global-workspace） |
| **memory** | `@modelcontextprotocol/server-memory` | 持久知识图谱记忆 |

现有 MCP 总数：**10 个**（+2）

## 2. npm 全局包升级

| 包 | 旧版本 | 新版本 |
|-----|--------|--------|
| @openai/codex | 0.149.1 | 0.152.1 |
| @qwen-code/qwen-code | 0.22.2 | 0.22.3 |
| agentic-awesome-skills | 16.2.0 | 16.5.0 |
| pnpm | 11.21.0 | 11.25.0 |
| reasonix | 1.31.4 | 1.35.0 |
| npm | 11.17.0 | 12.0.2 |

## 3. Python 工具包升级

| 包 | 旧版本 | 新版本 |
|-----|--------|--------|
| anthropic | 1.0.0 | 1.3.0 |
| cloakbrowser | 0.5.8 | 0.5.10 |
| dashscope | 1.27.1 | 1.27.3 |

跳过 fastmcp 4.x（大版本，zsb-agent-kit 依赖 3.x）

## 4. 修复 npm 12 升级导致的 dsh 命令丢失

npm 12 改变了全局 prefix，导致 dsh bin shim 被清理。已重建：
```bash
npm install -g @deepseek-ai/dsh@0.1.1-rc.2
```

## 5. 未执行（需人工）

- **dshmarket 缓存刷新**：需通过 DSH Web UI 市场面板点击「刷新」按钮
- **dsh-desktop 升级到 v2.0.4**：当前 2.0.2，最新 2.0.4 适配上游 v0.1.2-alpha.1。官方警告「破坏性更新会导致很多插件不可用」，且用户 14 个插件基于 rc.2 环境，故暂缓
- **DSH 插件安装**：仍受版本锁定限制（等 DSH 官方发布稳定版核心包）

## 6. 版本锁定当前状态

**DSH 0.1.1-rc.2 + dsh-desktop 2.0.2** 稳定运行中。
14 个插件 + 10 个 MCP 正常工作。

## 配置位置

- MCP 配置：`~/.dsh/profiles/desktop/cordis.patch.yml`
- 插件配置：`~/.dsh/profiles/desktop/package.json`
- 依赖树：`~/.dsh/profiles/desktop/node_modules/`（已修复，无 .ignored 残留）

---

*本记录由 Reasonix 自动执行，2026-09-02*