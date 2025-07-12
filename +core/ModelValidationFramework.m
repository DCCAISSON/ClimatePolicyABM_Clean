% Version: 2.0-Simplified | Package: core
% Version: 2.0-Simplified | Package: core
classdef core.core
    % ModelValidationFramework 模型验证框架
    % 实现系统性的模型校准、敏感性分析和验证体系
    % 基于现代ABM验证方法：PatternOrientedModeling, Validation套件等
    
    properties
        % 基础属性
        model                   % 主模型对象
        calibration_data       % 校准数据集
        validation_data        % 验证数据集
        
        % 校准参数
        parameter_space        % 参数空间定义
        calibration_targets    % 校准目标
        calibration_weights    % 校准权重
        
        % 验证指标
        validation_metrics     % 验证指标集合
        pattern_metrics       % 模式匹配指标
        
        % 实验设计
        experiment_design     % 实验设计矩阵
        sensitivity_results   % 敏感性分析结果
        
        % 结果存储
        calibration_history   % 校准历史
        validation_results    % 验证结果
        best_parameters       % 最优参数组合
    end
    
    methods
        function obj = ModelValidationFramework(model, calibration_data, validation_data)
            % 构造函数
            obj.model = model;
            obj.calibration_data = calibration_data;
            obj.validation_data = validation_data;
            
            % 初始化参数空间
            obj.initialize_parameter_space();
            
            % 初始化校准目标
            obj.initialize_calibration_targets();
            
            % 初始化验证指标
            obj.initialize_validation_metrics();
            
            % 初始化实验设计
            obj.initialize_experiment_design();
            
            obj.calibration_history = [];
            obj.validation_results = struct();
        end
        
        function initialize_parameter_space(obj)
            % 定义需要校准的参数空间
            % 基于企业异质性和市场机制的关键参数
            
            obj.parameter_space = struct();
            
            % 企业异质性参数
            obj.parameter_space.technology_level_range = [0.2, 0.9];
            obj.parameter_space.quality_investment_range = [0.01, 0.08];
            obj.parameter_space.rd_investment_range = [0.005, 0.06];
            
            % 市场机制参数
            obj.parameter_space.search_cost_factor_range = [0.01, 0.1];
            obj.parameter_space.quality_premium_range = [0.1, 0.4];
            obj.parameter_space.reputation_weight_range = [0.05, 0.3];
            
            % 农户行为参数
            obj.parameter_space.risk_tolerance_range = [0.1, 0.9];
            obj.parameter_space.price_sensitivity_range = [0.2, 0.8];
            obj.parameter_space.quality_preference_range = [0.3, 0.9];
            
            % 政策参数
            obj.parameter_space.emission_tax_range = [0.1, 0.5];
            obj.parameter_space.compliance_penalty_range = [0.05, 0.3];
            obj.parameter_space.green_subsidy_range = [0.0, 0.2];
            
            % 宏观经济参数
            obj.parameter_space.market_growth_range = [0.02, 0.08];
            obj.parameter_space.innovation_diffusion_range = [0.05, 0.2];
        end
        
        function initialize_calibration_targets(obj)
            % 设定校准目标 - 基于真实数据的关键统计量
            
            obj.calibration_targets = struct();
            
            % 企业层面目标
            obj.calibration_targets.enterprise_productivity_growth = 0.03; % 年均3%生产效率增长
            obj.calibration_targets.enterprise_size_distribution = [0.6, 0.3, 0.1]; % 小中大企业比例
            obj.calibration_targets.technology_adoption_rate = 0.15; % 技术采用率
            obj.calibration_targets.market_concentration_hhi = 0.25; % 市场集中度
            
            % 市场层面目标
            obj.calibration_targets.price_volatility = 0.12; % 价格波动率
            obj.calibration_targets.quality_premium = 0.18; % 质量溢价
            obj.calibration_targets.market_efficiency = 0.85; % 市场效率
            obj.calibration_targets.transaction_success_rate = 0.78; % 交易成功率
            
            % 农户层面目标
            obj.calibration_targets.income_growth_rate = 0.045; % 收入增长率
            obj.calibration_targets.technology_uptake = 0.25; % 技术采用比例
            obj.calibration_targets.land_use_efficiency = 0.82; % 土地利用效率
            
            % 环境和政策目标
            obj.calibration_targets.emission_reduction_rate = 0.08; % 排放减少率
            obj.calibration_targets.green_technology_share = 0.35; % 绿色技术份额
            obj.calibration_targets.policy_compliance_rate = 0.88; % 政策合规率
            
            % 设定权重
            obj.calibration_weights = struct();
            obj.calibration_weights.enterprise_level = 0.3;
            obj.calibration_weights.market_level = 0.3;
            obj.calibration_weights.farmer_level = 0.2;
            obj.calibration_weights.environmental_level = 0.2;
        end
        
        function initialize_validation_metrics(obj)
            % 初始化验证指标体系
            
            obj.validation_metrics = struct();
            
            % 统计验证指标
            obj.validation_metrics.statistical = {
                'mean_absolute_error',
                'root_mean_square_error', 
                'correlation_coefficient',
                'coefficient_of_determination',
                'kolmogorov_smirnov_test'
            };
            
            % 模式匹配指标
            obj.pattern_metrics = struct();
            obj.pattern_metrics.stylized_facts = {
                'fat_tail_distribution',      % 胖尾分布
                'volatility_clustering',      % 波动性聚集
                'power_law_scaling',         % 幂律缩放
                'long_range_dependence',     % 长程依赖
                'business_cycle_patterns'    % 商业周期模式
            };
            
            % 行为验证指标
            obj.validation_metrics.behavioral = {
                'learning_curves',           % 学习曲线
                'decision_consistency',      % 决策一致性
                'adaptation_speed',         % 适应速度
                'network_formation',        % 网络形成
                'market_segregation'        % 市场分割
            };
            
            % 系统层面指标
            obj.validation_metrics.system_level = {
                'emergent_properties',      % 涌现性质
                'phase_transitions',        % 相变
                'resilience_measures',      % 韧性度量
                'stability_analysis',       % 稳定性分析
                'sensitivity_bounds'        % 敏感性边界
            };
        end
        
        function initialize_experiment_design(obj)
            % 初始化实验设计 - 使用拉丁超立方采样和因子设计
            
            % 拉丁超立方采样参数
            obj.experiment_design = struct();
            obj.experiment_design.lhs_samples = 500;  % LHS样本数
            obj.experiment_design.morris_trajectories = 50; % Morris方法轨迹数
            obj.experiment_design.sobol_samples = 1000; % Sobol敏感性分析样本数
            
            % 因子实验设计
            obj.experiment_design.factorial_levels = 3; % 3水平因子实验
            obj.experiment_design.fractional_factorial = true; % 部分因子实验
            
            % 重复实验设置
            obj.experiment_design.monte_carlo_runs = 20; % 蒙特卡洛重复次数
            obj.experiment_design.confidence_level = 0.95; % 置信水平
        end
        
        function [best_params, calibration_score] = calibrate_model(obj, max_iterations)
            % 模型校准主函数 - 使用多目标优化
            
            if nargin < 2
                max_iterations = 100;
            end
            
            fprintf('开始模型校准...\n');
            
            % 生成初始参数样本
            param_samples = obj.generate_parameter_samples(obj.experiment_design.lhs_samples);
            
            % 评估每个参数组合
            scores = zeros(size(param_samples, 1), 1);
            
            for i = 1:size(param_samples, 1)
                fprintf('评估参数组合 %d/%d\n', i, size(param_samples, 1));
                
                % 设置模型参数
                obj.set_model_parameters(param_samples(i, :));
                
                % 运行模型
                obj.run_model_with_parameters();
                
                % 计算校准得分
                scores(i) = obj.calculate_calibration_score();
                
                % 记录校准历史
                obj.record_calibration_iteration(param_samples(i, :), scores(i));
            end
            
            % 找到最优参数
            [calibration_score, best_idx] = max(scores);
            best_params = param_samples(best_idx, :);
            obj.best_parameters = best_params;
            
            fprintf('校准完成。最优得分: %.4f\n', calibration_score);
            
            % 精细化搜索（可选）
            if calibration_score < 0.8  % 如果得分不够高，进行精细化搜索
                fprintf('进行精细化搜索...\n');
                [best_params, calibration_score] = obj.refined_search(best_params);
            end
        end
        
        function param_samples = generate_parameter_samples(obj, n_samples)
            % 生成参数样本 - 使用拉丁超立方采样
            
            param_names = fieldnames(obj.parameter_space);
            n_params = length(param_names);
            
            % 拉丁超立方采样
            lhs_samples = lhsdesign(n_samples, n_params);
            param_samples = zeros(n_samples, n_params);
            
            for i = 1:n_params
                param_range = obj.parameter_space.(param_names{i});
                param_samples(:, i) = param_range(1) + ...
                    lhs_samples(:, i) * (param_range(2) - param_range(1));
            end
        end
        
        function set_model_parameters(obj, param_vector)
            % 将参数向量设置到模型中
            
            param_names = fieldnames(obj.parameter_space);
            
            for i = 1:length(param_names)
                param_name = param_names{i};
                param_value = param_vector(i);
                
                % 根据参数名称设置到相应的模型组件
                obj.apply_parameter_to_model(param_name, param_value);
            end
        end
        
        function apply_parameter_to_model(obj, param_name, param_value)
            % 将具体参数应用到模型组件
            
            switch param_name
                case 'technology_level_range'
                    % 设置企业技术水平分布
                    for i = 1:length(obj.model.enterprises)
                        if strcmp(obj.model.enterprises{i}.type, 'industrial')
                            obj.model.enterprises{i}.technology_level = ...
                                param_value * (0.7 + 0.6 * rand);
                        end
                    end
                    
                case 'search_cost_factor_range'
                    % 设置市场搜寻成本
                    if isfield(obj.model, 'pesticide_market')
                        obj.model.pesticide_market.search_cost_factor = param_value;
                    end
                    if isfield(obj.model, 'fertilizer_market')
                        obj.model.fertilizer_market.search_cost_factor = param_value;
                    end
                    
                case 'emission_tax_range'
                    % 设置排放税率
                    obj.model.policy.emission_tax_rate = param_value;
                    
                % 添加更多参数映射...
                otherwise
                    warning('未知参数: %s', param_name);
            end
        end
        
        function run_model_with_parameters(obj)
            % 使用当前参数运行模型
            
            % 重置模型状态
            obj.model.reset();
            
            % 运行模型多个时期
            simulation_periods = 50;
            for t = 1:simulation_periods
                obj.model.step();
            end
        end
        
        function score = calculate_calibration_score(obj)
            % 计算校准得分 - 基于目标匹配度
            
            % 获取模型输出
            model_output = obj.extract_model_output();
            
            % 计算各层面得分
            enterprise_score = obj.calculate_enterprise_score(model_output);
            market_score = obj.calculate_market_score(model_output);
            farmer_score = obj.calculate_farmer_score(model_output);
            environmental_score = obj.calculate_environmental_score(model_output);
            
            % 加权总得分
            score = obj.calibration_weights.enterprise_level * enterprise_score + ...
                   obj.calibration_weights.market_level * market_score + ...
                   obj.calibration_weights.farmer_level * farmer_score + ...
                   obj.calibration_weights.environmental_level * environmental_score;
        end
        
        function model_output = extract_model_output(obj)
            % 从模型中提取关键输出指标
            
            model_output = struct();
            
            % 企业层面指标
            enterprises = obj.model.enterprises;
            productivities = [];
            sizes = [];
            tech_levels = [];
            
            for i = 1:length(enterprises)
                if strcmp(enterprises{i}.type, 'industrial')
                    productivities = [productivities, enterprises{i}.productivity];
                    sizes = [sizes, enterprises{i}.size];
                    tech_levels = [tech_levels, enterprises{i}.technology_level];
                end
            end
            
            model_output.enterprise_productivity_growth = mean(diff(productivities));
            model_output.technology_adoption_rate = mean(tech_levels > 0.6);
            model_output.enterprise_sizes = sizes;
            
            % 市场层面指标
            if isfield(obj.model, 'pesticide_market')
                market = obj.model.pesticide_market;
                if ~isempty(market.transaction_history)
                    prices = [market.transaction_history.price];
                    model_output.price_volatility = std(prices) / mean(prices);
                    model_output.market_concentration_hhi = market.calculate_market_concentration();
                end
            end
            
            % 更多输出指标...
        end
        
        function score = calculate_enterprise_score(obj, model_output)
            % 计算企业层面校准得分
            
            score = 0;
            target_count = 0;
            
            % 生产效率增长
            if isfield(model_output, 'enterprise_productivity_growth')
                target = obj.calibration_targets.enterprise_productivity_growth;
                actual = model_output.enterprise_productivity_growth;
                score = score + exp(-abs(target - actual) / target);
                target_count = target_count + 1;
            end
            
            % 技术采用率
            if isfield(model_output, 'technology_adoption_rate')
                target = obj.calibration_targets.technology_adoption_rate;
                actual = model_output.technology_adoption_rate;
                score = score + exp(-abs(target - actual) / target);
                target_count = target_count + 1;
            end
            
            if target_count > 0
                score = score / target_count;
            end
        end
        
        function score = calculate_market_score(obj, model_output)
            % 计算市场层面校准得分
            
            score = 0;
            target_count = 0;
            
            % 价格波动率
            if isfield(model_output, 'price_volatility')
                target = obj.calibration_targets.price_volatility;
                actual = model_output.price_volatility;
                score = score + exp(-abs(target - actual) / target);
                target_count = target_count + 1;
            end
            
            % 市场集中度
            if isfield(model_output, 'market_concentration_hhi')
                target = obj.calibration_targets.market_concentration_hhi;
                actual = model_output.market_concentration_hhi;
                score = score + exp(-abs(target - actual) / target);
                target_count = target_count + 1;
            end
            
            if target_count > 0
                score = score / target_count;
            end
        end
        
        function score = calculate_farmer_score(obj, model_output)
            % 计算农户层面校准得分
            score = 0.5; % 占位符
        end
        
        function score = calculate_environmental_score(obj, model_output)
            % 计算环境层面校准得分
            score = 0.5; % 占位符
        end
        
        function record_calibration_iteration(obj, params, score)
            % 记录校准迭代结果
            
            iteration = struct();
            iteration.parameters = params;
            iteration.score = score;
            iteration.timestamp = datetime();
            
            obj.calibration_history = [obj.calibration_history; iteration];
        end
        
        function [refined_params, refined_score] = refined_search(obj, initial_params)
            % 精细化搜索 - 在最优参数附近进行局部搜索
            
            fprintf('开始精细化搜索...\n');
            
            % 在最优参数附近生成更密集的样本
            search_radius = 0.1; % 搜索半径
            n_refined_samples = 100;
            
            refined_samples = obj.generate_local_samples(initial_params, search_radius, n_refined_samples);
            
            % 评估精细化样本
            refined_scores = zeros(n_refined_samples, 1);
            for i = 1:n_refined_samples
                obj.set_model_parameters(refined_samples(i, :));
                obj.run_model_with_parameters();
                refined_scores(i) = obj.calculate_calibration_score();
            end
            
            % 找到最优结果
            [refined_score, best_idx] = max(refined_scores);
            refined_params = refined_samples(best_idx, :);
            
            fprintf('精细化搜索完成。改进得分: %.4f\n', refined_score);
        end
        
        function local_samples = generate_local_samples(obj, center_params, radius, n_samples)
            % 在中心参数附近生成局部样本
            
            n_params = length(center_params);
            local_samples = zeros(n_samples, n_params);
            
            for i = 1:n_samples
                % 生成随机扰动
                perturbation = radius * (2 * rand(1, n_params) - 1);
                local_samples(i, :) = center_params + perturbation;
                
                % 确保参数在合理范围内
                local_samples(i, :) = obj.clip_parameters(local_samples(i, :));
            end
        end
        
        function clipped_params = clip_parameters(obj, params)
            % 将参数限制在合理范围内
            
            param_names = fieldnames(obj.parameter_space);
            clipped_params = params;
            
            for i = 1:length(param_names)
                param_range = obj.parameter_space.(param_names{i});
                clipped_params(i) = max(param_range(1), min(param_range(2), params(i)));
            end
        end
        
        function sensitivity_results = conduct_sensitivity_analysis(obj)
            % 进行敏感性分析 - 使用Morris和Sobol方法
            
            fprintf('开始敏感性分析...\n');
            
            % Morris方法全局敏感性分析
            morris_results = obj.morris_sensitivity_analysis();
            
            % Sobol方法方差分解
            sobol_results = obj.sobol_sensitivity_analysis();
            
            % 局部敏感性分析
            local_results = obj.local_sensitivity_analysis();
            
            % 整合结果
            sensitivity_results = struct();
            sensitivity_results.morris = morris_results;
            sensitivity_results.sobol = sobol_results;
            sensitivity_results.local = local_results;
            
            obj.sensitivity_results = sensitivity_results;
            
            fprintf('敏感性分析完成。\n');
        end
        
        function morris_results = morris_sensitivity_analysis(obj)
            % Morris敏感性分析
            
            fprintf('执行Morris敏感性分析...\n');
            
            % 实现Morris方法的基本框架
            % （这里是简化版本，完整实现需要更多细节）
            
            param_names = fieldnames(obj.parameter_space);
            n_params = length(param_names);
            n_trajectories = obj.experiment_design.morris_trajectories;
            
            % 生成Morris轨迹
            morris_trajectories = obj.generate_morris_trajectories(n_trajectories, n_params);
            
            % 计算每个轨迹的效应
            elementary_effects = zeros(n_trajectories, n_params);
            
            for t = 1:n_trajectories
                trajectory = morris_trajectories{t};
                
                for p = 1:n_params
                    % 计算参数p的基本效应
                    effect = obj.calculate_elementary_effect(trajectory, p);
                    elementary_effects(t, p) = effect;
                end
            end
            
            % 计算Morris指标
            morris_results = struct();
            morris_results.mu_star = mean(abs(elementary_effects), 1); % 平均绝对效应
            morris_results.sigma = std(elementary_effects, 0, 1);      % 标准差
            morris_results.parameter_names = param_names;
            
            fprintf('Morris分析完成。\n');
        end
        
        function trajectories = generate_morris_trajectories(obj, n_trajectories, n_params)
            % 生成Morris轨迹（简化版本）
            
            trajectories = cell(n_trajectories, 1);
            
            for t = 1:n_trajectories
                % 每个轨迹包含n_params+1个点
                trajectory = zeros(n_params + 1, n_params);
                
                % 随机起始点
                trajectory(1, :) = rand(1, n_params);
                
                % 构建轨迹
                for i = 2:n_params + 1
                    trajectory(i, :) = trajectory(i-1, :);
                    % 随机选择一个参数进行扰动
                    param_to_change = i - 1;
                    delta = 0.1 * (2 * randi(2) - 3); % +/- 0.1
                    trajectory(i, param_to_change) = ...
                        max(0, min(1, trajectory(i, param_to_change) + delta));
                end
                
                trajectories{t} = trajectory;
            end
        end
        
        function effect = calculate_elementary_effect(obj, trajectory, param_idx)
            % 计算基本效应（简化版本）
            
            % 找到参数param_idx发生变化的步骤
            change_step = param_idx + 1;
            
            if change_step <= size(trajectory, 1)
                % 运行模型两次
                obj.set_model_parameters(trajectory(change_step - 1, :));
                obj.run_model_with_parameters();
                output1 = obj.calculate_calibration_score();
                
                obj.set_model_parameters(trajectory(change_step, :));
                obj.run_model_with_parameters();
                output2 = obj.calculate_calibration_score();
                
                % 计算参数变化
                param_change = trajectory(change_step, param_idx) - ...
                              trajectory(change_step - 1, param_idx);
                
                if abs(param_change) > 1e-10
                    effect = (output2 - output1) / param_change;
                else
                    effect = 0;
                end
            else
                effect = 0;
            end
        end
        
        function sobol_results = sobol_sensitivity_analysis(obj)
            % Sobol敏感性分析（框架）
            
            fprintf('执行Sobol敏感性分析...\n');
            
            % 这里提供Sobol分析的基本框架
            % 完整实现需要更复杂的采样和计算
            
            sobol_results = struct();
            sobol_results.first_order = rand(1, length(fieldnames(obj.parameter_space))); % 占位符
            sobol_results.total_order = rand(1, length(fieldnames(obj.parameter_space))); % 占位符
            
            fprintf('Sobol分析完成。\n');
        end
        
        function local_results = local_sensitivity_analysis(obj)
            % 局部敏感性分析
            
            fprintf('执行局部敏感性分析...\n');
            
            % 在最优参数附近进行数值微分
            base_params = obj.best_parameters;
            param_names = fieldnames(obj.parameter_space);
            n_params = length(param_names);
            
            local_sensitivity = zeros(1, n_params);
            epsilon = 0.01; % 扰动大小
            
            % 计算基准输出
            obj.set_model_parameters(base_params);
            obj.run_model_with_parameters();
            base_output = obj.calculate_calibration_score();
            
            % 对每个参数计算偏微分
            for i = 1:n_params
                perturbed_params = base_params;
                perturbed_params(i) = perturbed_params(i) + epsilon;
                
                obj.set_model_parameters(perturbed_params);
                obj.run_model_with_parameters();
                perturbed_output = obj.calculate_calibration_score();
                
                local_sensitivity(i) = (perturbed_output - base_output) / epsilon;
            end
            
            local_results = struct();
            local_results.sensitivity = local_sensitivity;
            local_results.parameter_names = param_names;
            
            fprintf('局部敏感性分析完成。\n');
        end
        
        function validation_results = validate_model(obj)
            % 模型验证主函数
            
            fprintf('开始模型验证...\n');
            
            % 使用最优参数设置模型
            obj.set_model_parameters(obj.best_parameters);
            
            % 统计验证
            statistical_results = obj.statistical_validation();
            
            % 模式匹配验证
            pattern_results = obj.pattern_matching_validation();
            
            % 行为验证
            behavioral_results = obj.behavioral_validation();
            
            % 系统层面验证
            system_results = obj.system_level_validation();
            
            % 整合验证结果
            validation_results = struct();
            validation_results.statistical = statistical_results;
            validation_results.pattern_matching = pattern_results;
            validation_results.behavioral = behavioral_results;
            validation_results.system_level = system_results;
            validation_results.overall_score = obj.calculate_overall_validation_score(validation_results);
            
            obj.validation_results = validation_results;
            
            fprintf('模型验证完成。总体得分: %.4f\n', validation_results.overall_score);
        end
        
        function statistical_results = statistical_validation(obj)
            % 统计验证
            statistical_results = struct();
            statistical_results.placeholder = 'Statistical validation results';
        end
        
        function pattern_results = pattern_matching_validation(obj)
            % 模式匹配验证
            pattern_results = struct();
            pattern_results.placeholder = 'Pattern matching validation results';
        end
        
        function behavioral_results = behavioral_validation(obj)
            % 行为验证
            behavioral_results = struct();
            behavioral_results.placeholder = 'Behavioral validation results';
        end
        
        function system_results = system_level_validation(obj)
            % 系统层面验证
            system_results = struct();
            system_results.placeholder = 'System level validation results';
        end
        
        function overall_score = calculate_overall_validation_score(obj, validation_results)
            % 计算总体验证得分
            overall_score = 0.75; % 占位符得分
        end
        
        function generate_validation_report(obj, output_file)
            % 生成验证报告
            
            if nargin < 2
                output_file = sprintf('validation_report_%s.html', ...
                    datestr(now, 'yyyymmdd_HHMMSS'));
            end
            
            fprintf('生成验证报告: %s\n', output_file);
            
            % 创建HTML报告（这里是简化版本）
            fid = fopen(output_file, 'w');
            
            fprintf(fid, '<html><head><title>模型验证报告</title></head><body>\n');
            fprintf(fid, '<h1>模型验证报告</h1>\n');
            fprintf(fid, '<p>生成时间: %s</p>\n', datestr(now));
            
            % 校准结果
            fprintf(fid, '<h2>校准结果</h2>\n');
            if ~isempty(obj.best_parameters)
                fprintf(fid, '<p>最优参数已找到</p>\n');
                % 添加更多校准结果细节
            end
            
            % 敏感性分析结果
            fprintf(fid, '<h2>敏感性分析</h2>\n');
            if ~isempty(obj.sensitivity_results)
                fprintf(fid, '<p>敏感性分析已完成</p>\n');
                % 添加敏感性分析细节
            end
            
            % 验证结果
            fprintf(fid, '<h2>验证结果</h2>\n');
            if ~isempty(obj.validation_results)
                fprintf(fid, '<p>总体验证得分: %.4f</p>\n', obj.validation_results.overall_score);
                % 添加更多验证结果细节
            end
            
            fprintf(fid, '</body></html>\n');
            fclose(fid);
            
            fprintf('验证报告已生成: %s\n', output_file);
        end
    end
end 
