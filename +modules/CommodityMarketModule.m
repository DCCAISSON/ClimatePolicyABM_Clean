% Version: 2.0-Simplified | Package: modules
% Version: 2.0-Simplified | Package: modules
classdef modules.modules
    % CommodityMarketModule  商品市场模块
    % 基于经典农户模型 (Chayanov 1925, Singh et al. 1986) 和公共经济学理论
    % 包含农户消费行为、政府公共支出和商品市场均衡

    properties
        model               % 主模型引用
        
        % 商品市场参数
        commodity_types = {'food', 'clothing', 'housing', 'education', 'health', 'entertainment', 'transportation'};
        base_prices        % 基础价格向量
        price_elasticities % 价格弹性
        income_elasticities % 收入弹性
        
        % 市场状态
        supply             % 供给向量
        demand             % 需求向量
        market_prices      % 市场价格向量
        market_clearing    % 市场出清状态
        
        % 政府公共支出
        public_goods       % 公共品支出
        public_services    % 公共服务支出
        infrastructure     % 基础设施支出
        
        % 历史记录
        price_history      % 价格历史
        consumption_history % 消费历史
        welfare_history    % 福利历史
    end

    methods
        function obj = CommodityMarketModule(model)
            obj.model = model;
            obj.initialize_market_parameters();
            obj.initialize_government_expenditure();
        end
        
        function initialize_market_parameters(obj)
            % 初始化市场参数
            n_commodities = length(obj.commodity_types);
            
            % 基础价格 (元/单位)
            obj.base_prices = [5, 50, 2000, 500, 300, 100, 20];  % 食品、服装、住房、教育、医疗、娱乐、交通
            
            % 价格弹性 (绝对值)
            obj.price_elasticities = [0.8, 1.2, 0.5, 0.6, 0.4, 1.5, 1.0];
            
            % 收入弹性
            obj.income_elasticities = [0.6, 1.1, 1.3, 1.5, 1.2, 1.8, 1.4];
            
            % 初始化市场状态
            obj.supply = zeros(n_commodities, 1);
            obj.demand = zeros(n_commodities, 1);
            obj.market_prices = obj.base_prices';
            obj.market_clearing = false(n_commodities, 1);
            
            % 初始化历史记录
            obj.price_history = [];
            obj.consumption_history = [];
            obj.welfare_history = [];
        end
        
        function initialize_government_expenditure(obj)
            % 初始化政府支出
            obj.public_goods = struct();
            obj.public_goods.education = 0.15;      % 教育支出比例
            obj.public_goods.health = 0.12;         % 医疗支出比例
            obj.public_goods.infrastructure = 0.20;  % 基础设施支出比例
            obj.public_goods.social_security = 0.10; % 社会保障支出比例
            obj.public_goods.environment = 0.08;     % 环境保护支出比例
            
            obj.public_services = struct();
            obj.public_services.administration = 0.10; % 行政管理
            obj.public_services.public_safety = 0.08;  % 公共安全
            obj.public_services.culture = 0.05;        % 文化体育
            
            obj.infrastructure = struct();
            obj.infrastructure.transportation = 0.25;   % 交通基础设施
            obj.infrastructure.utilities = 0.20;        % 公用事业
            obj.infrastructure.rural_development = 0.30; % 农村发展
            obj.infrastructure.urban_planning = 0.25;   % 城市规划
        end
        
        function update(obj)
            % 更新商品市场
            obj.update_household_consumption();
            obj.update_government_expenditure();
            obj.update_market_equilibrium();
            obj.update_welfare_metrics();
            obj.record_market_data();
        end
        
        function update_household_consumption(obj)
            % 更新农户消费行为 (基于经典农户模型)
            households = obj.model.households;
            n_commodities = length(obj.commodity_types);
            
            % 重置需求
            obj.demand = zeros(n_commodities, 1);
            
            for i = 1:length(households)
                household = households{i};
                
                % 计算农户消费决策
                consumption = obj.calculate_household_consumption(household);
                
                % 累加到总需求
                obj.demand = obj.demand + consumption;
            end
        end
        
        function consumption = calculate_household_consumption(obj, household)
            % 计算农户消费决策 (基于 Singh et al. 1986 农户模型)
            n_commodities = length(obj.commodity_types);
            consumption = zeros(n_commodities, 1);
            
            % 农户总收入
            total_income = household.income.total;
            
            % 基本生活需求 (Engel 曲线)
            basic_needs = obj.calculate_basic_needs(household);
            
            % 可支配收入
            disposable_income = total_income - sum(basic_needs .* obj.market_prices);
            
            if disposable_income > 0
                % 扩展消费 (基于 Cobb-Douglas 效用函数)
                consumption = obj.calculate_extended_consumption(household, disposable_income);
            end
            
            % 总消费 = 基本需求 + 扩展消费
            consumption = basic_needs + consumption;
        end
        
        function basic_needs = calculate_basic_needs(obj, household)
            % 计算基本生活需求 (基于 Engel 曲线)
            n_commodities = length(obj.commodity_types);
            basic_needs = zeros(n_commodities, 1);
            
            % 家庭规模影响
            family_size = household.family_size;
            
            % 基本需求函数 (Engel 曲线)
            basic_needs(1) = 0.4 * family_size;  % 食品需求
            basic_needs(2) = 0.1 * family_size;  % 服装需求
            basic_needs(3) = 0.05 * family_size; % 住房需求
            basic_needs(4) = 0.02 * family_size; % 教育需求
            basic_needs(5) = 0.03 * family_size; % 医疗需求
            basic_needs(6) = 0.01 * family_size; % 娱乐需求
            basic_needs(7) = 0.02 * family_size; % 交通需求
            
            % 收入水平调整
            income_factor = min(1.5, max(0.5, household.income.total / 20000));
            basic_needs = basic_needs * income_factor;
        end
        
        function extended_consumption = calculate_extended_consumption(obj, household, disposable_income)
            % 计算扩展消费 (基于 Cobb-Douglas 效用函数)
            n_commodities = length(obj.commodity_types);
            extended_consumption = zeros(n_commodities, 1);
            
            % 消费偏好参数 (基于收入弹性)
            preferences = obj.income_elasticities / sum(obj.income_elasticities);
            
            % Cobb-Douglas 效用最大化
            for i = 1:n_commodities
                if obj.market_prices(i) > 0
                    % 最优消费量
                    extended_consumption(i) = preferences(i) * disposable_income / obj.market_prices(i);
                end
            end
        end
        
        function update_government_expenditure(obj)
            % 更新政府支出 (基于公共经济学理论)
            government = obj.model.government;
            n_commodities = length(obj.commodity_types);
            
            % 政府总预算
            total_budget = government.budget.total;
            
            % 公共品支出
            public_expenditure = zeros(n_commodities, 1);
            
            % 教育支出
            public_expenditure(4) = total_budget * obj.public_goods.education;
            
            % 医疗支出
            public_expenditure(5) = total_budget * obj.public_goods.health;
            
            % 基础设施支出 (影响交通)
            public_expenditure(7) = total_budget * obj.infrastructure.transportation;
            
            % 将政府支出加入需求
            obj.demand = obj.demand + public_expenditure;
        end
        
        function update_market_equilibrium(obj)
            % 更新市场均衡 (基于 Walras 均衡理论)
            n_commodities = length(obj.commodity_types);
            
            % 更新供给 (简化处理：基于企业生产)
            obj.update_supply();
            
            % 市场出清
            for i = 1:n_commodities
                if obj.supply(i) > 0
                    % 价格调整 (tâtonnement 过程)
                    excess_demand = obj.demand(i) - obj.supply(i);
                    price_adjustment = 0.01 * excess_demand / obj.supply(i);
                    
                    % 更新价格
                    obj.market_prices(i) = max(0.1, obj.market_prices(i) * (1 + price_adjustment));
                    
                    % 检查市场出清
                    obj.market_clearing(i) = abs(excess_demand) < 0.01 * obj.supply(i);
                end
            end
        end
        
        function update_supply(obj)
            % 更新供给 (基于企业生产)
            n_commodities = length(obj.commodity_types);
            enterprises = obj.model.enterprises;
            
            % 重置供给
            obj.supply = zeros(n_commodities, 1);
            
            for i = 1:length(enterprises)
                enterprise = enterprises{i};
                
                % 企业生产决策
                production = obj.calculate_enterprise_production(enterprise);
                
                % 累加到总供给
                obj.supply = obj.supply + production;
            end
        end
        
        function production = calculate_enterprise_production(obj, enterprise)
            % 计算企业生产决策
            n_commodities = length(obj.commodity_types);
            production = zeros(n_commodities, 1);
            
            % 基于企业类型和生产能力
            switch enterprise.type
                case 'agricultural'
                    % 农业企业主要生产食品
                    production(1) = enterprise.capacity * 0.8;
                case 'industrial'
                    % 工业企业生产多种商品
                    production(2) = enterprise.capacity * 0.3;  % 服装
                    production(3) = enterprise.capacity * 0.2;  % 住房材料
                    production(6) = enterprise.capacity * 0.1;  % 娱乐用品
                    production(7) = enterprise.capacity * 0.1;  % 交通工具
                case 'service'
                    % 服务业企业提供服务和教育
                    production(4) = enterprise.capacity * 0.4;  % 教育服务
                    production(5) = enterprise.capacity * 0.3;  % 医疗服务
                    production(6) = enterprise.capacity * 0.2;  % 娱乐服务
            end
            
            % 价格影响
            for i = 1:n_commodities
                if production(i) > 0
                    % 价格弹性调整
                    price_factor = (obj.market_prices(i) / obj.base_prices(i))^obj.price_elasticities(i);
                    production(i) = production(i) * price_factor;
                end
            end
        end
        
        function update_welfare_metrics(obj)
            % 更新福利指标
            households = obj.model.households;
            
            % 计算消费者剩余
            consumer_surplus = obj.calculate_consumer_surplus(households);
            
            % 计算生产者剩余
            producer_surplus = obj.calculate_producer_surplus();
            
            % 计算社会福利
            social_welfare = consumer_surplus + producer_surplus;
            
            % 记录福利历史
            welfare_record = struct();
            welfare_record.time = obj.model.current_time;
            welfare_record.consumer_surplus = consumer_surplus;
            welfare_record.producer_surplus = producer_surplus;
            welfare_record.social_welfare = social_welfare;
            welfare_record.price_index = mean(obj.market_prices ./ obj.base_prices');
            
            obj.welfare_history = [obj.welfare_history; welfare_record];
        end
        
        function consumer_surplus = calculate_consumer_surplus(obj, households)
            % 计算消费者剩余
            consumer_surplus = 0;
            
            for i = 1:length(households)
                household = households{i};
                
                % 计算效用
                utility = obj.calculate_household_utility(household);
                
                % 计算支出
                expenditure = sum(household.consumption .* obj.market_prices);
                
                % 消费者剩余 = 效用 - 支出
                consumer_surplus = consumer_surplus + utility - expenditure;
            end
        end
        
        function utility = calculate_household_utility(obj, household)
            % 计算农户效用 (基于 Cobb-Douglas 效用函数)
            consumption = household.consumption;
            
            % Cobb-Douglas 效用函数
            utility = 1;
            for i = 1:length(consumption)
                if consumption(i) > 0
                    utility = utility * (consumption(i) ^ obj.income_elasticities(i));
                end
            end
        end
        
        function producer_surplus = calculate_producer_surplus(obj)
            % 计算生产者剩余
            enterprises = obj.model.enterprises;
            producer_surplus = 0;
            
            for i = 1:length(enterprises)
                enterprise = enterprises{i};
                
                % 生产者剩余 = 收入 - 成本
                revenue = sum(enterprise.production .* obj.market_prices);
                cost = enterprise.capital * 0.1 + enterprise.workers * enterprise.wage * 12;
                
                producer_surplus = producer_surplus + revenue - cost;
            end
        end
        
        function record_market_data(obj)
            % 记录市场数据
            record = struct();
            record.time = obj.model.current_time;
            record.supply = obj.supply;
            record.demand = obj.demand;
            record.prices = obj.market_prices;
            record.market_clearing = obj.market_clearing;
            
            obj.price_history = [obj.price_history; record];
        end
        
        function plot_market_analysis(obj)
            % 绘制市场分析图表
            if ~isempty(obj.price_history)
                figure('Name', 'Commodity Market Analysis', 'Position', [100, 100, 1200, 800]);
                
                % 价格趋势
                subplot(2, 3, 1);
                times = [obj.price_history.time];
                prices = [obj.price_history.prices];
                plot(times, prices);
                xlabel('Time');
                ylabel('Price');
                title('Commodity Price Trends');
                legend(obj.commodity_types);
                grid on;
                
                % 供需平衡
                subplot(2, 3, 2);
                latest_record = obj.price_history(end);
                bar([latest_record.supply, latest_record.demand]);
                xlabel('Commodity Type');
                ylabel('Quantity');
                title('Supply vs Demand');
                legend('Supply', 'Demand');
                set(gca, 'XTickLabel', obj.commodity_types);
                grid on;
                
                % 市场出清状态
                subplot(2, 3, 3);
                clearing_status = [obj.price_history.market_clearing];
                imagesc(clearing_status');
                xlabel('Time');
                ylabel('Commodity Type');
                title('Market Clearing Status');
                set(gca, 'YTickLabel', obj.commodity_types);
                colorbar;
                
                % 福利指标
                if ~isempty(obj.welfare_history)
                    subplot(2, 3, 4);
                    welfare_times = [obj.welfare_history.time];
                    consumer_surplus = [obj.welfare_history.consumer_surplus];
                    producer_surplus = [obj.welfare_history.producer_surplus];
                    social_welfare = [obj.welfare_history.social_welfare];
                    
                    plot(welfare_times, consumer_surplus, 'b-', 'LineWidth', 2);
                    hold on;
                    plot(welfare_times, producer_surplus, 'r-', 'LineWidth', 2);
                    plot(welfare_times, social_welfare, 'g-', 'LineWidth', 2);
                    xlabel('Time');
                    ylabel('Welfare');
                    title('Welfare Metrics');
                    legend('Consumer Surplus', 'Producer Surplus', 'Social Welfare');
                    grid on;
                    
                    % 价格指数
                    subplot(2, 3, 5);
                    price_index = [obj.welfare_history.price_index];
                    plot(welfare_times, price_index, 'm-', 'LineWidth', 2);
                    xlabel('Time');
                    ylabel('Price Index');
                    title('Price Index Trend');
                    grid on;
                end
                
                sgtitle('Commodity Market Analysis Results');
            end
        end
    end
end 
