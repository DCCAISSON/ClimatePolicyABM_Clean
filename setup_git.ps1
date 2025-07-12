# Version: 2.0-Simplified | Git and GitHub Setup Script
# 设置Git版本控制并同步到GitHub仓库

Write-Host "=== Git版本控制和GitHub同步设置 ===" -ForegroundColor Green

# 检查当前目录
$currentDir = Get-Location
Write-Host "当前工作目录: $currentDir" -ForegroundColor Yellow

# 检查是否在正确的项目目录
if (-not $currentDir.Path.Contains("ClimatePolicyABM_Clean")) {
    Write-Host "错误: 请在ClimatePolicyABM_Clean目录中运行此脚本" -ForegroundColor Red
    exit 1
}

# 步骤1: 初始化Git仓库
Write-Host "`n步骤1: 初始化Git仓库..." -ForegroundColor Cyan
try {
    git init
    Write-Host "  ✓ Git仓库初始化完成" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Git初始化失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 步骤2: 配置Git用户信息
Write-Host "`n步骤2: 配置Git用户信息..." -ForegroundColor Cyan
try {
    # 设置用户名和邮箱（请根据实际情况修改）
    git config user.name "DCCAISSON"
    git config user.email "your.email@example.com"
    Write-Host "  ✓ Git用户信息配置完成" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Git配置失败: $($_.Exception.Message)" -ForegroundColor Red
}

# 步骤3: 添加所有文件到Git
Write-Host "`n步骤3: 添加文件到Git..." -ForegroundColor Cyan
try {
    git add .
    Write-Host "  ✓ 所有文件已添加到Git暂存区" -ForegroundColor Green
} catch {
    Write-Host "  ✗ 添加文件失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 步骤4: 创建初始提交
Write-Host "`n步骤4: 创建初始提交..." -ForegroundColor Cyan
try {
    $commitMessage = "Initial commit: Climate Policy ABM Model v2.0-Simplified"
    git commit -m $commitMessage
    Write-Host "  ✓ 初始提交完成" -ForegroundColor Green
} catch {
    Write-Host "  ✗ 提交失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 步骤5: 添加GitHub远程仓库
Write-Host "`n步骤5: 配置GitHub远程仓库..." -ForegroundColor Cyan
try {
    $remoteUrl = "https://github.com/DCCAISSON/ClimatePolicyABM_Clean.git"
    git remote add origin $remoteUrl
    Write-Host "  ✓ 远程仓库配置完成: $remoteUrl" -ForegroundColor Green
} catch {
    Write-Host "  ✗ 远程仓库配置失败: $($_.Exception.Message)" -ForegroundColor Red
}

# 步骤6: 显示Git状态
Write-Host "`n当前Git状态:" -ForegroundColor Cyan
git status

Write-Host "`n=== 设置完成 ===" -ForegroundColor Green
Write-Host "下一步操作:" -ForegroundColor Yellow
Write-Host "1. 访问 https://github.com/DCCAISSON" -ForegroundColor White
Write-Host "2. 创建新仓库: ClimatePolicyABM_Clean" -ForegroundColor White
Write-Host "3. 不要初始化README、.gitignore或license" -ForegroundColor White
Write-Host "4. 配置GitHub认证（个人访问令牌或SSH密钥）" -ForegroundColor White
Write-Host "5. 然后运行: git push -u origin main" -ForegroundColor White

# 检查GitHub仓库连接
Write-Host "`n检查GitHub仓库连接..." -ForegroundColor Cyan
try {
    $result = git ls-remote origin 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ GitHub仓库连接正常" -ForegroundColor Green
    } else {
        Write-Host "  ✗ 无法连接到GitHub仓库，请先创建仓库" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ 检查失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n完成！请按照上述步骤在GitHub上创建仓库并推送代码。" -ForegroundColor Green 