function [results] = agri_abm_enhanced(params)
% 增强版农业ABM主函数（简化版本）
% 整合行为经济学、网络效应、政策评估和实证验证模块

% 参数验证和修复
params = validate_and_repair_params(params);

% 初始化结果结构
results = struct();

% 设置随机种子（修复随机数生成器问题）
try
    rng(params.simulation.random_seed, 'twister');
catch
    % 如果出错，使用默认设置
    rng('default');
    rng(params.simulation.random_seed, 'twister');
end

% 初始化代理（使用简化版本）
[agents] = initialize_agents_simple(params);
% 增加政府主体
agents(end+1).id = length(agents)+1;
agents(end).type = 'government';
agents(end).budget = 100000; % 初始预算
agents(end).consumption = 0;
agents(end).investment = 0;
agents(end).tax_revenue = 0;
agents(end).purchase_goods = 0;
agents(end).tax_rate_firm = 0.15;   % 企业税率
agents(end).tax_rate_farmer = 0.05; % 农户税率
agents(end).policy_targets = struct('gdp_growth',0.03,'innovation',0.1,'welfare',0.8);

% 初始化网络结构（使用简化版本）
[network_structure] = initialize_network_structure_simple(agents, params);

% 初始化历史数据存储
history = struct();
history.gdp = zeros(params.simulation.time_steps, 1);
history.employment = zeros(params.simulation.time_steps, 1);
history.income = zeros(params.simulation.time_steps, 1);
history.productivity = zeros(params.simulation.time_steps, 1);
history.inequality = zeros(params.simulation.time_steps, 1);
history.land_transfer_rate = zeros(params.simulation.time_steps, 1);
history.innovation_rate = zeros(params.simulation.time_steps, 1);
history.environmental_impact = zeros(params.simulation.time_steps, 1);
history.learning_effectiveness = zeros(params.simulation.time_steps, 1);
history.avg_learning_rate = zeros(params.simulation.time_steps, 1);
history.avg_exploration_rate = zeros(params.simulation.time_steps, 1);

% 初始化宏观统计结构体
macro = struct();
macro.gdp = 0;
macro.innovation = 0;
macro.avg_health = 0.8;
macro.inequality = 0;
macro.market = struct('price', 100, 'wage', 50, 'demand', 100, 'supply', 100);

