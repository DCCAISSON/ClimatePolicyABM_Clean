function [results] = agri_abm(params)
    % 农业ABM主函数 - 基于EER附录A
    % params: 参数结构体
    
    % 初始化数据结构
    [firm_data] = modules_firm_structure(params.I, params.G, params.S, params);
    [household_data] = modules_household_structure(params.H, params.I, params.G, params);
    
    % 初始化历史数据
    Y_history = zeros(1, params.T_max);
    pi_history = zeros(1, params.T_max);
    
    % 初始化结果存储
    results = initialize_results(params);
    
    % 主循环
    for t = 1:params.T_max
        fprintf('Period %d/%d\n', t, params.T_max);
        
        % 1. 企业决策阶段 (附录A.1.2)
        [Q_s_i, P_i, N_d_i, I_d_i, DM_d_i] = modules_firm_decision(firm_data, household_data, params, t, Y_history, pi_history);
        
        % 更新企业数据
        firm_data.Q_s_i = Q_s_i;
        firm_data.P_i = P_i;
        firm_data.N_d_i = N_d_i;
        firm_data.I_d_i = I_d_i;
        firm_data.DM_d_i = DM_d_i;
        
        % 2. 劳动力市场匹配 (附录A.1.6, A.2.1)
        [N_i, household_data] = modules_labor_matching(firm_data, household_data, params);
        firm_data.N_i = N_i;
        
        % 3. 生产阶段 (附录A.1.3)
        [Y_i, a_i, w_i] = modules_production(Q_s_i, firm_data.M_i, N_i, firm_data.K_i, firm_data.a_bar_i, firm_data.beta_i, firm_data.kappa_i, params);
        firm_data.Y_i = Y_i;
        firm_data.a_i = a_i;
        firm_data.w_i = w_i;
        
        % 4. 市场匹配 (附录A.1.1)
        [Q_i, DS_i, household_data] = modules_market_matching_inventory(firm_data, household_data, params);
        firm_data.Q_i = Q_i;
        firm_data.DS_i = DS_i;
        firm_data.S_i = firm_data.S_i + DS_i;
        
        % 5. 价格均衡 (附录A.1.2)
        [P_bar, P_bar_g] = modules_price_equilibrium(firm_data, params);
        params.P_bar = P_bar;
        params.P_bar_g = P_bar_g;
        
        % 6. 投资和中间投入采购
        [I_i, DM_i] = modules_investment_material_procurement(firm_data, params);
        firm_data.I_i = I_i;
        firm_data.DM_i = DM_i;
        
        % 7. 资本和库存更新 (附录A.1.4, A.1.5)
        firm_data = update_capital_inventory(firm_data, params);
        
        % 8. 利润和现金流计算 (附录A.1.8)
        firm_data = calculate_profits_cashflow(firm_data, params);
        
        % 9. 家庭消费和投资决策 (附录A.2.2, A.2.3)
        household_data = modules_household_decision(household_data, firm_data, params);
        
        % 10. 家庭收入更新 (附录A.2.4)
        household_data = calculate_household_income(household_data, firm_data, [], params);
        
        % 11. 家庭储蓄更新 (附录A.2.5)
        household_data = update_household_savings(household_data, params);
        
        % 12. 破产检查 (附录A.1.9)
        firm_data = check_bankruptcy(firm_data, params);
        
        % 13. 记录结果
        results = record_results(results, firm_data, household_data, t, params);
        
        % 14. 更新历史数据
        Y_history(t) = sum(firm_data.Y_i);
        pi_history(t) = log(P_bar / params.P_bar_prev);
        params.P_bar_prev = P_bar;
    end
end

function results = initialize_results(params)
    % 初始化结果存储
    results = struct();
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
    
    % 家庭层面结果
    results.household_income = zeros(params.H, params.T_max);
    results.household_consumption = zeros(params.H, params.T_max);
    results.household_savings = zeros(params.H, params.T_max);
end

