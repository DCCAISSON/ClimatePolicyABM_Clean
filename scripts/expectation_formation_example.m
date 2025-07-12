%% EER模型风格的预期形成机制演示
% 展示基于AR(1)自适应学习的智能体预期形成和决策过程
% 参考2023年EER模型的设计思路：简洁有效的自适应学习，不断优化AR(1)预测规则

clear; clc;
fprintf('=== EER模型风格预期形成机制演示 ===\n\n');

%% 1. 初始化带预期功能的企业智能体
fprintf('1. 创建带有预期形成功能的企业智能体...\n');

% 创建三种不同类型的企业
enterprise_types = {'pesticide', 'fertilizer', 'processing'};
enterprises = cell(3, 1);

for i = 1:length(enterprise_types)
    % 设置企业参数
    params = struct();
    params.production_capacity = 1000 + i * 500;
    params.technology_level = 0.4 + i * 0.1;
    params.current_price = 50 + i * 20;
    params.variable_cost_per_unit = 30 + i * 10;
    
    % 创建企业智能体
    enterprises{i} = EnterpriseAgentWithExpectations(i, enterprise_types{i}, params);
    
    fprintf('  企业 %d (%s) 创建完成\n', i, enterprise_types{i});
end

%% 2. 模拟市场环境和数据生成
fprintf('\n2. 设定市场环境和数据生成机制...\n');

% 仿真参数
simulation_periods = 36;  % 36个月（3年）
current_time = 1;

% 初始化市场变量（模拟真实的市场动态）
market_data = struct();
market_data.time_series = struct();

% 市场变量的真实动态模型（用于生成"真实"数据）
true_market_params = struct();
true_market_params.price_trend = 0.02;        % 价格月度增长趋势
true_market_params.demand_growth = 0.015;     % 需求月度增长趋势
true_market_params.competition_cycle = 12;    % 竞争强度周期（月）
true_market_params.policy_shock_prob = 0.1;   % 政策冲击概率
true_market_params.volatility = 0.05;         % 市场波动率

% 初始化真实市场状态
true_market_state = struct();
true_market_state.base_price = 60;
true_market_state.base_demand = 1500;
true_market_state.base_competition = 0.5;
true_market_state.current_emission_tax = 0.05;
true_market_state.current_quality_standard = 0.6;

fprintf('市场环境设定完成\n');

%% 3. 运行多期仿真，展示预期学习过程
fprintf('\n3. 开始多期仿真，观察预期学习过程...\n');

% 记录仿真结果
simulation_results = struct();
simulation_results.market_data = [];
simulation_results.enterprise_decisions = cell(3, simulation_periods);
simulation_results.expectation_accuracy = zeros(3, simulation_periods);
simulation_results.prediction_errors = cell(3, 1);

for t = 1:simulation_periods
    fprintf('\n--- 时间步 %d ---\n', t);
    
    %% 3.1 生成真实市场数据
    market_data_t = generate_market_data(t, true_market_state, true_market_params);
    simulation_results.market_data = [simulation_results.market_data; market_data_t];
    
    %% 3.2 企业观测市场并更新预期
    for i = 1:length(enterprises)
        enterprise = enterprises{i};
        
        % 企业观测到的市场数据（可能有观测误差）
        observed_data = add_observation_noise(market_data_t, 0.02); % 2%观测噪声
        
        % 更新预期
        enterprise.update_market_observations(observed_data, t);
        
        fprintf('企业 %d 更新预期完成\n', i);
    end
    
    %% 3.3 企业基于预期做出决策
    for i = 1:length(enterprises)
        enterprise = enterprises{i};
        
        % 基于预期做出决策
        decision = enterprise.make_decision_with_expectations(market_data_t);
        simulation_results.enterprise_decisions{i, t} = decision;
        
        % 更新企业状态
        enterprise.current_price = decision.price;
        enterprise.current_production = decision.production;
        
        % 评估预期准确性
        accuracy = evaluate_expectation_accuracy(enterprise, market_data_t);
        simulation_results.expectation_accuracy(i, t) = accuracy;
    end
    
    %% 3.4 市场反馈和状态更新
    true_market_state = update_market_state(true_market_state, market_data_t, enterprises);
    
    % 每6个月打印详细状态
    if mod(t, 6) == 0
        fprintf('\n=== 第 %d 月市场状态总结 ===\n', t);
        print_market_summary(market_data_t, enterprises);
        
        % 打印预期学习进展
        print_expectation_learning_progress(enterprises, t);
    end
end

