@echo off
setlocal enabledelayedexpansion

REM 本地测试脚本 (Windows 版本)
REM 用于在本地环境测试补丁过程

echo 🚀 开始本地测试补丁过程...

REM 创建临时目录
set TEMP_DIR=%TEMP%\aug_cleaner_test_%RANDOM%
mkdir "%TEMP_DIR%"
echo 📁 使用临时目录: %TEMP_DIR%

cd /d "%TEMP_DIR%"

REM 1. 克隆 aug_cleaner
echo 📥 克隆 aug_cleaner 工具...
git clone https://github.com/gmh5225/aug_cleaner.git
if errorlevel 1 (
    echo ❌ 错误: 克隆 aug_cleaner 失败
    goto cleanup
)

REM 2. 下载最新的 VSIX
echo 📦 下载最新的 Augment Code VSIX...
set PUBLISHER=augmentcode
set EXTENSION_NAME=augment
set VSIX_URL=https://marketplace.visualstudio.com/_apis/public/gallery/publishers/%PUBLISHER%/vsextensions/%EXTENSION_NAME%/latest/vspackage

curl -L --compressed -o original.vsix "%VSIX_URL%"
if errorlevel 1 (
    echo ❌ 错误: 下载 VSIX 失败
    goto cleanup
)
echo ✅ VSIX 下载完成

REM 3. 解包 VSIX
echo 📂 解包 VSIX 文件...
powershell -Command "Expand-Archive -Path 'original.vsix' -DestinationPath 'unpacked_ext' -Force"
if errorlevel 1 (
    echo ❌ 错误: 解包 VSIX 失败
    goto cleanup
)

REM 4. 查找 package.json 并获取版本号
echo 🔍 获取插件版本号...
for /r unpacked_ext %%f in (package.json) do (
    set PACKAGE_JSON=%%f
    goto found_package
)
echo ❌ 错误: 找不到 package.json
goto cleanup

:found_package
echo 📋 找到 package.json: %PACKAGE_JSON%

REM 使用 PowerShell 提取版本号
for /f "delims=" %%i in ('powershell -Command "(Get-Content '%PACKAGE_JSON%' | ConvertFrom-Json).version"') do set VERSION=%%i
echo 📋 发现版本: %VERSION%

REM 5. 查找 extension.js
echo 🔍 查找 extension.js 文件...
for /r unpacked_ext %%f in (extension.js) do (
    echo %%f | findstr /i "out" >nul
    if not errorlevel 1 (
        set EXTENSION_JS=%%f
        goto found_extension
    )
)
echo ❌ 错误: 找不到 extension.js
goto cleanup

:found_extension
echo 📄 找到文件: %EXTENSION_JS%

REM 6. 检查 Python 版本并应用补丁
echo 🐍 检查 Python 版本...
python --version
if errorlevel 1 (
    echo ❌ 错误: 未找到 Python
    echo 💡 请安装 Python 3.6+ 并确保添加到 PATH
    goto cleanup
)

REM 检查 Python 版本是否满足要求
python -c "import sys; exit(0 if sys.version_info >= (3, 6) else 1)"
if errorlevel 1 (
    echo ❌ 错误: Python 版本不满足要求 (需要 3.6+)
    python -c "import sys; print(f'当前版本: {sys.version}')"
    goto cleanup
)
echo ✅ Python 版本满足要求 (需要 3.6+)

echo 🛠️ 使用 aug_cleaner 应用补丁...
python aug_cleaner\aug_cleaner.py "%EXTENSION_JS%" "%EXTENSION_JS%.patched"
if errorlevel 1 (
    echo ❌ 错误: 应用补丁失败
    goto cleanup
)

REM 替换原文件
move "%EXTENSION_JS%.patched" "%EXTENSION_JS%"
echo ✅ 补丁应用成功

REM 7. 显示文件大小
echo 📊 文件信息:
for %%f in ("%EXTENSION_JS%") do echo 文件大小: %%~zf bytes

REM 8. 检查是否安装了 vsce
where vsce >nul 2>&1
if errorlevel 1 (
    echo ⚠️ 未安装 vsce，跳过重新打包步骤
    echo 💡 要安装 vsce: npm install -g @vscode/vsce
    goto success
)

echo 📦 重新打包 VSIX...
for %%f in ("%PACKAGE_JSON%") do set EXTENSION_DIR=%%~dpf
cd /d "%EXTENSION_DIR%"

REM 创建 .vscodeignore
(
echo node_modules/
echo .git/
echo .gitignore
echo *.md
echo .vscode/
echo test/
echo src/
echo tsconfig.json
echo webpack.config.js
) > .vscodeignore

set PATCHED_VSIX_NAME=augmentcode.augment-%VERSION%-patched.vsix
vsce package --out "..\%PATCHED_VSIX_NAME%"
if errorlevel 1 (
    echo ❌ 错误: 重新打包失败
    goto cleanup
)

echo ✅ 补丁版本已创建: %PATCHED_VSIX_NAME%
echo 📍 文件位置: %CD%\..\%PATCHED_VSIX_NAME%

:success
echo 🎉 本地测试完成！
echo 📋 版本: %VERSION%
echo 📁 临时目录: %TEMP_DIR%

:cleanup
echo 🧹 清理临时文件...
cd /d "%~dp0"
rmdir /s /q "%TEMP_DIR%" 2>nul

pause
endlocal
