%% 农业系统仿真：基于AR(1)预期形成的农户-企业-政府协同机制
% 
% 本仿真展示了如何将AR(1)预期形成机制应用到农业政策ABM中，
% 重点展现农户、企业（化肥、农药）和政府智能体之间的协同关系
%

clear; clc; close all;

% 添加路径
addpath('../core');

%% 1. 仿真参数设置
fprintf('=== 初始化农业系统仿真 ===\n');

% 时间设置
simulation_periods = 60;  % 5年仿真（月度）
current_time = 1;

% 智能体数量
num_farmers = 50;         % 50个农户
num_fertilizer_enterprises = 3;  % 3家化肥企业
num_pesticide_enterprises = 2;   % 2家农药企业
num_governments = 1;      % 1个政府（可扩展为多级）

% 仿真记录
simulation_results = struct();
simulation_results.time_series = [];
simulation_results.agent_trajectories = struct();
simulation_results.policy_impacts = [];
simulation_results.market_dynamics = [];

%% 2. 初始化智能体
fprintf('\n--- 初始化智能体 ---\n');

% 2.1 初始化农户智能体
farmers = cell(num_farmers, 1);
for i = 1:num_farmers
    % 随机生成农户参数
    params = struct();
    params.land_holding = 5 + rand() * 15;  % 5-20亩
    params.education_level = 0.3 + rand() * 0.5;  % 0.3-0.8
    params.age = 30 + rand() * 40;  % 30-70岁
    params.risk_aversion = 0.2 + rand() * 0.6;  % 0.2-0.8
    
    farmers{i} = FarmerAgentWithExpectations(i, params);
end

% 2.2 初始化农业企业智能体
enterprises = cell(num_fertilizer_enterprises + num_pesticide_enterprises, 1);

% 化肥企业
for i = 1:num_fertilizer_enterprises
    params = struct();
    params.production_capacity = 8000 + rand() * 4000;
    params.technology_level = 0.5 + rand() * 0.3;
    params.competitive_strategy = {'cost_leadership', 'differentiation', 'focus'}{randi(3)};
    
    enterprises{i} = AgriculturalEnterpriseWithExpectations(100 + i, 'fertilizer_producer', params);
end

% 农药企业
for i = 1:num_pesticide_enterprises
    params = struct();
    params.production_capacity = 2000 + rand() * 3000;
    params.technology_level = 0.6 + rand() * 0.3;
    params.competitive_strategy = {'differentiation', 'focus'}{randi(2)};
    
    enterprises{num_fertilizer_enterprises + i} = AgriculturalEnterpriseWithExpectations(200 + i, 'pesticide_producer', params);
end

% 2.3 初始化政府智能体
government = GovernmentAgentWithExpectations(300, 'central');

% 2.4 初始化简化劳动力市场
labor_market = SimplifiedLaborMarket();

fprintf('智能体初始化完成：%d农户，%d企业，%d政府\n', num_farmers, length(enterprises), 1);

%% 3. 市场和环境初始化
fprintf('\n--- 初始化市场环境 ---\n');

% 3.1 初始化农产品市场
agricultural_market = struct();
agricultural_market.base_price = 4.5;  % 基础农产品价格 4.5元/公斤
agricultural_market.price_volatility = 0.15;
agricultural_market.seasonal_factors = [1.1, 0.9, 0.95, 1.3];  % 春夏秋冬季节因子

% 3.2 初始化投入品市场
input_market = struct();
input_market.fertilizer_base_price = 2000;  % 化肥基础价格 2000元/吨
input_market.pesticide_base_price = 10000;  % 农药基础价格 10000元/吨
input_market.price_trends = struct();

% 3.3 初始化环境状态
environmental_state = struct();
environmental_state.quality_index = 0.6;  % 环境质量指数
environmental_state.pollution_level = 0.3;  % 污染水平
environmental_state.climate_conditions = 0.7;  % 气候条件

%% 4. 主仿真循环
fprintf('\n=== 开始仿真循环 ===\n');

