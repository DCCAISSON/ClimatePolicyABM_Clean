function [results, farmers, agricultural_firms, other_firms, government] = agri_abm_extended(params)
    % 拓展的农业ABM主函数 - 基于EER附录A的完整拓展版本
    % 包含农户分层、企业创新、多层次市场、分级政府、环境冲击等机制
    
    fprintf('初始化拓展农业ABM系统...\n');
    
    % 1. 初始化基础数据结构
    [firm_data] = modules_firm_structure(params.I, params.G, params.S, params);
    [household_data] = modules_household_structure(params.H, params.I, params.G, params);
    
    % 2. 初始化拓展模块
    [farmer_data] = modules_farmer_layering(params);
    [market_data] = modules_multi_level_market(params);
    [government_data] = modules_government_hierarchy(params);
    [environment_data] = modules_environmental_shock(params);
    
    % 3. 初始化历史数据
    Y_history = zeros(1, params.T_max);
    pi_history = zeros(1, params.T_max);
    
    % 4. 初始化结果存储
    results = initialize_extended_results(params);
    
    fprintf('开始模拟运行...\n');
    
    % 主循环
    for t = 1:params.T_max
        if mod(t, 10) == 0
            fprintf('Period %d/%d\n', t, params.T_max);
        end
        
        % 5. 环境冲击阶段
        [firm_data, farmer_data, market_data] = apply_environmental_shocks(environment_data, firm_data, farmer_data, market_data, params, t);
        
        % 6. 农户生产阶段
        [farmer_output, farmer_data] = farmer_production_function(farmer_data, params, t);
        
        % 7. 企业决策阶段 (包含创新)
        [Q_s_i, P_i, N_d_i, I_d_i, DM_d_i] = modules_firm_decision(firm_data, household_data, params, t, Y_history, pi_history);
        
        % 更新企业数据
        firm_data.Q_s_i = Q_s_i;
        firm_data.P_i = P_i;
        firm_data.N_d_i = N_d_i;
        firm_data.I_d_i = I_d_i;
        firm_data.DM_d_i = DM_d_i;
        
        % 8. 企业创新阶段
        [firm_data] = modules_enterprise_innovation(firm_data, params, t);
        
        % 9. 劳动力市场匹配
        [N_i, household_data] = modules_labor_matching(firm_data, household_data, params);
        firm_data.N_i = N_i;
        
        % 10. 生产阶段
        [Y_i, a_i, w_i] = modules_production(Q_s_i, firm_data.M_i, N_i, firm_data.K_i, firm_data.a_bar_i, firm_data.beta_i, firm_data.kappa_i, params);
        firm_data.Y_i = Y_i;
        firm_data.a_i = a_i;
        firm_data.w_i = w_i;
        
        % 11. 多层次市场出清
        [market_data, firm_data, farmer_data] = multi_level_market_clearing(market_data, firm_data, farmer_data, params, t);
        
        % 12. 市场匹配 (库存管理)
        [Q_i, DS_i, household_data] = modules_market_matching_inventory(firm_data, household_data, params);
        firm_data.Q_i = Q_i;
        firm_data.DS_i = DS_i;
        firm_data.S_i = firm_data.S_i + DS_i;
        
        % 13. 价格均衡
        [P_bar, P_bar_g] = modules_price_equilibrium(firm_data, params);
        params.P_bar = P_bar;
        params.P_bar_g = P_bar_g;
        
        % 14. 投资和中间投入采购
        [I_i, DM_i] = modules_investment_material_procurement(firm_data, params);
        firm_data.I_i = I_i;
        firm_data.DM_i = DM_i;
        
        % 15. 资本和库存更新
        firm_data = update_capital_inventory(firm_data, params);
        
        % 16. 利润和现金流计算
        firm_data = calculate_profits_cashflow(firm_data, params);
        
        % 17. 农户决策阶段
        [farmer_data] = farmer_decision_making(farmer_data, firm_data, params, t);
        
        % 18. 家庭消费和投资决策
        household_data = modules_household_decision(household_data, firm_data, params);
        
        % 19. 家庭收入更新
        household_data = calculate_household_income(household_data, firm_data, farmer_data, params);
        
        % 20. 家庭储蓄更新
        household_data = update_household_savings(household_data, params);
        
        % 21. 政府政策实施
        [government_data, firm_data, farmer_data] = government_policy_implementation(government_data, firm_data, farmer_data, params, t);
        
        % 22. 破产检查
        firm_data = check_bankruptcy(firm_data, params);
        
        % 23. 记录结果
        results = record_extended_results(results, firm_data, household_data, farmer_data, market_data, government_data, environment_data, t, params);
        
        % 24. 更新历史数据
        Y_history(t) = sum(firm_data.Y_i) + sum(farmer_data.output);
        pi_history(t) = log(P_bar / params.P_bar_prev);
        params.P_bar_prev = P_bar;
    end
    
    fprintf('模拟完成，开始分析结果...\n');
    
    % 25. 结果分析
    results = analyze_extended_results(results, firm_data, household_data, farmer_data, market_data, government_data, environment_data, params);
    
    fprintf('拓展农业ABM模拟完成！\n');
