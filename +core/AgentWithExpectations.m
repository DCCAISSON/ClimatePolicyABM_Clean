% Version: 2.0-Simplified | Package: core
% Version: 2.0-Simplified | Package: core
classdef core.core
    % 带有预期形成功能的智能体基类
    % 为各种智能体提供基于AR(1)自适应学习的预期形成能力
    
    properties
        % 基本智能体属性
        agent_id
        agent_type
        
        % 预期形成模块
        expectation_module  % ExpectationFormationModule实例
        
        % 预期配置
        expectation_config = struct()  % 预期相关配置
        
        % 决策相关
        decision_weights = struct()    % 预期在决策中的权重
        risk_attitude = 0.5           % 风险态度 [0-1]，影响预期的使用
        
        % 更新周期
        expectation_update_frequency = 1  % 预期更新频率
        last_expectation_update = 0       % 最后预期更新时间
    end
    
    methods
        function obj = AgentWithExpectations(agent_id, agent_type, expectation_variables)
            % 构造函数
            % 输入：
            %   agent_id: 智能体ID
            %   agent_type: 智能体类型
            %   expectation_variables: 需要预期的变量列表
            
            obj.agent_id = agent_id;
            obj.agent_type = agent_type;
            
            % 初始化预期形成模块
            if nargin < 3 || isempty(expectation_variables)
                expectation_variables = obj.get_default_expectation_variables();
            end
            
            obj.expectation_module = ExpectationFormationModule(agent_id, expectation_variables);
            
            % 初始化预期配置
            obj.initialize_expectation_config();
            
            fprintf('智能体 %d (%s) 的预期形成功能初始化完成\n', agent_id, agent_type);
        end
        
        function expectation_variables = get_default_expectation_variables(obj)
            % 获取默认的预期变量 - 子类应该重写此方法
            expectation_variables = {'price', 'demand', 'competition'};
        end
        
        function initialize_expectation_config(obj)
            % 初始化预期配置 - 子类可以重写以自定义配置
            
            % 设置变量边界
            bounds = struct();
            bounds.price = [0, 1000];        % 价格边界
            bounds.demand = [0, 10000];      % 需求量边界
            bounds.competition = [0, 1];     % 竞争强度边界
            bounds.policy_rate = [0, 1];     % 政策税率/补贴率边界
            bounds.quality_standard = [0, 1]; % 质量标准边界
            bounds.wage_rate = [10, 100];    % 工资率边界
            bounds.technology_cost = [0, 100000]; % 技术成本边界
            
            % 应用边界到预期模块
            for i = 1:length(obj.expectation_module.expectation_variables)
                var_name = obj.expectation_module.expectation_variables{i};
                if isfield(bounds, var_name)
                    obj.expectation_module.variable_bounds.(var_name) = bounds.(var_name);
                end
            end
            
            % 设置决策权重
            obj.decision_weights.expectation_weight = 0.7;  % 预期在决策中的权重
            obj.decision_weights.current_info_weight = 0.3; % 当前信息的权重
            
            % 设置预期配置
            obj.expectation_config.use_confidence = true;   % 是否使用置信度调整决策
            obj.expectation_config.min_confidence = 0.1;    % 最小置信度阈值
            obj.expectation_config.confidence_decay = 0.95; % 置信度衰减因子
        end
        
        function update_expectations(obj, observations, current_time)
            % 更新预期
            % 输入：
            %   observations: 观测数据结构体 {变量名: 观测值}
            %   current_time: 当前时间步
            
            if nargin < 3
                current_time = obj.last_expectation_update + 1;
            end
            
            % 检查是否需要更新
            if current_time - obj.last_expectation_update < obj.expectation_update_frequency
                return;
            end
            
            % 添加观测数据并更新模型参数
            if isstruct(observations)
                fields = fieldnames(observations);
                for i = 1:length(fields)
                    var_name = fields{i};
                    if ismember(var_name, obj.expectation_module.expectation_variables)
                        % 添加观测
                        obj.expectation_module.add_observation(var_name, observations.(var_name), current_time);
                        
                        % 更新模型参数
                        obj.expectation_module.update_model_parameters(var_name, observations.(var_name));
                    end
                end
            end
            
            % 形成新的预期
            obj.expectation_module.form_expectations();
            
            obj.last_expectation_update = current_time;
        end
        
        function expectation = get_expectation(obj, var_name, horizon, adjust_for_confidence)
            % 获取特定变量的预期值
            % 输入：
            %   var_name: 变量名
            %   horizon: 预测期数（默认1）
            %   adjust_for_confidence: 是否根据置信度调整（默认true）
            % 输出：
            %   expectation: 预期值（可能是调整后的）
            
            if nargin < 3
                horizon = 1;
            end
            if nargin < 4
                adjust_for_confidence = true;
            end
            
            % 获取原始预期
            if horizon == 1 && isfield(obj.expectation_module.current_expectations, var_name)
                raw_expectation = obj.expectation_module.current_expectations.(var_name);
            else
                % 多期预测
                expectations = obj.expectation_module.form_expectations({var_name}, horizon);
                if isfield(expectations, var_name)
                    raw_expectation = expectations.(var_name);
                else
                    raw_expectation = NaN;
                end
            end
            
            if isnan(raw_expectation)
                expectation = raw_expectation;
                return;
            end
            
            % 根据置信度调整预期
            if adjust_for_confidence && obj.expectation_config.use_confidence
                confidence_interval = obj.expectation_module.confidence_intervals.(var_name);
                if ~any(isnan(confidence_interval))
                    % 根据风险态度调整预期
                    if obj.risk_attitude < 0.5
                        % 风险厌恶：倾向于保守预期
                        adjustment_factor = 0.3 - 0.6 * obj.risk_attitude;
                        expectation = raw_expectation + adjustment_factor * (confidence_interval(1) - raw_expectation);
                    elseif obj.risk_attitude > 0.5
                        % 风险喜好：倾向于乐观预期
                        adjustment_factor = 0.6 * obj.risk_attitude - 0.3;
                        expectation = raw_expectation + adjustment_factor * (confidence_interval(2) - raw_expectation);
                    else
                        % 风险中性：使用原始预期
                        expectation = raw_expectation;
                    end
                else
                    expectation = raw_expectation;
                end
            else
                expectation = raw_expectation;
            end
        end
        
        function confidence = get_prediction_confidence(obj, var_name)
            % 获取预测置信度
            
            if ~ismember(var_name, obj.expectation_module.expectation_variables)
                confidence = 0;
                return;
            end
            
            if isfield(obj.expectation_module.prediction_accuracy, var_name) && ...
               ~isnan(obj.expectation_module.prediction_accuracy.(var_name))
                accuracy = obj.expectation_module.prediction_accuracy.(var_name);
                confidence = accuracy.accuracy_score;
            else
                confidence = 0.5; % 默认中等置信度
            end
        end
        
        function weighted_value = combine_expectation_with_current(obj, var_name, current_value, expectation_horizon)
            % 将预期与当前信息结合
            % 输入：
            %   var_name: 变量名
            %   current_value: 当前观测值
            %   expectation_horizon: 预期期数
            % 输出：
            %   weighted_value: 加权组合值
            
            if nargin < 4
                expectation_horizon = 1;
            end
            
            % 获取预期值
            expected_value = obj.get_expectation(var_name, expectation_horizon);
            
            if isnan(expected_value)
                weighted_value = current_value;
                return;
            end
            
            % 获取置信度
            confidence = obj.get_prediction_confidence(var_name);
            
            % 根据置信度调整权重
            adjusted_expectation_weight = obj.decision_weights.expectation_weight * confidence;
            adjusted_current_weight = 1 - adjusted_expectation_weight;
            
            % 加权组合
            weighted_value = adjusted_expectation_weight * expected_value + ...
                           adjusted_current_weight * current_value;
        end
        
        function scenario_expectations = form_scenario_expectations(obj, scenario_adjustments)
            % 形成情景预期
            % 输入：
            %   scenario_adjustments: 情景调整 {变量名: 调整因子}
            % 输出：
            %   scenario_expectations: 情景预期
            
            scenario_expectations = struct();
            
            for i = 1:length(obj.expectation_module.expectation_variables)
                var_name = obj.expectation_module.expectation_variables{i};
                
                % 获取基准预期
                base_expectation = obj.get_expectation(var_name);
                
                if isnan(base_expectation)
                    continue;
                end
                
                % 应用情景调整
                if isfield(scenario_adjustments, var_name)
                    adjustment = scenario_adjustments.(var_name);
                    if adjustment >= 0
                        % 乘法调整
                        scenario_expectation = base_expectation * (1 + adjustment);
                    else
                        % 加法调整
                        scenario_expectation = base_expectation + adjustment;
                    end
                else
                    scenario_expectation = base_expectation;
                end
                
                % 应用变量边界
                bounds = obj.expectation_module.variable_bounds.(var_name);
                scenario_expectation = max(bounds(1), min(bounds(2), scenario_expectation));
                
                scenario_expectations.(var_name) = scenario_expectation;
            end
        end
        
        function adapt_to_forecast_errors(obj, var_name, actual_value, predicted_value)
            % 根据预测误差调整学习参数
            
            prediction_error = abs(actual_value - predicted_value);
            relative_error = prediction_error / max(abs(actual_value), 1e-6);
            
            % 如果误差过大，增加学习率
            if relative_error > 0.2 % 20%误差阈值
                current_lr = obj.expectation_module.learning_rate;
                new_lr = min(obj.expectation_module.max_learning_rate, current_lr * 1.2);
                obj.expectation_module.learning_rate = new_lr;
                
                % 可选：重置该变量的部分历史（如果误差极大）
                if relative_error > 0.5 % 50%误差阈值
                    data_length = length(obj.expectation_module.historical_data.(var_name));
                    if data_length > 6
                        % 保留最近一半的数据
                        keep_length = ceil(data_length / 2);
                        obj.expectation_module.historical_data.(var_name) = ...
                            obj.expectation_module.historical_data.(var_name)(end-keep_length+1:end);
                        obj.expectation_module.prediction_errors.(var_name) = ...
                            obj.expectation_module.prediction_errors.(var_name)(end-keep_length+1:end);
                    end
                end
            end
        end
        
        function summary = get_expectation_summary(obj)
            % 获取预期形成的总结信息
            
            summary = obj.expectation_module.get_learning_summary();
            
            % 添加智能体特定信息
            summary.risk_attitude = obj.risk_attitude;
            summary.decision_weights = obj.decision_weights;
            summary.update_frequency = obj.expectation_update_frequency;
            
            % 计算总体预期准确性
            variables = obj.expectation_module.expectation_variables;
            accuracy_scores = [];
            for i = 1:length(variables)
                var_name = variables{i};
                confidence = obj.get_prediction_confidence(var_name);
                if ~isnan(confidence)
                    accuracy_scores = [accuracy_scores, confidence];
                end
            end
            
            if ~isempty(accuracy_scores)
                summary.average_accuracy = mean(accuracy_scores);
                summary.accuracy_std = std(accuracy_scores);
            else
                summary.average_accuracy = NaN;
                summary.accuracy_std = NaN;
            end
        end
        
        function set_expectation_parameter(obj, param_name, value)
            % 设置预期形成参数
            
            switch param_name
                case 'learning_rate'
                    obj.expectation_module.learning_rate = value;
                case 'memory_length'
                    obj.expectation_module.memory_length = value;
                case 'risk_attitude'
                    obj.risk_attitude = value;
                case 'expectation_weight'
                    obj.decision_weights.expectation_weight = value;
                    obj.decision_weights.current_info_weight = 1 - value;
                case 'update_frequency'
                    obj.expectation_update_frequency = value;
                otherwise
                    warning('未知的参数: %s', param_name);
            end
        end
        
        function print_expectation_status(obj)
            % 打印预期形成状态
            
            fprintf('\n=== 智能体 %d (%s) 预期形成状态 ===\n', obj.agent_id, obj.agent_type);
            
            % 打印当前预期
            variables = obj.expectation_module.expectation_variables;
            fprintf('当前预期值：\n');
            for i = 1:length(variables)
                var_name = variables{i};
                expectation = obj.expectation_module.current_expectations.(var_name);
                confidence = obj.get_prediction_confidence(var_name);
                
                fprintf('  %s: %.4f (置信度: %.3f)\n', var_name, expectation, confidence);
            end
            
            % 打印学习参数
            fprintf('\n学习参数：\n');
            fprintf('  学习率: %.4f\n', obj.expectation_module.learning_rate);
            fprintf('  记忆长度: %d\n', obj.expectation_module.memory_length);
            fprintf('  风险态度: %.3f\n', obj.risk_attitude);
            fprintf('  预期权重: %.3f\n', obj.decision_weights.expectation_weight);
            
            % 打印准确性指标
            summary = obj.get_expectation_summary();
            if ~isnan(summary.average_accuracy)
                fprintf('\n预期准确性：\n');
                fprintf('  平均准确性: %.3f\n', summary.average_accuracy);
                fprintf('  准确性标准差: %.3f\n', summary.accuracy_std);
            end
            
            fprintf('================================\n\n');
        end
    end
    
    methods (Abstract)
        % 抽象方法 - 子类必须实现
        
        make_decision_with_expectations(obj, market_info, expectations)
        % 基于预期做出决策
        
        identify_key_expectation_variables(obj)
        % 识别关键的预期变量
    end
end 