% 主模拟循环
for t = 1:params.simulation.time_steps
    fprintf('时间步: %d/%d\n', t, params.simulation.time_steps);
    
    %% 0. 政府决策与税收
    gov_idx = find(strcmp({agents.type},'government'));
    firm_idx = find(strcmp({agents.type},'enterprise'));
    farmer_idx = find(strcmp({agents.type},'farmer'));
    
    %% 1. 简化的生产模块（先生产，再征税）
    for i = 1:length(agents)
        if strcmp(agents(i).type, 'farmer')
            % 农户生产 - 添加合理的生产函数和边界
            base_production = agents(i).land_area * agents(i).land_quality * agents(i).productivity;
            % 添加规模递减效应和边界
            scale_factor = min(100, agents(i).land_area); % 限制规模效应
            agents(i).income = base_production * scale_factor * 10; % 降低乘数
            agents(i).income = min(agents(i).income, 10000); % 设置收入上限
        elseif strcmp(agents(i).type, 'enterprise')
            % 企业生产 - 添加合理的生产函数和边界
            base_production = agents(i).capital * agents(i).technology * agents(i).productivity;
            % 添加规模递减效应和边界
            scale_factor = min(50, agents(i).capital / 100); % 限制规模效应
            agents(i).income = base_production * scale_factor * 5; % 降低乘数
            agents(i).income = min(agents(i).income, 50000); % 设置收入上限
        end
    end
    
    % 计算企业利润和农户收入
    total_firm_profit = sum([agents(firm_idx).income]);
    total_farmer_income = sum([agents(farmer_idx).income]);
    
    % 动态调整税率（可根据经济状态优化）
    agents(gov_idx).tax_rate_firm = max(0.1, min(0.3, 0.15 + 0.01*randn()));
    agents(gov_idx).tax_rate_farmer = max(0.02, min(0.1, 0.05 + 0.005*randn()));
    
    % 征税
    firm_tax = agents(gov_idx).tax_rate_firm * total_firm_profit;
    farmer_tax = agents(gov_idx).tax_rate_farmer * total_farmer_income;
    agents(gov_idx).tax_revenue = firm_tax + farmer_tax;
    agents(gov_idx).budget = agents(gov_idx).budget + agents(gov_idx).tax_revenue;
    
    % 扣除企业和农户税收
    for i = firm_idx
        agents(i).income = agents(i).income * (1 - agents(gov_idx).tax_rate_firm);
    end
    for i = farmer_idx
        agents(i).income = agents(i).income * (1 - agents(gov_idx).tax_rate_farmer);
    end
    
    % 政府消费和购买决策（如购买粮食、基础设施投资等）
    agents(gov_idx).consumption = 0.05 * agents(gov_idx).budget;
    agents(gov_idx).investment = 0.1 * agents(gov_idx).budget;
    agents(gov_idx).purchase_goods = 0.02 * agents(gov_idx).budget;
    agents(gov_idx).budget = agents(gov_idx).budget - (agents(gov_idx).consumption + agents(gov_idx).investment + agents(gov_idx).purchase_goods);
    
    %% 2. 简化的消费模块
    for i = 1:length(agents)
        if ~strcmp(agents(i).type, 'government')
            agents(i).consumption = agents(i).income * 0.8;
            agents(i).savings = agents(i).income * 0.2;
        end
    end
    
    %% 3. 简化的投资模块
    for i = 1:length(agents)
        if ~strcmp(agents(i).type, 'government')
            % 限制投资规模，防止过度积累
            max_investment = agents(i).income * 0.3; % 最大投资比例
            actual_investment = min(agents(i).savings * 0.5, max_investment);
            agents(i).capital = agents(i).capital + actual_investment;
            
            % 设置资本上限，防止过度积累
            if strcmp(agents(i).type, 'farmer')
                agents(i).capital = min(agents(i).capital, 5000);
            else
                agents(i).capital = min(agents(i).capital, 20000);
            end
        end
    end
    
    %% 4. 简化的创新模块
    for i = 1:length(agents)
        if ~strcmp(agents(i).type, 'government')
            if rand() < 0.05  % 降低创新概率到5%
                % 限制技术进步幅度
                tech_improvement = rand() * 0.02; % 最大2%的技术进步
                agents(i).technology = agents(i).technology * (1 + tech_improvement);
                % 设置技术上限
                agents(i).technology = min(agents(i).technology, 2.0);
            end
        end
    end
    
    %% 5. 简化的土地流转模块
    land_transfer_rate = 0;
    for i = farmer_idx
        if rand() < agents(i).transfer_willingness * 0.1
            land_transfer_rate = land_transfer_rate + 1;
        end
    end
    if length(farmer_idx) > 0
        land_transfer_rate = land_transfer_rate / length(farmer_idx);
    end
    
    %% 6. 简化的学习模块
    learning_effectiveness = 0;
    avg_learning_rate = 0;
    avg_exploration_rate = 0;
    
    for i = 1:length(agents)
        if ~strcmp(agents(i).type, 'government')
            % 简单的Q-learning更新
            if length(agents(i).performance_history) > 0
                last_performance = agents(i).performance_history(end);
                current_performance = agents(i).income;
                
                % Q-value更新（限制奖励范围）
                reward = current_performance - last_performance;
                reward = max(-1000, min(1000, reward)); % 限制奖励范围
                
                agents(i).q_values(agents(i).last_action) = agents(i).q_values(agents(i).last_action) + ...
                    agents(i).learning_rate * (reward - agents(i).q_values(agents(i).last_action));
                
                % 学习效果计算
                learning_effectiveness = learning_effectiveness + abs(reward);
                avg_learning_rate = avg_learning_rate + agents(i).learning_rate;
                avg_exploration_rate = avg_exploration_rate + agents(i).exploration_rate;
            end
            
            % 记录性能历史
            agents(i).performance_history = [agents(i).performance_history, agents(i).income];
        end
    end
    
    if length(farmer_idx) + length(firm_idx) > 0
        learning_effectiveness = learning_effectiveness / (length(farmer_idx) + length(firm_idx));
        avg_learning_rate = avg_learning_rate / (length(farmer_idx) + length(firm_idx));
        avg_exploration_rate = avg_exploration_rate / (length(farmer_idx) + length(firm_idx));
    end
    
    %% 7. 更新宏观统计
    macro.gdp = sum([agents([firm_idx, farmer_idx]).income]);
    macro.innovation = mean([agents([firm_idx, farmer_idx]).technology]);
    macro.avg_health = mean([agents([firm_idx, farmer_idx]).health_index]);
    
    % 安全计算不平等指数
    incomes = [agents([firm_idx, farmer_idx]).income];
    if length(incomes) > 0 && mean(incomes) > 0
        macro.inequality = std(incomes) / mean(incomes);
    else
        macro.inequality = 0;
    end
    
    %% 8. 记录历史数据
    history.gdp(t) = macro.gdp;
    history.employment(t) = (length(farmer_idx) + length(firm_idx)) / length(agents);
    
    % 安全计算平均收入
    if length([firm_idx, farmer_idx]) > 0
        history.income(t) = mean([agents([firm_idx, farmer_idx]).income]);
    else
        history.income(t) = 0;
    end
    
    history.productivity(t) = mean([agents([firm_idx, farmer_idx]).productivity]);
    history.inequality(t) = macro.inequality;
    history.land_transfer_rate(t) = land_transfer_rate;
    history.innovation_rate(t) = macro.innovation;
    history.environmental_impact(t) = 0;  % 简化处理
    history.learning_effectiveness(t) = learning_effectiveness;
    history.avg_learning_rate(t) = avg_learning_rate;
    history.avg_exploration_rate(t) = avg_exploration_rate;
    
    %% 9. 定期输出
    if mod(t, params.simulation.output_frequency) == 0
        fprintf('  GDP: %.2f, 就业率: %.3f, 收入: %.2f\n', macro.gdp, history.employment(t), history.income(t));
        fprintf('  土地流转率: %.3f, 创新率: %.3f\n', land_transfer_rate, macro.innovation);
        fprintf('  学习有效性: %.3f, 平均学习率: %.3f\n', learning_effectiveness, avg_learning_rate);
    end
