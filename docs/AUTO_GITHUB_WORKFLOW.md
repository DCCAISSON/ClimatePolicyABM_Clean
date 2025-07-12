# 自动化GitHub工作流程指南

## 🚀 快速开始

### 方法1: 使用快速推送函数（推荐）
```matlab
% 在MATLAB中运行
quick_push('修复企业异质性计算bug');
quick_push('添加新的政策实验功能');
quick_push('更新文档');
```

### 方法2: 使用完整自动化脚本
```matlab
% 在MATLAB中运行
auto_push_to_github('详细的更改描述');
```

### 方法3: 命令行快速推送
```bash
# 在命令行中运行
git add . && git commit -m "更改描述" && git push origin master
```

## 📋 工作流程

### 1. 代码修改后自动推送
```matlab
% 修改代码后，在MATLAB中运行：
quick_push('描述您的更改');
```

### 2. 批量更改推送
```matlab
% 多个文件更改后：
auto_push_to_github('批量更新：企业模型优化和文档完善');
```

### 3. 检查推送状态
```matlab
% 检查Git状态
system('git status');

% 查看最近提交
system('git log --oneline -5');
```

## 🛠️ 使用示例

### 示例1: 修复bug后推送
```matlab
% 修复了企业决策逻辑bug
quick_push('修复企业决策逻辑bug');
```

### 示例2: 添加新功能后推送
```matlab
% 添加了新的政策实验功能
auto_push_to_github('新增政策实验模块：支持多种政策组合测试');
```

### 示例3: 更新文档后推送
```matlab
% 更新了API文档
quick_push('更新API文档和示例代码');
```

## ⚙️ 高级功能

### 1. 自定义提交信息
```matlab
% 使用自定义提交信息
auto_push_to_github('feat: 添加企业异质性分析模块');
auto_push_to_github('fix: 修复市场匹配算法精度问题');
auto_push_to_github('docs: 更新README和API文档');
```

### 2. 检查GitHub连接
```matlab
% 检查连接状态
check_github_connection();
```

### 3. 查看Git配置
```matlab
% 显示Git配置信息
show_git_info();
```

## 🔄 自动化工作流程

### 日常开发流程：
1. **修改代码** - 在MATLAB中编辑文件
2. **测试功能** - 运行相关测试
3. **快速推送** - 使用 `quick_push()` 函数
4. **验证结果** - 访问GitHub仓库确认

### 批量更新流程：
1. **多个文件修改** - 完成一组相关更改
2. **完整推送** - 使用 `auto_push_to_github()` 函数
3. **详细描述** - 提供完整的更改说明

## 📊 推送历史管理

### 查看推送历史
```bash
# 查看最近10次提交
git log --oneline -10

# 查看详细提交信息
git log --oneline --graph -5
```

### 撤销推送（如果需要）
```bash
# 撤销最后一次推送
git reset --soft HEAD~1
git push origin master --force
```

## 🎯 最佳实践

### 1. 提交信息规范
- **feat**: 新功能
- **fix**: 修复bug
- **docs**: 文档更新
- **style**: 代码格式调整
- **refactor**: 代码重构
- **test**: 测试相关

### 2. 推送频率
- **小更改**: 使用 `quick_push()`
- **大更改**: 使用 `auto_push_to_github()`
- **紧急修复**: 立即推送
- **功能开发**: 完成一个功能后推送

### 3. 错误处理
如果推送失败，检查：
1. 网络连接
2. GitHub令牌有效性
3. 远程仓库配置
4. 文件冲突

## 🆘 故障排除

### 问题1: 推送失败
```matlab
% 检查Git状态
system('git status');

% 检查远程仓库
system('git remote -v');

% 重新推送
system('git push origin master');
```

### 问题2: 认证失败
```bash
# 重新配置令牌
git remote set-url origin https://YOUR_TOKEN@github.com/DCCAISSON/ClimatePolicyABM_Clean.git
```

### 问题3: 文件冲突
```bash
# 拉取最新更改
git pull origin master

# 解决冲突后推送
git add .
git commit -m "解决冲突"
git push origin master
```

---

**使用这些自动化工具，您可以轻松保持代码与GitHub的同步！** 