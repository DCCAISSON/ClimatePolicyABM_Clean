%% 拓展农业ABM主运行脚本
% 基于EER附录A的完整拓展版本
% 包含农户分层、企业创新、多层次市场、分级政府、环境冲击等机制

clear; clc; close all;

fprintf('=== 拓展农业ABM系统启动 ===\n');
fprintf('基于EER附录A的完整拓展版本\n');
fprintf('包含以下新机制:\n');
fprintf('1. 农户分层机制 (小农户、中农户、大农户、专业农户)\n');
fprintf('2. 企业创新机制 (农业生产企业、农业加工企业、其他企业)\n');
fprintf('3. 多层次市场机制 (初级市场、中间品市场、最终产品市场)\n');
fprintf('4. 分级政府机制 (中央政府、地方政府)\n');
fprintf('5. 环境冲击机制 (天气、政策、市场、技术、自然灾害、疫情)\n');
fprintf('6. 土地流转机制\n');
fprintf('7. 农户外出务工机制\n');
fprintf('8. 土地租赁价格机制\n');
fprintf('9. 农户收入变化机制\n');
fprintf('10. 收入不平等变化机制\n');
fprintf('11. 城乡收入差距变化机制\n');
fprintf('12. 土地流转与就业关系分析机制\n');
fprintf('13. 收入分布变化分析机制\n');
fprintf('14. 土地利用效率分析机制\n');
fprintf('15. 农户迁移数量分析机制\n');
fprintf('16. 农业生产变化分析机制\n');
fprintf('17. 收入来源分解分析机制\n');
fprintf('18. 土地流转价值分析机制\n');
fprintf('19. 综合指标分析机制\n');
fprintf('20. 统计分析机制\n');
fprintf('21. 政策建议生成机制\n\n');

%% 1. 参数配置
fprintf('1. 配置参数...\n');
params = params_extended();

%% 2. 运行模拟
fprintf('2. 运行拓展农业ABM模拟...\n');
tic;
[results, farmers, agricultural_firms, other_firms, government] = agri_abm_extended(params);
simulation_time = toc;
fprintf('模拟完成，耗时: %.2f 秒\n\n', simulation_time);

%% 3. 增强版土地流转模块分析
fprintf('3. 增强版土地流转模块分析...\n');
analysis_enhanced_land_transfer(results, farmers, agricultural_firms, other_firms, government, params);

%% 4. 结果分析和可视化
fprintf('4. 分析结果并生成图表...\n');

% 创建结果分析文件夹
if ~exist('results_extended', 'dir')
    mkdir('results_extended');
end

%% 4.1 基础宏观经济指标
figure('Name', '基础宏观经济指标', 'Position', [100, 100, 1200, 800]);

% GDP趋势
subplot(2, 3, 1);
plot(1:params.T_max, results.real_gdp, 'b-', 'LineWidth', 2);
title('实际GDP趋势');
xlabel('时间');
ylabel('实际GDP');
grid on;

% 就业趋势
subplot(2, 3, 2);
plot(1:params.T_max, results.employment_impact, 'r-', 'LineWidth', 2);
title('就业趋势');
xlabel('时间');
ylabel('就业人数');
grid on;

% 价格趋势
subplot(2, 3, 3);
plot(1:params.T_max, results.market_prices(1, :), 'g-', 'LineWidth', 2);
hold on;
plot(1:params.T_max, results.market_prices(2, :), 'm-', 'LineWidth', 2);
plot(1:params.T_max, results.market_prices(3, :), 'c-', 'LineWidth', 2);
title('多层次市场价格趋势');
xlabel('时间');
ylabel('价格');
legend('初级市场', '中间品市场', '最终产品市场', 'Location', 'best');
grid on;

% 收入不平等
subplot(2, 3, 4);
plot(1:params.T_max, results.income_inequality, 'k-', 'LineWidth', 2);
title('收入不平等趋势');
xlabel('时间');
ylabel('收入不平等系数');
grid on;

% 创新水平
subplot(2, 3, 5);
plot(1:params.T_max, results.innovation_impact, 'y-', 'LineWidth', 2);
title('创新水平趋势');
xlabel('时间');
ylabel('创新水平');
grid on;