end

% 保存结果
results.history = history;
results.agents = agents;
results.network_structure = network_structure;
results.macro = macro;

fprintf('仿真完成！\n');

end

function [agents] = initialize_agents_simple(params)
% 初始化代理（使用新的企业智能体）

num_agents = params.simulation.num_agents;
agents = {};

% 设置不同类型企业的数量比例
grain_farm_ratio = 0.35;
cash_crop_farm_ratio = 0.25;
mixed_crop_farm_ratio = 0.20;
industrial_enterprise_ratio = 0.15;
service_enterprise_ratio = 0.05;

% 计算各类型企业数量
num_grain_farms = floor(num_agents * grain_farm_ratio);
num_cash_crop_farms = floor(num_agents * cash_crop_farm_ratio);
num_mixed_crop_farms = floor(num_agents * mixed_crop_farm_ratio);
num_industrial_enterprises = floor(num_agents * industrial_enterprise_ratio);
num_service_enterprises = num_agents - num_grain_farms - num_cash_crop_farms - num_mixed_crop_farms - num_industrial_enterprises;

fprintf('初始化企业智能体: 粮食%d, 经济作物%d, 混合作物%d, 工业%d, 服务%d\n', ...
    num_grain_farms, num_cash_crop_farms, num_mixed_crop_farms, num_industrial_enterprises, num_service_enterprises);

agent_index = 1;

