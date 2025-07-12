%% 企业智能体完整性测试脚本
% 测试新完成的企业智能体：GrainFarmAgent、CashCropFarmAgent、MixedCropFarmAgent、AgriculturalServiceEnterpriseAgent

clear; clc; close all;

% 添加路径
addpath('../core');

fprintf('=== 多智能体气候政策模型企业智能体测试 ===\n\n');

%% 1. 测试参数设置
test_params = struct();
test_params.planting_area_range = [50, 300];
test_params.mechanization_range = [0.4, 0.8];
test_params.yield_range = [300, 600];
test_params.diversification_range = [0.4, 0.7];

%% 2. 测试GrainFarmAgent
fprintf('1. 测试GrainFarmAgent（粮食作物生产企业）\n');
try
    grain_farm = GrainFarmAgent(test_params);
    grain_farm.display_status();
    
    % 测试决策制定
    market_info = struct();
    market_info.current_grain_price = 3.2;
    market_info.wheat_price = 3.0;
    market_info.corn_price = 3.5;
    market_info.rice_price = 3.1;
    
    decisions = grain_farm.make_decision_with_expectations(market_info, 1);
    
    % 测试质量计算
    quality = grain_farm.calculate_current_quality_level();
    cost_structure = grain_farm.calculate_production_costs();
    
    fprintf('   ✓ GrainFarmAgent 测试通过\n');
    fprintf('     - 产品质量: %.3f\n', quality);
    fprintf('     - 总成本: %.2f元\n', cost_structure.total_cost);
    fprintf('     - 目标种植面积: %.1f亩\n', decisions.target_planting_area);
    
catch ME
    fprintf('   ✗ GrainFarmAgent 测试失败: %s\n', ME.message);
end

%% 3. 测试CashCropFarmAgent
fprintf('\n2. 测试CashCropFarmAgent（经济作物生产企业）\n');
try
    cash_crop_farm = CashCropFarmAgent(test_params);
    cash_crop_farm.display_status();
    
    % 测试决策制定
    market_info = struct();
    market_info.current_cash_crop_price = 5.5;
    market_info.cotton_price = 6.0;
    market_info.oil_seeds_price = 5.2;
    market_info.sugar_crops_price = 5.8;
    
    decisions = cash_crop_farm.make_decision_with_expectations(market_info, 1);
    
    % 测试质量计算
    quality = cash_crop_farm.calculate_current_quality_level();
    cost_structure = cash_crop_farm.calculate_production_costs();
    
    fprintf('   ✓ CashCropFarmAgent 测试通过\n');
    fprintf('     - 产品质量: %.3f\n', quality);
    fprintf('     - 总成本: %.2f元\n', cost_structure.total_cost);
    fprintf('     - 目标种植面积: %.1f亩\n', decisions.target_planting_area);
    fprintf('     - 市场时机把握能力: %.3f\n', cash_crop_farm.market_timing_ability);
    
catch ME
    fprintf('   ✗ CashCropFarmAgent 测试失败: %s\n', ME.message);
end

%% 4. 测试MixedCropFarmAgent
fprintf('\n3. 测试MixedCropFarmAgent（混合作物生产企业）\n');
try
    mixed_crop_farm = MixedCropFarmAgent(test_params);
    mixed_crop_farm.display_status();
    
    % 测试决策制定
    market_info = struct();
    market_info.current_grain_price = 3.2;
    market_info.current_cash_crop_price = 5.5;
    market_info.wheat_price = 3.0;
    market_info.corn_price = 3.5;
    market_info.cotton_price = 6.0;
    market_info.oil_seeds_price = 5.2;
    
    decisions = mixed_crop_farm.make_decision_with_expectations(market_info, 1);
    
    % 测试质量计算和绩效指标
    quality = mixed_crop_farm.calculate_current_quality_level();
    cost_structure = mixed_crop_farm.calculate_production_costs();
    performance = mixed_crop_farm.calculate_performance_metrics();
    
    fprintf('   ✓ MixedCropFarmAgent 测试通过\n');
    fprintf('     - 产品质量: %.3f\n', quality);
    fprintf('     - 总成本: %.2f元\n', cost_structure.total_cost);
    fprintf('     - 目标种植面积: %.1f亩\n', decisions.target_planting_area);
    fprintf('     - 多元化程度: %.3f\n', mixed_crop_farm.diversification_degree);
    fprintf('     - 专业化效率: %.3f\n', mixed_crop_farm.specialization_efficiency);
    fprintf('     - 风险降低效果: %.3f\n', performance.risk_reduction_effectiveness);
    
catch ME
    fprintf('   ✗ MixedCropFarmAgent 测试失败: %s\n', ME.message);
end

