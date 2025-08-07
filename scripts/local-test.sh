#!/bin/bash

# 本地测试脚本
# 用于在本地环境测试补丁过程

set -e

echo "🚀 开始本地测试补丁过程..."

# 创建临时目录
TEMP_DIR=$(mktemp -d)
echo "📁 使用临时目录: $TEMP_DIR"

# 清理函数
cleanup() {
    echo "🧹 清理临时文件..."
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

cd "$TEMP_DIR"

# 1. 克隆 aug_cleaner
echo "📥 克隆 aug_cleaner 工具..."
git clone https://github.com/gmh5225/aug_cleaner.git

# 2. 下载最新的 VSIX
echo "📦 下载最新的 Augment Code VSIX..."
PUBLISHER="augment"
EXTENSION_NAME="vscode-augment"
VSIX_URL="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${PUBLISHER}/vsextensions/${EXTENSION_NAME}/latest/vspackage"

echo "🌐 下载地址: ${VSIX_URL}"

# 使用改进的下载参数
curl -L \
  --fail \
  --retry 3 \
  --retry-delay 5 \
  --max-time 300 \
  --user-agent "Mozilla/5.0 (compatible; Local-Test)" \
  --header "Accept: application/octet-stream, */*" \
  --output original.vsix \
  "${VSIX_URL}"

if [ $? -ne 0 ]; then
    echo "❌ 错误: VSIX 下载失败"
    exit 1
fi

echo "✅ VSIX 下载完成"

# 验证文件
echo "📋 文件信息:"
ls -la original.vsix
file original.vsix

# 检查是否为有效的 ZIP 文件
if ! file original.vsix | grep -q "Zip\|ZIP"; then
    echo "❌ 错误: 下载的文件不是有效的 ZIP/VSIX 文件"
    echo "文件内容预览:"
    head -20 original.vsix
    exit 1
fi

# 3. 解包 VSIX
echo "📂 解包 VSIX 文件..."

# 测试 ZIP 文件完整性
if ! unzip -t original.vsix > /dev/null 2>&1; then
    echo "❌ 错误: VSIX 文件损坏或不是有效的 ZIP 文件"
    echo "文件大小: $(stat -f%z original.vsix 2>/dev/null || stat -c%s original.vsix) bytes"
    echo "文件类型: $(file original.vsix)"
    exit 1
fi

unzip -q original.vsix -d unpacked_ext

# 4. 获取版本号
echo "🔍 获取插件版本号..."
PACKAGE_JSON=$(find unpacked_ext -name "package.json" -type f | head -1)
if [ -z "$PACKAGE_JSON" ]; then
    echo "❌ 错误: 找不到 package.json"
    exit 1
fi

VERSION=$(jq -r .version "$PACKAGE_JSON")
echo "📋 发现版本: $VERSION"

# 5. 查找 extension.js
echo "🔍 查找 extension.js 文件..."
EXTENSION_JS=$(find unpacked_ext -name "extension.js" -path "*/out/*" | head -1)
if [ -z "$EXTENSION_JS" ]; then
    echo "❌ 错误: 找不到 extension.js"
    exit 1
fi
echo "📄 找到文件: $EXTENSION_JS"

# 6. 检查 Python 版本并应用补丁
echo "🐍 检查 Python 版本..."
PYTHON_VERSION=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
echo "发现 Python 版本: $PYTHON_VERSION"

# 检查是否满足 Python 3.6+ 要求
if python3 -c "import sys; exit(0 if sys.version_info >= (3, 6) else 1)"; then
    echo "✅ Python 版本满足要求 (需要 3.6+)"
else
    echo "❌ 错误: Python 版本不满足要求 (需要 3.6+，当前: $PYTHON_VERSION)"
    exit 1
fi

echo "🛠️ 使用 aug_cleaner 应用补丁..."
python3 aug_cleaner/aug_cleaner.py "$EXTENSION_JS" "${EXTENSION_JS}.patched"

# 替换原文件
mv "${EXTENSION_JS}.patched" "$EXTENSION_JS"
echo "✅ 补丁应用成功"

# 7. 显示文件大小对比
echo "📊 文件大小对比:"
echo "原始文件大小: $(stat -f%z "$EXTENSION_JS" 2>/dev/null || stat -c%s "$EXTENSION_JS") bytes"

# 8. 检查是否安装了 vsce
if command -v vsce &> /dev/null; then
    echo "📦 重新打包 VSIX..."
    EXTENSION_DIR=$(dirname "$PACKAGE_JSON")
    cd "$EXTENSION_DIR"
    
    # 创建 .vscodeignore
    cat > .vscodeignore << EOF
node_modules/
.git/
.gitignore
*.md
.vscode/
test/
src/
tsconfig.json
webpack.config.js
EOF
    
    PATCHED_VSIX_NAME="augment.vscode-augment-${VERSION}-patched.vsix"
    vsce package --out "../${PATCHED_VSIX_NAME}"
    
    echo "✅ 补丁版本已创建: ${PATCHED_VSIX_NAME}"
    echo "📍 文件位置: $(pwd)/../${PATCHED_VSIX_NAME}"
else
    echo "⚠️ 未安装 vsce，跳过重新打包步骤"
    echo "💡 要安装 vsce: npm install -g @vscode/vsce"
fi

echo "🎉 本地测试完成！"
echo "📋 版本: $VERSION"
echo "📁 临时目录: $TEMP_DIR (将在脚本结束时清理)"