% 政府政策
subplot(2, 3, 6);
plot(1:params.T_max, results.agricultural_subsidy, 'b-', 'LineWidth', 2);
hold on;
plot(1:params.T_max, results.innovation_support, 'r-', 'LineWidth', 2);
title('政府政策工具');
xlabel('时间');
ylabel('政策支出');
legend('农业补贴', '创新支持', 'Location', 'best');
grid on;

saveas(gcf, 'results_extended/macro_economic_indicators.png');
saveas(gcf, 'results_extended/macro_economic_indicators.fig');

%% 4.2 农户分层分析
figure('Name', '农户分层分析', 'Position', [200, 200, 1200, 800]);

% 农户层级分布
subplot(2, 3, 1);
bar(1:params.farmer_layers, results.farmer_analysis.avg_output);
title('各层级农户平均产出');
xlabel('农户层级');
ylabel('平均产出');
set(gca, 'XTickLabel', {'小农户', '中农户', '大农户', '专业农户'});
grid on;

% 农户收入分布
subplot(2, 3, 2);
bar(1:params.farmer_layers, results.farmer_analysis.avg_income);
title('各层级农户平均收入');
xlabel('农户层级');
ylabel('平均收入');
set(gca, 'XTickLabel', {'小农户', '中农户', '大农户', '专业农户'});
grid on;

% 农户技术效率
subplot(2, 3, 3);
bar(1:params.farmer_layers, results.farmer_analysis.avg_tech_efficiency);
title('各层级农户技术效率');
xlabel('农户层级');
ylabel('技术效率');
set(gca, 'XTickLabel', {'小农户', '中农户', '大农户', '专业农户'});
grid on;

% 农户土地面积
subplot(2, 3, 4);
bar(1:params.farmer_layers, results.farmer_analysis.avg_land_area);
title('各层级农户平均土地面积');
xlabel('农户层级');
ylabel('土地面积');
set(gca, 'XTickLabel', {'小农户', '中农户', '大农户', '专业农户'});
grid on;

% 农户收入不平等
subplot(2, 3, 5);
plot(1:params.T_max, results.farmer_analysis.income_inequality, 'b-', 'LineWidth', 2);
title('农户收入不平等趋势');
xlabel('时间');
ylabel('收入不平等系数');
grid on;

% 农户产出不平等
subplot(2, 3, 6);
plot(1:params.T_max, results.farmer_analysis.output_inequality, 'r-', 'LineWidth', 2);
title('农户产出不平等趋势');
xlabel('时间');
ylabel('产出不平等系数');
grid on;

saveas(gcf, 'results_extended/farmer_layer_analysis.png');
saveas(gcf, 'results_extended/farmer_layer_analysis.fig');

%% 4.3 企业创新分析
figure('Name', '企业创新分析', 'Position', [300, 300, 1200, 800]);

% 企业创新水平分布
subplot(2, 3, 1);
histogram(results.firm_innovation(:, end), 20);
title('企业创新水平分布');
xlabel('创新水平');
ylabel('企业数量');
grid on;

% 各类型企业平均创新水平
subplot(2, 3, 2);
agri_firms = find(results.firm_innovation(:, end) > 0 & results.firm_innovation(:, end) <= 0.3);
processing_firms = find(results.firm_innovation(:, end) > 0.3 & results.firm_innovation(:, end) <= 0.7);
other_firms = find(results.firm_innovation(:, end) > 0.7);

agri_avg = mean(results.firm_innovation(agri_firms, end));
processing_avg = mean(results.firm_innovation(processing_firms, end));
other_avg = mean(results.firm_innovation(other_firms, end));

bar([agri_avg, processing_avg, other_avg]);
title('各类型企业平均创新水平');
xlabel('企业类型');
ylabel('平均创新水平');
set(gca, 'XTickLabel', {'农业企业', '加工企业', '其他企业'});
grid on;

% 创新与生产率关系
subplot(2, 3, 3);
scatter(results.firm_innovation(:, end), results.firm_output(:, end), 'filled');
title('创新水平与产出关系');
xlabel('创新水平');
ylabel('企业产出');
grid on;

% 创新投资趋势
subplot(2, 3, 4);
plot(1:params.T_max, mean(results.firm_innovation, 1), 'b-', 'LineWidth', 2);
title('平均创新水平趋势');
xlabel('时间');
ylabel('平均创新水平');
grid on;