function [N_i, household_data] = modules_labor_matching(firm_data, household_data, params)
    % 劳动力市场匹配 (附录A.1.6, A.2.1)
    
    I = length(firm_data.firm_id);
    H_W = params.H_W;
    
    % 计算职位空缺
    V_i = max(0, firm_data.N_d_i - firm_data.N_i);
    
    % 更新雇佣状态
    N_i = firm_data.N_i;
    
    % 失业工人寻找工作
    unemployed = find(household_data.activity_status == 2);
    
    for h = unemployed'
        % 随机选择有空缺的企业
        firms_with_vacancies = find(V_i > 0);
        if ~isempty(firms_with_vacancies)
            selected_firm = firms_with_vacancies(randi(length(firms_with_vacancies)));
            
            % 雇佣工人
            household_data.employed_firm(h) = selected_firm;
            household_data.activity_status(h) = 1;  % 在业
            household_data.w_h(h) = firm_data.w_i(selected_firm);
            
            % 更新企业雇佣
            N_i(selected_firm) = N_i(selected_firm) + 1;
            V_i(selected_firm) = V_i(selected_firm) - 1;
        end
    end
    
    % 解雇多余工人
    for i = 1:I
        if N_i(i) > firm_data.N_d_i(i)
            excess_workers = N_i(i) - firm_data.N_d_i(i);
            
            % 找到在该企业工作的工人
            workers_at_firm = find(household_data.employed_firm == i);
            
            if length(workers_at_firm) >= excess_workers
                % 随机选择要解雇的工人
                to_fire = workers_at_firm(randperm(length(workers_at_firm), excess_workers));
                
                for h = to_fire'
                    household_data.activity_status(h) = 2;  % 失业
                    household_data.employed_firm(h) = 0;
                    household_data.last_wage(h) = household_data.w_h(h);
                end
                
                N_i(i) = firm_data.N_d_i(i);
            end
        end
    end
end

function [I_i, DM_i] = modules_investment_material_procurement(firm_data, params)
    % 投资和中间投入采购
    
    I = length(firm_data.firm_id);
    
    % 简化的采购过程 - 实际实现中需要市场匹配
    I_i = firm_data.I_d_i * 0.9;  % 假设90%的需求得到满足
    DM_i = firm_data.DM_d_i * 0.9;
end

function firm_data = update_capital_inventory(firm_data, params)
    % 更新资本和库存 (附录A.1.4, A.1.5)
    
    I = length(firm_data.firm_id);
    
    % 资本更新 (公式A.17)
    firm_data.K_i = firm_data.K_i - (firm_data.delta_i ./ firm_data.kappa_i) .* firm_data.Y_i + firm_data.I_i;
    
    % 中间品库存更新 (公式A.21)
    firm_data.M_i = firm_data.M_i - firm_data.Y_i ./ firm_data.beta_i + firm_data.DM_i;
end

function firm_data = calculate_profits_cashflow(firm_data, params)
    % 计算利润和现金流 (附录A.1.8)
    
    I = length(firm_data.firm_id);
    
    % 利润计算 (公式A.30)
    firm_data.Pi_i = firm_data.P_i .* firm_data.Q_i + ...
                     params.P_bar * firm_data.DS_i - ...
                     (1 + params.tau_SIF) * firm_data.w_i .* firm_data.N_i * params.P_bar_HH - ...
                     (1 ./ firm_data.beta_i) .* params.P_bar * firm_data.Y_i - ...
                     (firm_data.delta_i ./ firm_data.kappa_i) .* params.P_bar_CF * firm_data.Y_i - ...
                     params.tau_Y * firm_data.P_i .* firm_data.Y_i - ...
                     params.tau_K * firm_data.P_i .* firm_data.Y_i - ...
                     params.r * (firm_data.L_i + max(0, -firm_data.D_i)) + ...
                     params.r_bar * max(0, firm_data.D_i);
    
    % 现金流计算 (公式A.33)
    firm_data.DD_i = firm_data.P_i .* firm_data.Q_i - ...
                     (1 + params.tau_SIF) * firm_data.w_i .* firm_data.N_i * params.P_bar_HH - ...
                     params.P_bar * firm_data.DM_i - ...
                     params.tau_Y * firm_data.P_i .* firm_data.Y_i - ...
                     params.tau_K * firm_data.P_i .* firm_data.Y_i - ...
                     params.tau_FIRM * max(0, firm_data.Pi_i) - ...
                     params.theta_DIV * (1 - params.tau_FIRM) * max(0, firm_data.Pi_i) - ...
                     params.r * (firm_data.L_i + max(0, -firm_data.D_i)) + ...
                     params.r_bar * max(0, firm_data.D_i) - ...
                     params.P_bar_CF * firm_data.I_i + ...
                     firm_data.DL_i - ...
                     params.theta * firm_data.L_i;
    
    % 更新存款和债务 (公式A.34, A.35)
    firm_data.D_i = firm_data.D_i + firm_data.DD_i;
    firm_data.L_i = (1 - params.theta) * firm_data.L_i + firm_data.DL_i;
    
    % 更新权益 (公式A.36)
    firm_data.E_i = firm_data.D_i + firm_data.M_i + firm_data.S_i + firm_data.K_i - firm_data.L_i;