for t = 1:simulation_periods
    current_time = t;
    current_season = get_season(t);
    
    fprintf('\n--- 第 %d 期 (%s季) ---\n', t, current_season);
    
    %% 4.1 更新外部环境
    [agricultural_market, input_market, environmental_state] = update_external_environment(t, agricultural_market, input_market, environmental_state);
    
    %% 4.2 政府决策
    fprintf('政府制定政策...\n');
    
    % 收集系统状态信息
    system_info = collect_system_information(farmers, enterprises, agricultural_market, environmental_state, labor_market);
    
    % 政府基于预期做出政策决策
    government_decision = government.make_decision_with_expectations(system_info);
    
    % 政策影响传播到市场
    [agricultural_market, input_market] = apply_government_policies(government_decision, agricultural_market, input_market);
    
    %% 4.3 企业决策
    fprintf('企业制定经营策略...\n');
    
    enterprise_decisions = cell(length(enterprises), 1);
    for i = 1:length(enterprises)
        % 收集企业相关市场信息
        market_info = collect_enterprise_market_info(enterprises{i}, agricultural_market, input_market, farmers);
        
        % 企业基于预期做出决策
        enterprise_decisions{i} = enterprises{i}.make_decision_with_expectations(market_info);
    end
    
    %% 4.4 劳动力市场清算
    fprintf('劳动力市场运行...\n');
    
    % 清空上期参与者
    labor_market.clear_participants();
    
    % 添加农户劳动力供给
    for i = 1:length(farmers)
        labor_market.add_farmer_supplier(farmers{i});
    end
    
    % 添加企业劳动力需求
    for i = 1:length(enterprises)
        labor_market.add_enterprise_demander(enterprises{i});
    end
    
    % 市场清算
    [labor_matches, labor_outcomes] = labor_market.clear_labor_market(current_season);
    
    %% 4.5 农户决策
    fprintf('农户制定农业生产计划...\n');
    
    farmer_decisions = cell(length(farmers), 1);
    for i = 1:length(farmers)
        % 收集农户相关信息（包括政策、市场价格、劳动力收入等）
        farmer_info = collect_farmer_information(farmers{i}, agricultural_market, input_market, government_decision, labor_matches);
        
        % 农户基于预期做出决策
        farmer_decisions{i} = farmers{i}.make_decision_with_expectations(farmer_info);
    end
    
    %% 4.6 市场交互和结果计算
    fprintf('计算市场均衡和结果...\n');
    
    % 农产品市场交易
    agricultural_outcomes = simulate_agricultural_market(farmers, farmer_decisions, agricultural_market);
    
    % 投入品市场交易
    input_outcomes = simulate_input_market(farmers, farmer_decisions, enterprises, enterprise_decisions, input_market);
    
    % 环境影响计算
    environmental_outcomes = calculate_environmental_impacts(farmers, farmer_decisions, enterprises, enterprise_decisions, environmental_state);
    
    % 经济影响计算
    economic_outcomes = calculate_economic_impacts(agricultural_outcomes, input_outcomes, labor_outcomes);
    
    %% 4.7 智能体观测学习
    fprintf('智能体更新预期...\n');
    
    % 政府观测学习
    government_observations = create_government_observations(agricultural_outcomes, environmental_outcomes, economic_outcomes);
    government.update_government_observations(government_observations.system_data, government_observations.feedback_data, current_time);
    
    % 企业观测学习
    for i = 1:length(enterprises)
        enterprise_observations = create_enterprise_observations(enterprises{i}, input_outcomes, agricultural_outcomes, government_decision);
        enterprises{i}.update_enterprise_observations(enterprise_observations.market_data, enterprise_observations.policy_data, current_time);
    end
    
    % 农户观测学习
    for i = 1:length(farmers)
        farmer_observations = create_farmer_observations(farmers{i}, agricultural_outcomes, input_outcomes, government_decision, labor_outcomes);
        farmers{i}.update_farmer_observations(farmer_observations.market_data, farmer_observations.policy_data, current_time);
    end
    
    %% 4.8 记录仿真结果
    period_results = struct();
    period_results.time = t;
    period_results.season = current_season;
    period_results.government_decision = government_decision;
    period_results.agricultural_outcomes = agricultural_outcomes;
    period_results.input_outcomes = input_outcomes;
    period_results.environmental_outcomes = environmental_outcomes;
    period_results.economic_outcomes = economic_outcomes;
    period_results.labor_outcomes = labor_outcomes;
    
    simulation_results.time_series = [simulation_results.time_series; period_results];
    
    % 定期打印状态
    if mod(t, 12) == 0
        fprintf('\n=== 第 %d 年结束状态摘要 ===\n', t/12);
        print_system_summary(government, enterprises, farmers, labor_market, period_results);
    end
    
    %% 4.9 系统适应和调整
    if mod(t, 6) == 0  % 每半年进行一次系统调整
        % 可以在这里添加系统级的适应机制
        % 例如：市场结构调整、新技术引入、政策制度变迁等
    end
