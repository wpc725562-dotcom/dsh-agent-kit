# ============================================================
# dsh-agent-kit 安装脚本 v2
# 将本仓库的 MCP 配置、Skills、Presets 安装到 DSH Desktop
# 用法:
#   powershell -ExecutionPolicy Bypass -File scripts/install.ps1           # 正式安装
#   powershell -ExecutionPolicy Bypass -File scripts/install.ps1 --dry-run # 预览（不写入）
# ============================================================
$ErrorActionPreference = "Stop"

# --- 参数解析 ---
$DryRun = $false
if ($args -contains "--dry-run") { $DryRun = $true }

# --- 配置 ---
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$DshHome = Join-Path $env:USERPROFILE ".dsh"
$ProfileDir = Join-Path $DshHome "profiles\desktop"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

Write-Host "==========================================" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host " dsh-agent-kit 安装器（预览模式 --dry-run）" -ForegroundColor Cyan
} else {
    Write-Host " dsh-agent-kit 安装器 v2" -ForegroundColor Cyan
}
Write-Host "==========================================" -ForegroundColor Cyan

# --- 0. 检查环境 ---
if (-not (Test-Path $ProfileDir)) {
    Write-Host "❌ 未找到 DSH desktop profile: $ProfileDir" -ForegroundColor Red
    Write-Host "   请确认已安装 DSH Desktop 并运行过一次" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ DSH profile 目录: $ProfileDir"

# --- 1. 检查 npx ---
$npx = Get-Command npx.cmd -ErrorAction SilentlyContinue
if (-not $npx) {
    Write-Host "❌ 未找到 npx，请先安装 Node.js 18+" -ForegroundColor Red
    exit 1
}
Write-Host "✅ npx: $($npx.Source)"

# --- 2. 检查/安装 dsh-mcp-client 依赖 ---
$PkgJson = Join-Path $ProfileDir "package.json"
if (Test-Path $PkgJson) {
    $pkg = Get-Content $PkgJson -Raw | ConvertFrom-Json
    if (-not $pkg.dependencies.'@huiliyi37/dsh-mcp-client') {
        Write-Host "⚠️ package.json 缺少 @huiliyi37/dsh-mcp-client，安装中..." -ForegroundColor Yellow
        if (-not $DryRun) {
            Push-Location $ProfileDir
            cmd /c "npm install @huiliyi37/dsh-mcp-client --save 2>&1"
            Pop-Location
        } else {
            Write-Host "   [dry-run] 将执行: npm install @huiliyi37/dsh-mcp-client --save"
        }
    } else {
        Write-Host "✅ @huiliyi37/dsh-mcp-client 已安装 (v$($pkg.dependencies.'@huiliyi37/dsh-mcp-client'))"
    }
}

# --- 3. 合并 MCP 配置到 cordis.patch.yml（真正写入） ---
$CordisPatch = Join-Path $ProfileDir "cordis.patch.yml"
$McpDir = Join-Path $RepoRoot "mcp"

# 备份（仅正式安装时）
if ((Test-Path $CordisPatch) -and (-not $DryRun)) {
    $Backup = "$CordisPatch.bak-$Timestamp"
    Copy-Item $CordisPatch $Backup
    Write-Host "✅ 已备份 cordis.patch.yml -> $Backup"
}

# 读取现有 patch
$existing = ""
if (Test-Path $CordisPatch) {
    $existing = Get-Content $CordisPatch -Raw
}

# 生成新增 insert 块（从 mcp/*.yml 模板 + 替换 npx 路径）
$npxCmd = (Get-Command npx.cmd).Source.Replace("\", "\\")
$newBlocks = @()

Get-ChildItem "$McpDir\*.yml" | ForEach-Object {
    $name = $_.BaseName
    if ($existing -match "mcp-client-$name") {
        Write-Host "⏭️  MCP $name 已存在，跳过"
        return
    }
    $tmpl = Get-Content $_.FullName -Raw
    $tmpl = $tmpl -replace '\{NPX_CMD\}', $npxCmd
    # 模板（serverName/transport/...）→ cordis insert 条目格式
    $lines = $tmpl -split "`n"
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("    - id: mcp-client-$name")
    [void]$sb.AppendLine("      name: '@huiliyi37/dsh-mcp-client'")
    [void]$sb.AppendLine("      config:")
    foreach ($line in $lines) {
        $trimmed = $line.TrimEnd()
        if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
        # 跳过 serverName 行（已用 id 表达）
        if ($trimmed -match "^serverName:") { continue }
        [void]$sb.AppendLine("        $trimmed")
    }
    $newBlocks += $sb.ToString().TrimEnd()
    Write-Host "➕ 添加 MCP: $name"
}

if ($newBlocks.Count -gt 0) {
    if ($DryRun) {
        Write-Host ""
        Write-Host "以下 insert 块将追加到 $CordisPatch：" -ForegroundColor Yellow
        foreach ($b in $newBlocks) {
            Write-Host ""
            Write-Host $b -ForegroundColor Gray
            Write-Host "---"
        }
    } else {
        # 找到 `- insert:` 顶层项位置，在其列表内追加
        if ($existing -match "(?m)^- insert:") {
            # 追加到文件末尾（该文件只有 insert 列表时安全）
            $appendText = "`n" + ($newBlocks -join "`n") + "`n"
            Add-Content -Path $CordisPatch -Value $appendText -NoNewline -Encoding UTF8
            Write-Host "✅ 已追加 $($newBlocks.Count) 个 MCP insert 块到 cordis.patch.yml"
        } else {
            # 文件不存在或没有 insert 键：创建新文件
            $header = "# dsh-agent-kit 生成的 MCP 配置（$Timestamp）`n- insert:`n"
            $full = $header + ($newBlocks -join "`n") + "`n"
            Set-Content -Path $CordisPatch -Value $full -Encoding UTF8
            Write-Host "✅ 已创建 $CordisPatch（含 $($newBlocks.Count) 个 MCP）"
        }
    }
} else {
    Write-Host "✅ 所有 MCP 均已配置，无需新增"
}

# --- 4. 安装 Skills ---
$SkillDest = Join-Path $DshHome "skills"
if (-not (Test-Path $SkillDest)) {
    if ($DryRun) { Write-Host "[dry-run] 将创建 $SkillDest" }
    else { New-Item -Path $SkillDest -ItemType Directory -Force | Out-Null }
}

Get-ChildItem (Join-Path $RepoRoot "skills") -Directory | ForEach-Object {
    $skillName = $_.Name
    $dest = Join-Path $SkillDest $skillName
    if (Test-Path $dest) {
        Write-Host "⏭️  Skill $skillName 已存在，跳过"
    } else {
        if ($DryRun) {
            Write-Host "➕ [dry-run] 安装 Skill: $skillName"
        } else {
            Copy-Item $_.FullName $dest -Recurse
            Write-Host "✅ 安装 Skill: $skillName"
        }
    }
}

# --- 5. 安装 Presets ---
$PresetSrc = Join-Path $RepoRoot "presets"
$PresetDest = Join-Path $DshHome ".agent-presets"
if (Test-Path $PresetSrc) {
    if (-not (Test-Path $PresetDest)) {
        if ($DryRun) { Write-Host "[dry-run] 将创建 $PresetDest" }
        else { New-Item -Path $PresetDest -ItemType Directory -Force | Out-Null }
    }
    Get-ChildItem $PresetSrc -File | ForEach-Object {
        $name = $_.BaseName
        $destDir = Join-Path $PresetDest $name
        $destFile = Join-Path $destDir "cordis.yml"
        if (Test-Path $destFile) {
            Write-Host "⏭️  Preset $name 已存在，跳过"
        } else {
            if ($DryRun) {
                Write-Host "➕ [dry-run] 安装 Preset: $name"
            } else {
                New-Item -Path $destDir -ItemType Directory -Force | Out-Null
                Copy-Item $_.FullName $destFile
                Write-Host "✅ 安装 Preset: $name"
            }
        }
    }
}

# --- 6. 完成 ---
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
if ($DryRun) {
    Write-Host " 预览完成（未写入任何文件）" -ForegroundColor Green
} else {
    Write-Host " 安装完成！请重启 DSH Desktop 生效" -ForegroundColor Green
    Write-Host " 重启后执行 /mcp list 确认 MCP Active" -ForegroundColor Green
    Write-Host " 回滚：将 *.bak-$Timestamp 恢复为 cordis.patch.yml" -ForegroundColor Yellow
}
Write-Host "==========================================" -ForegroundColor Green