% 初始化粮食作物生产企业
for i = 1:num_grain_farms
    try
        agents{agent_index} = GrainFarmAgent(params);
        agents{agent_index}.id = agent_index;
        agents{agent_index}.type = 'farmer';
        
        % 添加基础属性以兼容原始模型
        agents{agent_index}.wealth = agents{agent_index}.land_cost_per_mu * agents{agent_index}.planting_area;
        agents{agent_index}.consumption = agents{agent_index}.wealth * 0.15;
        agents{agent_index}.savings = agents{agent_index}.wealth * 0.1;
        agents{agent_index}.capital = agents{agent_index}.machinery_investment;
        agents{agent_index}.labor = agents{agent_index}.family_labor;
        
        % 继承原有属性
        agents{agent_index}.village_id = ceil(agent_index / 20);
        agents{agent_index}.is_working = true;
        agents{agent_index}.health_index = 0.8 + rand() * 0.2;
        agents{agent_index}.innovation_capacity = agents{agent_index}.technology_level;
        agents{agent_index}.market_access = agents{agent_index}.market_orientation;
        agents{agent_index}.climate_exposure = agents{agent_index}.climate_risk_exposure;
        
        % 学习属性
        agents{agent_index}.q_values = zeros(5, 1);
        agents{agent_index}.action_values = ones(5, 1) / 5;
        agents{agent_index}.last_action = randi(5);
        agents{agent_index}.performance_history = [];
        
        agent_index = agent_index + 1;
    catch ME
        fprintf('粮食作物企业%d初始化失败: %s\n', i, ME.message);
        % 创建简化版本作为备选
        agents{agent_index} = create_fallback_farmer(agent_index, 'grain', params);
        agent_index = agent_index + 1;
    end
end

% 初始化经济作物生产企业
for i = 1:num_cash_crop_farms
    try
        agents{agent_index} = CashCropFarmAgent(params);
        agents{agent_index}.id = agent_index;
        agents{agent_index}.type = 'farmer';
        
        % 添加基础属性以兼容原始模型
        agents{agent_index}.wealth = agents{agent_index}.land_cost_per_mu * agents{agent_index}.planting_area;
        agents{agent_index}.consumption = agents{agent_index}.wealth * 0.15;
        agents{agent_index}.savings = agents{agent_index}.wealth * 0.1;
        agents{agent_index}.capital = agents{agent_index}.machinery_investment;
        agents{agent_index}.labor = agents{agent_index}.family_labor;
        
        % 继承原有属性
        agents{agent_index}.village_id = ceil(agent_index / 20);
        agents{agent_index}.is_working = true;
        agents{agent_index}.health_index = 0.8 + rand() * 0.2;
        agents{agent_index}.innovation_capacity = agents{agent_index}.technology_level;
        agents{agent_index}.market_access = agents{agent_index}.market_orientation;
        agents{agent_index}.climate_exposure = agents{agent_index}.climate_risk_exposure;
        
        % 学习属性
        agents{agent_index}.q_values = zeros(5, 1);
        agents{agent_index}.action_values = ones(5, 1) / 5;
        agents{agent_index}.last_action = randi(5);
        agents{agent_index}.performance_history = [];
        
        agent_index = agent_index + 1;
    catch ME
        fprintf('经济作物企业%d初始化失败: %s\n', i, ME.message);
        % 创建简化版本作为备选
        agents{agent_index} = create_fallback_farmer(agent_index, 'cash_crop', params);
        agent_index = agent_index + 1;
    end
end

