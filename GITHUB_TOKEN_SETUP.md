# GitHub个人访问令牌设置指南

## 步骤1: 生成个人访问令牌

### 1.1 访问GitHub设置页面
1. 登录GitHub账号
2. 点击右上角头像
3. 选择 "Settings"

### 1.2 进入开发者设置
1. 在左侧菜单中点击 "Developer settings"
2. 点击 "Personal access tokens"
3. 选择 "Tokens (classic)"

### 1.3 生成新令牌
1. 点击 "Generate new token (classic)"
2. 填写令牌信息：
   - **Note**: `ClimatePolicyABM_Clean Access`
   - **Expiration**: 选择 `90 days`
   - **Scopes**: 勾选 `repo` (完整仓库访问权限)
3. 点击 "Generate token"

### 1.4 保存令牌
**重要**: 令牌只显示一次，请立即复制并保存到安全的地方！

## 步骤2: 配置本地Git

### 2.1 更新远程仓库URL
在命令行中运行（替换YOUR_TOKEN为您的实际令牌）：

```bash
cd "C:\Users\lenovo\Desktop\一些任务\浙江大学\鄢老师\多智能体\23年EER复现\ClimatePolicyABM_Clean"

git remote set-url origin https://YOUR_TOKEN@github.com/DCCAISSON/ClimatePolicyABM_Clean.git
```

### 2.2 推送代码到GitHub
```bash
git push -u origin master
```

## 步骤3: 验证结果

### 3.1 检查推送状态
```bash
git status
```

### 3.2 访问GitHub仓库
1. 打开浏览器访问：https://github.com/DCCAISSON/ClimatePolicyABM_Clean
2. 确认所有文件都已上传
3. 检查目录结构是否正确

## 常见问题解决

### 问题1: 认证失败
```bash
# 重新配置认证
git config --global credential.helper manager-core
```

### 问题2: 令牌过期
重新生成令牌并更新URL：
```bash
git remote set-url origin https://NEW_TOKEN@github.com/DCCAISSON/ClimatePolicyABM_Clean.git
```

### 问题3: 推送被拒绝
```bash
# 强制推送（谨慎使用）
git push -u origin master --force
```

## 完成后的验证清单

- [ ] GitHub仓库已创建
- [ ] 个人访问令牌已生成
- [ ] 远程仓库URL已更新
- [ ] 代码已成功推送
- [ ] 文件结构正确显示
- [ ] README.md文件可见

## 日常使用命令

```bash
# 提交更改
git add .
git commit -m "描述更改内容"
git push

# 拉取更新
git pull origin master

# 查看状态
git status
git log --oneline -5
```

---

**完成这些步骤后，您的项目将成功同步到GitHub！** 