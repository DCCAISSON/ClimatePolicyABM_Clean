%% 快速参数校准脚本
clear; clc; close all;
fprintf('=== 快速参数校准 ===\n');

%% === 数据源路径设置 ===
if exist('input_data_file','var') && ~isempty(input_data_file)
    cfps_file = input_data_file;
else
    cfps_file = 'CFPS2010-2022清洗好数据/2010-2022CFPS非平衡面板数据.xlsx';
end
year_range = [2010, 2022];
if exist('output_prefix','var') && ~isempty(output_prefix)
    prefix = output_prefix;
else
    prefix = '';
end

%% 1. 读取CFPS数据
fprintf('1. 读取CFPS数据...\n');

try
    [cfps_data, data_summary] = cfps_data_interface(cfps_file, year_range);
    fprintf('CFPS数据处理完成，共 %d 个观测\n', data_summary.total_observations);
catch ME
    fprintf('CFPS数据读取失败: %s\n', ME.message);
    return;
end

%% 2. 提取校准目标
fprintf('2. 提取校准目标...\n');
calibration_targets = extract_calibration_targets_from_cfps(cfps_data);

%% 3. 定义参数边界
fprintf('3. 定义参数边界...\n');
param_bounds = define_parameter_bounds();

%% 4. 简化的参数校准
fprintf('4. 开始简化参数校准...\n');

% 使用网格搜索进行简化校准
best_params = simplified_calibration(cfps_data, calibration_targets, param_bounds);

%% 5. 保存结果
fprintf('5. 保存校准结果...\n');
save([prefix 'calibrated_parameters.mat'], 'best_params', 'calibration_targets', 'cfps_data');
generate_calibration_report(best_params, calibration_targets, prefix);

fprintf('校准完成！结果已保存\n');

%% 6. 运行政策实验
fprintf('6. 运行政策实验...\n');
run_policy_experiments(best_params, cfps_data, prefix);

%% 辅助函数
function calibration_targets = extract_calibration_targets_from_cfps(cfps_data)
calibration_targets = [];

% 收入分布
if isfield(cfps_data, 'total_income')
    income_data = cfps_data.total_income(~isnan(cfps_data.total_income));
    gini = calculate_gini(income_data);
    calibration_targets = [calibration_targets, struct('type', 'income_distribution', 'value', gini)];
    fprintf('收入基尼系数: %.3f\n', gini);
end

% 就业率
if isfield(cfps_data, 'employment_status')
    emp_rate = mean(cfps_data.employment_status(~isnan(cfps_data.employment_status)));
    calibration_targets = [calibration_targets, struct('type', 'employment_rate', 'value', emp_rate)];
    fprintf('就业率: %.3f\n', emp_rate);
end

% 土地流转率
if isfield(cfps_data, 'land_transfer_status')
    land_rate = mean(cfps_data.land_transfer_status(~isnan(cfps_data.land_transfer_status)));
    calibration_targets = [calibration_targets, struct('type', 'land_transfer_rate', 'value', land_rate)];
    fprintf('土地流转率: %.3f\n', land_rate);
end

% 合作社渗透率
if isfield(cfps_data, 'cooperative_membership')
    coop_rate = mean(cfps_data.cooperative_membership(~isnan(cfps_data.cooperative_membership)));
    calibration_targets = [calibration_targets, struct('type', 'cooperative_penetration', 'value', coop_rate)];
    fprintf('合作社渗透率: %.3f\n', coop_rate);
end
end

function gini = calculate_gini(income_data)
n = length(income_data);
if n == 0
    gini = 0;
    return;
end

sorted_income = sort(income_data);
cumulative_income = cumsum(sorted_income);
total_income = cumulative_income(end);

if total_income == 0
    gini = 0;
    return;
end