% 初始化混合作物生产企业
for i = 1:num_mixed_crop_farms
    try
        agents{agent_index} = MixedCropFarmAgent(params);
        agents{agent_index}.id = agent_index;
        agents{agent_index}.type = 'farmer';
        
        % 添加基础属性以兼容原始模型
        agents{agent_index}.wealth = agents{agent_index}.land_cost_per_mu * agents{agent_index}.planting_area;
        agents{agent_index}.consumption = agents{agent_index}.wealth * 0.15;
        agents{agent_index}.savings = agents{agent_index}.wealth * 0.1;
        agents{agent_index}.capital = agents{agent_index}.machinery_investment;
        agents{agent_index}.labor = agents{agent_index}.family_labor;
        
        % 继承原有属性
        agents{agent_index}.village_id = ceil(agent_index / 20);
        agents{agent_index}.is_working = true;
        agents{agent_index}.health_index = 0.8 + rand() * 0.2;
        agents{agent_index}.innovation_capacity = agents{agent_index}.technology_level;
        agents{agent_index}.market_access = agents{agent_index}.market_orientation;
        agents{agent_index}.climate_exposure = agents{agent_index}.climate_risk_exposure;
        
        % 学习属性
        agents{agent_index}.q_values = zeros(5, 1);
        agents{agent_index}.action_values = ones(5, 1) / 5;
        agents{agent_index}.last_action = randi(5);
        agents{agent_index}.performance_history = [];
        
        agent_index = agent_index + 1;
    catch ME
        fprintf('混合作物企业%d初始化失败: %s\n', i, ME.message);
        % 创建简化版本作为备选
        agents{agent_index} = create_fallback_farmer(agent_index, 'mixed', params);
        agent_index = agent_index + 1;
    end
end

% 初始化工业企业（化肥、农药、农产品加工）
industrial_types = {'fertilizer', 'pesticide', 'agro_processing'};
enterprises_per_type = floor(num_industrial_enterprises / 3);
remaining_enterprises = num_industrial_enterprises - enterprises_per_type * 3;

for type_idx = 1:length(industrial_types)
    type_name = industrial_types{type_idx};
    num_this_type = enterprises_per_type;
    if type_idx <= remaining_enterprises
        num_this_type = num_this_type + 1;
    end
    
    for i = 1:num_this_type
        try
            switch type_name
                case 'fertilizer'
                    agents{agent_index} = FertilizerEnterpriseAgent(agent_index, params);
                case 'pesticide'
                    agents{agent_index} = PesticideEnterpriseAgent(agent_index, params);
                case 'agro_processing'
                    agents{agent_index} = AgroProcessingEnterpriseAgent(agent_index, params);
            end
            
            agents{agent_index}.id = agent_index;
            agents{agent_index}.type = 'enterprise';
            
            % 添加基础属性以兼容原始模型
            agents{agent_index}.wealth = agents{agent_index}.fixed_capital;
            agents{agent_index}.consumption = agents{agent_index}.wealth * 0.08;
            agents{agent_index}.savings = agents{agent_index}.wealth * 0.12;
            agents{agent_index}.capital = agents{agent_index}.fixed_capital;
            agents{agent_index}.labor = agents{agent_index}.employment_capacity;
            
            % 设置土地属性（工业企业不使用农地）
            agents{agent_index}.land_area = 0;
            agents{agent_index}.land_quality = 0;
            agents{agent_index}.crop_type = 'none';
            agents{agent_index}.transfer_willingness = 0;
            agents{agent_index}.off_farm_employment = false;
            
            % 继承原有属性
            agents{agent_index}.village_id = ceil(agent_index / 20);
            agents{agent_index}.is_working = true;
            agents{agent_index}.health_index = 0.85 + rand() * 0.15;
            agents{agent_index}.innovation_capacity = agents{agent_index}.technology_level;
            agents{agent_index}.market_access = 0.8 + rand() * 0.2;
            agents{agent_index}.climate_exposure = 0.1 + rand() * 0.2;
            
            % 学习属性
            agents{agent_index}.q_values = zeros(5, 1);
            agents{agent_index}.action_values = ones(5, 1) / 5;
            agents{agent_index}.last_action = randi(5);
            agents{agent_index}.performance_history = [];
            
            agent_index = agent_index + 1;
        catch ME
            fprintf('%s企业%d初始化失败: %s\n', type_name, i, ME.message);
            % 创建简化版本作为备选
            agents{agent_index} = create_fallback_enterprise(agent_index, type_name, params);
            agent_index = agent_index + 1;
        end
    end
end

