%% 农业ABM模型主运行脚本
% 完整的模型运行和仿真模拟流程
% 支持多种运行模式和实验设计

clear; clc; close all;

%% 0. 修复随机数生成器问题
fprintf('=== 农业ABM模型主运行脚本 ===\n');
fprintf('正在初始化随机数生成器...\n');

% 修复随机数生成器问题
try
    rng('default');
    rng(12345, 'twister');
    fprintf('随机数生成器初始化成功\n');
catch
    fprintf('警告：随机数生成器初始化失败，使用默认设置\n');
end

%% 1. 运行模式选择
fprintf('\n请选择运行模式:\n');
fprintf('1. 基础运行 - 标准仿真\n');
fprintf('2. 增强运行 - 包含所有高级模块\n');
fprintf('3. 气候变化研究 - 专门的气候影响分析\n');
fprintf('4. 政策实验 - 政策效果评估\n');
fprintf('5. 敏感性分析 - 参数敏感性测试\n');
fprintf('6. 蒙特卡洛模拟 - 随机性分析\n');
fprintf('7. 批量实验 - 多情景对比\n');
fprintf('8. 自定义运行 - 用户自定义配置\n');

run_mode = input('请输入运行模式 (1-8): ');

%% 2. 根据运行模式执行相应流程
switch run_mode
    case 1
        fprintf('\n=== 执行基础运行模式 ===\n');
        run_basic_simulation();
        
    case 2
        fprintf('\n=== 执行增强运行模式 ===\n');
        [results, params] = run_enhanced_simulation();
        
    case 3
        fprintf('\n=== 执行气候变化研究模式 ===\n');
        [results, params] = run_climate_change_research();
        
    case 4
        fprintf('\n=== 执行政策实验模式 ===\n');
        [results, params] = run_policy_experiments();
        
    case 5
        fprintf('\n=== 执行敏感性分析模式 ===\n');
        [results, params] = run_sensitivity_analysis();
        
    case 6
        fprintf('\n=== 执行蒙特卡洛模拟模式 ===\n');
        [results, params] = run_monte_carlo_simulation();
        
    case 7
        fprintf('\n=== 执行批量实验模式 ===\n');
        [results, params] = run_batch_experiments();
        
    case 8
        fprintf('\n=== 执行自定义运行模式 ===\n');
        [results, params] = run_custom_simulation();
        
    otherwise
        error('无效的运行模式选择');
end

%% 3. 结果处理和可视化
fprintf('\n=== 处理结果和生成可视化 ===\n');
try
    process_and_visualize_results(results, params, run_mode);
catch ME
    fprintf('可视化处理出错: %s\n', ME.message);
    fprintf('跳过可视化，继续保存结果...\n');
end

%% 4. 保存结果
fprintf('\n=== 保存结果 ===\n');
save_simulation_results(results, params, run_mode);

fprintf('\n=== 仿真完成 ===\n');

%% 辅助函数

function run_basic_simulation()
% 基础仿真运行函数
fprintf('=== 执行基础运行模式 ===\n');

% 使用简化的参数配置
params = params_simple();

% 运行仿真
[results] = agri_abm_enhanced(params);

% 显示结果摘要
fprintf('\n=== 仿真结果摘要 ===\n');
fprintf('最终GDP: %.2f\n', results.history.gdp(end));
fprintf('最终就业率: %.3f\n', results.history.employment(end));
fprintf('最终平均收入: %.2f\n', results.history.income(end));
fprintf('最终不平等指数: %.3f\n', results.history.inequality(end));
fprintf('最终土地流转率: %.3f\n', results.history.land_transfer_rate(end));
fprintf('最终创新率: %.3f\n', results.history.innovation_rate(end));

% 绘制结果
figure('Name', '基础仿真结果', 'Position', [100, 100, 1200, 800]);

% GDP时间序列
subplot(2, 3, 1);
plot(results.history.gdp, 'b-', 'LineWidth', 2);
title('GDP时间序列');
xlabel('时间步');
ylabel('GDP');
grid on;

% 就业率时间序列
subplot(2, 3, 2);
plot(results.history.employment, 'g-', 'LineWidth', 2);
title('就业率时间序列');
xlabel('时间步');
ylabel('就业率');
grid on;