end

function results = initialize_extended_results(params)
    % 初始化拓展结果存储
    
    results = struct();
    
    % 基础宏观经济指标
    results.nominal_gdp = zeros(1, params.T_max);
    results.real_gdp = zeros(1, params.T_max);
    results.nominal_gva = zeros(1, params.T_max);
    results.real_gva = zeros(1, params.T_max);
    results.nominal_household_consumption = zeros(1, params.T_max);
    results.real_household_consumption = zeros(1, params.T_max);
    results.nominal_government_consumption = zeros(1, params.T_max);
    results.real_government_consumption = zeros(1, params.T_max);
    results.nominal_capitalformation = zeros(1, params.T_max);
    results.real_capitalformation = zeros(1, params.T_max);
    results.nominal_exports = zeros(1, params.T_max);
    results.real_exports = zeros(1, params.T_max);
    results.nominal_imports = zeros(1, params.T_max);
    results.real_imports = zeros(1, params.T_max);
    results.operating_surplus = zeros(1, params.T_max);
    results.compensation_employees = zeros(1, params.T_max);
    results.wages = zeros(1, params.T_max);
    results.taxes_production = zeros(1, params.T_max);
    results.nominal_sector_gva = zeros(params.T_max, params.G);
    results.real_sector_gva = zeros(params.T_max, params.G);
    results.euribor = zeros(1, params.T_max);
    results.gdp_deflator_growth_ea = zeros(1, params.T_max);
    results.real_gdp_ea = zeros(1, params.T_max);
    
    % 企业层面结果
    results.firm_output = zeros(params.I, params.T_max);
    results.firm_profits = zeros(params.I, params.T_max);
    results.firm_employment = zeros(params.I, params.T_max);
    results.firm_prices = zeros(params.I, params.T_max);
    results.firm_innovation = zeros(params.I, params.T_max);
    results.firm_technology_stock = zeros(params.I, params.T_max);
    
    % 家庭层面结果
    results.household_income = zeros(params.H, params.T_max);
    results.household_consumption = zeros(params.H, params.T_max);
    results.household_savings = zeros(params.H, params.T_max);
    
    % 农户层面结果
    results.farmer_output = zeros(params.H_farmers, params.T_max);
    results.farmer_income = zeros(params.H_farmers, params.T_max);
    results.farmer_tech_efficiency = zeros(params.H_farmers, params.T_max);
    results.farmer_layer_distribution = zeros(params.farmer_layers, params.T_max);
    
    % 市场层面结果
    results.market_prices = zeros(3, params.T_max);  % 3个市场层级
    results.market_quantities = zeros(3, params.T_max);
    results.market_supply = zeros(3, params.T_max);
    results.market_demand = zeros(3, params.T_max);
    
    % 政府层面结果
    results.central_revenue = zeros(1, params.T_max);
    results.central_expenditure = zeros(1, params.T_max);
    results.local_revenue = zeros(1, params.T_max);
    results.local_expenditure = zeros(1, params.T_max);
    results.agricultural_subsidy = zeros(1, params.T_max);
    results.innovation_support = zeros(1, params.T_max);
    
    % 环境冲击结果
    results.weather_shock = zeros(1, params.T_max);
    results.policy_shock = zeros(1, params.T_max);
    results.market_shock = zeros(1, params.T_max);
    results.technology_shock = zeros(1, params.T_max);
    results.natural_disaster_shock = zeros(1, params.T_max);
    results.pandemic_shock = zeros(1, params.T_max);
    
    % 政策效果评估
    results.gdp_impact = zeros(1, params.T_max);
    results.employment_impact = zeros(1, params.T_max);
    results.innovation_impact = zeros(1, params.T_max);
    results.income_inequality = zeros(1, params.T_max);