gini = (n + 1 - 2 * sum((1:n) .* sorted_income') / total_income) / n;
end

function param_bounds = define_parameter_bounds()
param_bounds = struct();

% 经济参数
param_bounds.subsidy_rate = struct('lb', 0.01, 'ub', 0.3);
param_bounds.tax_rate = struct('lb', 0.05, 'ub', 0.25);
param_bounds.credit_availability = struct('lb', 0.1, 'ub', 0.8);

% 生产参数
param_bounds.labor_productivity = struct('lb', 0.5, 'ub', 2.0);
param_bounds.land_productivity = struct('lb', 0.3, 'ub', 1.5);

% 合作社参数
param_bounds.cooperative_effectiveness = struct('lb', 0.1, 'ub', 0.9);
param_bounds.cooperative_cost = struct('lb', 0.01, 'ub', 0.2);

% 土地流转参数
param_bounds.land_transfer_cost = struct('lb', 0.01, 'ub', 0.3);
param_bounds.land_transfer_benefit = struct('lb', 0.05, 'ub', 0.4);

% 健康营养参数
param_bounds.health_productivity_factor = struct('lb', 0.5, 'ub', 1.5);
param_bounds.nutrition_effect = struct('lb', 0.1, 'ub', 0.5);

% 学习参数
param_bounds.learning_rate = struct('lb', 0.01, 'ub', 0.2);
param_bounds.adaptation_speed = struct('lb', 0.05, 'ub', 0.3);
end

function best_params = simplified_calibration(cfps_data, calibration_targets, param_bounds)
% 简化的参数校准（网格搜索）
fprintf('使用简化校准方法...\n');

% 定义参数网格
param_names = fieldnames(param_bounds);
n_params = length(param_names);

% 为每个参数定义几个候选值
param_candidates = struct();
for i = 1:n_params
    param_name = param_names{i};
    lb = param_bounds.(param_name).lb;
    ub = param_bounds.(param_name).ub;
    param_candidates.(param_name) = linspace(lb, ub, 5); % 5个候选值
end

% 网格搜索
best_fitness = inf;
best_params = struct();

% 随机采样参数组合
n_iterations = 100;
for iter = 1:n_iterations
    % 随机选择参数值
    params = struct();
    for i = 1:n_params
        param_name = param_names{i};
        candidates = param_candidates.(param_name);
        params.(param_name) = candidates(randi(length(candidates)));
    end
    
    % 计算适应度
    fitness = calculate_fitness(params, cfps_data, calibration_targets);
    
    if fitness < best_fitness
        best_fitness = fitness;
        best_params = params;
        fprintf('迭代 %d: 找到更好的参数，适应度 = %.4f\n', iter, fitness);
    end
end

fprintf('最佳适应度: %.4f\n', best_fitness);
end

function fitness = calculate_fitness(params, cfps_data, calibration_targets)
% 计算参数适应度
fitness = 0;

% 运行模型
model_results = run_model_with_params(params, cfps_data);

% 计算与目标的差异
for i = 1:length(calibration_targets)
    target = calibration_targets(i);
    model_value = get_model_value(model_results, target.type);
    target_value = target.value;
    
    % 相对误差
    if target_value > 0
        relative_error = abs(model_value - target_value) / target_value;
    else
        relative_error = abs(model_value - target_value);
    end
    
    fitness = fitness + relative_error;
end

fitness = fitness / length(calibration_targets); % 平均相对误差
end

function model_value = get_model_value(results, target_type)
% 从模型结果中提取目标值
switch target_type
    case 'income_distribution'
        model_value = calculate_gini(results.income_distribution);
    case 'employment_rate'
        model_value = mean(results.employment_status);
    case 'land_transfer_rate'
        model_value = mean(results.land_transfer_status);
    case 'cooperative_penetration'
        model_value = mean(results.cooperative_membership);
    otherwise
        model_value = 0;
end
end

function generate_calibration_report(best_params, calibration_targets, prefix)
if nargin < 3, prefix = ''; end
report_file = sprintf('%scalibration_report_%s.txt', prefix, datestr(now, 'yyyy-mm-dd_HH-MM-SS'));
fid = fopen(report_file, 'w');

fprintf(fid, '=== CAR-ABM模型参数校准报告 ===\n');
fprintf(fid, '校准时间: %s\n', datestr(now));
fprintf(fid, '\n');

% 最优参数
fprintf(fid, '--- 最优参数 ---\n');
param_names = fieldnames(best_params);
for i = 1:length(param_names)
    param_name = param_names{i};
    param_value = best_params.(param_name);
    fprintf(fid, '%s: %.6f\n', param_name, param_value);
end

% 校准目标
fprintf(fid, '\n--- 校准目标 ---\n');
for i = 1:length(calibration_targets)
    target = calibration_targets(i);
    fprintf(fid, '%s: %.4f\n', target.type, target.value);
end

fclose(fid);
fprintf('校准报告已保存至: %s\n', report_file);
end

function run_policy_experiments(best_params, cfps_data, prefix)
if nargin < 3, prefix = ''; end
fprintf('开始政策实验...\n');

experiment_config = struct();
experiment_config.experiment_type = 'counterfactual_analysis';
experiment_config.random_seed = 12345;

[experiment_results, policy_analysis] = policy_experiment_design(best_params, cfps_data, experiment_config);

save([prefix 'policy_experiment_results.mat'], 'experiment_results', 'policy_analysis');

fprintf('政策实验完成！结果已保存\n');
end 