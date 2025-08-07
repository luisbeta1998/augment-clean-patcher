# 故障排除指南

## VSIX 下载和解包问题

### 问题 1: "End-of-central-directory signature not found"

**错误信息:**
```
End-of-central-directory signature not found. Either this file is not
a zipfile, or it constitutes one disk of a multi-part archive.
```

**原因:**
- 下载的文件不是有效的 ZIP/VSIX 文件
- 可能下载了 HTML 重定向页面而不是实际文件
- 网络问题导致文件下载不完整

**解决方案:**
1. 检查网络连接
2. 手动验证下载 URL
3. 使用改进的下载参数（已在最新版本中实现）

### 问题 2: VSIX 下载失败

**可能原因:**
- VS Code Marketplace API 变更
- 网络连接问题
- 插件名称或发布者名称错误

**解决步骤:**
1. **验证插件信息:**
   ```bash
   # 检查插件是否存在
   curl -s "https://marketplace.visualstudio.com/items?itemName=augmentcode.augment"
   ```

2. **手动下载测试:**
   ```bash
   # 直接访问 API
   curl -I "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/augmentcode/vsextensions/augment/latest/vspackage"
   ```

3. **检查响应头:**
   - 确认返回的是 `application/octet-stream`
   - 检查是否有重定向

### 问题 3: 插件结构发生变化

**错误信息:**
```
Error: extension.js not found in unpacked VSIX
```

**解决方案:**
1. **检查解包结构:**
   ```bash
   find unpacked_ext -name "*.js" -type f
   find unpacked_ext -name "package.json" -type f
   ```

2. **更新查找逻辑:**
   如果插件结构发生变化，可能需要更新工作流中的文件查找逻辑。

### 问题 4: Python 版本不兼容

**错误信息:**
```
Python version does not meet requirements
```

**解决方案:**
1. **检查 Python 版本:**
   ```bash
   python --version
   python3 --version
   ```

2. **安装正确版本:**
   - 确保安装 Python 3.6 或更高版本
   - 在 GitHub Actions 中已固定为 Python 3.9

### 问题 5: aug_cleaner 工具问题

**可能问题:**
- aug_cleaner 仓库不可访问
- 工具本身有 bug
- 输入文件格式不支持

**调试步骤:**
1. **手动测试 aug_cleaner:**
   ```bash
   git clone https://github.com/gmh5225/aug_cleaner.git
   python aug_cleaner/aug_cleaner.py --help
   ```

2. **检查输入文件:**
   ```bash
   file extension.js
   head -20 extension.js
   ```

## 网络相关问题

### 代理和防火墙

如果在企业网络环境中运行：

1. **配置代理:**
   ```bash
   export https_proxy=http://proxy.company.com:8080
   export http_proxy=http://proxy.company.com:8080
   ```

2. **GitHub Actions 中的网络问题:**
   - GitHub Actions 运行器通常有良好的网络连接
   - 如果仍有问题，可能是目标服务的问题

### DNS 解析问题

1. **测试 DNS:**
   ```bash
   nslookup marketplace.visualstudio.com
   ```

2. **使用备用 DNS:**
   ```bash
   # 临时使用 Google DNS
   echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
   ```

## 权限问题

### GitHub Actions 权限

确保工作流有正确的权限：

```yaml
permissions:
  contents: write  # 创建 Release 需要
  actions: read    # 读取 Actions 状态
```

### 本地权限问题

1. **文件权限:**
   ```bash
   chmod +x scripts/local-test.sh
   ```

2. **目录权限:**
   ```bash
   # 确保有写入权限
   ls -la /tmp
   ```

## 调试技巧

### 启用详细日志

1. **在工作流中添加调试:**
   ```yaml
   - name: Debug step
     run: |
       set -x  # 启用命令跟踪
       # 你的命令
   ```

2. **本地调试:**
   ```bash
   # 启用 bash 调试模式
   bash -x scripts/local-test.sh
   ```

### 保留临时文件

修改脚本以保留临时文件进行检查：

```bash
# 注释掉清理步骤
# rm -rf "$TEMP_DIR"
echo "临时文件保留在: $TEMP_DIR"
```

## 获取帮助

如果问题仍然存在：

1. **创建 Issue:**
   - 包含完整的错误日志
   - 说明运行环境
   - 提供复现步骤

2. **提供信息:**
   - 操作系统版本
   - Python 版本
   - 网络环境
   - 错误发生的具体步骤

3. **检查已知问题:**
   - 查看 [Issues](../../issues) 页面
   - 搜索类似问题的解决方案
