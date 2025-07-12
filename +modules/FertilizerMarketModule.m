% Version: 2.0-Simplified | Package: modules
% Version: 2.0-Simplified | Package: modules
classdef modules.modules
    % FertilizerMarketModule 化肥市场模块
    % 负责化肥企业与农业企业之间的化肥产品供需撮合与价格形成。
    % 经济学机制：瓦尔拉斯均衡、双边撮合、价格反馈、政策干预等。

    properties
        fertilizer_enterprises   % 化肥企业列表
        agricultural_enterprises % 农业企业列表
        market_price            % 当前市场价格
        supply                  % 总供给
        demand                  % 总需求
        transaction_history     % 交易历史
    end
    methods
        function obj = FertilizerMarketModule(fertilizer_enterprises, agricultural_enterprises)
            % 构造函数，初始化市场参与者
            obj.fertilizer_enterprises = fertilizer_enterprises;
            obj.agricultural_enterprises = agricultural_enterprises;
            obj.market_price = 1.0; % 初始价格
            obj.supply = 0;
            obj.demand = 0;
            obj.transaction_history = [];
        end
        function match_supply_demand(obj)
            % 供需撮合：收集所有企业的供给和农业企业的需求，按价格优先分配
            supply_list = [obj.fertilizer_enterprises.output];
            price_list = [obj.fertilizer_enterprises.price];
            demand_list = [obj.agricultural_enterprises.fertilizer_demand];
            total_supply = sum(supply_list);
            total_demand = sum(demand_list);
            % 简单均衡：总供给=总需求，价格调整
            if total_supply > total_demand
                obj.market_price = min(price_list) * (1 - 0.05 * rand); % 供大于求，降价
            else
                obj.market_price = max(price_list) * (1 + 0.05 * rand); % 供不应求，涨价
            end
            % 按比例分配成交量
            for i = 1:length(obj.agricultural_enterprises)
                obj.agricultural_enterprises(i).actual_fertilizer = ...
                    obj.agricultural_enterprises(i).fertilizer_demand * min(1, total_supply/total_demand);
            end
            obj.supply = total_supply;
            obj.demand = total_demand;
            obj.record_transaction();
        end
        function update_market_price(obj)
            % 可实现瓦尔拉斯tâtonnement或其他机制
        end
        function record_transaction(obj)
            % 记录本期价格、供需、成交量
            obj.transaction_history = [obj.transaction_history; ...
                struct('price', obj.market_price, 'supply', obj.supply, 'demand', obj.demand)];
        end
    end
end 