end

%% 5. 仿真结果分析
fprintf('\n=== 仿真结果分析 ===\n');

% 5.1 时间序列分析
analyze_time_series_results(simulation_results);

% 5.2 预期学习表现分析
analyze_expectation_learning_performance(government, enterprises, farmers);

% 5.3 政策效果分析
analyze_policy_effectiveness(simulation_results);

% 5.4 农户-企业-政府协同效果分析
analyze_coordination_mechanisms(simulation_results);

% 5.5 生成可视化图表
generate_visualization_plots(simulation_results);

fprintf('\n=== 仿真完成 ===\n');

%% ========== 辅助函数 ==========

function season = get_season(period)
    % 根据期数确定季节
    month = mod(period - 1, 12) + 1;
    if month >= 3 && month <= 5
        season = 'spring';
    elseif month >= 6 && month <= 8
        season = 'summer';
    elseif month >= 9 && month <= 11
        season = 'autumn';
    else
        season = 'winter';
    end
end

function [agri_market, input_market, env_state] = update_external_environment(t, agri_market, input_market, env_state)
    % 更新外部环境
    
    % 农产品价格波动
    price_shock = 0.02 * sin(2 * pi * t / 12) + 0.01 * randn();  % 季节性 + 随机冲击
    agri_market.current_price = agri_market.base_price * (1 + price_shock);
    
    % 投入品价格趋势
    input_market.current_fertilizer_price = input_market.fertilizer_base_price * (1 + 0.03 * t / 12 + 0.05 * randn());
    input_market.current_pesticide_price = input_market.pesticide_base_price * (1 + 0.02 * t / 12 + 0.04 * randn());
    
    % 环境状态演化
    env_state.quality_index = max(0.2, min(0.9, env_state.quality_index + 0.001 * randn()));
    env_state.pollution_level = max(0.1, min(0.8, env_state.pollution_level + 0.002 * randn()));
    
    % 气候条件（季节性+随机）
    season_effect = 0.1 * sin(2 * pi * t / 12);
    env_state.climate_conditions = max(0.3, min(0.9, 0.7 + season_effect + 0.05 * randn()));
end

function system_info = collect_system_information(farmers, enterprises, agri_market, env_state, labor_market)
    % 收集系统状态信息供政府决策使用
    
    system_info = struct();
    
    % 农户状况统计
    farmer_incomes = zeros(length(farmers), 1);
    farmer_satisfactions = zeros(length(farmers), 1);
    for i = 1:length(farmers)
        farmer_incomes(i) = farmers{i}.total_income;
        farmer_satisfactions(i) = farmers{i}.satisfaction_level;
    end
    
    system_info.average_farmer_income = mean(farmer_incomes);
    system_info.farmer_income_growth = 0.05;  % 简化，实际应基于历史数据
    system_info.farmer_satisfaction = mean(farmer_satisfactions);
    
    % 企业状况统计
    enterprise_outputs = 0;
    enterprise_emissions = 0;
    for i = 1:length(enterprises)
        enterprise_outputs = enterprise_outputs + enterprises{i}.current_production;
        enterprise_emissions = enterprise_emissions + enterprises{i}.current_production * enterprises{i}.emission_rate;
    end
    
    system_info.total_enterprise_output = enterprise_outputs;
    system_info.total_enterprise_emissions = enterprise_emissions;
    
    % 市场状况
    system_info.agricultural_price = agri_market.current_price;
    system_info.input_price_index = (agri_market.current_fertilizer_price + agri_market.current_pesticide_price) / 2;
    
    % 环境状况
    system_info.environmental_quality = env_state.quality_index;
    system_info.pollution_level = env_state.pollution_level;
    
    % 劳动力市场状况
    labor_summary = labor_market.get_market_summary();
    system_info.unemployment_rate = labor_summary.unemployment_rate;
    system_info.average_wage = labor_summary.current_wage_rates.unskilled;
