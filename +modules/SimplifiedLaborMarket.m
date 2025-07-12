% Version: 2.0-Simplified | Package: modules
% Version: 2.0-Simplified | Package: modules
classdef modules.modules
    % 简化的劳动力市场模块
    % 专注于农户作为劳动力供给者为农业企业提供非农务工服务
    
    properties
        % 市场参与者
        farmer_labor_suppliers = {}    % 农户劳动力供给者
        enterprise_labor_demanders = {} % 企业劳动力需求者
        
        % 市场状态
        current_wage_rates = struct()  % 当前工资率
        employment_matches = []        % 就业匹配记录
        total_labor_supply = 0         % 总劳动力供给
        total_labor_demand = 0         % 总劳动力需求
        
        % 工资决定机制
        base_wage_rates = struct()     % 基础工资率
        wage_adjustment_factor = 0.1   % 工资调整因子
        
        % 匹配参数
        matching_efficiency = 0.8      % 匹配效率
        search_cost = 100              % 搜索成本（元）
        transportation_cost_per_km = 2 % 交通成本（元/公里）
        
        % 技能分类（简化）
        skill_categories = {'unskilled', 'skilled'} % 简化为两类
        
        % 季节性因素
        seasonal_factors = struct()    % 季节性调整因子
        current_season = 'spring'      % 当前季节
        
        % 市场统计
        unemployment_rate = 0.05       % 失业率
        average_wage = 150             % 平均日工资
        market_tightness = 0.5         % 市场紧张度
    end
    
    methods
        function obj = SimplifiedLaborMarket(params)
            % 构造函数
            
            if nargin > 0 && ~isempty(params)
                obj.initialize_market_parameters(params);
            else
                obj.initialize_default_parameters();
            end
            
            obj.initialize_seasonal_factors();
            obj.initialize_wage_structure();
            
            fprintf('简化劳动力市场初始化完成\n');
        end
        
        function initialize_market_parameters(obj, params)
            % 初始化市场参数
            
            if isfield(params, 'matching_efficiency')
                obj.matching_efficiency = params.matching_efficiency;
            end
            
            if isfield(params, 'search_cost')
                obj.search_cost = params.search_cost;
            end
            
            if isfield(params, 'average_wage')
                obj.average_wage = params.average_wage;
            end
        end
        
        function initialize_default_parameters(obj)
            % 初始化默认参数
            obj.matching_efficiency = 0.8;
            obj.search_cost = 100;
            obj.transportation_cost_per_km = 2;
            obj.average_wage = 150;
        end
        
        function initialize_seasonal_factors(obj)
            % 初始化季节性因子
            
            obj.seasonal_factors.spring = struct('demand_factor', 1.3, 'wage_factor', 1.1);  % 春耕高峰
            obj.seasonal_factors.summer = struct('demand_factor', 1.0, 'wage_factor', 1.0);  % 常规期
            obj.seasonal_factors.autumn = struct('demand_factor', 1.5, 'wage_factor', 1.2);  % 秋收高峰
            obj.seasonal_factors.winter = struct('demand_factor', 0.6, 'wage_factor', 0.9);  % 淡季
        end
        
        function initialize_wage_structure(obj)
            % 初始化工资结构
            
            obj.base_wage_rates.unskilled = obj.average_wage * 0.8;  % 非技能工：120元/天
            obj.base_wage_rates.skilled = obj.average_wage * 1.4;    % 技能工：210元/天
            
            obj.current_wage_rates = obj.base_wage_rates;
        end
        
        function add_farmer_supplier(obj, farmer_agent)
            % 添加农户劳动力供给者
            
            labor_supply_info = struct();
            labor_supply_info.farmer_id = farmer_agent.agent_id;
            labor_supply_info.available_hours = farmer_agent.labor_endowment;
            labor_supply_info.farm_labor_needs = farmer_agent.land_holding * 20; % 每亩20小时
            labor_supply_info.off_farm_hours = max(0, labor_supply_info.available_hours - labor_supply_info.farm_labor_needs);
            labor_supply_info.skill_level = obj.determine_farmer_skill_level(farmer_agent);
            labor_supply_info.location = [rand()*100, rand()*100]; % 简化位置
            labor_supply_info.reservation_wage = obj.calculate_reservation_wage(farmer_agent);
            labor_supply_info.transportation_tolerance = 30; % 30公里通勤容忍度
            
            obj.farmer_labor_suppliers{end+1} = labor_supply_info;
            
            fprintf('农户 %d 加入劳动力市场，可供给 %.0f 小时\n', ...
                    farmer_agent.agent_id, labor_supply_info.off_farm_hours);
        end
        
        function add_enterprise_demander(obj, enterprise_agent)
            % 添加企业劳动力需求者
            
            if isfield(enterprise_agent, 'labor_demand') && ~isempty(enterprise_agent.labor_demand)
                labor_demand_info = enterprise_agent.labor_demand;
                labor_demand_info.enterprise_id = enterprise_agent.agent_id;
                labor_demand_info.enterprise_type = enterprise_agent.enterprise_type;
                labor_demand_info.location = [rand()*100, rand()*100]; % 简化位置
                
                obj.enterprise_labor_demanders{end+1} = labor_demand_info;
                
                fprintf('企业 %d (%s) 加入劳动力市场，需求 %d 人\n', ...
                        enterprise_agent.agent_id, enterprise_agent.enterprise_type, ...
                        labor_demand_info.total_demand);
            end
        end
        
        function skill_level = determine_farmer_skill_level(obj, farmer_agent)
            % 根据农户特征确定技能水平
            
            % 基于教育水平和技术水平确定技能
            skill_score = farmer_agent.education_level * 0.6 + farmer_agent.current_technology_level * 0.4;
            
            if skill_score > 0.6
                skill_level = 'skilled';
            else
                skill_level = 'unskilled';
            end
        end
        
        function reservation_wage = calculate_reservation_wage(obj, farmer_agent)
            % 计算农户的保留工资
            
            % 基于农场边际生产力计算
            farm_productivity = farmer_agent.current_yield * 4.5 / 8; % 假设农产品价格4.5元/公斤，8小时工作
            
            % 考虑风险和机会成本
            risk_premium = farm_productivity * farmer_agent.risk_aversion * 0.2;
            
            reservation_wage = farm_productivity + risk_premium;
            
            % 确保不低于最低工资标准
            reservation_wage = max(80, reservation_wage); % 最低80元/天
        end
        
        function [matches, market_outcomes] = clear_labor_market(obj, current_season)
            % 劳动力市场清算
            
            obj.current_season = current_season;
            
            % 更新季节性工资和需求
            obj.update_seasonal_adjustments();
            
            % 计算总供给和需求
            obj.calculate_market_aggregates();
            
            % 进行匹配
            matches = obj.execute_matching_algorithm();
            
            % 计算市场结果
            market_outcomes = obj.calculate_market_outcomes(matches);
            
            % 更新工资率
            obj.update_wage_rates(market_outcomes);
            
            % 记录匹配结果
            obj.employment_matches = [obj.employment_matches; matches];
            
            fprintf('劳动力市场清算完成：匹配 %d 对，平均工资 %.0f 元/天\n', ...
                    length(matches), market_outcomes.average_wage);
        end
        
        function update_seasonal_adjustments(obj)
            % 更新季节性调整
            
            seasonal_factor = obj.seasonal_factors.(obj.current_season);
            
            % 调整工资率
            for i = 1:length(obj.skill_categories)
                skill = obj.skill_categories{i};
                obj.current_wage_rates.(skill) = obj.base_wage_rates.(skill) * seasonal_factor.wage_factor;
            end
            
            % 调整企业需求（通过季节性因子影响）
            for i = 1:length(obj.enterprise_labor_demanders)
                base_demand = obj.enterprise_labor_demanders{i}.total_demand;
                obj.enterprise_labor_demanders{i}.seasonal_adjusted_demand = ...
                    round(base_demand * seasonal_factor.demand_factor);
            end
        end
        
        function calculate_market_aggregates(obj)
            % 计算市场总供给和需求
            
            % 总供给（农户可供给的非农劳动小时）
            total_supply_hours = 0;
            for i = 1:length(obj.farmer_labor_suppliers)
                total_supply_hours = total_supply_hours + obj.farmer_labor_suppliers{i}.off_farm_hours;
            end
            obj.total_labor_supply = total_supply_hours / 8; % 转换为工日
            
            % 总需求（企业需求的工人数）
            total_demand_workers = 0;
            for i = 1:length(obj.enterprise_labor_demanders)
                if isfield(obj.enterprise_labor_demanders{i}, 'seasonal_adjusted_demand')
                    total_demand_workers = total_demand_workers + obj.enterprise_labor_demanders{i}.seasonal_adjusted_demand;
                else
                    total_demand_workers = total_demand_workers + obj.enterprise_labor_demanders{i}.total_demand;
                end
            end
            obj.total_labor_demand = total_demand_workers;
            
            % 计算市场紧张度
            if obj.total_labor_supply > 0
                obj.market_tightness = obj.total_labor_demand / obj.total_labor_supply;
            else
                obj.market_tightness = 1;
            end
        end
        
        function matches = execute_matching_algorithm(obj)
            % 执行匹配算法（简化的双边匹配）
            
            matches = [];
            
            % 为每个企业寻找匹配的农户工人
            for i = 1:length(obj.enterprise_labor_demanders)
                enterprise = obj.enterprise_labor_demanders{i};
                
                % 确定需求数量
                if isfield(enterprise, 'seasonal_adjusted_demand')
                    workers_needed = enterprise.seasonal_adjusted_demand;
                else
                    workers_needed = enterprise.total_demand;
                end
                
                % 寻找合适的农户工人
                suitable_farmers = obj.find_suitable_farmers(enterprise);
                
                % 按照工资接受意愿排序
                suitable_farmers = obj.rank_farmers_by_wage_acceptance(suitable_farmers, enterprise);
                
                % 进行匹配
                matched_count = 0;
                for j = 1:min(workers_needed, length(suitable_farmers))
                    farmer = suitable_farmers{j};
                    
                    % 检查农户是否已被匹配
                    if ~obj.is_farmer_already_matched(farmer.farmer_id, matches)
                        % 创建匹配
                        match = obj.create_match(enterprise, farmer);
                        if ~isempty(match)
                            matches = [matches; match];
                            matched_count = matched_count + 1;
                        end
                    end
                    
                    if matched_count >= workers_needed
                        break;
                    end
                end
            end
        end
        
        function suitable_farmers = find_suitable_farmers(obj, enterprise)
            % 为企业寻找合适的农户工人
            
            suitable_farmers = {};
            
            for i = 1:length(obj.farmer_labor_suppliers)
                farmer = obj.farmer_labor_suppliers{i};
                
                % 检查基本条件
                if farmer.off_farm_hours < 8 % 至少能工作1天
                    continue;
                end
                
                % 检查距离约束
                distance = obj.calculate_distance(enterprise.location, farmer.location);
                if distance > farmer.transportation_tolerance
                    continue;
                end
                
                % 检查技能匹配
                if obj.is_skill_suitable(farmer.skill_level, enterprise)
                    farmer.distance_to_enterprise = distance;
                    farmer.transportation_cost = distance * obj.transportation_cost_per_km;
                    suitable_farmers{end+1} = farmer;
                end
            end
        end
        
        function ranked_farmers = rank_farmers_by_wage_acceptance(obj, farmers, enterprise)
            % 按工资接受意愿对农户排序
            
            if isempty(farmers)
                ranked_farmers = {};
                return;
            end
            
            % 计算每个农户的效用得分
            scores = zeros(length(farmers), 1);
            offered_wage = obj.calculate_offered_wage(enterprise);
            
            for i = 1:length(farmers)
                farmer = farmers{i};
                net_wage = offered_wage - farmer.transportation_cost / 8; % 日净工资
                
                if net_wage >= farmer.reservation_wage
                    % 接受工作，计算效用
                    utility = (net_wage - farmer.reservation_wage) / farmer.reservation_wage;
                    scores(i) = utility;
                else
                    % 拒绝工作
                    scores(i) = -1;
                end
            end
            
            % 按效用得分降序排列
            [~, sorted_indices] = sort(scores, 'descend');
            ranked_farmers = farmers(sorted_indices);
            
            % 移除拒绝工作的农户
            ranked_farmers = ranked_farmers(scores(sorted_indices) >= 0);
        end
        
        function offered_wage = calculate_offered_wage(obj, enterprise)
            % 计算企业提供的工资
            
            % 基于企业预算和技能需求
            if isfield(enterprise, 'average_wage_offer')
                offered_wage = enterprise.average_wage_offer / 8; % 转换为小时工资
            else
                % 默认按市场工资
                if enterprise.skilled_demand > enterprise.unskilled_demand
                    offered_wage = obj.current_wage_rates.skilled / 8;
                else
                    offered_wage = obj.current_wage_rates.unskilled / 8;
                end
            end
        end
        
        function suitable = is_skill_suitable(obj, farmer_skill, enterprise)
            % 检查农户技能是否适合企业需求
            
            % 简化逻辑：技能工人可以做非技能工作，反之不行
            if strcmp(farmer_skill, 'skilled')
                suitable = true; % 技能工人可以做任何工作
            elseif strcmp(farmer_skill, 'unskilled')
                % 非技能工人只能做非技能工作，或企业主要需求是非技能工人
                suitable = enterprise.unskilled_demand >= enterprise.skilled_demand;
            else
                suitable = false;
            end
        end
        
        function already_matched = is_farmer_already_matched(obj, farmer_id, current_matches)
            % 检查农户是否已经被匹配
            
            already_matched = false;
            for i = 1:size(current_matches, 1)
                if current_matches(i).farmer_id == farmer_id
                    already_matched = true;
                    break;
                end
            end
        end
        
        function match = create_match(obj, enterprise, farmer)
            % 创建匹配记录
            
            offered_wage = obj.calculate_offered_wage(enterprise);
            net_wage = offered_wage - farmer.transportation_cost / 8;
            
            if net_wage >= farmer.reservation_wage
                match = struct();
                match.enterprise_id = enterprise.enterprise_id;
                match.farmer_id = farmer.farmer_id;
                match.skill_type = farmer.skill_level;
                match.daily_wage = net_wage * 8; % 日工资
                match.work_hours_per_day = 8;
                match.transportation_cost = farmer.transportation_cost;
                match.distance = farmer.distance_to_enterprise;
                match.match_utility = (net_wage - farmer.reservation_wage) / farmer.reservation_wage;
                match.season = obj.current_season;
            else
                match = [];
            end
        end
        
        function distance = calculate_distance(obj, location1, location2)
            % 计算两点间距离（简化为欧几里得距离）
            distance = sqrt(sum((location1 - location2).^2));
        end
        
        function outcomes = calculate_market_outcomes(obj, matches)
            % 计算市场结果
            
            outcomes = struct();
            
            if isempty(matches)
                outcomes.total_matches = 0;
                outcomes.average_wage = obj.average_wage;
                outcomes.wage_variance = 0;
                outcomes.matching_rate = 0;
                outcomes.unemployment_rate = 1;
                return;
            end
            
            % 基本统计
            outcomes.total_matches = size(matches, 1);
            outcomes.average_wage = mean([matches.daily_wage]);
            outcomes.wage_variance = var([matches.daily_wage]);
            
            % 匹配率
            outcomes.matching_rate = outcomes.total_matches / min(obj.total_labor_supply, obj.total_labor_demand);
            
            % 失业率（供给侧）
            employed_farmers = length(unique([matches.farmer_id]));
            total_farmers = length(obj.farmer_labor_suppliers);
            outcomes.unemployment_rate = (total_farmers - employed_farmers) / total_farmers;
            
            % 职位空缺率（需求侧）
            outcomes.vacancy_rate = (obj.total_labor_demand - outcomes.total_matches) / obj.total_labor_demand;
            
            % 技能分布
            skill_distribution = struct();
            for i = 1:length(obj.skill_categories)
                skill = obj.skill_categories{i};
                skill_matches = sum(strcmp({matches.skill_type}, skill));
                skill_distribution.(skill) = skill_matches;
            end
            outcomes.skill_distribution = skill_distribution;
            
            % 工资分布
            skilled_wages = [matches(strcmp({matches.skill_type}, 'skilled')).daily_wage];
            unskilled_wages = [matches(strcmp({matches.skill_type}, 'unskilled')).daily_wage];
            
            outcomes.skilled_average_wage = ifelse(isempty(skilled_wages), 0, mean(skilled_wages));
            outcomes.unskilled_average_wage = ifelse(isempty(unskilled_wages), 0, mean(unskilled_wages));
        end
        
        function update_wage_rates(obj, market_outcomes)
            % 根据市场结果更新工资率
            
            % 简单的工资调整机制
            adjustment_factor = obj.wage_adjustment_factor;
            
            % 基于市场紧张度调整
            if obj.market_tightness > 1.2 % 劳动力短缺
                wage_multiplier = 1 + adjustment_factor;
            elseif obj.market_tightness < 0.8 % 劳动力过剩
                wage_multiplier = 1 - adjustment_factor;
            else
                wage_multiplier = 1; % 平衡状态
            end
            
            % 更新基础工资率
            for i = 1:length(obj.skill_categories)
                skill = obj.skill_categories{i};
                obj.current_wage_rates.(skill) = obj.current_wage_rates.(skill) * wage_multiplier;
                
                % 确保工资不低于最低标准
                if strcmp(skill, 'unskilled')
                    obj.current_wage_rates.(skill) = max(80, obj.current_wage_rates.(skill));
                else
                    obj.current_wage_rates.(skill) = max(120, obj.current_wage_rates.(skill));
                end
            end
            
            % 更新平均工资
            obj.average_wage = (obj.current_wage_rates.skilled + obj.current_wage_rates.unskilled) / 2;
        end
        
        function clear_participants(obj)
            % 清空市场参与者（每期重新添加）
            obj.farmer_labor_suppliers = {};
            obj.enterprise_labor_demanders = {};
        end
        
        function market_summary = get_market_summary(obj)
            % 获取市场摘要信息
            
            market_summary = struct();
            market_summary.total_farmers = length(obj.farmer_labor_suppliers);
            market_summary.total_enterprises = length(obj.enterprise_labor_demanders);
            market_summary.total_labor_supply = obj.total_labor_supply;
            market_summary.total_labor_demand = obj.total_labor_demand;
            market_summary.market_tightness = obj.market_tightness;
            market_summary.current_wage_rates = obj.current_wage_rates;
            market_summary.unemployment_rate = obj.unemployment_rate;
            market_summary.current_season = obj.current_season;
            market_summary.recent_matches = length(obj.employment_matches);
        end
        
        function print_market_status(obj)
            % 打印市场状态
            
            fprintf('\n=== 简化劳动力市场状态 ===\n');
            fprintf('参与者：\n');
            fprintf('  农户供给者: %d 人\n', length(obj.farmer_labor_suppliers));
            fprintf('  企业需求者: %d 家\n', length(obj.enterprise_labor_demanders));
            
            fprintf('\n供需状况：\n');
            fprintf('  总劳动力供给: %.0f 工日\n', obj.total_labor_supply);
            fprintf('  总劳动力需求: %d 人\n', obj.total_labor_demand);
            fprintf('  市场紧张度: %.2f\n', obj.market_tightness);
            
            fprintf('\n工资水平 (%s季)：\n', obj.current_season);
            fprintf('  非技能工: %.0f 元/天\n', obj.current_wage_rates.unskilled);
            fprintf('  技能工: %.0f 元/天\n', obj.current_wage_rates.skilled);
            fprintf('  平均工资: %.0f 元/天\n', obj.average_wage);
            
            if ~isempty(obj.employment_matches)
                fprintf('\n近期匹配：\n');
                fprintf('  成功匹配: %d 对\n', length(obj.employment_matches));
                fprintf('  失业率: %.1f%%\n', obj.unemployment_rate * 100);
            end
            
            fprintf('========================\n\n');
        end
    end
end

function result = ifelse(condition, true_value, false_value)
    % 简单的条件函数
    if condition
        result = true_value;
    else
        result = false_value;
    end
end 