% 平均收入时间序列
subplot(2, 3, 3);
plot(results.history.income, 'r-', 'LineWidth', 2);
title('平均收入时间序列');
xlabel('时间步');
ylabel('平均收入');
grid on;

% 不平等指数时间序列
subplot(2, 3, 4);
plot(results.history.inequality, 'm-', 'LineWidth', 2);
title('不平等指数时间序列');
xlabel('时间步');
ylabel('不平等指数');
grid on;

% 土地流转率时间序列
subplot(2, 3, 5);
plot(results.history.land_transfer_rate, 'c-', 'LineWidth', 2);
title('土地流转率时间序列');
xlabel('时间步');
ylabel('土地流转率');
grid on;

% 创新率时间序列
subplot(2, 3, 6);
plot(results.history.innovation_rate, 'y-', 'LineWidth', 2);
title('创新率时间序列');
xlabel('时间步');
ylabel('创新率');
grid on;

% 保存结果
save('basic_simulation_results.mat', 'results', 'params');
fprintf('结果已保存到 basic_simulation_results.mat\n');

% 返回结果供主脚本使用
assignin('base', 'results', results);
assignin('base', 'params', params);

end

function [results, params] = run_enhanced_simulation()
% 增强运行模式 - 包含所有高级模块

% 加载增强参数
params = params_enhanced();

% 启用所有高级功能
params.behavioral_economics.enable = true;
params.network_effects.enable = true;
params.policy.enable = true;
params.environment.enable = true;
params.market.enable = true;

% 运行增强模型
[results] = agri_abm_enhanced(params);

end

function [results, params] = run_climate_change_research()
% 气候变化研究模式

% 加载气候变化参数
params = params_climate_change();

% 运行气候变化研究
fprintf('执行综合气候变化分析...\n');

% 运行基础仿真
[results] = agri_abm_enhanced(params);

% 添加气候变化特定分析
results.climate_analysis = struct();
results.climate_analysis.adaptation_effectiveness = mean(results.history.learning_effectiveness);
results.climate_analysis.resilience_index = 1 - mean(results.history.environmental_impact);

% 计算气候变化相关指标
results.climate_analysis.gdp_volatility = std(results.history.gdp) / mean(results.history.gdp);
results.climate_analysis.income_volatility = std(results.history.income) / mean(results.history.income);
results.climate_analysis.adaptation_rate = mean(results.history.learning_effectiveness) / max(results.history.learning_effectiveness);

fprintf('气候变化分析完成\n');

end

function [results, params] = run_policy_experiments()
% 政策实验模式

% 加载基础参数
params = params_enhanced();

% 设置政策实验参数
policy_scenarios = {'baseline', 'high_subsidy', 'low_subsidy', 'tax_incentive', 'regulation'};
results = struct();

for i = 1:length(policy_scenarios)
    fprintf('运行政策情景: %s\n', policy_scenarios{i});
    
    % 调整政策参数
    params = adjust_policy_parameters(params, policy_scenarios{i});
    
    % 运行仿真
    [temp_results] = agri_abm_enhanced(params);
    
    % 存储结果
    results.(policy_scenarios{i}) = temp_results;
end

end

function [results, params] = run_sensitivity_analysis()
% 敏感性分析模式

% 加载基础参数
params = params_enhanced();

% 定义敏感性分析参数
sensitivity_params = {'production_elasticity', 'learning_rate', 'risk_aversion', 'network_density'};
param_ranges = {[0.1, 0.9], [0.01, 0.1], [0.1, 0.9], [0.1, 0.9]};

results = struct();

for i = 1:length(sensitivity_params)
    fprintf('分析参数敏感性: %s\n', sensitivity_params{i});
    
    param_name = sensitivity_params{i};
    param_range = param_ranges{i};
    
    % 生成参数值序列
    param_values = linspace(param_range(1), param_range(2), 10);
    sensitivity_results = [];
    
    for j = 1:length(param_values)
        % 设置参数值
        params = set_parameter_value(params, param_name, param_values(j));
        
        % 运行仿真
        [temp_results] = agri_abm_enhanced(params);
        
        % 记录关键指标
        sensitivity_results(j).param_value = param_values(j);
        sensitivity_results(j).gdp_growth = (temp_results.history.gdp(end) - temp_results.history.gdp(1)) / temp_results.history.gdp(1);
        sensitivity_results(j).income_growth = (temp_results.history.income(end) - temp_results.history.income(1)) / temp_results.history.income(1);
    end
    
    results.(param_name) = sensitivity_results;
