# 多智能体气候政策模型 API 参考

## 📋 目录
- [核心模型类](#核心模型类)
- [企业智能体类](#企业智能体类)
- [农户智能体类](#农户智能体类)
- [市场模块](#市场模块)
- [验证框架](#验证框架)
- [工具函数](#工具函数)
- [配置参数](#配置参数)

---

## 🏗️ 核心模型类

### MultiAgentClimatePolicyModel

多智能体气候政策模型的主类，负责整个仿真的协调和管理。

#### 构造函数
```matlab
obj = MultiAgentClimatePolicyModel(params)
```

**参数**：
- `params` (struct): 模型参数结构体

**示例**：
```matlab
params = struct();
params.simulation.max_time = 120;
params.enterprises.count = 100;
params.households.count = 400;

model = MultiAgentClimatePolicyModel(params);
```

#### 主要属性

| 属性名 | 类型 | 描述 |
|--------|------|------|
| `enterprises` | cell array | 企业智能体数组 |
| `households` | cell array | 农户智能体数组 |
| `government` | GovernmentAgent | 政府智能体 |
| `markets` | struct | 市场模块集合 |
| `spatial_grid` | SpatialGrid | 空间网格 |
| `results` | struct | 仿真结果 |
| `current_time` | double | 当前时间步 |

#### 主要方法

##### `run_simulation()`
执行完整的仿真流程

```matlab
model.run_simulation()
```

**返回值**: 无  
**副作用**: 更新`model.results`结构体

**示例**：
```matlab
model = MultiAgentClimatePolicyModel(params);
model.run_simulation();
disp(['仿真完成，共运行', num2str(model.current_time), '个时间步']);
```

##### `step()`
执行单个时间步的仿真

```matlab
model.step()
```

**流程**：
1. 更新政府政策
2. 企业决策更新
3. 农户决策更新
4. 市场撮合
5. 结果收集

##### `initialize_agents()`
初始化所有智能体

```matlab
model.initialize_agents()
```

**功能**：
- 创建企业智能体（农药、化肥、加工、服务企业）
- 创建农户智能体
- 设置智能体初始状态和网络关系

##### `initialize_markets()`
初始化市场模块

```matlab
model.initialize_markets()
```

**创建的市场**：
- 农药市场 (`PesticideMarketModule`)
- 化肥市场 (`FertilizerMarketModule`)
- 商品市场 (`CommodityMarketModule`)
- 土地市场 (`LandMarketModule`)

##### `collect_results()`
收集和整理仿真结果

```matlab
results = model.collect_results()
```

**返回值**：
- `results` (struct): 包含时间序列数据、统计指标、验证结果

**结果结构**：
```matlab
results = struct(
    'time_series', [...],       % 时间序列数据
    'final_state', [...],       % 最终状态
    'statistics', [...],        % 统计指标
    'validation', [...]         % 验证结果
);
```

##### `generate_results_report()`
生成结果报告

```matlab
model.generate_results_report(output_path)
```

**参数**：
- `output_path` (string, optional): 报告输出路径，默认为当前目录

---

## 🏭 企业智能体类

### PesticideEnterpriseAgent

农药企业智能体，继承自`EnterpriseAgent`基类。

#### 构造函数
```matlab
obj = PesticideEnterpriseAgent(id, params, spatial_grid)
```

**参数**：
- `id` (double): 企业唯一标识符
- `params` (struct): 企业参数
- `spatial_grid` (SpatialGrid): 空间网格对象

#### 核心属性

| 属性名 | 类型 | 范围 | 描述 |
|--------|------|------|------|
| `product_quality` | double | [0.3, 1.0] | 产品质量指数 |
| `technology_level` | double | [0.3, 1.0] | 技术水平 |
| `quality_investment` | double | [0.01, 0.08] | 质量投资比例 |
| `rd_investment` | double | [0.005, 0.06] | 研发投资比例 |
| `reputation` | double | [0, 1] | 企业声誉 |
| `emission_rate` | double | [0.05, 0.2] | 排放系数 |
| `production_capacity` | double | [1000, 50000] | 年产能（吨） |
| `market_share` | double | [0, 1] | 市场份额 |

#### 关键方法

##### `calculate_product_quality()`
计算企业产品质量

```matlab
quality = obj.calculate_product_quality()
```

**公式**：
```
Q = [α_T·T^ρ + α_Q·QInv^ρ + α_R·RD^ρ + α_Rep·Rep^ρ]^(1/ρ)
```

**返回值**：
- `quality` (double): 计算得到的产品质量 [0.3, 1.0]

**示例**：
```matlab
enterprise = PesticideEnterpriseAgent(1, params, grid);
enterprise.technology_level = 0.7;
enterprise.quality_investment = 0.05;
enterprise.rd_investment = 0.03;
enterprise.reputation = 0.6;

quality = enterprise.calculate_product_quality();
fprintf('产品质量: %.3f\n', quality);
```

##### `update_decision()`
更新企业综合决策

```matlab
obj.update_decision()
```

**决策内容**：
1. 生产决策（产量优化）
2. 定价决策（成本加成+质量溢价）
3. 投资决策（质量投资、研发投资）
4. 环境策略决策

##### `set_price(market_info)`
设定产品价格

```matlab
price = obj.set_price(market_info)
```

**参数**：
- `market_info` (struct): 市场信息

**定价公式**：
```
P = MC × (1 + markup) × QualityPremium × ReputationPremium × CompetitionFactor
```

**示例**：
```matlab
market_info = struct();
market_info.expected_price = 100;
market_info.competitor_prices = [95, 105, 98];
market_info.emission_tax_rate = 0.2;

price = enterprise.set_price(market_info);
fprintf('设定价格: %.2f元\n', price);
```

##### `calculate_total_cost()`
计算企业总成本

```matlab
total_cost = obj.calculate_total_cost()
```

**成本组成**：
- 固定成本
- 可变成本
- 环境成本（排放税+合规成本）
- 质量成本
- 研发成本

**返回值**：
- `total_cost` (double): 总成本

### FertilizerEnterpriseAgent

化肥企业智能体，专注于绿色技术和环保合规。

#### 特化属性

| 属性名 | 类型 | 范围 | 描述 |
|--------|------|------|------|
| `nitrogen_efficiency` | double | [0.6, 0.95] | 氮肥利用效率 |
| `phosphorus_efficiency` | double | [0.5, 0.90] | 磷肥利用效率 |
| `organic_content_ratio` | double | [0, 0.3] | 有机成分比例 |
| `green_tech_adoption` | double | [0, 1] | 绿色技术采用水平 |
| `carbon_footprint` | double | [1.0, 2.5] | 碳足迹（吨CO2/吨产品） |

#### 特化方法

##### `green_technology_upgrade()`
绿色技术升级决策

```matlab
obj.green_technology_upgrade()
```

**技术选项评估**：
- 生物肥料技术
- 精准施用技术
- 废料回收技术
- 清洁生产技术

**决策标准**：ROI > 20%

##### `respond_to_emission_tax(tax_rate)`
响应排放税政策

```matlab
obj.respond_to_emission_tax(tax_rate)
```

**参数**：
- `tax_rate` (double): 排放税率

**响应策略**：
1. 评估排放成本影响
2. 调整产能利用率
3. 增加绿色技术投资
4. 更新排放率

### AgroProcessingEnterpriseAgent

农产品加工企业智能体，连接农业生产和终端消费。

#### 特化属性

| 属性名 | 类型 | 范围 | 描述 |
|--------|------|------|------|
| `processing_capacity` | double | [1000, 20000] | 加工能力（吨/年） |
| `input_quality_requirement` | double | [0.5, 0.9] | 原料质量要求 |
| `contract_farming_ratio` | double | [0, 0.6] | 订单农业比例 |
| `cold_chain_capability` | double | [0.2, 0.9] | 冷链能力 |
| `automation_level` | double | [0.1, 0.8] | 自动化水平 |

#### 特化方法

##### `select_suppliers_by_quality()`
基于质量选择供应商

```matlab
suppliers = obj.select_suppliers_by_quality()
```

**选择标准**：
```matlab
综合得分 = 0.4×质量得分 + 0.25×可靠性得分 + 0.2×价格竞争力 + 0.15×可持续性得分
```

**返回值**：
- `suppliers` (cell array): 选中的供应商列表

##### `set_quality_premium_price()`
质量溢价定价

```matlab
price = obj.set_quality_premium_price()
```

**溢价策略**：
- 基础成本加成
- 质量溢价
- 品牌溢价
- 渠道差异化定价

---

## 🏠 农户智能体类

### HouseholdAgent

传统小农户智能体。

#### 构造函数
```matlab
obj = HouseholdAgent(id, params, spatial_grid)
```

#### 核心属性

| 属性名 | 类型 | 范围 | 描述 |
|--------|------|------|------|
| `land_holding` | double | [1, 15] | 土地规模（亩） |
| `quality_preference` | double | [0.3, 0.9] | 质量偏好 |
| `price_sensitivity` | double | [0.8, 2.0] | 价格敏感度 |
| `education_level` | double | [0.1, 1.0] | 教育水平 |
| `risk_tolerance` | double | [0.2, 0.8] | 风险偏好 |
| `income` | struct | - | 收入结构 |

#### 关键方法

##### `calculate_quality_preference()`
计算农户质量偏好

```matlab
preference = obj.calculate_quality_preference()
```

**影响因素**：
- 收入水平（正相关）
- 教育程度（正相关）
- 年龄（负相关）
- 风险偏好（正相关）

##### `make_input_purchase_decision(available_products)`
投入品购买决策

```matlab
decisions = obj.make_input_purchase_decision(available_products)
```

**参数**：
- `available_products` (struct array): 可选产品列表

**决策模型**：随机效用模型
```matlab
U_ij = β_quality×Quality_j + β_price×Price_j + β_reputation×Reputation_j + ε_ij
```

**返回值**：
- `decisions` (struct): 购买决策，包含产品选择和数量

---

## 🏛️ 政府智能体类

### GovernmentAgent

政府智能体，负责制定和调整环境政策，是整个气候政策仿真的核心驱动力。

#### 构造函数
```matlab
obj = GovernmentAgent(params)
```

**参数**：
- `params` (struct): 政府参数配置

**示例**：
```matlab
gov_params = struct();
gov_params.policy_objective = 'emission_reduction';
gov_params.budget_constraint = 1000000;  % 政策预算（万元）
gov_params.emission_target = 0.3;        % 排放减少目标（30%）

government = GovernmentAgent(gov_params);
```

#### 核心属性

| 属性名 | 类型 | 范围 | 描述 |
|--------|------|------|------|
| `emission_tax_rate` | double | [0, 0.5] | 排放税率 |
| `green_subsidy_rate` | double | [0, 0.3] | 绿色补贴率 |
| `compliance_penalty_rate` | double | [0, 0.4] | 合规罚款率 |
| `quality_standard` | double | [0.3, 0.9] | 质量标准要求 |
| `policy_budget` | double | [0, Inf] | 政策实施预算 |
| `emission_target` | double | [0.1, 0.5] | 排放减少目标 |
| `policy_effectiveness` | struct | - | 政策效果评估 |
| `policy_history` | cell array | - | 政策调整历史 |

#### 政策工具组合

##### 1. 直接政策工具
```matlab
direct_policy_tools = struct( ...
    'emission_tax', struct( ...
        'rate', [0, 0.5], ...           % 税率范围
        'base', 'emissions', ...        % 征税基础
        'exemptions', [] ...            % 免税条件
    ), ...
    'green_subsidy', struct( ...
        'rate', [0, 0.3], ...           % 补贴率范围
        'target', 'tech_upgrade', ...   % 补贴目标
        'eligibility', 'all_enterprises' ... % 资格条件
    ), ...
    'compliance_penalty', struct( ...
        'rate', [0, 0.4], ...           % 罚款率范围
        'threshold', 'emission_standard', ... % 触发条件
        'enforcement_probability', 0.8 ... % 执法概率
    ) ...
);
```

##### 2. 市场机制政策
```matlab
market_policy_tools = struct( ...
    'quality_standard', struct( ...
        'minimum_level', [0.3, 0.9], ... % 最低质量要求
        'certification_cost', 5000, ...  % 认证成本
        'update_frequency', 24 ...       % 更新频率（月）
    ), ...
    'carbon_trading', struct( ...
        'cap_reduction_rate', 0.05, ... % 配额递减率
        'allocation_method', 'free', ... % 分配方式
        'banking_allowed', true ...      % 是否允许银行存储
    ) ...
);
```

#### 关键方法

##### `update_policy(market_feedback, economic_indicators)`
根据市场反馈和经济指标更新政策

```matlab
obj.update_policy(market_feedback, economic_indicators)
```

**参数**：
- `market_feedback` (struct): 市场反馈信息
- `economic_indicators` (struct): 经济指标

**更新逻辑**：
1. 评估当前政策效果
2. 计算目标达成度
3. 调整政策参数
4. 检查预算约束

**示例**：
```matlab
market_feedback = struct();
market_feedback.total_emissions = 15000;
market_feedback.economic_efficiency = 0.75;
market_feedback.compliance_rate = 0.85;

economic_indicators = struct();
economic_indicators.gdp_growth = 0.06;
economic_indicators.unemployment_rate = 0.04;
economic_indicators.inflation_rate = 0.02;

government.update_policy(market_feedback, economic_indicators);
```

##### `evaluate_policy_effectiveness(baseline_results, current_results)`
评估政策效果

```matlab
effectiveness = obj.evaluate_policy_effectiveness(baseline_results, current_results)
```

**评估维度**：
```matlab
effectiveness_metrics = struct( ...
    'emission_reduction_rate', ...,     % 排放减少率
    'economic_cost', ...,               % 经济成本
    'social_welfare_impact', ...,       % 社会福利影响
    'distributional_effects', ...,      % 分配效应
    'innovation_incentive', ...         % 创新激励效果
);
```

**计算公式**：
```matlab
% 排放减少率
emission_reduction_rate = (baseline_emissions - current_emissions) / baseline_emissions;

% 经济效率（单位减排成本）
economic_efficiency = total_policy_cost / emission_reduction_achieved;

% 创新激励指数
innovation_incentive = (current_rd_investment - baseline_rd_investment) / baseline_rd_investment;
```

##### `optimize_policy_mix(constraints, objectives)`
优化政策组合

```matlab
optimal_policy = obj.optimize_policy_mix(constraints, objectives)
```

**参数**：
- `constraints` (struct): 约束条件（预算、政治可行性等）
- `objectives` (struct): 政策目标和权重

**优化模型**：
```matlab
% 多目标优化问题
min F(x) = [f1(x), f2(x), f3(x)]  % 帕累托最优

其中：
f1(x) = -emission_reduction(x)    % 最大化减排效果
f2(x) = economic_cost(x)          % 最小化经济成本  
f3(x) = -social_acceptance(x)     % 最大化社会接受度

约束条件：
g1(x): budget_constraint
g2(x): political_feasibility
g3(x): administrative_capacity
```

**示例**：
```matlab
constraints = struct();
constraints.budget_limit = 500000;      % 预算约束（万元）
constraints.max_tax_rate = 0.3;         % 最高税率
constraints.political_support = 0.6;    % 政治支持度

objectives = struct();
objectives.emission_weight = 0.5;       % 减排目标权重
objectives.economic_weight = 0.3;       % 经济目标权重
objectives.social_weight = 0.2;         % 社会目标权重

optimal_policy = government.optimize_policy_mix(constraints, objectives);
```

##### `implement_adaptive_policy(learning_rate, adjustment_frequency)`
实施自适应政策调整

```matlab
obj.implement_adaptive_policy(learning_rate, adjustment_frequency)
```

**参数**：
- `learning_rate` (double): 学习速率 [0.01, 0.2]
- `adjustment_frequency` (integer): 调整频率（月）

**自适应算法**：
```matlab
% 强化学习式政策调整
function new_policy = adaptive_adjustment(current_policy, observed_outcome, target)
    % 计算误差
    error = target - observed_outcome;
    
    % 策略梯度更新
    policy_gradient = calculate_policy_gradient(current_policy, error);
    
    % 更新政策参数
    new_policy = current_policy + learning_rate * policy_gradient;
    
    % 确保参数在可行域内
    new_policy = project_to_feasible_region(new_policy);
end
```

##### `conduct_policy_experiment(experiment_design)`
进行政策实验

```matlab
experiment_results = obj.conduct_policy_experiment(experiment_design)
```

**实验类型**：
- **随机对照试验**：随机选择企业/地区实施新政策
- **渐进式试点**：分阶段扩大政策实施范围
- **对比分析**：不同政策工具效果对比

**实验设计**：
```matlab
experiment_design = struct( ...
    'type', 'randomized_controlled_trial', ...
    'treatment_group_size', 0.3, ...           % 处理组比例
    'experiment_duration', 24, ...             % 实验时长（月）
    'evaluation_metrics', {{'emission_reduction', 'economic_impact'}}, ...
    'control_variables', {{'enterprise_size', 'technology_level'}} ...
);
```

#### 政策决策算法

##### 1. 多目标决策分析（MCDA）
```matlab
function policy_ranking = multi_criteria_decision_analysis(policy_options, criteria, weights)
    % 政策选项评分矩阵
    score_matrix = zeros(length(policy_options), length(criteria));
    
    for i = 1:length(policy_options)
        for j = 1:length(criteria)
            score_matrix(i,j) = evaluate_policy_on_criterion(policy_options{i}, criteria{j});
        end
    end
    
    % 标准化评分
    normalized_scores = normalize_scores(score_matrix);
    
    % 加权综合评分
    weighted_scores = normalized_scores * weights';
    
    % 排序
    [~, ranking_indices] = sort(weighted_scores, 'descend');
    policy_ranking = policy_options(ranking_indices);
end
```

##### 2. 动态博弈理论应用
```matlab
function equilibrium_policy = find_stackelberg_equilibrium(government, enterprises)
    % 政府作为领导者，企业作为跟随者的Stackelberg博弈
    
    % 政府目标函数
    government_objective = @(policy) social_welfare(policy, enterprise_response(policy));
    
    % 企业最优响应函数
    enterprise_response = @(policy) optimize_enterprise_strategy(policy);
    
    % 求解政府最优政策
    equilibrium_policy = fmincon(government_objective, initial_policy, ...
                                constraints.A, constraints.b, ...
                                constraints.Aeq, constraints.beq, ...
                                constraints.lb, constraints.ub);
end
```

#### 政策学习与演化

##### `update_policy_knowledge(new_evidence)`
更新政策知识库

```matlab
obj.update_policy_knowledge(new_evidence)
```

**知识更新机制**：
```matlab
% 贝叶斯学习更新
function updated_belief = bayesian_update(prior_belief, new_evidence, likelihood)
    % 计算后验概率
    posterior = (likelihood * prior_belief) / marginal_likelihood;
    updated_belief = posterior;
end

% 政策效果预测模型更新
function updated_model = update_prediction_model(current_model, new_data)
    % 在线学习算法（如递归最小二乘法）
    updated_model = recursive_least_squares(current_model, new_data);
end
```

#### 使用示例

##### 基础政策设定示例
```matlab
%% 创建政府智能体
gov_params = struct();
gov_params.initial_emission_tax = 0.15;
gov_params.initial_subsidy_rate = 0.08;
gov_params.policy_budget = 800000;
gov_params.emission_target = 0.25;
gov_params.adjustment_frequency = 6;  % 每6个月调整一次

government = GovernmentAgent(gov_params);

%% 设定政策目标
policy_targets = struct();
policy_targets.emission_reduction = 0.25;    % 25%减排目标
policy_targets.economic_efficiency = 0.8;    % 80%经济效率目标
policy_targets.innovation_rate = 0.15;       % 15%创新率提升

government.set_policy_targets(policy_targets);

%% 实施自适应政策
government.implement_adaptive_policy(0.05, 6);  % 5%学习率，6个月调整
```

##### 政策实验示例
```matlab
%% 设计政策实验
experiment = struct();
experiment.type = 'A_B_testing';
experiment.policy_A = struct('emission_tax', 0.2, 'subsidy', 0.1);
experiment.policy_B = struct('emission_tax', 0.15, 'subsidy', 0.15);
experiment.duration = 18;  % 18个月实验期
experiment.sample_size = 0.5;  % 50%企业参与

%% 运行实验
results = government.conduct_policy_experiment(experiment);

%% 分析结果
fprintf('政策A效果：减排%.1f%%, 经济成本%.0f万元\n', ...
    results.policy_A.emission_reduction * 100, ...
    results.policy_A.economic_cost / 10000);

fprintf('政策B效果：减排%.1f%%, 经济成本%.0f万元\n', ...
    results.policy_B.emission_reduction * 100, ...
    results.policy_B.economic_cost / 10000);

%% 选择最优政策
if results.policy_A.cost_effectiveness > results.policy_B.cost_effectiveness
    government.adopt_policy(experiment.policy_A);
    fprintf('采用政策A\n');
else
    government.adopt_policy(experiment.policy_B);
    fprintf('采用政策B\n');
end
```

##### 复杂政策优化示例
```matlab
%% 多维政策空间优化
policy_space = struct();
policy_space.emission_tax = [0.1, 0.35];      % 税率范围
policy_space.green_subsidy = [0.05, 0.25];    % 补贴率范围
policy_space.quality_standard = [0.5, 0.8];   % 质量标准范围
policy_space.enforcement_prob = [0.6, 0.95];  % 执法概率范围

%% 定义约束条件
constraints = struct();
constraints.budget_limit = 1000000;           % 预算约束
constraints.political_feasibility = 0.7;      % 政治可行性
constraints.administrative_capacity = 0.8;    % 行政能力

%% 多目标优化
objectives = struct();
objectives.weights = [0.4, 0.3, 0.2, 0.1];   % 减排、经济、社会、创新权重
objectives.targets = [0.3, 0.8, 0.7, 0.15];  % 各目标水平

%% 求解最优政策组合
optimal_policy = government.optimize_policy_mix(constraints, objectives);

fprintf('最优政策组合：\n');
fprintf('  排放税率: %.2f\n', optimal_policy.emission_tax);
fprintf('  绿色补贴率: %.2f\n', optimal_policy.green_subsidy);
fprintf('  质量标准: %.2f\n', optimal_policy.quality_standard);
fprintf('  执法概率: %.2f\n', optimal_policy.enforcement_prob);
```

---

## 🏪 市场模块

### PesticideMarketModule

农药市场模块，实现基于质量的双边匹配。

#### 构造函数
```matlab
obj = PesticideMarketModule(suppliers, demanders)
```

**参数**：
- `suppliers` (cell array): 供应商（农药企业）
- `demanders` (cell array): 需求方（农户、农业企业）

#### 核心方法

##### `match_supply_demand_by_quality()`
执行质量匹配算法

```matlab
[matches, welfare] = obj.match_supply_demand_by_quality()
```

**算法流程**：
1. 计算所有可能配对的效用矩阵
2. 生成双方偏好排序
3. 执行Gale-Shapley稳定匹配算法
4. 验证匹配稳定性
5. 计算总福利

**返回值**：
- `matches` (matrix): 匹配结果矩阵
- `welfare` (double): 总社会福利

##### `calculate_matching_utility(demander, supplier, params)`
计算匹配效用

```matlab
utility = obj.calculate_matching_utility(demander, supplier, params)
```

**效用函数**：
```matlab
U = w_quality×QualityUtility + w_price×PriceUtility + w_reputation×ReputationUtility - SearchCost
```

**组成部分**：
- 质量匹配效用：高斯相似性函数
- 价格效用：负指数函数
- 声誉效用：Sigmoid函数
- 搜寻成本：距离+信息成本

##### `generate_market_feedback()`
生成市场反馈

```matlab
feedback = obj.generate_market_feedback()
```

**反馈内容**：
- 供应商满意度评分
- 市场集中度指标
- 价格离散度
- 匹配效率

### FertilizerMarketModule

化肥市场模块，继承自`PesticideMarketModule`，增加环保特性。

#### 特化功能
- 绿色产品偏好权重调整
- 环保认证加分机制
- 可持续供应链评估

### CommodityMarketModule

商品市场模块，处理农产品交易。

#### 核心功能
- 基于质量等级的价格发现
- 期货合约支持
- 季节性价格波动建模

### **LaborMarketModule** ⭐

**劳动力市场模块，处理农业劳动力的供需匹配和技能发展。**

#### 构造函数
```matlab
obj = LaborMarketModule(params)
```

**参数**：
- `params` (struct): 劳动力市场参数

#### 核心属性

| 属性名 | 类型 | 描述 |
|--------|------|------|
| `labor_suppliers` | cell array | 劳动力供给方智能体 |
| `labor_demanders` | cell array | 劳动力需求方智能体 |
| `labor_categories` | cell array | 劳动力类别 |
| `skill_levels` | array | 技能等级 [1-5] |
| `current_wage_rates` | struct | 当前工资率（按类别） |
| `employment_levels` | struct | 就业水平统计 |
| `seasonal_demand_multipliers` | struct | 季节性需求倍数 |
| `training_programs` | struct array | 可用培训项目 |
| `matching_algorithm` | string | 匹配算法类型 |

#### 劳动力类别定义

```matlab
labor_categories = {
    'unskilled',        % 非技能劳动力
    'skilled',          % 技能劳动力  
    'machinery_operator', % 机械操作员
    'seasonal',         % 季节性工人
    'management'        % 管理人员
};
```

#### 主要方法

##### `match_labor_supply_demand(time_period, climate_conditions)`
**劳动力供需匹配主算法**

```matlab
[matches, wages] = obj.match_labor_supply_demand(time_period, climate_conditions)
```

**算法特点**：
- 基于技能匹配的延迟接受算法（Deferred Acceptance）
- 考虑地理距离和通勤成本
- 整合季节性需求波动和气候影响
- 支持多对多匹配和工资谈判

**参数**：
- `time_period` (double): 时间周期（月）
- `climate_conditions` (struct): 气候条件

**返回值**：
- `matches` (struct array): 匹配结果
- `wages` (struct): 均衡工资率

**匹配算法流程**：
```matlab
% 1. 生成供需双方偏好列表
supplier_preferences = generate_supplier_preferences(suppliers, demanders);
demander_preferences = generate_demander_preferences(demanders, suppliers);

% 2. 迭代匹配过程
while ~isempty(unmatched_suppliers)
    % 供给方向偏好的需求方申请
    % 需求方根据预算和偏好决定是否接受
    % 工资通过Nash议价确定
end

% 3. 验证匹配稳定性
stability_check = verify_matching_stability(matches);
```

**示例**：
```matlab
% 春季播种期劳动力匹配
climate = struct('temperature', 18, 'precipitation', 120, 'extreme_events', 0);
[matches, wages] = labor_market.match_labor_supply_demand(3, climate);

fprintf('春季匹配结果：\n');
fprintf('  成功匹配: %d 对\n', length(matches));
fprintf('  非技能工平均工资: %.2f 元/小时\n', wages.unskilled);
fprintf('  技能工平均工资: %.2f 元/小时\n', wages.skilled);
fprintf('  机械操作员工资: %.2f 元/小时\n', wages.machinery_operator);
```

##### `determine_wage_rate(labor_category, supply, demand, location)`
**工资率决定机制**

```matlab
wage_rate = obj.determine_wage_rate(labor_category, supply, demand, location)
```

**定价机制**：
```matlab
% 基础工资（最低工资 + 技能溢价）
base_wage = minimum_wage * skill_premium_rates[category];

% 供需调整（价格弹性）
supply_demand_factor = (demand / supply)^wage_elasticity;

% 地区成本调整
location_factor = regional_cost_index[location];

% 季节性调整
seasonal_factor = seasonal_multipliers[current_season][category];

% 最终工资率
wage_rate = base_wage * supply_demand_factor * location_factor * seasonal_factor;
```

**参数**：
- `labor_category` (string): 劳动力类别
- `supply` (double): 该类别劳动力供给量
- `demand` (double): 该类别劳动力需求量  
- `location` (array): 地理位置坐标

**返回值**：
- `wage_rate` (double): 均衡工资率（元/小时）

**示例**：
```matlab
% 计算秋收季节技能工工资
supply = 150;  % 可用技能工数量
demand = 200;  % 需求技能工数量
location = [120.5, 36.2];  % 经纬度

wage = labor_market.determine_wage_rate('skilled', supply, demand, location);
fprintf('技能工工资: %.2f 元/小时\n', wage);
```

##### `forecast_seasonal_demand(climate_forecast, crop_plans)`
**季节性劳动力需求预测**

```matlab
demand_forecast = obj.forecast_seasonal_demand(climate_forecast, crop_plans)
```

**预测模型**：
```matlab
% 基础需求计算
base_demand = crop_area * labor_intensity[crop_type];

% 季节性调整
seasonal_factor = seasonal_multipliers[season][crop_type];

% 气候影响调整  
climate_factor = calculate_climate_impact(temperature_anomaly, precipitation_anomaly);

% 技术水平调整
tech_factor = 1 - mechanization_level * substitution_rate;

% 最终预测需求
forecasted_demand = base_demand * seasonal_factor * climate_factor * tech_factor;
```

**参数**：
- `climate_forecast` (struct): 未来气候预测数据
- `crop_plans` (struct array): 各农场的作物种植计划

**返回值**：
- `demand_forecast` (struct): 分类别、分季节的需求预测

**预测结果结构**：
```matlab
demand_forecast = struct( ...
    'spring', struct('unskilled', 1200, 'skilled', 800, 'machinery', 150), ...
    'summer', struct('unskilled', 600, 'skilled', 400, 'machinery', 80), ...
    'autumn', struct('unskilled', 1800, 'skilled', 1200, 'machinery', 220), ...
    'winter', struct('unskilled', 200, 'skilled', 150, 'machinery', 30), ...
    'confidence_intervals', [...], ...
    'risk_factors', [...] ...
);
```

##### `initialize_training_programs()`
**初始化培训项目**

```matlab
obj.initialize_training_programs()
```

**培训项目类型**：
```matlab
training_programs = struct( ...
    'technical_skills', struct( ...
        'duration', 6, ...              % 培训时长（月）
        'cost', 3000, ...               % 培训费用（元）
        'skill_improvement', 1, ...     % 技能等级提升
        'success_rate', 0.85, ...       % 培训成功率
        'target_group', 'unskilled' ... % 目标人群
    ), ...
    'machinery_operation', struct( ...
        'duration', 3, ...
        'cost', 5000, ...
        'skill_improvement', 2, ...
        'success_rate', 0.75, ...
        'target_group', 'skilled' ...
    ), ...
    'management_skills', struct( ...
        'duration', 12, ...
        'cost', 8000, ...
        'skill_improvement', 2, ...
        'success_rate', 0.70, ...
        'target_group', 'experienced' ...
    ) ...
);
```

##### `analyze_training_effectiveness(program_id, participants)`
**培训效果分析**

```matlab
effectiveness = obj.analyze_training_effectiveness(program_id, participants)
```

**评估指标**：
- **技能提升程度**：培训前后技能等级变化
- **工资增长率**：培训后工资提升百分比
- **就业率改善**：培训后就业状况改善程度
- **投资回报率**：培训投资的经济回报

**分析方法**：
```matlab
% 培训效果评估
function effectiveness = evaluate_training_effectiveness(pre_training, post_training)
    % 技能提升
    skill_improvement = mean(post_training.skill_levels - pre_training.skill_levels);
    
    % 工资增长
    wage_growth = (mean(post_training.wages) - mean(pre_training.wages)) / mean(pre_training.wages);
    
    % 就业率变化
    employment_improvement = mean(post_training.employment) - mean(pre_training.employment);
    
    % ROI计算
    benefit = sum(post_training.lifetime_earnings - pre_training.lifetime_earnings);
    cost = sum(training_costs);
    roi = (benefit - cost) / cost;
    
    effectiveness = struct('skill_improvement', skill_improvement, ...
                          'wage_growth', wage_growth, ...
                          'employment_improvement', employment_improvement, ...
                          'roi', roi);
end
```

**示例**：
```matlab
% 分析技术培训项目效果
tech_program = labor_market.training_programs.technical_skills;
participants = labor_market.get_training_participants(tech_program.id);

effectiveness = labor_market.analyze_training_effectiveness(tech_program.id, participants);

fprintf('技术培训效果分析：\n');
fprintf('  平均技能提升: %.1f 级\n', effectiveness.skill_improvement);
fprintf('  平均工资增长: %.1f%%\n', effectiveness.wage_growth * 100);
fprintf('  就业率改善: %.1f%%\n', effectiveness.employment_improvement * 100);
fprintf('  投资回报率: %.1f%%\n', effectiveness.roi * 100);
```

##### `simulate_policy_impact(policy_change)`
**政策影响仿真**

```matlab
impact = obj.simulate_policy_impact(policy_change)
```

**可仿真的政策变化**：
- **最低工资调整**：对就业和工资分布的影响
- **培训补贴政策**：对技能提升和人力资本投资的影响  
- **就业补贴政策**：对劳动力需求和就业率的影响
- **劳动力流动政策**：对区域间劳动力配置的影响

**政策影响模型**：
```matlab
function impact = simulate_minimum_wage_impact(old_wage, new_wage, labor_demand_elasticity)
    % 工资变化率
    wage_change_rate = (new_wage - old_wage) / old_wage;
    
    % 就业量变化（基于需求弹性）
    employment_change = -labor_demand_elasticity * wage_change_rate;
    
    % 劳动力供给变化
    supply_change = labor_supply_elasticity * wage_change_rate;
    
    % 总福利变化
    welfare_change = calculate_welfare_change(employment_change, wage_change_rate);
    
    impact = struct('employment_change', employment_change, ...
                   'wage_cost_change', wage_change_rate, ...
                   'welfare_change', welfare_change);
end
```

**示例**：
```matlab
% 仿真最低工资从15元/小时上调到20元/小时的影响
policy_change = struct();
policy_change.type = 'minimum_wage_increase';
policy_change.old_rate = 15;
policy_change.new_rate = 20;
policy_change.effective_date = model.current_time + 3;

impact = labor_market.simulate_policy_impact(policy_change);

fprintf('最低工资上调影响预测：\n');
fprintf('  就业率变化: %.2f%%\n', impact.employment_change * 100);
fprintf('  总工资成本变化: %.2f%%\n', impact.wage_cost_change * 100);
fprintf('  社会福利变化: %.0f万元\n', impact.welfare_change / 10000);
```

##### `calculate_market_efficiency()`
**计算市场效率指标**

```matlab
efficiency = obj.calculate_market_efficiency()
```

**效率指标**：
- **匹配效率**：实际匹配数 / 理论最大匹配数
- **工资离散度**：同类技能工人工资的变异系数
- **搜寻成本**：平均求职和招聘成本
- **技能匹配度**：工作要求技能与工人技能的匹配程度

```matlab
function efficiency = calculate_matching_efficiency(matches, max_possible_matches)
    % 匹配效率
    matching_efficiency = length(matches) / max_possible_matches;
    
    % 技能匹配度
    skill_matching = mean([matches.skill_match_score]);
    
    % 工资合理性（与边际生产力的偏离度）
    wage_reasonableness = 1 - mean(abs([matches.wage] - [matches.marginal_productivity]) ./ [matches.marginal_productivity]);
    
    % 综合效率评分
    overall_efficiency = 0.4 * matching_efficiency + 0.3 * skill_matching + 0.3 * wage_reasonableness;
    
    efficiency = struct('matching_efficiency', matching_efficiency, ...
                       'skill_matching', skill_matching, ...
                       'wage_reasonableness', wage_reasonableness, ...
                       'overall_efficiency', overall_efficiency);
end
```

#### 劳动力供需智能体

##### `LaborSupplierAgent`
**劳动力供给方智能体（农户、外来工）**

**核心属性**：
```matlab
properties:
    agent_id                    % 智能体ID
    agent_type                  % 'household', 'migrant_worker', 'external_worker'
    available_work_hours = 2000 % 年可工作小时数
    skill_level = 1            % 技能等级 [1-5]
    labor_categories = {'unskilled'} % 可从事的工作类别
    reservation_wage           % 保留工资
    commuting_tolerance = 30   % 通勤容忍度（公里）
    training_willingness = 0.5 % 培训参与意愿
```

**关键方法**：
```matlab
% 劳动力供给决策
function supply_decision = decide_labor_supply(obj, wage_offers, job_characteristics)
    % 计算各工作机会的效用
    utility_scores = calculate_job_utilities(wage_offers, job_characteristics);
    
    % 选择效用最高且超过保留工资的工作
    [max_utility, best_job] = max(utility_scores);
    
    if max_utility > obj.reservation_wage
        supply_decision = struct('accept', true, 'job_id', best_job, ...
                                'hours_supplied', calculate_optimal_hours(wage_offers(best_job)));
    else
        supply_decision = struct('accept', false);
    end
end

% 培训参与决策
function training_decision = decide_training_participation(obj, programs, subsidies)
    % 计算各培训项目的净现值
    best_program = [];
    max_npv = 0;
    
    for program = programs
        training_cost = program.cost * (1 - subsidies.rate);
        expected_benefit = estimate_training_benefit(program.skill_improvement);
        npv = expected_benefit - training_cost;
        
        if npv > max_npv
            max_npv = npv;
            best_program = program;
        end
    end
    
    training_decision = struct('participate', max_npv > 0, 'program', best_program);
end
```

##### `LaborDemanderAgent`  
**劳动力需求方智能体（各类农场和企业）**

**核心属性**：
```matlab
properties:
    agent_id
    agent_type                 % 'grain_farm', 'cash_crop_farm', 'agro_processing'
    production_scale = 100     % 生产规模（亩）
    technology_level = 0.5     % 技术水平（机械化程度）
    labor_demand_forecast      % 劳动力需求预测
    max_wage_budget = 50000    % 最大工资预算
    preferred_skill_levels = [1, 2] % 偏好的技能水平
```

**关键方法**：
```matlab
% 劳动力需求计算
function demand_plan = calculate_labor_demand(obj, production_plan, climate_forecast)
    % 按季节计算基础劳动力需求
    base_seasonal_demand = calculate_base_demand(production_plan);
    
    % 气候调整
    climate_adjusted_demand = apply_climate_adjustments(base_seasonal_demand, climate_forecast);
    
    % 技术调整（机械化替代）
    tech_adjusted_demand = climate_adjusted_demand * (1 - obj.technology_level * 0.4);
    
    % 分解为不同技能类别
    demand_plan = allocate_demand_by_skill(tech_adjusted_demand);
end

% 工资报价决策
function wage_offer = determine_wage_offer(obj, labor_category, market_conditions, urgency)
    % 基础市场工资
    market_wage = market_conditions.average_wage[labor_category];
    
    % 紧急程度溢价
    urgency_premium = urgency * 0.2;
    
    % 支付能力调整
    affordability = min(1.5, obj.max_wage_budget / obj.estimated_total_cost);
    
    wage_offer = market_wage * (1 + urgency_premium) * affordability;
end
```

#### 使用示例

##### 完整劳动力市场仿真
```matlab
%% 1. 初始化劳动力市场
labor_params = struct();
labor_params.search_cost_factor = 0.05;
labor_params.minimum_wage = 15;
labor_params.skill_premium_rates = [1.0, 1.3, 1.6, 2.0, 2.5];

labor_market = LaborMarketModule(labor_params);

%% 2. 添加劳动力供给方和需求方
suppliers = create_labor_suppliers(500);  % 500个劳动力供给方
demanders = create_labor_demanders(100);  % 100个农场/企业

labor_market.add_suppliers(suppliers);
labor_market.add_demanders(demanders);

%% 3. 运行季节性匹配循环
seasons = {'spring', 'summer', 'autumn', 'winter'};
annual_results = struct();

for season_idx = 1:length(seasons)
    season = seasons{season_idx};
    
    % 更新季节性需求
    labor_market.update_seasonal_demand(season);
    
    % 执行匹配
    [matches, wages] = labor_market.match_labor_supply_demand(season_idx);
    
    % 记录结果
    annual_results.(season) = struct('matches', matches, 'wages', wages);
    
    fprintf('%s季匹配结果: %d对, 平均工资%.2f元/小时\n', ...
            season, length(matches), mean([wages.hourly_rate]));
end

%% 4. 分析全年劳动力市场表现
annual_analysis = labor_market.analyze_annual_performance(annual_results);

fprintf('\n全年劳动力市场分析：\n');
fprintf('  平均就业率: %.1f%%\n', annual_analysis.average_employment_rate * 100);
fprintf('  工资增长率: %.1f%%\n', annual_analysis.wage_growth_rate * 100);
fprintf('  匹配效率: %.3f\n', annual_analysis.matching_efficiency);
```

##### 政策实验示例
```matlab
%% 培训补贴政策实验
baseline_scenario = labor_market.get_current_state();

% 实施50%培训补贴
training_subsidy_policy = struct('type', 'training_subsidy', 'rate', 0.5);
labor_market.implement_policy(training_subsidy_policy);

% 运行一年仿真
policy_results = labor_market.run_annual_simulation();

% 比较政策效果
policy_impact = compare_scenarios(baseline_scenario, policy_results);

fprintf('培训补贴政策效果：\n');
fprintf('  培训参与率提升: %.1f%%\n', policy_impact.training_participation_increase * 100);
fprintf('  平均技能水平提升: %.2f级\n', policy_impact.average_skill_improvement);
fprintf('  政策成本: %.0f万元\n', policy_impact.policy_cost / 10000);
fprintf('  社会净收益: %.0f万元\n', policy_impact.net_social_benefit / 10000);
```

##### 气候变化适应性分析
```matlab
%% 气候变化对劳动力需求的影响
% 设置气候变化情景
climate_scenarios = {
    struct('name', 'baseline', 'temp_change', 0, 'precip_change', 0),
    struct('name', 'mild_warming', 'temp_change', 1.5, 'precip_change', -5),
    struct('name', 'severe_warming', 'temp_change', 3.0, 'precip_change', -15)
};

scenario_results = cell(length(climate_scenarios), 1);

for i = 1:length(climate_scenarios)
    scenario = climate_scenarios{i};
    
    % 设置气候条件
    labor_market.set_climate_conditions(scenario);
    
    % 运行仿真
    scenario_results{i} = labor_market.run_climate_impact_simulation();
    
    fprintf('%s情景下劳动力需求变化: %.1f%%\n', ...
            scenario.name, scenario_results{i}.demand_change * 100);
end

% 分析气候适应能力
adaptation_analysis = labor_market.analyze_climate_adaptation(scenario_results);

fprintf('\n气候适应性分析：\n');
fprintf('  劳动力需求波动性: %.3f\n', adaptation_analysis.demand_volatility);
fprintf('  工资稳定性: %.3f\n', adaptation_analysis.wage_stability);
fprintf('  就业韧性指数: %.3f\n', adaptation_analysis.employment_resilience);
```

---

## 🔍 验证框架

### ModelValidationFramework

模型验证框架，提供多层次验证功能。

#### 构造函数
```matlab
obj = ModelValidationFramework(model, calibration_data, validation_data)
```

**参数**：
- `model` (MultiAgentClimatePolicyModel): 待验证模型
- `calibration_data` (struct): 校准目标数据
- `validation_data` (struct): 验证基准数据

#### 主要方法

##### `calibrate_model(max_iterations)`
模型校准

```matlab
[best_params, score] = obj.calibrate_model(max_iterations)
```

**参数**：
- `max_iterations` (double): 最大迭代次数

**算法**：遗传算法+局部搜索

**返回值**：
- `best_params` (vector): 最优参数组合
- `score` (double): 校准得分

##### `conduct_sensitivity_analysis()`
敏感性分析

```matlab
results = obj.conduct_sensitivity_analysis()
```

**方法**：
- Morris方法：全局筛选
- Sobol方法：方差分解
- 局部敏感性：梯度分析

**返回值**：
- `results` (struct): 敏感性分析结果

##### `validate_model()`
模型验证

```matlab
validation_results = obj.validate_model()
```

**验证层次**：
1. 统计验证：RMSE, MAE, 相关系数
2. 模式匹配：风格化事实验证
3. 行为验证：学习曲线、决策一致性
4. 系统验证：涌现性质

**返回值**：
- `validation_results` (struct): 验证结果和评分

---

## 🛠️ 工具函数

### 数据处理函数

#### `load_empirical_data(data_source)`
加载实证数据

```matlab
data = load_empirical_data(data_source)
```

**支持格式**：CSV, Excel, MAT, 数据库连接

#### `preprocess_data(raw_data, options)`
数据预处理

```matlab
processed_data = preprocess_data(raw_data, options)
```

**功能**：
- 缺失值处理
- 异常值检测和处理
- 数据标准化
- 特征工程

### 统计分析函数

#### `calculate_descriptive_stats(data)`
描述性统计

```matlab
stats = calculate_descriptive_stats(data)
```

**返回指标**：
- 均值、中位数、众数
- 标准差、方差
- 偏度、峰度
- 分位数

#### `test_distribution_fit(data, distribution_type)`
分布拟合检验

```matlab
[fit_result, parameters] = test_distribution_fit(data, distribution_type)
```

**支持分布**：
- 正态分布
- 对数正态分布
- Beta分布
- 幂律分布

### 网络分析函数

#### `analyze_network_properties(network)`
网络特性分析

```matlab
properties = analyze_network_properties(network)
```

**计算指标**：
- 度分布
- 聚类系数
- 平均路径长度
- 中心性指标

#### `detect_communities(network, algorithm)`
社区检测

```matlab
communities = detect_communities(network, algorithm)
```

**算法选项**：
- Louvain算法
- Leiden算法
- 模块度优化

---

## ⚙️ 配置参数

### 仿真参数

```matlab
simulation_params = struct( ...
    'max_time', 120, ...              % 最大仿真时间
    'time_step', 1, ...               % 时间步长
    'warm_up_period', 12, ...         % 预热期
    'random_seed', 12345, ...         % 随机种子
    'save_frequency', 10, ...         % 保存频率
    'output_level', 'detailed' ...    % 输出详细程度
);
```

### 智能体参数

#### 企业参数
```matlab
enterprise_params = struct( ...
    'total_count', 100, ...
    'pesticide_count', 25, ...
    'fertilizer_count', 25, ...
    'processing_count', 30, ...
    'service_count', 20, ...
    'tech_level_range', [0.3, 0.9], ...
    'rd_investment_range', [0.005, 0.06], ...
    'quality_investment_range', [0.01, 0.08] ...
);
```

#### 农户参数
```matlab
household_params = struct( ...
    'total_count', 400, ...
    'land_holding_range', [1, 15], ...
    'income_distribution', 'lognormal', ...
    'education_levels', [0.2, 0.5, 0.8], ...
    'quality_preference_beta', [2, 2] ...
);
```

### 市场参数

```matlab
market_params = struct( ...
    'search_cost_factor', 0.05, ...
    'matching_algorithm', 'stable_matching', ...
    'utility_weights', struct( ...
        'quality', 0.45, ...
        'price', 0.35, ...
        'reputation', 0.20 ...
    ), ...
    'market_clearing_frequency', 1 ...
);
```

### 政策参数

```matlab
policy_params = struct( ...
    'emission_tax_rate', 0.2, ...
    'green_subsidy_rate', 0.1, ...
    'compliance_penalty_rate', 0.15, ...
    'quality_standard', 0.6, ...
    'policy_update_frequency', 12 ...
);
```

### 验证参数

```matlab
validation_params = struct( ...
    'statistical_tests', {{'ks_test', 'ad_test', 'correlation'}}, ...
    'pattern_matching', {{'power_law', 'fat_tail', 'volatility_clustering'}}, ...
    'behavioral_validation', {{'learning_curves', 'decision_consistency'}}, ...
    'significance_level', 0.05 ...
);
```

---

## 📝 使用示例

### 完整示例：运行政策对比实验

```matlab
%% 设置实验参数
% 基础参数
base_params = struct();
base_params.simulation.max_time = 120;
base_params.enterprises.count = 100;
base_params.households.count = 400;

% 政策场景
scenarios = {
    struct('name', 'Baseline', 'emission_tax_rate', 0, 'green_subsidy_rate', 0),
    struct('name', 'EmissionTax', 'emission_tax_rate', 0.25, 'green_subsidy_rate', 0),
    struct('name', 'GreenSubsidy', 'emission_tax_rate', 0, 'green_subsidy_rate', 0.15),
    struct('name', 'PolicyMix', 'emission_tax_rate', 0.25, 'green_subsidy_rate', 0.15)
};

%% 运行实验
results = cell(length(scenarios), 1);

for i = 1:length(scenarios)
    fprintf('运行场景: %s\n', scenarios{i}.name);
    
    % 设置模型参数
    params = base_params;
    params.government = scenarios{i};
    
    % 创建和运行模型
    model = MultiAgentClimatePolicyModel(params);
    model.run_simulation();
    
    % 收集结果
    results{i} = model.collect_results();
    results{i}.scenario_name = scenarios{i}.name;
end

%% 结果分析
fprintf('\n=== 政策效果对比 ===\n');
for i = 1:length(results)
    fprintf('%s: 排放减少 %.1f%%, 经济效率 %.3f\n', ...
        results{i}.scenario_name, ...
        results{i}.statistics.emission_reduction * 100, ...
        results{i}.statistics.economic_efficiency);
end

%% 生成报告
generate_comparison_report(results, 'policy_comparison_report.html');
```

---

*API参考文档版本：2.0*  
*最后更新：2024年12月* 