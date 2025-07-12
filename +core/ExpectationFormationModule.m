% Version: 2.0-Simplified | Package: core
% Version: 2.0-Simplified | Package: core
classdef core.core
    % 预期形成模块 - 基于AR(1)自适应学习机制
    % 参考2023年EER模型的智能体预期形成机制
    % 特点：简洁有效的自适应学习，不断优化AR(1)预测规则
    
    properties
        % 预期变量
        expectation_variables = {}    % 需要预期的变量名列表
        
        % AR(1)模型参数 - 针对每个变量
        ar_coefficients = struct()   % AR(1)系数 {变量名: [α, β]}
        intercepts = struct()        % 截距项
        
        % 历史数据
        historical_data = struct()   % 历史观测数据 {变量名: [时间序列]}
        prediction_errors = struct() % 预测误差历史
        
        % 学习参数
        learning_rate = 0.1          % 学习速率
        memory_length = 12           % 记忆长度（时间步）
        minimum_data_points = 3      % 最少数据点数
        
        % 自适应调整参数
        error_threshold = 0.1        % 误差阈值，超过时调整学习率
        learning_rate_adjustment = 0.95  % 学习率调整因子
        max_learning_rate = 0.3      % 最大学习率
        min_learning_rate = 0.01     % 最小学习率
        
        % 预期结果
        current_expectations = struct()  % 当前预期值
        confidence_intervals = struct()  % 置信区间
        prediction_accuracy = struct()   % 预测准确性指标
        
        % 模型参数
        agent_id                     % 所属智能体ID
        variable_bounds = struct()   % 变量取值边界
        
        % 诊断信息
        learning_diagnostics = struct()  % 学习过程诊断
        last_update_time = 0        % 最后更新时间
    end
    
    methods
        function obj = ExpectationFormationModule(agent_id, variables, params)
            % 构造函数
            % 输入：
            %   agent_id: 智能体ID
            %   variables: 需要预期的变量名列表 (cell array)
            %   params: 参数结构体
            
            obj.agent_id = agent_id;
            
            if nargin > 1 && ~isempty(variables)
                obj.expectation_variables = variables;
            end
            
            if nargin > 2 && ~isempty(params)
                obj.initialize_parameters(params);
            else
                obj.initialize_default_parameters();
            end
            
            % 初始化变量
            obj.initialize_variables();
            
            fprintf('智能体 %d 的预期形成模块初始化完成，跟踪 %d 个变量\n', ...
                    obj.agent_id, length(obj.expectation_variables));
        end
        
        function initialize_parameters(obj, params)
            % 初始化参数
            
            if isfield(params, 'learning_rate')
                obj.learning_rate = params.learning_rate;
            end
            
            if isfield(params, 'memory_length')
                obj.memory_length = params.memory_length;
            end
            
            if isfield(params, 'minimum_data_points')
                obj.minimum_data_points = params.minimum_data_points;
            end
            
            if isfield(params, 'error_threshold')
                obj.error_threshold = params.error_threshold;
            end
            
            if isfield(params, 'variable_bounds')
                obj.variable_bounds = params.variable_bounds;
            end
        end
        
        function initialize_default_parameters(obj)
            % 初始化默认参数
            obj.learning_rate = 0.1;
            obj.memory_length = 12;
            obj.minimum_data_points = 3;
            obj.error_threshold = 0.1;
            obj.learning_rate_adjustment = 0.95;
            obj.max_learning_rate = 0.3;
            obj.min_learning_rate = 0.01;
        end
        
        function initialize_variables(obj)
            % 初始化所有跟踪变量的数据结构
            
            for i = 1:length(obj.expectation_variables)
                var_name = obj.expectation_variables{i};
                
                % 初始化AR(1)参数 - EER模型风格的简单初始化
                obj.ar_coefficients.(var_name) = [0.1, 0.8]; % [α(截距权重), β(滞后项权重)]
                obj.intercepts.(var_name) = 0;
                
                % 初始化历史数据
                obj.historical_data.(var_name) = [];
                obj.prediction_errors.(var_name) = [];
                
                % 初始化预期和置信度
                obj.current_expectations.(var_name) = NaN;
                obj.confidence_intervals.(var_name) = [NaN, NaN];
                obj.prediction_accuracy.(var_name) = NaN;
                
                % 设置默认边界
                if ~isfield(obj.variable_bounds, var_name)
                    obj.variable_bounds.(var_name) = [-Inf, Inf];
                end
                
                % 初始化诊断信息
                obj.learning_diagnostics.(var_name) = struct( ...
                    'learning_rate_history', [], ...
                    'parameter_history', [], ...
                    'error_variance', NaN, ...
                    'autocorrelation', NaN ...
                );
            end
        end
        
        function add_observation(obj, var_name, value, time_step)
            % 添加新的观测数据
            % 输入：
            %   var_name: 变量名
            %   value: 观测值
            %   time_step: 时间步（可选）
            
            if nargin < 4
                time_step = obj.last_update_time + 1;
            end
            
            if ~ismember(var_name, obj.expectation_variables)
                warning('变量 %s 不在预期变量列表中', var_name);
                return;
            end
            
            % 添加到历史数据
            obj.historical_data.(var_name) = [obj.historical_data.(var_name), value];
            
            % 维持记忆长度
            if length(obj.historical_data.(var_name)) > obj.memory_length
                obj.historical_data.(var_name) = obj.historical_data.(var_name)(end-obj.memory_length+1:end);
                obj.prediction_errors.(var_name) = obj.prediction_errors.(var_name)(end-obj.memory_length+1:end);
            end
            
            obj.last_update_time = max(obj.last_update_time, time_step);
        end
        
        function expectations = form_expectations(obj, var_names, horizon)
            % 形成预期 - 核心AR(1)预测机制
            % 输入：
            %   var_names: 变量名列表（可选，默认全部变量）
            %   horizon: 预测期数（默认1期）
            % 输出：
            %   expectations: 预期值结构体
            
            if nargin < 2 || isempty(var_names)
                var_names = obj.expectation_variables;
            end
            
            if nargin < 3
                horizon = 1;
            end
            
            expectations = struct();
            
            for i = 1:length(var_names)
                var_name = var_names{i};
                
                if ~ismember(var_name, obj.expectation_variables)
                    continue;
                end
                
                % 获取历史数据
                data = obj.historical_data.(var_name);
                
                if length(data) < obj.minimum_data_points
                    % 数据不足，使用简单平均或最后观测值
                    if isempty(data)
                        expectation = 0; % 或使用先验值
                    else
                        expectation = mean(data);
                    end
                    confidence = 0.3; % 低置信度
                else
                    % 使用AR(1)模型进行预测
                    [expectation, confidence] = obj.ar1_predict(var_name, horizon);
                end
                
                % 应用边界约束
                bounds = obj.variable_bounds.(var_name);
                expectation = max(bounds(1), min(bounds(2), expectation));
                
                % 存储结果
                obj.current_expectations.(var_name) = expectation;
                expectations.(var_name) = expectation;
                
                % 计算置信区间
                if confidence > 0
                    margin = 1.96 * confidence; % 95%置信区间
                    obj.confidence_intervals.(var_name) = [expectation - margin, expectation + margin];
                else
                    obj.confidence_intervals.(var_name) = [expectation, expectation];
                end
            end
        end
        
        function [prediction, confidence] = ar1_predict(obj, var_name, horizon)
            % AR(1)预测核心算法 - 参考EER模型的简洁设计
            % 模型：X_t+1 = α + β * X_t + ε_t
            
            data = obj.historical_data.(var_name);
            n = length(data);
            
            if n < 2
                prediction = data(end);
                confidence = 0.5;
                return;
            end
            
            % 获取当前AR(1)参数
            coeffs = obj.ar_coefficients.(var_name);
            alpha = coeffs(1); % 截距
            beta = coeffs(2);  % 自回归系数
            
            % 多步预测
            current_value = data(end);
            prediction = current_value;
            
            for h = 1:horizon
                prediction = alpha + beta * prediction;
            end
            
            % 计算预测置信度（基于历史预测误差）
            errors = obj.prediction_errors.(var_name);
            if length(errors) >= 3
                error_variance = var(errors);
                confidence = sqrt(error_variance * (1 + (horizon-1) * beta^2)); % 多步预测方差
            else
                confidence = abs(prediction) * 0.1; % 默认10%的不确定性
            end
        end
        
        function update_model_parameters(obj, var_name, observed_value)
            % 自适应学习更新AR(1)参数 - EER模型的核心机制
            % 使用递归最小二乘法的简化版本进行在线学习
            
            data = obj.historical_data.(var_name);
            n = length(data);
            
            if n < 2
                return; % 数据不足，无法更新
            end
            
            % 计算预测误差
            if ~isnan(obj.current_expectations.(var_name))
                prediction_error = observed_value - obj.current_expectations.(var_name);
                obj.prediction_errors.(var_name) = [obj.prediction_errors.(var_name), prediction_error];
                
                % 维持误差历史长度
                if length(obj.prediction_errors.(var_name)) > obj.memory_length
                    obj.prediction_errors.(var_name) = obj.prediction_errors.(var_name)(end-obj.memory_length+1:end);
                end
            else
                prediction_error = 0;
            end
            
            % 自适应调整学习率
            current_lr = obj.adapt_learning_rate(var_name, prediction_error);
            
            % 更新AR(1)参数 - 使用梯度下降的简化版本
            if n >= 2
                % 准备回归数据
                y = data(2:end);          % 因变量
                x_lag = data(1:end-1);    % 滞后项
                x_const = ones(size(y));  % 常数项
                
                if length(y) >= obj.minimum_data_points
                    % 使用最小二乘法估计参数（在线更新版本）
                    X = [x_const(:), x_lag(:)];
                    
                    try
                        % 简化的递归最小二乘更新
                        old_coeffs = obj.ar_coefficients.(var_name);
                        
                        % 计算新的参数估计
                        if size(X, 1) >= size(X, 2) % 确保有足够的观测
                            new_params = (X' * X) \ (X' * y(:));
                            alpha_new = new_params(1);
                            beta_new = new_params(2);
                            
                            % 平滑更新参数（避免剧烈变化）
                            alpha_updated = (1 - current_lr) * old_coeffs(1) + current_lr * alpha_new;
                            beta_updated = (1 - current_lr) * old_coeffs(2) + current_lr * beta_new;
                            
                            % 确保AR系数稳定性 |β| < 1
                            beta_updated = max(-0.95, min(0.95, beta_updated));
                            
                            obj.ar_coefficients.(var_name) = [alpha_updated, beta_updated];
                            
                            % 记录参数更新历史
                            obj.learning_diagnostics.(var_name).parameter_history = ...
                                [obj.learning_diagnostics.(var_name).parameter_history; ...
                                 alpha_updated, beta_updated];
                        end
                    catch ME
                        warning('参数更新失败: %s', ME.message);
                    end
                end
            end
            
            % 更新预测准确性指标
            obj.update_accuracy_metrics(var_name);
            
            % 记录学习率历史
            obj.learning_diagnostics.(var_name).learning_rate_history = ...
                [obj.learning_diagnostics.(var_name).learning_rate_history, current_lr];
        end
        
        function learning_rate = adapt_learning_rate(obj, var_name, prediction_error)
            % 自适应学习率调整 - EER模型的关键特性
            
            errors = obj.prediction_errors.(var_name);
            
            if length(errors) < 2
                learning_rate = obj.learning_rate;
                return;
            end
            
            % 计算最近的预测误差统计
            recent_errors = errors(max(1, end-5):end); % 最近5期误差
            mean_abs_error = mean(abs(recent_errors));
            error_volatility = std(recent_errors);
            
            % 基于误差大小调整学习率
            if mean_abs_error > obj.error_threshold
                % 误差较大，增加学习率以快速适应
                learning_rate = min(obj.max_learning_rate, obj.learning_rate * 1.1);
            else
                % 误差较小，减少学习率以稳定收敛
                learning_rate = max(obj.min_learning_rate, obj.learning_rate * obj.learning_rate_adjustment);
            end
            
            % 基于误差波动性调整
            if error_volatility > mean_abs_error * 0.5
                % 高波动性，适度降低学习率
                learning_rate = learning_rate * 0.9;
            end
            
            % 更新基础学习率
            obj.learning_rate = learning_rate;
        end
        
        function update_accuracy_metrics(obj, var_name)
            % 更新预测准确性指标
            
            errors = obj.prediction_errors.(var_name);
            
            if length(errors) < 3
                return;
            end
            
            % 计算各种准确性指标
            mae = mean(abs(errors));           % 平均绝对误差
            rmse = sqrt(mean(errors.^2));      % 均方根误差
            mape = mean(abs(errors) ./ abs(obj.historical_data.(var_name)(end-length(errors)+1:end))) * 100; % 平均绝对百分比误差
            
            % 避免除零
            if isnan(mape) || isinf(mape)
                mape = 100;
            end
            
            % 计算准确性得分（0-1，越接近1越准确）
            accuracy_score = 1 / (1 + rmse);
            
            obj.prediction_accuracy.(var_name) = struct( ...
                'mae', mae, ...
                'rmse', rmse, ...
                'mape', mape, ...
                'accuracy_score', accuracy_score ...
            );
            
            % 更新诊断信息
            obj.learning_diagnostics.(var_name).error_variance = var(errors);
            if length(errors) > 1
                obj.learning_diagnostics.(var_name).autocorrelation = corr(errors(1:end-1)', errors(2:end)');
            end
        end
        
        function reset_variable(obj, var_name)
            % 重置特定变量的学习状态
            
            if ismember(var_name, obj.expectation_variables)
                obj.historical_data.(var_name) = [];
                obj.prediction_errors.(var_name) = [];
                obj.ar_coefficients.(var_name) = [0.1, 0.8];
                obj.current_expectations.(var_name) = NaN;
                obj.confidence_intervals.(var_name) = [NaN, NaN];
                obj.prediction_accuracy.(var_name) = NaN;
                
                fprintf('变量 %s 的学习状态已重置\n', var_name);
            end
        end
        
        function add_new_variable(obj, var_name, bounds)
            % 添加新的预期变量
            
            if nargin < 3
                bounds = [-Inf, Inf];
            end
            
            if ~ismember(var_name, obj.expectation_variables)
                obj.expectation_variables{end+1} = var_name;
                obj.variable_bounds.(var_name) = bounds;
                
                % 初始化新变量
                obj.ar_coefficients.(var_name) = [0.1, 0.8];
                obj.intercepts.(var_name) = 0;
                obj.historical_data.(var_name) = [];
                obj.prediction_errors.(var_name) = [];
                obj.current_expectations.(var_name) = NaN;
                obj.confidence_intervals.(var_name) = [NaN, NaN];
                obj.prediction_accuracy.(var_name) = NaN;
                
                obj.learning_diagnostics.(var_name) = struct( ...
                    'learning_rate_history', [], ...
                    'parameter_history', [], ...
                    'error_variance', NaN, ...
                    'autocorrelation', NaN ...
                );
                
                fprintf('已添加新的预期变量: %s\n', var_name);
            end
        end
        
        function summary = get_learning_summary(obj)
            % 获取学习过程的总结信息
            
            summary = struct();
            summary.agent_id = obj.agent_id;
            summary.variables = obj.expectation_variables;
            summary.learning_rate = obj.learning_rate;
            summary.memory_length = obj.memory_length;
            summary.last_update_time = obj.last_update_time;
            
            % 汇总各变量的表现
            variable_performance = struct();
            for i = 1:length(obj.expectation_variables)
                var_name = obj.expectation_variables{i};
                
                performance = struct();
                performance.current_expectation = obj.current_expectations.(var_name);
                performance.confidence_interval = obj.confidence_intervals.(var_name);
                performance.data_points = length(obj.historical_data.(var_name));
                performance.ar_coefficients = obj.ar_coefficients.(var_name);
                
                if ~isnan(obj.prediction_accuracy.(var_name))
                    performance.accuracy = obj.prediction_accuracy.(var_name);
                else
                    performance.accuracy = struct('mae', NaN, 'rmse', NaN, 'mape', NaN, 'accuracy_score', NaN);
                end
                
                variable_performance.(var_name) = performance;
            end
            
            summary.variable_performance = variable_performance;
        end
        
        function print_diagnostics(obj, var_name)
            % 打印特定变量的诊断信息
            
            if nargin < 2
                % 打印所有变量
                for i = 1:length(obj.expectation_variables)
                    obj.print_diagnostics(obj.expectation_variables{i});
                end
                return;
            end
            
            if ~ismember(var_name, obj.expectation_variables)
                warning('变量 %s 不存在', var_name);
                return;
            end
            
            fprintf('\n=== 变量 %s 的预期形成诊断 ===\n', var_name);
            fprintf('数据点数: %d\n', length(obj.historical_data.(var_name)));
            fprintf('AR(1)参数: α=%.4f, β=%.4f\n', ...
                    obj.ar_coefficients.(var_name)(1), obj.ar_coefficients.(var_name)(2));
            fprintf('当前预期: %.4f\n', obj.current_expectations.(var_name));
            
            if ~isnan(obj.prediction_accuracy.(var_name))
                acc = obj.prediction_accuracy.(var_name);
                fprintf('预测准确性:\n');
                fprintf('  MAE: %.4f\n', acc.mae);
                fprintf('  RMSE: %.4f\n', acc.rmse);
                fprintf('  MAPE: %.2f%%\n', acc.mape);
                fprintf('  准确性得分: %.4f\n', acc.accuracy_score);
            end
            
            diagnostics = obj.learning_diagnostics.(var_name);
            if ~isnan(diagnostics.error_variance)
                fprintf('误差方差: %.4f\n', diagnostics.error_variance);
            end
            if ~isnan(diagnostics.autocorrelation)
                fprintf('误差自相关: %.4f\n', diagnostics.autocorrelation);
            end
            
            fprintf('当前学习率: %.4f\n', obj.learning_rate);
            fprintf('==============================\n\n');
        end
    end
end 