end

function household_data = modules_household_decision(household_data, firm_data, params)
    % 家庭消费和投资决策 (附录A.2.2, A.2.3)
    
    H = length(household_data.household_id);
    G = size(household_data.b_HH_g, 1);
    
    % 计算预期收入 (公式A.44)
    household_data = calculate_expected_income(household_data, firm_data, params);
    
    % 消费预算 (公式A.46)
    household_data.C_d_h = (params.psi * household_data.Y_e_h) / (1 + params.tau_VAT);
    
    % 投资预算 (公式A.49)
    household_data.I_d_h = (params.psi_H * household_data.Y_e_h) / (1 + params.tau_CF);
    
    % 产品消费分配 (公式A.47)
    for h = 1:H
        for g = 1:G
            household_data.C_hg(h, g) = (household_data.b_HH_g(g) * params.P_bar_g(g) / params.P_bar_HH) * household_data.C_d_h(h);
        end
    end
    
    % 产品投资分配 (公式A.50)
    for h = 1:H
        for g = 1:G
            household_data.I_hg(h, g) = (household_data.b_CFH_g(g) * params.P_bar_g(g) / sum(household_data.b_CFH_g .* params.P_bar_g)) * household_data.I_d_h(h);
        end
    end
    
    % 实际消费和投资 (简化实现)
    household_data.C_h = household_data.C_d_h * 0.95;  % 假设95%的消费计划得到满足
    household_data.I_h = household_data.I_d_h * 0.95;  % 假设95%的投资计划得到满足
end

function household_data = calculate_expected_income(household_data, firm_data, params)
    % 计算预期收入 (公式A.44)
    
    H = length(household_data.household_id);
    
    for h = 1:H
        switch household_data.activity_status(h)
            case 1  % 在业工人
                household_data.Y_e_h(h) = (household_data.w_h(h) * ...
                    (1 - params.tau_SIW - params.tau_INC * (1 - params.tau_SIW)) + ...
                    household_data.sb_other) * params.P_bar_HH * (1 + params.pi_e);
                
            case 2  % 失业工人
                household_data.Y_e_h(h) = (params.theta_UB * household_data.w_h(h) + ...
                    household_data.sb_other) * params.P_bar_HH * (1 + params.pi_e);
                
            case 3  % 非经济活动人口
                household_data.Y_e_h(h) = (household_data.sb_inact + ...
                    household_data.sb_other) * params.P_bar_HH * (1 + params.pi_e);
                
            case 4  % 企业投资者
                if household_data.investor_firm(h) > 0
                    i = household_data.investor_firm(h);
                    household_data.Y_e_h(h) = (params.theta_DIV * ...
                        (1 - params.tau_INC) * (1 - params.tau_FIRM) * ...
                        max(0, firm_data.Pi_e_i(i)) + household_data.sb_other) * params.P_bar_HH * (1 + params.pi_e);
                else
                    household_data.Y_e_h(h) = household_data.sb_other * params.P_bar_HH * (1 + params.pi_e);
                end
                
            case 5  % 银行投资者
                household_data.Y_e_h(h) = household_data.sb_other * params.P_bar_HH * (1 + params.pi_e);
        end
    end