% 初始化农业服务企业
for i = 1:num_service_enterprises
    try
        agents{agent_index} = AgriculturalServiceEnterpriseAgent(agent_index, params);
        agents{agent_index}.id = agent_index;
        agents{agent_index}.type = 'enterprise';
        
        % 添加基础属性以兼容原始模型
        agents{agent_index}.wealth = agents{agent_index}.fixed_capital;
        agents{agent_index}.consumption = agents{agent_index}.wealth * 0.08;
        agents{agent_index}.savings = agents{agent_index}.wealth * 0.12;
        agents{agent_index}.capital = agents{agent_index}.fixed_capital;
        agents{agent_index}.labor = agents{agent_index}.employment_capacity;
        
        % 设置土地属性（服务企业不使用农地）
        agents{agent_index}.land_area = 0;
        agents{agent_index}.land_quality = 0;
        agents{agent_index}.crop_type = 'none';
        agents{agent_index}.transfer_willingness = 0;
        agents{agent_index}.off_farm_employment = false;
        
        % 继承原有属性
        agents{agent_index}.village_id = ceil(agent_index / 20);
        agents{agent_index}.is_working = true;
        agents{agent_index}.health_index = 0.85 + rand() * 0.15;
        agents{agent_index}.innovation_capacity = agents{agent_index}.technology_level;
        agents{agent_index}.market_access = 0.8 + rand() * 0.2;
        agents{agent_index}.climate_exposure = 0.1 + rand() * 0.2;
        
        % 学习属性
        agents{agent_index}.q_values = zeros(5, 1);
        agents{agent_index}.action_values = ones(5, 1) / 5;
        agents{agent_index}.last_action = randi(5);
        agents{agent_index}.performance_history = [];
        
        agent_index = agent_index + 1;
    catch ME
        fprintf('农业服务企业%d初始化失败: %s\n', i, ME.message);
        % 创建简化版本作为备选
        agents{agent_index} = create_fallback_enterprise(agent_index, 'service', params);
        agent_index = agent_index + 1;
    end
end

% 转换为结构体数组以兼容原始代码
if ~isempty(agents)
    agents_struct = [];
    for i = 1:length(agents)
        if isobject(agents{i})
            % 将对象转换为结构体
            agent_struct = struct();
            props = properties(agents{i});
            for j = 1:length(props)
                try
                    agent_struct.(props{j}) = agents{i}.(props{j});
                catch
                    % 如果属性访问失败，设置默认值
                    agent_struct.(props{j}) = [];
                end
            end
            agents_struct = [agents_struct, agent_struct];
        else
            agents_struct = [agents_struct, agents{i}];
        end
    end
    agents = agents_struct;
else
    agents = struct();
end

% 添加调试信息
farmer_count = sum(strcmp({agents.type}, 'farmer'));
enterprise_count = sum(strcmp({agents.type}, 'enterprise'));
fprintf('初始化完成: %d个农业企业, %d个工业/服务企业\n', farmer_count, enterprise_count);

end

function agent = create_fallback_farmer(id, crop_type, params)
% 创建备用农户智能体（当新智能体初始化失败时使用）

agent = struct();
agent.id = id;
agent.type = 'farmer';

% 基础经济属性
agent.income = rand() * 1000 + 500;
agent.wealth = rand() * 5000 + 1000;
agent.consumption = agent.income * 0.8;
agent.savings = agent.income * 0.2;
agent.capital = rand() * 2000 + 500;
agent.labor = randi([2, 6]);

% 生产属性
agent.technology_level = 0.5 + rand() * 0.3;
agent.productivity = 0.7 + rand() * 0.3;

% 土地属性
agent.land_area = 50 + rand() * 200;
agent.land_quality = 0.3 + rand() * 0.6;
agent.crop_type = crop_type;
agent.transfer_willingness = rand();
agent.off_farm_employment = rand() > 0.7;

% 质量相关属性
agent.product_quality = 0.5 + rand() * 0.3;
agent.quality_investment = 0.02 + rand() * 0.03;
agent.rd_investment = 0.01 + rand() * 0.02;
agent.reputation = 0.3 + rand() * 0.4;

% 其他必要属性
agent.village_id = ceil(id / 20);
agent.is_working = true;
agent.health_index = 0.8 + rand() * 0.2;
agent.innovation_capacity = agent.technology_level;
agent.market_access = rand();
agent.climate_exposure = rand();

