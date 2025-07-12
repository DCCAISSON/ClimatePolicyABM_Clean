% Version: 2.0-Simplified | Package: modules
% Version: 2.0-Simplified | Package: modules
classdef modules.modules
    % 演化博弈分析模块
    % 基于最新理论支撑的分析方法：
    %   • 策略分布演化分析 (Hofbauer & Sandholm 2009)
    %   • 空间聚类分析 (Galeotti & Vega-Redondo 2019)
    %   • 认知偏差影响分析 (Golub & Jackson 2012)
    %   • 创新扩散网络分析 (Young 2009)

    properties
        model               % 主模型引用
        analysis_results    % 分析结果存储
    end

    methods
        function obj = EvolutionaryGameAnalysis(model)
            obj.model = model;
            obj.analysis_results = struct();
        end

        function analyze_evolutionary_dynamics(obj)
            % 分析演化动态
            if isempty(obj.model.results.time_series)
                return;
            end

            % 1. 策略分布演化分析
            obj.analyze_strategy_distribution_evolution();
            
            % 2. 空间聚类分析
            obj.analyze_spatial_clustering();
            
            % 3. 认知偏差影响分析
            obj.analyze_cognitive_bias_effects();
            
            % 4. 创新扩散网络分析
            obj.analyze_innovation_diffusion_network();
            
            % 5. 收敛速度分析
            obj.analyze_convergence_speed();
            
            % 6. 多样性演化分析
            obj.analyze_diversity_evolution();
        end

        function analyze_strategy_distribution_evolution(obj)
            % 策略分布演化分析 (Hofbauer & Sandholm 2009)
            time_series = obj.model.results.time_series;
            households = obj.model.households;
            
            strategy_distribution = struct();
            strategy_distribution.time = [];
            strategy_distribution.plant_grain_ratio = [];
            strategy_distribution.work_off_farm_ratio = [];
            strategy_distribution.land_transfer_ratio = [];
            strategy_distribution.technology_adoption_ratio = [];
            
            for t = 1:length(time_series)
                if isfield(time_series{t}, 'household_decisions')
                    decisions = time_series{t}.household_decisions;
                    
                    strategy_distribution.time = [strategy_distribution.time; t];
                    strategy_distribution.plant_grain_ratio = [strategy_distribution.plant_grain_ratio; 
                                                             mean([decisions.plant_grain])];
                    strategy_distribution.work_off_farm_ratio = [strategy_distribution.work_off_farm_ratio; 
                                                               mean([decisions.work_off_farm])];
                    strategy_distribution.land_transfer_ratio = [strategy_distribution.land_transfer_ratio; 
                                                               mean([decisions.land_transfer])];
                    strategy_distribution.technology_adoption_ratio = [strategy_distribution.technology_adoption_ratio; 
                                                                     mean([decisions.technology_adoption])];
                end
            end
            
            obj.analysis_results.strategy_distribution = strategy_distribution;
        end

        function analyze_spatial_clustering(obj)
            % 空间聚类分析 (Galeotti & Vega-Redondo 2019)
            households = obj.model.households;
            n = length(households);
            
            % 计算空间位置
            locations = zeros(n, 2);
            strategies = zeros(n, 4);
            
            for i = 1:n
                locations(i, :) = households{i}.location;
                strategies(i, 1) = households{i}.decision.plant_grain;
                strategies(i, 2) = households{i}.decision.work_off_farm;
                strategies(i, 3) = households{i}.decision.land_transfer;
                strategies(i, 4) = households{i}.decision.technology_adoption;
            end
            
            % 计算空间自相关
            spatial_autocorr = obj.calculate_spatial_autocorrelation(locations, strategies);
            
            % 计算策略聚类指数
            clustering_index = obj.calculate_strategy_clustering(locations, strategies);
            
            obj.analysis_results.spatial_clustering = struct();
            obj.analysis_results.spatial_clustering.spatial_autocorr = spatial_autocorr;
            obj.analysis_results.spatial_clustering.clustering_index = clustering_index;
        end

        function analyze_cognitive_bias_effects(obj)
            % 认知偏差影响分析 (Golub & Jackson 2012)
            households = obj.model.households;
            n = length(households);
            
            bias_effects = struct();
            bias_effects.confirmation_bias_impact = zeros(n, 1);
            bias_effects.anchor_effect_impact = zeros(n, 1);
            bias_effects.herd_effect_impact = zeros(n, 1);
            
            for i = 1:n
                % 计算确认偏差影响
                bias_effects.confirmation_bias_impact(i) = obj.calculate_confirmation_bias_impact(households{i});
                
                % 计算锚定效应影响
                bias_effects.anchor_effect_impact(i) = obj.calculate_anchor_effect_impact(households{i});
                
                % 计算从众效应影响
                bias_effects.herd_effect_impact(i) = obj.calculate_herd_effect_impact(households{i});
            end
            
            obj.analysis_results.cognitive_bias_effects = bias_effects;
        end

        function analyze_innovation_diffusion_network(obj)
            % 创新扩散网络分析 (Young 2009)
            households = obj.model.households;
            n = length(households);
            
            % 构建创新扩散网络
            innovation_network = zeros(n, n);
            
            for i = 1:n
                for j = 1:n
                    if i ~= j
                        % 计算创新扩散概率
                        diffusion_prob = obj.calculate_innovation_diffusion_probability(households{i}, households{j});
                        innovation_network(i, j) = diffusion_prob;
                    end
                end
            end
            
            % 计算网络特征
            network_metrics = obj.calculate_network_metrics(innovation_network);
            
            obj.analysis_results.innovation_diffusion_network = struct();
            obj.analysis_results.innovation_diffusion_network.network_matrix = innovation_network;
            obj.analysis_results.innovation_diffusion_network.network_metrics = network_metrics;
        end

        function analyze_convergence_speed(obj)
            % 收敛速度分析
            if isfield(obj.analysis_results, 'strategy_distribution')
                strategy_dist = obj.analysis_results.strategy_distribution;
                
                % 计算策略变化率
                convergence_speed = struct();
                convergence_speed.plant_grain_convergence = obj.calculate_convergence_speed(strategy_dist.plant_grain_ratio);
                convergence_speed.work_off_farm_convergence = obj.calculate_convergence_speed(strategy_dist.work_off_farm_ratio);
                convergence_speed.land_transfer_convergence = obj.calculate_convergence_speed(strategy_dist.land_transfer_ratio);
                convergence_speed.technology_adoption_convergence = obj.calculate_convergence_speed(strategy_dist.technology_adoption_ratio);
                
                obj.analysis_results.convergence_speed = convergence_speed;
            end
        end

        function analyze_diversity_evolution(obj)
            % 多样性演化分析
            households = obj.model.households;
            n = length(households);
            
            % 计算策略多样性
            diversity_metrics = struct();
            diversity_metrics.strategy_diversity = obj.calculate_strategy_diversity(households);
            diversity_metrics.income_diversity = obj.calculate_income_diversity(households);
            diversity_metrics.spatial_diversity = obj.calculate_spatial_diversity(households);
            
            obj.analysis_results.diversity_evolution = diversity_metrics;
        end

        % 辅助计算函数
        function spatial_autocorr = calculate_spatial_autocorrelation(obj, locations, strategies)
            % 计算空间自相关
            n = size(locations, 1);
            spatial_autocorr = zeros(size(strategies, 2), 1);
            
            for s = 1:size(strategies, 2)
                strategy = strategies(:, s);
                
                % Moran's I 统计量
                mean_strategy = mean(strategy);
                numerator = 0;
                denominator = 0;
                
                for i = 1:n
                    for j = 1:n
                        if i ~= j
                            distance = norm(locations(i, :) - locations(j, :));
                            weight = 1 / (1 + distance);
                            
                            numerator = numerator + weight * (strategy(i) - mean_strategy) * (strategy(j) - mean_strategy);
                            denominator = denominator + weight;
                        end
                    end
                end
                
                if denominator > 0
                    spatial_autocorr(s) = numerator / denominator;
                end
            end
        end

        function clustering_index = calculate_strategy_clustering(obj, locations, strategies)
            % 计算策略聚类指数
            n = size(locations, 1);
            clustering_index = zeros(size(strategies, 2), 1);
            
            for s = 1:size(strategies, 2)
                strategy = strategies(:, s);
                
                % 计算局部聚类系数
                local_clustering = zeros(n, 1);
                
                for i = 1:n
                    neighbors = [];
                    for j = 1:n
                        if i ~= j
                            distance = norm(locations(i, :) - locations(j, :));
                            if distance <= 5  % 邻居阈值
                                neighbors = [neighbors; j];
                            end
                        end
                    end
                    
                    if length(neighbors) >= 2
                        % 计算邻居间的策略相似性
                        neighbor_strategies = strategy(neighbors);
                        clustering_coeff = mean(neighbor_strategies);
                        local_clustering(i) = clustering_coeff;
                    end
                end
                
                clustering_index(s) = mean(local_clustering);
            end
        end

        function impact = calculate_confirmation_bias_impact(obj, agent)
            % 计算确认偏差影响
            if isfield(agent, 'historical_strategies') && length(agent.historical_strategies) > 0
                recent_strategies = agent.historical_strategies(max(1, end-5):end);
                current_strategy = agent.decision.plant_grain;
                
                % 计算策略一致性
                strategy_consistency = mean(recent_strategies == current_strategy);
                impact = strategy_consistency;
            else
                impact = 0.5;
            end
        end

        function impact = calculate_anchor_effect_impact(obj, agent)
            % 计算锚定效应影响
            if isfield(agent, 'historical_payoffs') && length(agent.historical_payoffs) > 0
                recent_payoffs = agent.historical_payoffs(max(1, end-5):end);
                anchor_payoff = mean(recent_payoffs);
                current_payoff = agent.income.total;
                
                % 锚定效应强度
                impact = abs(current_payoff - anchor_payoff) / (abs(anchor_payoff) + 1e-6);
            else
                impact = 0.5;
            end
        end

        function impact = calculate_herd_effect_impact(obj, agent)
            % 计算从众效应影响
            households = obj.model.households;
            n = length(households);
            
            % 计算邻居策略分布
            neighbor_strategies = zeros(n, 1);
            for i = 1:n
                if households{i}.id ~= agent.id
                    distance = norm(agent.location - households{i}.location);
                    if distance <= 5
                        neighbor_strategies(i) = households{i}.decision.plant_grain;
                    end
                end
            end
            
            % 从众效应 = 邻居策略的一致性
            neighbor_strategies = neighbor_strategies(neighbor_strategies > 0);
            if ~isempty(neighbor_strategies)
                impact = mean(neighbor_strategies);
            else
                impact = 0.5;
            end
        end

        function diffusion_prob = calculate_innovation_diffusion_probability(obj, source, target)
            % 计算创新扩散概率
            distance = norm(source.location - target.location);
            
            % 距离衰减
            distance_factor = exp(-0.1 * distance);
            
            % 策略相似性
            strategy_similarity = obj.calculate_strategy_similarity(source, target);
            
            % 收益差异
            payoff_difference = (source.income.total - target.income.total) / (abs(target.income.total) + 1e-6);
            
            % 综合扩散概率
            diffusion_prob = distance_factor * strategy_similarity * max(0, payoff_difference);
        end

        function network_metrics = calculate_network_metrics(obj, network_matrix)
            % 计算网络特征
            network_metrics = struct();
            
            % 平均度
            network_metrics.average_degree = mean(sum(network_matrix > 0, 2));
            
            % 网络密度
            n = size(network_matrix, 1);
            network_metrics.density = sum(sum(network_matrix > 0)) / (n * (n - 1));
            
            % 聚类系数
            network_metrics.clustering_coefficient = obj.calculate_network_clustering(network_matrix);
            
            % 中心性
            network_metrics.centrality = obj.calculate_network_centrality(network_matrix);
        end

        function convergence_speed = calculate_convergence_speed(obj, strategy_ratio)
            % 计算收敛速度
            if length(strategy_ratio) < 2
                convergence_speed = 0;
                return;
            end
            
            % 计算策略变化率
            changes = abs(diff(strategy_ratio));
            convergence_speed = mean(changes);
        end

        function diversity = calculate_strategy_diversity(obj, households)
            % 计算策略多样性
            n = length(households);
            strategies = zeros(n, 4);
            
            for i = 1:n
                strategies(i, 1) = households{i}.decision.plant_grain;
                strategies(i, 2) = households{i}.decision.work_off_farm;
                strategies(i, 3) = households{i}.decision.land_transfer;
                strategies(i, 4) = households{i}.decision.technology_adoption;
            end
            
            % 计算策略组合的多样性
            unique_strategies = unique(strategies, 'rows');
            diversity = size(unique_strategies, 1) / n;
        end

        function diversity = calculate_income_diversity(obj, households)
            % 计算收入多样性
            incomes = zeros(length(households), 1);
            for i = 1:length(households)
                incomes(i) = households{i}.income.total;
            end
            
            % 收入基尼系数
            diversity = obj.calculate_gini_coefficient(incomes);
        end

        function diversity = calculate_spatial_diversity(obj, households)
            % 计算空间多样性
            locations = zeros(length(households), 2);
            for i = 1:length(households)
                locations(i, :) = households{i}.location;
            end
            
            % 空间分布的标准差
            diversity = mean(std(locations));
        end

        function gini = calculate_gini_coefficient(obj, values)
            % 计算基尼系数
            n = length(values);
            if n == 0
                gini = 0;
                return;
            end
            
            values = sort(values);
            cumsum_values = cumsum(values);
            
            gini = (n + 1 - 2 * sum((n + 1 - (1:n)) .* values) / sum(values)) / n;
        end

        function similarity = calculate_strategy_similarity(obj, agent1, agent2)
            % 计算策略相似度
            strategies1 = [agent1.decision.plant_grain, agent1.decision.work_off_farm, ...
                          agent1.decision.land_transfer, agent1.decision.technology_adoption];
            strategies2 = [agent2.decision.plant_grain, agent2.decision.work_off_farm, ...
                          agent2.decision.land_transfer, agent2.decision.technology_adoption];
            
            similarity = 1 - mean(abs(strategies1 - strategies2));
        end

        function clustering_coeff = calculate_network_clustering(obj, network_matrix)
            % 计算网络聚类系数
            n = size(network_matrix, 1);
            clustering_coeff = 0;
            
            for i = 1:n
                neighbors = find(network_matrix(i, :) > 0);
                if length(neighbors) >= 2
                    triangles = 0;
                    for j = 1:length(neighbors)
                        for k = j+1:length(neighbors)
                            if network_matrix(neighbors(j), neighbors(k)) > 0
                                triangles = triangles + 1;
                            end
                        end
                    end
                    clustering_coeff = clustering_coeff + triangles / (length(neighbors) * (length(neighbors) - 1) / 2);
                end
            end
            
            clustering_coeff = clustering_coeff / n;
        end

        function centrality = calculate_network_centrality(obj, network_matrix)
            % 计算网络中心性
            centrality = sum(network_matrix, 2);
        end

        function plot_evolutionary_analysis(obj)
            % 绘制演化博弈分析结果
            if isfield(obj.analysis_results, 'strategy_distribution')
                figure('Name', 'Evolutionary Game Analysis', 'Position', [100, 100, 1200, 800]);
                
                % 策略分布演化
                subplot(2, 3, 1);
                strategy_dist = obj.analysis_results.strategy_distribution;
                plot(strategy_dist.time, strategy_dist.plant_grain_ratio, 'b-', 'LineWidth', 2);
                hold on;
                plot(strategy_dist.time, strategy_dist.work_off_farm_ratio, 'r-', 'LineWidth', 2);
                plot(strategy_dist.time, strategy_dist.land_transfer_ratio, 'g-', 'LineWidth', 2);
                plot(strategy_dist.time, strategy_dist.technology_adoption_ratio, 'm-', 'LineWidth', 2);
                xlabel('Time');
                ylabel('Strategy Ratio');
                title('Strategy Distribution Evolution');
                legend('Plant Grain', 'Work Off-farm', 'Land Transfer', 'Technology Adoption');
                grid on;
                
                % 空间聚类
                if isfield(obj.analysis_results, 'spatial_clustering')
                    subplot(2, 3, 2);
                    spatial_clustering = obj.analysis_results.spatial_clustering;
                    bar(spatial_clustering.spatial_autocorr);
                    xlabel('Strategy Type');
                    ylabel('Spatial Autocorrelation');
                    title('Spatial Clustering Analysis');
                    set(gca, 'XTickLabel', {'Plant Grain', 'Work Off-farm', 'Land Transfer', 'Technology'});
                    grid on;
                end
                
                % 认知偏差影响
                if isfield(obj.analysis_results, 'cognitive_bias_effects')
                    subplot(2, 3, 3);
                    bias_effects = obj.analysis_results.cognitive_bias_effects;
                    bias_data = [mean(bias_effects.confirmation_bias_impact), ...
                                mean(bias_effects.anchor_effect_impact), ...
                                mean(bias_effects.herd_effect_impact)];
                    bar(bias_data);
                    xlabel('Cognitive Bias Type');
                    ylabel('Average Impact');
                    title('Cognitive Bias Effects');
                    set(gca, 'XTickLabel', {'Confirmation', 'Anchor', 'Herd'});
                    grid on;
                end
                
                % 收敛速度
                if isfield(obj.analysis_results, 'convergence_speed')
                    subplot(2, 3, 4);
                    convergence_speed = obj.analysis_results.convergence_speed;
                    convergence_data = [convergence_speed.plant_grain_convergence, ...
                                      convergence_speed.work_off_farm_convergence, ...
                                      convergence_speed.land_transfer_convergence, ...
                                      convergence_speed.technology_adoption_convergence];
                    bar(convergence_data);
                    xlabel('Strategy Type');
                    ylabel('Convergence Speed');
                    title('Convergence Speed Analysis');
                    set(gca, 'XTickLabel', {'Plant Grain', 'Work Off-farm', 'Land Transfer', 'Technology'});
                    grid on;
                end
                
                % 多样性演化
                if isfield(obj.analysis_results, 'diversity_evolution')
                    subplot(2, 3, 5);
                    diversity_evolution = obj.analysis_results.diversity_evolution;
                    diversity_data = [diversity_evolution.strategy_diversity, ...
                                    diversity_evolution.income_diversity, ...
                                    diversity_evolution.spatial_diversity];
                    bar(diversity_data);
                    xlabel('Diversity Type');
                    ylabel('Diversity Index');
                    title('Diversity Evolution');
                    set(gca, 'XTickLabel', {'Strategy', 'Income', 'Spatial'});
                    grid on;
                end
                
                % 网络特征
                if isfield(obj.analysis_results, 'innovation_diffusion_network')
                    subplot(2, 3, 6);
                    network_metrics = obj.analysis_results.innovation_diffusion_network.network_metrics;
                    network_data = [network_metrics.average_degree, ...
                                  network_metrics.density, ...
                                  network_metrics.clustering_coefficient];
                    bar(network_data);
                    xlabel('Network Metric');
                    ylabel('Value');
                    title('Innovation Diffusion Network');
                    set(gca, 'XTickLabel', {'Avg Degree', 'Density', 'Clustering'});
                    grid on;
                end
                
                sgtitle('Advanced Evolutionary Game Analysis Results');
            end
        end

        function save_analysis_results(obj, filename)
            % 保存分析结果
            if isfield(obj, 'analysis_results')
                save(filename, 'obj.analysis_results');
                fprintf('Evolutionary game analysis results saved to %s\n', filename);
            end
        end
    end
end 
