# GitHub版本控制设置指南

## 快速开始

### 1. 在MATLAB中运行Git设置
```matlab
cd('C:\Users\lenovo\Desktop\一些任务\浙江大学\鄢老师\多智能体\23年EER复现\ClimatePolicyABM_Clean');
setup_git_and_github();
```

### 2. 在GitHub上创建仓库
1. 访问 https://github.com/DCCAISSON
2. 点击 "New repository"
3. 仓库名: `ClimatePolicyABM_Clean`
4. 选择 Public
5. **不要**勾选README、.gitignore、license
6. 点击 "Create repository"

### 3. 配置认证
```bash
# 使用个人访问令牌
git remote set-url origin https://YOUR_TOKEN@github.com/DCCAISSON/ClimatePolicyABM_Clean.git
```

### 4. 推送代码
```bash
git push -u origin main
```

## 详细步骤

### 本地Git设置
```bash
# 初始化仓库
git init

# 配置用户信息
git config user.name "DCCAISSON"
git config user.email "your.email@example.com"

# 添加文件
git add .

# 提交
git commit -m "Initial commit: Climate Policy ABM Model v2.0-Simplified"

# 添加远程仓库
git remote add origin https://github.com/DCCAISSON/ClimatePolicyABM_Clean.git
```

### GitHub认证
1. 生成个人访问令牌
2. 配置凭据管理器
3. 推送代码到GitHub

### 日常使用
```bash
# 提交更改
git add .
git commit -m "描述更改"
git push

# 拉取更新
git pull origin main
```

完成设置后，您的项目将具备完整的版本控制功能。 