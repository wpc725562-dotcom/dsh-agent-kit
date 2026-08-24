# ============================================================
# dsh-agent-kit 校验脚本
# 检查仓库结构与配置完整性
# 用法: powershell -File scripts/verify.ps1
# ============================================================
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$pass = 0; $fail = 0

function Check($name, $cond) {
    if ($cond) { Write-Host "✅ $name" -ForegroundColor Green; $script:pass++ }
    else { Write-Host "❌ $name" -ForegroundColor Red; $script:fail++ }
}

Write-Host "=== dsh-agent-kit 结构校验 ===" -ForegroundColor Cyan

# 目录存在
foreach ($d in @("mcp", "skills", "presets", "scripts", "docs", ".github/workflows")) {
    Check "目录 $d" (Test-Path (Join-Path $RepoRoot $d))
}

# MCP 配置
Check "MCP: cloakbrowser.yml" (Test-Path (Join-Path $RepoRoot "mcp\cloakbrowser.yml"))
Check "MCP: anki.yml" (Test-Path (Join-Path $RepoRoot "mcp\anki.yml"))
Check "MCP: bilibili.yml" (Test-Path (Join-Path $RepoRoot "mcp\bilibili.yml"))
Check "MCP: code-runner.yml" (Test-Path (Join-Path $RepoRoot "mcp\code-runner.yml"))

# MCP 配置不含密钥
$keyLeaks = Select-String -Path (Join-Path $RepoRoot "mcp\*.yml") -Pattern "sk-[A-Za-z0-9]{20}|apiKey:" -ErrorAction SilentlyContinue
Check "MCP 无密钥泄露" (-not $keyLeaks)

# Skills
$skills = Get-ChildItem (Join-Path $RepoRoot "skills") -Directory -ErrorAction SilentlyContinue
Check "Skills 目录非空" ($skills.Count -gt 0)
foreach ($s in $skills) {
    $f = Join-Path $s.FullName "SKILL.md"
    $hasFrontmatter = (Test-Path $f) -and ((Get-Content $f -Raw) -match '^---\s*\n')
    Check "Skill: $($s.Name)/SKILL.md" $hasFrontmatter
}

# 核心文件
foreach ($f in @("README.md", "AGENTS.md", "LICENSE", ".gitignore", "scripts\install.ps1", "scripts\verify.ps1", "scripts\export.ps1")) {
    Check "文件 $f" (Test-Path (Join-Path $RepoRoot $f))
}

# 无密钥模式（检查 mcp 和 presets 配置，排除脚本自身包含搜索模式导致的 false positive）
$allLeaks = Get-ChildItem (Join-Path $RepoRoot "mcp") -Filter "*.yml" -Recurse -ErrorAction SilentlyContinue
$allLeaks += Get-ChildItem (Join-Path $RepoRoot "presets") -Filter "*.yml" -Recurse -ErrorAction SilentlyContinue
$allLeaks = $allLeaks | Select-String -Pattern "sk-[A-Za-z0-9]{20}|apiKey\s*:" -ErrorAction SilentlyContinue
Check "全库无密钥泄露" (-not $allLeaks)

# 汇总
Write-Host ""
Write-Host "==============================" -ForegroundColor Cyan
Write-Host " 通过: $pass / 失败: $fail" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Red" })
Write-Host "==============================" -ForegroundColor Cyan
exit $(if ($fail -eq 0) { 0 } else { 1 })