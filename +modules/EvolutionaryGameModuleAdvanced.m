% Version: 2.0-Simplified | Package: modules
% Version: 2.0-Simplified | Package: modules
classdef modules.modules
    % 基于最新理论支撑的演化博弈模块：
    %   • 基于空间距离的邻居选择 (Galeotti & Vega-Redondo 2019)
    %   • 认知偏差下的社会学习 (Bala & Goyal 2000, Golub & Jackson 2012)
    %   • 适应性突变机制 (Sandholm 2010)
    %   • 创新扩散理论 (Young 2009, Rogers 2003)
    %   • 多群体演化博弈 (Hofbauer & Sandholm 2009)

    properties
        model               % 主模型引用
        neighbor_count  = 3 % 每个主体模仿的邻居数量
        imitation_strength = 0.5  % 收益差异 → 模仿概率系数 (0~1)
        mutation_rate       = 0.02 % 基础突变概率
        
        % 空间交互参数
        max_spatial_distance = 10  % 最大空间距离
        spatial_decay_factor = 0.1 % 空间距离衰减因子
        
        % 认知偏差参数
        confirmation_bias = 0.3    % 确认偏差强度
        anchor_effect = 0.2        % 锚定效应强度
        herd_effect = 0.3          % 从众效应强度
        
        % 适应性突变参数
        environmental_pressure_threshold = 0.5  % 环境压力阈值
        diversity_threshold = 0.3              % 多样性阈值
        
        % 创新扩散参数
        innovation_susceptibility_mean = 0.5   % 创新接受度均值
        innovation_susceptibility_std = 0.2    % 创新接受度标准差
    end

    methods
        function obj = EvolutionaryGameModuleAdvanced(model)
            obj.model = model;
        end

        function step(obj)
            % 仅当已有上一期数据时运行
            if isempty(obj.model.results.time_series)
                return;
            end

            % 多群体演化博弈
            obj.update_household_evolution();
            obj.update_enterprise_evolution();
            obj.update_government_evolution();
            
            % 群体间交互效应
            obj.update_cross_population_effects();
        end
        
        function update_household_evolution(obj)
            % 农户群体演化博弈
            households = obj.model.households;
            n = numel(households);

            % 收集当前收益
            payoffs = zeros(n,1);
            for i = 1:n
                payoffs(i) = households{i}.income.total;
            end

            % 计算环境压力
            environmental_pressure = obj.calculate_environmental_pressure(households);
            
            % 逐个农户进行演化决策
            for i = 1:n
                % 1) 基于空间距离的邻居选择
                neighbors = obj.get_spatial_neighbors(households{i}, households);
                
                if ~isempty(neighbors)
                    % 2) 认知偏差下的社会学习
                    obj.cognitive_biased_learning(households{i}, neighbors, payoffs);
                    
                    % 3) 适应性突变
                    obj.adaptive_mutation(households{i}, environmental_pressure);
                    
                    % 4) 创新扩散
                    obj.innovation_diffusion(households{i}, neighbors);
                end
            end
        end
        
        function update_enterprise_evolution(obj)
            % 企业群体演化博弈
            enterprises = obj.model.enterprises;
            n = numel(enterprises);
            
            if n == 0
                return;
            end
            
            % 收集企业收益
            payoffs = zeros(n,1);
            for i = 1:n
                payoffs(i) = enterprises{i}.profit;
            end
            
            % 企业间策略演化
            for i = 1:n
                neighbors = obj.get_spatial_neighbors(enterprises{i}, enterprises);
                
                if ~isempty(neighbors)
                    % 企业策略学习
                    obj.enterprise_strategy_learning(enterprises{i}, neighbors, payoffs);
                    
                    % 企业创新扩散
                    obj.enterprise_innovation_diffusion(enterprises{i}, neighbors);
                end
            end
        end
        
        function update_government_evolution(obj)
            % 政府策略演化
            government = obj.model.government;
            
            % 评估政策效果
            policy_effectiveness = obj.evaluate_policy_effectiveness(government);
            
            % 政府策略调整
            obj.government_strategy_adjustment(government, policy_effectiveness);
        end
        
        function neighbors = get_spatial_neighbors(obj, agent, all_agents)
            % 基于空间距离的邻居选择 (Galeotti & Vega-Redondo 2019)
            neighbors = [];
            distances = [];
            
            for i = 1:length(all_agents)
                if all_agents{i}.id ~= agent.id
                    % 计算空间距离
                    distance = norm(agent.location - all_agents{i}.location);
                    
                    % 距离衰减效应
                    if distance <= obj.max_spatial_distance
                        weight = exp(-obj.spatial_decay_factor * distance);
                        neighbors = [neighbors; all_agents{i}];
                        distances = [distances; weight];
                    end
                end
            end
            
            % 按距离权重排序，选择最近的邻居
            if ~isempty(neighbors)
                [~, sorted_idx] = sort(distances, 'descend');
                neighbors = neighbors(sorted_idx(1:min(obj.neighbor_count, length(sorted_idx))));
            end
        end
        
        function cognitive_biased_learning(obj, agent, neighbors, payoffs)
            % 认知偏差下的社会学习 (Bala & Goyal 2000, Golub & Jackson 2012)
            
            % 1) 确认偏差：偏好与自身策略相似的邻居
            similar_neighbors = obj.filter_similar_strategies(agent, neighbors);
            confirmation_weight = obj.confirmation_bias;
            
            % 2) 锚定效应：基于历史收益调整学习强度
            anchor_effect = obj.calculate_anchor_effect(agent);
            
            % 3) 从众效应：考虑多数邻居的策略
            herd_effect = obj.calculate_herd_effect(neighbors);
            
            % 4) 计算综合学习概率
            if ~isempty(neighbors)
                best_neighbor = obj.find_best_neighbor(agent, neighbors, payoffs);
                
                if ~isempty(best_neighbor)
                    payoff_difference = best_neighbor.payoff - agent.income.total;
                    
                    if payoff_difference > 0
                        % 基础模仿概率
                        base_imitation_prob = obj.imitation_strength * payoff_difference / (abs(agent.income.total) + 1e-6);
                        
                        % 认知偏差调整
                        cognitive_adjustment = (similar_neighbors.weight * confirmation_weight + 
                                             anchor_effect * obj.anchor_effect + 
                                             herd_effect * obj.herd_effect);
                        
                        % 综合模仿概率
                        imitation_prob = min(1, base_imitation_prob * cognitive_adjustment);
                        
                        % 执行模仿
                        if rand < imitation_prob
                            obj.copy_strategy(agent, best_neighbor);
                        end
                    end
                end
            end
        end
        
        function adaptive_mutation(obj, agent, environmental_pressure)
            % 适应性突变机制 (Sandholm 2010)
            
            % 计算适应性突变概率
            base_mutation_rate = obj.mutation_rate;
            pressure_factor = obj.calculate_pressure_factor(environmental_pressure);
            diversity_factor = obj.calculate_diversity_factor(agent);
            
            adaptive_mutation_rate = base_mutation_rate * pressure_factor * diversity_factor;
            
            % 执行适应性突变
            if rand < adaptive_mutation_rate
                new_strategy = obj.generate_adaptive_mutation(agent, environmental_pressure);
                obj.apply_mutation(agent, new_strategy);
            end
        end
        
        function innovation_diffusion(obj, agent, neighbors)
            % 创新扩散机制 (Young 2009, Rogers 2003)
            
            % 计算创新接受度
            if ~isfield(agent, 'innovation_susceptibility')
                agent.innovation_susceptibility = normrnd(obj.innovation_susceptibility_mean, ...
                                                        obj.innovation_susceptibility_std);
            end
            
            % 创新扩散概率
            innovation_prob = obj.calculate_innovation_probability(agent, neighbors);
            adoption_threshold = obj.calculate_adoption_threshold(agent);
            
            % 创新扩散决策
            if rand < innovation_prob && agent.innovation_susceptibility > adoption_threshold
                % 从邻居中选择创新策略
                new_innovation = obj.select_innovation_from_neighbors(agent, neighbors);
                
                if ~isempty(new_innovation)
                    % 评估创新采用
                    if obj.evaluate_innovation_adoption(agent, new_innovation)
                        obj.apply_innovation(agent, new_innovation);
                    end
                end
            end
        end
        
        function pressure_factor = calculate_pressure_factor(obj, environmental_pressure)
            % 计算环境压力因子
            if environmental_pressure > obj.environmental_pressure_threshold
                pressure_factor = 1.5;  % 高压力环境增加突变
            elseif environmental_pressure < 0.2
                pressure_factor = 0.5;  % 低压力环境减少突变
            else
                pressure_factor = 1.0;  % 中等压力环境
            end
        end
        
        function diversity_factor = calculate_diversity_factor(obj, agent)
            % 计算多样性因子
            % 基于智能体策略的独特性
            strategy_uniqueness = obj.calculate_strategy_uniqueness(agent);
            diversity_factor = 1.0 + strategy_uniqueness;
        end
        
        function new_strategy = generate_adaptive_mutation(obj, agent, environmental_pressure)
            % 生成适应性突变策略
            if environmental_pressure > obj.environmental_pressure_threshold
                % 高压力环境：探索性突变
                new_strategy = obj.explore_new_strategies(agent);
            elseif environmental_pressure < 0.2
                % 低压力环境：保守性突变
                new_strategy = obj.conservative_mutation(agent);
            else
                % 中等压力：平衡性突变
                new_strategy = obj.balanced_mutation(agent);
            end
        end
        
        function copy_strategy(obj, target, source)
            % 复制策略 (改进版)
            % 不仅复制决策，还复制策略强度
            target.decision.plant_grain = source.decision.plant_grain;
            target.decision.work_off_farm = source.decision.work_off_farm;
            target.decision.land_transfer = source.decision.land_transfer;
            target.decision.technology_adoption = source.decision.technology_adoption;
            
            % 复制策略强度
            if isfield(source, 'strategy_strength')
                target.strategy_strength = source.strategy_strength;
            end
        end
        
        function mutate_strategy(obj, agent)
            % 改进的突变机制
            mutation_type = randi(4);  % 4种突变类型
            
            switch mutation_type
                case 1
                    % 种植决策突变
                    agent.decision.plant_grain = ~agent.decision.plant_grain;
                case 2
                    % 务工决策突变
                    agent.decision.work_off_farm = ~agent.decision.work_off_farm;
                case 3
                    % 土地流转决策突变
                    agent.decision.land_transfer = ~agent.decision.land_transfer;
                case 4
                    % 技术采用决策突变
                    agent.decision.technology_adoption = ~agent.decision.technology_adoption;
            end
        end
        
        % 辅助函数
        function similar_neighbors = filter_similar_strategies(obj, agent, neighbors)
            % 过滤相似策略的邻居
            similar_neighbors = [];
            for i = 1:length(neighbors)
                similarity = obj.calculate_strategy_similarity(agent, neighbors{i});
                if similarity > 0.7  % 相似度阈值
                    similar_neighbors = [similar_neighbors; neighbors{i}];
                end
            end
        end
        
        function anchor_effect = calculate_anchor_effect(obj, agent)
            % 计算锚定效应
            if isfield(agent, 'historical_payoffs') && length(agent.historical_payoffs) > 0
                recent_payoffs = agent.historical_payoffs(max(1, end-5):end);
                anchor_effect = mean(recent_payoffs) / (agent.income.total + 1e-6);
            else
                anchor_effect = 1.0;
            end
        end
        
        function herd_effect = calculate_herd_effect(obj, neighbors)
            % 计算从众效应
            if isempty(neighbors)
                herd_effect = 0.5;
                return;
            end
            
            % 计算邻居策略的分布
            strategies = zeros(length(neighbors), 1);
            for i = 1:length(neighbors)
                strategies(i) = neighbors{i}.decision.plant_grain;
            end
            
            % 从众效应 = 多数策略的比例
            herd_effect = mean(strategies);
        end
        
        function best_neighbor = find_best_neighbor(obj, agent, neighbors, payoffs)
            % 找到最佳邻居
            if isempty(neighbors)
                best_neighbor = [];
                return;
            end
            
            [~, best_idx] = max(payoffs);
            best_neighbor = neighbors{best_idx};
        end
        
        function environmental_pressure = calculate_environmental_pressure(obj, agents)
            % 计算环境压力
            if isempty(agents)
                environmental_pressure = 0.5;
                return;
            end
            
            % 基于收益变异系数计算环境压力
            payoffs = zeros(length(agents), 1);
            for i = 1:length(agents)
                payoffs(i) = agents{i}.income.total;
            end
            
            mean_payoff = mean(payoffs);
            std_payoff = std(payoffs);
            
            if mean_payoff > 0
                environmental_pressure = std_payoff / mean_payoff;
            else
                environmental_pressure = 0.5;
            end
        end
        
        function update_cross_population_effects(obj)
            % 群体间交互效应
            % 农户策略对企业的影响
            % 企业策略对农户的影响
            % 政府政策对整体的影响
        end
        
        function update_enterprise_evolution(obj)
            % 企业演化博弈
        end
        
        function update_government_evolution(obj)
            % 政府演化博弈
        end
        
        function enterprise_strategy_learning(obj, enterprise, neighbors, payoffs)
            % 企业策略学习
        end
        
        function enterprise_innovation_diffusion(obj, enterprise, neighbors)
            % 企业创新扩散
        end
        
        function policy_effectiveness = evaluate_policy_effectiveness(obj, government)
            % 评估政策效果
            policy_effectiveness = 0.5;  % 简化处理
        end
        
        function government_strategy_adjustment(obj, government, policy_effectiveness)
            % 政府策略调整
        end
        
        function innovation_prob = calculate_innovation_probability(obj, agent, neighbors)
            % 计算创新概率
            innovation_prob = 0.1;  % 简化处理
        end
        
        function adoption_threshold = calculate_adoption_threshold(obj, agent)
            % 计算采用阈值
            adoption_threshold = 0.3;  % 简化处理
        end
        
        function new_innovation = select_innovation_from_neighbors(obj, agent, neighbors)
            % 从邻居中选择创新
            new_innovation = [];  % 简化处理
        end
        
        function success = evaluate_innovation_adoption(obj, agent, innovation)
            % 评估创新采用
            success = rand < 0.5;  % 简化处理
        end
        
        function apply_innovation(obj, agent, innovation)
            % 应用创新
        end
        
        function strategy_uniqueness = calculate_strategy_uniqueness(obj, agent)
            % 计算策略独特性
            strategy_uniqueness = 0.5;  % 简化处理
        end
        
        function new_strategy = explore_new_strategies(obj, agent)
            % 探索新策略
            new_strategy = agent.decision;  % 简化处理
        end
        
        function new_strategy = conservative_mutation(obj, agent)
            % 保守性突变
            new_strategy = agent.decision;  % 简化处理
        end
        
        function new_strategy = balanced_mutation(obj, agent)
            % 平衡性突变
            new_strategy = agent.decision;  % 简化处理
        end
        
        function apply_mutation(obj, agent, new_strategy)
            % 应用突变
            agent.decision = new_strategy;
        end
        
        function similarity = calculate_strategy_similarity(obj, agent1, agent2)
            % 计算策略相似度
            similarity = 0.5;  % 简化处理
        end
    end
end 