%% 4. 分析预期形成的效果
fprintf('\n4. 分析预期形成机制的效果...\n');

%% 4.1 预期准确性分析
fprintf('\n预期准确性分析：\n');
for i = 1:length(enterprises)
    enterprise = enterprises{i};
    avg_accuracy = mean(simulation_results.expectation_accuracy(i, 6:end)); % 排除前6个月的适应期
    
    fprintf('  企业 %d (%s):\n', i, enterprise.enterprise_type);
    fprintf('    平均预期准确性: %.3f\n', avg_accuracy);
    
    % 分析学习改进
    early_accuracy = mean(simulation_results.expectation_accuracy(i, 6:12));
    late_accuracy = mean(simulation_results.expectation_accuracy(i, 30:36));
    improvement = late_accuracy - early_accuracy;
    
    fprintf('    学习改进: %.3f (早期: %.3f -> 后期: %.3f)\n', ...
            improvement, early_accuracy, late_accuracy);
    
    % 分析关键变量的预期表现
    key_vars = enterprise.identify_key_expectation_variables();
    fprintf('    关键变量预期表现：\n');
    for j = 1:min(3, length(key_vars)) % 显示前3个关键变量
        var_name = key_vars{j};
        confidence = enterprise.get_prediction_confidence(var_name);
        fprintf('      %s: 置信度 %.3f\n', var_name, confidence);
    end
end

%% 4.2 预期vs实际值的对比分析
fprintf('\n预期与实际值对比分析：\n');
analyze_expectation_vs_actual(enterprises, simulation_results.market_data);

%% 4.3 不同学习参数的敏感性分析
fprintf('\n学习参数敏感性分析...\n');
conduct_learning_sensitivity_analysis(enterprises);

%% 5. 政策冲击实验
fprintf('\n5. 政策冲击实验：测试预期适应能力...\n');

% 模拟突然的政策变化
policy_shock = struct();
policy_shock.emission_tax_increase = 0.15;  % 排放税突然增加到15%
policy_shock.quality_standard_increase = 0.8; % 质量标准提高到0.8

fprintf('实施政策冲击：排放税 %.1f%% -> %.1f%%, 质量标准 %.2f -> %.2f\n', ...
        true_market_state.current_emission_tax * 100, ...
        policy_shock.emission_tax_increase * 100, ...
        true_market_state.current_quality_standard, ...
        policy_shock.quality_standard_increase);

% 应用政策冲击
true_market_state.current_emission_tax = policy_shock.emission_tax_increase;
true_market_state.current_quality_standard = policy_shock.quality_standard_increase;

% 运行政策冲击后的6个月
post_shock_periods = 6;
for t = 1:post_shock_periods
    time_step = simulation_periods + t;
    
    % 生成冲击后的市场数据
    market_data_t = generate_market_data(time_step, true_market_state, true_market_params);
    
    % 企业观测和决策
    for i = 1:length(enterprises)
        enterprise = enterprises{i};
        observed_data = add_observation_noise(market_data_t, 0.02);
        enterprise.update_market_observations(observed_data, time_step);
        
        decision = enterprise.make_decision_with_expectations(market_data_t);
        
        % 分析政策冲击响应
        if t == 1
            fprintf('企业 %d 对政策冲击的初始响应：\n', i);
            fprintf('  R&D投资调整: %.0f 元\n', decision.investment.rd_amount);
            fprintf('  环保投资调整: %.0f 元\n', decision.investment.environmental_amount);
            fprintf('  价格调整: %.2f 元\n', decision.price);
        end
    end
end

%% 6. 可视化结果
fprintf('\n6. 生成可视化结果...\n');
generate_expectation_visualization(enterprises, simulation_results);

%% 7. 总结和政策建议
fprintf('\n7. 总结和政策建议...\n');
provide_policy_insights(enterprises, simulation_results);

fprintf('\n=== EER模型风格预期形成机制演示完成 ===\n');

%% ============= 辅助函数 =============

