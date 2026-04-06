@echo off
chcp 65001 > nul
echo ========================================
echo 🚀 自动同步到 GitHub（%date% %time%）
echo ========================================

set "REPO_DIR=E:\Notes"

cd /d "%REPO_DIR%"
if %errorlevel% neq 0 (
    echo ❌ 目录不存在：%REPO_DIR%
    pause
    exit /b 1
)

git add .
git diff --cached --quiet
if %errorlevel% equ 0 (
    echo ℹ️ 无文件改动，跳过提交
) else (
    git commit -m "Auto backup: %date% %time%"
    git push origin master
    echo ✅ 推送完成
)

echo ========================================
echo 完成
echo ========================================
pause