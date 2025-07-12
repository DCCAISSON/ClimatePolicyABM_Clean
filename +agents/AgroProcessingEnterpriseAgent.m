% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % AgroProcessingEnterpriseAgent 农产品加工企业智能体
    % 继承自EnterpriseAgent，代表农产品加工企业。可加工多种农产品，企业间可有异质性。
    % 经济学机制：投入品采购、加工产能、产品多样化、品牌溢价、利润最大化等。

    properties
        processing_capacity % 加工能力
        product_types      % 可加工产品类型
        technology_level   % 技术水平
        input_inventory    % 原料库存
        output            % 加工产品产量
        price             % 产品价格
        cost              % 总成本
        policy            % 政策参数结构体（如补贴、绿色激励等）
        % 新增：质量相关属性
        product_quality   % 产品质量 (替代brand_strength)
        quality_investment % 质量投资水平
        reputation       % 企业声誉
        r_and_d_investment % 研发投资
    end
    methods
        function obj = AgroProcessingEnterpriseAgent(id, params, spatial_grid, policy)
            % 构造函数，初始化加工企业属性
            obj@EnterpriseAgent(id, params, spatial_grid);
            obj.type = 'industrial';
            obj.subtype = 'agro_processing';
            obj.processing_capacity = 10 + 40 * rand;
            obj.product_types = {'grain', 'cash_crop'};
            obj.technology_level = 0.3 + 0.7 * rand;
            obj.quality_investment = 0.02 + 0.03 * rand; % 质量投资占收入比例
            obj.r_and_d_investment = 0.01 + 0.04 * rand; % 研发投资占收入比例
            obj.reputation = 0.5; % 初始声誉
            obj.policy = policy;
            obj.input_inventory = struct('grain', 0, 'cash_crop', 0);
            obj.output = struct('grain', 0, 'cash_crop', 0);
            obj.price = struct('grain', 0, 'cash_crop', 0);
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
        
        function process_products(obj, market_info)
            % 加工决策：根据库存和产能决定加工量
            for i = 1:length(obj.product_types)
                prod = obj.product_types{i};
                input_amt = min(obj.input_inventory.(prod), obj.processing_capacity);
                obj.output.(prod) = input_amt * obj.technology_level;
            end
            obj.cost = obj.calculate_total_cost(obj.output);
        end
        
        function set_price(obj, market_info)
            % 定价决策：产品质量溢价+市场均价
            for i = 1:length(obj.product_types)
                prod = obj.product_types{i};
                base_price = market_info.([prod '_price']);
                % 使用产品质量计算溢价，替代brand_strength
                quality_premium = 1 + 0.25 * (obj.product_quality - 0.5);
                obj.price.(prod) = base_price * quality_premium;
            end
        end
        
        function cost = calculate_total_cost(obj, output)
            % 总成本 = 固定成本 + 变动成本 + 质量投资成本
            fixed_cost = 1500;
            variable_cost = 0;
            for i = 1:length(obj.product_types)
                prod = obj.product_types{i};
                variable_cost = variable_cost + output.(prod) * (1.0 - 0.3 * obj.technology_level);
            end
            
            % 新增：质量投资成本
            quality_cost = obj.revenue * obj.quality_investment;
            rd_cost = obj.revenue * obj.r_and_d_investment;
            
            cost = fixed_cost + variable_cost + quality_cost + rd_cost;
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
