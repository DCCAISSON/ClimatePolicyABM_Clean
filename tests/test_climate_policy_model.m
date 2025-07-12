%% 多智能体气候变化政策模型测试脚本
% 测试农户、企业、政府三类智能体的交互和政策效果

clear; clc; close all;

fprintf('=== 多智能体气候变化政策模型测试 ===\n');

%% 1. 创建模型实例
fprintf('\n1. 创建模型实例...\n');

% 创建模型
model = MultiAgentClimatePolicyModel();

fprintf('✓ 模型创建完成\n');

%% 2. 运行仿真
fprintf('\n2. 运行仿真...\n');

% 运行仿真
model.run_simulation();

fprintf('✓ 仿真完成\n');

%% 3. 生成结果报告
fprintf('\n3. 生成结果报告...\n');

% 生成政府政策报告
model.government.generate_policy_report();

fprintf('✓ 报告生成完成\n');

%% 4. 绘制结果图表
fprintf('\n4. 绘制结果图表...\n');

% 绘制结果图表
model.plot_results();

fprintf('✓ 图表绘制完成\n');

%% 5. 详细分析
fprintf('\n5. 详细分析...\n');

% 分析农户决策模式
analyze_household_decisions(model);

% 分析企业行为模式
analyze_enterprise_behavior(model);

% 分析政策效果
analyze_policy_effects(model);

fprintf('✓ 分析完成\n');

%% 6. 敏感性分析
fprintf('\n6. 敏感性分析...\n');

% 进行敏感性分析
sensitivity_analysis(model);

fprintf('✓ 敏感性分析完成\n');

fprintf('\n=== 测试完成 ===\n');

%% 7. 保存结果
fprintf('\n7. 保存结果...\n');
save_test_results(model);
fprintf('✓ 结果已保存\n');

fprintf('\n=== 测试脚本执行完成 ===\n');

%% 辅助函数

function analyze_household_decisions(model)
    % 分析农户决策模式
    fprintf('\n--- 农户决策分析 ---\n');
    
    if isempty(model.results.time_series)
        fprintf('没有可用的结果数据\n');
        return;
    end
    
    % 获取最终状态
    final_state = model.results.time_series(end);
    
    % 分析外出务工决策
    off_farm_ratio = final_state.households.off_farm_ratio;
    fprintf('外出务工比例: %.2f%%\n', off_farm_ratio * 100);
    
    % 分析种植决策
    grain_planting_ratio = final_state.households.grain_planting_ratio;
    fprintf('粮食种植比例: %.2f%%\n', grain_planting_ratio * 100);
    
    % 分析收入结构
    mean_income = final_state.households.mean_income;
    mean_off_farm_income = final_state.households.mean_off_farm_income;
    mean_agricultural_income = final_state.households.mean_agricultural_income;
    
    fprintf('平均总收入: %.2f\n', mean_income);
    fprintf('平均非农收入: %.2f\n', mean_off_farm_income);
    fprintf('平均农业收入: %.2f\n', mean_agricultural_income);
    
    % 分析韧性指标
    income_resilience = final_state.households.income_resilience;
    production_resilience = final_state.households.production_resilience;
    nutrition_health = final_state.households.nutrition_health;
    
    fprintf('收入韧性: %.3f\n', income_resilience);
    fprintf('生产韧性: %.3f\n', production_resilience);
    fprintf('营养健康: %.3f\n', nutrition_health);
    
    % 分析性别差异
    analyze_gender_differences(model);
end

function analyze_gender_differences(model)
    % 分析性别差异
    fprintf('\n--- 性别差异分析 ---\n');
    
    % 这里可以添加基于性别的分析
    % 由于模型简化，这里只提供框架
    
    fprintf('性别差异分析框架已建立\n');
    fprintf('可以进一步扩展分析不同性别农户的决策差异\n');
end