end

function household_data = update_household_savings(household_data, params)
    % 更新家庭储蓄 (公式A.54)
    
    H = length(household_data.household_id);
    
    for h = 1:H
        % 储蓄
        savings = household_data.Y_h(h) - ...
                  (1 + params.tau_VAT) * household_data.C_h(h) - ...
                  (1 + params.tau_CF) * household_data.I_h(h);
        
        % 利息收入/支付
        interest = params.r_bar * max(0, household_data.D_h(h)) - ...
                   params.r * max(0, -household_data.D_h(h));
        
        % 更新存款
        household_data.D_h(h) = household_data.D_h(h) + savings + interest;
    end
    
    % 更新家庭资本存量 (公式A.52)
    household_data.K_h = household_data.K_h + household_data.I_h;
end

function firm_data = check_bankruptcy(firm_data, params)
    % 破产检查 (附录A.1.9)
    
    I = length(firm_data.firm_id);
    
    for i = 1:I
        % 检查现金流破产和资产负债表破产
        if firm_data.D_i(i) < 0 && firm_data.E_i(i) < 0
            firm_data.bankrupt(i) = true;
            
            % 债务重组 (公式A.38, A.39)
            firm_data.L_i(i) = params.zeta * params.P_bar_CF * firm_data.K_i(i);
            firm_data.D_i(i) = 0;
            firm_data.E_i(i) = firm_data.E_i(i) + (firm_data.L_i(i) - firm_data.D_i(i) - params.zeta * params.P_bar_CF * firm_data.K_i(i));
        end
    end
end

function results = record_results(results, firm_data, household_data, t, params)
    % 记录结果
    
    % 宏观经济指标
    results.nominal_gdp(t) = sum(firm_data.P_i .* firm_data.Y_i);
    results.real_gdp(t) = sum(firm_data.Y_i);
    results.nominal_gva(t) = sum(firm_data.P_i .* firm_data.Y_i) - sum(params.P_bar * firm_data.Y_i ./ firm_data.beta_i);
    results.real_gva(t) = sum(firm_data.Y_i .* (1 - 1 ./ firm_data.beta_i));
    results.nominal_household_consumption(t) = (1 + params.tau_VAT) * sum(household_data.C_h);
    results.real_household_consumption(t) = sum(household_data.C_h);
    results.operating_surplus(t) = sum(firm_data.Pi_i);
    results.compensation_employees(t) = (1 + params.tau_SIF) * sum(firm_data.w_i .* firm_data.N_i) * params.P_bar_HH;
    results.wages(t) = sum(firm_data.w_i .* firm_data.N_i) * params.P_bar_HH;
    
    % 部门增加值
    for g = 1:params.G
        sector_firms = (firm_data.sector == g);
        if any(sector_firms)
            results.nominal_sector_gva(t, g) = sum(firm_data.P_i(sector_firms) .* firm_data.Y_i(sector_firms)) - ...
                                              sum(params.P_bar * firm_data.Y_i(sector_firms) ./ firm_data.beta_i(sector_firms));
            results.real_sector_gva(t, g) = sum(firm_data.Y_i(sector_firms) .* (1 - 1 ./ firm_data.beta_i(sector_firms)));
        end
    end
    
    % 企业层面结果
    results.firm_output(:, t) = firm_data.Y_i;
    results.firm_profits(:, t) = firm_data.Pi_i;
    results.firm_employment(:, t) = firm_data.N_i;
    results.firm_prices(:, t) = firm_data.P_i;
    
    % 家庭层面结果
    results.household_income(:, t) = household_data.Y_h;
    results.household_consumption(:, t) = household_data.C_h;
    results.household_savings(:, t) = household_data.D_h;
end 