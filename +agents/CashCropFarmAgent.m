% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % CashCropFarmAgent 经济作物生产企业智能体
    % 专业化生产棉花、油料、糖料等经济作物，注重市场价值和品质
    % 经济学机制：市场导向、价格敏感、质量投资、风险管理、价值链参与
    
    properties
        % 企业基础特征
        enterprise_type = 'cash_crop_farm'      % 企业类型
        main_product = 'cash_crop'              % 主要产品：经济作物
        
        % 生产异质性属性（遵循统一异质性框架）
        technology_level = 0.5                 % 技术水平 [0.3,1.0]
        product_quality = 0.6                  % 产品质量 [0.3,1.0] 
        quality_investment = 0.03               % 质量投资比例 [0.015,0.08]
        rd_investment = 0.02                    % 研发投资比例 [0.01,0.05]
        reputation = 0.5                        % 企业声誉 [0,1]
        market_share = 0                        % 市场份额 [0,1]
        
        % 经济作物特化属性
        crop_types = {'cotton', 'oil_seeds', 'sugar_crops'}  % 种植作物类型
        crop_portfolio = struct()               % 作物组合：{'cotton': 面积比例, 'oil_seeds': 面积比例}
        planting_area = 150                     % 种植面积（亩）[30,600]
        mechanization_level = 0.7               % 机械化水平 [0.4,0.9]
        yield_per_mu = 400                      % 单产水平（公斤/亩）[250,700]
        
        % 市场导向特征
        market_orientation = 0.7                % 市场化程度 [0.5,0.9]
        contract_farming_ratio = 0.5            % 订单农业比例 [0.2,0.8]
        price_sensitivity = 0.8                 % 价格敏感度 [0.6,1.0]
        market_timing_ability = 0.6             % 市场时机把握能力
        
        % 成本结构
        land_cost_per_mu = 1000                 % 土地成本（元/亩/年）
        labor_cost_ratio = 0.2                  % 劳动力成本占比
        machinery_cost_ratio = 0.2              % 机械成本占比
        input_cost_ratio = 0.4                  % 投入品成本占比（经济作物投入更高）
        
        % 库存和销售
        inventory_level = 0                     % 库存水平（吨）
        storage_capacity = 80                   % 储存能力（吨）
        inventory_cost_rate = 0.03              % 库存成本率（月）
        forward_sales_ratio = 0.3              % 期货销售比例
        
        % 政策响应特征
        subsidy_responsiveness = 0.8            % 补贴响应敏感度 [0.5,1.0]
        environmental_compliance = 0.7          % 环保合规水平 [0.5,0.9]
        policy_awareness = 0.7                  % 政策了解程度 [0.4,0.9]
        
        % 风险管理
        risk_preference = 0.2                   % 风险偏好 [-0.5,0.5] 正值表示风险偏好
        diversification_tendency = 0.4          % 多元化倾向 [0.2,0.8]
        insurance_participation = 0.6          % 保险参与率
        
        % 预期形成变量（经济作物企业特定）
        expectation_variables = {'cash_crop_price', 'input_cost', 'weather_condition', ...
                               'policy_subsidy', 'export_demand', 'processing_demand', ...
                               'futures_price', 'exchange_rate'}
    end
    
    properties (Access = private)
        % 内部状态变量
        production_cost_history = []
        yield_history = []
        price_history = []
        profit_history = []
        decision_history = []
        market_timing_history = []
    end
    
    methods
        function obj = CashCropFarmAgent(params)
            % 构造函数
            obj = obj@EnterpriseAgentWithExpectations(params);
            
            if nargin > 0 && ~isempty(params)
                obj = obj.initialize_cash_crop_farm_properties(params);
            end
            
            % 初始化异质性属性
            obj = obj.generate_heterogeneous_characteristics();
            
            % 初始化预期形成模块
            obj = obj.initialize_expectations_for_cash_crop_farm();
            
            % 设置作物组合
            obj = obj.set_initial_crop_portfolio();
        end
        
        function obj = initialize_cash_crop_farm_properties(obj, params)
            % 初始化经济作物企业特有属性
            
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
            
            % 技术水平：经济作物企业技术水平一般较高
            obj.technology_level = max(0.3, min(1.0, 0.6 + 0.2*randn));
            
            % 产品质量：与技术水平和市场导向正相关
            obj.product_quality = max(0.3, min(1.0, ...
                0.6*obj.technology_level + 0.3*obj.market_orientation + 0.1*rand + 0.05*randn));
            
            % 投资强度：市场导向的企业投资更积极
            base_quality_inv = 0.04;
            obj.quality_investment = max(0.015, min(0.08, ...
                base_quality_inv * (1 + 0.8*obj.market_orientation + 0.4*obj.technology_level)));
            
            base_rd_inv = 0.025;
            obj.rd_investment = max(0.01, min(0.05, ...
                base_rd_inv * (1 + 0.6*obj.technology_level + 0.3*obj.market_orientation)));
            
            % 声誉：基于历史表现（初始化为中等偏上水平）
            obj.reputation = 0.4 + 0.4*rand;
            
            % 风险偏好：经济作物企业相对更愿意承担风险
            obj.risk_preference = -0.1 + 0.4*rand;
        end
        
        function obj = set_initial_crop_portfolio(obj)
            % 设置初始作物组合
            
            % 经济作物企业主要种植3种经济作物，权重根据市场导向分配
            if obj.market_orientation > 0.7
                % 高市场导向：集中种植价值高的作物
                weights = [0.5, 0.3, 0.2] + rand(1,3)*0.1;
            else
                % 低市场导向：相对均衡分配
                weights = rand(1, 3);
            end
            weights = weights / sum(weights);
            
            obj.crop_portfolio.cotton = weights(1);
            obj.crop_portfolio.oil_seeds = weights(2);
            obj.crop_portfolio.sugar_crops = weights(3);
        end
        
        function obj = initialize_expectations_for_cash_crop_farm(obj)
            % 初始化经济作物企业的预期形成模块
            
            for i = 1:length(obj.expectation_variables)
                var_name = obj.expectation_variables{i};
                
                % 为每个预期变量设置初始参数
                switch var_name
                    case 'cash_crop_price'
                        obj.expectation_module.bounds.(var_name) = [3.0, 8.0];  % 元/公斤
                        obj.expectation_module.initial_value.(var_name) = 5.0;
                        
                    case 'input_cost'
                        obj.expectation_module.bounds.(var_name) = [1000, 2000]; % 元/亩
                        obj.expectation_module.initial_value.(var_name) = 1400;
                        
                    case 'weather_condition'
                        obj.expectation_module.bounds.(var_name) = [0.3, 1.0];  % 气候适宜度
                        obj.expectation_module.initial_value.(var_name) = 0.7;
                        
                    case 'policy_subsidy'
                        obj.expectation_module.bounds.(var_name) = [0, 300];    % 元/亩
                        obj.expectation_module.initial_value.(var_name) = 150;
                        
                    case 'export_demand'
                        obj.expectation_module.bounds.(var_name) = [0.7, 1.4];  % 出口需求指数
                        obj.expectation_module.initial_value.(var_name) = 1.0;
                        
                    case 'processing_demand'
                        obj.expectation_module.bounds.(var_name) = [0.8, 1.3];  % 加工需求指数
                        obj.expectation_module.initial_value.(var_name) = 1.0;
                        
                    case 'futures_price'
                        obj.expectation_module.bounds.(var_name) = [2.5, 9.0];  % 期货价格
                        obj.expectation_module.initial_value.(var_name) = 5.2;
                        
                    case 'exchange_rate'
                        obj.expectation_module.bounds.(var_name) = [6.0, 8.0];  % 汇率
                        obj.expectation_module.initial_value.(var_name) = 7.0;
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
            expected_cash_crop_price = obj.get_expectation('cash_crop_price', 1, true);
            expected_input_cost = obj.get_expectation('input_cost', 1, true);
            expected_weather = obj.get_expectation('weather_condition', 1, true);
            expected_subsidy = obj.get_expectation('policy_subsidy', 1, true);
            expected_futures_price = obj.get_expectation('futures_price', 3, true);
            
            % 计算预期利润
            expected_revenue_per_mu = expected_cash_crop_price * obj.yield_per_mu * expected_weather;
            expected_cost_per_mu = expected_input_cost;
            expected_profit_per_mu = expected_revenue_per_mu - expected_cost_per_mu + expected_subsidy;
            
            % 种植面积决策（经济作物对价格更敏感）
            if expected_profit_per_mu > 0
                price_factor = (expected_cash_crop_price / 5.0 - 1) * obj.price_sensitivity;
                area_adjustment = (0.15 * tanh(expected_profit_per_mu / 300) + 0.1 * price_factor) * ...
                    (1 + obj.risk_preference);  % 风险偏好者更激进
                decisions.target_planting_area = obj.planting_area * (1 + area_adjustment);
            else
                area_reduction = min(0.25, abs(expected_profit_per_mu) / 500);
                decisions.target_planting_area = obj.planting_area * (1 - area_reduction);
            end
            
            % 限制面积变化幅度（考虑调整成本）
            max_area_change = 0.2 * obj.planting_area;
            decisions.target_planting_area = max(obj.planting_area - max_area_change, ...
                min(obj.planting_area + max_area_change, decisions.target_planting_area));
            
            % 技术投资决策
            obj = obj.make_technology_investment_decision(expected_profit_per_mu, decisions);
            
            % 市场时机决策
            obj = obj.make_market_timing_decision(market_info, expected_futures_price, decisions);
            
            % 库存管理决策
            obj = obj.make_inventory_decision(market_info, decisions);
            
            % 作物组合调整决策
            obj = obj.adjust_crop_portfolio(market_info, decisions);
            
            % 记录决策历史
            obj.decision_history(end+1) = decisions;
            
            fprintf('经济作物企业 %d: 目标种植面积 %.1f 亩, 预期利润 %.2f 元/亩\n', ...
                obj.id, decisions.target_planting_area, expected_profit_per_mu);
        end
        
        function obj = make_technology_investment_decision(obj, expected_profit, decisions)
            % 技术投资决策（经济作物企业投资更积极）
            
            % 基于预期利润调整投资强度
            if expected_profit > 200
                tech_investment_multiplier = 1.3;
            elseif expected_profit > 100
                tech_investment_multiplier = 1.1;
            else
                tech_investment_multiplier = 0.9;
            end
            
            % 质量投资决策（经济作物更注重质量）
            decisions.quality_investment_rate = obj.quality_investment * tech_investment_multiplier;
            decisions.quality_investment_rate = max(0.015, min(0.08, decisions.quality_investment_rate));
            
            % 研发投资决策
            decisions.rd_investment_rate = obj.rd_investment * tech_investment_multiplier;
            decisions.rd_investment_rate = max(0.01, min(0.05, decisions.rd_investment_rate));
            
            % 机械化投资决策
            if obj.mechanization_level < 0.85 && expected_profit > 150
                decisions.mechanization_investment = 0.08 * expected_profit * obj.planting_area;
            else
                decisions.mechanization_investment = 0;
            end
        end
        
        function obj = make_market_timing_decision(obj, market_info, expected_futures_price, decisions)
            % 市场时机决策（经济作物企业特有）
            
            current_price = market_info.current_cash_crop_price;
            
            % 期货与现货价差分析
            if ~isnan(expected_futures_price) && current_price > 0
                price_spread = (expected_futures_price - current_price) / current_price;
                
                % 销售时机决策
                if price_spread > 0.1 && obj.market_timing_ability > 0.6
                    decisions.immediate_sales_ratio = 0.3;  % 推迟销售
                    decisions.forward_sales_ratio = 0.1;    % 减少期货销售
                elseif price_spread < -0.1
                    decisions.immediate_sales_ratio = 0.8;  % 立即销售
                    decisions.forward_sales_ratio = 0.4;    % 增加期货销售
                else
                    decisions.immediate_sales_ratio = 0.6;  % 正常销售
                    decisions.forward_sales_ratio = obj.forward_sales_ratio;
                end
            else
                decisions.immediate_sales_ratio = 0.6;
                decisions.forward_sales_ratio = obj.forward_sales_ratio;
            end
            
            % 记录市场时机决策历史
            timing_record = struct();
            timing_record.price_spread = price_spread;
            timing_record.sales_decision = decisions.immediate_sales_ratio;
            obj.market_timing_history(end+1) = timing_record;
        end
        
        function obj = make_inventory_decision(obj, market_info, decisions)
            % 库存管理决策
            
            current_price = market_info.current_cash_crop_price;
            expected_future_price = obj.get_expectation('cash_crop_price', 6, true);  % 6期预期
            
            % 价格预期上涨且有储存能力，增加库存
            if expected_future_price > current_price * 1.08 && obj.inventory_level < obj.storage_capacity
                decisions.target_inventory_ratio = min(0.9, obj.inventory_level / obj.storage_capacity + 0.25);
            else
                decisions.target_inventory_ratio = max(0.1, obj.inventory_level / obj.storage_capacity - 0.15);
            end
            
            decisions.target_inventory_level = decisions.target_inventory_ratio * obj.storage_capacity;
        end
        
        function obj = adjust_crop_portfolio(obj, market_info, decisions)
            % 作物组合调整决策
            
            % 获取各作物的预期价格和市场需求
            crop_expected_returns = struct();
            crop_market_prospects = struct();
            
            for i = 1:length(obj.crop_types)
                crop = obj.crop_types{i};
                if isfield(market_info, [crop '_price'])
                    current_price = market_info.([crop '_price']);
                    expected_yield = obj.yield_per_mu * obj.get_crop_yield_factor(crop);
                    crop_expected_returns.(crop) = current_price * expected_yield;
                    
                    % 市场前景评估
                    export_demand = obj.get_expectation('export_demand', 2);
                    processing_demand = obj.get_expectation('processing_demand', 2);
                    crop_market_prospects.(crop) = (export_demand + processing_demand) / 2;
                else
                    crop_expected_returns.(crop) = 5.0 * obj.yield_per_mu;  % 默认收益
                    crop_market_prospects.(crop) = 1.0;
                end
            end
            
            % 综合考虑收益和市场前景
            total_return = crop_expected_returns.cotton + crop_expected_returns.oil_seeds + crop_expected_returns.sugar_crops;
            total_prospect = crop_market_prospects.cotton + crop_market_prospects.oil_seeds + crop_market_prospects.sugar_crops;
            
            % 风险偏好者更愿意调整组合
            adjustment_intensity = 0.3 * (1 + obj.risk_preference);
            
            decisions.new_crop_portfolio = struct();
            decisions.new_crop_portfolio.cotton = obj.crop_portfolio.cotton + ...
                adjustment_intensity * (0.4*(crop_expected_returns.cotton/total_return) + 0.6*(crop_market_prospects.cotton/total_prospect) - obj.crop_portfolio.cotton);
            decisions.new_crop_portfolio.oil_seeds = obj.crop_portfolio.oil_seeds + ...
                adjustment_intensity * (0.4*(crop_expected_returns.oil_seeds/total_return) + 0.6*(crop_market_prospects.oil_seeds/total_prospect) - obj.crop_portfolio.oil_seeds);
            decisions.new_crop_portfolio.sugar_crops = obj.crop_portfolio.sugar_crops + ...
                adjustment_intensity * (0.4*(crop_expected_returns.sugar_crops/total_return) + 0.6*(crop_market_prospects.sugar_crops/total_prospect) - obj.crop_portfolio.sugar_crops);
            
            % 归一化
            total_weight = decisions.new_crop_portfolio.cotton + decisions.new_crop_portfolio.oil_seeds + decisions.new_crop_portfolio.sugar_crops;
            decisions.new_crop_portfolio.cotton = decisions.new_crop_portfolio.cotton / total_weight;
            decisions.new_crop_portfolio.oil_seeds = decisions.new_crop_portfolio.oil_seeds / total_weight;
            decisions.new_crop_portfolio.sugar_crops = decisions.new_crop_portfolio.sugar_crops / total_weight;
        end
        
        function yield_factor = get_crop_yield_factor(obj, crop_type)
            % 获取不同作物的产量系数
            switch crop_type
                case 'cotton'
                    yield_factor = 0.8;   % 棉花相对产量较低但价值高
                case 'oil_seeds'
                    yield_factor = 1.1;   % 油料作物产量中等
                case 'sugar_crops'
                    yield_factor = 1.3;   % 糖料作物产量较高
                otherwise
                    yield_factor = 1.0;
            end
        end
        
        function update_production_state(obj, market_results, time_step)
            % 更新生产状态
            
            % 更新技术水平（基于投资和市场表现）
            if ~isempty(obj.decision_history)
                last_decision = obj.decision_history(end);
                tech_growth = 0.015 + 0.6 * last_decision.rd_investment_rate;
                
                % 市场成功增强技术学习
                if isfield(market_results, 'market_success_rate') && market_results.market_success_rate > 0.7
                    tech_growth = tech_growth * 1.2;
                end
                
                obj.technology_level = min(1.0, obj.technology_level * (1 + tech_growth));
            end
            
            % 更新产品质量
            obj = obj.update_product_quality_based_on_investment();
            
            % 更新市场时机把握能力
            if ~isempty(obj.market_timing_history)
                recent_decisions = obj.market_timing_history(max(1, end-5):end);
                success_rate = obj.evaluate_timing_decisions(recent_decisions, market_results);
                
                if success_rate > 0.6
                    obj.market_timing_ability = min(1.0, obj.market_timing_ability + 0.02);
                else
                    obj.market_timing_ability = max(0.3, obj.market_timing_ability - 0.01);
                end
            end
            
            % 更新声誉（基于市场表现和质量）
            if isfield(market_results, 'quality_satisfaction') && isfield(market_results, 'price_competitiveness')
                reputation_change = 0.1 * (0.6*market_results.quality_satisfaction + 0.4*market_results.price_competitiveness - 0.5);
                obj.reputation = max(0, min(1, obj.reputation + reputation_change));
            end
            
            % 更新历史记录
            if isfield(market_results, 'profit')
                obj.profit_history(end+1) = market_results.profit;
            end
            
            % 限制历史记录长度
            max_history_length = 24;
            if length(obj.profit_history) > max_history_length
                obj.profit_history = obj.profit_history((end-max_history_length+1):end);
            end
            if length(obj.market_timing_history) > max_history_length
                obj.market_timing_history = obj.market_timing_history((end-max_history_length+1):end);
            end
        end
        
        function success_rate = evaluate_timing_decisions(obj, timing_decisions, market_results)
            % 评估市场时机决策的成功率
            
            if isempty(timing_decisions)
                success_rate = 0.5;
                return;
            end
            
            success_count = 0;
            for i = 1:length(timing_decisions)
                decision = timing_decisions(i);
                
                % 简化的成功评估：价格预期与实际走势的一致性
                if abs(decision.price_spread) > 0.05
                    if (decision.price_spread > 0 && decision.sales_decision < 0.5) || ...
                       (decision.price_spread < 0 && decision.sales_decision > 0.7)
                        success_count = success_count + 1;
                    end
                else
                    success_count = success_count + 0.5; % 中性决策给部分分数
                end
            end
            
            success_rate = success_count / length(timing_decisions);
        end
        
        function key_vars = identify_key_expectation_variables(obj)
            % 识别关键的预期变量
            key_vars = {'cash_crop_price', 'input_cost', 'weather_condition', 'export_demand', 'futures_price'};
        end
        
        function quality_level = calculate_current_quality_level(obj)
            % 计算当前质量水平（用于市场匹配）
            
            % 基于CES质量函数
            A_quality = 1.3;  % 经济作物质量系数稍高
            alpha_T = 0.35; alpha_Q = 0.30; alpha_R = 0.25; alpha_Rep = 0.10;
            rho = -0.4;
            
            % 估算质量资本和研发存量（简化计算）
            quality_capital = obj.quality_investment * 12;  % 累积质量投资的近似
            rd_stock = obj.rd_investment * 10;              % 累积研发投资的近似
            
            quality_level = A_quality * (alpha_T * obj.technology_level^rho + ...
                                       alpha_Q * quality_capital^rho + ...
                                       alpha_R * rd_stock^rho + ...
                                       alpha_Rep * obj.reputation^rho)^(1/rho);
            
            quality_level = max(0.3, min(1.0, quality_level));
        end
        
        function cost_structure = calculate_production_costs(obj)
            % 计算生产成本结构
            
            cost_structure = struct();
            
            % 基础生产成本（经济作物成本高于粮食作物）
            cost_per_mu = obj.land_cost_per_mu / (1 + 0.08*obj.technology_level);  % 技术提高效率
            
            cost_structure.land_cost = cost_per_mu * obj.planting_area;
            cost_structure.labor_cost = cost_structure.land_cost * obj.labor_cost_ratio;
            cost_structure.machinery_cost = cost_structure.land_cost * obj.machinery_cost_ratio;
            cost_structure.input_cost = cost_structure.land_cost * obj.input_cost_ratio;
            
            % 质量投资成本
            total_revenue = cost_structure.land_cost / 0.5;  % 假设成本占收入50%
            cost_structure.quality_investment_cost = total_revenue * obj.quality_investment;
            cost_structure.rd_investment_cost = total_revenue * obj.rd_investment;
            
            % 库存成本
            cost_structure.inventory_cost = obj.inventory_level * obj.inventory_cost_rate * 12;
            
            % 总成本
            cost_structure.total_cost = cost_structure.land_cost + cost_structure.labor_cost + ...
                cost_structure.machinery_cost + cost_structure.input_cost + ...
                cost_structure.quality_investment_cost + cost_structure.rd_investment_cost + ...
                cost_structure.inventory_cost;
        end
        
        function display_status(obj)
            % 显示企业状态
            fprintf('\n=== 经济作物生产企业 %d 状态 ===\n', obj.id);
            fprintf('技术水平: %.3f\n', obj.technology_level);
            fprintf('产品质量: %.3f\n', obj.calculate_current_quality_level());
            fprintf('企业声誉: %.3f\n', obj.reputation);
            fprintf('种植面积: %.1f 亩\n', obj.planting_area);
            fprintf('机械化水平: %.3f\n', obj.mechanization_level);
            fprintf('市场导向程度: %.3f\n', obj.market_orientation);
            fprintf('价格敏感度: %.3f\n', obj.price_sensitivity);
            fprintf('市场时机把握能力: %.3f\n', obj.market_timing_ability);
            fprintf('作物组合: 棉花%.1f%%, 油料%.1f%%, 糖料%.1f%%\n', ...
                obj.crop_portfolio.cotton*100, obj.crop_portfolio.oil_seeds*100, obj.crop_portfolio.sugar_crops*100);
            fprintf('风险偏好: %.3f\n', obj.risk_preference);
            fprintf('订单农业比例: %.3f\n', obj.contract_farming_ratio);
            
            if ~isempty(obj.profit_history)
                fprintf('平均利润: %.2f\n', mean(obj.profit_history));
            end
        end
    end
end 
