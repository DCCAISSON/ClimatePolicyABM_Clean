% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % AgriculturalServiceEnterpriseAgent 农业服务企业智能体
    % 提供农业生产技术服务、农机服务、技术咨询等，连接工业企业和农业企业
    % 经济学机制：服务供给、技术扩散、规模经济、网络效应等
    
    properties
        % 服务类型和能力
        service_types = {'machinery', 'technical_consulting', 'plant_protection'}  % 服务类型
        service_capacity = struct()     % 各类服务能力
        service_quality = struct()      % 各类服务质量
        service_prices = struct()       % 各类服务价格
        
        % 技术能力
        technology_level = 0.6          % 技术水平 [0-1]
        technical_expertise = 0.5       % 技术专长 [0-1]
        innovation_capacity = 0.4       % 创新能力 [0-1]
        knowledge_stock = 0             % 知识存量
        
        % 设备和资产
        machinery_stock = struct()      % 农机设备存量
        equipment_utilization = 0.7     % 设备利用率
        maintenance_cost_ratio = 0.1    % 维护成本比例
        
        % 客户关系
        customer_base = {}              % 客户群体
        customer_loyalty = 0.6          % 客户忠诚度
        service_coverage_radius = 20    % 服务覆盖半径（公里）
        repeat_customer_ratio = 0.5     % 回头客比例
        
        % 市场网络
        partner_enterprises = {}        % 合作企业
        information_network = 0.4       % 信息网络程度
        market_penetration = 0.3        % 市场渗透率
        
        % 经营策略
        pricing_strategy = 'market_based'  % 'cost_plus', 'market_based', 'value_based'
        service_differentiation = 0.5   % 服务差异化程度
        seasonal_adjustment = true      % 是否季节性调整
        
        % 决策历史
        service_volume_history = []     % 服务量历史
        revenue_history = []            % 收入历史
        customer_satisfaction_history = [] % 客户满意度历史
    end
    
    methods
        function obj = AgriculturalServiceEnterpriseAgent(agent_id, params)
            % 构造函数
            
            % 定义服务企业特有的预期变量
            expectation_variables = {'service_demand', 'machinery_cost', 'labor_wage', 
                                   'technology_trend', 'competition_intensity', 'fuel_price',
                                   'agricultural_income', 'modernization_rate', 'policy_support'};
            
            % 调用父类构造函数
            obj = obj@EnterpriseAgentWithExpectations(agent_id, 'agricultural_service_enterprise', expectation_variables);
            
            % 初始化服务企业参数
            if nargin > 1 && ~isempty(params)
                obj.initialize_service_parameters(params);
            else
                obj.initialize_default_service_parameters();
            end
            
            % 配置服务企业特有的预期设置
            obj.configure_service_expectations();
            
            % 初始化服务能力
            obj.initialize_service_capabilities();
            
            fprintf('农业服务企业智能体 %d 初始化完成，提供%d种服务\n', agent_id, length(obj.service_types));
        end
        
        function initialize_default_service_parameters(obj)
            % 初始化默认服务企业参数
            
            % 技术能力
            obj.technology_level = 0.5 + rand() * 0.4;
            obj.technical_expertise = 0.4 + rand() * 0.5;
            obj.innovation_capacity = 0.3 + rand() * 0.4;
            obj.knowledge_stock = obj.technology_level * 1000;
            
            % 设备配置
            obj.equipment_utilization = 0.6 + rand() * 0.3;
            obj.maintenance_cost_ratio = 0.08 + rand() * 0.04;
            
            % 市场能力
            obj.customer_loyalty = 0.5 + rand() * 0.3;
            obj.service_coverage_radius = 15 + rand() * 15;  % 15-30公里
            obj.repeat_customer_ratio = 0.4 + rand() * 0.3;
            obj.market_penetration = 0.2 + rand() * 0.3;
            
            % 经营策略
            strategies = {'cost_plus', 'market_based', 'value_based'};
            obj.pricing_strategy = strategies{randi(length(strategies))};
            obj.service_differentiation = 0.3 + rand() * 0.4;
        end
        
        function configure_service_expectations(obj)
            % 配置服务企业特有的预期边界和参数
            
            bounds = struct();
            bounds.service_demand = [1000, 10000];          % 服务需求量
            bounds.machinery_cost = [50000, 500000];        % 农机成本
            bounds.labor_wage = [30000, 80000];             % 劳动力工资
            bounds.technology_trend = [0.01, 0.1];          % 技术发展趋势
            bounds.competition_intensity = [0.2, 0.8];      % 竞争强度
            bounds.fuel_price = [5.0, 12.0];                % 燃油价格
            bounds.agricultural_income = [20000, 100000];   % 农业收入水平
            bounds.modernization_rate = [0.02, 0.15];       % 农业现代化速度
            bounds.policy_support = [0, 0.3];               % 政策支持力度
            
            % 应用边界
            variables = obj.expectation_module.expectation_variables;
            for i = 1:length(variables)
                var_name = variables{i};
                if isfield(bounds, var_name)
                    obj.expectation_module.variable_bounds.(var_name) = bounds.(var_name);
                end
            end
            
            % 设置服务企业特有的学习参数
            obj.expectation_module.learning_rate = 0.15;  % 服务企业学习较快
            obj.expectation_module.memory_length = 18;    % 记忆1.5年
            obj.risk_attitude = 0.5;  % 服务企业风险中性
        end
        
        function initialize_service_capabilities(obj)
            % 初始化服务能力
            
            for i = 1:length(obj.service_types)
                service_type = obj.service_types{i};
                
                switch service_type
                    case 'machinery'
                        % 农机服务
                        obj.service_capacity.(service_type) = 500 + rand() * 1500;  % 年服务能力（亩）
                        obj.service_quality.(service_type) = 0.6 + rand() * 0.3;
                        obj.service_prices.(service_type) = 80 + rand() * 40;  % 元/亩
                        obj.machinery_stock.(service_type) = 3 + randi(8);  % 设备数量
                        
                    case 'technical_consulting'
                        % 技术咨询
                        obj.service_capacity.(service_type) = 200 + rand() * 300;  % 年咨询次数
                        obj.service_quality.(service_type) = 0.5 + rand() * 0.4;
                        obj.service_prices.(service_type) = 200 + rand() * 300;  % 元/次
                        
                    case 'plant_protection'
                        % 植保服务
                        obj.service_capacity.(service_type) = 800 + rand() * 1200;  % 年服务面积（亩）
                        obj.service_quality.(service_type) = 0.6 + rand() * 0.3;
                        obj.service_prices.(service_type) = 50 + rand() * 30;  % 元/亩
                end
            end
        end
        
        function decision = make_decision_with_expectations(obj, market_info, expectations)
            % 基于预期做出综合服务决策 - 实现父类的抽象方法
            
            if nargin < 3
                expectations = obj.expectation_module.form_expectations();
            end
            
            decision = struct();
            
            % 1. 服务供给决策
            decision.service_supply = obj.make_service_supply_decision(market_info, expectations);
            
            % 2. 定价策略决策
            decision.pricing_strategy = obj.make_pricing_decision(market_info, expectations);
            
            % 3. 设备投资决策
            decision.equipment_investment = obj.make_equipment_investment_decision(market_info, expectations);
            
            % 4. 技术升级决策
            decision.technology_upgrade = obj.make_technology_upgrade_decision(market_info, expectations);
            
            % 5. 市场拓展决策
            decision.market_expansion = obj.make_market_expansion_decision(market_info, expectations);
            
            % 记录决策历史
            obj.record_service_decision(decision);
            
            fprintf('农业服务企业 %d 决策：服务总量%.0f，设备投资%.0f万元，技术升级投资%.0f万元\n', ...
                    obj.agent_id, decision.service_supply.total_capacity, ...
                    decision.equipment_investment.total_investment / 10000, ...
                    decision.technology_upgrade.investment_amount / 10000);
        end
        
        function service_decision = make_service_supply_decision(obj, market_info, expectations)
            % 服务供给决策
            
            expected_demand = obj.get_expectation('service_demand', 2);
            expected_ag_income = obj.get_expectation('agricultural_income', 1);
            expected_competition = obj.get_expectation('competition_intensity', 1);
            
            if isnan(expected_demand)
                expected_demand = sum([obj.service_capacity.machinery, obj.service_capacity.technical_consulting, obj.service_capacity.plant_protection]);
            end
            
            service_decision = struct();
            
            % 各类服务的供给调整
            for i = 1:length(obj.service_types)
                service_type = obj.service_types{i};
                base_capacity = obj.service_capacity.(service_type);
                
                % 根据预期需求调整
                demand_factor = min(1.5, expected_demand / (base_capacity * length(obj.service_types)));
                
                % 根据农户收入调整
                if ~isnan(expected_ag_income)
                    income_factor = max(0.7, min(1.3, expected_ag_income / 50000));
                else
                    income_factor = 1.0;
                end
                
                % 根据竞争强度调整
                if ~isnan(expected_competition)
                    competition_factor = 1 - expected_competition * 0.2;
                else
                    competition_factor = 1.0;
                end
                
                % 最终服务供给能力
                adjusted_capacity = base_capacity * demand_factor * income_factor * competition_factor;
                service_decision.capacity.(service_type) = max(base_capacity * 0.7, adjusted_capacity);
            end
            
            service_decision.total_capacity = sum(struct2array(service_decision.capacity));
            service_decision.utilization_target = min(0.9, obj.equipment_utilization + 0.1);
        end
        
        function pricing_decision = make_pricing_decision(obj, market_info, expectations)
            % 定价策略决策
            
            expected_competition = obj.get_expectation('competition_intensity', 1);
            expected_ag_income = obj.get_expectation('agricultural_income', 1);
            expected_fuel_price = obj.get_expectation('fuel_price', 1);
            
            pricing_decision = struct();
            
            for i = 1:length(obj.service_types)
                service_type = obj.service_types{i};
                base_price = obj.service_prices.(service_type);
                
                switch obj.pricing_strategy
                    case 'cost_plus'
                        % 成本加成定价
                        cost_factor = 1.0;
                        if ~isnan(expected_fuel_price)
                            cost_factor = cost_factor * (expected_fuel_price / 7.0);  % 基准燃油价格7元
                        end
                        markup = 0.2 - (expected_competition * 0.1);
                        new_price = base_price * cost_factor * (1 + markup);
                        
                    case 'market_based'
                        % 市场竞争定价
                        competition_adjustment = 1 - expected_competition * 0.15;
                        quality_premium = 1 + (obj.service_quality.(service_type) - 0.5) * 0.3;
                        new_price = base_price * competition_adjustment * quality_premium;
                        
                    case 'value_based'
                        % 价值导向定价
                        if ~isnan(expected_ag_income)
                            value_factor = max(0.8, min(1.4, expected_ag_income / 50000));
                        else
                            value_factor = 1.0;
                        end
                        service_value = obj.service_quality.(service_type) * obj.technical_expertise;
                        new_price = base_price * value_factor * (0.8 + 0.4 * service_value);
                end
                
                % 价格平滑调整
                price_change_limit = 0.1;  % 最大10%调整
                max_price = base_price * (1 + price_change_limit);
                min_price = base_price * (1 - price_change_limit);
                
                pricing_decision.prices.(service_type) = max(min_price, min(max_price, new_price));
            end
            
            pricing_decision.avg_price_change = mean(struct2array(pricing_decision.prices)) / mean(struct2array(obj.service_prices)) - 1;
        end
        
        function equipment_decision = make_equipment_investment_decision(obj, market_info, expectations)
            % 设备投资决策
            
            expected_demand = obj.get_expectation('service_demand', 3);
            expected_modernization = obj.get_expectation('modernization_rate', 2);
            expected_machinery_cost = obj.get_expectation('machinery_cost', 1);
            
            equipment_decision = struct();
            
            % 评估设备投资需求
            current_utilization = obj.equipment_utilization;
            
            if current_utilization > 0.85 && ~isnan(expected_demand)
                % 高利用率且需求增长，考虑扩大投资
                demand_growth = expected_demand / sum(struct2array(obj.service_capacity)) - 1;
                
                if demand_growth > 0.1  % 需求增长超过10%
                    if ~isnan(expected_machinery_cost)
                        equipment_cost = expected_machinery_cost;
                    else
                        equipment_cost = 200000;  % 默认成本
                    end
                    
                    % 投资回收期分析
                    annual_revenue_increase = demand_growth * mean(struct2array(obj.service_prices)) * sum(struct2array(obj.service_capacity));
                    payback_period = equipment_cost / annual_revenue_increase;
                    
                    if payback_period < 5  % 回收期小于5年
                        equipment_decision.invest = true;
                        equipment_decision.investment_amount = equipment_cost * 0.8;  % 部分投资
                    else
                        equipment_decision.invest = false;
                        equipment_decision.investment_amount = 0;
                    end
                else
                    equipment_decision.invest = false;
                    equipment_decision.investment_amount = 0;
                end
            else
                equipment_decision.invest = false;
                equipment_decision.investment_amount = 0;
            end
            
            equipment_decision.total_investment = equipment_decision.investment_amount;
        end
        
        function tech_decision = make_technology_upgrade_decision(obj, market_info, expectations)
            % 技术升级决策
            
            expected_tech_trend = obj.get_expectation('technology_trend', 3);
            expected_competition = obj.get_expectation('competition_intensity', 2);
            expected_policy_support = obj.get_expectation('policy_support', 2);
            
            tech_decision = struct();
            
            % 技术升级驱动因素
            upgrade_incentive = 0;
            
            if ~isnan(expected_tech_trend) && expected_tech_trend > 0.05
                upgrade_incentive = upgrade_incentive + expected_tech_trend * 5;  % 技术趋势激励
            end
            
            if ~isnan(expected_competition) && expected_competition > 0.6
                upgrade_incentive = upgrade_incentive + (expected_competition - 0.5) * 2;  % 竞争压力激励
            end
            
            if ~isnan(expected_policy_support) && expected_policy_support > 0.1
                upgrade_incentive = upgrade_incentive + expected_policy_support * 3;  % 政策支持激励
            end
            
            % 技术升级决策
            if upgrade_incentive > 0.3
                base_investment = mean(struct2array(obj.service_prices)) * sum(struct2array(obj.service_capacity)) * 0.05;
                tech_decision.upgrade = true;
                tech_decision.investment_amount = base_investment * (1 + upgrade_incentive);
                tech_decision.target_tech_level = min(1.0, obj.technology_level + 0.05);
            else
                tech_decision.upgrade = false;
                tech_decision.investment_amount = 0;
                tech_decision.target_tech_level = obj.technology_level;
            end
        end
        
        function market_decision = make_market_expansion_decision(obj, market_info, expectations)
            % 市场拓展决策
            
            expected_modernization = obj.get_expectation('modernization_rate', 3);
            
            market_decision = struct();
            
            if ~isnan(expected_modernization) && expected_modernization > 0.08
                % 农业现代化速度快，扩大市场覆盖
                market_decision.expand = true;
                market_decision.target_coverage_increase = obj.service_coverage_radius * 0.2;
                market_decision.marketing_investment = sum(struct2array(obj.service_prices)) * sum(struct2array(obj.service_capacity)) * 0.02;
            else
                market_decision.expand = false;
                market_decision.target_coverage_increase = 0;
                market_decision.marketing_investment = 0;
            end
        end
        
        function key_variables = identify_key_expectation_variables(obj)
            % 识别关键预期变量 - 实现父类的抽象方法
            
            key_variables = {'service_demand', 'agricultural_income', 'competition_intensity'};
            
            % 根据主营服务调整
            if obj.service_capacity.machinery > obj.service_capacity.technical_consulting
                key_variables = [key_variables, {'fuel_price', 'machinery_cost'}];
            end
            
            if obj.service_differentiation > 0.6
                key_variables = [key_variables, {'technology_trend', 'modernization_rate'}];
            end
            
            if obj.market_penetration < 0.4
                key_variables = [key_variables, {'policy_support'}];
            end
        end
        
        function record_service_decision(obj, decision)
            % 记录服务决策历史
            
            if isfield(decision, 'service_supply')
                obj.service_volume_history = [obj.service_volume_history, decision.service_supply.total_capacity];
            end
            
            % 维护历史长度
            max_history = 24;
            if length(obj.service_volume_history) > max_history
                obj.service_volume_history = obj.service_volume_history(end-max_history+1:end);
            end
        end
    end
end 