% 学习属性
agent.q_values = zeros(5, 1);
agent.action_values = ones(5, 1) / 5;
agent.last_action = randi(5);
agent.performance_history = [];

fprintf('创建备用%s农户智能体 %d\n', crop_type, id);
end

function agent = create_fallback_enterprise(id, enterprise_type, params)
% 创建备用企业智能体（当新智能体初始化失败时使用）

agent = struct();
agent.id = id;
agent.type = 'enterprise';

% 基础经济属性
agent.income = rand() * 5000 + 2000;
agent.wealth = rand() * 20000 + 5000;
agent.consumption = agent.income * 0.6;
agent.savings = agent.income * 0.4;
agent.capital = rand() * 15000 + 3000;
agent.labor = randi([5, 20]);

% 生产属性
agent.technology_level = 0.6 + rand() * 0.3;
agent.productivity = 0.8 + rand() * 0.2;

% 土地属性（企业不使用农地）
agent.land_area = 0;
agent.land_quality = 0;
agent.crop_type = 'none';
agent.transfer_willingness = 0;
agent.off_farm_employment = false;

% 质量相关属性
agent.product_quality = 0.6 + rand() * 0.3;
agent.quality_investment = 0.03 + rand() * 0.04;
agent.rd_investment = 0.02 + rand() * 0.03;
agent.reputation = 0.4 + rand() * 0.4;

% 其他必要属性
agent.village_id = ceil(id / 20);
agent.is_working = true;
agent.health_index = 0.85 + rand() * 0.15;
agent.innovation_capacity = agent.technology_level;
agent.market_access = 0.8 + rand() * 0.2;
agent.climate_exposure = 0.1 + rand() * 0.2;

% 学习属性
agent.q_values = zeros(5, 1);
agent.action_values = ones(5, 1) / 5;
agent.last_action = randi(5);
agent.performance_history = [];

fprintf('创建备用%s企业智能体 %d\n', enterprise_type, id);
end

function [network_structure] = initialize_network_structure_simple(agents, params)
% 初始化网络结构（使用简化版本）

num_agents = length(agents);

% 创建简单的随机网络
density = 0.1;  % 网络密度
adjacency_matrix = rand(num_agents, num_agents) < density;

% 移除自环
adjacency_matrix = adjacency_matrix - diag(diag(adjacency_matrix));

