% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % MixedCropFarmAgent 混合作物生产企业智能体
    % 同时生产粮食作物和经济作物，分散风险但可能牺牲专业化效率
    % 经济学机制：风险分散、多元化经营、灵活适应、规模不经济、投资平衡
    
    properties
        % 企业基础特征
        enterprise_type = 'mixed_crop_farm'     % 企业类型
        main_product = 'mixed_crops'            % 主要产品：混合作物
        
        % 生产异质性属性（遵循统一异质性框架）
        technology_level = 0.5                 % 技术水平 [0.3,1.0]
        product_quality = 0.6                  % 产品质量 [0.3,1.0] 
        quality_investment = 0.025              % 质量投资比例 [0.01,0.06]
        rd_investment = 0.018                   % 研发投资比例 [0.005,0.04]
        reputation = 0.5                        % 企业声誉 [0,1]
        market_share = 0                        % 市场份额 [0,1]
        
        % 混合作物特化属性
        grain_types = {'wheat', 'corn', 'rice'}                    % 粮食作物类型
        cash_crop_types = {'cotton', 'oil_seeds', 'vegetables'}    % 经济作物类型
        crop_portfolio = struct()               % 作物组合结构
        planting_area = 180                     % 种植面积（亩）[80,500]
        mechanization_level = 0.65              % 机械化水平 [0.35,0.85]
        yield_per_mu = 450                      % 平均单产水平（公斤/亩）[300,650]
        
        % 多元化经营特征
        diversification_degree = 0.6           % 多元化程度 [0.4,0.8]
        specialization_efficiency = 0.85       % 专业化效率损失 [0.75,0.95]
        flexibility_advantage = 0.7            % 灵活性优势 [0.5,0.9]
        risk_reduction_benefit = 0.4           % 风险降低收益 [0.2,0.6]
        
        % 市场导向与风险管理
        market_orientation = 0.5                % 市场化程度 [0.3,0.7]
        risk_preference = -0.3                  % 风险偏好 [-0.8,0.1] 更风险厌恶
        adaptive_capacity = 0.8                 % 适应能力 [0.6,1.0]
        switching_cost = 0.15                   % 品种转换成本
        
        % 成本结构
        land_cost_per_mu = 900                  % 土地成本（元/亩/年）
        labor_cost_ratio = 0.25                 % 劳动力成本占比（管理复杂度高）
        machinery_cost_ratio = 0.18             % 机械成本占比
        input_cost_ratio = 0.37                 % 投入品成本占比
        coordination_cost_ratio = 0.08          % 协调成本占比（多品种管理）
        
        % 库存和销售
        inventory_level = struct()              % 分品种库存水平
        storage_capacity = 120                  % 总储存能力（吨）
        inventory_cost_rate = 0.025             % 库存成本率（月）
        sales_timing_diversity = 0.6           % 销售时机多样化程度
        
        % 政策响应特征
        subsidy_responsiveness = 0.75           % 补贴响应敏感度 [0.5,0.9]
        environmental_compliance = 0.65         % 环保合规水平 [0.4,0.85]
        policy_awareness = 0.6                  % 政策了解程度 [0.3,0.8]
        
        % 预期形成变量（混合作物企业特定）
        expectation_variables = {'grain_price', 'cash_crop_price', 'input_cost', 'weather_condition', ...
                               'policy_subsidy', 'market_volatility', 'crop_disease_risk', ...
                               'labor_availability', 'machinery_cost'}
    end
    
    properties (Access = private)
        % 内部状态变量
        production_cost_history = []
        yield_history = struct()               % 分作物产量历史
        price_history = struct()               % 分作物价格历史
        profit_history = []
        decision_history = []
        switching_history = []                 % 品种转换历史
        performance_comparison = struct()      % 品种间绩效比较
    end
    
    methods
        function obj = MixedCropFarmAgent(params)
            % 构造函数
            obj = obj@EnterpriseAgentWithExpectations(params);
            
            if nargin > 0 && ~isempty(params)
                obj = obj.initialize_mixed_crop_farm_properties(params);
            end
            
            % 初始化异质性属性
            obj = obj.generate_heterogeneous_characteristics();
            
            % 初始化预期形成模块
            obj = obj.initialize_expectations_for_mixed_crop_farm();
            
            % 设置作物组合
            obj = obj.set_initial_crop_portfolio();
            
            % 初始化库存结构
            obj = obj.initialize_inventory_structure();
        end
        
        function obj = initialize_mixed_crop_farm_properties(obj, params)
            % 初始化混合作物企业特有属性
            
            if isfield(params, 'planting_area_range')
                obj.planting_area = params.planting_area_range(1) + ...
                    rand * (params.planting_area_range(2) - params.planting_area_range(1));
            end
            
            if isfield(params, 'mechanization_range')
                obj.mechanization_level = params.mechanization_range(1) + ...
                    rand * (params.mechanization_range(2) - params.mechanization_range(1));
            end
            
            if isfield(params, 'diversification_range')
                obj.diversification_degree = 0.4 + rand * 0.4;
            end
        end
        
        function obj = generate_heterogeneous_characteristics(obj)
            % 生成异质性特征（遵循统一框架）
            
            % 技术水平：混合作物企业技术水平中等（平衡各作物需求）
            obj.technology_level = max(0.3, min(1.0, 0.5 + 0.15*randn));
            
            % 产品质量：与技术水平和适应能力正相关
            obj.product_quality = max(0.3, min(1.0, ...
                0.6*obj.technology_level + 0.25*obj.adaptive_capacity + 0.15*rand + 0.05*randn));
            
            % 投资强度：分散投资，单项投资相对较低
            base_quality_inv = 0.03;
            obj.quality_investment = max(0.01, min(0.06, ...
                base_quality_inv * (1 + 0.4*obj.technology_level - 0.2*obj.diversification_degree)));
            
            base_rd_inv = 0.02;
            obj.rd_investment = max(0.005, min(0.04, ...
                base_rd_inv * (1 + 0.5*obj.technology_level - 0.15*obj.diversification_degree)));
            
            % 声誉：基于稳定性和可靠性（初始化为中等水平）
            obj.reputation = 0.35 + 0.4*rand;
            
            % 专业化效率损失：多元化程度越高，效率损失越大
            obj.specialization_efficiency = 1.0 - 0.3*obj.diversification_degree + 0.1*obj.adaptive_capacity;
            obj.specialization_efficiency = max(0.75, min(0.95, obj.specialization_efficiency));
            
            % 风险降低收益：多元化程度越高，风险降低越明显
            obj.risk_reduction_benefit = 0.2 + 0.6*obj.diversification_degree*rand;
        end
        
        function obj = set_initial_crop_portfolio(obj)
            % 设置初始作物组合（混合配置）
            
            % 粮食作物配置（40-60%）
            grain_ratio = 0.4 + 0.2*rand;
            grain_weights = rand(1, 3);
            grain_weights = grain_weights / sum(grain_weights) * grain_ratio;
            
            obj.crop_portfolio.wheat = grain_weights(1);
            obj.crop_portfolio.corn = grain_weights(2);
            obj.crop_portfolio.rice = grain_weights(3);
            
            % 经济作物配置（40-60%）
            cash_crop_ratio = 1 - grain_ratio;
            cash_weights = rand(1, 3);
            cash_weights = cash_weights / sum(cash_weights) * cash_crop_ratio;
            
            obj.crop_portfolio.cotton = cash_weights(1);
            obj.crop_portfolio.oil_seeds = cash_weights(2);
            obj.crop_portfolio.vegetables = cash_weights(3);
            
            % 计算实际多元化程度
            portfolio_values = [obj.crop_portfolio.wheat, obj.crop_portfolio.corn, obj.crop_portfolio.rice, ...
                               obj.crop_portfolio.cotton, obj.crop_portfolio.oil_seeds, obj.crop_portfolio.vegetables];
            nonzero_crops = sum(portfolio_values > 0.05);  % 占比超过5%的作物数量
            obj.diversification_degree = min(0.8, nonzero_crops / 6);
        end
        
        function obj = initialize_inventory_structure(obj)
            % 初始化库存结构
            
            obj.inventory_level = struct();
            obj.inventory_level.grain = 0;
            obj.inventory_level.cash_crop = 0;
            obj.inventory_level.total = 0;
        end
        
        function obj = initialize_expectations_for_mixed_crop_farm(obj)
            % 初始化混合作物企业的预期形成模块
            
            for i = 1:length(obj.expectation_variables)
                var_name = obj.expectation_variables{i};
                
                % 为每个预期变量设置初始参数
                switch var_name
                    case 'grain_price'
                        obj.expectation_module.bounds.(var_name) = [2.0, 4.5];  % 元/公斤
                        obj.expectation_module.initial_value.(var_name) = 3.0;
                        
                    case 'cash_crop_price'
                        obj.expectation_module.bounds.(var_name) = [3.0, 8.0];  % 元/公斤
                        obj.expectation_module.initial_value.(var_name) = 5.0;
                        
                    case 'input_cost'
                        obj.expectation_module.bounds.(var_name) = [900, 1600]; % 元/亩
                        obj.expectation_module.initial_value.(var_name) = 1200;
                        
                    case 'weather_condition'
                        obj.expectation_module.bounds.(var_name) = [0.3, 1.0];  % 气候适宜度
                        obj.expectation_module.initial_value.(var_name) = 0.7;
                        
                    case 'policy_subsidy'
                        obj.expectation_module.bounds.(var_name) = [0, 250];    % 元/亩
                        obj.expectation_module.initial_value.(var_name) = 120;
                        
                    case 'market_volatility'
                        obj.expectation_module.bounds.(var_name) = [0.1, 0.5];  % 市场波动率
                        obj.expectation_module.initial_value.(var_name) = 0.25;
                        
                    case 'crop_disease_risk'
                        obj.expectation_module.bounds.(var_name) = [0.05, 0.3]; % 病虫害风险
                        obj.expectation_module.initial_value.(var_name) = 0.15;
                        
                    case 'labor_availability'
                        obj.expectation_module.bounds.(var_name) = [0.6, 1.2];  % 劳动力可得性指数
                        obj.expectation_module.initial_value.(var_name) = 1.0;
                        
                    case 'machinery_cost'
                        obj.expectation_module.bounds.(var_name) = [5000, 25000]; % 机械成本
                        obj.expectation_module.initial_value.(var_name) = 12000;
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
            expected_cash_crop_price = obj.get_expectation('cash_crop_price', 1, true);
            expected_input_cost = obj.get_expectation('input_cost', 1, true);
            expected_weather = obj.get_expectation('weather_condition', 1, true);
            expected_subsidy = obj.get_expectation('policy_subsidy', 1, true);
            expected_volatility = obj.get_expectation('market_volatility', 2, true);
            
            % 计算各类作物的预期利润
            [grain_profit_per_mu, cash_crop_profit_per_mu] = obj.calculate_expected_profits(...
                expected_grain_price, expected_cash_crop_price, expected_input_cost, expected_weather, expected_subsidy);
            
            % 种植面积决策（考虑风险分散和专业化损失）
            overall_expected_profit = obj.calculate_portfolio_expected_profit(grain_profit_per_mu, cash_crop_profit_per_mu);
            
            if overall_expected_profit > 0
                % 风险调整的面积决策
                risk_adjusted_profit = overall_expected_profit * (1 - obj.risk_reduction_benefit * expected_volatility);
                area_adjustment = 0.12 * tanh(risk_adjusted_profit / 250) * (1 + obj.risk_preference);
                decisions.target_planting_area = obj.planting_area * (1 + area_adjustment);
            else
                area_reduction = min(0.2, abs(overall_expected_profit) / 400);
                decisions.target_planting_area = obj.planting_area * (1 - area_reduction);
            end
            
            % 限制面积变化幅度
            max_area_change = 0.15 * obj.planting_area;
            decisions.target_planting_area = max(obj.planting_area - max_area_change, ...
                min(obj.planting_area + max_area_change, decisions.target_planting_area));
            
            % 作物组合调整决策
            obj = obj.make_portfolio_adjustment_decision(grain_profit_per_mu, cash_crop_profit_per_mu, expected_volatility, decisions);
            
            % 技术投资决策
            obj = obj.make_technology_investment_decision(overall_expected_profit, decisions);
            
            % 风险管理决策
            obj = obj.make_risk_management_decision(market_info, expected_volatility, decisions);
            
            % 库存管理决策
            obj = obj.make_inventory_decision(market_info, decisions);
            
            % 记录决策历史
            obj.decision_history(end+1) = decisions;
            
            fprintf('混合作物企业 %d: 目标种植面积 %.1f 亩, 预期综合利润 %.2f 元/亩, 多元化程度 %.2f\n', ...
                obj.id, decisions.target_planting_area, overall_expected_profit, obj.diversification_degree);
        end
        
        function [grain_profit, cash_crop_profit] = calculate_expected_profits(obj, grain_price, cash_crop_price, input_cost, weather, subsidy)
            % 计算各类作物的预期利润
            
            % 粮食作物预期利润
            grain_yield = obj.yield_per_mu * 0.9 * weather;  % 粮食作物产量稍低
            grain_revenue = grain_price * grain_yield;
            grain_cost = input_cost * 0.8;  % 粮食作物成本相对较低
            grain_profit = grain_revenue - grain_cost + subsidy * 0.8;  % 粮食补贴相对较多
            
            % 经济作物预期利润
            cash_crop_yield = obj.yield_per_mu * 0.7 * weather;  % 经济作物产量较低但价值高
            cash_crop_revenue = cash_crop_price * cash_crop_yield;
            cash_crop_cost = input_cost * 1.2;  % 经济作物成本较高
            cash_crop_profit = cash_crop_revenue - cash_crop_cost + subsidy * 0.4;  % 经济作物补贴较少
        end
        
        function portfolio_profit = calculate_portfolio_expected_profit(obj, grain_profit, cash_crop_profit)
            % 计算组合的预期利润（考虑专业化效率损失）
            
            % 计算粮食作物和经济作物的面积比例
            grain_ratio = obj.crop_portfolio.wheat + obj.crop_portfolio.corn + obj.crop_portfolio.rice;
            cash_crop_ratio = 1 - grain_ratio;
            
            % 加权平均利润
            raw_portfolio_profit = grain_ratio * grain_profit + cash_crop_ratio * cash_crop_profit;
            
            % 应用专业化效率损失
            portfolio_profit = raw_portfolio_profit * obj.specialization_efficiency;
        end
        
        function obj = make_portfolio_adjustment_decision(obj, grain_profit, cash_crop_profit, expected_volatility, decisions)
            % 作物组合调整决策
            
            % 计算当前组合比例
            current_grain_ratio = obj.crop_portfolio.wheat + obj.crop_portfolio.corn + obj.crop_portfolio.rice;
            current_cash_crop_ratio = 1 - current_grain_ratio;
            
            % 基于预期利润的最优比例
            if grain_profit > 0 && cash_crop_profit > 0
                total_profit = grain_profit + cash_crop_profit;
                optimal_grain_ratio = grain_profit / total_profit;
                optimal_cash_crop_ratio = cash_crop_profit / total_profit;
            else
                optimal_grain_ratio = 0.5;
                optimal_cash_crop_ratio = 0.5;
            end
            
            % 风险调整：高波动率时增加分散化
            volatility_adjustment = expected_volatility * 0.3;
            if optimal_grain_ratio > 0.7
                optimal_grain_ratio = optimal_grain_ratio - volatility_adjustment;
                optimal_cash_crop_ratio = optimal_cash_crop_ratio + volatility_adjustment;
            elseif optimal_cash_crop_ratio > 0.7
                optimal_cash_crop_ratio = optimal_cash_crop_ratio - volatility_adjustment;
                optimal_grain_ratio = optimal_grain_ratio + volatility_adjustment;
            end
            
            % 约束在合理范围内
            optimal_grain_ratio = max(0.3, min(0.7, optimal_grain_ratio));
            optimal_cash_crop_ratio = 1 - optimal_grain_ratio;
            
            % 渐进调整（考虑转换成本）
            adjustment_speed = 0.3 * (1 - obj.switching_cost);
            
            target_grain_ratio = current_grain_ratio + adjustment_speed * (optimal_grain_ratio - current_grain_ratio);
            target_cash_crop_ratio = current_cash_crop_ratio + adjustment_speed * (optimal_cash_crop_ratio - current_cash_crop_ratio);
            
            % 更新作物组合
            decisions.new_crop_portfolio = struct();
            
            % 重新分配粮食作物内部比例（保持相对权重）
            grain_total = obj.crop_portfolio.wheat + obj.crop_portfolio.corn + obj.crop_portfolio.rice;
            if grain_total > 0
                decisions.new_crop_portfolio.wheat = (obj.crop_portfolio.wheat / grain_total) * target_grain_ratio;
                decisions.new_crop_portfolio.corn = (obj.crop_portfolio.corn / grain_total) * target_grain_ratio;
                decisions.new_crop_portfolio.rice = (obj.crop_portfolio.rice / grain_total) * target_grain_ratio;
            else
                equal_grain_share = target_grain_ratio / 3;
                decisions.new_crop_portfolio.wheat = equal_grain_share;
                decisions.new_crop_portfolio.corn = equal_grain_share;
                decisions.new_crop_portfolio.rice = equal_grain_share;
            end
            
            % 重新分配经济作物内部比例
            cash_crop_total = obj.crop_portfolio.cotton + obj.crop_portfolio.oil_seeds + obj.crop_portfolio.vegetables;
            if cash_crop_total > 0
                decisions.new_crop_portfolio.cotton = (obj.crop_portfolio.cotton / cash_crop_total) * target_cash_crop_ratio;
                decisions.new_crop_portfolio.oil_seeds = (obj.crop_portfolio.oil_seeds / cash_crop_total) * target_cash_crop_ratio;
                decisions.new_crop_portfolio.vegetables = (obj.crop_portfolio.vegetables / cash_crop_total) * target_cash_crop_ratio;
            else
                equal_cash_share = target_cash_crop_ratio / 3;
                decisions.new_crop_portfolio.cotton = equal_cash_share;
                decisions.new_crop_portfolio.oil_seeds = equal_cash_share;
                decisions.new_crop_portfolio.vegetables = equal_cash_share;
            end
            
            % 记录转换决策
            switching_record = struct();
            switching_record.from_grain_ratio = current_grain_ratio;
            switching_record.to_grain_ratio = target_grain_ratio;
            switching_record.adjustment_magnitude = abs(target_grain_ratio - current_grain_ratio);
            obj.switching_history(end+1) = switching_record;
        end
        
        function obj = make_technology_investment_decision(obj, expected_profit, decisions)
            % 技术投资决策（混合作物企业投资相对保守）
            
            % 基于预期利润调整投资强度
            if expected_profit > 150
                tech_investment_multiplier = 1.1;
            elseif expected_profit > 80
                tech_investment_multiplier = 1.0;
            else
                tech_investment_multiplier = 0.9;
            end
            
            % 多元化程度影响投资分配
            diversification_penalty = 1 - 0.2 * obj.diversification_degree;
            
            % 质量投资决策
            decisions.quality_investment_rate = obj.quality_investment * tech_investment_multiplier * diversification_penalty;
            decisions.quality_investment_rate = max(0.01, min(0.06, decisions.quality_investment_rate));
            
            % 研发投资决策
            decisions.rd_investment_rate = obj.rd_investment * tech_investment_multiplier * diversification_penalty;
            decisions.rd_investment_rate = max(0.005, min(0.04, decisions.rd_investment_rate));
            
            % 机械化投资决策（需要考虑多种作物的机械需求）
            if obj.mechanization_level < 0.8 && expected_profit > 120
                diversified_machinery_cost = 1.3;  % 多种作物需要不同机械
                decisions.mechanization_investment = 0.06 * expected_profit * obj.planting_area * diversified_machinery_cost;
            else
                decisions.mechanization_investment = 0;
            end
        end
        
        function obj = make_risk_management_decision(obj, market_info, expected_volatility, decisions)
            % 风险管理决策
            
            decisions.risk_management = struct();
            
            % 保险参与决策
            if expected_volatility > 0.3
                decisions.risk_management.increase_insurance = true;
                decisions.risk_management.insurance_coverage = min(0.9, obj.diversification_degree + 0.3);
            else
                decisions.risk_management.increase_insurance = false;
                decisions.risk_management.insurance_coverage = max(0.5, obj.diversification_degree);
            end
            
            % 合同农业参与决策
            if obj.adaptive_capacity > 0.7 && expected_volatility > 0.25
                decisions.risk_management.contract_farming_ratio = min(0.6, obj.diversification_degree * 0.8);
            else
                decisions.risk_management.contract_farming_ratio = obj.diversification_degree * 0.4;
            end
            
            % 缓冲资金决策
            if expected_volatility > 0.35
                decisions.risk_management.cash_buffer_ratio = 0.15;
            else
                decisions.risk_management.cash_buffer_ratio = 0.08;
            end
        end
        
        function obj = make_inventory_decision(obj, market_info, decisions)
            % 库存管理决策（分品种管理）
            
            decisions.inventory_strategy = struct();
            
            % 粮食作物库存策略
            current_grain_price = market_info.current_grain_price;
            expected_grain_price = obj.get_expectation('grain_price', 4, true);
            
            if expected_grain_price > current_grain_price * 1.05
                decisions.inventory_strategy.grain_storage_ratio = 0.7;
            else
                decisions.inventory_strategy.grain_storage_ratio = 0.3;
            end
            
            % 经济作物库存策略
            current_cash_crop_price = market_info.current_cash_crop_price;
            expected_cash_crop_price = obj.get_expectation('cash_crop_price', 4, true);
            
            if expected_cash_crop_price > current_cash_crop_price * 1.08
                decisions.inventory_strategy.cash_crop_storage_ratio = 0.6;
            else
                decisions.inventory_strategy.cash_crop_storage_ratio = 0.2;
            end
            
            % 总库存水平
            grain_ratio = obj.crop_portfolio.wheat + obj.crop_portfolio.corn + obj.crop_portfolio.rice;
            decisions.inventory_strategy.total_storage_ratio = grain_ratio * decisions.inventory_strategy.grain_storage_ratio + ...
                (1-grain_ratio) * decisions.inventory_strategy.cash_crop_storage_ratio;
            
            decisions.target_inventory_level = decisions.inventory_strategy.total_storage_ratio * obj.storage_capacity;
        end
        
        function update_production_state(obj, market_results, time_step)
            % 更新生产状态
            
            % 更新技术水平（基于投资和多元化学习）
            if ~isempty(obj.decision_history)
                last_decision = obj.decision_history(end);
                tech_growth = 0.01 + 0.4 * last_decision.rd_investment_rate;
                
                % 多元化学习效应
                diversification_learning = 0.02 * obj.diversification_degree * obj.adaptive_capacity;
                tech_growth = tech_growth + diversification_learning;
                
                obj.technology_level = min(1.0, obj.technology_level * (1 + tech_growth));
            end
            
            % 更新产品质量
            obj = obj.update_product_quality_based_on_investment();
            
            % 更新适应能力（基于转换经验）
            if ~isempty(obj.switching_history)
                recent_switches = obj.switching_history(max(1, end-5):end);
                avg_adjustment = mean([recent_switches.adjustment_magnitude]);
                
                if avg_adjustment > 0.1  % 频繁大幅调整提高适应能力
                    obj.adaptive_capacity = min(1.0, obj.adaptive_capacity + 0.01);
                end
            end
            
            % 更新专业化效率（基于经验积累）
            if isfield(market_results, 'operational_efficiency')
                efficiency_feedback = market_results.operational_efficiency - 0.5;
                obj.specialization_efficiency = max(0.75, min(0.95, obj.specialization_efficiency + 0.005 * efficiency_feedback));
            end
            
            % 更新声誉（基于稳定性和多样化能力）
            if isfield(market_results, 'stability_score') && isfield(market_results, 'diversification_benefit')
                reputation_change = 0.08 * (0.7*market_results.stability_score + 0.3*market_results.diversification_benefit - 0.5);
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
            if length(obj.switching_history) > max_history_length
                obj.switching_history = obj.switching_history((end-max_history_length+1):end);
            end
        end
        
        function key_vars = identify_key_expectation_variables(obj)
            % 识别关键的预期变量
            key_vars = {'grain_price', 'cash_crop_price', 'input_cost', 'weather_condition', 'market_volatility'};
        end
        
        function quality_level = calculate_current_quality_level(obj)
            % 计算当前质量水平（加权平均质量）
            
            % 基于CES质量函数
            A_quality = 1.1;  % 混合作物质量系数适中
            alpha_T = 0.35; alpha_Q = 0.30; alpha_R = 0.25; alpha_Rep = 0.10;
            rho = -0.4;
            
            % 估算质量资本和研发存量
            quality_capital = obj.quality_investment * 10;
            rd_stock = obj.rd_investment * 8;
            
            quality_level = A_quality * (alpha_T * obj.technology_level^rho + ...
                                       alpha_Q * quality_capital^rho + ...
                                       alpha_R * rd_stock^rho + ...
                                       alpha_Rep * obj.reputation^rho)^(1/rho);
            
            % 多元化调整
            diversification_adjustment = 1 - 0.1 * obj.diversification_degree;  % 轻微质量损失
            quality_level = quality_level * diversification_adjustment;
            
            quality_level = max(0.3, min(1.0, quality_level));
        end
        
        function cost_structure = calculate_production_costs(obj)
            % 计算生产成本结构
            
            cost_structure = struct();
            
            % 基础生产成本
            cost_per_mu = obj.land_cost_per_mu / (1 + 0.06*obj.technology_level);
            
            cost_structure.land_cost = cost_per_mu * obj.planting_area;
            cost_structure.labor_cost = cost_structure.land_cost * obj.labor_cost_ratio;
            cost_structure.machinery_cost = cost_structure.land_cost * obj.machinery_cost_ratio;
            cost_structure.input_cost = cost_structure.land_cost * obj.input_cost_ratio;
            cost_structure.coordination_cost = cost_structure.land_cost * obj.coordination_cost_ratio;
            
            % 投资成本
            total_revenue = cost_structure.land_cost / 0.55;  % 假设成本占收入55%
            cost_structure.quality_investment_cost = total_revenue * obj.quality_investment;
            cost_structure.rd_investment_cost = total_revenue * obj.rd_investment;
            
            % 转换成本
            if ~isempty(obj.switching_history)
                recent_switching = obj.switching_history(end);
                cost_structure.switching_cost = recent_switching.adjustment_magnitude * obj.switching_cost * total_revenue;
            else
                cost_structure.switching_cost = 0;
            end
            
            % 库存成本
            cost_structure.inventory_cost = obj.inventory_level.total * obj.inventory_cost_rate * 12;
            
            % 总成本
            cost_structure.total_cost = cost_structure.land_cost + cost_structure.labor_cost + ...
                cost_structure.machinery_cost + cost_structure.input_cost + cost_structure.coordination_cost + ...
                cost_structure.quality_investment_cost + cost_structure.rd_investment_cost + ...
                cost_structure.switching_cost + cost_structure.inventory_cost;
        end
        
        function performance_metrics = calculate_performance_metrics(obj)
            % 计算绩效指标
            
            performance_metrics = struct();
            
            % 多元化收益
            if ~isempty(obj.profit_history) && length(obj.profit_history) >= 12
                profit_volatility = std(obj.profit_history(end-11:end));
                market_volatility = obj.get_expectation('market_volatility', 1, false);
                if ~isnan(market_volatility) && market_volatility > 0
                    performance_metrics.risk_reduction_effectiveness = max(0, 1 - profit_volatility / market_volatility);
                else
                    performance_metrics.risk_reduction_effectiveness = obj.risk_reduction_benefit;
                end
            else
                performance_metrics.risk_reduction_effectiveness = obj.risk_reduction_benefit;
            end
            
            % 适应性指标
            if ~isempty(obj.switching_history)
                recent_adjustments = obj.switching_history(max(1, end-11):end);
                performance_metrics.adaptation_frequency = length(recent_adjustments) / 12;
                performance_metrics.avg_adjustment_magnitude = mean([recent_adjustments.adjustment_magnitude]);
            else
                performance_metrics.adaptation_frequency = 0;
                performance_metrics.avg_adjustment_magnitude = 0;
            end
            
            % 专业化效率
            performance_metrics.specialization_efficiency = obj.specialization_efficiency;
            performance_metrics.diversification_degree = obj.diversification_degree;
        end
        
        function display_status(obj)
            % 显示企业状态
            fprintf('\n=== 混合作物生产企业 %d 状态 ===\n', obj.id);
            fprintf('技术水平: %.3f\n', obj.technology_level);
            fprintf('产品质量: %.3f\n', obj.calculate_current_quality_level());
            fprintf('企业声誉: %.3f\n', obj.reputation);
            fprintf('种植面积: %.1f 亩\n', obj.planting_area);
            fprintf('机械化水平: %.3f\n', obj.mechanization_level);
            fprintf('多元化程度: %.3f\n', obj.diversification_degree);
            fprintf('专业化效率: %.3f\n', obj.specialization_efficiency);
            fprintf('适应能力: %.3f\n', obj.adaptive_capacity);
            fprintf('风险偏好: %.3f\n', obj.risk_preference);
            
            % 作物组合详情
            fprintf('粮食作物组合: 小麦%.1f%%, 玉米%.1f%%, 水稻%.1f%%\n', ...
                obj.crop_portfolio.wheat*100, obj.crop_portfolio.corn*100, obj.crop_portfolio.rice*100);
            fprintf('经济作物组合: 棉花%.1f%%, 油料%.1f%%, 蔬菜%.1f%%\n', ...
                obj.crop_portfolio.cotton*100, obj.crop_portfolio.oil_seeds*100, obj.crop_portfolio.vegetables*100);
            
            grain_total = obj.crop_portfolio.wheat + obj.crop_portfolio.corn + obj.crop_portfolio.rice;
            cash_crop_total = obj.crop_portfolio.cotton + obj.crop_portfolio.oil_seeds + obj.crop_portfolio.vegetables;
            fprintf('粮食/经济作物比例: %.1f%% / %.1f%%\n', grain_total*100, cash_crop_total*100);
            
            if ~isempty(obj.profit_history)
                fprintf('平均利润: %.2f\n', mean(obj.profit_history));
                if length(obj.profit_history) >= 12
                    fprintf('利润波动率: %.3f\n', std(obj.profit_history(end-11:end)));
                end
            end
            
            % 绩效指标
            metrics = obj.calculate_performance_metrics();
            fprintf('风险降低效果: %.3f\n', metrics.risk_reduction_effectiveness);
            fprintf('适应调整频率: %.2f 次/年\n', metrics.adaptation_frequency);
        end
    end
end 
