# EER模型风格的预期形成机制

## 🎯 设计理念

本预期形成机制参考**2023年EER（Environmental and Resource Economics）模型**的设计思路，实现了**简洁有效的自适应学习**机制。核心特点是通过不断优化一个简单的**一阶自回归（AR(1)）预测规则**，让智能体能够从历史数据中学习并形成对未来的预期。

## 🏗️ 核心组件

### 1. ExpectationFormationModule
- **AR(1)模型**：`X_{t+1} = α + β * X_t + ε_t`
- **自适应学习**：基于预测误差动态调整学习率和模型参数
- **记忆管理**：维持有限的历史数据，适应环境变化
- **置信度评估**：根据预测准确性提供置信区间

### 2. AgentWithExpectations（基类）
- 集成预期形成功能的智能体基类
- 提供预期与当前信息的加权组合
- 支持风险态度调整和情景分析
- 包含预期准确性评估和参数适应机制

### 3. EnterpriseAgentWithExpectations（示例实现）
- 展示如何将预期机制集成到具体的企业决策中
- 涵盖生产、定价、投资、环境策略等多维度决策
- 基于预期进行前瞻性规划和风险管理

## 🚀 关键特性

### 简洁性
- **单一模型结构**：所有变量都使用统一的AR(1)框架
- **参数少**：每个变量只需要两个核心参数（α, β）
- **计算高效**：递归更新，无需存储大量历史数据

### 自适应性
- **动态学习率**：根据预测误差自动调整学习速度
- **参数进化**：使用在线学习算法不断优化AR(1)参数
- **环境适应**：能够快速适应市场结构变化和政策冲击

### 有效性
- **预测能力**：在仿真中展现出良好的预测准确性
- **决策支持**：有效指导智能体的多维度决策
- **政策响应**：能够合理预期和响应政策变化

## 📊 使用方法

### 基本使用流程

```matlab
%% 1. 创建带预期功能的智能体
expectation_variables = {'price', 'demand', 'competition'};
agent = EnterpriseAgentWithExpectations(1, 'pesticide', params);

%% 2. 观测市场数据并更新预期
market_data = struct('average_price', 60, 'total_demand', 1500, ...);
agent.update_market_observations(market_data, current_time);

%% 3. 获取预期值
expected_price = agent.get_expectation('product_price', 1);  % 1期预期
price_confidence = agent.get_prediction_confidence('product_price');

%% 4. 基于预期做出决策
decision = agent.make_decision_with_expectations(market_data);

%% 5. 诊断和监控
agent.print_expectation_status();
summary = agent.get_expectation_summary();
```

### 高级功能

```matlab
%% 情景分析
scenario_adjustments = struct('product_price', 0.1, 'demand_quantity', -0.05);
scenario_expectations = agent.form_scenario_expectations(scenario_adjustments);

%% 多期预测
long_term_price = agent.get_expectation('product_price', 6);  % 6期预测

%% 学习参数调整
agent.set_expectation_parameter('learning_rate', 0.15);
agent.set_expectation_parameter('risk_attitude', 0.3);

%% 预测准确性评估
agent.adapt_to_forecast_errors('product_price', actual_value, predicted_value);
```

## 🔬 核心算法

### AR(1)预测算法
```matlab
% 基本预测公式
prediction = alpha + beta * current_value;

% 多步预测
for h = 1:horizon
    prediction = alpha + beta * prediction;
end

% 置信度计算
confidence = sqrt(error_variance * (1 + (horizon-1) * beta^2));
```

### 自适应学习更新
```matlab
% 参数更新（递归最小二乘法简化版）
alpha_new = (1 - learning_rate) * alpha_old + learning_rate * estimated_alpha;
beta_new = (1 - learning_rate) * beta_old + learning_rate * estimated_beta;

% 学习率自适应调整
if mean_prediction_error > threshold
    learning_rate = min(max_lr, learning_rate * 1.1);  % 增加学习率
else
    learning_rate = max(min_lr, learning_rate * 0.95); % 减少学习率
end
```

## 📈 应用示例

### 企业定价决策
```matlab
% 获取价格和成本预期
expected_price = agent.get_expectation('product_price', 1);
expected_cost = agent.get_expectation('input_cost', 1);
competition = agent.get_expectation('competition_intensity', 1);

% 基于预期的定价策略
markup = 0.4 * (1 - competition * 0.15);  % 竞争调整
price = expected_cost * (1 + markup);

% 价格平滑调整
price_change_limit = 0.1;
final_price = constrain_price_change(price, current_price, price_change_limit);
```

### 投资决策
```matlab
% R&D投资基于竞争预期
competition_2period = agent.get_expectation('competition_intensity', 2);
rd_investment = base_rd * (1 + competition_2period * 0.5);

% 产能投资基于需求预期
demand_4period = agent.get_expectation('demand_quantity', 4);
demand_confidence = agent.get_prediction_confidence('demand_quantity');

if demand_confidence > 0.6 && demand_4period > capacity * 0.85
    capacity_investment = calculate_expansion_investment(demand_4period);
end
```

## 🎛️ 参数配置

### 核心参数
- `learning_rate`: 学习速率 [0.01, 0.3]，默认0.1
- `memory_length`: 记忆长度，默认12（月）
- `minimum_data_points`: 最少数据点，默认3
- `error_threshold`: 误差阈值，默认0.1

### 智能体参数
- `risk_attitude`: 风险态度 [0, 1]，影响预期使用
- `expectation_weight`: 预期权重，默认0.7
- `update_frequency`: 更新频率，默认每期更新

## 🔍 验证与评估

### 预期准确性指标
- **MAE**: 平均绝对误差
- **RMSE**: 均方根误差  
- **MAPE**: 平均绝对百分比误差
- **准确性得分**: 1/(1+RMSE)

### 学习效果评估
- **参数收敛性**: AR(1)参数的稳定性
- **适应速度**: 面对冲击时的调整速度
- **预测置信度**: 基于历史表现的置信度

## 💡 政策应用洞察

### 政策设计建议
1. **透明度**: 提高政策信息透明度，改善智能体预期质量
2. **渐进性**: 避免剧烈政策变化，给予充分适应时间
3. **可预测性**: 保持政策连贯性，降低预期形成成本
4. **差异化**: 考虑不同智能体的学习能力差异

### 政策效果预测
- 利用预期机制评估政策的预期效应
- 分析政策冲击对智能体行为的影响路径
- 识别政策传导的时滞和强度

## 📚 参考文献

本实现参考了2023年EER模型中智能体预期形成的设计理念，结合了行为经济学和计算经济学的最新进展，为多智能体气候政策模型提供了科学可靠的微观基础。

---

*最后更新：2024年12月* 