% 技术存量分布
subplot(2, 3, 5);
histogram(results.firm_technology_stock(:, end), 20);
title('企业技术存量分布');
xlabel('技术存量');
ylabel('企业数量');
grid on;

% 创新成功率
subplot(2, 3, 6);
innovation_success_rate = sum(results.firm_innovation(:, end) > 0.5) / length(results.firm_innovation(:, end));
bar(innovation_success_rate);
title('创新成功率');
xlabel('成功企业比例');
ylabel('比例');
ylim([0, 1]);
grid on;

saveas(gcf, 'results_extended/enterprise_innovation_analysis.png');
saveas(gcf, 'results_extended/enterprise_innovation_analysis.fig');

%% 4.4 环境冲击分析
figure('Name', '环境冲击分析', 'Position', [400, 400, 1200, 800]);

% 各种冲击时间序列
subplot(2, 3, 1);
plot(1:params.T_max, results.weather_shock, 'b-', 'LineWidth', 1.5);
hold on;
plot(1:params.T_max, results.policy_shock, 'r-', 'LineWidth', 1.5);
plot(1:params.T_max, results.market_shock, 'g-', 'LineWidth', 1.5);
title('环境冲击时间序列');
xlabel('时间');
ylabel('冲击强度');
legend('天气冲击', '政策冲击', '市场冲击', 'Location', 'best');
grid on;

% 技术冲击和自然灾害
subplot(2, 3, 2);
plot(1:params.T_max, results.technology_shock, 'm-', 'LineWidth', 1.5);
hold on;
plot(1:params.T_max, results.natural_disaster_shock, 'c-', 'LineWidth', 1.5);
plot(1:params.T_max, results.pandemic_shock, 'y-', 'LineWidth', 1.5);
title('技术冲击和灾害冲击');
xlabel('时间');
ylabel('冲击强度');
legend('技术冲击', '自然灾害', '疫情冲击', 'Location', 'best');
grid on;

% 冲击对GDP的影响
subplot(2, 3, 3);
gdp_growth = diff(results.real_gdp) ./ results.real_gdp(1:end-1);
plot(2:params.T_max, gdp_growth, 'k-', 'LineWidth', 2);
title('GDP增长率');
xlabel('时间');
ylabel('GDP增长率');
grid on;

% 冲击对就业的影响
subplot(2, 3, 4);
employment_growth = diff(results.employment_impact) ./ results.employment_impact(1:end-1);
plot(2:params.T_max, employment_growth, 'b-', 'LineWidth', 2);
title('就业增长率');
xlabel('时间');
ylabel('就业增长率');
grid on;

% 冲击对价格的影响
subplot(2, 3, 5);
price_volatility = std(results.market_prices, 0, 2);
bar(price_volatility);
title('各市场层级价格波动性');
xlabel('市场层级');
ylabel('价格波动性');
set(gca, 'XTickLabel', {'初级市场', '中间品市场', '最终产品市场'});
grid on;

% 冲击对收入不平等的影响
subplot(2, 3, 6);
plot(1:params.T_max, results.income_inequality, 'r-', 'LineWidth', 2);
title('收入不平等变化');
xlabel('时间');
ylabel('收入不平等系数');
grid on;

saveas(gcf, 'results_extended/environmental_shock_analysis.png');
saveas(gcf, 'results_extended/environmental_shock_analysis.fig');

%% 4.5 政府政策分析
figure('Name', '政府政策分析', 'Position', [500, 500, 1200, 800]);

% 政府收支
subplot(2, 3, 1);
plot(1:params.T_max, results.central_revenue, 'b-', 'LineWidth', 2);
hold on;
plot(1:params.T_max, results.central_expenditure, 'r-', 'LineWidth', 2);
title('中央政府收支');
xlabel('时间');
ylabel('金额');
legend('收入', '支出', 'Location', 'best');
grid on;

% 地方政府收支
subplot(2, 3, 2);
plot(1:params.T_max, results.local_revenue, 'b-', 'LineWidth', 2);
hold on;
plot(1:params.T_max, results.local_expenditure, 'r-', 'LineWidth', 2);
title('地方政府收支');
xlabel('时间');
ylabel('金额');
legend('收入', '支出', 'Location', 'best');
grid on;