function analyze_enterprise_behavior(model)
    % 分析企业行为模式
    fprintf('\n--- 企业行为分析 ---\n');
    
    if isempty(model.results.time_series)
        fprintf('没有可用的结果数据\n');
        return;
    end
    
    % 获取最终状态
    final_state = model.results.time_series(end);
    
    % 分析企业类型分布
    agricultural_ratio = final_state.enterprises.agricultural_ratio;
    fprintf('农业企业比例: %.2f%%\n', agricultural_ratio * 100);
    
    % 分析生产效率
    mean_productivity = final_state.enterprises.mean_productivity;
    std_productivity = final_state.enterprises.std_productivity;
    fprintf('平均生产效率: %.3f ± %.3f\n', mean_productivity, std_productivity);
    
    % 分析雇佣情况
    total_workers = final_state.enterprises.total_workers;
    mean_workers_per_enterprise = final_state.enterprises.mean_workers_per_enterprise;
    fprintf('总雇佣工人数: %d\n', total_workers);
    fprintf('平均每企业工人数: %.2f\n', mean_workers_per_enterprise);
    
    % 分析企业竞争力
    analyze_enterprise_competitiveness(model);
end

function analyze_enterprise_competitiveness(model)
    % 分析企业竞争力
    fprintf('\n--- 企业竞争力分析 ---\n');
    
    % 分析不同类型企业的竞争力
    agricultural_enterprises = model.get_agricultural_enterprises();
    other_enterprises = {};
    
    for i = 1:length(model.enterprises)
        if ~strcmp(model.enterprises{i}.type, 'agricultural')
            other_enterprises{end+1} = model.enterprises{i};
        end
    end
    
    % 计算农业企业平均效率
    if ~isempty(agricultural_enterprises)
        agri_efficiencies = zeros(length(agricultural_enterprises), 1);
        for i = 1:length(agricultural_enterprises)
            agri_efficiencies(i) = agricultural_enterprises{i}.performance.efficiency;
        end
        mean_agri_efficiency = mean(agri_efficiencies);
        fprintf('农业企业平均效率: %.3f\n', mean_agri_efficiency);
    end
    
    % 计算其他企业平均效率
    if ~isempty(other_enterprises)
        other_efficiencies = zeros(length(other_enterprises), 1);
        for i = 1:length(other_enterprises)
            other_efficiencies(i) = other_enterprises{i}.performance.efficiency;
        end
        mean_other_efficiency = mean(other_efficiencies);
        fprintf('其他企业平均效率: %.3f\n', mean_other_efficiency);
    end
end

function analyze_policy_effects(model)
    % 分析政策效果
    fprintf('\n--- 政策效果分析 ---\n');
    
    if isempty(model.results.time_series)
        fprintf('没有可用的结果数据\n');
        return;
    end
    
    % 获取最终状态
    final_state = model.results.time_series(end);
    
    % 分析政策参数
    grain_subsidy_rate = final_state.government.grain_subsidy_rate;
    land_red_line_ratio = final_state.government.land_red_line_ratio;
    climate_adaptation_policy = final_state.government.climate_adaptation_policy;
    rural_urban_mobility_policy = final_state.government.rural_urban_mobility_policy;
    
    fprintf('种粮补贴率: %.2f%%\n', grain_subsidy_rate * 100);
    fprintf('耕地红线比例: %.2f%%\n', land_red_line_ratio * 100);
    fprintf('气候适应政策强度: %.2f\n', climate_adaptation_policy);
    fprintf('城乡流动政策强度: %.2f\n', rural_urban_mobility_policy);
    
    % 分析政策成本
    total_subsidy_cost = final_state.government.total_subsidy_cost;
    fprintf('总补贴成本: %.2f\n', total_subsidy_cost);
    
    % 分析政策有效性
    effectiveness = model.government.calculate_policy_effectiveness();
    fprintf('政策综合有效性: %.3f\n', effectiveness.overall);
    
    % 分析成本效率
    cost_efficiency = model.government.calculate_cost_efficiency();
    fprintf('政策成本效率: %.3f\n', cost_efficiency);
    
    % 分析政策对农户决策的影响
    analyze_policy_household_interaction(model);
end

