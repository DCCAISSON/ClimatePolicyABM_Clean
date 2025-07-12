# 文档同步机制使用指南

## 📋 概述

本文档介绍ClimatePolicyABM_Clean项目的文档与代码同步机制，包括自动更新README.md和GitHub同步功能。

## 🎯 功能特性

### 1. 自动文档同步
- **智能体类型验证**：自动检查所有智能体文件是否存在
- **市场模块验证**：验证市场模块的完整性
- **代码结构扫描**：扫描当前代码结构并更新文档
- **备份机制**：自动备份原README.md文件

### 2. GitHub自动同步
- **自动提交**：检测更改并自动提交到Git
- **自动推送**：推送到GitHub远程仓库
- **状态检查**：检查Git状态和远程仓库配置
- **错误处理**：完善的错误处理和回滚机制

## 🚀 快速开始

### 基本使用

#### 1. 同步文档与代码结构
```matlab
% 运行文档同步
sync_documentation();
```

#### 2. 自动同步并推送到GitHub
```matlab
% 使用默认提交信息
auto_sync_and_push();

% 使用自定义提交信息
auto_sync_and_push('Update documentation with new agent types');
```

#### 3. 快速同步（推荐）
```matlab
% 快速同步，使用时间戳作为提交信息
quick_sync_and_push();
```

#### 4. 交互式同步
```matlab
% 交互式输入提交信息
sync_with_custom_message();
```

### 高级功能

#### 1. 检查同步状态
```matlab
% 检查当前同步状态
check_sync_status();
```

#### 2. 仅同步文档（不推送）
```matlab
% 仅更新文档，不进行Git操作
sync_documentation();
```

## 📊 同步机制详解

### 1. 智能体类型验证

系统会自动验证以下智能体类型：

#### 企业智能体（7类）
- `PesticideEnterpriseAgent` - 农药企业
- `FertilizerEnterpriseAgent` - 化肥企业
- `AgroProcessingEnterpriseAgent` - 农产品加工企业
- `GrainFarmAgent` - 粮食作物生产企业
- `CashCropFarmAgent` - 经济作物生产企业
- `MixedCropFarmAgent` - 混合作物生产企业
- `AgriculturalServiceEnterpriseAgent` - 农业服务企业

#### 农户智能体（2类）
- `HouseholdAgent` - 传统农户
- `FarmerAgentWithExpectations` - 带预期的农户

#### 政府智能体（2类）
- `GovernmentAgent` - 基础政府智能体
- `GovernmentAgentWithExpectations` - 带预期的政府智能体

#### 劳动力市场智能体（2类）
- `LaborSupplierAgent` - 劳动力供给方
- `LaborDemanderAgent` - 劳动力需求方

### 2. 市场模块验证

系统会验证以下市场模块：

- `PesticideMarketModule` - 农药市场
- `FertilizerMarketModule` - 化肥市场
- `CommodityMarketModule` - 商品市场
- `LandMarketModule` - 土地市场
- `LaborMarketModule` - 劳动力市场
- `InputMarketModule` - 投入品市场
- `SimplifiedLaborMarket` - 简化劳动力市场

### 3. 文档更新内容

同步机制会自动更新以下内容：

#### README.md更新
- **智能体架构部分**：更新智能体类型列表
- **市场模块部分**：更新市场模块描述
- **系统架构部分**：更新当前代码结构
- **使用指南部分**：更新代码示例

#### 生成同步报告
- **代码结构统计**：文件数量和类型统计
- **验证结果**：智能体和模块验证结果
- **同步状态**：同步完成状态和时间戳

## 🔧 配置选项

### 1. 自定义验证规则

可以修改`sync_documentation.m`中的验证规则：

```matlab
% 在validate_agent_types()函数中修改预期智能体列表
expected_agents = {
    'PesticideEnterpriseAgent',
    'FertilizerEnterpriseAgent',
    % ... 添加或删除智能体类型
};
```

### 2. 自定义模块描述

可以修改模块描述映射：

```matlab
% 在get_module_description()函数中修改描述
descriptions.PesticideMarketModule = '自定义描述';
```

### 3. Git配置

确保Git配置正确：

```bash
# 设置用户信息
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 设置远程仓库
git remote add origin https://github.com/DCCAISSON/ClimatePolicyABM_Clean.git
```

## 📈 工作流程

### 日常开发流程

1. **开发新功能**
   ```matlab
   % 添加新的智能体或模块
   % 修改现有代码
   ```

2. **同步文档**
   ```matlab
   % 运行文档同步
   quick_sync_and_push();
   ```

3. **验证更新**
   ```matlab
   % 检查同步状态
   check_sync_status();
   ```

### 版本发布流程

1. **准备发布**
   ```matlab
   % 确保所有更改已提交
   check_sync_status();
   ```

2. **同步文档**
   ```matlab
   % 使用发布信息同步
   auto_sync_and_push('Release v2.0 - Enhanced agent heterogeneity');
   ```

3. **验证发布**
   - 检查GitHub仓库更新
   - 验证README.md内容
   - 确认所有文档同步

## 🛠️ 故障排除

### 常见问题

#### 1. Git状态检查失败
```matlab
% 错误：无法检查Git状态
% 解决方案：
% 1. 确保在Git仓库目录中
% 2. 检查Git是否正确安装
% 3. 验证Git配置
```

#### 2. 推送失败
```matlab
% 错误：推送失败
% 解决方案：
% 1. 检查网络连接
% 2. 验证GitHub访问令牌
% 3. 确认远程仓库配置
```

#### 3. 文档更新失败
```matlab
% 错误：无法更新README.md
% 解决方案：
% 1. 检查文件权限
% 2. 确保docs目录存在
% 3. 验证文件路径
```

### 调试模式

启用详细日志输出：

```matlab
% 在sync_documentation()函数中添加调试信息
fprintf('调试信息: 正在处理文件 %s\n', file_path);
```

## 📋 最佳实践

### 1. 定期同步
- 每次添加新智能体后立即同步
- 每周至少运行一次完整同步
- 发布前必须同步文档

### 2. 提交信息规范
- 使用描述性的提交信息
- 包含版本号和主要更改
- 遵循约定式提交格式

### 3. 备份策略
- 同步前自动备份原文档
- 保留历史版本
- 定期检查备份完整性

### 4. 团队协作
- 团队成员使用相同的同步流程
- 统一提交信息格式
- 定期审查同步报告

## 📞 技术支持

### 联系信息
- **开发团队**：多智能体建模研究组
- **邮箱**：research@abm-climate.org
- **GitHub**：https://github.com/DCCAISSON/ClimatePolicyABM_Clean

### 问题反馈
如果遇到问题，请：
1. 检查本文档的故障排除部分
2. 查看生成的同步报告
3. 提交GitHub Issue
4. 联系开发团队

---

*最后更新时间：2024年12月* | *版本：2.0-Simplified* 