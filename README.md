# Augment Clean Patcher

基于 [aug_cleaner](https://github.com/gmh5225/aug_cleaner) 工具的 VS Code Augment 插件自动打包仓库。

## 功能特性

- 🤖 **自动化构建**: 每日自动检查 Augment Code 插件的新版本
- 🛠️ **智能补丁**: 使用 aug_cleaner Python 工具自动应用补丁
- 📦 **自动打包**: 自动重新打包为 VSIX 文件
- 🚀 **自动发布**: 自动创建 GitHub Release 并上传补丁版本
- 🔄 **版本管理**: 智能检测版本变化，避免重复构建

## 工作流程

1. **检出代码**: 获取 aug_cleaner 工具的最新代码
2. **下载插件**: 从 VS Code Marketplace 下载最新的 Augment Code VSIX 插件
3. **解包处理**: 解压 VSIX 文件并定位核心 JavaScript 文件
4. **应用补丁**: 使用 aug_cleaner.py 工具处理插件文件
5. **重新打包**: 使用 vsce 工具重新打包为 VSIX 文件
6. **版本发布**: 创建 GitHub Release 并上传补丁版本

## 触发方式

### 自动触发
- **定时任务**: 每天 UTC 时间 8:00 自动运行
- **代码更新**: 当工作流文件更新时自动运行

### 手动触发
1. 进入 GitHub 仓库的 Actions 页面
2. 选择 "Build Patched Augment Code Extension with aug_cleaner" 工作流
3. 点击 "Run workflow" 按钮

## 安装使用

### 下载补丁版本
1. 访问本仓库的 [Releases 页面](../../releases)
2. 下载最新的 `.vsix` 文件

### 安装到 VS Code
1. 打开 VS Code
2. 按 `Ctrl+Shift+X` 打开扩展视图
3. 点击右上角的 "..." 菜单
4. 选择 "Install from VSIX..."
5. 选择下载的 `.vsix` 文件

## 版本说明

- **标签格式**: `v{原版本号}-patched`
- **文件命名**: `augmentcode.augment-{版本号}-patched.vsix`
- **版本检测**: 自动检测新版本，避免重复构建相同版本

## 补丁内容

本项目使用 [aug_cleaner](https://github.com/gmh5225/aug_cleaner) 工具对 Augment Code 插件进行处理，主要功能包括：
- 移除遥测和跟踪功能
- 清理不必要的网络请求
- 优化插件性能

## 技术细节

### 依赖工具
- **aug_cleaner**: Python 补丁工具 (要求 Python 3.6+)
- **@vscode/vsce**: VS Code 插件打包工具
- **Node.js**: 运行环境
- **Python 3.9**: 用于运行 aug_cleaner (满足 3.6+ 要求)
- **jq**: JSON 处理工具

### 工作流特性
- 智能版本检测，避免重复构建
- 自动查找插件核心文件
- 完整的错误处理和日志记录
- 自动清理临时文件

## 故障排除

### 常见问题

**Q: 工作流失败，提示找不到 extension.js**
A: 这可能是因为插件结构发生变化。工作流会自动查找 `*/out/extension.js` 文件。

**Q: 版本已存在，如何重新构建？**
A: 删除对应的 Git 标签和 Release，工作流会自动重新构建。

**Q: 如何查看构建日志？**
A: 进入 Actions 页面，点击对应的工作流运行记录查看详细日志。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 许可证

本项目遵循 MIT 许可证。

## 相关项目

- [aug_cleaner](https://github.com/gmh5225/aug_cleaner) - Python 补丁工具
- [Augment Code](https://marketplace.visualstudio.com/items?itemName=augmentcode.augment) - 原始插件