end

function market_info = collect_enterprise_market_info(enterprise, agri_market, input_market, farmers)
    % 收集企业相关的市场信息
    
    market_info = struct();
    
    % 需求信息（来自农户）
    total_demand = 0;
    for i = 1:length(farmers)
        if strcmp(enterprise.enterprise_type, 'fertilizer_producer')
            total_demand = total_demand + farmers{i}.land_holding * 0.3;  % 每亩0.3吨化肥需求
        elseif strcmp(enterprise.enterprise_type, 'pesticide_producer')
            total_demand = total_demand + farmers{i}.land_holding * 0.05;  % 每亩0.05吨农药需求
        end
    end
    
    market_info.farmer_demand = total_demand;
    market_info.agricultural_price = agri_market.current_price;
    
    % 投入成本信息
    market_info.raw_material_cost = input_market.fertilizer_base_price * 0.6;  % 原材料占成本60%
    
    % 竞争信息（简化）
    market_info.competition_intensity = 0.6 + 0.2 * randn();
    
    % 市场增长信息
    market_info.market_growth_rate = 0.03 + 0.02 * randn();
end

function farmer_info = collect_farmer_information(farmer, agri_market, input_market, government_decision, labor_matches)
    % 收集农户相关信息
    
    farmer_info = struct();
    
    % 农产品市场信息
    farmer_info.crop_price = agri_market.current_price;
    farmer_info.price_volatility = agri_market.price_volatility;
    
    % 投入品价格信息
    farmer_info.fertilizer_price = input_market.current_fertilizer_price;
    farmer_info.pesticide_price = input_market.current_pesticide_price;
    
    % 政策信息
    farmer_info.subsidy_rate = government_decision.agricultural_policy.subsidy_rate;
    farmer_info.quality_standard = government_decision.regulatory_policy.quality_standard;
    farmer_info.environmental_tax = government_decision.environmental_policy.emission_tax_rate;
    
    % 劳动力市场信息
    farmer_labor_income = 0;
    for i = 1:size(labor_matches, 1)
        if labor_matches(i).farmer_id == farmer.agent_id
            farmer_labor_income = farmer_labor_income + labor_matches(i).daily_wage * 20;  % 假设月工作20天
        end
    end
    farmer_info.off_farm_income = farmer_labor_income;
    
    % 技术信息
    farmer_info.technology_cost = 5000 + 2000 * randn();
    farmer_info.technology_effectiveness = 0.8 + 0.1 * randn();
end

function [agri_market, input_market] = apply_government_policies(government_decision, agri_market, input_market)
    % 应用政府政策到市场
    
    % 农业补贴影响农户收入，间接影响需求
    subsidy_effect = government_decision.agricultural_policy.subsidy_rate;
    agri_market.effective_price = agri_market.current_price * (1 + subsidy_effect);
    
    % 环境税影响企业成本
    env_tax = government_decision.environmental_policy.emission_tax_rate;
    input_market.effective_fertilizer_price = input_market.current_fertilizer_price * (1 + env_tax * 0.5);
    input_market.effective_pesticide_price = input_market.current_pesticide_price * (1 + env_tax * 0.3);
    
    % 绿色补贴降低清洁技术成本
    green_subsidy = government_decision.environmental_policy.green_subsidy_rate;
    input_market.green_technology_discount = green_subsidy;
end

function agricultural_outcomes = simulate_agricultural_market(farmers, farmer_decisions, agri_market)
    % 模拟农产品市场交易
    
    agricultural_outcomes = struct();
    
    % 总产量和总收入
    total_output = 0;
    total_revenue = 0;
    
    for i = 1:length(farmers)
        farmer_output = farmer_decisions{i}.production_plan.expected_yield * farmers{i}.land_holding;
        farmer_revenue = farmer_output * agri_market.effective_price;
        
        total_output = total_output + farmer_output;
        total_revenue = total_revenue + farmer_revenue;
        
        % 更新农户收入
        farmers{i}.total_income = farmer_revenue + farmers{i}.off_farm_income;
    end
    
    agricultural_outcomes.total_output = total_output;
    agricultural_outcomes.total_revenue = total_revenue;
    agricultural_outcomes.average_price = agri_market.effective_price;
    agricultural_outcomes.price_volatility = agri_market.price_volatility;
