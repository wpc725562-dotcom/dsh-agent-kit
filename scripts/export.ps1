# ============================================================
# dsh-agent-kit 导出脚本
# 从当前 DSH Desktop 导出实际配置，同步回本仓库
# 用法: powershell -File scripts/export.ps1
# 注意: 导出的配置会脱敏（替换真实 key 为占位符）
# ============================================================
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$DshHome = Join-Path $env:USERPROFILE ".dsh"
$ProfileDir = Join-Path $DshHome "profiles\desktop"

Write-Host "=== 从 DSH 导出配置 ===" -ForegroundColor Cyan

# --- 1. 导出 MCP 配置（从 cordis.patch.yml 提取）---
$CordisPatch = Join-Path $ProfileDir "cordis.patch.yml"
if (Test-Path $CordisPatch) {
    $content = Get-Content $CordisPatch -Raw
    $mcps = @("cloakbrowser", "anki", "bilibili", "code-runner")
    foreach ($m in $mcps) {
        # 简单提取：匹配 serverName: xxx 所在的 insert 块
        if ($content -match "(?s)(- id: mcp-client-$m.*?)(?=- id:|\z)") {
            $block = $matches[1]
            # 脱敏：去掉本机绝对路径，换成 {NPX_CMD}
            $block = $block -replace "'C:\\[^']*?npx\.cmd'", "'{NPX_CMD}'"
            $out = Join-Path $RepoRoot "mcp\$m.yml"
            [System.IO.File]::WriteAllText($out, $block, [System.Text.UTF8Encoding]::new($false))
            Write-Host "✅ 导出 mcp/$m.yml"
        } else {
            Write-Host "⏭️  mcp/$m 未在 cordis.patch.yml 中找到，跳过"
        }
    }
} else {
    Write-Host "❌ 未找到 cordis.patch.yml" -ForegroundColor Red
}

# --- 2. 导出 Skills（复制到仓库）---
$SkillSrc = Join-Path $DshHome "skills"
$SkillDest = Join-Path $RepoRoot "skills"
if (Test-Path $SkillSrc) {
    Get-ChildItem $SkillSrc -Directory | ForEach-Object {
        $name = $_.Name
        $dest = Join-Path $SkillDest $name
        if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
        Copy-Item $_.FullName $dest -Recurse
        Write-Host "✅ 导出 skills/$name"
    }
} else {
    Write-Host "❌ 未找到 skills 目录: $SkillSrc" -ForegroundColor Red
}

# --- 3. 密钥安全检查 ---
$leaks = Get-ChildItem $RepoRoot -Recurse -File -ErrorAction SilentlyContinue |
    Select-String -Pattern "sk-[a-zA-Z0-9]{20,}|apiKey\s*:\s*['""]?sk-" -ErrorAction SilentlyContinue
if ($leaks) {
    Write-Host ""
    Write-Host "⚠️  检测到疑似密钥，导出文件已含敏感信息！" -ForegroundColor Red
    $leaks | ForEach-Object { Write-Host "  $($_.Path):$($_.LineNumber)" -ForegroundColor Red }
    Write-Host "请手动清理后再提交" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "✅ 导出完成，无密钥泄露" -ForegroundColor Green
}
Write-Host "✅ 完成！请检查后提交到仓库" -ForegroundColor Green