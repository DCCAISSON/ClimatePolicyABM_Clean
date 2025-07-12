% 测试财政政策功能
% 基于23年EER论文的政府收入支出和家庭消费设定

clear; clc; close all;

fprintf('=== 财政政策功能测试 ===\n');

% 创建模型实例
model = MultiAgentClimatePolicyModel();

% 初始化模型
model.initialize_model();

fprintf('模型初始化完成\n');

% 测试政府财政政策
fprintf('\n--- 测试政府财政政策 ---\n');

% 检查政府预算结构
if isfield(model.government, 'budget')
    fprintf('✓ 政府预算结构已初始化\n');
    fprintf('  收入结构: %s\n', strjoin(fieldnames(model.government.budget.revenue), ', '));
    fprintf('  支出结构: %s\n', strjoin(fieldnames(model.government.budget.expenditure), ', '));
else
    fprintf('✗ 政府预算结构未初始化\n');
end

% 检查税率设置
if isfield(model.government, 'tax_rates')
    fprintf('✓ 税率设置已初始化\n');
    fprintf('  所得税率: %.1f%%\n', model.government.tax_rates.income_tax * 100);
    fprintf('  企业所得税率: %.1f%%\n', model.government.tax_rates.corporate_tax * 100);
    fprintf('  消费税率: %.1f%%\n', model.government.tax_rates.consumption_tax * 100);
else
    fprintf('✗ 税率设置未初始化\n');
end

% 检查政府消费系数
if isfield(model.government, 'consumption_coefficients')
    fprintf('✓ 政府消费系数已初始化\n');
    fprintf('  食品消费系数: %.2f\n', model.government.consumption_coefficients.food);
    fprintf('  教育消费系数: %.2f\n', model.government.consumption_coefficients.education);
    fprintf('  医疗消费系数: %.2f\n', model.government.consumption_coefficients.health);
else
    fprintf('✗ 政府消费系数未初始化\n');
end

% 测试农户消费行为
fprintf('\n--- 测试农户消费行为 ---\n');

% 检查农户消费结构
sample_household = model.households{1};
if isfield(sample_household, 'consumption')
    fprintf('✓ 农户消费结构已初始化\n');
    fprintf('  食品消费: %.2f\n', sample_household.consumption.food);
    fprintf('  服装消费: %.2f\n', sample_household.consumption.clothing);
    fprintf('  住房消费: %.2f\n', sample_household.consumption.housing);
else
    fprintf('✗ 农户消费结构未初始化\n');
end

% 测试消费预算计算
expected_income = sample_household.calculate_expected_disposable_income();
fprintf('预期可支配净收入: %.2f\n', expected_income);

consumption_budget = sample_household.calculate_consumption_budget(expected_income);
fprintf('消费预算: %.2f\n', consumption_budget);

% 测试消费系数计算
coefficients = sample_household.calculate_household_consumption_coefficients();
fprintf('消费系数: [%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f]\n', coefficients);

% 运行短期仿真测试
fprintf('\n--- 运行短期仿真测试 ---\n');

% 设置仿真参数
model.simulation_params.max_steps = 10;
model.simulation_params.convergence_threshold = 0.01;

% 运行仿真
try
    model.run_simulation();
    fprintf('✓ 仿真运行成功\n');
    
    % 检查结果
    if ~isempty(model.results.time_series)
        final_state = model.results.time_series(end);
        fprintf('最终状态:\n');
        fprintf('  农户数量: %d\n', final_state.households.total_count);
        fprintf('  平均收入: %.2f\n', final_state.households.mean_income);
        fprintf('  政府收入: %.2f\n', final_state.government.fiscal_revenue);
        fprintf('  政府支出: %.2f\n', final_state.government.fiscal_expenditure);
        fprintf('  财政余额: %.2f\n', final_state.government.fiscal_balance);
        
        % 检查商品市场
        if isfield(final_state, 'commodity_market')
            fprintf('  消费者剩余: %.2f\n', final_state.commodity_market.consumer_surplus);
            fprintf('  生产者剩余: %.2f\n', final_state.commodity_market.producer_surplus);
            fprintf('  社会福利: %.2f\n', final_state.commodity_market.social_welfare);
        end
    else
        fprintf('✗ 仿真结果为空\n');
    end
    
catch ME
    fprintf('✗ 仿真运行失败: %s\n', ME.message);
    fprintf('错误位置: %s\n', ME.stack(1).name);
end

% 测试财政历史记录
fprintf('\n--- 测试财政历史记录 ---\n');

if isfield(model.government, 'fiscal_history') && ~isempty(model.government.fiscal_history)
    fprintf('✓ 财政历史记录功能正常\n');
    fprintf('记录数量: %d\n', length(model.government.fiscal_history));
    
    % 显示最新的财政记录
    latest_fiscal = model.government.fiscal_history(end);
    fprintf('最新财政记录:\n');
    fprintf('  时间: %d\n', latest_fiscal.time);
    fprintf('  总收入: %.2f\n', latest_fiscal.revenue.total);
    fprintf('  总支出: %.2f\n', latest_fiscal.expenditure.total);
    fprintf('  财政余额: %.2f\n', latest_fiscal.balance);
else
    fprintf('✗ 财政历史记录功能异常\n');
end

% 生成结果报告
fprintf('\n--- 生成结果报告 ---\n');
model.generate_results_report();

fprintf('\n=== 财政政策功能测试完成 ===\n');

% 保存测试结果
save('fiscal_policy_test_results.mat', 'model');
fprintf('测试结果已保存到 fiscal_policy_test_results.mat\n'); 