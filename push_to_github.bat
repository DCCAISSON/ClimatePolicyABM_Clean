@echo off
REM 推送到GitHub脚本
REM 请将YOUR_TOKEN替换为您的实际GitHub个人访问令牌

echo === 推送到GitHub ===
echo.

REM 检查是否在正确的目录
if not exist "+core" (
    echo 错误: 请在ClimatePolicyABM_Clean目录中运行此脚本
    pause
    exit /b 1
)

echo 当前目录: %CD%
echo.

REM 请在这里替换YOUR_TOKEN为您的实际令牌
set GITHUB_TOKEN=YOUR_TOKEN

if "%GITHUB_TOKEN%"=="YOUR_TOKEN" (
    echo 请先编辑此脚本，将YOUR_TOKEN替换为您的GitHub个人访问令牌
    echo.
    echo 获取令牌步骤:
    echo 1. 访问 https://github.com/settings/tokens
    echo 2. 点击 "Generate new token (classic)"
    echo 3. Note: ClimatePolicyABM_Clean Access
    echo 4. Expiration: 90 days
    echo 5. Scopes: 勾选 repo
    echo 6. 复制生成的令牌
    echo 7. 替换此脚本中的YOUR_TOKEN
    echo.
    pause
    exit /b 1
)

echo 配置远程仓库URL...
git remote set-url origin https://%GITHUB_TOKEN%@github.com/DCCAISSON/ClimatePolicyABM_Clean.git

echo.
echo 推送到GitHub...
git push -u origin master

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ 推送成功！
    echo 请访问: https://github.com/DCCAISSON/ClimatePolicyABM_Clean
    echo 确认所有文件都已上传
) else (
    echo.
    echo ✗ 推送失败，请检查:
    echo 1. 令牌是否正确
    echo 2. 网络连接是否正常
    echo 3. GitHub仓库是否存在
)

echo.
pause 