function market_data = generate_market_data(time_step, market_state, market_params)
    % 生成真实的市场数据（模拟市场的真实动态）
    
    market_data = struct();
    
    % 价格动态：趋势 + 周期 + 随机波动
    price_trend = market_state.base_price * (1 + market_params.price_trend)^time_step;
    price_cycle = sin(2 * pi * time_step / 12) * market_state.base_price * 0.1;
    price_noise = randn() * market_state.base_price * market_params.volatility;
    market_data.average_price = max(20, price_trend + price_cycle + price_noise);
    
    % 需求动态：增长趋势 + 季节性 + 随机冲击
    demand_trend = market_state.base_demand * (1 + market_params.demand_growth)^time_step;
    demand_seasonality = (1 + 0.3 * sin(2 * pi * time_step / 12 + pi/4)); % 秋季高峰
    demand_noise = randn() * market_state.base_demand * market_params.volatility;
    market_data.total_demand = max(100, demand_trend * demand_seasonality + demand_noise);
    
    % 投入成本动态
    input_price_base = 40;
    input_trend = input_price_base * (1 + market_params.price_trend * 0.8)^time_step;
    input_noise = randn() * input_price_base * market_params.volatility;
    market_data.input_prices = max(10, input_trend + input_noise);
    
    % 竞争强度动态：周期性变化
    competition_cycle = 0.3 * sin(2 * pi * time_step / market_params.competition_cycle);
    competition_noise = randn() * 0.05;
    market_data.competition_index = max(0.1, min(0.9, ...
        market_state.base_competition + competition_cycle + competition_noise));
    
    % 政策变量
    market_data.policy_rates = struct();
    
    % 排放税：可能有政策冲击
    if rand() < market_params.policy_shock_prob
        tax_shock = (rand() - 0.5) * 0.05; % ±2.5%的政策冲击
        market_state.current_emission_tax = max(0, min(0.3, ...
            market_state.current_emission_tax + tax_shock));
    end
    market_data.policy_rates.emission_tax = market_state.current_emission_tax;
    
    % 质量标准：缓慢上升趋势
    if mod(time_step, 12) == 0 % 每年可能调整
        if rand() < 0.3 % 30%概率调整
            standard_change = rand() * 0.05; % 最多提高5%
            market_state.current_quality_standard = min(0.9, ...
                market_state.current_quality_standard + standard_change);
        end
    end
    market_data.policy_rates.quality_standard = market_state.current_quality_standard;
    
    % 添加时间戳
    market_data.time_step = time_step;
end

function noisy_data = add_observation_noise(clean_data, noise_level)
    % 为市场数据添加观测噪声
    
    noisy_data = clean_data;
    
    % 为数值字段添加噪声
    if isfield(clean_data, 'average_price')
        noisy_data.average_price = clean_data.average_price * (1 + randn() * noise_level);
    end
    
    if isfield(clean_data, 'total_demand')
        noisy_data.total_demand = clean_data.total_demand * (1 + randn() * noise_level);
    end
    
    if isfield(clean_data, 'input_prices')
        noisy_data.input_prices = clean_data.input_prices * (1 + randn() * noise_level);
    end
    
    if isfield(clean_data, 'competition_index')
        noisy_data.competition_index = max(0.1, min(0.9, ...
            clean_data.competition_index + randn() * noise_level));
    end
end

function accuracy = evaluate_expectation_accuracy(enterprise, actual_market_data)
    % 评估企业预期的准确性
    
    key_vars = {'product_price', 'demand_quantity', 'input_cost', 'competition_intensity'};
    errors = [];
    
    for i = 1:length(key_vars)
        var_name = key_vars{i};
        
        expected_value = enterprise.get_expectation(var_name, 1);
        if isnan(expected_value)
            continue;
        end
        
        % 获取实际值
        actual_value = enterprise.get_actual_value(var_name, actual_market_data);
        if isnan(actual_value)
            continue;
        end
        
        % 计算相对误差
        relative_error = abs(expected_value - actual_value) / max(abs(actual_value), 1e-6);
        errors = [errors, relative_error];
    end
    
    if ~isempty(errors)
        accuracy = 1 / (1 + mean(errors)); % 准确性得分：0-1
    else
        accuracy = 0.5; % 默认中等准确性
    end
end

function new_state = update_market_state(current_state, market_data, enterprises)
    % 根据市场数据和企业行为更新市场状态
    
    new_state = current_state;
    
    % 基于企业决策调整基础价格和需求
    avg_enterprise_price = 0;
    avg_enterprise_production = 0;
    
    for i = 1:length(enterprises)
        enterprise = enterprises{i};
        avg_enterprise_price = avg_enterprise_price + enterprise.current_price;
        avg_enterprise_production = avg_enterprise_production + enterprise.current_production;
    end
    
    avg_enterprise_price = avg_enterprise_price / length(enterprises);
    avg_enterprise_production = avg_enterprise_production / length(enterprises);
    
    % 价格和需求的相互影响
    price_factor = avg_enterprise_price / new_state.base_price;
    if price_factor > 1.1
        new_state.base_demand = new_state.base_demand * 0.98; % 价格高抑制需求
    elseif price_factor < 0.9
        new_state.base_demand = new_state.base_demand * 1.02; % 价格低刺激需求
    end
    
    new_state.base_price = 0.9 * new_state.base_price + 0.1 * market_data.average_price;