% 政策工具使用
subplot(2, 3, 3);
plot(1:params.T_max, results.agricultural_subsidy, 'g-', 'LineWidth', 2);
hold on;
plot(1:params.T_max, results.innovation_support, 'm-', 'LineWidth', 2);
title('政策工具使用');
xlabel('时间');
ylabel('政策支出');
legend('农业补贴', '创新支持', 'Location', 'best');
grid on;

% 政策效果评估
subplot(2, 3, 4);
plot(1:params.T_max, results.gdp_impact, 'b-', 'LineWidth', 2);
title('政策对GDP的影响');
xlabel('时间');
ylabel('GDP影响');
grid on;

% 政策对就业的影响
subplot(2, 3, 5);
plot(1:params.T_max, results.employment_impact, 'r-', 'LineWidth', 2);
title('政策对就业的影响');
xlabel('时间');
ylabel('就业影响');
grid on;

% 政策对创新的影响
subplot(2, 3, 6);
plot(1:params.T_max, results.innovation_impact, 'g-', 'LineWidth', 2);
title('政策对创新的影响');
xlabel('时间');
ylabel('创新影响');
grid on;

saveas(gcf, 'results_extended/government_policy_analysis.png');
saveas(gcf, 'results_extended/government_policy_analysis.fig');

%% 4.6 经济韧性分析
figure('Name', '经济韧性分析', 'Position', [600, 600, 1200, 800]);

% GDP韧性
subplot(2, 3, 1);
plot(1:params.T_max, results.real_gdp, 'b-', 'LineWidth', 2);
title('GDP韧性分析');
xlabel('时间');
ylabel('实际GDP');
grid on;

% 就业韧性
subplot(2, 3, 2);
plot(1:params.T_max, results.employment_impact, 'r-', 'LineWidth', 2);
title('就业韧性分析');
xlabel('时间');
ylabel('就业人数');
grid on;

% 价格稳定性
subplot(2, 3, 3);
plot(1:params.T_max, results.market_prices(1, :), 'g-', 'LineWidth', 2);
title('价格稳定性分析');
xlabel('时间');
ylabel('初级市场价格');
grid on;

% 收入不平等稳定性
subplot(2, 3, 4);
plot(1:params.T_max, results.income_inequality, 'm-', 'LineWidth', 2);
title('收入不平等稳定性');
xlabel('时间');
ylabel('收入不平等系数');
grid on;

% 创新韧性
subplot(2, 3, 5);
plot(1:params.T_max, results.innovation_impact, 'c-', 'LineWidth', 2);
title('创新韧性分析');
xlabel('时间');
ylabel('创新水平');
grid on;

% 综合韧性指标
subplot(2, 3, 6);
% 计算综合韧性指标 (GDP、就业、价格的加权平均)
composite_resilience = (results.real_gdp / max(results.real_gdp) + ...
                       results.employment_impact / max(results.employment_impact) + ...
                       results.market_prices(1, :) / max(results.market_prices(1, :))) / 3;
plot(1:params.T_max, composite_resilience, 'k-', 'LineWidth', 2);
title('综合经济韧性指标');
xlabel('时间');
ylabel('韧性指标');
grid on;

saveas(gcf, 'results_extended/economic_resilience_analysis.png');
saveas(gcf, 'results_extended/economic_resilience_analysis.fig');

%% 5. 详细分析图表
figure('Position', [200, 200, 1400, 1000]);

%% 5.1 土地流转与就业关系
subplot(2, 4, 1);
scatter(results.land_transfer_area, results.employment_rate * 100, 50, results.periods, 'filled');
colorbar;
title('土地流转与就业率关系');
xlabel('土地流转面积（亩）');
ylabel('就业率（%）');
grid on;

%% 5.2 收入分布变化
subplot(2, 4, 2);
income_percentiles = prctile(results.farmer_income, [25, 50, 75], 2);
plot(results.periods, income_percentiles(:, 1), 'b-', 'LineWidth', 1.5);
hold on;
plot(results.periods, income_percentiles(:, 2), 'r-', 'LineWidth', 2);
plot(results.periods, income_percentiles(:, 3), 'g-', 'LineWidth', 1.5);
title('农户收入分布变化');
xlabel('时间周期');
ylabel('收入（元）');
legend('25分位数', '中位数', '75分位数', 'Location', 'best');
grid on;

