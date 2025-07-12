% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % 带有预期形成功能的企业智能体
    % 展示如何将EER模型风格的AR(1)预期形成机制集成到具体的智能体决策中
    
    properties
        % 企业基本属性
        enterprise_type         % 'pesticide', 'fertilizer', 'processing'
        production_capacity = 1000
        technology_level = 0.5
        quality_level = 0.6
        
        % 市场和产品属性
        current_price = 50
        current_production = 500
        current_market_share = 0.05
        inventory_level = 100
        
        % 成本结构
        fixed_costs = 10000
        variable_cost_per_unit = 30
        rd_investment_rate = 0.02
        quality_investment_rate = 0.03
        
        % 环境和政策相关
        current_emission_rate = 0.1
        environmental_compliance_cost = 5000
        
        % 决策历史
        price_history = []
        production_history = []
        profit_history = []
        investment_history = []
        
        % 竞争者信息
        competitor_info = struct()
        market_conditions = struct()
        
        % 政策预期相关
        policy_expectations = struct()
        climate_expectations = struct()
    end
    
    methods
        function obj = EnterpriseAgentWithExpectations(agent_id, enterprise_type, params)
            % 构造函数
            
            % 定义企业特有的预期变量
            expectation_variables = obj.get_enterprise_expectation_variables(enterprise_type);
            
            % 调用父类构造函数
            obj = obj@AgentWithExpectations(agent_id, 'enterprise', expectation_variables);
            
            obj.enterprise_type = enterprise_type;
            
            % 初始化企业参数
            if nargin > 2 && ~isempty(params)
                obj.initialize_enterprise_parameters(params);
            else
                obj.initialize_default_enterprise_parameters();
            end
            
            % 设置企业特有的预期配置
            obj.configure_enterprise_expectations();
            
            fprintf('企业智能体 %d (%s) 初始化完成，具备预期形成能力\n', agent_id, enterprise_type);
        end
        
        function expectation_variables = get_enterprise_expectation_variables(obj, enterprise_type)
            % 根据企业类型获取预期变量 - 实现父类的抽象方法
            
            % 通用企业预期变量
            common_variables = {'product_price', 'input_cost', 'demand_quantity', ...
                               'competition_intensity', 'emission_tax_rate', 'quality_standard'};
            
            % 企业类型特有的预期变量
            switch enterprise_type
                case 'pesticide'
                    specific_variables = {'pesticide_regulation', 'bio_pesticide_demand', 'seasonal_demand'};
                case 'fertilizer'
                    specific_variables = {'fertilizer_subsidy', 'green_tech_cost', 'nitrogen_price'};
                case 'processing'
                    specific_variables = {'raw_material_price', 'food_safety_standard', 'export_demand'};
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
            
            if isfield(params, 'current_price')
                obj.current_price = params.current_price;
            end
            
            if isfield(params, 'variable_cost_per_unit')
                obj.variable_cost_per_unit = params.variable_cost_per_unit;
            end
            
            if isfield(params, 'rd_investment_rate')
                obj.rd_investment_rate = params.rd_investment_rate;
            end
        end
        
        function initialize_default_enterprise_parameters(obj)
            % 初始化默认企业参数
            
            switch obj.enterprise_type
                case 'pesticide'
                    obj.production_capacity = 2000;
                    obj.current_price = 80;
                    obj.variable_cost_per_unit = 50;
                    obj.rd_investment_rate = 0.04;
                    
                case 'fertilizer'
                    obj.production_capacity = 5000;
                    obj.current_price = 60;
                    obj.variable_cost_per_unit = 40;
                    obj.rd_investment_rate = 0.03;
                    
                case 'processing'
                    obj.production_capacity = 1500;
                    obj.current_price = 120;
                    obj.variable_cost_per_unit = 80;
                    obj.rd_investment_rate = 0.025;
            end
        end
        
        function configure_enterprise_expectations(obj)
            % 配置企业特有的预期边界和参数
            
            % 设置变量边界
            bounds = struct();
            bounds.product_price = [20, 200];
            bounds.input_cost = [10, 100];
            bounds.demand_quantity = [100, 5000];
            bounds.competition_intensity = [0.1, 0.9];
            bounds.emission_tax_rate = [0, 0.5];
            bounds.quality_standard = [0.3, 0.9];
            
            % 企业类型特有边界
            switch obj.enterprise_type
                case 'pesticide'
                    bounds.pesticide_regulation = [0, 1];
                    bounds.bio_pesticide_demand = [0, 1000];
                    bounds.seasonal_demand = [0.5, 2.0];
                    
                case 'fertilizer'
                    bounds.fertilizer_subsidy = [0, 0.3];
                    bounds.green_tech_cost = [1000, 50000];
                    bounds.nitrogen_price = [500, 2000];
                    
                case 'processing'
                    bounds.raw_material_price = [30, 120];
                    bounds.food_safety_standard = [0.5, 1.0];
                    bounds.export_demand = [0, 2000];
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
            obj.risk_attitude = 0.4;  % 企业相对风险厌恶
        end
        
        function decision = make_decision_with_expectations(obj, market_info, expectations)
            % 基于预期做出综合决策 - 实现父类的抽象方法
            
            if nargin < 3
                expectations = obj.expectation_module.form_expectations();
            end
            
            decision = struct();
            
            % 1. 生产决策
            decision.production = obj.make_production_decision(market_info, expectations);
            
            % 2. 定价决策
            decision.price = obj.make_pricing_decision(market_info, expectations);
            
            % 3. 投资决策
            decision.investment = obj.make_investment_decision(market_info, expectations);
            
            % 4. 环境策略决策
            decision.environmental_strategy = obj.make_environmental_decision(market_info, expectations);
            
            % 记录决策历史
            obj.record_decision(decision);
            
            fprintf('企业 %d 基于预期做出决策：生产%.0f单位，价格%.2f元，R&D投资%.0f元\n', ...
                    obj.agent_id, decision.production, decision.price, decision.investment.rd_amount);
        end
        
        function production_level = make_production_decision(obj, market_info, expectations)
            % 基于预期的生产决策
            
            % 获取需求预期
            expected_demand = obj.get_expectation('demand_quantity', 1);
            if isnan(expected_demand)
                expected_demand = obj.current_production; % 默认维持当前生产
            end
            
            % 获取价格预期
            expected_price = obj.get_expectation('product_price', 1);
            if isnan(expected_price)
                expected_price = obj.current_price;
            end
            
            % 获取成本预期
            expected_input_cost = obj.get_expectation('input_cost', 1);
            if isnan(expected_input_cost)
                expected_input_cost = obj.variable_cost_per_unit;
            end
            
            % 计算预期边际收益和边际成本
            expected_marginal_revenue = expected_price;
            expected_marginal_cost = expected_input_cost;
            
            % 考虑竞争强度对定价能力的影响
            competition_intensity = obj.get_expectation('competition_intensity', 1);
            if ~isnan(competition_intensity)
                price_adjustment = 1 - competition_intensity * 0.2; % 竞争越激烈，价格越低
                expected_marginal_revenue = expected_marginal_revenue * price_adjustment;
            end
            
            % 基本的利润最大化决策
            if expected_marginal_revenue > expected_marginal_cost
                % 有利润空间，考虑增产
                demand_confidence = obj.get_prediction_confidence('demand_quantity');
                capacity_utilization = min(0.9, 0.6 + 0.4 * demand_confidence); % 根据需求预期置信度调整产能利用率
                
                production_level = min(obj.production_capacity * capacity_utilization, ...
                                     expected_demand * 1.1); % 不超过预期需求的110%
            else
                % 利润空间有限，保守生产
                production_level = min(obj.current_production * 0.9, expected_demand * 0.8);
            end
            
            % 考虑库存水平
            if obj.inventory_level > obj.current_production * 0.3
                production_level = production_level * 0.8; % 库存过高，减产
            elseif obj.inventory_level < obj.current_production * 0.1
                production_level = production_level * 1.2; % 库存过低，增产
            end
            
            % 确保在合理范围内
            production_level = max(obj.production_capacity * 0.2, ...
                                 min(obj.production_capacity, production_level));
        end
        
        function price = make_pricing_decision(obj, market_info, expectations)
            % 基于预期的定价决策
            
            % 获取成本预期
            expected_input_cost = obj.get_expectation('input_cost', 1);
            if isnan(expected_input_cost)
                expected_input_cost = obj.variable_cost_per_unit;
            end
            
            % 基础成本加成定价
            markup_rate = 0.4; % 基础加成率40%
            base_price = expected_input_cost * (1 + markup_rate);
            
            % 根据需求预期调整价格
            expected_demand = obj.get_expectation('demand_quantity', 1);
            if ~isnan(expected_demand)
                demand_growth = (expected_demand - obj.current_production) / obj.current_production;
                demand_adjustment = 1 + demand_growth * 0.3; % 需求增长30%时，价格上调30%*0.3=9%
                base_price = base_price * demand_adjustment;
            end
            
            % 根据竞争强度调整价格
            competition_intensity = obj.get_expectation('competition_intensity', 1);
            if ~isnan(competition_intensity)
                competition_adjustment = 1 - competition_intensity * 0.15; % 最大下调15%
                base_price = base_price * competition_adjustment;
            end
            
            % 质量溢价
            quality_premium = 1 + (obj.quality_level - 0.5) * 0.2; % 质量每提高0.1，价格溢价2%
            base_price = base_price * quality_premium;
            
            % 政策影响调整
            expected_emission_tax = obj.get_expectation('emission_tax_rate', 1);
            if ~isnan(expected_emission_tax)
                emission_cost_per_unit = expected_emission_tax * obj.current_emission_rate * 100; % 假设单位排放成本
                base_price = base_price + emission_cost_per_unit;
            end
            
            % 价格平滑调整（避免剧烈波动）
            price_change_limit = 0.1; % 最大10%的价格变化
            max_price = obj.current_price * (1 + price_change_limit);
            min_price = obj.current_price * (1 - price_change_limit);
            
            price = max(min_price, min(max_price, base_price));
            
            % 确保盈利性
            min_profitable_price = expected_input_cost * 1.05; % 至少5%毛利
            price = max(price, min_profitable_price);
        end
        
        function investment = make_investment_decision(obj, market_info, expectations)
            % 基于预期的投资决策
            
            investment = struct();
            
            % 计算可用投资资金
            estimated_revenue = obj.current_price * obj.current_production;
            estimated_costs = obj.fixed_costs + obj.variable_cost_per_unit * obj.current_production;
            estimated_profit = estimated_revenue - estimated_costs;
            available_funds = max(0, estimated_profit * 0.6); % 60%利润用于投资
            
            % R&D投资决策
            investment.rd_amount = obj.decide_rd_investment(expectations, available_funds);
            
            % 质量投资决策
            investment.quality_amount = obj.decide_quality_investment(expectations, available_funds);
            
            % 环保投资决策
            investment.environmental_amount = obj.decide_environmental_investment(expectations, available_funds);
            
            % 产能投资决策
            investment.capacity_amount = obj.decide_capacity_investment(expectations, available_funds);
            
            % 确保总投资不超过可用资金
            total_investment = investment.rd_amount + investment.quality_amount + ...
                             investment.environmental_amount + investment.capacity_amount;
            
            if total_investment > available_funds
                scaling_factor = available_funds / total_investment;
                investment.rd_amount = investment.rd_amount * scaling_factor;
                investment.quality_amount = investment.quality_amount * scaling_factor;
                investment.environmental_amount = investment.environmental_amount * scaling_factor;
                investment.capacity_amount = investment.capacity_amount * scaling_factor;
            end
        end
        
        function rd_investment = decide_rd_investment(obj, expectations, available_funds)
            % R&D投资决策
            
            % 基础R&D投资
            base_rd = available_funds * obj.rd_investment_rate;
            
            % 根据竞争预期调整
            competition_intensity = obj.get_expectation('competition_intensity', 2); % 2期预期
            if ~isnan(competition_intensity)
                competition_adjustment = 1 + competition_intensity * 0.5; % 竞争越激烈，R&D投资越多
                base_rd = base_rd * competition_adjustment;
            end
            
            % 根据质量标准预期调整
            expected_quality_standard = obj.get_expectation('quality_standard', 3); % 3期预期
            if ~isnan(expected_quality_standard)
                if expected_quality_standard > obj.quality_level
                    quality_gap = expected_quality_standard - obj.quality_level;
                    quality_adjustment = 1 + quality_gap * 2; % 质量缺口越大，R&D投资越多
                    base_rd = base_rd * quality_adjustment;
                end
            end
            
            % 确保在合理范围内
            rd_investment = max(available_funds * 0.01, min(available_funds * 0.4, base_rd));
        end
        
        function quality_investment = decide_quality_investment(obj, expectations, available_funds)
            % 质量投资决策
            
            base_quality_investment = available_funds * obj.quality_investment_rate;
            
            % 根据价格预期调整
            expected_price = obj.get_expectation('product_price', 2);
            if ~isnan(expected_price)
                price_growth = (expected_price - obj.current_price) / obj.current_price;
                if price_growth > 0
                    price_adjustment = 1 + price_growth; % 价格上涨预期，增加质量投资
                    base_quality_investment = base_quality_investment * price_adjustment;
                end
            end
            
            quality_investment = max(0, min(available_funds * 0.3, base_quality_investment));
        end
        
        function env_investment = decide_environmental_investment(obj, expectations, available_funds)
            % 环保投资决策
            
            % 基础环保投资
            base_env_investment = obj.environmental_compliance_cost * 0.1;
            
            % 根据排放税预期调整
            expected_emission_tax = obj.get_expectation('emission_tax_rate', 6); % 6期预期
            if ~isnan(expected_emission_tax)
                if expected_emission_tax > 0.1 % 如果预期排放税超过10%
                    tax_adjustment = expected_emission_tax * 10; % 税率每增加1%，环保投资增加10倍
                    base_env_investment = base_env_investment * (1 + tax_adjustment);
                end
            end
            
            env_investment = max(0, min(available_funds * 0.25, base_env_investment));
        end
        
        function capacity_investment = decide_capacity_investment(obj, expectations, available_funds)
            % 产能投资决策
            
            % 根据需求预期决定是否扩产
            expected_demand = obj.get_expectation('demand_quantity', 4); % 4期预期
            
            if isnan(expected_demand)
                capacity_investment = 0;
                return;
            end
            
            % 如果预期需求显著超过当前产能
            demand_capacity_ratio = expected_demand / obj.production_capacity;
            
            if demand_capacity_ratio > 0.85 % 产能利用率超过85%
                demand_confidence = obj.get_prediction_confidence('demand_quantity');
                
                if demand_confidence > 0.6 % 需求预期较为可靠
                    % 计算所需的产能扩张
                    capacity_expansion_ratio = (demand_capacity_ratio - 0.8) * 2; % 保持20%产能缓冲
                    capacity_investment = obj.production_capacity * capacity_expansion_ratio * 50; % 假设每单位产能成本50元
                    
                    capacity_investment = min(available_funds * 0.4, capacity_investment);
                else
                    capacity_investment = 0; % 需求不确定，不扩产
                end
            else
                capacity_investment = 0; % 产能充足，无需扩张
            end
        end
        
        function env_strategy = make_environmental_decision(obj, market_info, expectations)
            % 基于预期的环境策略决策
            
            env_strategy = struct();
            
            % 排放减少策略
            expected_emission_tax = obj.get_expectation('emission_tax_rate', 3);
            if ~isnan(expected_emission_tax) && expected_emission_tax > 0.05
                % 预期排放税较高，制定减排策略
                target_emission_reduction = min(0.3, expected_emission_tax * 2); % 最大减排30%
                env_strategy.emission_reduction_target = target_emission_reduction;
                env_strategy.green_technology_adoption = true;
            else
                env_strategy.emission_reduction_target = 0;
                env_strategy.green_technology_adoption = false;
            end
            
            % 质量标准合规策略
            expected_quality_standard = obj.get_expectation('quality_standard', 2);
            if ~isnan(expected_quality_standard)
                if expected_quality_standard > obj.quality_level
                    env_strategy.quality_upgrade_plan = true;
                    env_strategy.target_quality_level = expected_quality_standard * 1.05; % 略高于标准
                else
                    env_strategy.quality_upgrade_plan = false;
                    env_strategy.target_quality_level = obj.quality_level;
                end
            end
        end
        
        function record_decision(obj, decision)
            % 记录决策历史
            
            obj.price_history = [obj.price_history, decision.price];
            obj.production_history = [obj.production_history, decision.production];
            
            % 维护历史长度
            max_history = 24;
            if length(obj.price_history) > max_history
                obj.price_history = obj.price_history(end-max_history+1:end);
                obj.production_history = obj.production_history(end-max_history+1:end);
            end
        end
        
        function update_market_observations(obj, market_data, current_time)
            % 更新市场观测数据，触发预期学习
            
            % 准备观测数据
            observations = struct();
            
            if isfield(market_data, 'average_price')
                observations.product_price = market_data.average_price;
            end
            
            if isfield(market_data, 'total_demand')
                observations.demand_quantity = market_data.total_demand;
            end
            
            if isfield(market_data, 'input_prices')
                observations.input_cost = mean(market_data.input_prices);
            end
            
            if isfield(market_data, 'competition_index')
                observations.competition_intensity = market_data.competition_index;
            end
            
            if isfield(market_data, 'policy_rates')
                if isfield(market_data.policy_rates, 'emission_tax')
                    observations.emission_tax_rate = market_data.policy_rates.emission_tax;
                end
                if isfield(market_data.policy_rates, 'quality_standard')
                    observations.quality_standard = market_data.policy_rates.quality_standard;
                end
            end
            
            % 更新预期
            obj.update_expectations(observations, current_time);
            
            % 评估预测准确性并适应
            obj.evaluate_and_adapt_predictions(market_data);
        end
        
        function evaluate_and_adapt_predictions(obj, market_data)
            % 评估预测准确性并适应学习参数
            
            variables = obj.expectation_module.expectation_variables;
            
            for i = 1:length(variables)
                var_name = variables{i};
                
                if isfield(obj.expectation_module.current_expectations, var_name) && ...
                   ~isnan(obj.expectation_module.current_expectations.(var_name))
                    
                    predicted_value = obj.expectation_module.current_expectations.(var_name);
                    
                    % 获取实际值
                    actual_value = obj.get_actual_value(var_name, market_data);
                    
                    if ~isnan(actual_value)
                        % 评估并适应
                        obj.adapt_to_forecast_errors(var_name, actual_value, predicted_value);
                    end
                end
            end
        end
        
        function actual_value = get_actual_value(obj, var_name, market_data)
            % 从市场数据中提取实际值
            
            actual_value = NaN;
            
            switch var_name
                case 'product_price'
                    if isfield(market_data, 'average_price')
                        actual_value = market_data.average_price;
                    end
                case 'demand_quantity'
                    if isfield(market_data, 'total_demand')
                        actual_value = market_data.total_demand;
                    end
                case 'input_cost'
                    if isfield(market_data, 'input_prices')
                        actual_value = mean(market_data.input_prices);
                    end
                case 'competition_intensity'
                    if isfield(market_data, 'competition_index')
                        actual_value = market_data.competition_index;
                    end
                case 'emission_tax_rate'
                    if isfield(market_data, 'policy_rates') && isfield(market_data.policy_rates, 'emission_tax')
                        actual_value = market_data.policy_rates.emission_tax;
                    end
            end
        end
        
        function key_variables = identify_key_expectation_variables(obj)
            % 识别关键预期变量 - 实现父类的抽象方法
            
            % 基于当前业务状况和市场环境识别关键变量
            key_variables = {};
            
            % 价格和需求总是关键的
            key_variables = [key_variables, {'product_price', 'demand_quantity'}];
            
            % 根据企业类型添加特定关键变量
            switch obj.enterprise_type
                case 'pesticide'
                    key_variables = [key_variables, {'pesticide_regulation', 'seasonal_demand'}];
                case 'fertilizer'
                    key_variables = [key_variables, {'fertilizer_subsidy', 'green_tech_cost'}];
                case 'processing'
                    key_variables = [key_variables, {'raw_material_price', 'export_demand'}];
            end
            
            % 如果面临高竞争，竞争强度是关键变量
            current_competition = obj.get_expectation('competition_intensity', 1);
            if ~isnan(current_competition) && current_competition > 0.6
                key_variables = [key_variables, {'competition_intensity'}];
            end
            
            % 如果环保压力大，政策变量是关键
            current_emission_tax = obj.get_expectation('emission_tax_rate', 1);
            if ~isnan(current_emission_tax) && current_emission_tax > 0.1
                key_variables = [key_variables, {'emission_tax_rate', 'quality_standard'}];
            end
        end
        
        function print_enterprise_status(obj)
            % 打印企业状态，包括预期信息
            
            fprintf('\n=== 企业智能体 %d (%s) 状态报告 ===\n', obj.agent_id, obj.enterprise_type);
            
            % 基本经营状况
            fprintf('基本经营状况：\n');
            fprintf('  当前价格: %.2f 元\n', obj.current_price);
            fprintf('  当前产量: %.0f 单位\n', obj.current_production);
            fprintf('  产能利用率: %.1f%%\n', obj.current_production / obj.production_capacity * 100);
            fprintf('  技术水平: %.3f\n', obj.technology_level);
            fprintf('  质量水平: %.3f\n', obj.quality_level);
            
            % 预期信息
            fprintf('\n关键变量预期：\n');
            key_vars = obj.identify_key_expectation_variables();
            for i = 1:length(key_vars)
                var_name = key_vars{i};
                expectation = obj.get_expectation(var_name, 1);
                confidence = obj.get_prediction_confidence(var_name);
                
                fprintf('  %s: %.4f (置信度: %.3f)\n', var_name, expectation, confidence);
            end
            
            % 预期学习表现
            summary = obj.get_expectation_summary();
            if ~isnan(summary.average_accuracy)
                fprintf('\n预期学习表现：\n');
                fprintf('  平均预测准确性: %.3f\n', summary.average_accuracy);
                fprintf('  学习率: %.4f\n', obj.expectation_module.learning_rate);
                fprintf('  风险态度: %.3f\n', obj.risk_attitude);
            end
            
            fprintf('=======================================\n\n');
        end
    end
end 
