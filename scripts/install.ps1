# ============================================================
# dsh-agent-kit 安装脚本
# 将本仓库的 MCP 配置、Skills、Presets 安装到 DSH Desktop
# 用法: powershell -ExecutionPolicy Bypass -File scripts/install.ps1
# ============================================================
$ErrorActionPreference = "Stop"

# --- 配置 ---
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$DshHome = Join-Path $env:USERPROFILE ".dsh"
$ProfileDir = Join-Path $DshHome "profiles\desktop"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " dsh-agent-kit 安装器" -ForegroundColor Cyan
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
        Push-Location $ProfileDir
        cmd /c "npm install @huiliyi37/dsh-mcp-client --save 2>&1"
        Pop-Location
    } else {
        Write-Host "✅ @huiliyi37/dsh-mcp-client 已安装 (v$($pkg.dependencies.'@huiliyi37/dsh-mcp-client'))"
    }
}

# --- 3. 合并 MCP 配置到 cordis.patch.yml ---
$CordisPatch = Join-Path $ProfileDir "cordis.patch.yml"
$McpDir = Join-Path $RepoRoot "mcp"

if (Test-Path $CordisPatch) {
    # 备份
    $Backup = "$CordisPatch.bak-$Timestamp"
    Copy-Item $CordisPatch $Backup
    Write-Host "✅ 已备份 cordis.patch.yml -> $Backup"
}

# 读取现有 patch（若存在）
$existing = ""
if (Test-Path $CordisPatch) {
    $existing = Get-Content $CordisPatch -Raw
}

# 生成新增 insert 块（从 mcp/*.yml 模板 + 替换 npx 路径）
$npxCmd = (Get-Command npx.cmd).Source.Replace("\", "\\")
$newInserts = @()

Get-ChildItem "$McpDir\*.yml" | ForEach-Object {
    $name = $_.BaseName
    if ($existing -match "mcp-client-$name") {
        Write-Host "⏭️  MCP $name 已存在，跳过"
        return
    }
    $tmpl = Get-Content $_.FullName -Raw
    $tmpl = $tmpl -replace '\{NPX_CMD\}', $npxCmd
    $newInserts += $tmpl
    Write-Host "➕ 添加 MCP: $name"
}

if ($newInserts.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠️  以下 MCP 需要手动合并到 $CordisPatch :" -ForegroundColor Yellow
    foreach ($block in $newInserts) {
        Write-Host ""
        Write-Host $block -ForegroundColor Gray
        Write-Host "---"
    }
    Write-Host ""
    Write-Host "提示：将上述 insert 块追加到 cordis.patch.yml 的 insert 列表末尾即可" -ForegroundColor Yellow
} else {
    Write-Host "✅ 所有 MCP 均已配置，无需新增"
}

# --- 4. 安装 Skills ---
$SkillDest = Join-Path $DshHome "skills"
if (-not (Test-Path $SkillDest)) { New-Item -Path $SkillDest -ItemType Directory -Force | Out-Null }

Get-ChildItem (Join-Path $RepoRoot "skills") -Directory | ForEach-Object {
    $skillName = $_.Name
    $dest = Join-Path $SkillDest $skillName
    if (Test-Path $dest) {
        Write-Host "⏭️  Skill $skillName 已存在，跳过"
    } else {
        Copy-Item $_.FullName $dest -Recurse
        Write-Host "✅ 安装 Skill: $skillName"
    }
}

# --- 5. 完成 ---
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host " 安装完成！请重启 DSH Desktop 生效" -ForegroundColor Green
Write-Host " 重启后执行 /mcp list 确认 MCP Active" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green