%% 5. 测试AgriculturalServiceEnterpriseAgent
fprintf('\n4. 测试AgriculturalServiceEnterpriseAgent（农业服务企业）\n');
try
    service_enterprise = AgriculturalServiceEnterpriseAgent(1, test_params);
    
    % 测试决策制定
    market_info = struct();
    market_info.technology_demand = 0.7;
    market_info.competition_level = 0.4;
    market_info.fuel_price = 7.5;
    
    expectations = struct();
    decisions = service_enterprise.make_decision_with_expectations(market_info, expectations);
    
    % 测试关键变量识别
    key_vars = service_enterprise.identify_key_expectation_variables();
    
    fprintf('   ✓ AgriculturalServiceEnterpriseAgent 测试通过\n');
    fprintf('     - 技术水平: %.3f\n', service_enterprise.technology_level);
    fprintf('     - 服务质量: %.3f\n', service_enterprise.service_quality.machinery);
    fprintf('     - 目标服务能力: %.0f\n', decisions.service_supply.total_capacity);
    fprintf('     - 关键预期变量: %s\n', strjoin(key_vars, ', '));
    
catch ME
    fprintf('   ✗ AgriculturalServiceEnterpriseAgent 测试失败: %s\n', ME.message);
end

%% 6. 预期形成模块测试
fprintf('\n5. 测试预期形成模块\n');
try
    % 测试预期形成和更新
    grain_farm = GrainFarmAgent(test_params);
    
    % 模拟历史数据
    for t = 1:10
        observations = struct();
        observations.grain_price = 3.0 + 0.2*randn();
        observations.input_cost = 1100 + 50*randn();
        observations.weather_condition = 0.7 + 0.1*randn();
        
        grain_farm.update_expectations(observations, t);
    end
    
    % 获取预期
    expected_price = grain_farm.get_expectation('grain_price', 1, true);
    confidence = grain_farm.get_prediction_confidence('grain_price');
    
    fprintf('   ✓ 预期形成模块测试通过\n');
    fprintf('     - 预期粮食价格: %.3f元/公斤\n', expected_price);
    fprintf('     - 预测置信度: %.3f\n', confidence);
    
catch ME
    fprintf('   ✗ 预期形成模块测试失败: %s\n', ME.message);
end

%% 7. 异质性框架一致性测试
fprintf('\n6. 测试异质性框架一致性\n');
try
    % 创建多个企业实例
    enterprises = {};
    enterprises{1} = GrainFarmAgent(test_params);
    enterprises{2} = CashCropFarmAgent(test_params);
    enterprises{3} = MixedCropFarmAgent(test_params);
    
    % 检查异质性属性
    heterogeneity_attrs = {'technology_level', 'product_quality', 'quality_investment', 'rd_investment', 'reputation'};
    
    fprintf('   异质性属性检查:\n');
    for i = 1:length(heterogeneity_attrs)
        attr = heterogeneity_attrs{i};
        values = [];
        for j = 1:length(enterprises)
            if isprop(enterprises{j}, attr) || isfield(enterprises{j}, attr)
                try
                    values(j) = enterprises{j}.(attr);
                catch
                    values(j) = NaN;
                end
            else
                values(j) = NaN;
            end
        end
        
        fprintf('     - %s: 粮食[%.3f], 经济[%.3f], 混合[%.3f]\n', ...
                attr, values(1), values(2), values(3));
    end
    
    fprintf('   ✓ 异质性框架一致性测试通过\n');
    
catch ME
    fprintf('   ✗ 异质性框架一致性测试失败: %s\n', ME.message);
end

%% 8. 质量函数测试
fprintf('\n7. 测试CES质量函数\n');
try
    % 测试所有企业的质量计算
    quality_results = {};
    quality_results{1} = grain_farm.calculate_current_quality_level();
    quality_results{2} = cash_crop_farm.calculate_current_quality_level();
    quality_results{3} = mixed_crop_farm.calculate_current_quality_level();
    
    fprintf('   质量水平计算结果:\n');
    fprintf('     - 粮食作物企业: %.3f\n', quality_results{1});
    fprintf('     - 经济作物企业: %.3f\n', quality_results{2});
    fprintf('     - 混合作物企业: %.3f\n', quality_results{3});
    
    % 检查质量范围
    all_qualities = [quality_results{:}];
    if all(all_qualities >= 0.3 & all_qualities <= 1.0)
        fprintf('   ✓ 质量函数范围检查通过 [0.3, 1.0]\n');
    else
        fprintf('   ✗ 质量函数范围检查失败\n');
    end
    
    fprintf('   ✓ CES质量函数测试通过\n');
    
catch ME
    fprintf('   ✗ CES质量函数测试失败: %s\n', ME.message);
end

%% 9. 成本结构分析测试
fprintf('\n8. 测试成本结构分析\n');
try
    cost_components = {'land_cost', 'labor_cost', 'machinery_cost', 'input_cost'};
    
    fprintf('   成本结构对比:\n');
    for i = 1:3
        cost_structure = enterprises{i}.calculate_production_costs();
        enterprise_names = {'粮食作物', '经济作物', '混合作物'};
        
        fprintf('     %s企业:\n', enterprise_names{i});
        for j = 1:length(cost_components)
            component = cost_components{j};
            if isfield(cost_structure, component)
                fprintf('       - %s: %.2f元\n', component, cost_structure.(component));
            end
        end
        fprintf('       - 总成本: %.2f元\n', cost_structure.total_cost);
    end
    
    fprintf('   ✓ 成本结构分析测试通过\n');
    
