% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % 带有预期形成功能的农业企业智能体
    % 包括化肥生产企业和农药生产企业，重点关注与农户的供需关系
    
    properties
        % 企业基本属性
        enterprise_type         % 'fertilizer_producer', 'pesticide_producer'
        production_capacity = 10000  % 年生产能力（吨）
        technology_level = 0.6      % 技术水平 [0-1]
        quality_level = 0.7         % 产品质量水平 [0-1]
        market_share = 0.1          % 市场份额
        
        % 生产和成本结构
        current_production = 5000   % 当前产量（吨）
        current_price = 2000        % 当前价格（元/吨）
        production_cost_per_unit = 1500  % 单位生产成本
        fixed_costs = 5000000       % 年固定成本
        
        % 研发和质量投资
        rd_investment_rate = 0.03   % R&D投资率
        quality_improvement_rate = 0.02  % 质量改进投资率
        environmental_investment_rate = 0.015  % 环保投资率
        
        % 市场和客户关系
        farmer_customer_base = []   % 农户客户群体
        market_penetration = 0.3    % 市场渗透率
        customer_loyalty = 0.6      % 客户忠诚度
        distribution_network = 0.5  % 分销网络覆盖
        
        % 环境和政策合规
        emission_rate = 0.08        % 排放率（吨CO2/吨产品）
        environmental_compliance_score = 0.7  % 环保合规评分
        green_certification = false % 绿色认证状态
        
        % 劳动力需求（简化）
        labor_demand = struct()     % 劳动力需求结构
        wage_budget = 2000000       % 年工资预算
        skilled_labor_ratio = 0.4   % 技能劳动力比例
        
        % 决策历史和策略
        pricing_history = []
        production_history = []
        market_share_history = []
        investment_history = []
        
        % 预期和战略规划
        strategic_plan = struct()
        competitive_strategy = 'cost_leadership'  % 'cost_leadership', 'differentiation', 'focus'
    end
    
    methods
        function obj = AgriculturalEnterpriseWithExpectations(agent_id, enterprise_type, params)
            % 构造函数
            
            % 定义企业特有的预期变量
            expectation_variables = obj.get_enterprise_expectation_variables(enterprise_type);
            
            % 调用父类构造函数
            obj = obj@AgentWithExpectations(agent_id, 'agricultural_enterprise', expectation_variables);
            
            obj.enterprise_type = enterprise_type;
            
            % 初始化企业参数
            if nargin > 2 && ~isempty(params)
                obj.initialize_enterprise_parameters(params);
            else
                obj.initialize_default_enterprise_parameters();
            end
            
            % 配置企业特有的预期设置
            obj.configure_enterprise_expectations();
            
            fprintf('农业企业智能体 %d (%s) 初始化完成，具备预期形成能力\n', agent_id, enterprise_type);
        end
        
        function expectation_variables = get_enterprise_expectation_variables(obj, enterprise_type)
            % 根据企业类型获取预期变量
            
            % 通用企业预期变量
            common_variables = {'farmer_demand', 'input_material_cost', 'competition_intensity', 
                               'regulation_stringency', 'labor_cost', 'technology_cost', 
                               'environmental_tax_rate', 'market_growth_rate'};
            
            % 企业类型特有的预期变量
            switch enterprise_type
                case 'fertilizer_producer'
                    specific_variables = {'crop_planting_area', 'organic_fertilizer_trend', 
                                        'precision_agriculture_adoption', 'nitrogen_price_volatility'};
                case 'pesticide_producer'
                    specific_variables = {'pest_outbreak_probability', 'bio_pesticide_demand', 
                                        'resistance_development_rate', 'integrated_pest_management_adoption'};
                otherwise
                    specific_variables = {};
            end
            
            expectation_variables = [common_variables, specific_variables];
        end
        
        function initialize_enterprise_parameters(obj, params)
            % 初始化企业参数
            
            if isfield(params, 'production_capacity')
                obj.production_capacity = params.production_capacity;
            end
            
            if isfield(params, 'technology_level')
                obj.technology_level = params.technology_level;
            end
            
            if isfield(params, 'market_share')
                obj.market_share = params.market_share;
            end
            
            if isfield(params, 'competitive_strategy')
                obj.competitive_strategy = params.competitive_strategy;
            end
        end
        
        function initialize_default_enterprise_parameters(obj)
            % 根据企业类型初始化默认参数
            
            switch obj.enterprise_type
                case 'fertilizer_producer'
                    obj.production_capacity = 8000 + rand() * 4000;  % 8000-12000吨
                    obj.current_price = 1800 + rand() * 400;         % 1800-2200元/吨
                    obj.production_cost_per_unit = 1400 + rand() * 200;  % 1400-1600元/吨
                    obj.technology_level = 0.5 + rand() * 0.3;       % 0.5-0.8
                    obj.market_share = 0.05 + rand() * 0.15;         % 5%-20%
                    obj.emission_rate = 0.06 + rand() * 0.04;        % 0.06-0.10
                    
                case 'pesticide_producer'
                    obj.production_capacity = 2000 + rand() * 3000;  % 2000-5000吨
                    obj.current_price = 8000 + rand() * 4000;        % 8000-12000元/吨
                    obj.production_cost_per_unit = 6000 + rand() * 2000;  % 6000-8000元/吨
                    obj.technology_level = 0.6 + rand() * 0.3;       % 0.6-0.9
                    obj.market_share = 0.03 + rand() * 0.12;         % 3%-15%
                    obj.emission_rate = 0.04 + rand() * 0.03;        % 0.04-0.07
            end
        end
        
        function configure_enterprise_expectations(obj)
            % 配置企业特有的预期边界和参数
            
            % 设置变量边界
            bounds = struct();
            bounds.farmer_demand = [1000, 20000];           % 农户需求（吨）
            bounds.input_material_cost = [500, 1500];       % 原材料成本（元/吨）
            bounds.competition_intensity = [0.2, 0.9];      % 竞争强度
            bounds.regulation_stringency = [0.3, 0.8];      % 监管严格程度
            bounds.labor_cost = [50000, 120000];            % 劳动力成本（元/人/年）
            bounds.technology_cost = [100000, 1000000];     % 技术升级成本
            bounds.environmental_tax_rate = [0, 0.3];       % 环境税率
            bounds.market_growth_rate = [-0.1, 0.2];        % 市场增长率
            
            % 企业类型特有边界
            switch obj.enterprise_type
                case 'fertilizer_producer'
                    bounds.crop_planting_area = [50000, 200000];     % 作物种植面积（亩）
                    bounds.organic_fertilizer_trend = [0.1, 0.5];   % 有机肥趋势
                    bounds.precision_agriculture_adoption = [0.2, 0.8];  % 精准农业采用率
                    bounds.nitrogen_price_volatility = [0.05, 0.3]; % 氮肥价格波动率
                    
                case 'pesticide_producer'
                    bounds.pest_outbreak_probability = [0.1, 0.6];  % 病虫害爆发概率
                    bounds.bio_pesticide_demand = [0.1, 0.4];       % 生物农药需求
                    bounds.resistance_development_rate = [0.05, 0.2]; % 抗性发展率
                    bounds.integrated_pest_management_adoption = [0.2, 0.7]; % IPM采用率
            end
            
            % 应用边界
            variables = obj.expectation_module.expectation_variables;
            for i = 1:length(variables)
                var_name = variables{i};
                if isfield(bounds, var_name)
                    obj.expectation_module.variable_bounds.(var_name) = bounds.(var_name);
                end
            end
            
            % 设置企业特有的学习参数
            obj.expectation_module.learning_rate = 0.12;  % 企业学习较快
            obj.expectation_module.memory_length = 24;    % 记忆2年
            obj.risk_attitude = 0.6;  % 企业相对风险中性
        end
        
        function decision = make_decision_with_expectations(obj, market_info, expectations)
            % 基于预期做出综合企业决策 - 实现父类的抽象方法
            
            if nargin < 3
                expectations = obj.expectation_module.form_expectations();
            end
            
            decision = struct();
            
            % 1. 生产计划决策
            decision.production_plan = obj.make_production_decision(market_info, expectations);
            
            % 2. 定价策略决策
            decision.pricing_strategy = obj.make_pricing_decision(market_info, expectations);
            
            % 3. 投资决策
            decision.investment_plan = obj.make_investment_decision(market_info, expectations);
            
            % 4. 市场拓展决策
            decision.market_expansion = obj.make_market_expansion_decision(market_info, expectations);
            
            % 5. 劳动力需求决策（简化）
            decision.labor_demand = obj.make_labor_demand_decision(market_info, expectations);
            
            % 6. 环境合规决策
            decision.environmental_compliance = obj.make_environmental_decision(market_info, expectations);
            
            % 记录决策历史
            obj.record_enterprise_decision(decision);
            
            fprintf('农业企业 %d (%s) 基于预期做出决策：生产%.0f吨，价格%.0f元/吨，R&D投资%.0f万元\n', ...
                    obj.agent_id, obj.enterprise_type, decision.production_plan.target_output, ...
                    decision.pricing_strategy.unit_price, decision.investment_plan.rd_investment/10000);
        end
        
        function production_decision = make_production_decision(obj, market_info, expectations)
            % 基于预期的生产决策
            
            % 获取农户需求预期
            expected_farmer_demand = obj.get_expectation('farmer_demand', 2); % 2期预期
            if isnan(expected_farmer_demand)
                expected_farmer_demand = obj.current_production * 1.05;
            end
            
            % 获取竞争强度预期
            expected_competition = obj.get_expectation('competition_intensity', 1);
            if isnan(expected_competition)
                expected_competition = 0.5;
            end
            
            % 计算市场份额调整后的目标需求
            target_demand = expected_farmer_demand * obj.market_share;
            
            % 根据竞争强度调整生产策略
            competition_factor = 1 - expected_competition * 0.3;
            adjusted_target = target_demand * competition_factor;
            
            % 产能约束
            optimal_production = min(obj.production_capacity * 0.9, adjusted_target);
            
            production_decision = struct();
            production_decision.target_output = optimal_production;
            production_decision.capacity_utilization = optimal_production / obj.production_capacity;
            production_decision.expected_demand = expected_farmer_demand;
        end
        
        function pricing_decision = make_pricing_decision(obj, market_info, expectations)
            % 基于预期的定价决策
            
            % 获取成本预期
            expected_input_cost = obj.get_expectation('input_material_cost', 1);
            expected_labor_cost = obj.get_expectation('labor_cost', 1);
            expected_competition = obj.get_expectation('competition_intensity', 1);
            
            % 基础定价策略
            pricing_decision = struct();
            
            switch obj.competitive_strategy
                case 'cost_leadership'
                    markup_rate = 0.15 - expected_competition * 0.08;
                case 'differentiation'
                    quality_premium = 1 + (obj.quality_level - 0.5) * 0.4;
                    markup_rate = 0.25 - expected_competition * 0.05;
                case 'focus'
                    markup_rate = 0.2;
            end
            
            base_price = obj.production_cost_per_unit * (1 + markup_rate);
            
            % 价格平滑调整
            price_change_limit = 0.15;
            max_price = obj.current_price * (1 + price_change_limit);
            min_price = obj.current_price * (1 - price_change_limit);
            final_price = max(min_price, min(max_price, base_price));
            
            pricing_decision.unit_price = final_price;
            pricing_decision.markup_rate = markup_rate;
        end
        
        function investment_decision = make_investment_decision(obj, market_info, expectations)
            % 基于预期的投资决策
            
            % 估算可用投资资金
            estimated_revenue = obj.current_price * obj.current_production;
            estimated_costs = obj.production_cost_per_unit * obj.current_production + obj.fixed_costs;
            estimated_profit = max(0, estimated_revenue - estimated_costs);
            available_funds = estimated_profit * 0.7;
            
            investment_decision = struct();
            
            % R&D投资决策
            base_rd = available_funds * obj.rd_investment_rate;
            competition_2period = obj.get_expectation('competition_intensity', 2);
            if ~isnan(competition_2period)
                competition_adjustment = 1 + competition_2period * 0.4;
                base_rd = base_rd * competition_adjustment;
            end
            investment_decision.rd_investment = max(available_funds * 0.02, min(available_funds * 0.4, base_rd));
            
            % 质量改进投资
            investment_decision.quality_investment = available_funds * obj.quality_improvement_rate;
            
            % 环保投资
            env_tax_expectation = obj.get_expectation('environmental_tax_rate', 4);
            base_env_investment = available_funds * obj.environmental_investment_rate;
            if ~isnan(env_tax_expectation) && env_tax_expectation > 0.1
                tax_adjustment = 1 + env_tax_expectation * 3;
                base_env_investment = base_env_investment * tax_adjustment;
            end
            investment_decision.environmental_investment = max(available_funds * 0.01, min(available_funds * 0.3, base_env_investment));
            
            investment_decision.total_investment = investment_decision.rd_investment + ...
                                                 investment_decision.quality_investment + ...
                                                 investment_decision.environmental_investment;
        end
        
        function market_decision = make_market_expansion_decision(obj, market_info, expectations)
            % 市场拓展决策
            
            market_decision = struct();
            market_growth = obj.get_expectation('market_growth_rate', 3);
            
            if ~isnan(market_growth) && market_growth > 0.05
                market_decision.expand_market = true;
                market_decision.target_market_share_increase = min(0.05, market_growth * 0.3);
            else
                market_decision.expand_market = false;
            end
        end
        
        function labor_decision = make_labor_demand_decision(obj, market_info, expectations)
            % 劳动力需求决策（简化版本）
            
            expected_production = obj.get_expectation('farmer_demand', 1) * obj.market_share;
            if isnan(expected_production)
                expected_production = obj.current_production;
            end
            
            % 计算所需劳动力
            labor_productivity = 10; % 每人每年生产10吨
            total_labor_needed = ceil(expected_production / labor_productivity);
            skilled_labor_needed = ceil(total_labor_needed * obj.skilled_labor_ratio);
            unskilled_labor_needed = total_labor_needed - skilled_labor_needed;
            
            labor_decision = struct();
            labor_decision.total_demand = total_labor_needed;
            labor_decision.skilled_demand = skilled_labor_needed;
            labor_decision.unskilled_demand = unskilled_labor_needed;
            labor_decision.wage_budget = obj.wage_budget;
            labor_decision.average_wage_offer = obj.wage_budget / max(1, total_labor_needed);
            labor_decision.prefer_farmer_workers = true;
            labor_decision.farmer_worker_ratio = 0.6;
        end
        
        function env_decision = make_environmental_decision(obj, market_info, expectations)
            % 环境合规决策
            
            env_decision = struct();
            
            env_tax_expectation = obj.get_expectation('environmental_tax_rate', 3);
            regulation_expectation = obj.get_expectation('regulation_stringency', 2);
            
            % 排放减少目标
            if ~isnan(env_tax_expectation) && env_tax_expectation > 0.1
                target_reduction = min(0.3, env_tax_expectation * 1.5);
                env_decision.emission_reduction_target = target_reduction;
                env_decision.green_tech_adoption = true;
            else
                env_decision.emission_reduction_target = 0.05;
                env_decision.green_tech_adoption = false;
            end
            
            % 绿色认证策略
            if ~isnan(regulation_expectation) && regulation_expectation > 0.6
                env_decision.pursue_green_certification = true;
                env_decision.certification_timeline = 24;
            else
                env_decision.pursue_green_certification = false;
            end
        end
        
        function record_enterprise_decision(obj, decision)
            % 记录企业决策历史
            
            obj.pricing_history = [obj.pricing_history, decision.pricing_strategy.unit_price];
            obj.production_history = [obj.production_history, decision.production_plan.target_output];
            
            % 维护历史长度
            max_history = 36;
            if length(obj.pricing_history) > max_history
                obj.pricing_history = obj.pricing_history(end-max_history+1:end);
                obj.production_history = obj.production_history(end-max_history+1:end);
            end
        end
        
        function update_enterprise_observations(obj, market_data, policy_data, current_time)
            % 更新企业观测数据，触发预期学习
            
            observations = struct();
            
            if isfield(market_data, 'farmer_demand')
                observations.farmer_demand = market_data.farmer_demand.(obj.enterprise_type);
            end
            
            if isfield(market_data, 'input_material_costs')
                observations.input_material_cost = market_data.input_material_costs.average;
            end
            
            if isfield(market_data, 'competition_indices')
                observations.competition_intensity = market_data.competition_indices.(obj.enterprise_type);
            end
            
            if isfield(market_data, 'labor_costs')
                observations.labor_cost = market_data.labor_costs.average_annual;
            end
            
            if isfield(policy_data, 'environmental_tax_rate')
                observations.environmental_tax_rate = policy_data.environmental_tax_rate;
            end
            
            if isfield(policy_data, 'regulation_stringency')
                observations.regulation_stringency = policy_data.regulation_stringency;
            end
            
            % 更新预期
            obj.update_expectations(observations, current_time);
        end
        
        function key_variables = identify_key_expectation_variables(obj)
            % 识别关键预期变量 - 实现父类的抽象方法
            
            key_variables = {};
            
            % 需求和成本总是关键的
            key_variables = [key_variables, {'farmer_demand', 'input_material_cost'}];
            
            % 根据企业类型添加特定关键变量
            switch obj.enterprise_type
                case 'fertilizer_producer'
                    key_variables = [key_variables, {'crop_planting_area', 'precision_agriculture_adoption'}];
                case 'pesticide_producer'
                    key_variables = [key_variables, {'pest_outbreak_probability', 'bio_pesticide_demand'}];
            end
            
            % 根据竞争策略调整
            if strcmp(obj.competitive_strategy, 'differentiation')
                key_variables = [key_variables, {'regulation_stringency', 'technology_cost'}];
            elseif strcmp(obj.competitive_strategy, 'cost_leadership')
                key_variables = [key_variables, {'competition_intensity', 'labor_cost'}];
            end
            
            if obj.environmental_investment_rate > 0.02
                key_variables = [key_variables, {'environmental_tax_rate'}];
            end
        end
        
        function print_enterprise_status(obj)
            % 打印企业状态，包括预期信息
            
            fprintf('\n=== 农业企业智能体 %d (%s) 状态报告 ===\n', obj.agent_id, obj.enterprise_type);
            
            fprintf('基本企业状况：\n');
            fprintf('  生产能力: %.0f 吨/年\n', obj.production_capacity);
            fprintf('  当前产量: %.0f 吨\n', obj.current_production);
            fprintf('  当前价格: %.0f 元/吨\n', obj.current_price);
            fprintf('  市场份额: %.2f%%\n', obj.market_share * 100);
            fprintf('  技术水平: %.2f\n', obj.technology_level);
            fprintf('  质量水平: %.2f\n', obj.quality_level);
            
            fprintf('\n关键变量预期：\n');
            key_vars = obj.identify_key_expectation_variables();
            for i = 1:length(key_vars)
                var_name = key_vars{i};
                expectation = obj.get_expectation(var_name, 1);
                confidence = obj.get_prediction_confidence(var_name);
                
                fprintf('  %s: %.4f (置信度: %.3f)\n', var_name, expectation, confidence);
            end
            
            summary = obj.get_expectation_summary();
            if ~isnan(summary.average_accuracy)
                fprintf('\n预期学习表现：\n');
                fprintf('  平均预测准确性: %.3f\n', summary.average_accuracy);
                fprintf('  学习率: %.4f\n', obj.expectation_module.learning_rate);
                fprintf('  风险态度: %.3f\n', obj.risk_attitude);
            end
            
            fprintf('=====================================\n\n');
        end
    end
end 
