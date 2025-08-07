# 使用指南

## 快速开始

### 1. Fork 这个仓库
点击右上角的 "Fork" 按钮，将这个仓库 fork 到你的 GitHub 账户。

### 2. 启用 GitHub Actions
1. 进入你 fork 的仓库
2. 点击 "Actions" 标签页
3. 如果看到提示，点击 "I understand my workflows, go ahead and enable them"

### 3. 手动触发第一次构建
1. 在 Actions 页面，选择 "Build Patched Augment Code Extension with aug_cleaner"
2. 点击 "Run workflow" 按钮
3. 等待构建完成

### 4. 下载和安装
1. 构建完成后，进入 "Releases" 页面
2. 下载最新的 `.vsix` 文件
3. 在 VS Code 中安装：
   - 按 `Ctrl+Shift+X` 打开扩展视图
   - 点击 "..." 菜单 → "Install from VSIX..."
   - 选择下载的文件

## 自动化构建

### 定时构建
工作流会在每天 UTC 8:00 自动运行，检查是否有新版本的 Augment Code 插件。

### 版本管理
- 只有当检测到新版本时才会创建新的 Release
- 版本标签格式：`v{版本号}-patched`
- 如果版本已存在，会跳过构建过程

## 本地测试

### 前置要求
- Python 3.6+ (推荐 3.9+)
- Git
- curl/wget
- unzip
- Node.js (如果需要重新打包)

### Linux/macOS
```bash
chmod +x scripts/local-test.sh
./scripts/local-test.sh
```

### Windows
```cmd
scripts\local-test.bat
```

**注意**: 本地测试脚本会自动检查 Python 版本是否满足 aug_cleaner 的要求 (3.6+)。

## 自定义配置

### 配置文件
项目包含一个配置文件 `config/workflow-config.yml`，包含了所有可自定义的选项：

```yaml
# Augment Code 插件信息
extension:
  publisher: "augment"
  name: "vscode-augment"

# 构建配置
build:
  schedule: "0 8 * * *"  # 定时任务
  python_version: "3.9"  # Python 版本
  node_version: "20"     # Node.js 版本
```

### 修改定时任务
编辑 `.github/workflows/build-patched-extension.yml` 文件中的 cron 表达式：
```yaml
schedule:
  - cron: '0 8 * * *'  # 每天 UTC 8:00
```

### 修改插件信息
如果需要处理其他插件，修改工作流中的变量：
```yaml
PUBLISHER="augment"
EXTENSION_NAME="vscode-augment"
```

## 故障排除

### 构建失败
1. 检查 Actions 页面的构建日志
2. 确认 aug_cleaner 仓库是否可访问
3. 检查 VS Code Marketplace 是否可访问

### 版本检测问题
如果版本检测出现问题，可能是因为：
- package.json 文件位置发生变化
- 版本字段格式发生变化

### 重新构建已存在的版本
1. 进入 Releases 页面，删除对应的 Release
2. 使用 Git 命令删除对应的标签：
   ```bash
   git tag -d v{版本号}-patched
   git push origin :refs/tags/v{版本号}-patched
   ```
3. 手动触发工作流

## 高级用法

### 修改补丁逻辑
如果需要自定义补丁逻辑，可以：
1. Fork aug_cleaner 仓库
2. 修改补丁逻辑
3. 更新工作流中的 aug_cleaner 仓库地址

### 添加额外的处理步骤
在工作流的 "Apply patch with aug_cleaner" 步骤后添加自定义处理逻辑。

### 自定义发布信息
修改工作流中的 Release 创建步骤，自定义发布说明和标签。

## 安全注意事项

- 这个工具会修改第三方插件的代码
- 请确保你理解补丁的作用
- 建议在隔离环境中测试补丁版本
- 定期检查原始插件的更新和安全公告

## 支持

如果遇到问题：
1. 查看 [Issues](../../issues) 页面是否有类似问题
2. 创建新的 Issue 并提供详细信息
3. 包含构建日志和错误信息
