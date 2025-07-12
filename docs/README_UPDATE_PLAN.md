# README.md 更新计划

## 📋 当前问题分析

### 1. 智能体类名不匹配
**问题：** README中的类名与实际文件不符
- README: `agents.PesticideEnterpriseAgent`
- 实际: `PesticideEnterpriseAgent.m`

**解决方案：** 更新README中的类名引用

### 2. 缺少预期形成机制描述
**问题：** README没有描述预期形成模块
- 缺少 `AgentWithExpectations` 基类
- 缺少 `ExpectationFormationModule` 模块
- 缺少带预期的智能体类

**解决方案：** 添加预期形成机制的详细描述

### 3. 市场模块描述不完整
**问题：** README缺少重要市场模块
- 缺少 `LaborMarketModule` 详细描述
- 缺少 `CommodityMarketModule` 描述
- 缺少 `LandMarketModule` 描述

**解决方案：** 补充市场模块的完整描述

## 🔧 更新计划

### 第一阶段：清理冗余文件
```matlab
% 运行清理脚本
cleanup_redundant_files();
```

### 第二阶段：更新README.md

#### 1. 更新智能体架构部分
```markdown
## 🏗️ 智能体架构设计

### 核心智能体类型

#### 企业智能体
- `PesticideEnterpriseAgent` - 农药企业
- `FertilizerEnterpriseAgent` - 化肥企业  
- `AgroProcessingEnterpriseAgent` - 农产品加工企业
- `GrainFarmAgent` - 粮食作物生产企业
- `CashCropFarmAgent` - 经济作物生产企业
- `MixedCropFarmAgent` - 混合作物生产企业
- `AgriculturalServiceEnterpriseAgent` - 农业服务企业

#### 农户智能体
- `HouseholdAgent` - 传统农户
- `FarmerAgentWithExpectations` - 带预期的农户

#### 政府智能体
- `GovernmentAgent` - 基础政府智能体
- `GovernmentAgentWithExpectations` - 带预期的政府智能体

#### 劳动力市场智能体
- `LaborSupplierAgent` - 劳动力供给方
- `LaborDemanderAgent` - 劳动力需求方
```

#### 2. 添加预期形成机制部分
```markdown
## 🧠 预期形成机制

### 核心模块
- `AgentWithExpectations` - 带预期功能的智能体基类
- `ExpectationFormationModule` - 预期形成模块

### 预期形成算法
```matlab
% AR(1)自适应学习机制
E_t[X_{t+h}] = α + β × X_t + γ × trend_t + ε_t
```

### 预期变量类型
- **企业预期变量**：市场需求、成本变化、政策环境
- **农户预期变量**：价格趋势、政策补贴、气候条件
- **政府预期变量**：政策效果、经济指标、社会反馈
```

#### 3. 完善市场模块描述
```markdown
## 🏪 市场模块体系

### 核心市场模块
- `PesticideMarketModule` - 农药市场（质量匹配）
- `FertilizerMarketModule` - 化肥市场
- `CommodityMarketModule` - 商品市场
- `LandMarketModule` - 土地市场
- `LaborMarketModule` - 劳动力市场
- `InputMarketModule` - 投入品市场

### 市场匹配机制
- **质量匹配**：基于产品质量的双边搜寻
- **价格发现**：动态价格调整机制
- **信息传播**：声誉和网络效应
```

### 第三阶段：更新使用示例

#### 1. 更新快速开始示例
```matlab
% 创建带预期的模型
model = core.MultiAgentClimatePolicyModel(params);

% 验证智能体类型
agent_types = cellfun(@(a) class(a), model.agents, 'UniformOutput', false);
unique_types = unique(agent_types);
```

#### 2. 添加预期形成示例
```matlab
% 预期形成实验
fprintf('=== 预期形成机制实验 ===\n');

% 创建带预期的智能体
farmer_with_expectations = agents.FarmerAgentWithExpectations(1, params);
enterprise_with_expectations = agents.EnterpriseAgentWithExpectations(1, params);

% 观察预期形成过程
for t = 1:12
    farmer_with_expectations.update_expectations(market_data, t);
    enterprise_with_expectations.update_expectations(market_data, t);
    
    fprintf('时间步 %d: 农户预期=%.3f, 企业预期=%.3f\n', ...
            t, farmer_with_expectations.get_expectation('price', 1), ...
            enterprise_with_expectations.get_expectation('demand', 1));
end
```

## 📊 更新检查清单

- [ ] 清理冗余文件
- [ ] 更新智能体类名引用
- [ ] 添加预期形成机制描述
- [ ] 完善市场模块描述
- [ ] 更新使用示例代码
- [ ] 验证所有代码示例可运行
- [ ] 更新版本信息和联系信息

## 🎯 预期效果

更新后的README.md将：
1. **准确反映当前模型结构**
2. **提供完整的功能描述**
3. **包含可运行的代码示例**
4. **清晰展示模型创新点**
5. **便于新用户理解和使用** 