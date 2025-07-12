% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % 企业智能体类
    % 包含企业的基本属性、决策逻辑和状态更新
    
    properties
        % 基本属性
        id              % 企业ID
        type            % 企业类型 ('agricultural', 'industrial', 'service')
        size            % 企业规模
        location        % 空间位置 [x, y]
        
        % 经济属性
        capital         % 资本
        revenue         % 收入
        profit          % 利润
        wage            % 工资水平
        
        % 生产属性
        productivity    % 生产效率
        capacity        % 生产能力
        workers         % 工人数量
        max_workers     % 最大工人数量
        last_input_price = 0; % 上期化肥价格
        application_rate = 0.1; % 吨/规模单位 (默认)
        
        % 决策变量
        decision        % 决策结构
        strategy        % 战略参数
        
        % 状态变量
        status          % 状态信息
        performance     % 绩效指标
        
        % 外部影响
        market_conditions    % 市场条件
        policy_impact        % 政策影响
        competition          % 竞争环境
        
        % 土地流转相关属性 (新增)
        land_params     % 土地流转参数
        current_land    % 当前经营土地面积
    end
    
    methods
        function obj = EnterpriseAgent(id, params, spatial_grid)
            % 构造函数
            obj.id = id;
            
            % 初始化基本属性
            obj.initialize_attributes(params);
            
            % 初始化位置
            obj.initialize_location(spatial_grid);
            
            % 初始化经济属性
            obj.initialize_economic_attributes();
            
            % 初始化生产属性
            obj.initialize_production_attributes();
            
            % 初始化决策
            obj.initialize_decision();
            
            % 初始化状态
            obj.initialize_status();
            
            % 初始化土地流转参数 (新增)
            obj.initialize_land_transfer_params(params);
        end
        
        function initialize_attributes(obj, params)
            % 初始化基本属性 (增强异质性)
            % 企业类型 (更细致的分类)
            rand_val = rand;
            if rand_val < params.agricultural_ratio
                obj.type = 'agricultural';
                % 农业企业细分
                if rand < params.grain_farm_ratio
                    obj.subtype = 'grain_farm';  % 粮食农场
                elseif rand < params.cash_crop_farm_ratio
                    obj.subtype = 'cash_crop_farm';  % 经济作物农场
                else
                    obj.subtype = 'mixed_farm';  % 混合农场
                end
            elseif rand_val < params.agricultural_ratio + params.chemical_ratio
                obj.type = 'industrial';
                obj.subtype = 'chemical';  % 化工企业
            else
                obj.type = 'service';
                obj.subtype = 'service';  % 服务业
            end
            
            % 企业规模 (基于类型调整)
            size_dist = params.size_distribution;
            base_size = normrnd(size_dist.mean, size_dist.std);
            
            % 根据企业类型调整规模
            switch obj.type
                case 'agricultural'
                    obj.size = max(5, round(base_size * (0.8 + 0.4 * rand)));  % 农业企业规模较小
                case 'industrial'
                    obj.size = max(10, round(base_size * (1.0 + 0.6 * rand)));  % 工业企业规模中等
                case 'service'
                    obj.size = max(8, round(base_size * (0.9 + 0.5 * rand)));   % 服务业企业规模中等
            end
            
            % 最大工人数量
            obj.max_workers = round(obj.size / 2);
            
            % 增强异质性：战略参数 (基于企业类型和规模)
            obj.strategy = struct();
            
            % 风险容忍度：基于企业类型和规模
            switch obj.type
                case 'agricultural'
                    obj.strategy.risk_tolerance = 0.3 + 0.4 * rand;  % 农业企业相对保守
                case 'industrial'
                    obj.strategy.risk_tolerance = 0.5 + 0.4 * rand;  % 工业企业中等风险
                case 'service'
                    obj.strategy.risk_tolerance = 0.6 + 0.3 * rand;  % 服务业企业较高风险
            end
            
            % 增长导向：基于规模和类型
            size_factor = min(1, obj.size / 100);
            obj.strategy.growth_orientation = 0.4 + 0.4 * size_factor + 0.2 * rand;
            
            % 效率导向：基于类型
            switch obj.type
                case 'agricultural'
                    obj.strategy.efficiency_focus = 0.6 + 0.3 * rand;  % 农业企业重视效率
                case 'industrial'
                    obj.strategy.efficiency_focus = 0.7 + 0.2 * rand;  % 工业企业重视效率
                case 'service'
                    obj.strategy.efficiency_focus = 0.5 + 0.3 * rand;  % 服务业企业中等效率
            end
            
            % 市场导向：基于类型
            switch obj.type
                case 'agricultural'
                    obj.strategy.market_orientation = 0.4 + 0.4 * rand;  % 农业企业市场导向中等
                case 'industrial'
                    obj.strategy.market_orientation = 0.6 + 0.3 * rand;  % 工业企业市场导向较高
                case 'service'
                    obj.strategy.market_orientation = 0.7 + 0.2 * rand;  % 服务业企业市场导向最高
            end
            
            % 新增：学习能力 (基于规模和类型)
            obj.learning_ability = 0.3 + 0.4 * min(1, obj.size / 100) + 0.2 * rand;
            
            % 新增：创新能力 (基于类型和战略)
            obj.innovation_capacity = 0.2 + 0.3 * obj.strategy.risk_tolerance + 0.3 * obj.learning_ability + 0.2 * rand;
            
            % 新增：市场信息获取能力
            obj.market_info_access = 0.4 + 0.3 * obj.strategy.market_orientation + 0.2 * rand;
            
            % 新增：决策风格
            obj.decision_style = struct();
            obj.decision_style.rule_based_prob = 0.3 + 0.3 * (1 - obj.learning_ability) + 0.2 * rand;
            obj.decision_style.imitation_prob = 0.2 + 0.3 * obj.market_info_access + 0.2 * rand;
            obj.decision_style.exploration_prob = 0.1 + 0.2 * obj.innovation_capacity + 0.1 * rand;
            obj.decision_style.learning_prob = 0.2 + 0.3 * obj.learning_ability + 0.2 * rand;
            
            % 新增：历史记忆长度
            obj.memory_length = max(3, min(15, round(5 + 3 * (obj.size / 100) + 2 * randn)));
        end
        
        function initialize_land_transfer_params(obj, params)
            % 初始化土地流转参数 (新增)
            obj.land_params = struct();
            
            % 从配置中获取土地流转参数，如果没有则使用默认值
            if isfield(params, 'land_module')
                land_module = params.land_module;
                obj.land_params.alpha_grain = land_module.alpha_grain;
                obj.land_params.alpha_cash = land_module.alpha_cash;
                obj.land_params.psi_grain = land_module.psi_grain;
                obj.land_params.psi_cash = land_module.psi_cash;
            else
                % 默认参数
                obj.land_params.alpha_grain = 0.9;  % 粮食企业租地折扣系数
                obj.land_params.alpha_cash = 1.15;  % 经济作物企业租地加价系数
                obj.land_params.psi_grain = 0.3;    % 粮食企业规模报酬递减参数
                obj.land_params.psi_cash = 0.2;     % 经济作物企业规模报酬递减参数
            end
            
            % 当前经营土地面积 (初始等于企业规模)
            obj.current_land = obj.size;
        end
        
        function initialize_location(obj, spatial_grid)
            % 初始化位置
            grid_size = spatial_grid.size;
            
            % 根据企业类型分配位置
            if strcmp(obj.type, 'agricultural')
                % 农业企业在农业区域
                agricultural_cells = find(spatial_grid.land_use == 0);
                if ~isempty(agricultural_cells)
                    cell_idx = agricultural_cells(randi(length(agricultural_cells)));
                    [row, col] = ind2sub(grid_size, cell_idx);
                    obj.location = [row, col];
                else
                    obj.location = [randi(grid_size(1)), randi(grid_size(2))];
                end
            else
                % 非农企业在城市区域
                urban_cells = find(spatial_grid.land_use == 1);
                if ~isempty(urban_cells)
                    cell_idx = urban_cells(randi(length(urban_cells)));
                    [row, col] = ind2sub(grid_size, cell_idx);
                    obj.location = [row, col];
                else
                    obj.location = [randi(grid_size(1)), randi(grid_size(2))];
                end
            end
        end
        
        function initialize_economic_attributes(obj)
            % 初始化经济属性
            % 初始资本
            obj.capital = obj.size * 1000;  % 规模越大，初始资本越多
            
            % 工资水平
            base_wage = 3000;
            wage_variation = randn * 500;
            obj.wage = max(2000, base_wage + wage_variation);
            
            % 初始收入和利润
            obj.revenue = 0;
            obj.profit = 0;
        end
        
        function initialize_production_attributes(obj)
            % 初始化生产属性
            % 基础生产效率
            base_productivity = 1.0;
            
            % 根据企业类型调整生产效率
            switch obj.type
                case 'agricultural'
                    obj.productivity = base_productivity * (0.8 + 0.4 * rand);  % 农业企业效率较低
                case 'industrial'
                    obj.productivity = base_productivity * (1.0 + 0.5 * rand);  % 工业企业效率中等
                case 'service'
                    obj.productivity = base_productivity * (1.2 + 0.6 * rand);  % 服务业企业效率较高
            end
            
            % 生产能力
            obj.capacity = obj.size * obj.productivity;
            
            % 工人数量
            obj.workers = 0;
        end
        
        function initialize_decision(obj)
            % 初始化决策
            obj.decision = struct();
            obj.decision.hire_workers = false;      % 是否雇佣工人
            obj.decision.invest_capital = false;    % 是否投资
            obj.decision.expand_production = false; % 是否扩大生产
            obj.decision.change_strategy = false;   % 是否改变战略
            
            % 初始化战略参数
            obj.strategy = struct();
            obj.strategy.risk_tolerance = rand;     % 风险容忍度
            obj.strategy.growth_orientation = rand; % 增长导向
            obj.strategy.efficiency_focus = rand;   % 效率导向
            obj.strategy.market_orientation = rand; % 市场导向
        end
        
        function initialize_status(obj)
            % 初始化状态
            obj.status = struct();
            obj.status.operational = true;          % 是否运营
            obj.status.growing = false;             % 是否增长
            obj.status.profitable = false;          % 是否盈利
            obj.status.competitive = true;          % 是否具有竞争力
            
            % 初始化绩效指标
            obj.performance = struct();
            obj.performance.efficiency = obj.productivity;
            obj.performance.profitability = 0;
            obj.performance.growth_rate = 0;
            obj.performance.market_share = 0;
        end
        
        function update_decision(obj, model, current_time)
            % 更新企业决策 (增强异质性决策机制)
            % 基于有界理性、市场学习、战略导向等多样化决策
            
            % 获取竞争对手信息
            competitors = obj.get_competitors(model);
            
            % 根据决策风格选择决策方式
            decision_method = obj.select_decision_method();
            
            switch decision_method
                case 'rule_based'
                    obj.update_decision_rule_based(model, current_time);
                case 'imitation'
                    obj.update_decision_imitation(model, competitors);
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
            
            % 雇佣决策：基于利润和增长导向
            profit_margin = obj.profit / (obj.revenue + 1);
            growth_factor = obj.strategy.growth_orientation;
            
            % 简单规则：利润高且增长导向强则雇佣
            if profit_margin > 0.1 && growth_factor > 0.6 && obj.workers < obj.max_workers
                obj.decision.hire_workers = true;
            elseif profit_margin < 0.05 || obj.workers >= obj.max_workers
                obj.decision.hire_workers = false;
            end
            
            % 投资决策：基于资本和效率导向
            capital_ratio = obj.capital / (obj.size * 1000);
            efficiency_factor = obj.strategy.efficiency_focus;
            
            % 简单规则：资本充足且重视效率则投资
            if capital_ratio > 1.2 && efficiency_factor > 0.6
                obj.decision.invest_capital = true;
            elseif capital_ratio < 0.8
                obj.decision.invest_capital = false;
            end
            
            % 扩大生产决策：基于市场需求和规模
            market_demand = obj.estimate_market_demand(model);
            size_factor = obj.size / 100;
            
            % 简单规则：需求高且规模适中则扩大生产
            if market_demand > 0.7 && size_factor < 0.8
                obj.decision.expand_production = true;
            elseif market_demand < 0.3 || size_factor > 1.2
                obj.decision.expand_production = false;
            end
        end
        
        function update_decision_imitation(obj, model, competitors)
            % 模仿学习决策 (基于竞争对手表现)
            
            if isempty(competitors)
                return;
            end
            
            % 计算竞争对手的平均利润率
            competitor_profits = zeros(length(competitors), 1);
            for i = 1:length(competitors)
                competitor_profits(i) = competitors{i}.profit / (competitors{i}.revenue + 1);
            end
            
            % 找到利润率最高的竞争对手
            [max_profit, max_idx] = max(competitor_profits);
            best_competitor = competitors{max_idx};
            
            % 模仿概率：基于利润差异和市场信息获取能力
            own_profit = obj.profit / (obj.revenue + 1);
            profit_diff = max_profit - own_profit;
            imitation_prob = min(0.7, obj.market_info_access * profit_diff / (max_profit + 0.1));
            
            if rand < imitation_prob
                % 模仿最佳竞争对手的决策
                obj.decision.hire_workers = best_competitor.decision.hire_workers;
                obj.decision.invest_capital = best_competitor.decision.invest_capital;
                obj.decision.expand_production = best_competitor.decision.expand_production;
            end
        end
        
        function update_decision_exploration(obj, model, current_time)
            % 探索性决策 (随机尝试新策略)
            
            % 随机改变决策
            if rand < 0.08  % 8%概率探索
                obj.decision.hire_workers = ~obj.decision.hire_workers;
            end
            
            if rand < 0.06  % 6%概率探索
                obj.decision.invest_capital = ~obj.decision.invest_capital;
            end
            
            if rand < 0.04  % 4%概率探索
                obj.decision.expand_production = ~obj.decision.expand_production;
            end
            
            % 随机调整战略参数
            if rand < 0.05  % 5%概率调整战略
                obj.strategy.risk_tolerance = max(0, min(1, obj.strategy.risk_tolerance + 0.1 * randn));
                obj.strategy.growth_orientation = max(0, min(1, obj.strategy.growth_orientation + 0.1 * randn));
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
                if success_rates.hire_workers > 0.6
                    obj.decision.hire_workers = true;
                elseif success_rates.hire_workers < 0.4
                    obj.decision.hire_workers = false;
                end
                
                if success_rates.invest_capital > 0.6
                    obj.decision.invest_capital = true;
                elseif success_rates.invest_capital < 0.4
                    obj.decision.invest_capital = false;
                end
                
                if success_rates.expand_production > 0.6
                    obj.decision.expand_production = true;
                elseif success_rates.expand_production < 0.4
                    obj.decision.expand_production = false;
                end
            else
                % 无历史记录时使用默认决策
                obj.update_decision_rule_based(model, current_time);
            end
        end
        
        function competitors = get_competitors(obj, model)
            % 获取同类型竞争对手
            competitors = {};
            
            for i = 1:length(model.enterprises)
                competitor = model.enterprises{i};
                if competitor.id == obj.id
                    continue;
                end
                
                % 同类型企业视为竞争对手
                if strcmp(competitor.type, obj.type)
                    competitors{end+1} = competitor;
                end
            end
        end
        
        function market_demand = estimate_market_demand(obj, model)
            % 估算市场需求 (简化)
            % 基于宏观经济条件和企业类型
            
            base_demand = 0.6;  % 基础需求
            
            % 根据企业类型调整需求
            switch obj.type
                case 'agricultural'
                    market_demand = base_demand + 0.2 * rand;  % 农业需求相对稳定
                case 'industrial'
                    market_demand = base_demand + 0.3 * rand;  % 工业需求波动较大
                case 'service'
                    market_demand = base_demand + 0.4 * rand;  % 服务业需求波动最大
            end
            
            market_demand = max(0, min(1, market_demand));
        end
        
        function success_rates = analyze_decision_success(obj, recent_decisions)
            % 分析历史决策的成功率
            success_rates = struct();
            success_rates.hire_workers = 0.5;
            success_rates.invest_capital = 0.5;
            success_rates.expand_production = 0.5;
            
            if isempty(recent_decisions)
                return;
            end
            
            % 计算各决策的成功率 (简化计算)
            hire_workers_count = 0;
            invest_capital_count = 0;
            expand_production_count = 0;
            
            for i = 1:length(recent_decisions)
                decision = recent_decisions(i);
                if isfield(decision, 'hire_workers')
                    hire_workers_count = hire_workers_count + decision.hire_workers;
                end
                if isfield(decision, 'invest_capital')
                    invest_capital_count = invest_capital_count + decision.invest_capital;
                end
                if isfield(decision, 'expand_production')
                    expand_production_count = expand_production_count + decision.expand_production;
                end
            end
            
            success_rates.hire_workers = hire_workers_count / length(recent_decisions);
            success_rates.invest_capital = invest_capital_count / length(recent_decisions);
            success_rates.expand_production = expand_production_count / length(recent_decisions);
        end
        
        function record_decision_history(obj, current_time)
            % 记录决策历史
            decision_record = struct();
            decision_record.time = current_time;
            decision_record.hire_workers = obj.decision.hire_workers;
            decision_record.invest_capital = obj.decision.invest_capital;
            decision_record.expand_production = obj.decision.expand_production;
            decision_record.profit = obj.profit;
            decision_record.revenue = obj.revenue;
            
            if ~isfield(obj.history, 'decision_history')
                obj.history.decision_history = [];
            end
            
            obj.history.decision_history = [obj.history.decision_history; decision_record];
            
            % 保持历史记录长度
            if length(obj.history.decision_history) > obj.memory_length
                obj.history.decision_history = obj.history.decision_history(end-obj.memory_length+1:end);
            end
        end
        
        function prob = calculate_hire_probability(obj)
            % 计算雇佣工人概率
            % 基于当前工人数量、生产能力、利润等因素
            
            % 基础概率
            base_prob = 0.2;
            
            % 工人需求 (当前工人数少于最大工人数)
            worker_need = max(0, (obj.max_workers - obj.workers) / obj.max_workers);
            
            % 盈利能力影响
            if obj.capital > 0
                profitability = obj.profit / obj.capital;
                profit_factor = max(0, min(1, profitability + 0.1));
            else
                profit_factor = 0;
            end
            
            % 生产能力利用率
            capacity_utilization = obj.workers / obj.max_workers;
            capacity_factor = max(0, 1 - capacity_utilization);
            
            % 综合概率
            prob = base_prob + 0.4 * worker_need + 0.2 * profit_factor + 0.2 * capacity_factor;
            
            % 限制在合理范围内
            prob = max(0, min(1, prob));
        end
        
        function prob = calculate_invest_probability(obj)
            % 计算投资概率
            % 基于资本充足性、盈利能力、增长机会等因素
            
            % 基础概率
            base_prob = 0.1;
            
            % 资本充足性
            capital_adequacy = min(1, obj.capital / (obj.size * 2000));
            
            % 盈利能力
            if obj.capital > 0
                profitability = max(0, obj.profit / obj.capital);
            else
                profitability = 0;
            end
            
            % 增长机会 (基于战略导向)
            growth_opportunity = obj.strategy.growth_orientation;
            
            % 综合概率
            prob = base_prob + 0.3 * capital_adequacy + 0.3 * profitability + 0.3 * growth_opportunity;
            
            % 限制在合理范围内
            prob = max(0, min(1, prob));
        end
        
        function prob = calculate_expand_production_probability(obj)
            % 计算扩大生产概率
            % 基于市场需求、生产能力、竞争环境等因素
            
            % 基础概率
            base_prob = 0.15;
            
            % 生产能力利用率
            capacity_utilization = obj.workers / obj.max_workers;
            capacity_factor = min(1, capacity_utilization);
            
            % 盈利能力
            if obj.capital > 0
                profitability = max(0, obj.profit / obj.capital);
            else
                profitability = 0;
            end
            
            % 竞争压力
            competition_factor = 1 - obj.performance.market_share;
            
            % 综合概率
            prob = base_prob + 0.3 * capacity_factor + 0.3 * profitability + 0.25 * competition_factor;
            
            % 限制在合理范围内
            prob = max(0, min(1, prob));
        end
        
        function prob = calculate_change_strategy_probability(obj)
            % 计算改变战略概率
            % 基于绩效表现、市场变化、竞争压力等因素
            
            % 基础概率
            base_prob = 0.05;
            
            % 绩效表现 (绩效差更可能改变战略)
            performance_factor = 1 - obj.performance.efficiency;
            
            % 竞争压力
            competition_factor = 1 - obj.performance.market_share;
            
            % 风险容忍度
            risk_factor = obj.strategy.risk_tolerance;
            
            % 综合概率
            prob = base_prob + 0.4 * performance_factor + 0.3 * competition_factor + 0.25 * risk_factor;
            
            % 限制在合理范围内
            prob = max(0, min(1, prob));
        end
        
        function execute_decisions(obj)
            % 执行决策
            if obj.decision.hire_workers && obj.workers < obj.max_workers
                obj.auto_hire_worker();
            end
            
            if obj.decision.invest_capital
                obj.invest_capital();
            end
            
            if obj.decision.expand_production
                obj.expand_production();
            end
            
            if obj.decision.change_strategy
                obj.change_strategy();
            end
        end
        
        function auto_hire_worker(obj)
            % 自动雇佣工人
            if obj.workers < obj.max_workers
                obj.workers = obj.workers + 1;
                
                % 更新生产能力
                obj.capacity = obj.size * obj.productivity * (1 + 0.1 * obj.workers / obj.max_workers);
            end
        end
        
        function invest_capital(obj)
            % 投资资本
            investment_amount = obj.capital * 0.1;  % 投资10%的资本
            
            if obj.capital >= investment_amount
                obj.capital = obj.capital - investment_amount;
                
                % 投资效果
                productivity_improvement = 0.05;  % 提高5%的生产效率
                obj.productivity = obj.productivity * (1 + productivity_improvement);
                
                % 更新生产能力
                obj.capacity = obj.size * obj.productivity * (1 + 0.1 * obj.workers / obj.max_workers);
            end
        end
        
        function expand_production(obj)
            % 扩大生产
            if obj.profit > 0
                expansion_cost = obj.size * 500;  % 扩大生产的成本
                
                if obj.capital >= expansion_cost
                    obj.capital = obj.capital - expansion_cost;
                    obj.size = obj.size * 1.1;  % 扩大10%
                    obj.max_workers = round(obj.size / 2);
                    
                    % 更新生产能力
                    obj.capacity = obj.size * obj.productivity * (1 + 0.1 * obj.workers / obj.max_workers);
                end
            end
        end
        
        function change_strategy(obj)
            % 改变战略
            % 随机调整战略参数
            obj.strategy.risk_tolerance = max(0, min(1, obj.strategy.risk_tolerance + randn * 0.1));
            obj.strategy.growth_orientation = max(0, min(1, obj.strategy.growth_orientation + randn * 0.1));
            obj.strategy.efficiency_focus = max(0, min(1, obj.strategy.efficiency_focus + randn * 0.1));
            obj.strategy.market_orientation = max(0, min(1, obj.strategy.market_orientation + randn * 0.1));
        end
        
        function can_hire = can_hire_workers(obj)
            % 检查是否可以雇佣工人
            can_hire = obj.workers < obj.max_workers && obj.status.operational;
        end
        
        function hire_worker(obj, household)
            % 雇佣特定农户
            if obj.can_hire_workers()
                obj.workers = obj.workers + 1;
                
                % 更新生产能力
                obj.capacity = obj.size * obj.productivity * (1 + 0.1 * obj.workers / obj.max_workers);
            end
        end
        
        function respond_to_policy(obj, government)
            % 对政府政策的响应
            % 更新政策影响
            obj.policy_impact = struct();
            
            % 农业企业响应种粮补贴政策
            if strcmp(obj.type, 'agricultural')
                subsidy_benefit = government.policy.grain_subsidy_rate * 0.1;  % 补贴带来的收益
                obj.profit = obj.profit * (1 + subsidy_benefit);
            end
            
            % 更新绩效指标
            obj.update_performance();
        end
        
        function update_performance(obj)
            % 更新绩效指标
            % 效率指标
            obj.performance.efficiency = obj.productivity;
            
            % 盈利能力
            if obj.capital > 0
                obj.performance.profitability = obj.profit / obj.capital;
            else
                obj.performance.profitability = 0;
            end
            
            % 增长率
            if obj.capital > 0
                obj.performance.growth_rate = obj.profit / obj.capital;
            else
                obj.performance.growth_rate = 0;
            end
            
            % 市场占有率 (简化计算)
            obj.performance.market_share = min(1, obj.size / 1000);  % 基于企业规模
        end
        
        function update_competitiveness(obj, competitors)
            % 更新竞争力
            % 基于与竞争对手的比较
            
            if isempty(competitors)
                obj.status.competitive = true;
                return;
            end
            
            % 计算相对竞争力
            my_efficiency = obj.performance.efficiency;
            my_profitability = obj.performance.profitability;
            
            competitor_efficiencies = zeros(length(competitors), 1);
            competitor_profitabilities = zeros(length(competitors), 1);
            
            for i = 1:length(competitors)
                competitor = competitors{i};
                competitor_efficiencies(i) = competitor.performance.efficiency;
                competitor_profitabilities(i) = competitor.performance.profitability;
            end
            
            % 计算竞争力排名
            efficiency_rank = sum(my_efficiency >= competitor_efficiencies) / length(competitors);
            profitability_rank = sum(my_profitability >= competitor_profitabilities) / length(competitors);
            
            overall_rank = (efficiency_rank + profitability_rank) / 2;
            
            % 更新竞争力状态
            obj.status.competitive = overall_rank > 0.5;
        end
        
        function update_revenue_and_profit(obj, market_conditions)
            % 更新收入和利润
            % 基于生产能力、市场条件、工人数量等因素
            
            % 基础收入
            base_revenue = obj.capacity * market_conditions.price_factor;
            
            % 工人效率影响
            worker_efficiency = min(1, obj.workers / obj.max_workers);
            
            % 实际收入
            obj.revenue = base_revenue * worker_efficiency;
            
            % 计算成本
            labor_cost = obj.workers * obj.wage;
            capital_cost = obj.capital * 0.05;  % 5%的资本成本
            operational_cost = obj.revenue * 0.3;  % 30%的运营成本
            
            % 化肥成本（仅农业企业）
            input_cost = 0;
            if strcmp(obj.type,'agricultural') && obj.last_input_price>0
                input_cost = obj.size * obj.application_rate * obj.last_input_price;
            end

            total_cost = labor_cost + capital_cost + operational_cost + input_cost;
            
            % 计算利润
            obj.profit = obj.revenue - total_cost;
            
            % 更新资本
            obj.capital = obj.capital + obj.profit;
            
            % 更新状态
            obj.status.profitable = obj.profit > 0;
            obj.status.growing = obj.profit > 0 && obj.performance.growth_rate > 0.05;
        end
        
        function prob = calculate_expand_probability(obj)
            % 兼容旧版本的别名函数
            prob = obj.calculate_expand_production_probability();
        end
        
        function bid_price = getBidPrice(obj, avg_rent)
            % 计算企业土地承租出价 (基于顶级农业经济学文献)
            % 参考: Alston & Pardey (1999), Deininger & Jin (2005)
            % bid_j = p̄_t + γ_j
            % γ_j = (α_grain·MRP_j – MC_landsearch) / κ_size^ψ – τ_j
            
            if ~strcmp(obj.type, 'agricultural')
                bid_price = 0;  % 非农企业不参与土地租赁
                return;
            end
            
            % 1. 计算边际收益产值/亩 MRP_j (改进版)
            mrp_j = obj.calculate_marginal_revenue_product();
            
            % 2. 确定企业类型系数 α (基于作物类型和风险偏好)
            if isa(obj, 'GrainFarmAgent')
                alpha = obj.land_params.alpha_grain;
                psi = obj.land_params.psi_grain;
                risk_premium = 0.05;  % 粮食企业风险溢价较低
            elseif isa(obj, 'CashCropFarmAgent')
                alpha = obj.land_params.alpha_cash;
                psi = obj.land_params.psi_cash;
                risk_premium = 0.15;  % 经济作物企业风险溢价较高
            else
                % 默认农业企业
                alpha = obj.land_params.alpha_grain;
                psi = obj.land_params.psi_grain;
                risk_premium = 0.10;
            end
            
            % 3. 计算规模系数 κ_size (基于Alston & Pardey 1999)
            kappa_size = obj.current_land;
            
            % 4. 计算寻找并评估地块的成本 MC_landsearch (基于企业效率)
            base_search_cost = 100;
            efficiency_factor = obj.performance.efficiency;  % 企业效率影响搜索成本
            mc_landsearch = base_search_cost / (efficiency_factor + 0.1);
            
            % 5. 计算剩余交易摩擦 τ_j (基于企业规模和类型)
            base_tau = 20;
            size_factor = min(1, obj.size / 100);  % 规模越大，交易摩擦越小
            tau_j = base_tau * (1 - 0.5 * size_factor);
            
            % 6. 计算 γ_j (考虑风险溢价)
            gamma_j = (alpha * mrp_j * (1 - risk_premium) - mc_landsearch) / (kappa_size^psi) - tau_j;
            
            % 7. 计算出价
            bid_price = avg_rent + gamma_j;
            
            % 确保出价合理
            bid_price = max(0, bid_price);
            bid_price = min(bid_price, avg_rent * 3);  % 不超过基准地租3倍
        end
        
        function mrp = calculate_marginal_revenue_product(obj)
            % 计算边际收益产值/亩 (改进版)
            % 基于Alston & Pardey (1999) 的农业规模经济理论
            % MRP_j = P_grain·yield_marginal·efficiency_factor
            
            % 边际产量 (每亩) - 考虑技术采用和规模经济
            base_marginal_yield = 800;  % 单位产量
            
            % 技术采用影响 (基于企业技术等级)
            if isfield(obj.decision, 'technology_adoption') && obj.decision.technology_adoption
                tech_level = 1;  % 简化处理，可从企业属性获取
                tech_factor = 1.15 + 0.1 * tech_level;  % 技术等级越高效果越好
            else
                tech_factor = 1.0;
            end
            
            % 规模经济影响 (基于Alston & Pardey 1999)
            scale_factor = min(1.3, 1 + 0.1 * log(obj.current_land + 1));  % 规模经济效应
            
            % 边际产量
            yield_marginal = base_marginal_yield * tech_factor * scale_factor;
            
            % 产品价格 (考虑市场波动)
            if isa(obj, 'GrainFarmAgent')
                base_price = 2.5;  % 粮食价格
                price_volatility = 0.1;
            elseif isa(obj, 'CashCropFarmAgent')
                base_price = 4.0;  % 经济作物价格
                price_volatility = 0.2;
            else
                base_price = 3.0;  % 默认价格
                price_volatility = 0.15;
            end
            
            % 风险调整后的价格
            risk_adjustment = 1 - 0.1 * price_volatility;  % 企业风险厌恶程度
            adjusted_price = base_price * risk_adjustment;
            
            % 边际收益产值
            mrp = adjusted_price * yield_marginal;
        end
        
        function desired_land = calculateLandDemand(obj, rent_price)
            % 计算土地需求面积 (改进版)
            % 基于利润最大化和规模经济考虑
            % 参考: Alston & Pardey (1999), Deininger & Jin (2005)
            
            if ~strcmp(obj.type, 'agricultural')
                desired_land = 0;
                return;
            end
            
            % 基础需求 (当前规模的20%)
            base_demand = obj.size * 0.2;
            
            % 利润考虑 (基于边际收益与租金比较)
            if rent_price > 0
                % 计算每单位土地的预期利润
                mrp = obj.calculate_marginal_revenue_product();
                expected_profit_per_unit = mrp - rent_price;
                
                % 利润弹性 (基于企业风险偏好)
                if expected_profit_per_unit > 0
                    profit_elasticity = 1.5;  % 利润弹性
                    profit_factor = min(3.0, (expected_profit_per_unit / 1000)^profit_elasticity);
                    base_demand = base_demand * profit_factor;
                else
                    % 如果预期利润为负，减少需求
                    base_demand = base_demand * 0.3;
                end
            end
            
            % 规模经济考虑 (基于Alston & Pardey 1999)
            current_scale = obj.current_land;
            optimal_scale = obj.size * 2;  % 假设最优规模是当前规模的2倍
            
            if current_scale < optimal_scale
                scale_incentive = 1 + 0.5 * (optimal_scale - current_scale) / optimal_scale;
                base_demand = base_demand * scale_incentive;
            else
                scale_incentive = 0.5;  % 超过最优规模后需求减少
                base_demand = base_demand * scale_incentive;
            end
            
            % 资本约束 (基于企业资本充足性)
            capital_adequacy = min(1, obj.capital / (obj.size * 2000));
            base_demand = base_demand * capital_adequacy;
            
            % 规模限制 (不超过当前规模的80%)
            max_demand = obj.size * 0.8;
            desired_land = min(base_demand, max_demand);
            
            % 确保非负
            desired_land = max(0, desired_land);
        end
    end
end 