end

end

function [results, params] = run_monte_carlo_simulation()
% 蒙特卡洛模拟模式

% 加载基础参数
params = params_enhanced();

% 设置蒙特卡洛参数
n_simulations = 50;
results = struct();

fprintf('执行蒙特卡洛模拟，总次数: %d\n', n_simulations);

for i = 1:n_simulations
    fprintf('运行第 %d/%d 次模拟\n', i, n_simulations);
    
    % 随机化参数
    params = randomize_parameters(params);
    
    % 运行仿真
    [temp_results] = agri_abm_enhanced(params);
    
    % 记录关键指标
    results.simulations(i).gdp_growth = (temp_results.history.gdp(end) - temp_results.history.gdp(1)) / temp_results.history.gdp(1);
    results.simulations(i).income_growth = (temp_results.history.income(end) - temp_results.history.income(1)) / temp_results.history.income(1);
    results.simulations(i).employment_change = temp_results.history.employment(end) - temp_results.history.employment(1);
    results.simulations(i).productivity_growth = (temp_results.history.productivity(end) - temp_results.history.productivity(1)) / temp_results.history.productivity(1);
end

% 计算统计指标
results.statistics.mean_gdp_growth = mean([results.simulations.gdp_growth]);
results.statistics.std_gdp_growth = std([results.simulations.gdp_growth]);
results.statistics.mean_income_growth = mean([results.simulations.income_growth]);
results.statistics.std_income_growth = std([results.simulations.income_growth]);

end

function [results, params] = run_batch_experiments()
% 批量实验模式

% 加载基础参数
params = params_enhanced();

% 定义实验情景
experiments = {
    'baseline', '标准情景';
    'high_innovation', '高创新情景';
    'low_innovation', '低创新情景';
    'high_climate_impact', '高气候影响情景';
    'low_climate_impact', '低气候影响情景';
    'high_policy_support', '高政策支持情景';
    'low_policy_support', '低政策支持情景';
};

results = struct();

for i = 1:size(experiments, 1)
    experiment_name = experiments{i, 1};
    experiment_desc = experiments{i, 2};
    
    fprintf('运行实验: %s (%s)\n', experiment_desc, experiment_name);
    
    % 设置实验参数
    params = set_experiment_parameters(params, experiment_name);
    
    % 运行仿真
    [temp_results] = agri_abm_enhanced(params);
    
    % 存储结果
    results.(experiment_name) = temp_results;
    results.(experiment_name).description = experiment_desc;
end

end

function [results, params] = run_custom_simulation()
% 自定义运行模式

fprintf('请输入自定义参数:\n');

% 时间步数
time_steps = input('时间步数 (默认100): ');
if isempty(time_steps)
    time_steps = 100;
end

% 智能体数量
num_agents = input('智能体数量 (默认100): ');
if isempty(num_agents)
    num_agents = 100;
end

% 是否启用高级功能
enable_advanced = input('是否启用高级功能 (1=是, 0=否, 默认1): ');
if isempty(enable_advanced)
    enable_advanced = 1;
end

% 加载参数
params = params_enhanced();

% 设置自定义参数
params.simulation.time_steps = time_steps;
params.simulation.num_agents = num_agents;
params.behavioral_economics.enable = enable_advanced;
params.network_effects.enable = enable_advanced;
params.policy_evaluation.enable = enable_advanced;

% 运行仿真
[results] = agri_abm_enhanced(params);

end

function process_and_visualize_results(results, params, run_mode)
% 处理和可视化结果

fprintf('\n=== 处理结果和生成可视化 ===\n');

% 检查结果是否有效
if ~isfield(results, 'history') || isempty(results.history)
    fprintf('警告：结果数据为空或无效\n');
    return;
end

% 创建图形窗口
figure('Name', '农业ABM仿真结果', 'Position', [100, 100, 1400, 900]);

% 获取时间序列
time_steps = 1:length(results.history.gdp);

% 1. GDP时间序列
subplot(3, 3, 1);
plot(time_steps, results.history.gdp, 'b-', 'LineWidth', 2);
title('GDP时间序列');
xlabel('时间步');
ylabel('GDP');
grid on;

