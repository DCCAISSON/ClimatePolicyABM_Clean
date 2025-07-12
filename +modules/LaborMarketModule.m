% Version: 2.0-Simplified | Package: modules
% Version: 2.0-Simplified | Package: modules
classdef modules.modules
    % 劳动力市场模块
    % 处理农业劳动力的供需匹配、工资决定和技能发展
    
    properties
        % 市场参与者
        labor_suppliers     % cell array of LaborSupplierAgent
        labor_demanders     % cell array of LaborDemanderAgent
        
        % 劳动力分类和等级
        labor_categories = {'unskilled', 'skilled', 'machinery_operator', 'seasonal', 'management'}
        skill_levels = [1, 2, 3, 4, 5]
        
        % 市场状态
        current_wage_rates  % struct with wage rates by category
        employment_levels   % struct with employment by category
        unemployment_rate   % overall unemployment rate
        total_matches       % total number of matches
        
        % 季节性参数
        seasonal_demand_multipliers
        current_season = 'spring'
        peak_seasons = {'spring_planting', 'summer_management', 'autumn_harvest'}
        
        % 匹配机制参数
        matching_algorithm = 'deferred_acceptance'
        search_cost_factor = 0.05
        geographic_search_radius = 50  % km
        wage_elasticity = 0.3
        
        % 培训和技能发展
        training_programs
        skill_upgrade_cost
        training_effectiveness = 0.8
        
        % 政策工具
        minimum_wage = 15           % 元/小时
        training_subsidies = struct()
        employment_subsidies = struct()
        
        % 市场参数
        params
    end
    
    methods
        function obj = LaborMarketModule(params)
            % 构造函数
            if nargin > 0
                obj.params = params;
                obj.initialize_market(params);
            else
                obj.initialize_default_market();
            end
        end
        
        function initialize_market(obj, params)
            % 初始化市场
            
            % 设置基本参数
            if isfield(params, 'minimum_wage')
                obj.minimum_wage = params.minimum_wage;
            end
            
            if isfield(params, 'search_cost_factor')
                obj.search_cost_factor = params.search_cost_factor;
            end
            
            if isfield(params, 'geographic_search_radius')
                obj.geographic_search_radius = params.geographic_search_radius;
            end
            
            % 初始化季节性需求倍数
            obj.initialize_seasonal_multipliers();
            
            % 初始化培训项目
            obj.initialize_training_programs();
            
            % 初始化工资率
            obj.initialize_wage_rates();
            
            % 初始化智能体容器
            obj.labor_suppliers = {};
            obj.labor_demanders = {};
            
            fprintf('劳动力市场模块初始化完成\n');
        end
        
        function initialize_default_market(obj)
            % 使用默认参数初始化市场
            default_params = struct();
            default_params.minimum_wage = 15;
            default_params.search_cost_factor = 0.05;
            default_params.geographic_search_radius = 50;
            
            obj.initialize_market(default_params);
        end
        
        function initialize_seasonal_multipliers(obj)
            % 初始化季节性需求倍数
            obj.seasonal_demand_multipliers = struct();
            
            % 春季（播种期）
            obj.seasonal_demand_multipliers.spring = struct( ...
                'unskilled', 1.5, ...
                'skilled', 1.3, ...
                'machinery_operator', 2.0, ...
                'seasonal', 1.8, ...
                'management', 1.2 ...
            );
            
            % 夏季（管理期）
            obj.seasonal_demand_multipliers.summer = struct( ...
                'unskilled', 0.8, ...
                'skilled', 1.0, ...
                'machinery_operator', 0.7, ...
                'seasonal', 0.6, ...
                'management', 1.0 ...
            );
            
            % 秋季（收获期）
            obj.seasonal_demand_multipliers.autumn = struct( ...
                'unskilled', 1.8, ...
                'skilled', 1.5, ...
                'machinery_operator', 2.2, ...
                'seasonal', 2.0, ...
                'management', 1.4 ...
            );
            
            % 冬季（休息期）
            obj.seasonal_demand_multipliers.winter = struct( ...
                'unskilled', 0.3, ...
                'skilled', 0.5, ...
                'machinery_operator', 0.2, ...
                'seasonal', 0.1, ...
                'management', 0.8 ...
            );
        end
        
        function initialize_training_programs(obj)
            % 初始化培训项目
            obj.training_programs = struct();
            
            % 技术技能培训
            obj.training_programs.technical_skills = struct( ...
                'id', 1, ...
                'name', '技术技能培训', ...
                'duration', 6, ...
                'cost', 3000, ...
                'skill_improvement', 1, ...
                'success_rate', 0.85, ...
                'target_group', 'unskilled', ...
                'capacity', 50 ...
            );
            
            % 机械操作培训
            obj.training_programs.machinery_operation = struct( ...
                'id', 2, ...
                'name', '机械操作培训', ...
                'duration', 3, ...
                'cost', 5000, ...
                'skill_improvement', 2, ...
                'success_rate', 0.75, ...
                'target_group', 'skilled', ...
                'capacity', 30 ...
            );
            
            % 管理技能培训
            obj.training_programs.management_skills = struct( ...
                'id', 3, ...
                'name', '管理技能培训', ...
                'duration', 12, ...
                'cost', 8000, ...
                'skill_improvement', 2, ...
                'success_rate', 0.70, ...
                'target_group', 'experienced', ...
                'capacity', 20 ...
            );
        end
        
        function initialize_wage_rates(obj)
            % 初始化工资率
            skill_premium_rates = [1.0, 1.3, 1.6, 2.0, 2.5];
            
            obj.current_wage_rates = struct();
            for i = 1:length(obj.labor_categories)
                category = obj.labor_categories{i};
                base_premium = skill_premium_rates(min(i, length(skill_premium_rates)));
                obj.current_wage_rates.(category) = obj.minimum_wage * base_premium;
            end
        end
        
        function add_supplier(obj, supplier)
            % 添加劳动力供给方
            obj.labor_suppliers{end+1} = supplier;
        end
        
        function add_demander(obj, demander)
            % 添加劳动力需求方
            obj.labor_demanders{end+1} = demander;
        end
        
        function [matches, wages] = match_labor_supply_demand(obj, time_period, climate_conditions)
            % 劳动力供需匹配主算法
            
            if nargin < 3
                climate_conditions = struct('temperature', 20, 'precipitation', 100, 'extreme_events', 0);
            end
            
            if isempty(obj.labor_suppliers) || isempty(obj.labor_demanders)
                warning('劳动力供给方或需求方为空，无法进行匹配');
                matches = [];
                wages = obj.current_wage_rates;
                return;
            end
            
            % 根据匹配算法选择匹配方法
            switch obj.matching_algorithm
                case 'deferred_acceptance'
                    [matches, wages] = obj.deferred_acceptance_matching(time_period, climate_conditions);
                case 'simple_matching'
                    [matches, wages] = obj.simple_matching(time_period, climate_conditions);
                otherwise
                    error('未知的匹配算法: %s', obj.matching_algorithm);
            end
            
            % 更新市场状态
            obj.update_market_state(matches, wages);
            
            % 记录匹配结果
            obj.total_matches = length(matches);
            
            fprintf('时间周期 %d: 成功匹配 %d 对劳动力供需\n', time_period, length(matches));
        end
        
        function [matches, wages] = deferred_acceptance_matching(obj, time_period, climate_conditions)
            % 延迟接受匹配算法（Gale-Shapley扩展）
            
            n_suppliers = length(obj.labor_suppliers);
            n_demanders = length(obj.labor_demanders);
            
            % 初始化
            matches = [];
            unmatched_suppliers = 1:n_suppliers;
            
            % 生成偏好列表
            [supplier_preferences, demander_preferences] = obj.generate_preference_lists();
            
            % 初始化需求方的临时匹配
            demander_temp_matches = cell(n_demanders, 1);
            
            % 迭代匹配过程
            max_iterations = 100;
            iteration = 0;
            
            while ~isempty(unmatched_suppliers) && iteration < max_iterations
                iteration = iteration + 1;
                new_unmatched = [];
                
                for s_idx = unmatched_suppliers
                    if ~isempty(supplier_preferences{s_idx})
                        % 获取下一个偏好的需求方
                        d_idx = supplier_preferences{s_idx}(1);
                        supplier_preferences{s_idx}(1) = [];
                        
                        % 工资谈判
                        proposed_wage = obj.negotiate_wage(obj.labor_suppliers{s_idx}, ...
                                                         obj.labor_demanders{d_idx}, ...
                                                         climate_conditions);
                        
                        % 需求方决策
                        if obj.labor_demanders{d_idx}.can_afford_wage(proposed_wage)
                            % 创建临时匹配
                            temp_match = struct('supplier_idx', s_idx, ...
                                              'demander_idx', d_idx, ...
                                              'wage', proposed_wage, ...
                                              'hours', obj.labor_suppliers{s_idx}.available_work_hours / 12); % 月工作小时
                            
                            % 需求方评估是否接受
                            current_matches = demander_temp_matches{d_idx};
                            if obj.should_accept_match(obj.labor_demanders{d_idx}, temp_match, current_matches)
                                % 接受匹配，可能需要拒绝之前的匹配
                                [demander_temp_matches{d_idx}, rejected_suppliers] = ...
                                    obj.update_demander_matches(d_idx, temp_match, current_matches);
                                
                                % 将被拒绝的供给方重新加入未匹配列表
                                new_unmatched = [new_unmatched, rejected_suppliers];
                            else
                                new_unmatched = [new_unmatched, s_idx];
                            end
                        else
                            new_unmatched = [new_unmatched, s_idx];
                        end
                    end
                end
                
                unmatched_suppliers = new_unmatched;
            end
            
            % 整理最终匹配结果
            matches = [];
            for d_idx = 1:n_demanders
                if ~isempty(demander_temp_matches{d_idx})
                    matches = [matches; demander_temp_matches{d_idx}];
                end
            end
            
            % 计算均衡工资
            wages = obj.calculate_equilibrium_wages(matches);
        end
        
        function [supplier_prefs, demander_prefs] = generate_preference_lists(obj)
            % 生成供需双方的偏好列表
            
            n_suppliers = length(obj.labor_suppliers);
            n_demanders = length(obj.labor_demanders);
            
            supplier_prefs = cell(n_suppliers, 1);
            demander_prefs = cell(n_demanders, 1);
            
            % 生成供给方偏好（按期望效用排序）
            for s_idx = 1:n_suppliers
                supplier = obj.labor_suppliers{s_idx};
                scores = zeros(n_demanders, 1);
                
                for d_idx = 1:n_demanders
                    demander = obj.labor_demanders{d_idx};
                    scores(d_idx) = obj.calculate_supplier_utility(supplier, demander);
                end
                
                [~, sort_idx] = sort(scores, 'descend');
                supplier_prefs{s_idx} = sort_idx;
            end
            
            % 生成需求方偏好（按生产力-成本比排序）
            for d_idx = 1:n_demanders
                demander = obj.labor_demanders{d_idx};
                scores = zeros(n_suppliers, 1);
                
                for s_idx = 1:n_suppliers
                    supplier = obj.labor_suppliers{s_idx};
                    scores(s_idx) = obj.calculate_demander_utility(demander, supplier);
                end
                
                [~, sort_idx] = sort(scores, 'descend');
                demander_prefs{d_idx} = sort_idx;
            end
        end
        
        function utility = calculate_supplier_utility(obj, supplier, demander)
            % 计算供给方对需求方的效用
            
            % 预期工资效用
            expected_wage = obj.estimate_wage_offer(demander, supplier);
            wage_utility = expected_wage / supplier.reservation_wage;
            
            % 距离成本
            distance = obj.calculate_distance(supplier.location, demander.location);
            distance_cost = exp(-distance / supplier.commuting_tolerance);
            
            % 工作条件效用
            condition_utility = demander.working_conditions_rating / 5;
            
            % 综合效用
            utility = 0.5 * wage_utility + 0.3 * distance_cost + 0.2 * condition_utility;
        end
        
        function utility = calculate_demander_utility(obj, demander, supplier)
            % 计算需求方对供给方的效用
            
            % 生产力评估
            productivity = obj.estimate_productivity(supplier, demander);
            
            % 预期工资成本
            expected_wage = obj.estimate_wage_offer(demander, supplier);
            
            % 性价比
            if expected_wage > 0
                value_ratio = productivity / expected_wage;
            else
                value_ratio = productivity;
            end
            
            % 技能匹配度
            skill_match = obj.calculate_skill_match(supplier, demander);
            
            % 综合效用
            utility = 0.6 * value_ratio + 0.4 * skill_match;
        end
        
        function wage = negotiate_wage(obj, supplier, demander, climate_conditions)
            % 工资谈判
            
            % 供给方保留工资
            reservation_wage = supplier.reservation_wage;
            
            % 需求方最高支付意愿
            max_willingness = demander.calculate_max_wage_offer(supplier);
            
            % 如果无交集，返回NaN
            if reservation_wage > max_willingness
                wage = NaN;
                return;
            end
            
            % Nash议价解
            supplier_power = supplier.bargaining_power;
            demander_power = 1 - supplier_power;
            
            wage = reservation_wage^demander_power * max_willingness^supplier_power;
            
            % 市场竞争调整
            market_factor = obj.calculate_market_competition_factor();
            wage = wage * market_factor;
            
            % 气候影响调整
            climate_factor = obj.calculate_climate_wage_adjustment(climate_conditions);
            wage = wage * climate_factor;
        end
        
        function should_accept = should_accept_match(obj, demander, new_match, current_matches)
            % 判断需求方是否应该接受新的匹配
            
            if isempty(current_matches)
                should_accept = true;
                return;
            end
            
            % 计算当前匹配的总效用
            current_utility = obj.calculate_total_match_utility(demander, current_matches);
            
            % 计算加入新匹配后的总效用
            proposed_matches = [current_matches; new_match];
            proposed_utility = obj.calculate_total_match_utility(demander, proposed_matches);
            
            should_accept = proposed_utility > current_utility;
        end
        
        function wages = calculate_equilibrium_wages(obj, matches)
            % 计算均衡工资
            
            wages = struct();
            
            for i = 1:length(obj.labor_categories)
                category = obj.labor_categories{i};
                category_wages = [];
                
                for j = 1:length(matches)
                    match = matches(j);
                    supplier = obj.labor_suppliers{match.supplier_idx};
                    if ismember(category, supplier.labor_categories)
                        category_wages = [category_wages, match.wage];
                    end
                end
                
                if ~isempty(category_wages)
                    wages.(category) = mean(category_wages);
                else
                    wages.(category) = obj.current_wage_rates.(category);
                end
            end
        end
        
        function wage_rate = determine_wage_rate(obj, labor_category, supply, demand, location)
            % 工资率决定机制
            
            % 基础工资（最低工资 + 技能溢价）
            skill_premium_rates = [1.0, 1.3, 1.6, 2.0, 2.5];
            category_idx = find(strcmp(obj.labor_categories, labor_category));
            if isempty(category_idx)
                category_idx = 1;
            end
            
            base_wage = obj.minimum_wage * skill_premium_rates(min(category_idx, length(skill_premium_rates)));
            
            % 供需调整
            if supply > 0
                supply_demand_factor = (demand / supply)^obj.wage_elasticity;
            else
                supply_demand_factor = 2.0; % 供给极度短缺
            end
            
            % 地区调整（简化版本）
            location_factor = 1.0; % 可以根据location参数实现更复杂的地区调整
            
            % 季节性调整
            seasonal_factor = obj.seasonal_demand_multipliers.(obj.current_season).(labor_category);
            
            % 最终工资率
            wage_rate = base_wage * supply_demand_factor * location_factor * seasonal_factor;
        end
        
        function demand_forecast = forecast_seasonal_demand(obj, climate_forecast, crop_plans)
            % 季节性劳动力需求预测
            
            if nargin < 2
                climate_forecast = struct('temperature_change', 0, 'precipitation_change', 0);
            end
            if nargin < 3
                crop_plans = []; % 如果没有提供作物计划，使用默认值
            end
            
            demand_forecast = struct();
            seasons = fieldnames(obj.seasonal_demand_multipliers);
            
            for i = 1:length(seasons)
                season = seasons{i};
                seasonal_demand = struct();
                
                for j = 1:length(obj.labor_categories)
                    category = obj.labor_categories{j};
                    
                    % 基础需求（从当前需求方聚合）
                    base_demand = obj.calculate_base_demand(category);
                    
                    % 季节性调整
                    seasonal_factor = obj.seasonal_demand_multipliers.(season).(category);
                    
                    % 气候影响调整
                    climate_factor = obj.calculate_climate_impact(climate_forecast, season);
                    
                    % 最终预测需求
                    seasonal_demand.(category) = base_demand * seasonal_factor * climate_factor;
                end
                
                demand_forecast.(season) = seasonal_demand;
            end
            
            % 添加不确定性估计
            demand_forecast.uncertainty = obj.estimate_forecast_uncertainty(climate_forecast);
        end
        
        function base_demand = calculate_base_demand(obj, category)
            % 计算基础劳动力需求
            
            base_demand = 0;
            for i = 1:length(obj.labor_demanders)
                demander = obj.labor_demanders{i};
                if demander.requires_labor_category(category)
                    base_demand = base_demand + demander.get_category_demand(category);
                end
            end
        end
        
        function climate_factor = calculate_climate_impact(obj, climate_forecast, season)
            % 计算气候对劳动力需求的影响
            
            % 基础气候影响系数
            base_factor = 1.0;
            
            % 温度影响
            if isfield(climate_forecast, 'temperature_change')
                temp_change = climate_forecast.temperature_change;
                temp_impact = 1 + 0.02 * temp_change; % 温度每升高1度，需求增加2%
                base_factor = base_factor * temp_impact;
            end
            
            % 降水影响
            if isfield(climate_forecast, 'precipitation_change')
                precip_change = climate_forecast.precipitation_change;
                precip_impact = 1 + 0.01 * precip_change / 100; % 降水变化1%，需求变化0.01%
                base_factor = base_factor * precip_impact;
            end
            
            % 极端天气影响
            if isfield(climate_forecast, 'extreme_events') && climate_forecast.extreme_events > 0
                extreme_impact = 1.15; % 极端天气增加15%劳动力需求
                base_factor = base_factor * extreme_impact;
            end
            
            climate_factor = base_factor;
        end
        
        function update_market_state(obj, matches, wages)
            % 更新市场状态
            
            % 更新工资率
            obj.current_wage_rates = wages;
            
            % 更新就业水平
            obj.employment_levels = struct();
            for i = 1:length(obj.labor_categories)
                category = obj.labor_categories{i};
                employed_count = 0;
                total_count = 0;
                
                for j = 1:length(obj.labor_suppliers)
                    supplier = obj.labor_suppliers{j};
                    if ismember(category, supplier.labor_categories)
                        total_count = total_count + 1;
                        
                        % 检查是否被匹配
                        for k = 1:length(matches)
                            if matches(k).supplier_idx == j
                                employed_count = employed_count + 1;
                                break;
                            end
                        end
                    end
                end
                
                if total_count > 0
                    obj.employment_levels.(category) = employed_count / total_count;
                else
                    obj.employment_levels.(category) = 0;
                end
            end
            
            % 更新总体失业率
            total_suppliers = length(obj.labor_suppliers);
            total_matched = length(matches);
            if total_suppliers > 0
                obj.unemployment_rate = 1 - (total_matched / total_suppliers);
            else
                obj.unemployment_rate = 0;
            end
        end
        
        function distance = calculate_distance(obj, loc1, loc2)
            % 计算两点间距离（简化版本）
            if length(loc1) >= 2 && length(loc2) >= 2
                distance = sqrt((loc1(1) - loc2(1))^2 + (loc1(2) - loc2(2))^2);
            else
                distance = 0;
            end
        end
        
        function wage_offer = estimate_wage_offer(obj, demander, supplier)
            % 估计需求方对供给方的工资报价
            
            % 获取供给方主要技能类别
            if ~isempty(supplier.labor_categories)
                category = supplier.labor_categories{1};
                base_wage = obj.current_wage_rates.(category);
            else
                base_wage = obj.minimum_wage;
            end
            
            % 根据需求方支付能力调整
            affordability_factor = min(1.5, demander.max_wage_budget / (base_wage * 2000));
            
            wage_offer = base_wage * affordability_factor;
        end
        
        function productivity = estimate_productivity(obj, supplier, demander)
            % 估计供给方在需求方的生产力
            
            % 基础生产力（基于技能等级）
            base_productivity = supplier.skill_level * 10;
            
            % 经验调整
            experience_factor = 1 + supplier.experience_years * 0.02;
            
            % 技术匹配调整
            tech_match = obj.calculate_technology_match(supplier, demander);
            
            productivity = base_productivity * experience_factor * tech_match;
        end
        
        function match_score = calculate_skill_match(obj, supplier, demander)
            % 计算技能匹配度
            
            required_skills = demander.required_skill_levels;
            available_skills = supplier.skill_level;
            
            if isempty(required_skills)
                match_score = 0.5; % 默认匹配度
            else
                % 计算技能差距
                skill_gap = abs(available_skills - mean(required_skills));
                match_score = exp(-skill_gap / 2); % 指数衰减函数
            end
        end
        
        function tech_match = calculate_technology_match(obj, supplier, demander)
            % 计算技术匹配度
            
            % 简化版本：基于供给方是否具备需求方要求的技能类别
            required_categories = demander.required_labor_categories;
            available_categories = supplier.labor_categories;
            
            if isempty(required_categories) || isempty(available_categories)
                tech_match = 1.0;
            else
                overlap = intersect(required_categories, available_categories);
                match_ratio = length(overlap) / length(required_categories);
                tech_match = 0.5 + 0.5 * match_ratio; % 0.5到1.0之间
            end
        end
        
        function market_factor = calculate_market_competition_factor(obj)
            % 计算市场竞争因子
            
            % 基于供需比例的竞争强度
            total_supply = length(obj.labor_suppliers);
            total_demand = length(obj.labor_demanders);
            
            if total_supply > 0 && total_demand > 0
                supply_demand_ratio = total_demand / total_supply;
                market_factor = 0.8 + 0.4 * min(supply_demand_ratio, 2); % 0.8到1.6之间
            else
                market_factor = 1.0;
            end
        end
        
        function climate_factor = calculate_climate_wage_adjustment(obj, climate_conditions)
            % 计算气候对工资的调整因子
            
            climate_factor = 1.0;
            
            % 极端天气增加工资
            if isfield(climate_conditions, 'extreme_events') && climate_conditions.extreme_events > 0
                climate_factor = climate_factor * 1.05; % 增加5%
            end
            
            % 温度影响
            if isfield(climate_conditions, 'temperature')
                temp = climate_conditions.temperature;
                if temp > 35 || temp < 0 % 极端温度
                    climate_factor = climate_factor * 1.03; % 增加3%
                end
            end
        end
        
        function total_utility = calculate_total_match_utility(obj, demander, matches)
            % 计算需求方的总匹配效用
            
            total_utility = 0;
            total_cost = 0;
            
            for i = 1:length(matches)
                match = matches(i);
                supplier = obj.labor_suppliers{match.supplier_idx};
                
                % 生产力贡献
                productivity = obj.estimate_productivity(supplier, demander);
                total_utility = total_utility + productivity * match.hours;
                
                % 工资成本
                total_cost = total_cost + match.wage * match.hours;
            end
            
            % 净效用 = 生产价值 - 工资成本
            total_utility = total_utility - total_cost;
        end
        
        function [updated_matches, rejected_suppliers] = update_demander_matches(obj, demander_idx, new_match, current_matches)
            % 更新需求方的匹配，可能拒绝之前的匹配
            
            demander = obj.labor_demanders{demander_idx};
            rejected_suppliers = [];
            
            % 检查是否超出预算
            total_cost = new_match.wage * new_match.hours;
            for i = 1:length(current_matches)
                total_cost = total_cost + current_matches(i).wage * current_matches(i).hours;
            end
            
            if total_cost <= demander.max_wage_budget
                % 预算内，直接添加
                updated_matches = [current_matches; new_match];
            else
                % 超出预算，需要选择最优组合
                all_matches = [current_matches; new_match];
                [updated_matches, rejected_suppliers] = obj.select_optimal_matches(demander, all_matches);
            end
        end
        
        function [optimal_matches, rejected_suppliers] = select_optimal_matches(obj, demander, candidate_matches)
            % 为需求方选择最优匹配组合
            
            % 简化版本：使用贪心算法选择性价比最高的匹配
            value_ratios = zeros(length(candidate_matches), 1);
            
            for i = 1:length(candidate_matches)
                match = candidate_matches(i);
                supplier = obj.labor_suppliers{match.supplier_idx};
                productivity = obj.estimate_productivity(supplier, demander);
                value_ratios(i) = (productivity * match.hours) / (match.wage * match.hours);
            end
            
            % 按性价比排序
            [~, sort_idx] = sort(value_ratios, 'descend');
            sorted_matches = candidate_matches(sort_idx);
            
            % 贪心选择
            optimal_matches = [];
            total_cost = 0;
            rejected_suppliers = [];
            
            for i = 1:length(sorted_matches)
                match = sorted_matches(i);
                cost = match.wage * match.hours;
                
                if total_cost + cost <= demander.max_wage_budget
                    optimal_matches = [optimal_matches; match];
                    total_cost = total_cost + cost;
                else
                    rejected_suppliers = [rejected_suppliers, match.supplier_idx];
                end
            end
        end
        
        function uncertainty = estimate_forecast_uncertainty(obj, climate_forecast)
            % 估计预测不确定性
            
            base_uncertainty = 0.1; % 基础不确定性10%
            
            % 气候变化增加不确定性
            if isfield(climate_forecast, 'temperature_change')
                temp_uncertainty = abs(climate_forecast.temperature_change) * 0.02;
                base_uncertainty = base_uncertainty + temp_uncertainty;
            end
            
            if isfield(climate_forecast, 'precipitation_change')
                precip_uncertainty = abs(climate_forecast.precipitation_change) * 0.001;
                base_uncertainty = base_uncertainty + precip_uncertainty;
            end
            
            uncertainty = min(base_uncertainty, 0.5); % 最大50%不确定性
        end
        
        function set_season(obj, season)
            % 设置当前季节
            valid_seasons = {'spring', 'summer', 'autumn', 'winter'};
            if ismember(season, valid_seasons)
                obj.current_season = season;
                fprintf('当前季节设置为: %s\n', season);
            else
                warning('无效的季节: %s', season);
            end
        end
        
        function summary = get_market_summary(obj)
            % 获取市场摘要
            
            summary = struct();
            summary.total_suppliers = length(obj.labor_suppliers);
            summary.total_demanders = length(obj.labor_demanders);
            summary.total_matches = obj.total_matches;
            summary.unemployment_rate = obj.unemployment_rate;
            summary.current_wage_rates = obj.current_wage_rates;
            summary.employment_levels = obj.employment_levels;
            summary.current_season = obj.current_season;
        end
        
        function print_market_status(obj)
            % 打印市场状态
            
            fprintf('\n=== 劳动力市场状态 ===\n');
            fprintf('供给方数量: %d\n', length(obj.labor_suppliers));
            fprintf('需求方数量: %d\n', length(obj.labor_demanders));
            fprintf('总匹配数: %d\n', obj.total_matches);
            fprintf('失业率: %.2f%%\n', obj.unemployment_rate * 100);
            fprintf('当前季节: %s\n', obj.current_season);
            
            fprintf('\n当前工资率:\n');
            categories = fieldnames(obj.current_wage_rates);
            for i = 1:length(categories)
                category = categories{i};
                wage = obj.current_wage_rates.(category);
                fprintf('  %s: %.2f 元/小时\n', category, wage);
            end
            
            fprintf('\n就业水平:\n');
            if ~isempty(obj.employment_levels)
                categories = fieldnames(obj.employment_levels);
                for i = 1:length(categories)
                    category = categories{i};
                    level = obj.employment_levels.(category);
                    fprintf('  %s: %.2f%%\n', category, level * 100);
                end
            end
            fprintf('===================\n\n');
        end
    end
end 