end

function input_outcomes = simulate_input_market(farmers, farmer_decisions, enterprises, enterprise_decisions, input_market)
    % 模拟投入品市场交易
    
    input_outcomes = struct();
    
    % 农户需求汇总
    total_fertilizer_demand = 0;
    total_pesticide_demand = 0;
    
    for i = 1:length(farmers)
        if isfield(farmer_decisions{i}, 'input_plan')
            total_fertilizer_demand = total_fertilizer_demand + farmer_decisions{i}.input_plan.fertilizer_amount;
            total_pesticide_demand = total_pesticide_demand + farmer_decisions{i}.input_plan.pesticide_amount;
        end
    end
    
    % 企业供给汇总
    total_fertilizer_supply = 0;
    total_pesticide_supply = 0;
    
    for i = 1:length(enterprises)
        if strcmp(enterprises{i}.enterprise_type, 'fertilizer_producer')
            total_fertilizer_supply = total_fertilizer_supply + enterprise_decisions{i}.production_plan.target_output;
        elseif strcmp(enterprises{i}.enterprise_type, 'pesticide_producer')
            total_pesticide_supply = total_pesticide_supply + enterprise_decisions{i}.production_plan.target_output;
        end
    end
    
    % 市场清算（简化为供需平衡）
    input_outcomes.fertilizer_price = input_market.effective_fertilizer_price;
    input_outcomes.pesticide_price = input_market.effective_pesticide_price;
    input_outcomes.fertilizer_quantity = min(total_fertilizer_demand, total_fertilizer_supply);
    input_outcomes.pesticide_quantity = min(total_pesticide_demand, total_pesticide_supply);
    
    % 供需平衡度
    input_outcomes.fertilizer_balance = total_fertilizer_supply / max(total_fertilizer_demand, 1);
    input_outcomes.pesticide_balance = total_pesticide_supply / max(total_pesticide_demand, 1);
end

function environmental_outcomes = calculate_environmental_impacts(farmers, farmer_decisions, enterprises, enterprise_decisions, env_state)
    % 计算环境影响
    
    environmental_outcomes = struct();
    
    % 农业污染
    agricultural_pollution = 0;
    for i = 1:length(farmers)
        if isfield(farmer_decisions{i}, 'input_plan')
            pollution_from_inputs = farmer_decisions{i}.input_plan.fertilizer_amount * 0.1 + ...
                                  farmer_decisions{i}.input_plan.pesticide_amount * 0.3;
            agricultural_pollution = agricultural_pollution + pollution_from_inputs;
        end
    end
    
    % 工业污染
    industrial_pollution = 0;
    for i = 1:length(enterprises)
        enterprise_pollution = enterprise_decisions{i}.production_plan.target_output * enterprises{i}.emission_rate;
        industrial_pollution = industrial_pollution + enterprise_pollution;
    end
    
    % 总体环境影响
    total_pollution = agricultural_pollution + industrial_pollution;
    environmental_outcomes.total_pollution = total_pollution;
    environmental_outcomes.agricultural_pollution = agricultural_pollution;
    environmental_outcomes.industrial_pollution = industrial_pollution;
    
    % 环境质量变化
    pollution_impact = -total_pollution / 10000;  % 标准化影响
    environmental_outcomes.quality_change = pollution_impact;
    environmental_outcomes.quality_improvement = max(0, -pollution_impact);
    
    % 政策成功率（简化计算）
    if total_pollution < env_state.pollution_level * 50000
        environmental_outcomes.policy_success_rate = 0.8;
    else
        environmental_outcomes.policy_success_rate = 0.4;
    end
end

function economic_outcomes = calculate_economic_impacts(agricultural_outcomes, input_outcomes, labor_outcomes)
    % 计算经济影响
    
    economic_outcomes = struct();
    
    % GDP增长率（简化）
    total_value_added = agricultural_outcomes.total_revenue + input_outcomes.fertilizer_quantity * input_outcomes.fertilizer_price * 0.2;
    economic_outcomes.gdp_growth = 0.05 + 0.02 * randn();  % 基础增长率 + 随机波动
    
    % 竞争力指数
    economic_outcomes.competitiveness_index = 0.7 + 0.1 * randn();
    
    % 就业和收入
    economic_outcomes.employment_rate = 1 - labor_outcomes.unemployment_rate;
    economic_outcomes.average_income = agricultural_outcomes.total_revenue / 50;  % 简化为农户数量
    
    economic_outcomes.growth_rate = economic_outcomes.gdp_growth;
