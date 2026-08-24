# dsh-agent-kit 使用手册

## 安装

### 前置条件

| 依赖 | 版本要求 | 检查命令 |
|:---|:---|:---|
| Windows | 10/11 | — |
| Node.js | 18+ | `node -v` |
| DSH Desktop | 已安装运行过 | 检查 `%USERPROFILE%\.dsh` 存在 |

### 一键安装

```powershell
git clone https://github.com/<your-name>/dsh-agent-kit.git
cd dsh-agent-kit
powershell -ExecutionPolicy Bypass -File scripts/install.ps1
```

安装脚本会：
1. 检查 npx / DSH profile
2. 安装 @huiliyi37/dsh-mcp-client 依赖（如缺）
3. 输出需要合并到 `cordis.patch.yml` 的 MCP insert 块
4. 复制 skills 到 `%USERPROFILE%\.dsh\skills`

### 手动合并 MCP 配置

安装脚本会打印新的 insert 块，将它们追加到：

```
%USERPROFILE%\.dsh\profiles\desktop\cordis.patch.yml
```

的 `insert:` 列表末尾，然后重启 DSH Desktop。

## 验证

```powershell
powershell -File scripts/verify.ps1
```

通过标准：全部 ✅，无 ❌。

## MCP 服务器前置条件

| 服务器 | 前置条件 | 首次启动耗时 |
|:---|:---|:---|
| cloakbrowser | 无（自动下载浏览器） | ~60s |
| anki | Anki 已运行 + AnkiConnect 插件（端口 8765） | ~30s |
| bilibili | `npx -y @xzxzzx/bilibili-mcp@latest config` 配 Cookie | ~60s |
| code-runner | gcc / python 已装 | ~20s |

## 故障排查

### MCP 启动失败 / 0 工具

1. 确认前置条件满足（Anki 必须运行、bilibili 必须配 Cookie）
2. 手动测试服务器：
   ```powershell
   cmd /c "npx -y <package> --help"
   ```
3. 首次运行 npx 下载较慢，耐心等待或预下载

### 执行策略阻止脚本

PowerShell 报"无法加载文件...禁止运行脚本"：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install.ps1
```

或在脚本内用 `cmd /c` 调用（本仓库脚本已内置处理）。

### 中文乱码 / BOM 问题

PowerShell 5.1 对无 BOM 的 UTF-8 中文解析有兼容问题。本仓库脚本均使用 UTF-8 BOM 编码。若手动编辑脚本后出现"字符串缺少终止符"，用带 BOM 的方式重新保存。

## 更新

```powershell
git pull --rebase origin main
powershell -File scripts/verify.ps1
```

## 反向同步（导出当前 DSH 配置）

```powershell
powershell -File scripts/export.ps1
```

会把当前 DSH 的 MCP 配置和 skills 导出回仓库（自动脱敏），适合迁移后同步。
