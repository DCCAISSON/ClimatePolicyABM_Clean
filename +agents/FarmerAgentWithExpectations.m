% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % 带有预期形成功能的农户智能体
    % 聚焦农业领域的农户决策：种植、投入、技术采用、风险管理
    
    properties
        % 农户基本属性
        land_holding = 10           % 土地规模（亩）
        farm_type = 'grain'         % 'grain', 'cash_crop', 'mixed'
        education_level = 0.5       % 教育水平 [0-1]
        age = 45                    % 年龄
        experience_years = 20       % 农业经验年数
        
        % 生产能力和资源
        capital_stock = 50000       % 农业资本存量（设备、工具等）
        credit_access = 0.6         % 信贷可得性 [0-1]
        labor_endowment = 2000      % 年劳动力供给（小时）
        
        % 当前生产状况
        current_crop_mix = struct() % 当前种植结构
        current_yield = 500         % 当前亩产（公斤/亩）
        current_input_use = struct() % 当前投入品使用
        current_technology_level = 0.4 % 当前技术水平
        
        % 决策偏好和约束
        risk_aversion = 0.6         % 风险厌恶程度 [0-1]
        subsistence_requirement = 20000 % 基本生活需求（元/年）
        investment_budget = 10000   % 年投资预算
        
        % 市场参与和信息获取
        market_participation = 0.8  % 市场参与度 [0-1]
        information_access = 0.5    % 信息获取能力 [0-1]
        social_network_size = 10    % 社交网络规模
        
        % 气候和环境适应
        climate_vulnerability = 0.3 % 气候脆弱性 [0-1]
        environmental_awareness = 0.4 % 环保意识 [0-1]
        
        % 决策历史
        crop_choice_history = []
        yield_history = []
        income_history = []
        technology_adoption_history = []
        
        % 适应策略
        adaptation_strategies = struct()
        insurance_participation = false
        cooperative_membership = false
    end
    
    methods
        function obj = FarmerAgentWithExpectations(agent_id, farm_type, params)
            % 构造函数
            
            % 定义农户特有的预期变量
            expectation_variables = obj.get_farmer_expectation_variables(farm_type);
            
            % 调用父类构造函数
            obj = obj@AgentWithExpectations(agent_id, 'farmer', expectation_variables);
            
            obj.farm_type = farm_type;
            
            % 初始化农户参数
            if nargin > 2 && ~isempty(params)
                obj.initialize_farmer_parameters(params);
            else
                obj.initialize_default_farmer_parameters();
            end
            
            % 配置农户特有的预期设置
            obj.configure_farmer_expectations();
            
            fprintf('农户智能体 %d (%s) 初始化完成，具备预期形成能力\n', agent_id, farm_type);
        end
        
        function expectation_variables = get_farmer_expectation_variables(obj, farm_type)
            % 根据农场类型获取预期变量
            
            % 通用农户预期变量
            common_variables = {'crop_price', 'input_cost', 'weather_risk', 'subsidy_rate', 
                               'land_rent', 'labor_wage', 'technology_cost', 'policy_uncertainty'};
            
            % 农场类型特有的预期变量
            switch farm_type
                case 'grain'
                    specific_variables = {'grain_policy_support', 'storage_price', 'transportation_cost'};
                case 'cash_crop'
                    specific_variables = {'export_demand', 'quality_premium', 'processing_price'};
                case 'mixed'
                    specific_variables = {'crop_diversification_benefit', 'market_risk_correlation'};
                otherwise
                    specific_variables = {};
            end
            
            expectation_variables = [common_variables, specific_variables];
        end
        
        function initialize_farmer_parameters(obj, params)
            % 初始化农户参数
            
            if isfield(params, 'land_holding')
                obj.land_holding = params.land_holding;
            end
            
            if isfield(params, 'education_level')
                obj.education_level = params.education_level;
            end
            
            if isfield(params, 'age')
                obj.age = params.age;
            end
            
            if isfield(params, 'risk_aversion')
                obj.risk_aversion = params.risk_aversion;
            end
            
            if isfield(params, 'credit_access')
                obj.credit_access = params.credit_access;
            end
        end
        
        function initialize_default_farmer_parameters(obj)
            % 初始化默认农户参数
            
            switch obj.farm_type
                case 'grain'
                    obj.land_holding = 8 + rand() * 7;  % 8-15亩
                    obj.risk_aversion = 0.5 + rand() * 0.3; % 相对保守
                    obj.current_technology_level = 0.6; % 粮食生产机械化程度较高
                    
                case 'cash_crop'
                    obj.land_holding = 5 + rand() * 10; % 5-15亩
                    obj.risk_aversion = 0.3 + rand() * 0.4; % 风险偏好较高
                    obj.current_technology_level = 0.4; % 技术水平中等
                    
                case 'mixed'
                    obj.land_holding = 10 + rand() * 10; % 10-20亩
                    obj.risk_aversion = 0.4 + rand() * 0.3; % 中等风险偏好
                    obj.current_technology_level = 0.5; % 综合技术水平
            end
        end
        
        function configure_farmer_expectations(obj)
            % 配置农户特有的预期边界和参数
            
            % 设置变量边界
            bounds = struct();
            bounds.crop_price = [2.0, 8.0];           % 农产品价格（元/公斤）
            bounds.input_cost = [100, 500];           % 投入品成本（元/亩）
            bounds.weather_risk = [0.1, 0.8];         % 天气风险概率
            bounds.subsidy_rate = [0, 0.3];           % 补贴率
            bounds.land_rent = [200, 1000];           % 土地租金（元/亩）
            bounds.labor_wage = [80, 200];            % 劳动力工资（元/天）
            bounds.technology_cost = [1000, 20000];   % 技术采用成本
            bounds.policy_uncertainty = [0.1, 0.7];   % 政策不确定性
            
            % 农场类型特有边界
            switch obj.farm_type
                case 'grain'
                    bounds.grain_policy_support = [0.1, 0.4];
                    bounds.storage_price = [1.8, 6.0];
                    bounds.transportation_cost = [0.1, 0.5];
                    
                case 'cash_crop'
                    bounds.export_demand = [0.8, 1.5];
                    bounds.quality_premium = [1.1, 2.0];
                    bounds.processing_price = [3.0, 10.0];
                    
                case 'mixed'
                    bounds.crop_diversification_benefit = [1.05, 1.3];
                    bounds.market_risk_correlation = [0.2, 0.8];
            end
            
            % 应用边界
            variables = obj.expectation_module.expectation_variables;
            for i = 1:length(variables)
                var_name = variables{i};
                if isfield(bounds, var_name)
                    obj.expectation_module.variable_bounds.(var_name) = bounds.(var_name);
                end
            end
            
            % 设置农户特有的学习参数
            obj.expectation_module.learning_rate = 0.08;  % 农户学习较慢
            obj.expectation_module.memory_length = 36;    % 记忆3年
            obj.risk_attitude = 1 - obj.risk_aversion;     % 风险态度与风险厌恶相反
        end
        
        function decision = make_decision_with_expectations(obj, market_info, expectations)
            % 基于预期做出综合农业决策 - 实现父类的抽象方法
            
            if nargin < 3
                expectations = obj.expectation_module.form_expectations();
            end
            
            decision = struct();
            
            % 1. 种植结构决策
            decision.crop_allocation = obj.make_crop_choice_decision(market_info, expectations);
            
            % 2. 投入品使用决策
            decision.input_usage = obj.make_input_decision(market_info, expectations);
            
            % 3. 技术采用决策
            decision.technology_adoption = obj.make_technology_decision(market_info, expectations);
            
            % 4. 风险管理决策
            decision.risk_management = obj.make_risk_management_decision(market_info, expectations);
            
            % 5. 劳动力配置决策
            decision.labor_allocation = obj.make_labor_allocation_decision(market_info, expectations);
            
            % 记录决策历史
            obj.record_farmer_decision(decision);
            
            fprintf('农户 %d 基于预期做出决策：种植作物%s，投入%.0f元/亩，技术水平%.2f\n', ...
                    obj.agent_id, decision.crop_allocation.main_crop, ...
                    decision.input_usage.total_cost_per_acre, decision.technology_adoption.target_level);
        end
        
        function crop_decision = make_crop_choice_decision(obj, market_info, expectations)
            % 基于预期的种植结构决策
            
            % 获取作物价格预期
            expected_crop_price = obj.get_expectation('crop_price', 2); % 2期预期
            if isnan(expected_crop_price)
                expected_crop_price = market_info.current_crop_price;
            end
            
            % 获取投入成本预期
            expected_input_cost = obj.get_expectation('input_cost', 1);
            if isnan(expected_input_cost)
                expected_input_cost = market_info.current_input_cost;
            end
            
            % 获取天气风险预期
            expected_weather_risk = obj.get_expectation('weather_risk', 1);
            if isnan(expected_weather_risk)
                expected_weather_risk = 0.3; % 默认中等风险
            end
            
            % 计算预期净收益
            expected_yield = obj.current_yield * (1 - expected_weather_risk * 0.5);
            expected_revenue = expected_crop_price * expected_yield;
            expected_cost = expected_input_cost;
            expected_net_income = expected_revenue - expected_cost;
            
            % 风险调整
            risk_adjusted_income = expected_net_income - obj.risk_aversion * 
                                  sqrt(expected_weather_risk) * expected_revenue;
            
            % 决策逻辑
            crop_decision = struct();
            
            if risk_adjusted_income > obj.subsistence_requirement / obj.land_holding
                % 收益足够，选择高收益作物
                switch obj.farm_type
                    case 'grain'
                        crop_decision.main_crop = 'high_yield_grain';
                        crop_decision.area_allocation = obj.land_holding;
                    case 'cash_crop'
                        crop_decision.main_crop = 'cash_crop';
                        crop_decision.area_allocation = obj.land_holding * 0.8;
                        crop_decision.backup_crop = 'grain';
                        crop_decision.backup_area = obj.land_holding * 0.2;
                    case 'mixed'
                        crop_decision.main_crop = 'mixed_optimal';
                        crop_decision.grain_ratio = 0.6;
                        crop_decision.cash_crop_ratio = 0.4;
                end
            else
                % 收益不足，选择保守策略
                crop_decision.main_crop = 'safe_grain';
                crop_decision.area_allocation = obj.land_holding;
                crop_decision.strategy = 'risk_minimization';
            end
            
            crop_decision.expected_income = risk_adjusted_income;
            crop_decision.confidence_level = obj.get_prediction_confidence('crop_price');
        end
        
        function input_decision = make_input_decision(obj, market_info, expectations)
            % 基于预期的投入品使用决策
            
            % 获取投入成本预期
            expected_input_cost = obj.get_expectation('input_cost', 1);
            if isnan(expected_input_cost)
                expected_input_cost = market_info.current_input_cost;
            end
            
            % 获取作物价格预期
            expected_crop_price = obj.get_expectation('crop_price', 1);
            if isnan(expected_crop_price)
                expected_crop_price = market_info.current_crop_price;
            end
            
            % 计算最优投入水平
            marginal_productivity = 0.8; % 投入品边际生产力
            optimal_input_intensity = (expected_crop_price * marginal_productivity) / expected_input_cost;
            
            % 预算约束调整
            affordable_input = obj.investment_budget / obj.land_holding;
            actual_input_intensity = min(optimal_input_intensity, affordable_input);
            
            % 风险调整
            risk_factor = 1 - obj.risk_aversion * 0.3;
            adjusted_input_intensity = actual_input_intensity * risk_factor;
            
            input_decision = struct();
            input_decision.total_cost_per_acre = adjusted_input_intensity;
            input_decision.fertilizer_rate = adjusted_input_intensity * 0.6;
            input_decision.pesticide_rate = adjusted_input_intensity * 0.2;
            input_decision.seed_cost = adjusted_input_intensity * 0.2;
            input_decision.expected_yield_increase = adjusted_input_intensity * marginal_productivity;
        end
        
        function tech_decision = make_technology_decision(obj, market_info, expectations)
            % 基于预期的技术采用决策
            
            % 获取技术成本预期
            expected_tech_cost = obj.get_expectation('technology_cost', 3); % 3期预期
            if isnan(expected_tech_cost)
                expected_tech_cost = 10000; % 默认技术成本
            end
            
            % 获取劳动力工资预期
            expected_wage = obj.get_expectation('labor_wage', 2);
            if isnan(expected_wage)
                expected_wage = 120; % 默认日工资
            end
            
            % 计算技术采用的净现值
            productivity_gain = 0.15; % 技术带来的生产力提升
            labor_saving = 20; % 节省的工日数
            annual_benefit = productivity_gain * obj.current_yield * 
                           obj.get_expectation('crop_price', 1) * obj.land_holding +
                           labor_saving * expected_wage;
            
            tech_payback_period = expected_tech_cost / annual_benefit;
            
            tech_decision = struct();
            
            if tech_payback_period < 5 && obj.credit_access > 0.5
                % 技术采用条件满足
                tech_decision.adopt = true;
                tech_decision.target_level = min(obj.current_technology_level + 0.1, 0.9);
                tech_decision.investment_amount = expected_tech_cost;
                tech_decision.financing_method = tech_payback_period > 2 ? 'credit' : 'self_finance';
            else
                % 技术采用条件不满足
                tech_decision.adopt = false;
                tech_decision.target_level = obj.current_technology_level;
                tech_decision.reason = tech_payback_period >= 5 ? 'low_return' : 'credit_constraint';
            end
            
            tech_decision.payback_period = tech_payback_period;
            tech_decision.expected_annual_benefit = annual_benefit;
        end
        
        function risk_decision = make_risk_management_decision(obj, market_info, expectations)
            % 基于预期的风险管理决策
            
            % 获取天气风险预期
            expected_weather_risk = obj.get_expectation('weather_risk', 1);
            if isnan(expected_weather_risk)
                expected_weather_risk = 0.3;
            end
            
            % 获取政策不确定性预期
            expected_policy_uncertainty = obj.get_expectation('policy_uncertainty', 2);
            if isnan(expected_policy_uncertainty)
                expected_policy_uncertainty = 0.4;
            end
            
            % 计算综合风险水平
            total_risk = expected_weather_risk * 0.6 + expected_policy_uncertainty * 0.4;
            
            risk_decision = struct();
            
            % 保险参与决策
            if total_risk > 0.4 && obj.risk_aversion > 0.5
                risk_decision.buy_insurance = true;
                risk_decision.insurance_coverage = min(0.8, total_risk + 0.2);
            else
                risk_decision.buy_insurance = false;
            end
            
            % 作物多样化决策
            if total_risk > 0.5 && obj.land_holding > 8
                risk_decision.crop_diversification = true;
                risk_decision.diversification_ratio = min(0.4, total_risk * 0.6);
            else
                risk_decision.crop_diversification = false;
            end
            
            % 储蓄决策
            target_savings = obj.subsistence_requirement * total_risk;
            risk_decision.target_savings = target_savings;
            risk_decision.savings_strategy = total_risk > 0.5 ? 'aggressive' : 'moderate';
            
            % 合作社参与决策
            if total_risk > 0.4 && obj.social_network_size > 5
                risk_decision.join_cooperative = true;
                risk_decision.cooperation_type = 'risk_sharing';
            else
                risk_decision.join_cooperative = obj.cooperative_membership;
            end
        end
        
        function labor_decision = make_labor_allocation_decision(obj, market_info, expectations)
            % 基于预期的劳动力配置决策
            
            % 获取劳动力工资预期
            expected_wage = obj.get_expectation('labor_wage', 1);
            if isnan(expected_wage)
                expected_wage = 120; % 默认日工资
            end
            
            % 计算农场边际劳动生产力
            crop_price_expectation = obj.get_expectation('crop_price', 1);
            if isnan(crop_price_expectation)
                crop_price_expectation = market_info.current_crop_price;
            end
            
            farm_marginal_productivity = crop_price_expectation * 0.5; % 简化的边际生产力
            
            labor_decision = struct();
            
            % 基本农场劳动需求
            base_farm_hours = obj.land_holding * 20; % 每亩20小时基本需求
            
            if expected_wage > farm_marginal_productivity * 1.2
                % 外出务工收益更高
                labor_decision.allocation = 'mixed';
                labor_decision.farm_hours = base_farm_hours;
                labor_decision.off_farm_hours = obj.labor_endowment - base_farm_hours;
                labor_decision.expected_off_farm_income = labor_decision.off_farm_hours * expected_wage / 8;
            else
                % 专注农场生产
                labor_decision.allocation = 'on_farm';
                labor_decision.farm_hours = obj.labor_endowment * 0.9;
                labor_decision.off_farm_hours = 0;
                labor_decision.expected_farm_income = obj.land_holding * crop_price_expectation * obj.current_yield;
            end
            
            labor_decision.total_expected_income = 
                (labor_decision.farm_hours / obj.labor_endowment) * labor_decision.expected_farm_income +
                labor_decision.expected_off_farm_income;
        end
        
        function record_farmer_decision(obj, decision)
            % 记录农户决策历史
            
            obj.crop_choice_history = [obj.crop_choice_history, decision.crop_allocation];
            
            % 维护历史长度
            max_history = 24;
            if length(obj.crop_choice_history) > max_history
                obj.crop_choice_history = obj.crop_choice_history(end-max_history+1:end);
            end
        end
        
        function update_farm_observations(obj, market_data, yield_data, policy_data, current_time)
            % 更新农场观测数据，触发预期学习
            
            % 准备观测数据
            observations = struct();
            
            if isfield(market_data, 'crop_prices')
                observations.crop_price = market_data.crop_prices.(obj.farm_type);
            end
            
            if isfield(market_data, 'input_costs')
                observations.input_cost = market_data.input_costs.average;
            end
            
            if isfield(yield_data, 'weather_impact')
                observations.weather_risk = yield_data.weather_impact;
            end
            
            if isfield(policy_data, 'subsidy_rates')
                observations.subsidy_rate = policy_data.subsidy_rates.(obj.farm_type);
            end
            
            if isfield(market_data, 'labor_wages')
                observations.labor_wage = market_data.labor_wages.daily_rate;
            end
            
            % 更新预期
            obj.update_expectations(observations, current_time);
            
            % 评估预测准确性并适应
            obj.evaluate_and_adapt_farmer_predictions(market_data, yield_data);
        end
        
        function evaluate_and_adapt_farmer_predictions(obj, market_data, yield_data)
            % 评估农户预测准确性并适应学习参数
            
            variables = obj.expectation_module.expectation_variables;
            
            for i = 1:length(variables)
                var_name = variables{i};
                
                if isfield(obj.expectation_module.current_expectations, var_name) && ...
                   ~isnan(obj.expectation_module.current_expectations.(var_name))
                    
                    predicted_value = obj.expectation_module.current_expectations.(var_name);
                    
                    % 获取实际值
                    actual_value = obj.get_farmer_actual_value(var_name, market_data, yield_data);
                    
                    if ~isnan(actual_value)
                        % 评估并适应
                        obj.adapt_to_forecast_errors(var_name, actual_value, predicted_value);
                    end
                end
            end
        end
        
        function actual_value = get_farmer_actual_value(obj, var_name, market_data, yield_data)
            % 从农业数据中提取实际值
            
            actual_value = NaN;
            
            switch var_name
                case 'crop_price'
                    if isfield(market_data, 'crop_prices') && isfield(market_data.crop_prices, obj.farm_type)
                        actual_value = market_data.crop_prices.(obj.farm_type);
                    end
                case 'input_cost'
                    if isfield(market_data, 'input_costs')
                        actual_value = market_data.input_costs.average;
                    end
                case 'weather_risk'
                    if isfield(yield_data, 'weather_impact')
                        actual_value = yield_data.weather_impact;
                    end
                case 'labor_wage'
                    if isfield(market_data, 'labor_wages')
                        actual_value = market_data.labor_wages.daily_rate;
                    end
            end
        end
        
        function key_variables = identify_key_expectation_variables(obj)
            % 识别关键预期变量 - 实现父类的抽象方法
            
            % 基于农户类型和当前状况识别关键变量
            key_variables = {};
            
            % 价格和成本总是关键的
            key_variables = [key_variables, {'crop_price', 'input_cost'}];
            
            % 根据农场类型添加特定关键变量
            switch obj.farm_type
                case 'grain'
                    key_variables = [key_variables, {'grain_policy_support', 'storage_price'}];
                case 'cash_crop'
                    key_variables = [key_variables, {'export_demand', 'quality_premium'}];
                case 'mixed'
                    key_variables = [key_variables, {'crop_diversification_benefit'}];
            end
            
            % 如果风险厌恶程度高，天气风险是关键变量
            if obj.risk_aversion > 0.6
                key_variables = [key_variables, {'weather_risk', 'policy_uncertainty'}];
            end
            
            % 如果劳动力配置重要，工资是关键变量
            if obj.labor_endowment > 1500 % 劳动力充足的农户
                key_variables = [key_variables, {'labor_wage'}];
            end
        end
        
        function print_farmer_status(obj)
            % 打印农户状态，包括预期信息
            
            fprintf('\n=== 农户智能体 %d (%s) 状态报告 ===\n', obj.agent_id, obj.farm_type);
            
            % 基本农户状况
            fprintf('基本农户状况：\n');
            fprintf('  土地规模: %.1f 亩\n', obj.land_holding);
            fprintf('  教育水平: %.2f\n', obj.education_level);
            fprintf('  风险厌恶: %.2f\n', obj.risk_aversion);
            fprintf('  技术水平: %.2f\n', obj.current_technology_level);
            fprintf('  信贷可得性: %.2f\n', obj.credit_access);
            
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
            
            fprintf('==============================\n\n');
        end
    end
end 