end

function government_obs = create_government_observations(agri_outcomes, env_outcomes, econ_outcomes)
    % 创建政府观测数据
    
    government_obs = struct();
    
    % 系统数据
    government_obs.system_data = struct();
    government_obs.system_data.environmental_outcomes = env_outcomes;
    government_obs.system_data.economic_outcomes = econ_outcomes;
    government_obs.system_data.social_outcomes = struct();
    government_obs.system_data.social_outcomes.farmer_income_change = 0.06;  % 简化
    government_obs.system_data.social_outcomes.satisfaction_score = 0.7;
    
    % 反馈数据
    government_obs.feedback_data = struct();
    government_obs.feedback_data.implementation_feedback = struct();
    government_obs.feedback_data.implementation_feedback.difficulty_score = 0.5;
    government_obs.feedback_data.implementation_feedback.average_compliance_cost = 1000000;
    government_obs.feedback_data.implementation_feedback.political_support = 0.65;
end

function enterprise_obs = create_enterprise_observations(enterprise, input_outcomes, agri_outcomes, government_decision)
    % 创建企业观测数据
    
    enterprise_obs = struct();
    
    % 市场数据
    enterprise_obs.market_data = struct();
    enterprise_obs.market_data.farmer_demand = struct();
    if strcmp(enterprise.enterprise_type, 'fertilizer_producer')
        enterprise_obs.market_data.farmer_demand.fertilizer_producer = input_outcomes.fertilizer_quantity;
    else
        enterprise_obs.market_data.farmer_demand.pesticide_producer = input_outcomes.pesticide_quantity;
    end
    
    enterprise_obs.market_data.input_material_costs = struct();
    enterprise_obs.market_data.input_material_costs.average = 1200;
    
    enterprise_obs.market_data.competition_indices = struct();
    enterprise_obs.market_data.competition_indices.(enterprise.enterprise_type) = 0.6;
    
    enterprise_obs.market_data.labor_costs = struct();
    enterprise_obs.market_data.labor_costs.average_annual = 60000;
    
    % 政策数据
    enterprise_obs.policy_data = struct();
    enterprise_obs.policy_data.environmental_tax_rate = government_decision.environmental_policy.emission_tax_rate;
    enterprise_obs.policy_data.regulation_stringency = government_decision.regulatory_policy.quality_standard;
end

function farmer_obs = create_farmer_observations(farmer, agri_outcomes, input_outcomes, government_decision, labor_outcomes)
    % 创建农户观测数据
    
    farmer_obs = struct();
    
    % 市场数据
    farmer_obs.market_data = struct();
    farmer_obs.market_data.crop_prices = agri_outcomes.average_price;
    farmer_obs.market_data.input_costs = struct();
    farmer_obs.market_data.input_costs.fertilizer = input_outcomes.fertilizer_price;
    farmer_obs.market_data.input_costs.pesticide = input_outcomes.pesticide_price;
    
    farmer_obs.market_data.labor_market = struct();
    farmer_obs.market_data.labor_market.wage_rates = labor_outcomes.average_wage;
    farmer_obs.market_data.labor_market.employment_opportunities = 1 - labor_outcomes.unemployment_rate;
    
    % 政策数据
    farmer_obs.policy_data = struct();
    farmer_obs.policy_data.subsidy_rates = government_decision.agricultural_policy.subsidy_rate;
    farmer_obs.policy_data.environmental_regulations = government_decision.regulatory_policy.quality_standard;
    farmer_obs.policy_data.technology_support = government_decision.support_policy.training_programs;
end

function print_system_summary(government, enterprises, farmers, labor_market, period_results)
    % 打印系统状态摘要
    
    fprintf('政府政策状态：\n');
    government.print_government_status();
    
    fprintf('企业状态样例（前2家）：\n');
    for i = 1:min(2, length(enterprises))
        enterprises{i}.print_enterprise_status();
    end
    
    fprintf('农户状态样例（前3户）：\n');
    for i = 1:min(3, length(farmers))
        farmers{i}.print_farmer_status();
    end
    
    fprintf('劳动力市场状态：\n');
    labor_market.print_market_status();
    
    fprintf('期间结果摘要：\n');
    fprintf('  农业总产量: %.0f 公斤\n', period_results.agricultural_outcomes.total_output);
    fprintf('  农业总收入: %.0f 元\n', period_results.agricultural_outcomes.total_revenue);
    fprintf('  环境质量变化: %.3f\n', period_results.environmental_outcomes.quality_change);
    fprintf('  经济增长率: %.2f%%\n', period_results.economic_outcomes.growth_rate * 100);
