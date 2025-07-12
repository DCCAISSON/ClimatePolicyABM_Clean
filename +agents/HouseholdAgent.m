% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % 农户智能体类
    % 包含农户的基本属性、决策逻辑和状态更新
    
    properties
        % 基本属性
        id              % 农户ID
        age             % 年龄
        gender          % 性别 (0: 女性, 1: 男性)
        education       % 教育年限
        family_size     % 家庭人口
        land_holding    % 土地持有量
        
        % 位置信息
        location        % 空间位置 [x, y]
        
        % 收入信息
        income          % 收入结构
        wealth          % 财富
        
        % 决策变量
        decision        % 决策结构
        preferences     % 偏好参数
        
        % 状态变量
        status          % 状态信息
        history         % 历史记录
        
        % 外部影响
        climate_impact  % 气候影响
        policy_impact   % 政策影响
        market_impact   % 市场影响
        
        % 土地流转相关属性 (新增)
        land_params     % 土地流转参数
        info_access     % 信息获取能力 (0-1)
        theta_land      % 土地情感偏好
        
        % 消费行为 (新增)
        consumption     % 消费结构
    end
    
    methods
        function obj = HouseholdAgent(id, params, spatial_grid)
            % 构造函数
            obj.id = id;
            
            % 初始化基本属性
            obj.initialize_attributes(params);
            
            % 初始化位置
            obj.initialize_location(spatial_grid);
            
            % 初始化收入
            obj.initialize_income();
            
            % 初始化决策
            obj.initialize_decision();
            
            % 初始化状态
            obj.initialize_status();
            
            % 初始化土地流转参数 (新增)
            obj.initialize_land_transfer_params(params);
        end
        
        function initialize_attributes(obj, params)
            % 初始化基本属性 (增强异质性)
            age_dist = params.age_distribution;
            obj.age = max(20, min(80, round(normrnd(age_dist.mean, age_dist.std))));
            
            obj.gender = rand < params.gender_ratio;
            
            edu_dist = params.education_distribution;
            obj.education = max(0, min(16, round(normrnd(edu_dist.mean, edu_dist.std))));
            
            family_dist = params.family_size_distribution;
            obj.family_size = max(1, min(10, round(normrnd(family_dist.mean, family_dist.std))));
            
            land_dist = params.land_holding_distribution;
            obj.land_holding = max(0, normrnd(land_dist.mean, land_dist.std));
            
            % 增强异质性：偏好参数 (基于个体特征)
            obj.preferences = struct();
            
            % 风险厌恶：年龄、教育、性别影响
            age_factor = 0.3 + 0.4 * (obj.age - 20) / 60;  % 年龄越大越保守
            edu_factor = 0.2 + 0.3 * (obj.education / 16);  % 教育越高越开放
            gender_factor = 0.1 * (obj.gender - 0.5);  % 性别差异
            obj.preferences.risk_aversion = min(1, max(0, 0.5 + age_factor - edu_factor + gender_factor + 0.2 * randn));
            
            % 时间偏好：年龄、家庭规模影响
            obj.preferences.time_preference = 0.3 + 0.4 * (obj.age - 20) / 60 + 0.1 * (obj.family_size - 4) / 6 + 0.2 * rand;
            
            % 劳动偏好：年龄、教育、性别影响
            obj.preferences.labor_preference = 0.4 + 0.3 * (1 - (obj.age - 20) / 60) + 0.2 * (obj.education / 16) + 0.1 * obj.gender + 0.2 * rand;
            
            % 土地偏好：土地持有量、年龄影响
            obj.preferences.land_preference = 0.3 + 0.4 * min(1, obj.land_holding / 10) + 0.2 * (obj.age - 20) / 60 + 0.1 * rand;
            
            % 新增：学习能力 (基于教育、年龄)
            obj.learning_ability = 0.3 + 0.4 * (obj.education / 16) + 0.2 * (1 - (obj.age - 20) / 60) + 0.1 * rand;
            
            % 新增：社会网络强度 (基于家庭规模、教育)
            obj.social_network_strength = 0.2 + 0.3 * min(1, obj.family_size / 8) + 0.3 * (obj.education / 16) + 0.2 * rand;
            
            % 新增：信息获取能力 (基于教育、年龄、社会网络)
            obj.info_access = 0.2 + 0.3 * (obj.education / 16) + 0.2 * (1 - (obj.age - 20) / 60) + 0.2 * obj.social_network_strength + 0.1 * rand;
            
            % 新增：决策风格 (经验法则 vs 理性计算)
            obj.decision_style = struct();
            obj.decision_style.rule_based_prob = 0.4 + 0.3 * (1 - obj.learning_ability) + 0.2 * (1 - obj.education / 16);  % 经验法则概率
            obj.decision_style.imitation_prob = 0.3 + 0.4 * obj.social_network_strength + 0.2 * rand;  % 模仿概率
            obj.decision_style.exploration_prob = 0.1 + 0.2 * obj.learning_ability + 0.1 * rand;  % 探索概率
            
            % 新增：历史记忆长度 (基于年龄、教育)
            obj.memory_length = max(1, min(10, round(3 + 2 * (obj.age - 20) / 60 + 2 * (obj.education / 16) + randn)));
        end
        
        function initialize_land_transfer_params(obj, params)
            % 初始化土地流转参数 (新增)
            obj.land_params = struct();
            
            % 从配置中获取土地流转参数，如果没有则使用默认值
            if isfield(params, 'land_module')
                land_module = params.land_module;
                obj.land_params.mu_rho = land_module.mu_rho;
                obj.land_params.sigma_rho = land_module.sigma_rho;
                obj.land_params.c0 = land_module.c0;
                obj.land_params.c_search = land_module.c_search;
            else
                % 默认参数
                obj.land_params.mu_rho = 80;      % 情感溢价均值
                obj.land_params.sigma_rho = 20;   % 情感溢价标准差
                obj.land_params.c0 = 30;          % 固定交易成本
                obj.land_params.c_search = 50;    % 信息搜索成本
            end
            
            % 个体异质性参数
            obj.info_access = 0.5 + 0.5 * rand;  % 信息获取能力 (0-1)
            obj.theta_land = obj.preferences.land_preference;  % 土地情感偏好
        end
        
        function initialize_location(obj, spatial_grid)
            % 初始化位置
            grid_size = spatial_grid.size;
            
            % 在农业区域随机分配位置
            agricultural_cells = find(spatial_grid.land_use == 0);
            if ~isempty(agricultural_cells)
                cell_idx = agricultural_cells(randi(length(agricultural_cells)));
                [row, col] = ind2sub(grid_size, cell_idx);
                obj.location = [row, col];
            else
                % 如果没有农业区域，随机分配
                obj.location = [randi(grid_size(1)), randi(grid_size(2))];
            end
        end
        
        function initialize_income(obj)
            % 初始化收入
            obj.income = struct();
            obj.income.agricultural = 0;  % 农业收入
            obj.income.off_farm = 0;      % 非农收入
            obj.income.subsidy = 0;       % 补贴收入
            obj.income.total = 0;         % 总收入
            obj.income.rent = 0;          % 地租收入
            
            % 初始化财富
            obj.wealth = rand * 10000;  % 初始财富
            
            % 初始化消费行为 (新增)
            obj.initialize_consumption();
        end
        
        function initialize_consumption(obj)
            % 初始化消费行为 (基于经典农户模型)
            obj.consumption = struct();
            
            % 消费量 (7种商品)
            obj.consumption.food = 0;           % 食品消费
            obj.consumption.clothing = 0;       % 服装消费
            obj.consumption.housing = 0;        % 住房消费
            obj.consumption.education = 0;      % 教育消费
            obj.consumption.health = 0;         % 医疗消费
            obj.consumption.entertainment = 0;  % 娱乐消费
            obj.consumption.transportation = 0; % 交通消费
            
            % 消费支出
            obj.consumption.expenditure = 0;    % 总消费支出
            
            % 消费效用
            obj.consumption.utility = 0;        % 消费效用
            
            % 消费偏好
            obj.consumption.preferences = struct();
            obj.consumption.preferences.food_share = 0.4;        % 食品消费比例
            obj.consumption.preferences.clothing_share = 0.1;    % 服装消费比例
            obj.consumption.preferences.housing_share = 0.2;     % 住房消费比例
            obj.consumption.preferences.education_share = 0.1;   % 教育消费比例
            obj.consumption.preferences.health_share = 0.1;      % 医疗消费比例
            obj.consumption.preferences.entertainment_share = 0.05; % 娱乐消费比例
            obj.consumption.preferences.transportation_share = 0.05; % 交通消费比例
            
            % 消费历史
            obj.consumption.history = [];
        end
        
        function initialize_decision(obj)
            % 初始化决策
            obj.decision = struct();
            obj.decision.work_off_farm = false;    % 是否外出务工
            obj.decision.plant_grain = true;       % 是否种植粮食
            obj.decision.land_transfer = false;    % 是否流转土地
            obj.decision.technology_adoption = false; % 是否采用新技术
            obj.decision.crop_diversification = 0.5;  % 作物多样化程度
        end
        
        function initialize_status(obj)
            % 初始化状态
            obj.status = struct();
            obj.status.employed = false;           % 是否就业
            obj.status.employed_enterprise = [];   % 就业企业
            obj.status.health = 1.0;               % 健康状态
            obj.status.nutrition = 1.0;            % 营养状态
            obj.status.satisfaction = 0.5;         % 满意度
            
            % 初始化历史记录
            obj.history = struct();
            obj.history.income_trajectory = [];
            obj.history.decision_trajectory = [];
            obj.history.status_trajectory = [];
        end
        
        function update_decision(obj, model, current_time)
            % 更新农户决策 (增强异质性决策机制)
            % 基于有界理性、社会学习、经验法则等多样化决策
            
            % 获取邻居信息
            neighbors = obj.get_neighbors(model);
            
            % 根据决策风格选择决策方式
            decision_method = obj.select_decision_method();
            
            switch decision_method
                case 'rule_based'
                    obj.update_decision_rule_based(model, current_time);
                case 'imitation'
                    obj.update_decision_imitation(model, neighbors);
                case 'exploration'
                    obj.update_decision_exploration(model, current_time);
                case 'learning'
                    obj.update_decision_learning(model, current_time);
            end
            
            % 记录决策历史
            obj.record_decision_history(current_time);
        end
        
        function decision_method = select_decision_method(obj)
            % 选择决策方式 (基于决策风格)
            rand_val = rand;
            
            if rand_val < obj.decision_style.rule_based_prob
                decision_method = 'rule_based';
            elseif rand_val < obj.decision_style.rule_based_prob + obj.decision_style.imitation_prob
                decision_method = 'imitation';
            elseif rand_val < obj.decision_style.rule_based_prob + obj.decision_style.imitation_prob + obj.decision_style.exploration_prob
                decision_method = 'exploration';
            else
                decision_method = 'learning';
            end
        end
        
        function update_decision_rule_based(obj, model, current_time)
            % 经验法则决策 (基于简单规则)
            
            % 务工决策：基于收入比较
            off_farm_income = obj.income.off_farm;
            agricultural_income = obj.income.agricultural;
            income_ratio = off_farm_income / (agricultural_income + 1);
            
            % 简单规则：非农收入高则务工
            if income_ratio > 1.2
                obj.decision.work_off_farm = true;
            elseif income_ratio < 0.8
                obj.decision.work_off_farm = false;
            end
            
            % 种植决策：基于补贴和价格
            subsidy_rate = model.government.policy.grain_subsidy_rate;
            grain_price = model.params.economic.grain_price;
            
            % 简单规则：补贴高或价格高则种粮
            if subsidy_rate > 0.15 || grain_price > 2.8
                obj.decision.plant_grain = true;
            elseif subsidy_rate < 0.05 && grain_price < 2.2
                obj.decision.plant_grain = false;
            end
            
            % 土地流转决策：基于土地持有量和收入
            if obj.land_holding > 8 && obj.income.total > 15000
                obj.decision.land_transfer = true;
            elseif obj.land_holding < 3 || obj.income.total < 8000
                obj.decision.land_transfer = false;
            end
        end
        
        function update_decision_imitation(obj, model, neighbors)
            % 模仿学习决策 (基于邻居表现)
            
            if isempty(neighbors)
                return;
            end
            
            % 计算邻居的平均收益
            neighbor_incomes = zeros(length(neighbors), 1);
            for i = 1:length(neighbors)
                neighbor_incomes(i) = neighbors{i}.income.total;
            end
            
            % 找到收益最高的邻居
            [max_income, max_idx] = max(neighbor_incomes);
            best_neighbor = neighbors{max_idx};
            
            % 模仿概率：基于收益差异和社会网络强度
            income_diff = max_income - obj.income.total;
            imitation_prob = min(0.8, obj.social_network_strength * income_diff / (max_income + 1));
            
            if rand < imitation_prob
                % 模仿最佳邻居的决策
                obj.decision.work_off_farm = best_neighbor.decision.work_off_farm;
                obj.decision.plant_grain = best_neighbor.decision.plant_grain;
                obj.decision.land_transfer = best_neighbor.decision.land_transfer;
            end
        end
        
        function update_decision_exploration(obj, model, current_time)
            % 探索性决策 (随机尝试新策略)
            
            % 随机改变决策
            if rand < 0.1  % 10%概率探索
                obj.decision.work_off_farm = ~obj.decision.work_off_farm;
            end
            
            if rand < 0.1  % 10%概率探索
                obj.decision.plant_grain = ~obj.decision.plant_grain;
            end
            
            if rand < 0.05  % 5%概率探索土地流转
                obj.decision.land_transfer = ~obj.decision.land_transfer;
            end
        end
        
        function update_decision_learning(obj, model, current_time)
            % 学习型决策 (基于历史经验和适应性)
            
            % 获取历史决策效果
            if ~isempty(obj.history.decision_history)
                recent_decisions = obj.history.decision_history(max(1, end-obj.memory_length):end);
                
                % 分析历史决策的成功率
                success_rates = obj.analyze_decision_success(recent_decisions);
                
                % 基于成功率调整决策
                if success_rates.work_off_farm > 0.6
                    obj.decision.work_off_farm = true;
                elseif success_rates.work_off_farm < 0.4
                    obj.decision.work_off_farm = false;
                end
                
                if success_rates.plant_grain > 0.6
                    obj.decision.plant_grain = true;
                elseif success_rates.plant_grain < 0.4
                    obj.decision.plant_grain = false;
                end
            else
                % 无历史记录时使用默认决策
                obj.update_decision_rule_based(model, current_time);
            end
        end
        
        function neighbors = get_neighbors(obj, model)
            % 获取空间邻居 (Moore邻域)
            neighbors = {};
            grid_size = model.spatial_grid.size;
            
            % 搜索8个方向的邻居
            directions = [-1,-1; -1,0; -1,1; 0,-1; 0,1; 1,-1; 1,0; 1,1];
            
            for i = 1:length(model.households)
                neighbor = model.households{i};
                if neighbor.id == obj.id
                    continue;
                end
                
                % 计算距离
                distance = norm(neighbor.location - obj.location);
                if distance <= 2  % 邻居范围
                    neighbors{end+1} = neighbor;
                end
            end
        end
        
        function success_rates = analyze_decision_success(obj, recent_decisions)
            % 分析历史决策的成功率
            success_rates = struct();
            success_rates.work_off_farm = 0.5;
            success_rates.plant_grain = 0.5;
            success_rates.land_transfer = 0.5;
            
            if isempty(recent_decisions)
                return;
            end
            
            % 计算各决策的成功率 (简化计算)
            work_off_farm_count = 0;
            plant_grain_count = 0;
            land_transfer_count = 0;
            
            for i = 1:length(recent_decisions)
                decision = recent_decisions(i);
                if isfield(decision, 'work_off_farm')
                    work_off_farm_count = work_off_farm_count + decision.work_off_farm;
                end
                if isfield(decision, 'plant_grain')
                    plant_grain_count = plant_grain_count + decision.plant_grain;
                end
                if isfield(decision, 'land_transfer')
                    land_transfer_count = land_transfer_count + decision.land_transfer;
                end
            end
            
            success_rates.work_off_farm = work_off_farm_count / length(recent_decisions);
            success_rates.plant_grain = plant_grain_count / length(recent_decisions);
            success_rates.land_transfer = land_transfer_count / length(recent_decisions);
        end
        
        function record_decision_history(obj, current_time)
            % 记录决策历史
            decision_record = struct();
            decision_record.time = current_time;
            decision_record.work_off_farm = obj.decision.work_off_farm;
            decision_record.plant_grain = obj.decision.plant_grain;
            decision_record.land_transfer = obj.decision.land_transfer;
            decision_record.income = obj.income.total;
            
            if ~isfield(obj.history, 'decision_history')
                obj.history.decision_history = [];
            end
            
            obj.history.decision_history = [obj.history.decision_history; decision_record];
            
            % 保持历史记录长度
            if length(obj.history.decision_history) > obj.memory_length
                obj.history.decision_history = obj.history.decision_history(end-obj.memory_length+1:end);
            end
        end
        
        function record_income_history(obj, current_time)
            % 记录收入历史
            income_record = struct();
            income_record.time = current_time;
            income_record.total = obj.income.total;
            income_record.agricultural = obj.income.agricultural;
            income_record.off_farm = obj.income.off_farm;
            income_record.subsidy = obj.income.subsidy;
            
            obj.history.income_trajectory = [obj.history.income_trajectory; income_record];
        end
        
        function record_status_history(obj, current_time)
            % 记录状态历史
            status_record = struct();
            status_record.time = current_time;
            status_record.health = obj.status.health;
            status_record.nutrition = obj.status.nutrition;
            status_record.satisfaction = obj.status.satisfaction;
            status_record.employed = obj.status.employed;
            
            obj.history.status_trajectory = [obj.history.status_trajectory; status_record];
        end

        function ask_price = getAskPrice(obj, avg_rent)
            % 计算农户土地出租要价 (基于顶级土地经济学文献)
            % 参考: Deininger & Jin (2005), Holden et al. (2020), 熊航等 (2023)
            % ask_i = max {0, π_self,i + ρ_i – c_i}
            
            % 1. 计算预期自种净利润/亩 (改进版)
            pi_self = obj.calculate_expected_self_profit_per_mu();
            
            % 2. 计算土地情感溢价 ρ_i (基于Holden et al. 2020)
            % ρ_i = ρ_base + ρ_age + ρ_income + ρ_heritage
            rho_base = normrnd(obj.land_params.mu_rho, obj.land_params.sigma_rho);
            
            % 年龄影响 (U型关系: 年轻和年老农户情感溢价更高)
            age_factor = 0.5 * sin(2*pi*(obj.age-20)/60) + 0.5;
            rho_age = rho_base * 0.3 * age_factor;
            
            % 收入影响 (收入越高，情感溢价越高 - 财富效应)
            income_factor = min(1, obj.income.total / 30000);
            rho_income = rho_base * 0.2 * income_factor;
            
            % 土地传承价值 (基于土地持有时间，简化处理)
            heritage_factor = min(1, obj.land_holding / 10);  % 土地越多传承价值越高
            rho_heritage = rho_base * 0.3 * heritage_factor;
            
            % 综合情感溢价
            rho_i = rho_base + rho_age + rho_income + rho_heritage;
            
            % 3. 计算交易成本 c_i (基于Deininger & Jin 2005)
            % c_i = c_fixed + c_search + c_negotiation + c_contract
            c_fixed = obj.land_params.c0;  % 固定交易成本
            
            % 信息搜索成本 (与信息获取能力负相关)
            c_search = obj.land_params.c_search / (obj.info_access + 0.1);
            
            % 议价成本 (与土地规模正相关)
            c_negotiation = 20 * (obj.land_holding / 5);
            
            % 合同执行成本 (与教育程度负相关)
            c_contract = 30 * (1 - obj.education / 16);
            
            % 政府补贴后的净交易成本
            subsidy_rate = 0.1;  % 简化处理，可从政府政策获取
            c_i = (c_fixed + c_search + c_negotiation + c_contract) * (1 - subsidy_rate);
            
            % 4. 计算要价
            ask_price = max(0, pi_self + rho_i - c_i);
            
            % 确保要价合理 (不超过基准地租的2.5倍)
            ask_price = min(ask_price, avg_rent * 2.5);
        end
        
        function pi_self = calculate_expected_self_profit_per_mu(obj)
            % 计算预期自种净利润/亩 (改进版)
            % 基于熊航等 (2023) 的农户决策模型
            % π_self,i = 预期产量 × 价格 – 投入成本 – 机会成本
            
            % 基础产量 (每亩)
            base_yield = 1000;  % 单位产量
            
            % 技术采用影响 (基于教育程度和风险偏好)
            if obj.decision.technology_adoption
                tech_factor = 1.2 + 0.1 * (obj.education / 16);  % 教育程度影响技术效果
            else
                tech_factor = 1.0;
            end
            
            % 土地质量影响 (简化处理)
            land_quality = 0.8 + 0.4 * rand;  % 土地质量随机分布
            
            % 预期产量
            expected_yield = base_yield * tech_factor * land_quality;
            
            % 预期价格 (考虑价格波动风险)
            if obj.decision.plant_grain
                base_price = 2.5;  % 粮食价格
                price_volatility = 0.1;  % 价格波动率
            else
                base_price = 4.0;  % 经济作物价格
                price_volatility = 0.2;  % 经济作物价格波动更大
            end
            
            % 风险调整后的预期价格
            risk_adjustment = 1 - obj.preferences.risk_aversion * price_volatility;
            expected_price = base_price * risk_adjustment;
            
            % 投入成本 (化肥、种子、机械等)
            input_cost = 800 + 100 * obj.decision.technology_adoption;  % 技术采用增加投入
            
            % 机会成本 (非农就业机会)
            opportunity_cost = 0;
            if obj.income.off_farm > 0
                opportunity_cost = obj.income.off_farm / (obj.land_holding + 1);  % 单位土地机会成本
            end
            
            % 预期净利润
            pi_self = expected_yield * expected_price - input_cost - opportunity_cost;
        end

        function update_consumption(obj, commodity_market)
            % 更新消费决策 (基于23年EER论文的有界理性设定)
            % 参考: Delli Gatti et al. (2011), 23年EER论文公式(A.44)-(A.48)
            
            % 获取市场价格
            market_prices = commodity_market.market_prices;
            
            % 计算预期可支配净收入
            expected_disposable_income = obj.calculate_expected_disposable_income();
            
            % 计算消费预算 (基于23年EER公式A.46)
            consumption_budget = obj.calculate_consumption_budget(expected_disposable_income);
            
            % 分配消费预算到不同商品 (基于23年EER公式A.47)
            consumption_allocation = obj.allocate_consumption_budget(consumption_budget, market_prices);
            
            % 更新消费量
            obj.consumption.food = consumption_allocation(1);
            obj.consumption.clothing = consumption_allocation(2);
            obj.consumption.housing = consumption_allocation(3);
            obj.consumption.education = consumption_allocation(4);
            obj.consumption.health = consumption_allocation(5);
            obj.consumption.entertainment = consumption_allocation(6);
            obj.consumption.transportation = consumption_allocation(7);
            
            % 计算实际消费支出
            obj.consumption.expenditure = sum(consumption_allocation .* market_prices);
            
            % 计算消费效用
            obj.consumption.utility = obj.calculate_consumption_utility(consumption_allocation);
            
            % 记录消费历史
            obj.record_consumption_history();
        end
        
        function expected_income = calculate_expected_disposable_income(obj)
            % 计算预期可支配净收入 (基于23年EER公式A.44)
            % 参考: Delli Gatti et al. (2011), 23年EER论文
            
            % 基础参数设置
            tax_rates = struct();
            tax_rates.income_tax = 0.15;           % 所得税率
            tax_rates.social_insurance = 0.08;     % 社会保险缴费率
            tax_rates.consumption_tax = 0.13;      % 消费税率/VAT
            
            % 根据农户状态计算预期收入
            if obj.status.employed
                % 在业状态
                labor_income = obj.income.off_farm;
                social_benefits = 0; % 其他社会福利
                
                % 预期可支配净收入
                expected_income = ((labor_income * (1 - tax_rates.social_insurance - tax_rates.income_tax * (1 - tax_rates.social_insurance))) + social_benefits);
                
            elseif ~obj.status.employed && obj.income.off_farm > 0
                % 失业状态
                unemployment_benefit_rate = 0.6; % 失业救济率
                unemployment_income = obj.income.off_farm * unemployment_benefit_rate;
                social_benefits = 0; % 其他社会福利
                
                expected_income = (unemployment_income + social_benefits);
                
            else
                % 非经济活动人口
                social_benefits = 2000; % 基本社会保障
                other_benefits = 0; % 其他社会福利
                
                expected_income = (social_benefits + other_benefits);
            end
            
            % 加上农业收入 (免税或低税率)
            agricultural_income = obj.income.agricultural * 0.8; % 农业收入税率较低
            expected_income = expected_income + agricultural_income;
            
            % 加上补贴收入
            subsidy_income = obj.income.subsidy;
            expected_income = expected_income + subsidy_income;
            
            % 加上地租收入
            rent_income = obj.income.rent;
            expected_income = expected_income + rent_income;
        end
        
        function consumption_budget = calculate_consumption_budget(obj, expected_disposable_income)
            % 计算消费预算 (基于23年EER公式A.46)
            % 参考: Delli Gatti et al. (2011)
            
            % 消费倾向 (有界理性设定)
            consumption_propensity = 0.7; % 从预期收入中消费的倾向
            
            % 消费税率
            consumption_tax_rate = 0.13; % VAT税率
            
            % 消费预算计算
            consumption_budget = (consumption_propensity * expected_disposable_income) / (1 + consumption_tax_rate);
        end
        
        function consumption_allocation = allocate_consumption_budget(obj, consumption_budget, market_prices)
            % 分配消费预算到不同商品 (基于23年EER公式A.47)
            % 参考: Delli Gatti et al. (2011)
            
            % 家庭消费系数 (基于农户特征)
            consumption_coefficients = obj.calculate_household_consumption_coefficients();
            
            % 计算消费分配
            consumption_allocation = zeros(7, 1);
            
            for i = 1:7
                if market_prices(i) > 0
                    % 基于消费系数和价格分配消费预算
                    consumption_allocation(i) = (consumption_coefficients(i) * market_prices(i) / sum(consumption_coefficients .* market_prices)) * consumption_budget / market_prices(i);
                end
            end
        end
        
        function coefficients = calculate_household_consumption_coefficients(obj)
            % 计算家庭消费系数 (基于农户特征)
            % 参考: Engel (1857), Deaton & Muellbauer (1980)
            
            coefficients = zeros(7, 1);
            
            % 基础消费系数
            base_coefficients = [0.4, 0.1, 0.2, 0.1, 0.1, 0.05, 0.05]; % 食品、服装、住房、教育、医疗、娱乐、交通
            
            % 根据家庭特征调整系数
            family_size_factor = min(1.5, max(0.5, obj.family_size / 4)); % 家庭规模影响
            income_factor = min(1.3, max(0.7, obj.income.total / 20000)); % 收入水平影响
            age_factor = min(1.2, max(0.8, obj.age / 45)); % 年龄影响
            education_factor = min(1.2, max(0.8, obj.education / 9)); % 教育程度影响
            
            % 计算调整后的系数
            for i = 1:7
                coefficients(i) = base_coefficients(i) * family_size_factor * income_factor * age_factor * education_factor;
            end
            
            % 归一化
            coefficients = coefficients / sum(coefficients);
        end
        
        function utility = calculate_consumption_utility(obj, consumption_vector)
            % 计算消费效用 (基于 Cobb-Douglas 效用函数)
            utility = 1;
            
            % 消费偏好参数
            preferences = [obj.consumption.preferences.food_share, ...
                          obj.consumption.preferences.clothing_share, ...
                          obj.consumption.preferences.housing_share, ...
                          obj.consumption.preferences.education_share, ...
                          obj.consumption.preferences.health_share, ...
                          obj.consumption.preferences.entertainment_share, ...
                          obj.consumption.preferences.transportation_share];
            
            % 归一化偏好
            preferences = preferences / sum(preferences);
            
            % Cobb-Douglas 效用函数
            for i = 1:length(consumption_vector)
                if consumption_vector(i) > 0
                    utility = utility * (consumption_vector(i) ^ preferences(i));
                end
            end
        end
        
        function record_consumption_history(obj)
            % 记录消费历史
            consumption_record = struct();
            consumption_record.time = obj.model.current_time;
            consumption_record.food = obj.consumption.food;
            consumption_record.clothing = obj.consumption.clothing;
            consumption_record.housing = obj.consumption.housing;
            consumption_record.education = obj.consumption.education;
            consumption_record.health = obj.consumption.health;
            consumption_record.entertainment = obj.consumption.entertainment;
            consumption_record.transportation = obj.consumption.transportation;
            consumption_record.expenditure = obj.consumption.expenditure;
            consumption_record.utility = obj.consumption.utility;
            consumption_record.income = obj.income.total;
            
            obj.consumption.history = [obj.consumption.history; consumption_record];
        end
    end
end 