%% 5.3 土地利用效率
subplot(2, 4, 3);
plot(results.periods, results.land_use_efficiency, 'b-', 'LineWidth', 2);
title('土地利用效率变化');
xlabel('时间周期');
ylabel('单位土地产出');
grid on;

%% 5.4 农户迁移数量
subplot(2, 4, 4);
plot(results.periods, results.farmer_migration, 'r-', 'LineWidth', 2);
title('外出务工农户数量');
xlabel('时间周期');
ylabel('外出务工农户数');
grid on;

%% 5.5 农业生产变化
subplot(2, 4, 5);
total_agricultural_production = sum(results.agricultural_production, 2);
plot(results.periods, total_agricultural_production, 'g-', 'LineWidth', 2);
title('总农业生产变化');
xlabel('时间周期');
ylabel('总产量');
grid on;

%% 5.6 收入来源分解
subplot(2, 4, 6);
% 计算不同收入来源的比例
farming_income_ratio = mean(results.farmer_income, 2) ./ (mean(results.farmer_income, 2) + results.land_transfer_area * 800);
off_farm_income_ratio = 1 - farming_income_ratio;

plot(results.periods, farming_income_ratio * 100, 'b-', 'LineWidth', 2);
hold on;
plot(results.periods, off_farm_income_ratio * 100, 'r-', 'LineWidth', 2);
title('收入来源结构变化');
xlabel('时间周期');
ylabel('收入比例（%）');
legend('务农收入', '非农收入', 'Location', 'best');
grid on;

%% 5.7 土地流转价值
subplot(2, 4, 7);
land_transfer_value = results.land_transfer_area .* results.rental_prices;
plot(results.periods, land_transfer_value, 'm-', 'LineWidth', 2);
title('土地流转总价值');
xlabel('时间周期');
ylabel('流转价值（元）');
grid on;

%% 5.8 综合指标
subplot(2, 4, 8);
% 创建综合发展指数
development_index = (results.employment_rate * 0.3 + ...
                    (1 - results.income_inequality) * 0.3 + ...
                    results.land_use_efficiency / max(results.land_use_efficiency) * 0.4);
plot(results.periods, development_index, 'k-', 'LineWidth', 2);
title('农村综合发展指数');
xlabel('时间周期');
ylabel('发展指数');
grid on;

%% 6. 统计分析
fprintf('6. 生成统计分析报告...\n');

% 创建统计报告
stats_report = struct();

% 土地流转统计
stats_report.land_transfer = struct();
stats_report.land_transfer.total_area = sum(results.land_transfer_area);
stats_report.land_transfer.average_area = mean(results.land_transfer_area);
stats_report.land_transfer.max_area = max(results.land_transfer_area);
stats_report.land_transfer.growth_rate = (results.land_transfer_area(end) - results.land_transfer_area(1)) / results.land_transfer_area(1) * 100;

% 就业统计
stats_report.employment = struct();
stats_report.employment.average_rate = mean(results.employment_rate) * 100;
stats_report.employment.max_rate = max(results.employment_rate) * 100;
stats_report.employment.total_migrants = sum(results.farmer_migration);
stats_report.employment.growth_rate = (results.employment_rate(end) - results.employment_rate(1)) / results.employment_rate(1) * 100;

% 收入统计
stats_report.income = struct();
stats_report.income.average_income = mean(results.farmer_income, 'all');
stats_report.income.income_growth = (mean(results.farmer_income(end, :)) - mean(results.farmer_income(1, :))) / mean(results.farmer_income(1, :)) * 100;
stats_report.income.inequality_reduction = results.income_inequality(1) - results.income_inequality(end);
stats_report.income.urban_rural_gap_change = (results.rural_urban_income_gap(end) - results.rural_urban_income_gap(1)) / results.rural_urban_income_gap(1) * 100;

% 生产统计
stats_report.production = struct();
stats_report.production.total_output = sum(results.agricultural_production, 'all');
stats_report.production.average_efficiency = mean(results.land_use_efficiency);
stats_report.production.efficiency_improvement = (results.land_use_efficiency(end) - results.land_use_efficiency(1)) / results.land_use_efficiency(1) * 100;