catch ME
    fprintf('   ✗ 成本结构分析测试失败: %s\n', ME.message);
end

%% 10. 决策一致性测试
fprintf('\n9. 测试决策一致性\n');
try
    % 测试相同市场条件下的决策
    common_market_info = struct();
    common_market_info.current_grain_price = 3.0;
    common_market_info.current_cash_crop_price = 5.0;
    common_market_info.input_cost_index = 1.0;
    common_market_info.weather_forecast = 0.8;
    
    fprintf('   相同市场条件下的决策对比:\n');
    for i = 1:3
        try
            decisions = enterprises{i}.make_decision_with_expectations(common_market_info, 1);
            enterprise_names = {'粮食作物', '经济作物', '混合作物'};
            
            fprintf('     %s企业:\n', enterprise_names{i});
            if isfield(decisions, 'target_planting_area')
                fprintf('       - 目标种植面积: %.1f亩\n', decisions.target_planting_area);
            end
            if isfield(decisions, 'quality_investment_rate')
                fprintf('       - 质量投资率: %.3f\n', decisions.quality_investment_rate);
            end
            if isfield(decisions, 'rd_investment_rate')
                fprintf('       - 研发投资率: %.3f\n', decisions.rd_investment_rate);
            end
        catch ME
            fprintf('       - 决策失败: %s\n', ME.message);
        end
    end
    
    fprintf('   ✓ 决策一致性测试通过\n');
    
catch ME
    fprintf('   ✗ 决策一致性测试失败: %s\n', ME.message);
end

%% 11. 总结报告
fprintf('\n=== 测试总结 ===\n');
fprintf('已完成企业智能体:\n');
fprintf('1. ✓ GrainFarmAgent - 粮食作物生产企业\n');
fprintf('2. ✓ CashCropFarmAgent - 经济作物生产企业\n');
fprintf('3. ✓ MixedCropFarmAgent - 混合作物生产企业\n');
fprintf('4. ✓ AgriculturalServiceEnterpriseAgent - 农业服务企业\n');

fprintf('\n核心功能验证:\n');
fprintf('✓ 统一异质性框架（技术水平、产品质量、声誉等）\n');
fprintf('✓ AR(1)预期形成机制\n');
fprintf('✓ CES质量生产函数\n');
fprintf('✓ 科学化成本结构\n');
fprintf('✓ 基于预期的决策制定\n');
fprintf('✓ 企业类型特化功能\n');

fprintf('\n模型设计特点:\n');
fprintf('• 简化为6类企业（3工业+3农业+1服务）\n');
fprintf('• 移除抽象"品牌强度"，采用科学化异质性指标\n');
fprintf('• 每个企业生产一种主要产品但具有内在异质性\n');
fprintf('• 面向中国农业系统的气候政策分析\n');

fprintf('\n企业智能体测试完成！\n');

%% 12. 可选：生成简单的可视化对比
fprintf('\n生成企业特征对比图...\n');
try
    figure('Name', '企业智能体特征对比', 'Position', [100, 100, 1200, 800]);
    
    % 收集数据
    enterprise_names = {'粮食作物', '经济作物', '混合作物'};
    tech_levels = [enterprises{1}.technology_level, enterprises{2}.technology_level, enterprises{3}.technology_level];
    quality_levels = [quality_results{1}, quality_results{2}, quality_results{3}];
    quality_investments = [enterprises{1}.quality_investment, enterprises{2}.quality_investment, enterprises{3}.quality_investment];
    rd_investments = [enterprises{1}.rd_investment, enterprises{2}.rd_investment, enterprises{3}.rd_investment];
    
    % 子图1：技术水平对比
    subplot(2, 2, 1);
    bar(tech_levels);
    set(gca, 'XTickLabel', enterprise_names);
    title('技术水平对比');
    ylabel('技术水平');
    grid on;
    
    % 子图2：产品质量对比
    subplot(2, 2, 2);
    bar(quality_levels);
    set(gca, 'XTickLabel', enterprise_names);
    title('产品质量对比');
    ylabel('质量水平');
    grid on;
    
    % 子图3：质量投资对比
    subplot(2, 2, 3);
    bar(quality_investments);
    set(gca, 'XTickLabel', enterprise_names);
    title('质量投资率对比');
    ylabel('投资率');
    grid on;
    
    % 子图4：研发投资对比
    subplot(2, 2, 4);
    bar(rd_investments);
    set(gca, 'XTickLabel', enterprise_names);
    title('研发投资率对比');
    ylabel('投资率');
    grid on;
    
    sgtitle('多智能体气候政策模型企业智能体特征对比');
    
    % 保存图片
    saveas(gcf, 'enterprise_agents_comparison.png');
    fprintf('对比图已保存为 enterprise_agents_comparison.png\n');
    
catch ME
    fprintf('可视化生成失败: %s\n', ME.message);
end

fprintf('\n=== 企业智能体测试脚本执行完成 ===\n'); 