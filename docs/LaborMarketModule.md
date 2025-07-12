# 劳动力市场模块设计文档

## 📋 目录
- [模块概述](#模块概述)
- [核心类设计](#核心类设计)
- [算法实现](#算法实现)
- [市场机制](#市场机制)
- [与现有系统集成](#与现有系统集成)
- [参数配置](#参数配置)
- [使用示例](#使用示例)

---

## 🏗️ 模块概述

### 设计目标
劳动力市场模块旨在填补多智能体气候政策模型中的关键空白，为农业生产、气候适应和政策分析提供完整的劳动力动态建模。

### 核心功能
1. **劳动力供需匹配**：基于技能、地理位置和季节性的劳动力匹配
2. **工资决定机制**：动态工资率确定和谈判过程
3. **季节性流动**：农业劳动力的季节性需求和供给模式
4. **技能培训**：劳动力技能提升和人力资本投资
5. **政策影响分析**：种粮补贴、培训补贴等政策对劳动力配置的影响

---

## 🏛️ 核心类设计

### LaborMarketModule

```matlab
classdef LaborMarketModule < handle
    % 劳动力市场主模块
    
    properties
        % 市场参与者
        labor_suppliers     % cell array of labor suppliers
        labor_demanders     % cell array of labor demanders
        
        % 劳动力分类
        labor_categories = {'unskilled', 'skilled', 'machinery_operator', 'seasonal', 'management'}
        skill_levels = [1, 2, 3, 4, 5]  % 技能等级 1-5
        
        % 市场状态
        current_wage_rates  % struct with wage rates by category
        employment_levels   % struct with employment by category
        unemployment_rate   % overall unemployment rate
        
        % 季节性参数
        seasonal_demand_multipliers  % struct by season and crop type
        peak_seasons = {'spring_planting', 'summer_management', 'autumn_harvest'}
        
        % 匹配机制
        matching_algorithm = 'deferred_acceptance'
        search_cost_factor = 0.05
        geographic_search_radius = 50  % km
        
        % 培训和技能发展
        training_programs   % available training programs
        skill_upgrade_cost  % cost matrix for skill upgrades
        
        % 政策工具
        minimum_wage = 0
        training_subsidies = struct()
        employment_subsidies = struct()
    end
    
    methods
        function obj = LaborMarketModule(params)
            % 构造函数
            obj.initialize_market(params);
        end
        
        function [matches, wages] = match_labor_supply_demand(obj, time_period, climate_conditions)
            % 主要匹配算法
            % 返回匹配结果和均衡工资
        end
        
        function wage_rate = determine_wage_rate(obj, labor_category, supply, demand, location)
            % 工资率决定机制
        end
        
        function demand_forecast = forecast_seasonal_demand(obj, climate_forecast, crop_plans)
            % 季节性劳动力需求预测
        end
        
        function training_decision = decide_training_investment(obj, agent, available_programs)
            % 培训投资决策
        end
        
        function policy_impact = analyze_policy_impact(obj, policy_change)
            % 政策影响分析
        end
    end
end
```

### LaborSupplierAgent

```matlab
classdef LaborSupplierAgent < handle
    % 劳动力供给方智能体（农户或外部劳动力）
    
    properties
        % 基本属性
        agent_id
        agent_type  % 'household', 'external_worker', 'migrant_worker'
        location    % geographic location
        
        % 劳动力资源
        available_work_hours = 2000  % 年可工作小时数
        current_employment_hours = 0  % 当前就业小时数
        
        % 技能和能力
        skill_level = 1  % 1-5 skill level
        labor_categories = {'unskilled'}  % categories this agent can work in
        experience_years = 0
        
        % 偏好和约束
        reservation_wage  % 保留工资
        commuting_tolerance = 30  % 通勤容忍度(km)
        seasonal_availability  % 季节性可用性
        
        % 家庭约束
        family_labor_needs = 0  % 家庭农场劳动力需求
        care_responsibilities = 0  % 照料责任
        
        % 学习和发展
        training_history = []
        skill_upgrade_willingness = 0.5
        
        % 收入和福利
        wage_history = []
        total_labor_income = 0
        employment_satisfaction = 0.5
    end
    
    methods
        function obj = LaborSupplierAgent(id, type, params)
            % 构造函数
            obj.agent_id = id;
            obj.agent_type = type;
            obj.initialize_agent(params);
        end
        
        function supply_decision = decide_labor_supply(obj, wage_offers, job_characteristics)
            % 劳动力供给决策
            % 考虑工资、工作条件、通勤距离等因素
            
            utility_scores = zeros(length(wage_offers), 1);
            
            for i = 1:length(wage_offers)
                offer = wage_offers(i);
                
                % 工资效用
                wage_utility = obj.calculate_wage_utility(offer.wage);
                
                % 距离成本
                distance_cost = obj.calculate_commuting_cost(offer.location);
                
                % 工作条件效用
                condition_utility = obj.evaluate_job_conditions(offer.conditions);
                
                % 综合效用
                utility_scores(i) = wage_utility - distance_cost + condition_utility;
            end
            
            % 选择最佳工作机会
            [max_utility, best_offer_idx] = max(utility_scores);
            
            if max_utility > obj.reservation_wage
                supply_decision = struct('accept', true, 'offer_id', best_offer_idx, ...
                                       'hours_supplied', obj.calculate_hours_supplied(wage_offers(best_offer_idx)));
            else
                supply_decision = struct('accept', false, 'offer_id', 0, 'hours_supplied', 0);
            end
        end
        
        function training_decision = decide_training_participation(obj, training_programs, subsidies)
            % 培训参与决策
            
            best_program = [];
            max_net_benefit = 0;
            
            for program = training_programs
                % 计算培训成本
                training_cost = program.cost * (1 - subsidies.rate);
                
                % 计算预期收益
                expected_wage_increase = obj.estimate_wage_increase(program.skill_improvement);
                discounted_benefit = obj.calculate_discounted_benefit(expected_wage_increase, program.duration);
                
                % 净收益
                net_benefit = discounted_benefit - training_cost;
                
                if net_benefit > max_net_benefit
                    max_net_benefit = net_benefit;
                    best_program = program;
                end
            end
            
            training_decision = struct('participate', max_net_benefit > 0, ...
                                     'program', best_program, ...
                                     'expected_benefit', max_net_benefit);
        end
        
        function hours = calculate_optimal_hours(obj, wage_rate, own_farm_needs)
            % 计算最优工作小时数
            % 在外出务工和自家农场工作之间的权衡
            
            % 自家农场机会成本
            own_farm_marginal_product = obj.calculate_own_farm_marginal_product();
            
            % 如果市场工资高于自家农场边际产品，选择外出务工
            if wage_rate > own_farm_marginal_product
                hours = min(obj.available_work_hours - own_farm_needs, ...
                           obj.calculate_labor_supply_curve(wage_rate));
            else
                hours = 0;
            end
        end
    end
end
```

### LaborDemanderAgent

```matlab
classdef LaborDemanderAgent < handle
    % 劳动力需求方智能体（各类农场和企业）
    
    properties
        % 基本属性
        agent_id
        agent_type  % 'grain_farm', 'cash_crop_farm', 'agro_processing', etc.
        location
        
        % 生产特征
        production_scale = 100  % 生产规模（亩）
        crop_types = {'grain'}  % 种植作物类型
        technology_level = 0.5  % 技术水平（机械化程度）
        
        % 劳动力需求
        labor_demand_forecast = struct()  % 按季节和技能类型的需求预测
        current_labor_force = struct()    % 当前雇佣的劳动力
        
        % 招聘偏好
        preferred_skill_levels = [1, 2]  % 偏好的技能水平
        max_wage_budget = 50000  % 最大工资预算
        reliability_preference = 0.8  % 对可靠性的偏好
        
        % 生产季节性
        peak_labor_periods = {'spring', 'autumn'}  % 劳动力高峰期
        labor_intensity_curve = struct()  % 全年劳动力强度曲线
        
        % 培训投资
        training_budget = 5000  % 培训预算
        skill_development_strategy = 'reactive'  % 'proactive' or 'reactive'
    end
    
    methods
        function obj = LaborDemanderAgent(id, type, params)
            % 构造函数
            obj.agent_id = id;
            obj.agent_type = type;
            obj.initialize_agent(params);
        end
        
        function demand_plan = calculate_labor_demand(obj, production_plan, climate_forecast)
            % 计算劳动力需求
            
            demand_plan = struct();
            
            for season = {'spring', 'summer', 'autumn', 'winter'}
                season_name = season{1};
                
                % 基础劳动力需求
                base_demand = obj.calculate_base_seasonal_demand(season_name, production_plan);
                
                % 气候调整
                climate_adjustment = obj.calculate_climate_adjustment(climate_forecast, season_name);
                
                % 技术调整
                tech_adjustment = 1 - obj.technology_level * 0.4;  % 机械化减少劳动力需求
                
                % 分技能类型计算需求
                for category = obj.get_required_labor_categories()
                    category_name = category{1};
                    skill_multiplier = obj.get_skill_multiplier(category_name, season_name);
                    
                    demand_plan.(season_name).(category_name) = ...
                        base_demand * climate_adjustment * tech_adjustment * skill_multiplier;
                end
            end
        end
        
        function wage_offer = determine_wage_offer(obj, labor_category, market_conditions, urgency)
            % 确定工资报价
            
            % 基础工资（市场参考价格）
            market_wage = market_conditions.average_wage.(labor_category);
            
            % 紧急程度调整
            urgency_premium = urgency * 0.2;  % 最高20%溢价
            
            % 企业支付能力
            affordability_factor = min(1.5, obj.max_wage_budget / obj.calculate_total_wage_bill());
            
            % 质量偏好调整
            quality_premium = obj.reliability_preference * 0.15;  % 最高15%质量溢价
            
            wage_offer = market_wage * (1 + urgency_premium) * affordability_factor * (1 + quality_premium);
            
            % 确保不超过预算约束
            wage_offer = min(wage_offer, obj.calculate_max_affordable_wage(labor_category));
        end
        
        function hiring_decision = make_hiring_decision(obj, applicants, positions_available)
            % 招聘决策
            
            hiring_decision = struct('hired', {}, 'wage_offered', {}, 'hours_offered', {});
            
            % 对申请者进行评分
            applicant_scores = obj.evaluate_applicants(applicants);
            
            % 按得分排序
            [sorted_scores, sort_idx] = sort(applicant_scores, 'descend');
            sorted_applicants = applicants(sort_idx);
            
            % 选择最佳申请者（在预算约束内）
            total_wage_cost = 0;
            hired_count = 0;
            
            for i = 1:min(length(sorted_applicants), positions_available)
                applicant = sorted_applicants(i);
                required_wage = applicant.wage_expectation;
                
                if total_wage_cost + required_wage <= obj.max_wage_budget && hired_count < positions_available
                    hired_count = hired_count + 1;
                    hiring_decision.hired{hired_count} = applicant;
                    hiring_decision.wage_offered{hired_count} = required_wage;
                    hiring_decision.hours_offered{hired_count} = applicant.preferred_hours;
                    total_wage_cost = total_wage_cost + required_wage;
                end
            end
        end
        
        function training_investment = decide_training_investment(obj, current_workforce, skill_gaps)
            % 培训投资决策
            
            training_investment = struct();
            
            % 识别技能缺口的严重程度
            critical_gaps = obj.identify_critical_skill_gaps(skill_gaps);
            
            % 评估培训 vs. 招聘的成本效益
            for gap = critical_gaps
                gap_name = gap{1};
                
                % 培训现有员工的成本
                training_cost = obj.estimate_training_cost(gap_name);
                
                % 招聘熟练工人的成本
                recruitment_cost = obj.estimate_recruitment_cost(gap_name);
                
                % 选择成本较低的方案
                if training_cost < recruitment_cost && obj.training_budget >= training_cost
                    training_investment.(gap_name) = struct('action', 'train', 'cost', training_cost);
                    obj.training_budget = obj.training_budget - training_cost;
                else
                    training_investment.(gap_name) = struct('action', 'recruit', 'cost', recruitment_cost);
                end
            end
        end
    end
end
```

---

## ⚙️ 算法实现

### 1. 稳定匹配算法（Deferred Acceptance）

```matlab
function [matches, wages] = deferred_acceptance_matching(suppliers, demanders, market_params)
    % 实现 Gale-Shapley 延迟接受算法的扩展版本
    % 考虑多对多匹配和工资谈判
    
    n_suppliers = length(suppliers);
    n_demanders = length(demanders);
    
    % 初始化
    matches = [];
    wages = [];
    unmatched_suppliers = 1:n_suppliers;
    
    % 生成偏好列表
    supplier_preferences = generate_supplier_preferences(suppliers, demanders);
    demander_preferences = generate_demander_preferences(demanders, suppliers);
    
    % 迭代匹配过程
    max_iterations = 100;
    iteration = 0;
    
    while ~isempty(unmatched_suppliers) && iteration < max_iterations
        iteration = iteration + 1;
        
        % 供给方提出申请
        for s_idx = unmatched_suppliers
            supplier = suppliers{s_idx};
            
            % 找到下一个偏好的需求方
            next_preference = supplier_preferences{s_idx}(1);
            
            if ~isempty(next_preference)
                demander_idx = next_preference;
                demander = demanders{demander_idx};
                
                % 工资谈判
                proposed_wage = negotiate_wage(supplier, demander, market_params);
                
                % 需求方决策
                decision = demander.evaluate_application(supplier, proposed_wage);
                
                if decision.accept
                    % 临时匹配
                    temp_match = struct('supplier_idx', s_idx, 'demander_idx', demander_idx, ...
                                       'wage', proposed_wage, 'hours', decision.hours);
                    matches = [matches; temp_match];
                    
                    % 更新未匹配列表
                    unmatched_suppliers = setdiff(unmatched_suppliers, s_idx);
                    
                    % 检查需求方是否需要拒绝之前的匹配
                    demander.update_current_matches(temp_match);
                else
                    % 从偏好列表中移除这个需求方
                    supplier_preferences{s_idx}(1) = [];
                end
            else
                % 没有更多偏好，保持未匹配状态
                unmatched_suppliers = setdiff(unmatched_suppliers, s_idx);
            end
        end
    end
    
    % 最终确认匹配并设定工资
    [matches, wages] = finalize_matches(matches, market_params);
end

function preferences = generate_supplier_preferences(suppliers, demanders)
    % 生成供给方对需求方的偏好排序
    preferences = cell(length(suppliers), 1);
    
    for i = 1:length(suppliers)
        supplier = suppliers{i};
        scores = zeros(length(demanders), 1);
        
        for j = 1:length(demanders)
            demander = demanders{j};
            
            % 计算效用得分
            wage_score = demander.expected_wage_offer / supplier.reservation_wage;
            distance_score = exp(-demander.distance_to(supplier) / supplier.commuting_tolerance);
            condition_score = demander.working_conditions_rating / 5;
            
            scores(j) = 0.5 * wage_score + 0.3 * distance_score + 0.2 * condition_score;
        end
        
        % 按得分排序
        [~, sort_idx] = sort(scores, 'descend');
        preferences{i} = sort_idx;
    end
end
```

### 2. 工资决定机制

```matlab
function equilibrium_wage = determine_equilibrium_wage(supply_curve, demand_curve, market_params)
    % 使用迭代方法找到市场均衡工资
    
    wage_min = market_params.minimum_wage;
    wage_max = market_params.maximum_reasonable_wage;
    tolerance = 0.01;
    
    % 二分法搜索均衡点
    while (wage_max - wage_min) > tolerance
        wage_mid = (wage_min + wage_max) / 2;
        
        supply_at_mid = evaluate_supply_curve(supply_curve, wage_mid);
        demand_at_mid = evaluate_demand_curve(demand_curve, wage_mid);
        
        excess_demand = demand_at_mid - supply_at_mid;
        
        if excess_demand > 0
            % 供不应求，提高工资
            wage_min = wage_mid;
        else
            % 供过于求，降低工资
            wage_max = wage_mid;
        end
    end
    
    equilibrium_wage = (wage_min + wage_max) / 2;
end

function wage = negotiate_wage(supplier, demander, market_params)
    % 双边工资谈判
    
    % 供给方保留工资
    reservation_wage = supplier.reservation_wage;
    
    % 需求方最高支付意愿
    max_willingness_to_pay = demander.calculate_marginal_productivity(supplier);
    
    % 如果无交集，无法达成交易
    if reservation_wage > max_willingness_to_pay
        wage = NaN;
        return;
    end
    
    % 使用Nash议价解
    supplier_bargaining_power = supplier.bargaining_power;  % 0-1
    demander_bargaining_power = 1 - supplier_bargaining_power;
    
    wage = reservation_wage^demander_bargaining_power * max_willingness_to_pay^supplier_bargaining_power;
    
    % 添加市场竞争调整
    market_competition_factor = calculate_market_competition(market_params);
    wage = wage * market_competition_factor;
end
```

### 3. 季节性需求预测

```matlab
function seasonal_forecast = forecast_seasonal_labor_demand(agents, climate_forecast, time_horizon)
    % 预测未来几个季节的劳动力需求
    
    seasonal_forecast = struct();
    seasons = {'spring', 'summer', 'autumn', 'winter'};
    
    for t = 1:time_horizon
        for season_idx = 1:length(seasons)
            season = seasons{season_idx};
            
            total_demand = struct();
            
            % 汇总所有需求方的需求
            for agent = agents
                if isa(agent, 'LaborDemanderAgent')
                    agent_demand = agent.forecast_seasonal_demand(season, climate_forecast, t);
                    
                    % 汇总到总需求
                    for category = fieldnames(agent_demand)'
                        cat_name = category{1};
                        if isfield(total_demand, cat_name)
                            total_demand.(cat_name) = total_demand.(cat_name) + agent_demand.(cat_name);
                        else
                            total_demand.(cat_name) = agent_demand.(cat_name);
                        end
                    end
                end
            end
            
            seasonal_forecast.(sprintf('period_%d', t)).(season) = total_demand;
        end
    end
    
    % 添加不确定性分析
    seasonal_forecast.uncertainty = estimate_forecast_uncertainty(climate_forecast);
end
```

---

## 🔧 与现有系统集成

### 更新主模型类

```matlab
% 在 MultiAgentClimatePolicyModel 中添加劳动力市场
classdef MultiAgentClimatePolicyModel < handle
    properties
        % ... 现有属性 ...
        labor_market    % LaborMarketModule instance
    end
    
    methods
        function obj = MultiAgentClimatePolicyModel(params)
            % ... 现有初始化代码 ...
            
            % 初始化劳动力市场
            obj.labor_market = LaborMarketModule(params.labor_market);
        end
        
        function initialize_markets(obj)
            % 更新市场初始化以包含劳动力市场
            obj.markets.pesticide = PesticideMarketModule(...);
            obj.markets.fertilizer = FertilizerMarketModule(...);
            obj.markets.commodity = CommodityMarketModule(...);
            obj.markets.land = LandMarketModule(...);
            obj.markets.labor = obj.labor_market;  % 添加劳动力市场
        end
        
        function step(obj)
            % 更新仿真步骤以包含劳动力市场清算
            
            % 1. 更新政府政策
            obj.government.update_policy(...);
            
            % 2. 劳动力需求预测
            obj.forecast_labor_demand();
            
            % 3. 劳动力市场清算
            obj.labor_market.match_labor_supply_demand(obj.current_time, obj.climate_conditions);
            
            % 4. 其他智能体决策更新
            obj.update_enterprise_decisions();
            obj.update_household_decisions();
            
            % 5. 其他市场撮合
            obj.match_other_markets();
            
            % 6. 结果收集
            obj.collect_results();
        end
    end
end
```

### 更新农户智能体

```matlab
% 扩展 HouseholdAgent 以包含劳动力供给决策
classdef HouseholdAgent < handle
    properties
        % ... 现有属性 ...
        
        % 劳动力相关属性
        labor_endowment = 2000  % 年可工作小时数
        skill_level = 1         % 技能水平
        off_farm_work_history = []  % 外出务工历史
        training_participation = []  % 培训参与历史
    end
    
    methods
        function labor_decision = make_labor_allocation_decision(obj, market_opportunities, own_farm_needs)
            % 劳动力配置决策：自家农场 vs. 外出务工
            
            % 计算自家农场边际产品
            own_farm_marginal_product = obj.calculate_own_farm_marginal_product();
            
            % 评估市场机会
            best_market_opportunity = obj.find_best_market_opportunity(market_opportunities);
            
            if ~isempty(best_market_opportunity) && ...
               best_market_opportunity.wage > own_farm_marginal_product
                % 选择外出务工
                labor_decision = struct('choice', 'off_farm', ...
                                      'hours', best_market_opportunity.hours, ...
                                      'wage', best_market_opportunity.wage);
            else
                % 留在自家农场
                labor_decision = struct('choice', 'own_farm', ...
                                      'hours', own_farm_needs, ...
                                      'wage', own_farm_marginal_product);
            end
        end
        
        function training_decision = evaluate_training_programs(obj, available_programs, subsidies)
            % 评估培训项目的投资价值
            
            best_program = [];
            max_net_present_value = 0;
            
            for program = available_programs
                % 计算培训成本（考虑补贴）
                training_cost = program.cost * (1 - subsidies.training_subsidy_rate);
                
                % 计算预期收益
                expected_wage_increase = obj.estimate_post_training_wage_increase(program);
                discounted_benefits = obj.calculate_discounted_benefits(expected_wage_increase, 10);  % 10年期
                
                % 净现值
                npv = discounted_benefits - training_cost;
                
                if npv > max_net_present_value
                    max_net_present_value = npv;
                    best_program = program;
                end
            end
            
            training_decision = struct('participate', max_net_present_value > 0, ...
                                     'program', best_program, ...
                                     'expected_npv', max_net_present_value);
        end
    end
end
```

### 更新农场智能体

```matlab
% 扩展农场智能体以包含劳动力需求
classdef GrainFarmAgent < handle
    properties
        % ... 现有属性 ...
        
        % 劳动力需求相关
        labor_requirement_calendar  % 全年劳动力需求日历
        current_workforce = struct()  % 当前雇佣的劳动力
        hiring_budget = 50000       % 雇工预算
        preferred_worker_types = {'local', 'experienced'}  % 偏好的工人类型
    end
    
    methods
        function labor_plan = develop_annual_labor_plan(obj, production_plan, climate_forecast)
            % 制定年度劳动力计划
            
            labor_plan = struct();
            
            % 按月份计算劳动力需求
            for month = 1:12
                % 基础劳动力需求
                base_demand = obj.calculate_monthly_base_demand(month, production_plan);
                
                % 气候调整
                climate_factor = obj.estimate_climate_impact_on_labor(month, climate_forecast);
                
                % 技术调整
                tech_factor = 1 - obj.mechanization_level * 0.35;
                
                adjusted_demand = base_demand * climate_factor * tech_factor;
                
                % 分解为不同技能类型
                labor_plan.monthly_demand(month) = obj.allocate_demand_by_skill(adjusted_demand);
            end
            
            % 制定招聘策略
            labor_plan.hiring_strategy = obj.develop_hiring_strategy(labor_plan.monthly_demand);
            
            % 制定培训计划
            labor_plan.training_plan = obj.develop_training_plan(obj.current_workforce);
        end
        
        function cost = calculate_total_labor_cost(obj, labor_plan, wage_rates)
            % 计算总劳动力成本
            
            cost = struct();
            cost.fixed_wages = 0;     % 固定工工资
            cost.seasonal_wages = 0;  % 季节工工资
            cost.training_costs = 0;  % 培训费用
            cost.recruitment_costs = 0;  % 招聘费用
            
            % 计算固定工成本
            for worker = obj.current_workforce.permanent
                cost.fixed_wages = cost.fixed_wages + worker.annual_wage;
            end
            
            % 计算季节工成本
            for month = 1:12
                monthly_seasonal_hours = labor_plan.monthly_demand(month).seasonal;
                monthly_wage_rate = wage_rates.seasonal(month);
                cost.seasonal_wages = cost.seasonal_wages + monthly_seasonal_hours * monthly_wage_rate;
            end
            
            % 计算培训成本
            cost.training_costs = sum([labor_plan.training_plan.cost]);
            
            % 计算招聘成本
            cost.recruitment_costs = obj.estimate_recruitment_costs(labor_plan.hiring_strategy);
            
            cost.total = cost.fixed_wages + cost.seasonal_wages + cost.training_costs + cost.recruitment_costs;
        end
    end
end
```

---

## 📊 参数配置

### 劳动力市场参数

```matlab
labor_market_params = struct( ...
    % 基础市场参数
    'search_cost_factor', 0.05, ...           % 搜寻成本系数
    'geographic_search_radius', 50, ...       % 地理搜寻半径(km)
    'matching_frequency', 1, ...              % 匹配频率(月)
    'wage_adjustment_speed', 0.1, ...         % 工资调整速度
    
    % 技能和培训参数
    'skill_levels', [1, 2, 3, 4, 5], ...     % 技能等级
    'skill_upgrade_time', [6, 12, 18, 24], ... % 技能升级所需时间(月)
    'training_effectiveness', 0.8, ...        % 培训有效性
    'skill_depreciation_rate', 0.02, ...      % 技能折旧率(年)
    
    % 季节性参数
    'seasonal_demand_multipliers', struct( ...
        'spring', struct('unskilled', 1.5, 'skilled', 1.3, 'machinery', 2.0), ...
        'summer', struct('unskilled', 0.8, 'skilled', 1.0, 'machinery', 0.7), ...
        'autumn', struct('unskilled', 1.8, 'skilled', 1.5, 'machinery', 2.2), ...
        'winter', struct('unskilled', 0.3, 'skilled', 0.5, 'machinery', 0.2) ...
    ), ...
    
    % 工资参数
    'minimum_wage', 15, ...                   % 最低工资(元/小时)
    'skill_premium_rates', [1.0, 1.3, 1.6, 2.0, 2.5], ... % 技能溢价率
    'experience_premium_rate', 0.02, ...      % 经验溢价率(每年)
    'overtime_premium_rate', 1.5, ...         % 加班费率
    
    % 政策参数
    'training_subsidy_rate', 0.3, ...         % 培训补贴率
    'employment_subsidy_rate', 0.1, ...       % 就业补贴率
    'rural_employment_bonus', 0.15, ...       % 农村就业奖励
    
    % 行为参数
    'average_bargaining_power', 0.3, ...      % 平均议价能力
    'reservation_wage_factor', 0.8, ...       % 保留工资系数
    'job_search_intensity', 0.7, ...          % 求职强度
    'commuting_cost_per_km', 0.5 ...          % 通勤成本(元/公里)
);
```

### 智能体类型特定参数

```matlab
% 农户劳动力供给参数
household_labor_params = struct( ...
    'work_capacity_distribution', struct('mean', 2000, 'std', 300), ... % 工作能力分布(小时/年)
    'skill_level_distribution', [0.4, 0.3, 0.2, 0.08, 0.02], ...      % 技能水平分布
    'training_willingness_factors', struct( ...
        'age', [-0.02, 0.01, 0.0], ...           % 年龄对培训意愿的影响
        'education', [0.05, 0.03, 0.02], ...     % 教育对培训意愿的影响
        'income', [0.0001, -0.00005] ...         % 收入对培训意愿的影响
    ), ...
    'migration_propensity', 0.15, ...                    % 外出务工倾向
    'family_constraint_factor', 0.3 ...                  % 家庭约束因子
);

% 农场劳动力需求参数
farm_labor_demand_params = struct( ...
    'base_labor_intensity', struct( ...      % 基础劳动强度(小时/亩)
        'grain_crops', 50, ...
        'cash_crops', 80, ...
        'vegetables', 120, ...
        'orchards', 90 ...
    ), ...
    'mechanization_substitution_rate', 0.35, ...         % 机械化替代率
    'climate_sensitivity', struct( ...                   % 气候敏感性
        'temperature', 0.02, ...                         % 温度影响系数
        'precipitation', 0.01, ...                       % 降水影响系数
        'extreme_weather', 0.15 ...                      % 极端天气影响系数
    ), ...
    'quality_preference_weight', 0.6, ...                % 质量偏好权重
    'cost_sensitivity', 0.4 ...                          % 成本敏感性
);
```

---

## 💡 使用示例

### 完整仿真示例

```matlab
%% 1. 初始化劳动力市场模型
clear; clc;

% 设置参数
params = struct();
params.simulation.max_time = 120;  % 10年仿真
params.simulation.time_step = 1;   % 月步长

% 劳动力市场参数
params.labor_market = labor_market_params;
params.household_labor = household_labor_params;
params.farm_labor_demand = farm_labor_demand_params;

% 创建模型
model = MultiAgentClimatePolicyModel(params);

%% 2. 运行基线情形
fprintf('运行基线情形...\n');
baseline_results = model.run_simulation();

%% 3. 政策实验：种粮补贴对劳动力配置的影响
fprintf('运行种粮补贴实验...\n');

% 增加种粮补贴
subsidy_params = params;
subsidy_params.government.grain_subsidy_rate = 0.2;  % 20%种粮补贴

model_subsidy = MultiAgentClimatePolicyModel(subsidy_params);
subsidy_results = model_subsidy.run_simulation();

%% 4. 政策实验：劳动力培训补贴
fprintf('运行培训补贴实验...\n');

% 增加培训补贴
training_params = params;
training_params.labor_market.training_subsidy_rate = 0.5;  % 50%培训补贴

model_training = MultiAgentClimatePolicyModel(training_params);
training_results = model_training.run_simulation();

%% 5. 结果分析和比较
fprintf('\n=== 政策效果对比分析 ===\n');

% 分析劳动力配置效率
analyze_labor_allocation_efficiency(baseline_results, subsidy_results, training_results);

% 分析收入分配效果
analyze_income_distribution_effects(baseline_results, subsidy_results, training_results);

% 分析粮食生产效果
analyze_food_production_effects(baseline_results, subsidy_results, training_results);

%% 6. 生成可视化报告
generate_labor_market_report([baseline_results, subsidy_results, training_results], ...
                            {'Baseline', 'Grain Subsidy', 'Training Subsidy'});
```

### 特定场景分析示例

```matlab
%% 气候冲击对劳动力市场的影响分析

% 设置极端天气情景
climate_shock_scenario = struct( ...
    'type', 'drought', ...
    'intensity', 0.8, ...           % 强度(0-1)
    'duration', 6, ...              % 持续时间(月)
    'affected_regions', [1, 3, 5] ... % 受影响地区
);

% 运行冲击情景
model.apply_climate_shock(climate_shock_scenario);
shock_results = model.run_simulation();

% 分析劳动力市场韧性
resilience_metrics = analyze_labor_market_resilience(baseline_results, shock_results);

fprintf('劳动力市场韧性指标：\n');
fprintf('  恢复时间: %.1f 月\n', resilience_metrics.recovery_time);
fprintf('  工资波动性: %.3f\n', resilience_metrics.wage_volatility);
fprintf('  就业率变化: %.2f%%\n', resilience_metrics.employment_change * 100);
```

### 微观决策分析示例

```matlab
%% 农户劳动力配置决策分析

% 选择典型农户
typical_household = model.households{1};

% 分析不同工资水平下的劳动力供给
wage_range = 10:2:40;  % 工资范围(元/小时)
labor_supply_curve = zeros(size(wage_range));

for i = 1:length(wage_range)
    wage = wage_range(i);
    mock_offer = struct('wage', wage, 'hours', 160, 'location', [0, 0], 'conditions', 3);
    
    supply_decision = typical_household.decide_labor_supply(mock_offer, []);
    labor_supply_curve(i) = supply_decision.hours_supplied;
end

% 绘制劳动力供给曲线
figure;
plot(wage_range, labor_supply_curve, 'b-', 'LineWidth', 2);
xlabel('工资率 (元/小时)');
ylabel('劳动力供给 (小时/月)');
title('典型农户劳动力供给曲线');
grid on;

% 分析培训投资决策
available_programs = model.labor_market.training_programs;
training_decision = typical_household.evaluate_training_programs(available_programs, ...
                                                               model.government.training_subsidies);

fprintf('培训决策分析：\n');
if training_decision.participate
    fprintf('  选择参与培训: %s\n', training_decision.program.name);
    fprintf('  预期净现值: %.0f 元\n', training_decision.expected_npv);
else
    fprintf('  选择不参与培训\n');
end
```

### 政策优化示例

```matlab
%% 劳动力政策组合优化

% 定义政策空间
policy_space = struct( ...
    'training_subsidy_rate', 0:0.1:0.8, ...        % 培训补贴率
    'employment_subsidy_rate', 0:0.05:0.3, ...     % 就业补贴率
    'minimum_wage', 12:2:24 ...                    % 最低工资
);

% 定义优化目标
objectives = struct( ...
    'employment_rate', 0.4, ...                    % 就业率权重
    'wage_level', 0.3, ...                        % 工资水平权重
    'skill_upgrading', 0.2, ...                   % 技能提升权重
    'food_production', 0.1 ...                    % 粮食生产权重
);

% 运行政策优化
optimal_policy = optimize_labor_market_policy(model, policy_space, objectives);

fprintf('最优劳动力政策组合：\n');
fprintf('  培训补贴率: %.1f%%\n', optimal_policy.training_subsidy_rate * 100);
fprintf('  就业补贴率: %.1f%%\n', optimal_policy.employment_subsidy_rate * 100);
fprintf('  最低工资: %.0f 元/小时\n', optimal_policy.minimum_wage);
fprintf('  预期综合效用: %.3f\n', optimal_policy.expected_utility);
```

---

## 🔍 模块验证和测试

### 单元测试

```matlab
function test_labor_market_module()
    % 劳动力市场模块单元测试
    
    fprintf('开始劳动力市场模块测试...\n');
    
    % 测试1：基本匹配算法
    test_basic_matching();
    
    % 测试2：工资决定机制
    test_wage_determination();
    
    % 测试3：季节性需求预测
    test_seasonal_forecasting();
    
    % 测试4：政策影响分析
    test_policy_impact_analysis();
    
    fprintf('所有测试完成！\n');
end

function test_basic_matching()
    fprintf('  测试基本匹配算法...');
    
    % 创建测试数据
    suppliers = create_test_suppliers(10);
    demanders = create_test_demanders(5);
    
    % 运行匹配算法
    labor_market = LaborMarketModule(struct());
    [matches, wages] = labor_market.match_labor_supply_demand(suppliers, demanders);
    
    % 验证结果
    assert(~isempty(matches), '匹配结果不应为空');
    assert(all(wages > 0), '工资应为正数');
    assert(length(unique([matches.supplier_idx])) == length([matches.supplier_idx]), ...
           '每个供给方最多匹配一次');
    
    fprintf(' 通过\n');
end

function test_wage_determination()
    fprintf('  测试工资决定机制...');
    
    % 创建测试市场条件
    supply_curve = @(w) 100 * w^0.5;  % 供给曲线
    demand_curve = @(w) 500 - 10 * w;  % 需求曲线
    
    % 计算均衡工资
    market_params = struct('minimum_wage', 10, 'maximum_reasonable_wage', 50);
    eq_wage = determine_equilibrium_wage(supply_curve, demand_curve, market_params);
    
    % 验证均衡条件
    supply_at_eq = supply_curve(eq_wage);
    demand_at_eq = demand_curve(eq_wage);
    
    assert(abs(supply_at_eq - demand_at_eq) < 1, '供需应基本平衡');
    assert(eq_wage >= market_params.minimum_wage, '工资不应低于最低工资');
    
    fprintf(' 通过\n');
end
```

---

这个劳动力市场模块设计为您的多智能体气候政策模型提供了完整的劳动力动态建模能力。它能够很好地支持您关于气候变化适应性、种粮补贴效果和政策-微观决策匹配的研究问题。

您希望我进一步细化某个特定功能，或者开始实现具体的代码文件吗？ 