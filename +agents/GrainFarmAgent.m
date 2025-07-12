% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % GrainFarmAgent 粮食作物生产企业智能体
    % 专业化生产小麦、玉米、水稻等粮食作物，注重稳定性和规模效应
    % 经济学机制：规模经济、技术采用、质量投资、风险管理、价格稳定性偏好
    
    properties
        % 企业基础特征
        enterprise_type = 'grain_farm'      % 企业类型
        main_product = 'grain'              % 主要产品：粮食作物
        
        % 生产异质性属性（遵循统一异质性框架）
        technology_level = 0.5              % 技术水平 [0.3,1.0]
        product_quality = 0.6               % 产品质量 [0.3,1.0] 
        quality_investment = 0.02           % 质量投资比例 [0.01,0.06]
        rd_investment = 0.015               % 研发投资比例 [0.005,0.04]
        reputation = 0.5                    % 企业声誉 [0,1]
        market_share = 0                    % 市场份额 [0,1]
        
        % 粮食作物特化属性
        crop_types = {'wheat', 'corn', 'rice'}  % 种植作物类型
        crop_portfolio = struct()           % 作物组合：{'wheat': 面积比例, 'corn': 面积比例}
        planting_area = 200                 % 种植面积（亩）[50,800]
        mechanization_level = 0.6           % 机械化水平 [0.3,0.9]
        yield_per_mu = 500                  % 单产水平（公斤/亩）[300,800]
        
        % 市场导向
        market_orientation = 0.4            % 市场化程度 [0.2,0.8]
        contract_farming_ratio = 0.3        % 订单农业比例 [0,0.7]
        risk_preference = -0.2              % 风险偏好 [-1,1] 负值表示风险厌恶
        
        % 成本结构
        land_cost_per_mu = 800              % 土地成本（元/亩/年）
        labor_cost_ratio = 0.25             % 劳动力成本占比
        machinery_cost_ratio = 0.15         % 机械成本占比
        input_cost_ratio = 0.35             % 投入品成本占比
        
        % 库存和销售
        inventory_level = 0                 % 库存水平（吨）
        storage_capacity = 100              % 储存能力（吨）
        inventory_cost_rate = 0.02          % 库存成本率（月）
        
        % 政策响应特征
        subsidy_responsiveness = 0.7        % 补贴响应敏感度 [0.3,1.0]
        environmental_compliance = 0.6      % 环保合规水平 [0.4,0.9]
        policy_awareness = 0.5              % 政策了解程度 [0.2,0.8]
        
        % 预期形成变量（粮食作物企业特定）
        expectation_variables = {'grain_price', 'input_cost', 'weather_condition', ...
                               'policy_subsidy', 'market_demand', 'competitor_supply'}
    end
    
    properties (Access = private)
        % 内部状态变量
        production_cost_history = []
        yield_history = []
        price_history = []
        profit_history = []
        decision_history = []
    end
    
    methods
        function obj = GrainFarmAgent(params)
            % 构造函数
            obj = obj@EnterpriseAgentWithExpectations(params);
            
            if nargin > 0 && ~isempty(params)
                obj = obj.initialize_grain_farm_properties(params);
            end
            
            % 初始化异质性属性
            obj = obj.generate_heterogeneous_characteristics();
            
            % 初始化预期形成模块
            obj = obj.initialize_expectations_for_grain_farm();
            
            % 设置作物组合
            obj = obj.set_initial_crop_portfolio();
        end
        
        function obj = initialize_grain_farm_properties(obj, params)
            % 初始化粮食作物企业特有属性
            
            if isfield(params, 'planting_area_range')
                obj.planting_area = params.planting_area_range(1) + ...
                    rand * (params.planting_area_range(2) - params.planting_area_range(1));
            end
            
            if isfield(params, 'mechanization_range')
                obj.mechanization_level = params.mechanization_range(1) + ...
                    rand * (params.mechanization_range(2) - params.mechanization_range(1));
            end
            
            if isfield(params, 'yield_range')
                obj.yield_per_mu = params.yield_range(1) + ...
                    rand * (params.yield_range(2) - params.yield_range(1));
            end
        end
        
        function obj = generate_heterogeneous_characteristics(obj)
            % 生成异质性特征（遵循统一框架）
            
            % 技术水平：基于正态分布
            obj.technology_level = max(0.3, min(1.0, 0.5 + 0.15*randn));
            
            % 产品质量：与技术水平正相关，但有随机成分
            obj.product_quality = max(0.3, min(1.0, ...
                0.7*obj.technology_level + 0.3*rand + 0.1*randn));
            
            % 投资强度：风险厌恶的企业投资更保守
            base_quality_inv = 0.025;
            obj.quality_investment = max(0.01, min(0.06, ...
                base_quality_inv * (1 + 0.5*obj.technology_level - 0.3*abs(obj.risk_preference))));
            
            base_rd_inv = 0.02;
            obj.rd_investment = max(0.005, min(0.04, ...
                base_rd_inv * (1 + 0.6*obj.technology_level - 0.2*abs(obj.risk_preference))));
            
            % 声誉：基于历史表现（初始化为中等水平）
            obj.reputation = 0.3 + 0.4*rand;
        end
        
        function obj = set_initial_crop_portfolio(obj)
            % 设置初始作物组合
            
            % 粮食作物企业主要种植3种作物，权重随机分配
            weights = rand(1, 3);
            weights = weights / sum(weights);
            
            obj.crop_portfolio.wheat = weights(1);
            obj.crop_portfolio.corn = weights(2);
            obj.crop_portfolio.rice = weights(3);
        end
        
        function obj = initialize_expectations_for_grain_farm(obj)
            % 初始化粮食作物企业的预期形成模块
            
            for i = 1:length(obj.expectation_variables)
                var_name = obj.expectation_variables{i};
                
                % 为每个预期变量设置初始参数
                switch var_name
                    case 'grain_price'
                        obj.expectation_module.bounds.(var_name) = [2.0, 4.5];  % 元/公斤
                        obj.expectation_module.initial_value.(var_name) = 3.0;
                        
                    case 'input_cost'
                        obj.expectation_module.bounds.(var_name) = [800, 1500]; % 元/亩
                        obj.expectation_module.initial_value.(var_name) = 1100;
                        
                    case 'weather_condition'
                        obj.expectation_module.bounds.(var_name) = [0.3, 1.0];  % 气候适宜度
                        obj.expectation_module.initial_value.(var_name) = 0.7;
                        
                    case 'policy_subsidy'
                        obj.expectation_module.bounds.(var_name) = [0, 200];    % 元/亩
                        obj.expectation_module.initial_value.(var_name) = 100;
                        
                    case 'market_demand'
                        obj.expectation_module.bounds.(var_name) = [0.8, 1.3];  % 需求指数
                        obj.expectation_module.initial_value.(var_name) = 1.0;
                        
                    case 'competitor_supply'
                        obj.expectation_module.bounds.(var_name) = [0.7, 1.4];  % 供给指数
                        obj.expectation_module.initial_value.(var_name) = 1.0;
                end
                
                % 初始化AR(1)参数
                obj.expectation_module.model_parameters.(var_name) = [0.1; 0.8; 0.05]; % [α, β, γ]
                obj.expectation_module.covariance_matrix.(var_name) = 0.1 * eye(3);
                obj.expectation_module.historical_data.(var_name) = ...
                    obj.expectation_module.initial_value.(var_name);
            end
        end
        
        function decisions = make_decision_with_expectations(obj, market_info, time_step)
            % 基于预期形成生产决策
            
            decisions = struct();
            
            % 获取关键预期
            expected_grain_price = obj.get_expectation('grain_price', 1, true);
            expected_input_cost = obj.get_expectation('input_cost', 1, true);
            expected_weather = obj.get_expectation('weather_condition', 1, true);
            expected_subsidy = obj.get_expectation('policy_subsidy', 1, true);
            
            % 计算预期利润
            expected_revenue_per_mu = expected_grain_price * obj.yield_per_mu * expected_weather;
            expected_cost_per_mu = expected_input_cost;
            expected_profit_per_mu = expected_revenue_per_mu - expected_cost_per_mu + expected_subsidy;
            
            % 种植面积决策（基于预期利润和风险偏好）
            if expected_profit_per_mu > 0
                area_adjustment = 0.1 * tanh(expected_profit_per_mu / 200) * ...
                    (1 + obj.risk_preference);  % 风险偏好者更激进
                decisions.target_planting_area = obj.planting_area * (1 + area_adjustment);
            else
                area_reduction = min(0.2, abs(expected_profit_per_mu) / 400);
                decisions.target_planting_area = obj.planting_area * (1 - area_reduction);
            end
            
            % 限制面积变化幅度（考虑调整成本）
            max_area_change = 0.15 * obj.planting_area;
            decisions.target_planting_area = max(obj.planting_area - max_area_change, ...
                min(obj.planting_area + max_area_change, decisions.target_planting_area));
            
            % 技术投资决策
            obj = obj.make_technology_investment_decision(expected_profit_per_mu, decisions);
            
            % 库存管理决策
            obj = obj.make_inventory_decision(market_info, decisions);
            
            % 作物组合调整决策
            obj = obj.adjust_crop_portfolio(market_info, decisions);
            
            % 记录决策历史
            obj.decision_history(end+1) = decisions;
            
            fprintf('粮食作物企业 %d: 目标种植面积 %.1f 亩, 预期利润 %.2f 元/亩\n', ...
                obj.id, decisions.target_planting_area, expected_profit_per_mu);
        end
        
        function obj = make_technology_investment_decision(obj, expected_profit, decisions)
            % 技术投资决策
            
            % 基于预期利润调整投资强度
            if expected_profit > 150
                tech_investment_multiplier = 1.2;
            elseif expected_profit > 50
                tech_investment_multiplier = 1.0;
            else
                tech_investment_multiplier = 0.8;
            end
            
            % 质量投资决策
            decisions.quality_investment_rate = obj.quality_investment * tech_investment_multiplier;
            decisions.quality_investment_rate = max(0.01, min(0.06, decisions.quality_investment_rate));
            
            % 研发投资决策
            decisions.rd_investment_rate = obj.rd_investment * tech_investment_multiplier;
            decisions.rd_investment_rate = max(0.005, min(0.04, decisions.rd_investment_rate));
            
            % 机械化投资决策
            if obj.mechanization_level < 0.8 && expected_profit > 100
                decisions.mechanization_investment = 0.05 * expected_profit * obj.planting_area;
            else
                decisions.mechanization_investment = 0;
            end
        end
        
        function obj = make_inventory_decision(obj, market_info, decisions)
            % 库存管理决策
            
            current_price = market_info.current_grain_price;
            expected_future_price = obj.get_expectation('grain_price', 3, true);  % 3期预期
            
            % 价格预期上涨且有储存能力，增加库存
            if expected_future_price > current_price * 1.05 && obj.inventory_level < obj.storage_capacity
                decisions.target_inventory_ratio = min(0.8, obj.inventory_level / obj.storage_capacity + 0.2);
            else
                decisions.target_inventory_ratio = max(0.1, obj.inventory_level / obj.storage_capacity - 0.1);
            end
            
            decisions.target_inventory_level = decisions.target_inventory_ratio * obj.storage_capacity;
        end
        
        function obj = adjust_crop_portfolio(obj, market_info, decisions)
            % 作物组合调整决策
            
            % 获取各作物的预期价格
            crop_expected_returns = struct();
            for i = 1:length(obj.crop_types)
                crop = obj.crop_types{i};
                if isfield(market_info, [crop '_price'])
                    current_price = market_info.([crop '_price']);
                    expected_yield = obj.yield_per_mu * obj.get_crop_yield_factor(crop);
                    crop_expected_returns.(crop) = current_price * expected_yield;
                else
                    crop_expected_returns.(crop) = 3.0 * obj.yield_per_mu;  % 默认收益
                end
            end
            
            % 根据预期收益调整作物组合（但保持多样化以分散风险）
            total_return = crop_expected_returns.wheat + crop_expected_returns.corn + crop_expected_returns.rice;
            
            % 风险厌恶者保持更均衡的组合
            risk_adjustment = abs(obj.risk_preference);
            
            decisions.new_crop_portfolio = struct();
            decisions.new_crop_portfolio.wheat = 0.33 + 0.2*(crop_expected_returns.wheat/total_return - 0.33)*(1-risk_adjustment);
            decisions.new_crop_portfolio.corn = 0.33 + 0.2*(crop_expected_returns.corn/total_return - 0.33)*(1-risk_adjustment);
            decisions.new_crop_portfolio.rice = 0.33 + 0.2*(crop_expected_returns.rice/total_return - 0.33)*(1-risk_adjustment);
            
            % 归一化
            total_weight = decisions.new_crop_portfolio.wheat + decisions.new_crop_portfolio.corn + decisions.new_crop_portfolio.rice;
            decisions.new_crop_portfolio.wheat = decisions.new_crop_portfolio.wheat / total_weight;
            decisions.new_crop_portfolio.corn = decisions.new_crop_portfolio.corn / total_weight;
            decisions.new_crop_portfolio.rice = decisions.new_crop_portfolio.rice / total_weight;
        end
        
        function yield_factor = get_crop_yield_factor(obj, crop_type)
            % 获取不同作物的产量系数
            switch crop_type
                case 'wheat'
                    yield_factor = 0.9;   % 小麦相对产量较低
                case 'corn'
                    yield_factor = 1.2;   % 玉米产量较高
                case 'rice'
                    yield_factor = 1.0;   % 水稻中等产量
                otherwise
                    yield_factor = 1.0;
            end
        end
        
        function update_production_state(obj, market_results, time_step)
            % 更新生产状态
            
            % 更新技术水平（基于投资和溢出效应）
            if ~isempty(obj.decision_history)
                last_decision = obj.decision_history(end);
                tech_growth = 0.01 + 0.5 * last_decision.rd_investment_rate;
                obj.technology_level = min(1.0, obj.technology_level * (1 + tech_growth));
            end
            
            % 更新产品质量
            obj = obj.update_product_quality_based_on_investment();
            
            % 更新声誉（基于市场表现）
            if isfield(market_results, 'price_achieved') && isfield(market_results, 'quantity_sold')
                market_performance = market_results.quantity_sold / obj.planting_area;
                reputation_change = 0.1 * (market_performance - 0.5);
                obj.reputation = max(0, min(1, obj.reputation + reputation_change));
            end
            
            % 更新历史记录
            if isfield(market_results, 'profit')
                obj.profit_history(end+1) = market_results.profit;
            end
            
            % 限制历史记录长度
            max_history_length = 20;
            if length(obj.profit_history) > max_history_length
                obj.profit_history = obj.profit_history((end-max_history_length+1):end);
            end
        end
        
        function key_vars = identify_key_expectation_variables(obj)
            % 识别关键的预期变量
            key_vars = {'grain_price', 'input_cost', 'weather_condition', 'policy_subsidy'};
        end
        
        function quality_level = calculate_current_quality_level(obj)
            % 计算当前质量水平（用于市场匹配）
            
            % 基于CES质量函数
            A_quality = 1.2;
            alpha_T = 0.35; alpha_Q = 0.30; alpha_R = 0.25; alpha_Rep = 0.10;
            rho = -0.4;
            
            % 估算质量资本和研发存量（简化计算）
            quality_capital = obj.quality_investment * 10;  % 累积质量投资的近似
            rd_stock = obj.rd_investment * 8;               % 累积研发投资的近似
            
            quality_level = A_quality * (alpha_T * obj.technology_level^rho + ...
                                       alpha_Q * quality_capital^rho + ...
                                       alpha_R * rd_stock^rho + ...
                                       alpha_Rep * obj.reputation^rho)^(1/rho);
            
            quality_level = max(0.3, min(1.0, quality_level));
        end
        
        function cost_structure = calculate_production_costs(obj)
            % 计算生产成本结构
            
            cost_structure = struct();
            
            % 基础生产成本
            cost_per_mu = obj.land_cost_per_mu / (1 + 0.1*obj.technology_level);  % 技术提高效率
            
            cost_structure.land_cost = cost_per_mu * obj.planting_area;
            cost_structure.labor_cost = cost_structure.land_cost * obj.labor_cost_ratio;
            cost_structure.machinery_cost = cost_structure.land_cost * obj.machinery_cost_ratio;
            cost_structure.input_cost = cost_structure.land_cost * obj.input_cost_ratio;
            
            % 质量投资成本
            total_revenue = cost_structure.land_cost / 0.6;  % 假设成本占收入60%
            cost_structure.quality_investment_cost = total_revenue * obj.quality_investment;
            cost_structure.rd_investment_cost = total_revenue * obj.rd_investment;
            
            % 总成本
            cost_structure.total_cost = cost_structure.land_cost + cost_structure.labor_cost + ...
                cost_structure.machinery_cost + cost_structure.input_cost + ...
                cost_structure.quality_investment_cost + cost_structure.rd_investment_cost;
        end
        
        function display_status(obj)
            % 显示企业状态
            fprintf('\n=== 粮食作物生产企业 %d 状态 ===\n', obj.id);
            fprintf('技术水平: %.3f\n', obj.technology_level);
            fprintf('产品质量: %.3f\n', obj.calculate_current_quality_level());
            fprintf('企业声誉: %.3f\n', obj.reputation);
            fprintf('种植面积: %.1f 亩\n', obj.planting_area);
            fprintf('机械化水平: %.3f\n', obj.mechanization_level);
            fprintf('作物组合: 小麦%.1f%%, 玉米%.1f%%, 水稻%.1f%%\n', ...
                obj.crop_portfolio.wheat*100, obj.crop_portfolio.corn*100, obj.crop_portfolio.rice*100);
            fprintf('风险偏好: %.3f\n', obj.risk_preference);
            fprintf('市场化程度: %.3f\n', obj.market_orientation);
            
            if ~isempty(obj.profit_history)
                fprintf('平均利润: %.2f\n', mean(obj.profit_history));
            end
        end
    end
end 