% 2. 就业率时间序列
subplot(3, 3, 2);
plot(time_steps, results.history.employment, 'g-', 'LineWidth', 2);
title('就业率时间序列');
xlabel('时间步');
ylabel('就业率');
grid on;

% 3. 平均收入时间序列
subplot(3, 3, 3);
plot(time_steps, results.history.income, 'r-', 'LineWidth', 2);
title('平均收入时间序列');
xlabel('时间步');
ylabel('平均收入');
grid on;

% 4. 不平等指数时间序列
subplot(3, 3, 4);
plot(time_steps, results.history.inequality, 'm-', 'LineWidth', 2);
title('不平等指数时间序列');
xlabel('时间步');
ylabel('不平等指数');
grid on;

% 5. 土地流转率时间序列
subplot(3, 3, 5);
plot(time_steps, results.history.land_transfer_rate, 'c-', 'LineWidth', 2);
title('土地流转率时间序列');
xlabel('时间步');
ylabel('土地流转率');
grid on;

% 6. 创新率时间序列
subplot(3, 3, 6);
plot(time_steps, results.history.innovation_rate, 'y-', 'LineWidth', 2);
title('创新率时间序列');
xlabel('时间步');
ylabel('创新率');
grid on;

% 7. 学习有效性时间序列
subplot(3, 3, 7);
plot(time_steps, results.history.learning_effectiveness, 'k-', 'LineWidth', 2);
title('学习有效性时间序列');
xlabel('时间步');
ylabel('学习有效性');
grid on;

% 8. 平均学习率时间序列
subplot(3, 3, 8);
plot(time_steps, results.history.avg_learning_rate, 'b--', 'LineWidth', 2);
title('平均学习率时间序列');
xlabel('时间步');
ylabel('平均学习率');
grid on;

% 9. 平均探索率时间序列
subplot(3, 3, 9);
plot(time_steps, results.history.avg_exploration_rate, 'g--', 'LineWidth', 2);
title('平均探索率时间序列');
xlabel('时间步');
ylabel('平均探索率');
grid on;

% 保存图形
saveas(gcf, 'simulation_results.png');
fprintf('结果图表已保存为 simulation_results.png\n');

% 生成结果摘要
fprintf('\n=== 仿真结果摘要 ===\n');
fprintf('初始GDP: %.2f\n', results.history.gdp(1));
fprintf('最终GDP: %.2f\n', results.history.gdp(end));
fprintf('GDP增长率: %.2f%%\n', (results.history.gdp(end) - results.history.gdp(1)) / results.history.gdp(1) * 100);
fprintf('最终就业率: %.3f\n', results.history.employment(end));
fprintf('最终平均收入: %.2f\n', results.history.income(end));
fprintf('最终不平等指数: %.3f\n', results.history.inequality(end));
fprintf('最终土地流转率: %.3f\n', results.history.land_transfer_rate(end));
fprintf('最终创新率: %.3f\n', results.history.innovation_rate(end));

end

function save_simulation_results(results, params, run_mode)
% 保存仿真结果

% 生成时间戳
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');

% 根据运行模式生成文件名
switch run_mode
    case 1
        filename = sprintf('basic_simulation_%s.mat', timestamp);
    case 2
        filename = sprintf('enhanced_simulation_%s.mat', timestamp);
    case 3
        filename = sprintf('climate_research_%s.mat', timestamp);
    case 4
        filename = sprintf('policy_experiments_%s.mat', timestamp);
    case 5
        filename = sprintf('sensitivity_analysis_%s.mat', timestamp);
    case 6
        filename = sprintf('monte_carlo_%s.mat', timestamp);
    case 7
        filename = sprintf('batch_experiments_%s.mat', timestamp);
    case 8
        filename = sprintf('custom_simulation_%s.mat', timestamp);
end

% 保存结果
save(filename, 'results', 'params', 'run_mode', 'timestamp');

fprintf('结果已保存到: %s\n', filename);

% 生成结果报告
generate_results_report(results, params, run_mode, filename);

end

function generate_results_report(results, params, run_mode, filename)
% 生成结果报告

% 创建报告文件名
[~, name, ~] = fileparts(filename);
report_filename = sprintf('%s_report.txt', name);

% 打开文件写入
fid = fopen(report_filename, 'w');