end

function analyze_time_series_results(simulation_results)
    % 分析时间序列结果
    
    fprintf('时间序列分析：\n');
    
    time_series = simulation_results.time_series;
    n_periods = length(time_series);
    
    % 提取关键指标
    gdp_growth = zeros(n_periods, 1);
    env_quality = zeros(n_periods, 1);
    policy_effectiveness = zeros(n_periods, 1);
    
    for i = 1:n_periods
        gdp_growth(i) = time_series(i).economic_outcomes.growth_rate;
        env_quality(i) = time_series(i).environmental_outcomes.quality_improvement;
        policy_effectiveness(i) = time_series(i).environmental_outcomes.policy_success_rate;
    end
    
    fprintf('  平均GDP增长率: %.2f%%\n', mean(gdp_growth) * 100);
    fprintf('  平均环境质量改善: %.3f\n', mean(env_quality));
    fprintf('  平均政策有效性: %.3f\n', mean(policy_effectiveness));
    
    % 趋势分析
    if length(gdp_growth) > 12
        recent_growth = mean(gdp_growth(end-11:end));
        early_growth = mean(gdp_growth(1:12));
        fprintf('  GDP增长趋势: %.3f (近期) vs %.3f (早期)\n', recent_growth, early_growth);
    end
end

function analyze_expectation_learning_performance(government, enterprises, farmers)
    % 分析预期学习表现
    
    fprintf('\n预期学习表现分析：\n');
    
    % 政府学习表现
    gov_summary = government.get_expectation_summary();
    if ~isempty(fieldnames(gov_summary)) && ~isnan(gov_summary.average_accuracy)
        fprintf('  政府预期准确性: %.3f\n', gov_summary.average_accuracy);
    end
    
    % 企业学习表现
    enterprise_accuracies = [];
    for i = 1:length(enterprises)
        ent_summary = enterprises{i}.get_expectation_summary();
        if ~isempty(fieldnames(ent_summary)) && ~isnan(ent_summary.average_accuracy)
            enterprise_accuracies = [enterprise_accuracies, ent_summary.average_accuracy];
        end
    end
    
    if ~isempty(enterprise_accuracies)
        fprintf('  企业平均预期准确性: %.3f\n', mean(enterprise_accuracies));
    end
    
    % 农户学习表现
    farmer_accuracies = [];
    for i = 1:length(farmers)
        farmer_summary = farmers{i}.get_expectation_summary();
        if ~isempty(fieldnames(farmer_summary)) && ~isnan(farmer_summary.average_accuracy)
            farmer_accuracies = [farmer_accuracies, farmer_summary.average_accuracy];
        end
    end
    
    if ~isempty(farmer_accuracies)
        fprintf('  农户平均预期准确性: %.3f\n', mean(farmer_accuracies));
    end
end

function analyze_policy_effectiveness(simulation_results)
    % 分析政策有效性
    
    fprintf('\n政策有效性分析：\n');
    
    time_series = simulation_results.time_series;
    n_periods = length(time_series);
    
    if n_periods > 24  % 至少2年数据
        % 政策变化与结果关联分析
        policy_changes = [];
        outcome_changes = [];
        
        for i = 2:n_periods
            % 简化的政策变化指标
            prev_tax = time_series(i-1).government_decision.environmental_policy.emission_tax_rate;
            curr_tax = time_series(i).government_decision.environmental_policy.emission_tax_rate;
            policy_change = abs(curr_tax - prev_tax);
            
            % 环境结果变化
            prev_env = time_series(i-1).environmental_outcomes.quality_improvement;
            curr_env = time_series(i).environmental_outcomes.quality_improvement;
            outcome_change = curr_env - prev_env;
            
            policy_changes = [policy_changes, policy_change];
            outcome_changes = [outcome_changes, outcome_change];
        end
        
        % 简单相关性分析
        if length(policy_changes) > 12
            correlation = corr(policy_changes', outcome_changes');
            fprintf('  政策调整与环境改善相关性: %.3f\n', correlation);
        end
    end
