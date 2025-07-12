% Version: 2.0-Simplified | Package: modules
% Version: 2.0-Simplified | Package: modules
classdef modules.modules
    % PesticideMarketModule 农药市场模块 (Enhanced)
    % 负责农药企业与农业企业之间的农药产品供需撮合与价格形成。
    % 经济学机制：质量匹配、双边搜寻、价格发现、声誉传播等。

    properties
        pesticide_enterprises   % 农药企业列表
        agricultural_enterprises % 农业企业列表
        market_price            % 当前市场价格
        supply                  % 总供给
        demand                  % 总需求
        transaction_history     % 交易历史
        quality_distribution    % 质量分布统计
        search_cost_factor      % 搜寻成本系数
        match_records          % 匹配记录
    end
    
    methods
        function obj = PesticideMarketModule(pesticide_enterprises, agricultural_enterprises)
            % 构造函数，初始化市场参与者
            obj.pesticide_enterprises = pesticide_enterprises;
            obj.agricultural_enterprises = agricultural_enterprises;
            obj.market_price = 1.0; % 初始价格
            obj.supply = 0;
            obj.demand = 0;
            obj.transaction_history = [];
            obj.quality_distribution = struct();
            obj.search_cost_factor = 0.05; % 搜寻成本占价格的5%
            obj.match_records = [];
        end
        
        function match_supply_demand_by_quality(obj)
            % 基于质量偏好的供需匹配算法
            % 实现双边搜寻和质量匹配机制
            
            % 收集供给方信息
            suppliers = [];
            for i = 1:length(obj.pesticide_enterprises)
                enterprise = obj.pesticide_enterprises(i);
                if enterprise.output > 0
                    suppliers = [suppliers; struct(...
                        'id', enterprise.id, ...
                        'output', enterprise.output, ...
                        'price', enterprise.price, ...
                        'quality', enterprise.product_quality, ...
                        'reputation', enterprise.reputation, ...
                        'technology_level', enterprise.technology_level)];
                end
            end
            
            % 收集需求方信息
            demanders = [];
            for i = 1:length(obj.agricultural_enterprises)
                enterprise = obj.agricultural_enterprises(i);
                if isfield(enterprise, 'pesticide_demand') && enterprise.pesticide_demand > 0
                    % 农户的质量偏好基于其收入和风险偏好
                    quality_preference = obj.calculate_quality_preference(enterprise);
                    price_sensitivity = obj.calculate_price_sensitivity(enterprise);
                    
                    demanders = [demanders; struct(...
                        'id', enterprise.id, ...
                        'demand', enterprise.pesticide_demand, ...
                        'quality_preference', quality_preference, ...
                        'price_sensitivity', price_sensitivity, ...
                        'max_budget', enterprise.pesticide_budget)];
                end
            end
            
            % 执行双边匹配
            matches = obj.bilateral_matching(suppliers, demanders);
            
            % 更新交易结果
            obj.update_transaction_results(matches);
            
            % 更新市场价格和统计信息
            obj.update_market_statistics(suppliers, demanders, matches);
        end
        
        function quality_pref = calculate_quality_preference(obj, farmer)
            % 计算农户的质量偏好
            % 基于收入水平、教育程度、风险偏好等因素
            
            base_preference = 0.5; % 基础质量偏好
            
            % 收入效应：收入越高，质量偏好越强
            if isfield(farmer, 'income')
                income_effect = min(0.3, farmer.income / 100000); % 标准化收入
            else
                income_effect = 0.1;
            end
            
            % 教育效应：教育水平越高，质量偏好越强
            if isfield(farmer, 'education_level')
                education_effect = 0.2 * farmer.education_level;
            else
                education_effect = 0.1;
            end
            
            % 风险偏好：风险厌恶者更偏好高质量产品
            if isfield(farmer, 'risk_tolerance')
                risk_effect = 0.15 * (1 - farmer.risk_tolerance);
            else
                risk_effect = 0.1;
            end
            
            % 随机因素
            random_factor = 0.1 * randn;
            
            quality_pref = max(0.1, min(1.0, base_preference + income_effect + ...
                              education_effect + risk_effect + random_factor));
        end
        
        function price_sens = calculate_price_sensitivity(obj, farmer)
            % 计算农户的价格敏感度
            % 收入越低，价格敏感度越高
            
            base_sensitivity = 0.5;
            
            if isfield(farmer, 'income')
                income_effect = max(-0.3, min(0.3, -farmer.income / 100000 + 0.5));
            else
                income_effect = 0.1;
            end
            
            if isfield(farmer, 'profit_margin')
                profit_effect = max(-0.2, min(0.2, -farmer.profit_margin + 0.3));
            else
                profit_effect = 0.1;
            end
            
            price_sens = max(0.1, min(1.0, base_sensitivity + income_effect + profit_effect));
        end
        
        function matches = bilateral_matching(obj, suppliers, demanders)
            % 双边匹配算法：实现基于质量和价格的最优匹配
            
            matches = [];
            
            % 为每个需求方找到最佳供给方
            for d = 1:length(demanders)
                demander = demanders(d);
                best_match = [];
                best_utility = -inf;
                
                for s = 1:length(suppliers)
                    supplier = suppliers(s);
                    
                    % 检查供给是否充足
                    if supplier.output <= 0
                        continue;
                    end
                    
                    % 计算匹配效用
                    utility = obj.calculate_matching_utility(demander, supplier);
                    
                    if utility > best_utility
                        best_utility = utility;
                        best_match = supplier;
                        best_match.utility = utility;
                        best_match.demanded_quantity = min(demander.demand, supplier.output);
                    end
                end
                
                % 如果找到合适的匹配
                if ~isempty(best_match) && best_match.utility > 0
                    % 计算实际交易量
                    transaction_quantity = min(demander.demand, best_match.output);
                    
                    % 计算交易价格（考虑质量溢价和议价能力）
                    transaction_price = obj.calculate_transaction_price(demander, best_match);
                    
                    % 记录匹配
                    match = struct(...
                        'supplier_id', best_match.id, ...
                        'demander_id', demander.id, ...
                        'quantity', transaction_quantity, ...
                        'price', transaction_price, ...
                        'quality', best_match.quality, ...
                        'utility', best_match.utility);
                    
                    matches = [matches; match];
                    
                    % 更新供给量
                    for s = 1:length(suppliers)
                        if suppliers(s).id == best_match.id
                            suppliers(s).output = suppliers(s).output - transaction_quantity;
                            break;
                        end
                    end
                end
            end
        end
        
        function utility = calculate_matching_utility(obj, demander, supplier)
            % 计算匹配效用函数
            % 考虑质量匹配度、价格敏感度、搜寻成本等
            
            % 质量匹配效用
            quality_gap = abs(supplier.quality - demander.quality_preference);
            quality_utility = 1 - quality_gap; % 质量差距越小，效用越高
            
            % 价格效用（归一化价格）
            normalized_price = supplier.price / 100; % 假设基准价格为100
            price_utility = max(0, 1 - normalized_price * demander.price_sensitivity);
            
            % 声誉效用
            reputation_utility = 0.2 * supplier.reputation;
            
            % 搜寻成本
            search_cost = obj.search_cost_factor * supplier.price;
            
            % 综合效用
            utility = 0.5 * quality_utility + 0.3 * price_utility + ...
                     0.2 * reputation_utility - search_cost;
            
            % 预算约束检查
            if isfield(demander, 'max_budget') && supplier.price > demander.max_budget
                utility = utility - 10; % 严重惩罚超预算
            end
        end
        
        function price = calculate_transaction_price(obj, demander, supplier)
            % 计算交易价格：考虑议价能力和市场力量
            
            base_price = supplier.price;
            
            % 议价调整：价格敏感度高的买方获得折扣
            bargaining_discount = 0.02 * demander.price_sensitivity;
            
            % 质量溢价：高质量产品获得溢价
            quality_premium = 0.1 * (supplier.quality - 0.5);
            
            % 声誉溢价
            reputation_premium = 0.05 * supplier.reputation;
            
            price = base_price * (1 - bargaining_discount + quality_premium + reputation_premium);
            price = max(0.1, price); % 确保价格为正
        end
        
        function update_transaction_results(obj, matches)
            % 更新交易结果到相关企业
            
            for i = 1:length(matches)
                match = matches(i);
                
                % 更新供给方
                for j = 1:length(obj.pesticide_enterprises)
                    if obj.pesticide_enterprises(j).id == match.supplier_id
                        obj.pesticide_enterprises(j).revenue = ...
                            obj.pesticide_enterprises(j).revenue + match.quantity * match.price;
                        break;
                    end
                end
                
                % 更新需求方
                for j = 1:length(obj.agricultural_enterprises)
                    if obj.agricultural_enterprises(j).id == match.demander_id
                        obj.agricultural_enterprises(j).actual_pesticide = match.quantity;
                        obj.agricultural_enterprises(j).pesticide_cost = match.quantity * match.price;
                        break;
                    end
                end
            end
            
            obj.match_records = [obj.match_records; matches];
        end
        
        function update_market_statistics(obj, suppliers, demanders, matches)
            % 更新市场统计信息
            
            % 计算总供给和需求
            obj.supply = sum([suppliers.output]);
            obj.demand = sum([demanders.demand]);
            
            % 计算加权平均价格
            if ~isempty(matches)
                total_value = sum([matches.quantity] .* [matches.price]);
                total_quantity = sum([matches.quantity]);
                if total_quantity > 0
                    obj.market_price = total_value / total_quantity;
                end
            end
            
            % 更新质量分布
            if ~isempty(suppliers)
                obj.quality_distribution.mean = mean([suppliers.quality]);
                obj.quality_distribution.std = std([suppliers.quality]);
                obj.quality_distribution.min = min([suppliers.quality]);
                obj.quality_distribution.max = max([suppliers.quality]);
            end
            
            % 记录交易历史
            obj.record_transaction();
        end
        
        function record_transaction(obj)
            % 记录本期价格、供需、成交量
            transaction_data = struct(...
                'price', obj.market_price, ...
                'supply', obj.supply, ...
                'demand', obj.demand, ...
                'quality_stats', obj.quality_distribution, ...
                'num_matches', length(obj.match_records));
            
            obj.transaction_history = [obj.transaction_history; transaction_data];
        end
        
        function market_feedback = generate_market_feedback(obj)
            % 生成市场反馈信息，用于企业更新质量和声誉
            
            market_feedback = struct();
            
            if ~isempty(obj.match_records)
                % 计算平均客户满意度
                avg_quality = mean([obj.match_records.quality]);
                market_feedback.customer_satisfaction = min(1, avg_quality);
                
                % 价格竞争力
                market_feedback.price_competitiveness = obj.market_price;
                
                % 市场集中度
                market_feedback.market_concentration = obj.calculate_market_concentration();
            else
                market_feedback.customer_satisfaction = 0.5;
                market_feedback.price_competitiveness = obj.market_price;
                market_feedback.market_concentration = 0.5;
            end
        end
        
        function concentration = calculate_market_concentration(obj)
            % 计算市场集中度（HHI指数）
            
            if isempty(obj.match_records)
                concentration = 0;
                return;
            end
            
            % 按供应商统计市场份额
            supplier_sales = containers.Map('KeyType', 'int32', 'ValueType', 'double');
            total_sales = 0;
            
            for i = 1:length(obj.match_records)
                match = obj.match_records(i);
                sales = match.quantity * match.price;
                
                if isKey(supplier_sales, match.supplier_id)
                    supplier_sales(match.supplier_id) = supplier_sales(match.supplier_id) + sales;
                else
                    supplier_sales(match.supplier_id) = sales;
                end
                
                total_sales = total_sales + sales;
            end
            
            % 计算HHI
            concentration = 0;
            market_shares = values(supplier_sales);
            for i = 1:length(market_shares)
                share = market_shares{i} / total_sales;
                concentration = concentration + share^2;
            end
        end
    end
end 