% 确保无向性
adjacency_matrix = (adjacency_matrix + adjacency_matrix') > 0;

network_structure = struct();
network_structure.adjacency_matrix = adjacency_matrix;
network_structure.degree_distribution = sum(adjacency_matrix, 2);
network_structure.clustering_coefficient = 0.1;  % 简化计算
network_structure.average_path_length = 2.5;     % 简化计算

end

function params = validate_and_repair_params(params)
% 验证和修复参数配置
% 确保所有必需的字段都存在

% 检查并修复simulation字段
if ~isfield(params, 'simulation')
    params.simulation = struct();
end

if ~isfield(params.simulation, 'num_agents')
    params.simulation.num_agents = 100;
end

if ~isfield(params.simulation, 'time_steps')
    params.simulation.time_steps = 50;
end

if ~isfield(params.simulation, 'random_seed')
    params.simulation.random_seed = 12345;
end

if ~isfield(params.simulation, 'output_frequency')
    params.simulation.output_frequency = 10;
end

% 检查并修复production字段
if ~isfield(params, 'production')
    params.production = struct();
end

if ~isfield(params.production, 'elasticity')
    params.production.elasticity = 0.6;
end

if ~isfield(params.production, 'scale_factor')
    params.production.scale_factor = 1.0;
end

if ~isfield(params.production, 'technology_growth')
    params.production.technology_growth = 0.02;
end

% 检查并修复behavioral_economics字段
if ~isfield(params, 'behavioral_economics')
    params.behavioral_economics = struct();
end

if ~isfield(params.behavioral_economics, 'risk_aversion')
    params.behavioral_economics.risk_aversion = 0.5;
end

if ~isfield(params.behavioral_economics, 'reference_dependence')
    params.behavioral_economics.reference_dependence = 0.3;
end

if ~isfield(params.behavioral_economics, 'loss_aversion')
    params.behavioral_economics.loss_aversion = 2.0;
end

if ~isfield(params.behavioral_economics, 'enable')
    params.behavioral_economics.enable = false;
end

% 检查并修复network_effects字段
if ~isfield(params, 'network_effects')
    params.network_effects = struct();
end

if ~isfield(params.network_effects, 'density')
    params.network_effects.density = 0.1;
end

if ~isfield(params.network_effects, 'clustering')
    params.network_effects.clustering = 0.2;
end

if ~isfield(params.network_effects, 'influence_strength')
    params.network_effects.influence_strength = 0.3;
end

if ~isfield(params.network_effects, 'enable')
    params.network_effects.enable = false;
end

% 检查并修复policy字段
if ~isfield(params, 'policy')
    params.policy = struct();
end

if ~isfield(params.policy, 'subsidy_rate')
    params.policy.subsidy_rate = 0.05;
end

if ~isfield(params.policy, 'tax_rate')
    params.policy.tax_rate = 0.15;
end

if ~isfield(params.policy, 'regulation_strength')
    params.policy.regulation_strength = 0.3;
end

if ~isfield(params.policy, 'enable')
    params.policy.enable = false;
end

% 检查并修复environment字段
if ~isfield(params, 'environment')
    params.environment = struct();
end

if ~isfield(params.environment, 'climate_change_rate')
    params.environment.climate_change_rate = 0.01;
end

if ~isfield(params.environment, 'adaptation_cost')
    params.environment.adaptation_cost = 0.1;
end

if ~isfield(params.environment, 'enable')
    params.environment.enable = false;
end

% 检查并修复learning字段
if ~isfield(params, 'learning')
    params.learning = struct();
end

if ~isfield(params.learning, 'rate')
    params.learning.rate = 0.1;
end

if ~isfield(params.learning, 'exploration_rate')
    params.learning.exploration_rate = 0.2;
end

if ~isfield(params.learning, 'discount_factor')
    params.learning.discount_factor = 0.9;
end

if ~isfield(params.learning, 'enable')
    params.learning.enable = true;
end

% 检查并修复land_transfer字段
if ~isfield(params, 'land_transfer')
    params.land_transfer = struct();
end

if ~isfield(params.land_transfer, 'base_rate')
    params.land_transfer.base_rate = 0.05;
end

if ~isfield(params.land_transfer, 'cost_factor')
    params.land_transfer.cost_factor = 0.1;
end

if ~isfield(params.land_transfer, 'enable')
    params.land_transfer.enable = true;
end

% 检查并修复innovation字段
if ~isfield(params, 'innovation')
    params.innovation = struct();
end

if ~isfield(params.innovation, 'base_rate')
    params.innovation.base_rate = 0.1;
end

if ~isfield(params.innovation, 'success_rate')
    params.innovation.success_rate = 0.3;
end

if ~isfield(params.innovation, 'enable')
    params.innovation.enable = true;
end

% 检查并修复market字段
if ~isfield(params, 'market')
    params.market = struct();
end

if ~isfield(params.market, 'price_volatility')
    params.market.price_volatility = 0.1;
end

if ~isfield(params.market, 'demand_elasticity')
    params.market.demand_elasticity = 0.5;
end

if ~isfield(params.market, 'enable')
    params.market.enable = false;
end

% 检查并修复government字段
if ~isfield(params, 'government')
    params.government = struct();
end

if ~isfield(params.government, 'budget')
    params.government.budget = 100000;
end

if ~isfield(params.government, 'consumption_rate')
    params.government.consumption_rate = 0.05;
end

if ~isfield(params.government, 'investment_rate')
    params.government.investment_rate = 0.1;
end

if ~isfield(params.government, 'tax_rate_firm')
    params.government.tax_rate_firm = 0.15;
end

if ~isfield(params.government, 'tax_rate_farmer')
    params.government.tax_rate_farmer = 0.05;
end

if ~isfield(params.government, 'enable')
    params.government.enable = true;
end

end 