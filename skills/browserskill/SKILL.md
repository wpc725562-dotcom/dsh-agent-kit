---
name: browserskill
description: 通过 bsk CLI + BrowserSkill 扩展驱动本机 Chrome：读取/导航/点击/填写/截图任意页面，复用已登录会话
---

# BrowserSkill — 驱动本机浏览器的技能

通过已安装的 **bsk CLI**（腾讯 BrowserSkill）操作本机 Chrome 浏览器。无需 CDP、无需自建桥接，扩展已装、daemon 常驻。

## 前置条件检查（每次调用前快速确认）

1. daemon 是否在运行：
   ```powershell
   $bsk = "$env:USERPROFILE\.local\bin\bsk.exe"
   & $bsk status
   ```
   - 输出应含 `browsers connected  1`。若无，先 `& $bsk daemon start` 并等待 5 秒。
2. 浏览器是否连接：`& $bsk browsers` 应列出 chrome 实例。
3. 若无 session：`& $bsk session start --json` 创建（可能需等 30~90 秒，因为扩展 Service Worker 周期唤醒；用后台 job 等待再取结果）。

## 核心工作流

### 1. 创建/复用 session（Agent Window）
```powershell
$s = & $bsk session start --json    # 返回 {session_id, agent_window_id}
$sid = ($s | ConvertFrom-Json).session_id
```
> ⚠️ 若命令长时间无输出：SW 休眠导致 RPC 未达扩展。**用 `Start-Job` 后台运行 + `Start-Sleep` 30~90 秒**再 `Receive-Job` 取结果，这是已知时序问题，不是故障。

### 2. 导航到 URL
```powershell
& $bsk navigate --session $sid "https://example.com"
# 输出: tab=<id> reached=load url=...
```

### 3. 读取页面内容（快照）
```powershell
& $bsk snapshot --session $sid --json
# 返回 aria 语义快照: @e1 button "xxx"、StaticText 值、table 行列
# 元素用 @eN 引用，供后续 click/fill 使用
```

### 4. 交互操作
```powershell
& $bsk click  --session $sid @e5          # 点击 @e5
& $bsk fill   --session $sid @e12 "text"  # 填输入框
& $bsk press  --session $sid Enter        # 按键
& $bsk select --session $sid @e18 "value" # 下拉选择
& $bsk screenshot --session $sid          # 截图（默认保存 PNG）
& $bsk get-html --session $sid            # 原始 HTML
& $bsk observe --session $sid             # 语义观察
```

### 5. 标签页管理
```powershell
& $bsk tab list --session $sid            # 列出所有标签页（含 user 作用域）
& $bsk tab select --session $sid <id>     # 聚焦标签页
& $bsk tab borrow --session $sid <id>     # 借用用户标签页
& $bsk tab return --session $sid <id>     # 归还
```

### 6. 结束会话
```powershell
& $bsk session stop $sid      # 停止单个 session（SESSION_ID 是位置参数）
& $bsk session stop --all     # 停止全部
```

## 关键注意事项

- **路径**：bsk 在 `C:\Users\Administrator\.local\bin\bsk.exe`，已加入 PATH，但脚本里用完整变量更稳。
- **时序**：SW 每 ~30 秒唤醒（`bh-keepalive`），RPC 若赶上休眠会卡住。**任何命令超过 15 秒无响应，改用后台 job + 等待**，不要重复前台重试。
- **daemon 保活**：daemon 可能被会话回收，操作前先 `status` 确认，必要时重启动。
- **编码**：PowerShell 5.1 控制台是 GBK，中文会乱码。读页面内容时设置 `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` 或把结果写文件再用 UTF-8 读。
- **安全**：bsk 操作的是您**已登录的真实浏览器**，点击/填写是真实操作。涉及提交、付款、删除等高风险动作前，先向用户确认。
- **screenshot 输出**：默认保存到当前目录或指定路径，注意收集文件位置给用户。
- **session 列表**：`& $bsk session list` 查看活跃 session；daemon 重启后 session 失效需重建。

## 失败排查

- `requested resource does not exist` / `session not registered`：session 已失效（daemon 重启），重建 session。
- `waiting for browser extension to connect`：扩展 SW 休眠，等待 30~90 秒重试。
- `error: unexpected argument`：参数格式错，用 `& $bsk <cmd> --help` 查用法。
- 中文字符乱码：非数据损坏，是控制台编码，用文件+UTF-8 读取解决。