end

function results = record_extended_results(results, firm_data, household_data, farmer_data, market_data, government_data, environment_data, t, params)
    % 记录拓展结果
    
    % 基础宏观经济指标
    results.nominal_gdp(t) = sum(firm_data.Y_i .* firm_data.P_i) + sum(farmer_data.output .* market_data.prices(1, t));
    results.real_gdp(t) = sum(firm_data.Y_i) + sum(farmer_data.output);
    
    % 企业层面结果
    results.firm_output(:, t) = firm_data.Y_i;
    results.firm_profits(:, t) = firm_data.profits;
    results.firm_employment(:, t) = firm_data.N_i;
    results.firm_prices(:, t) = firm_data.P_i;
    results.firm_innovation(:, t) = firm_data.innovation_level;
    results.firm_technology_stock(:, t) = firm_data.technology_stock;
    
    % 家庭层面结果
    results.household_income(:, t) = household_data.income;
    results.household_consumption(:, t) = household_data.consumption;
    results.household_savings(:, t) = household_data.savings;
    
    % 农户层面结果
    results.farmer_output(:, t) = farmer_data.output;
    results.farmer_income(:, t) = farmer_data.income;
    results.farmer_tech_efficiency(:, t) = farmer_data.tech_efficiency;
    
    % 农户层级分布
    for layer = 1:params.farmer_layers
        layer_farmers = find(farmer_data.layer == layer);
        results.farmer_layer_distribution(layer, t) = length(layer_farmers);
    end
    
    % 市场层面结果
    results.market_prices(:, t) = market_data.prices(:, t);
    results.market_quantities(:, t) = market_data.quantities(:, t);
    results.market_supply(:, t) = market_data.supply(:, t);
    results.market_demand(:, t) = market_data.demand(:, t);
    
    % 政府层面结果
    results.central_revenue(t) = government_data.central.revenue(t);
    results.central_expenditure(t) = government_data.central.expenditure(t);
    results.local_revenue(t) = government_data.local.revenue(t);
    results.local_expenditure(t) = government_data.local.expenditure(t);
    results.agricultural_subsidy(t) = government_data.policy_tools.central.agricultural_subsidy(t);
    results.innovation_support(t) = government_data.policy_tools.central.innovation_support(t);
    
    % 环境冲击结果
    results.weather_shock(t) = environment_data.weather_shock(t);
    results.policy_shock(t) = environment_data.policy_shock(t);
    results.market_shock(t) = environment_data.market_shock(t);
    results.technology_shock(t) = environment_data.technology_shock(t);
    results.natural_disaster_shock(t) = environment_data.natural_disaster_shock(t);
    results.pandemic_shock(t) = environment_data.pandemic_shock(t);
    
    % 政策效果评估
    results.gdp_impact(t) = government_data.policy_effects.gdp_impact(t);
    results.employment_impact(t) = government_data.policy_effects.employment_impact(t);
    results.innovation_impact(t) = government_data.policy_effects.innovation_impact(t);
    results.income_inequality(t) = government_data.policy_effects.income_inequality(t);
end

function results = analyze_extended_results(results, firm_data, household_data, farmer_data, market_data, government_data, environment_data, params)
    % 分析拓展结果
    
    % 1. 创新绩效分析
    [innovation_results] = analyze_innovation_performance(firm_data, params);
    results.innovation_analysis = innovation_results;
    
    % 2. 冲击效应分析
    [shock_analysis] = analyze_shock_effects(environment_data, firm_data, farmer_data, market_data, params);
    results.shock_analysis = shock_analysis;
    
    % 3. 农户分层分析
    results.farmer_analysis = analyze_farmer_layers(farmer_data, params);
    
    % 4. 市场结构分析
    results.market_analysis = analyze_market_structure(market_data, params);
    
    % 5. 政府政策分析
    results.policy_analysis = analyze_government_policies(government_data, params);
    
    % 6. 经济韧性分析
    results.resilience_analysis = analyze_economic_resilience(results, params);