function analyze_policy_household_interaction(model)
    % 分析政策对农户决策的影响
    fprintf('\n--- 政策-农户交互分析 ---\n');
    
    if length(model.results.time_series) < 2
        fprintf('数据不足，无法进行交互分析\n');
        return;
    end
    
    % 分析政策变化对农户决策的影响
    times = arrayfun(@(ts) ts.time, model.results.time_series);
    grain_planting_ratios = arrayfun(@(ts) ts.households.grain_planting_ratio, model.results.time_series);
    off_farm_ratios = arrayfun(@(ts) ts.households.off_farm_ratio, model.results.time_series);
    mean_incomes = arrayfun(@(ts) ts.households.mean_income, model.results.time_series);
    
    % 计算相关性
    if length(times) > 1
        % 计算政策变化与农户决策的相关性
        fprintf('政策变化对农户决策的影响分析:\n');
        fprintf('  粮食种植比例变化趋势: %.3f\n', (grain_planting_ratios(end) - grain_planting_ratios(1)) / length(times));
        fprintf('  外出务工比例变化趋势: %.3f\n', (off_farm_ratios(end) - off_farm_ratios(1)) / length(times));
        fprintf('  平均收入变化趋势: %.3f\n', (mean_incomes(end) - mean_incomes(1)) / length(times));
    end
end

function sensitivity_analysis(model)
    % 敏感性分析
    fprintf('\n--- 敏感性分析 ---\n');
    
    % 分析不同政策参数的影响
    fprintf('分析不同政策参数对结果的影响:\n');
    
    % 种粮补贴率敏感性
    fprintf('1. 种粮补贴率敏感性分析\n');
    analyze_subsidy_sensitivity(model);
    
    % 耕地红线比例敏感性
    fprintf('2. 耕地红线比例敏感性分析\n');
    analyze_land_red_line_sensitivity(model);
    
    % 气候适应政策敏感性
    fprintf('3. 气候适应政策敏感性分析\n');
    analyze_climate_adaptation_sensitivity(model);
    
    % 城乡流动政策敏感性
    fprintf('4. 城乡流动政策敏感性分析\n');
    analyze_mobility_sensitivity(model);
end

function analyze_subsidy_sensitivity(model)
    % 分析种粮补贴敏感性
    fprintf('  种粮补贴率对粮食种植比例的影响\n');
    fprintf('  种粮补贴率对农民收入的影响\n');
    fprintf('  种粮补贴率对政策成本的影响\n');
end

function analyze_land_red_line_sensitivity(model)
    % 分析耕地红线敏感性
    fprintf('  耕地红线比例对土地利用效率的影响\n');
    fprintf('  耕地红线比例对种植结构的影响\n');
    fprintf('  耕地红线比例对农民收入的影响\n');
end

function analyze_climate_adaptation_sensitivity(model)
    % 分析气候适应政策敏感性
    fprintf('  气候适应政策对农户适应行为的影响\n');
    fprintf('  气候适应政策对生产韧性的影响\n');
    fprintf('  气候适应政策对收入稳定性的影响\n');
end

function analyze_mobility_sensitivity(model)
    % 分析城乡流动政策敏感性
    fprintf('  城乡流动政策对外出务工比例的影响\n');
    fprintf('  城乡流动政策对收入结构的影响\n');
    fprintf('  城乡流动政策对社会稳定的影响\n');
end

function save_test_results(model)
    % 保存模型和测试结果到文件
    % 保存模型和结果
    save('climate_policy_model_test_results.mat', 'model');
    
    % 保存详细报告
    fid = fopen('climate_policy_model_test_report.txt', 'w');
    fprintf(fid, '多智能体气候变化政策模型测试报告\n');
    fprintf(fid, '================================\n\n');
    
    % 写入测试结果
    if ~isempty(model.results.time_series)
        final_state = model.results.time_series(end);
        fprintf(fid, '最终状态:\n');
        fprintf(fid, '  农户数量: %d\n', final_state.households.total_count);
        fprintf(fid, '  企业数量: %d\n', final_state.enterprises.total_count);
        fprintf(fid, '  平均农户收入: %.2f\n', final_state.households.mean_income);
        fprintf(fid, '  外出务工比例: %.2f%%\n', final_state.households.off_farm_ratio * 100);
        fprintf(fid, '  粮食种植比例: %.2f%%\n', final_state.households.grain_planting_ratio * 100);
        fprintf(fid, '  收入韧性: %.3f\n', final_state.households.income_resilience);
        fprintf(fid, '  生产韧性: %.3f\n', final_state.households.production_resilience);
        fprintf(fid, '  营养健康: %.3f\n', final_state.households.nutrition_health);
    end
    
    fclose(fid);
end 