% 写入报告标题
fprintf(fid, '=== 农业ABM模型仿真结果报告 ===\n\n');
fprintf(fid, '运行时间: %s\n', datestr(now));
fprintf(fid, '运行模式: %d\n', run_mode);
fprintf(fid, '结果文件: %s\n\n', filename);

% 根据运行模式写入相应内容
switch run_mode
    case {1, 2, 8}  % 基础、增强、自定义运行
        write_basic_report(fid, results, params);
        
    case 3  % 气候变化研究
        write_climate_report(fid, results, params);
        
    case 4  % 政策实验
        write_policy_report(fid, results, params);
        
    case 5  % 敏感性分析
        write_sensitivity_report(fid, results, params);
        
    case 6  % 蒙特卡洛模拟
        write_monte_carlo_report(fid, results, params);
        
    case 7  % 批量实验
        write_batch_report(fid, results, params);
end

% 关闭文件
fclose(fid);

fprintf('结果报告已生成: %s\n', report_filename);

end

% 其他辅助函数（简化实现）
function params = adjust_policy_parameters(params, scenario)
% 调整政策参数
switch scenario
    case 'high_subsidy'
        params.policy.subsidy_rate = 0.2;
    case 'low_subsidy'
        params.policy.subsidy_rate = 0.05;
    case 'tax_incentive'
        params.government.tax_rate_firm = 0.1;
        params.government.tax_rate_farmer = 0.02;
    case 'regulation'
        params.policy.regulation_strength = 0.8;
end
end

function params = set_parameter_value(params, param_name, value)
% 设置参数值
if contains(param_name, 'production_elasticity')
    params.production.elasticity = value;
elseif contains(param_name, 'learning_rate')
    params.learning.rate = value;
elseif contains(param_name, 'risk_aversion')
    params.behavioral_economics.risk_aversion = value;
elseif contains(param_name, 'network_density')
    params.network_effects.density = value;
end
end

function params = randomize_parameters(params)
% 随机化参数
params.production.elasticity = 0.3 + rand() * 0.4;
params.learning.rate = 0.02 + rand() * 0.06;
params.behavioral_economics.risk_aversion = 0.3 + rand() * 0.4;
params.network_effects.density = 0.2 + rand() * 0.6;
end

function params = set_experiment_parameters(params, experiment_name)
% 设置实验参数
switch experiment_name
    case 'high_innovation'
        params.innovation.base_rate = 0.8;
    case 'low_innovation'
        params.innovation.base_rate = 0.2;
    case 'high_climate_impact'
        params.environment.climate_change_rate = 0.05;
    case 'low_climate_impact'
        params.environment.climate_change_rate = 0.01;
    case 'high_policy_support'
        params.policy.subsidy_rate = 0.3;
    case 'low_policy_support'
        params.policy.subsidy_rate = 0.05;
end
end

% 报告写入函数（简化实现）
function write_basic_report(fid, results, params)
fprintf(fid, '基础仿真结果:\n');
fprintf(fid, '最终GDP: %.2f\n', results.history.gdp(end));
fprintf(fid, '最终就业率: %.3f\n', results.history.employment(end));
fprintf(fid, '最终平均收入: %.2f\n', results.history.income(end));
fprintf(fid, '最终不平等指数: %.3f\n', results.history.inequality(end));
fprintf(fid, '最终土地流转率: %.3f\n', results.history.land_transfer_rate(end));
fprintf(fid, '最终创新率: %.3f\n', results.history.innovation_rate(end));
end

function write_climate_report(fid, results, params)
fprintf(fid, '气候变化研究结果:\n');
% 添加气候变化相关结果
end

function write_policy_report(fid, results, params)
fprintf(fid, '政策实验结果:\n');
% 添加政策实验相关结果
end

function write_sensitivity_report(fid, results, params)
fprintf(fid, '敏感性分析结果:\n');
% 添加敏感性分析相关结果
end

function write_monte_carlo_report(fid, results, params)
fprintf(fid, '蒙特卡洛模拟结果:\n');
fprintf(fid, 'GDP增长均值: %.2f%%\n', results.statistics.mean_gdp_growth * 100);
fprintf(fid, 'GDP增长标准差: %.2f%%\n', results.statistics.std_gdp_growth * 100);
end

function write_batch_report(fid, results, params)
fprintf(fid, '批量实验结果:\n');
% 添加批量实验相关结果
end 