end

function farmer_analysis = analyze_farmer_layers(farmer_data, params)
    % 分析农户分层
    
    farmer_analysis = struct();
    
    % 各层级农户特征
    for layer = 1:params.farmer_layers
        layer_farmers = find(farmer_data.layer == layer);
        
        if ~isempty(layer_farmers)
            farmer_analysis.avg_output(layer) = mean(farmer_data.output(layer_farmers));
            farmer_analysis.avg_income(layer) = mean(farmer_data.income(layer_farmers));
            farmer_analysis.avg_tech_efficiency(layer) = mean(farmer_data.tech_efficiency(layer_farmers));
            farmer_analysis.avg_land_area(layer) = mean(farmer_data.land_area(layer_farmers));
        else
            farmer_analysis.avg_output(layer) = 0;
            farmer_analysis.avg_income(layer) = 0;
            farmer_analysis.avg_tech_efficiency(layer) = 0;
            farmer_analysis.avg_land_area(layer) = 0;
        end
    end
    
    % 农户间不平等
    farmer_analysis.income_inequality = std(farmer_data.income) / mean(farmer_data.income);
    farmer_analysis.output_inequality = std(farmer_data.output) / mean(farmer_data.output);
end

function market_analysis = analyze_market_structure(market_data, params)
    % 分析市场结构
    
    market_analysis = struct();
    
    % 各市场层级特征
    for level = 1:market_data.market_levels
        market_analysis.price_volatility(level) = std(market_data.prices(level, :));
        market_analysis.avg_price(level) = mean(market_data.prices(level, :));
        market_analysis.avg_quantity(level) = mean(market_data.quantities(level, :));
    end
    
    % 市场间价格传导
    market_analysis.price_transmission = corr(market_data.prices(1, :)', market_data.prices(2, :)');
end

function policy_analysis = analyze_government_policies(government_data, params)
    % 分析政府政策
    
    policy_analysis = struct();
    
    % 政策工具使用情况
    policy_analysis.total_agricultural_subsidy = sum(government_data.policy_tools.central.agricultural_subsidy);
    policy_analysis.total_innovation_support = sum(government_data.policy_tools.central.innovation_support);
    policy_analysis.total_infrastructure_investment = sum(government_data.policy_tools.central.infrastructure_investment);
    
    % 政策效果
    policy_analysis.avg_gdp_impact = mean(government_data.policy_effects.gdp_impact);
    policy_analysis.avg_employment_impact = mean(government_data.policy_effects.employment_impact);
    policy_analysis.avg_innovation_impact = mean(government_data.policy_effects.innovation_impact);
    policy_analysis.avg_income_inequality = mean(government_data.policy_effects.income_inequality);
end

function resilience_analysis = analyze_economic_resilience(results, params)
    % 分析经济韧性
    
    resilience_analysis = struct();
    
    % GDP韧性
    gdp_growth = diff(results.real_gdp) ./ results.real_gdp(1:end-1);
    resilience_analysis.gdp_volatility = std(gdp_growth);
    resilience_analysis.gdp_recovery_speed = calculate_recovery_speed(results.real_gdp);
    
    % 就业韧性
    employment_growth = diff(results.employment_impact) ./ results.employment_impact(1:end-1);
    resilience_analysis.employment_volatility = std(employment_growth);
    resilience_analysis.employment_recovery_speed = calculate_recovery_speed(results.employment_impact);
    
    % 价格稳定性
    resilience_analysis.price_stability = std(results.market_prices(1, :)) / mean(results.market_prices(1, :));
    
    % 收入不平等稳定性
    resilience_analysis.inequality_stability = std(results.income_inequality);
end

function recovery_speed = calculate_recovery_speed(series)
    % 计算恢复速度
    
    % 找到最低点
    [~, min_idx] = min(series);
    
    if min_idx < length(series)
        % 计算从最低点到恢复的时间
        recovery_threshold = series(min_idx) * 1.1;  % 恢复到最低点的110%
        recovery_idx = find(series(min_idx:end) >= recovery_threshold, 1);
        
        if ~isempty(recovery_idx)
            recovery_speed = 1 / recovery_idx;  % 恢复速度
        else
            recovery_speed = 0;  % 未恢复
        end
    else
        recovery_speed = 0;
    end
end 