end

function print_market_summary(market_data, enterprises)
    % 打印市场状态总结
    
    fprintf('市场数据：\n');
    fprintf('  平均价格: %.2f 元\n', market_data.average_price);
    fprintf('  总需求: %.0f 单位\n', market_data.total_demand);
    fprintf('  投入成本: %.2f 元\n', market_data.input_prices);
    fprintf('  竞争强度: %.3f\n', market_data.competition_index);
    fprintf('  排放税率: %.1f%%\n', market_data.policy_rates.emission_tax * 100);
    fprintf('  质量标准: %.3f\n', market_data.policy_rates.quality_standard);
    
    fprintf('\n企业状况：\n');
    for i = 1:length(enterprises)
        enterprise = enterprises{i};
        fprintf('  企业 %d (%s): 价格 %.2f, 产量 %.0f\n', ...
                i, enterprise.enterprise_type, enterprise.current_price, enterprise.current_production);
    end
end

function print_expectation_learning_progress(enterprises, current_time)
    % 打印预期学习进展
    
    fprintf('\n预期学习进展：\n');
    for i = 1:length(enterprises)
        enterprise = enterprises{i};
        summary = enterprise.get_expectation_summary();
        
        fprintf('  企业 %d (%s):\n', i, enterprise.enterprise_type);
        fprintf('    学习率: %.4f\n', enterprise.expectation_module.learning_rate);
        if ~isnan(summary.average_accuracy)
            fprintf('    平均预期准确性: %.3f\n', summary.average_accuracy);
        end
        
        % 显示主要变量的AR(1)参数
        main_vars = {'product_price', 'demand_quantity'};
        for j = 1:length(main_vars)
            var_name = main_vars{j};
            if ismember(var_name, enterprise.expectation_module.expectation_variables)
                coeffs = enterprise.expectation_module.ar_coefficients.(var_name);
                fprintf('    %s AR(1): α=%.3f, β=%.3f\n', var_name, coeffs(1), coeffs(2));
            end
        end
    end
end

function analyze_expectation_vs_actual(enterprises, market_data_history)
    % 分析预期与实际值的对比
    
    fprintf('预期vs实际值分析（最近12期）：\n');
    
    recent_periods = max(1, length(market_data_history) - 11):length(market_data_history);
    
    for i = 1:length(enterprises)
        enterprise = enterprises{i};
        fprintf('  企业 %d (%s):\n', i, enterprise.enterprise_type);
        
        % 分析价格预期
        price_errors = [];
        for t = recent_periods
            if t > 1
                expected_price = enterprise.get_expectation('product_price', 1);
                actual_price = market_data_history(t).average_price;
                if ~isnan(expected_price)
                    error = abs(expected_price - actual_price) / actual_price;
                    price_errors = [price_errors, error];
                end
            end
        end
        
        if ~isempty(price_errors)
            fprintf('    价格预期平均误差: %.2f%%\n', mean(price_errors) * 100);
        end
        
        % 分析需求预期
        demand_errors = [];
        for t = recent_periods
            if t > 1
                expected_demand = enterprise.get_expectation('demand_quantity', 1);
                actual_demand = market_data_history(t).total_demand;
                if ~isnan(expected_demand)
                    error = abs(expected_demand - actual_demand) / actual_demand;
                    demand_errors = [demand_errors, error];
                end
            end
        end
        
        if ~isempty(demand_errors)
            fprintf('    需求预期平均误差: %.2f%%\n', mean(demand_errors) * 100);
        end
    end
end

function conduct_learning_sensitivity_analysis(enterprises)
    % 进行学习参数敏感性分析
    
    fprintf('不同学习参数下的预期表现：\n');
    
    for i = 1:length(enterprises)
        enterprise = enterprises{i};
        current_lr = enterprise.expectation_module.learning_rate;
        current_memory = enterprise.expectation_module.memory_length;
        
        fprintf('  企业 %d 当前参数：\n', i);
        fprintf('    学习率: %.3f, 记忆长度: %d\n', current_lr, current_memory);
        
        % 分析不同学习率的影响
        lr_test_values = [0.05, 0.1, 0.15, 0.2];
        fprintf('    不同学习率下的学习速度评估：\n');
        for lr = lr_test_values
            % 模拟评估（简化版本）
            adaptation_speed = estimate_adaptation_speed(lr, current_memory);
            fprintf('      学习率 %.2f: 适应速度 %.3f\n', lr, adaptation_speed);
        end
    end