%% 7. 保存结果
fprintf('7. 保存结果...\n');

% 保存数据
save('results_extended/extended_agri_abm_results.mat', 'results', 'farmers', 'agricultural_firms', 'other_firms', 'government', 'stats_report');

% 保存图表
saveas(gcf, 'results_extended/extended_agri_abm_analysis.png');
saveas(gcf, 'results_extended/extended_agri_abm_analysis.fig');

%% 8. 输出统计报告
fprintf('\n=== 扩展农业ABM模型统计报告 ===\n');

fprintf('\n土地流转统计:\n');
fprintf('  总流转面积: %.2f 亩\n', stats_report.land_transfer.total_area);
fprintf('  平均流转面积: %.2f 亩\n', stats_report.land_transfer.average_area);
fprintf('  最大流转面积: %.2f 亩\n', stats_report.land_transfer.max_area);
fprintf('  流转面积增长率: %.2f%%\n', stats_report.land_transfer.growth_rate);

fprintf('\n就业统计:\n');
fprintf('  平均就业率: %.2f%%\n', stats_report.employment.average_rate);
fprintf('  最高就业率: %.2f%%\n', stats_report.employment.max_rate);
fprintf('  总外出务工农户: %.0f 户\n', stats_report.employment.total_migrants);
fprintf('  就业率增长率: %.2f%%\n', stats_report.employment.growth_rate);

fprintf('\n收入统计:\n');
fprintf('  平均收入: %.2f 元\n', stats_report.income.average_income);
fprintf('  收入增长率: %.2f%%\n', stats_report.income.income_growth);
fprintf('  收入不平等减少: %.4f\n', stats_report.income.inequality_reduction);
fprintf('  城乡收入差距变化: %.2f%%\n', stats_report.income.urban_rural_gap_change);

fprintf('\n生产统计:\n');
fprintf('  总农业产出: %.2f\n', stats_report.production.total_output);
fprintf('  平均土地利用效率: %.2f\n', stats_report.production.average_efficiency);
fprintf('  效率提升: %.2f%%\n', stats_report.production.efficiency_improvement);

%% 9. 政策建议
fprintf('\n=== 政策建议 ===\n');

% 基于模拟结果生成政策建议
if stats_report.land_transfer.growth_rate > 10
    fprintf('• 土地流转发展良好，建议进一步完善土地流转市场机制\n');
end

if stats_report.employment.average_rate < 30
    fprintf('• 外出就业率较低，建议加强技能培训和就业信息服务\n');
end

if stats_report.income.inequality_reduction < 0.05
    fprintf('• 收入不平等改善有限，建议加强收入再分配政策\n');
end

if stats_report.production.efficiency_improvement > 20
    fprintf('• 土地利用效率显著提升，土地流转政策效果良好\n');
end

fprintf('\n模拟完成！结果已保存到 extended_agri_abm_results.mat\n');
fprintf('分析图表已保存到 extended_agri_abm_analysis.png\n');

