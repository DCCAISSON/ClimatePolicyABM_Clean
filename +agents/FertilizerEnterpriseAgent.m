% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % FertilizerEnterpriseAgent 化肥企业智能体
    % 继承自EnterpriseAgent，代表化肥生产企业。每个企业只生产一种化肥，但企业间可有异质性（如成本、技术、定价等）。
    % 经济学机制：利润最大化、成本函数、排放税、技术升级、有限理性等。

    properties
        emission_rate   % 排放系数
        product_quality % 产品质量 (替代brand_strength)
        technology_level % 技术水平
        quality_investment % 质量投资水平
        output         % 本期产量
        price          % 本期定价
        cost           % 本期总成本
        labor_demand   % 劳动力需求
        capital_demand % 资本需求
        raw_material_demand % 原材料需求
        policy         % 政策参数结构体（如排放税率等）
        % 新增：质量相关属性
        reputation     % 企业声誉
        r_and_d_investment % 研发投资
    end
    methods
        function obj = FertilizerEnterpriseAgent(id, params, spatial_grid, policy)
            % 构造函数，初始化化肥企业属性
            obj@EnterpriseAgent(id, params, spatial_grid);
            obj.type = 'industrial';
            obj.subtype = 'fertilizer';
            obj.emission_rate = 0.1 + 0.2 * rand;
            obj.technology_level = 0.3 + 0.7 * rand;
            obj.quality_investment = 0.02 + 0.03 * rand; % 质量投资占收入比例
            obj.r_and_d_investment = 0.01 + 0.04 * rand; % 研发投资占收入比例
            obj.reputation = 0.5; % 初始声誉
            obj.policy = policy;
            obj.output = 0;
            obj.price = 0;
            obj.cost = 0;
            % 计算初始产品质量
            obj.product_quality = obj.calculate_product_quality();
        end
        
        function quality = calculate_product_quality(obj)
            % 基于技术水平、质量投资和研发投资计算产品质量
            % 质量函数：Q = f(技术水平, 质量投资, 研发投资, 声誉) + 随机因素
            
            % 技术水平贡献 (40%)
            tech_contribution = 0.4 * obj.technology_level;
            
            % 质量投资贡献 (25%)
            quality_inv_contribution = 0.25 * min(1, obj.quality_investment / 0.05);
            
            % 研发投资贡献 (20%)
            rd_contribution = 0.2 * min(1, obj.r_and_d_investment / 0.03);
            
            % 声誉贡献 (10%)
            reputation_contribution = 0.1 * obj.reputation;
            
            % 随机因素 (5%)
            random_factor = 0.05 * (0.5 + rand);
            
            % 质量范围：0.3-1.0
            quality = 0.3 + 0.7 * (tech_contribution + quality_inv_contribution + ...
                     rd_contribution + reputation_contribution + random_factor);
            
            % 确保质量在合理范围内
            quality = max(0.3, min(1.0, quality));
        end
        
        function produce(obj, market_info)
            % 生产决策：利润最大化，考虑产能、成本、预期价格
            expected_price = market_info.expected_price;
            marginal_cost = obj.calculate_marginal_cost();
            
            % 产品质量溢价：高质量产品可以获得更高价格
            quality_premium = 1 + 0.3 * (obj.product_quality - 0.5);
            adjusted_expected_price = expected_price * quality_premium;
            
            % 简单规则：只要预期价格高于边际成本就生产最大产能
            if adjusted_expected_price > marginal_cost
                obj.output = obj.capacity;
            else
                obj.output = 0.5 * obj.capacity; % 保守生产
            end
            obj.cost = obj.calculate_total_cost(obj.output);
        end
        
        function set_price(obj, market_info)
            % 定价决策：成本加成+市场竞争+质量溢价
            competitor_prices = market_info.competitor_prices;
            avg_competitor_price = mean(competitor_prices);
            
            % 基础加成
            markup = 0.1 + 0.2 * rand; % 随机加成
            base_price = obj.calculate_marginal_cost() * (1 + markup);
            
            % 质量溢价：基于产品质量调整价格
            quality_premium = 1 + 0.25 * (obj.product_quality - 0.5);
            
            % 市场竞争调整
            market_adjustment = 0.95 + 0.1 * rand;
            competitive_price = avg_competitor_price * market_adjustment;
            
            % 最终价格：考虑质量溢价和市场竞争
            obj.price = max(base_price * quality_premium, competitive_price);
        end
        
        function update_inputs(obj)
            % 投入决策：基于产量和技术
            obj.labor_demand = obj.output / obj.technology_level;
            obj.capital_demand = obj.output * 0.2;
            obj.raw_material_demand = obj.output * 0.5;
        end
        
        function cost = calculate_total_cost(obj, output)
            % 总成本 = 固定成本 + 变动成本 + 排放税 + 质量投资成本
            fixed_cost = 1000;
            variable_cost = output * (1.5 - 0.5 * obj.technology_level);
            emission_tax = output * obj.emission_rate * obj.policy.emission_tax_rate;
            
            % 新增：质量投资成本
            quality_cost = obj.revenue * obj.quality_investment;
            rd_cost = obj.revenue * obj.r_and_d_investment;
            
            cost = fixed_cost + variable_cost + emission_tax + quality_cost + rd_cost;
        end
        
        function mc = calculate_marginal_cost(obj)
            % 边际成本
            mc = 1.5 - 0.5 * obj.technology_level + obj.emission_rate * obj.policy.emission_tax_rate;
        end
        
        function update_quality_and_reputation(obj, market_feedback)
            % 更新产品质量和企业声誉
            % 基于市场反馈、投资水平和技术进步
            
            % 更新技术水平（基于研发投资）
            tech_improvement = 0.02 * obj.r_and_d_investment * (1 + randn * 0.1);
            obj.technology_level = min(1.0, obj.technology_level + tech_improvement);
            
            % 重新计算产品质量
            obj.product_quality = obj.calculate_product_quality();
            
            % 更新声誉（基于产品质量和市场表现）
            if isfield(market_feedback, 'customer_satisfaction')
                satisfaction_effect = 0.1 * (market_feedback.customer_satisfaction - 0.5);
                obj.reputation = max(0, min(1, obj.reputation + satisfaction_effect));
            end
            
            % 质量投资的调整（基于盈利能力）
            if obj.profit > 0
                profit_margin = obj.profit / obj.revenue;
                if profit_margin > 0.15  % 高盈利时增加质量投资
                    obj.quality_investment = min(0.08, obj.quality_investment * 1.05);
                end
            else  % 亏损时减少质量投资
                obj.quality_investment = max(0.01, obj.quality_investment * 0.95);
            end
        end
    end
end 