end

function adaptation_speed = estimate_adaptation_speed(learning_rate, memory_length)
    % 估计给定参数下的适应速度
    
    % 简化的适应速度模型
    base_speed = learning_rate * 2;
    memory_factor = 1 / (1 + memory_length / 12); % 记忆越长，适应越慢
    adaptation_speed = base_speed * (1 + memory_factor);
end

function generate_expectation_visualization(enterprises, simulation_results)
    % 生成预期相关的可视化图表
    
    fprintf('生成可视化图表：\n');
    
    % 创建图表显示预期准确性的时间序列
    figure('Name', 'Expectation Accuracy Over Time');
    
    periods = size(simulation_results.expectation_accuracy, 2);
    time_axis = 1:periods;
    
    for i = 1:length(enterprises)
        accuracy_series = simulation_results.expectation_accuracy(i, :);
        plot(time_axis, accuracy_series, 'LineWidth', 2, 'DisplayName', ...
             sprintf('Enterprise %d (%s)', i, enterprises{i}.enterprise_type));
        hold on;
    end
    
    xlabel('Time Period (months)');
    ylabel('Expectation Accuracy');
    title('Evolution of Expectation Accuracy');
    legend('show');
    grid on;
    
    fprintf('  - 预期准确性时间序列图已生成\n');
    
    % 创建AR(1)参数演化图
    figure('Name', 'AR(1) Parameter Evolution');
    
    for i = 1:length(enterprises)
        enterprise = enterprises{i};
        
        % 获取主要变量的参数历史
        if ismember('product_price', enterprise.expectation_module.expectation_variables)
            param_history = enterprise.expectation_module.learning_diagnostics.product_price.parameter_history;
            if ~isempty(param_history)
                subplot(2, 2, i);
                plot(param_history(:, 1), 'r-', 'DisplayName', 'α (intercept)');
                hold on;
                plot(param_history(:, 2), 'b-', 'DisplayName', 'β (AR coefficient)');
                xlabel('Update Steps');
                ylabel('Parameter Value');
                title(sprintf('Enterprise %d (%s) AR(1) Parameters', i, enterprise.enterprise_type));
                legend('show');
                grid on;
            end
        end
    end
    
    fprintf('  - AR(1)参数演化图已生成\n');
end

function provide_policy_insights(enterprises, simulation_results)
    % 基于仿真结果提供政策洞察
    
    fprintf('基于预期形成机制的政策洞察：\n\n');
    
    % 1. 学习能力分析
    fprintf('1. 智能体学习能力分析：\n');
    avg_final_accuracy = mean(simulation_results.expectation_accuracy(:, end-5:end), 'all');
    fprintf('   - 整体预期准确性：%.3f\n', avg_final_accuracy);
    
    if avg_final_accuracy > 0.7
        fprintf('   - 智能体展现出强的学习和适应能力\n');
        fprintf('   - 建议：政策可以采用渐进式调整，智能体能够适应\n');
    else
        fprintf('   - 智能体学习能力有限，需要更多时间适应\n');
        fprintf('   - 建议：政策变化应当更加谨慎，提供充分的过渡期\n');
    end
    
    % 2. 不同企业类型的适应性差异
    fprintf('\n2. 不同企业类型的适应性：\n');
    for i = 1:length(enterprises)
        enterprise = enterprises{i};
        type_accuracy = mean(simulation_results.expectation_accuracy(i, end-5:end));
        fprintf('   - %s企业：预期准确性 %.3f\n', enterprise.enterprise_type, type_accuracy);
    end
    
    % 3. 政策建议
    fprintf('\n3. 基于EER模型预期形成机制的政策建议：\n');
    fprintf('   a) 政策透明度：\n');
    fprintf('      - 提高政策信息的透明度和可预测性\n');
    fprintf('      - 智能体的AR(1)学习依赖于观测数据的质量\n');
    
    fprintf('   b) 政策调整频率：\n');
    fprintf('      - 避免过于频繁的政策调整\n');
    fprintf('      - 给智能体充分的学习和适应时间\n');
    
    fprintf('   c) 政策冲击管理：\n');
    fprintf('      - 重大政策变化应当提前预告\n');
    fprintf('      - 考虑分阶段实施，减少对智能体预期的冲击\n');
    
    fprintf('   d) 差异化政策：\n');
    fprintf('      - 不同类型企业的学习能力存在差异\n');
    fprintf('      - 可以考虑针对不同企业类型的差异化政策措施\n');
end 