%% 辅助函数
function generate_results_report(results, params, simulation_time)
    % 生成结果报告
    
    report_file = 'results_extended/results_report.txt';
    fid = fopen(report_file, 'w');
    
    fprintf(fid, '=== 拓展农业ABM系统结果报告 ===\n\n');
    fprintf(fid, '模拟时间: %.2f 秒\n', simulation_time);
    fprintf(fid, '模拟周期: %d\n', params.T_max);
    fprintf(fid, '企业数量: %d\n', params.I);
    fprintf(fid, '家庭数量: %d\n', params.H);
    fprintf(fid, '农户数量: %d\n', params.H_farmers);
    fprintf(fid, '农户层级数: %d\n', params.farmer_layers);
    fprintf(fid, '市场层级数: %d\n', params.market_levels);
    fprintf(fid, '部门数量: %d\n', params.G);
    fprintf(fid, '产品种类数: %d\n\n', params.S);
    
    % 宏观经济指标
    fprintf(fid, '=== 宏观经济指标 ===\n');
    fprintf(fid, '最终实际GDP: %.2f\n', results.real_gdp(end));
    fprintf(fid, 'GDP增长率: %.2f%%\n', (results.real_gdp(end) / results.real_gdp(1) - 1) * 100);
    fprintf(fid, '最终就业人数: %.2f\n', results.employment_impact(end));
    fprintf(fid, '最终收入不平等系数: %.4f\n\n', results.income_inequality(end));
    
    % 农户分析
    fprintf(fid, '=== 农户分层分析 ===\n');
    for layer = 1:params.farmer_layers
        layer_names = {'小农户', '中农户', '大农户', '专业农户'};
        fprintf(fid, '%s平均产出: %.2f\n', layer_names{layer}, results.farmer_analysis.avg_output(layer));
        fprintf(fid, '%s平均收入: %.2f\n', layer_names{layer}, results.farmer_analysis.avg_income(layer));
        fprintf(fid, '%s技术效率: %.4f\n', layer_names{layer}, results.farmer_analysis.avg_tech_efficiency(layer));
        fprintf(fid, '%s土地面积: %.2f\n\n', layer_names{layer}, results.farmer_analysis.avg_land_area(layer));
    end
    
    % 企业创新分析
    fprintf(fid, '=== 企业创新分析 ===\n');
    fprintf(fid, '平均创新水平: %.4f\n', mean(results.firm_innovation(:, end)));
    fprintf(fid, '创新成功率: %.2f%%\n', sum(results.firm_innovation(:, end) > 0.5) / length(results.firm_innovation(:, end)) * 100);
    fprintf(fid, '平均技术存量: %.4f\n\n', mean(results.firm_technology_stock(:, end)));
    
    % 市场分析
    fprintf(fid, '=== 多层次市场分析 ===\n');
    market_names = {'初级市场', '中间品市场', '最终产品市场'};
    for level = 1:params.market_levels
        fprintf(fid, '%s平均价格: %.2f\n', market_names{level}, mean(results.market_prices(level, :)));
        fprintf(fid, '%s价格波动性: %.4f\n', market_names{level}, std(results.market_prices(level, :)));
    end
    fprintf(fid, '市场间价格传导系数: %.4f\n\n', results.market_analysis.price_transmission);
    
    % 政府政策分析
    fprintf(fid, '=== 政府政策分析 ===\n');
    fprintf(fid, '总农业补贴: %.2f\n', sum(results.agricultural_subsidy));
    fprintf(fid, '总创新支持: %.2f\n', sum(results.innovation_support));
    fprintf(fid, '政策平均GDP影响: %.2f\n', mean(results.gdp_impact));
    fprintf(fid, '政策平均就业影响: %.2f\n', mean(results.employment_impact));
    fprintf(fid, '政策平均创新影响: %.2f\n\n', mean(results.innovation_impact));
    
    % 环境冲击分析
    fprintf(fid, '=== 环境冲击分析 ===\n');
    shock_names = {'天气冲击', '政策冲击', '市场冲击', '技术冲击', '自然灾害', '疫情冲击'};
    shock_series = {results.weather_shock, results.policy_shock, results.market_shock, ...
                   results.technology_shock, results.natural_disaster_shock, results.pandemic_shock};
    
    for i = 1:length(shock_names)
        total_intensity = sum(abs(shock_series{i}));
        max_intensity = max(abs(shock_series{i}));
        frequency = sum(shock_series{i} ~= 0) / length(shock_series{i});
        fprintf(fid, '%s总强度: %.4f, 最大强度: %.4f, 发生频率: %.2f%%\n', ...
                shock_names{i}, total_intensity, max_intensity, frequency * 100);
    end
    fprintf(fid, '\n');
    
    % 经济韧性分析
    fprintf(fid, '=== 经济韧性分析 ===\n');
    fprintf(fid, 'GDP波动性: %.4f\n', results.resilience_analysis.gdp_volatility);
    fprintf(fid, 'GDP恢复速度: %.4f\n', results.resilience_analysis.gdp_recovery_speed);
    fprintf(fid, '就业波动性: %.4f\n', results.resilience_analysis.employment_volatility);
    fprintf(fid, '就业恢复速度: %.4f\n', results.resilience_analysis.employment_recovery_speed);
    fprintf(fid, '价格稳定性: %.4f\n', results.resilience_analysis.price_stability);
    fprintf(fid, '收入不平等稳定性: %.4f\n', results.resilience_analysis.inequality_stability);
    
    fclose(fid);
    fprintf('结果报告已生成: %s\n', report_file);
end 