end

function analyze_coordination_mechanisms(simulation_results)
    % 分析协同机制效果
    
    fprintf('\n协同机制分析：\n');
    
    time_series = simulation_results.time_series;
    n_periods = length(time_series);
    
    % 分析系统稳定性
    if n_periods > 12
        gdp_volatility = std([time_series.economic_outcomes.growth_rate]);
        env_volatility = std([time_series.environmental_outcomes.quality_improvement]);
        
        fprintf('  经济增长波动性: %.4f\n', gdp_volatility);
        fprintf('  环境质量波动性: %.4f\n', env_volatility);
        
        % 系统韧性指标
        if gdp_volatility < 0.02 && env_volatility < 0.05
            fprintf('  系统韧性: 良好 (低波动性)\n');
        else
            fprintf('  系统韧性: 一般 (存在波动)\n');
        end
    end
    
    % 多目标平衡分析
    if n_periods > 6
        recent_periods = time_series(end-5:end);
        avg_growth = mean([recent_periods.economic_outcomes.growth_rate]);
        avg_env_improvement = mean([recent_periods.environmental_outcomes.quality_improvement]);
        
        balance_score = sqrt(avg_growth^2 + avg_env_improvement^2);
        fprintf('  经济-环境平衡得分: %.3f\n', balance_score);
    end
end

function generate_visualization_plots(simulation_results)
    % 生成可视化图表
    
    fprintf('\n正在生成可视化图表...\n');
    
    time_series = simulation_results.time_series;
    n_periods = length(time_series);
    
    if n_periods < 12
        fprintf('数据不足，跳过可视化\n');
        return;
    end
    
    % 提取数据
    time_points = 1:n_periods;
    gdp_growth = [time_series.economic_outcomes.growth_rate] * 100;
    env_quality = [time_series.environmental_outcomes.quality_improvement];
    emission_tax = [time_series(1:end).government_decision.environmental_policy.emission_tax_rate] * 100;
    
    % 创建图表
    figure('Position', [100, 100, 1200, 800]);
    
    % 子图1：经济增长与政策
    subplot(2, 2, 1);
    yyaxis left;
    plot(time_points, gdp_growth, 'b-', 'LineWidth', 2);
    ylabel('GDP增长率 (%)', 'Color', 'b');
    
    yyaxis right;
    plot(time_points, emission_tax, 'r--', 'LineWidth', 1.5);
    ylabel('排放税率 (%)', 'Color', 'r');
    
    xlabel('时期');
    title('经济增长与环境税政策');
    legend('GDP增长率', '排放税率', 'Location', 'best');
    grid on;
    
    % 子图2：环境质量改善
    subplot(2, 2, 2);
    plot(time_points, env_quality, 'g-', 'LineWidth', 2);
    xlabel('时期');
    ylabel('环境质量改善');
    title('环境质量改善趋势');
    grid on;
    
    % 子图3：政策有效性
    subplot(2, 2, 3);
    policy_effectiveness = [time_series.environmental_outcomes.policy_success_rate];
    plot(time_points, policy_effectiveness, 'm-', 'LineWidth', 2);
    xlabel('时期');
    ylabel('政策有效性');
    title('政策有效性演变');
    ylim([0, 1]);
    grid on;
    
    % 子图4：系统综合表现
    subplot(2, 2, 4);
    normalized_gdp = (gdp_growth - min(gdp_growth)) / (max(gdp_growth) - min(gdp_growth));
    normalized_env = (env_quality - min(env_quality)) / (max(env_quality) - min(env_quality));
    
    plot(time_points, normalized_gdp, 'b-', 'LineWidth', 1.5);
    hold on;
    plot(time_points, normalized_env, 'g-', 'LineWidth', 1.5);
    
    xlabel('时期');
    ylabel('标准化指标');
    title('系统综合表现');
    legend('经济表现', '环境表现', 'Location', 'best');
    grid on;
    
    % 保存图表
    saveas(gcf, '../results/agricultural_system_simulation.png');
    fprintf('图表已保存至 ../results/agricultural_system_simulation.png\n');
end 