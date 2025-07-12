% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % 劳动力需求方智能体（各类农场和企业）
    % 负责计算劳动力需求和做出招聘决策
    
    properties
        % 基本属性
        agent_id
        agent_type  % 'grain_farm', 'cash_crop_farm', 'agro_processing', etc.
        location = [0, 0]  % geographic location [x, y]
        
        % 生产特征
        production_scale = 100  % 生产规模（亩或产值）
        crop_types = {'grain'}  % 种植作物类型
        technology_level = 0.5  % 技术水平（机械化程度）[0-1]
        
        % 劳动力需求
        labor_demand_forecast = struct()  % 按季节和技能类型的需求预测
        current_labor_force = struct()    % 当前雇佣的劳动力
        required_labor_categories = {'unskilled', 'skilled'}  % 需要的劳动力类别
        required_skill_levels = [1, 2, 3]  % 需要的技能等级
        
        % 招聘偏好和约束
        preferred_skill_levels = [1, 2]  % 偏好的技能水平
        max_wage_budget = 50000  % 最大工资预算（元/月）
        reliability_preference = 0.8  % 对可靠性的偏好 [0-1]
        quality_over_cost_preference = 0.6  % 质量vs成本偏好 [0-1]
        
        % 生产季节性
        peak_labor_periods = {'spring', 'autumn'}  % 劳动力高峰期
        labor_intensity_curve = struct()  % 全年劳动力强度曲线
        base_labor_intensity = 50  % 基础劳动强度（小时/亩/年）
        
        % 培训投资
        training_budget = 5000  % 培训预算（元）
        skill_development_strategy = 'reactive'  % 'proactive' or 'reactive'
        training_willingness = 0.5  % 培训投资意愿 [0-1]
        
        % 工作环境
        working_conditions_rating = 3  % 工作条件评分 [1-5]
        provides_training = false  % 是否提供培训机会
        job_stability_score = 0.6  % 工作稳定性评分 [0-1]
        
        % 决策参数
        hiring_urgency = 0.5  % 招聘紧急程度 [0-1]
        productivity_threshold = 10  % 最低生产力要求
        
        % 历史数据
        hiring_history = []
        productivity_records = []
        wage_cost_history = []
    end
    
    methods
        function obj = LaborDemanderAgent(id, type, params)
            % 构造函数
            obj.agent_id = id;
            obj.agent_type = type;
            
            if nargin > 2 && ~isempty(params)
                obj.initialize_agent(params);
            else
                obj.initialize_default_agent();
            end
        end
        
        function initialize_agent(obj, params)
            % 根据参数初始化智能体
            
            % 设置基本属性
            if isfield(params, 'location')
                obj.location = params.location;
            end
            
            if isfield(params, 'production_scale')
                obj.production_scale = params.production_scale;
            end
            
            if isfield(params, 'technology_level')
                obj.technology_level = params.technology_level;
            end
            
            if isfield(params, 'max_wage_budget')
                obj.max_wage_budget = params.max_wage_budget;
            end
            
            if isfield(params, 'crop_types')
                obj.crop_types = params.crop_types;
            end
            
            % 根据智能体类型设置特定参数
            obj.set_type_specific_parameters();
            
            % 初始化劳动力强度曲线
            obj.initialize_labor_intensity_curve();
            
            fprintf('劳动力需求方 %d (%s) 初始化完成\n', obj.agent_id, obj.agent_type);
        end
        
        function initialize_default_agent(obj)
            % 使用默认参数初始化
            default_params = struct();
            default_params.production_scale = 100;
            default_params.technology_level = 0.5;
            default_params.max_wage_budget = 50000;
            default_params.location = [rand()*100, rand()*100];
            default_params.crop_types = {'grain'};
            
            obj.initialize_agent(default_params);
        end
        
        function set_type_specific_parameters(obj)
            % 根据智能体类型设置特定参数
            
            switch obj.agent_type
                case 'grain_farm'
                    obj.base_labor_intensity = 40;  % 粮食作物劳动强度较低
                    obj.required_labor_categories = {'unskilled', 'seasonal', 'machinery_operator'};
                    obj.required_skill_levels = [1, 2, 3];
                    obj.peak_labor_periods = {'spring', 'autumn'};
                    obj.technology_level = max(obj.technology_level, 0.6); % 粮食生产机械化程度较高
                    
                case 'cash_crop_farm'
                    obj.base_labor_intensity = 80;  % 经济作物劳动强度较高
                    obj.required_labor_categories = {'unskilled', 'skilled', 'seasonal'};
                    obj.required_skill_levels = [1, 2, 3, 4];
                    obj.peak_labor_periods = {'spring', 'summer', 'autumn'};
                    obj.quality_over_cost_preference = 0.7; % 更重视质量
                    
                case 'mixed_crop_farm'
                    obj.base_labor_intensity = 60;  % 混合农场中等劳动强度
                    obj.required_labor_categories = {'unskilled', 'skilled', 'machinery_operator'};
                    obj.required_skill_levels = [1, 2, 3];
                    obj.peak_labor_periods = {'spring', 'summer', 'autumn'};
                    
                case 'agro_processing'
                    obj.base_labor_intensity = 100; % 加工企业劳动强度高
                    obj.required_labor_categories = {'skilled', 'machinery_operator', 'management'};
                    obj.required_skill_levels = [2, 3, 4, 5];
                    obj.peak_labor_periods = {'summer', 'autumn'}; % 收获后加工
                    obj.provides_training = true;
                    obj.training_willingness = 0.8;
                    
                otherwise
                    % 默认设置
                    obj.base_labor_intensity = 50;
                    obj.required_labor_categories = {'unskilled', 'skilled'};
                    obj.required_skill_levels = [1, 2];
            end
        end
        
        function initialize_labor_intensity_curve(obj)
            % 初始化全年劳动力强度曲线
            
            % 基础季节性模式
            obj.labor_intensity_curve.spring = 1.0;  % 基准
            obj.labor_intensity_curve.summer = 0.6;
            obj.labor_intensity_curve.autumn = 1.2;
            obj.labor_intensity_curve.winter = 0.3;
            
            % 根据作物类型调整
            if ismember('grain', obj.crop_types)
                obj.labor_intensity_curve.spring = 1.2;  % 春播
                obj.labor_intensity_curve.autumn = 1.5;  % 秋收
            end
            
            if ismember('vegetables', obj.crop_types)
                obj.labor_intensity_curve.summer = 1.0;  % 蔬菜夏季也需要劳动力
            end
        end
        
        function demand_plan = calculate_labor_demand(obj, production_plan, climate_forecast)
            % 计算劳动力需求
            
            if nargin < 2
                production_plan = struct('area', obj.production_scale, 'crops', {obj.crop_types});
            end
            if nargin < 3
                climate_forecast = struct('temperature_change', 0, 'precipitation_change', 0);
            end
            
            demand_plan = struct();
            seasons = {'spring', 'summer', 'autumn', 'winter'};
            
            for i = 1:length(seasons)
                season = seasons{i};
                
                % 基础劳动力需求
                base_demand = obj.calculate_base_seasonal_demand(season, production_plan);
                
                % 气候调整
                climate_adjustment = obj.calculate_climate_adjustment(climate_forecast, season);
                
                % 技术调整（机械化减少劳动力需求）
                tech_adjustment = 1 - obj.technology_level * 0.4;
                
                % 按技能类型分解需求
                seasonal_demand = struct();
                for j = 1:length(obj.required_labor_categories)
                    category = obj.required_labor_categories{j};
                    skill_multiplier = obj.get_skill_multiplier(category, season);
                    
                    seasonal_demand.(category) = base_demand * climate_adjustment * tech_adjustment * skill_multiplier;
                end
                
                demand_plan.(season) = seasonal_demand;
            end
            
            % 更新内部需求预测
            obj.labor_demand_forecast = demand_plan;
        end
        
        function base_demand = calculate_base_seasonal_demand(obj, season, production_plan)
            % 计算季节性基础需求
            
            if isfield(production_plan, 'area')
                area = production_plan.area;
            else
                area = obj.production_scale;
            end
            
            % 获取季节强度系数
            if isfield(obj.labor_intensity_curve, season)
                intensity_factor = obj.labor_intensity_curve.(season);
            else
                intensity_factor = 1.0;
            end
            
            % 基础需求 = 面积 × 基础劳动强度 × 季节系数 / 12个月
            base_demand = area * obj.base_labor_intensity * intensity_factor / 12;
        end
        
        function climate_adjustment = calculate_climate_adjustment(obj, climate_forecast, season)
            % 计算气候对劳动力需求的调整系数
            
            climate_adjustment = 1.0;
            
            % 温度影响
            if isfield(climate_forecast, 'temperature_change')
                temp_change = climate_forecast.temperature_change;
                
                % 春秋季温度变化对劳动力需求影响较大
                if ismember(season, {'spring', 'autumn'})
                    temp_impact = 1 + 0.03 * abs(temp_change); % 温度异常增加劳动力需求
                else
                    temp_impact = 1 + 0.01 * abs(temp_change);
                end
                
                climate_adjustment = climate_adjustment * temp_impact;
            end
            
            % 降水影响
            if isfield(climate_forecast, 'precipitation_change')
                precip_change = climate_forecast.precipitation_change;
                
                % 降水不足增加灌溉劳动力需求
                if precip_change < -10 % 减少超过10%
                    precip_impact = 1.15;
                elseif precip_change > 20 % 增加超过20%
                    precip_impact = 1.10; % 排水等额外工作
                else
                    precip_impact = 1.0;
                end
                
                climate_adjustment = climate_adjustment * precip_impact;
            end
            
            % 极端天气影响
            if isfield(climate_forecast, 'extreme_events') && climate_forecast.extreme_events > 0
                extreme_impact = 1 + 0.2 * climate_forecast.extreme_events;
                climate_adjustment = climate_adjustment * extreme_impact;
            end
        end
        
        function multiplier = get_skill_multiplier(obj, category, season)
            % 获取技能类别在特定季节的需求倍数
            
            switch category
                case 'unskilled'
                    if ismember(season, obj.peak_labor_periods)
                        multiplier = 0.6; % 高峰期更多使用非技能工
                    else
                        multiplier = 0.3;
                    end
                    
                case 'skilled'
                    multiplier = 0.3; % 技能工需求相对稳定
                    
                case 'machinery_operator'
                    if ismember(season, {'spring', 'autumn'})
                        multiplier = 0.15; % 播种收获期机械操作员需求高
                    else
                        multiplier = 0.05;
                    end
                    
                case 'seasonal'
                    if ismember(season, obj.peak_labor_periods)
                        multiplier = 0.4; % 高峰期大量使用季节工
                    else
                        multiplier = 0.1;
                    end
                    
                case 'management'
                    multiplier = 0.05; % 管理人员需求较少且稳定
                    
                otherwise
                    multiplier = 0.2;
            end
        end
        
        function wage_offer = determine_wage_offer(obj, labor_category, market_conditions, urgency)
            % 确定工资报价
            
            if nargin < 3
                market_conditions = struct('average_wage', struct(labor_category, 20));
            end
            if nargin < 4
                urgency = obj.hiring_urgency;
            end
            
            % 基础工资（市场参考价格）
            if isfield(market_conditions, 'average_wage') && isfield(market_conditions.average_wage, labor_category)
                market_wage = market_conditions.average_wage.(labor_category);
            else
                market_wage = 20; % 默认工资
            end
            
            % 紧急程度调整
            urgency_premium = urgency * 0.2;  % 最高20%溢价
            
            % 企业支付能力调整
            current_wage_cost = obj.calculate_current_wage_cost();
            affordability_factor = min(1.5, obj.max_wage_budget / max(current_wage_cost + market_wage * 160, market_wage * 160));
            
            % 质量偏好调整
            quality_premium = obj.reliability_preference * 0.15;  % 最高15%质量溢价
            
            % 竞争压力调整
            competition_factor = obj.calculate_competition_factor(market_conditions);
            
            wage_offer = market_wage * (1 + urgency_premium) * affordability_factor * (1 + quality_premium) * competition_factor;
            
            % 确保不超过预算约束
            max_affordable = obj.calculate_max_affordable_wage(labor_category);
            wage_offer = min(wage_offer, max_affordable);
        end
        
        function current_cost = calculate_current_wage_cost(obj)
            % 计算当前工资成本
            
            current_cost = 0;
            categories = fieldnames(obj.current_labor_force);
            
            for i = 1:length(categories)
                category = categories{i};
                workers = obj.current_labor_force.(category);
                
                if isstruct(workers) && isfield(workers, 'count') && isfield(workers, 'wage')
                    current_cost = current_cost + workers.count * workers.wage * 160; % 月工资
                end
            end
        end
        
        function max_wage = calculate_max_affordable_wage(obj, labor_category)
            % 计算最高可承受工资
            
            current_cost = obj.calculate_current_wage_cost();
            remaining_budget = obj.max_wage_budget - current_cost;
            
            % 假设每个工人每月工作160小时
            max_wage = remaining_budget / 160;
            
            % 确保不低于合理最低工资
            max_wage = max(max_wage, 15);
        end
        
        function competition_factor = calculate_competition_factor(obj, market_conditions)
            % 计算竞争因子
            
            % 基于市场紧张程度
            if isfield(market_conditions, 'unemployment_rate')
                unemployment_rate = market_conditions.unemployment_rate;
                if unemployment_rate < 0.05 % 低失业率，竞争激烈
                    competition_factor = 1.1;
                elseif unemployment_rate > 0.15 % 高失业率，竞争较弱
                    competition_factor = 0.95;
                else
                    competition_factor = 1.0;
                end
            else
                competition_factor = 1.0;
            end
        end
        
        function hiring_decision = make_hiring_decision(obj, applicants, positions_available)
            % 招聘决策
            
            if isempty(applicants)
                hiring_decision = struct('hired', {}, 'wage_offered', {}, 'hours_offered', {});
                return;
            end
            
            if nargin < 3
                positions_available = 5; % 默认招聘5人
            end
            
            hiring_decision = struct('hired', {}, 'wage_offered', {}, 'hours_offered', {});
            
            % 对申请者进行评分
            applicant_scores = obj.evaluate_applicants(applicants);
            
            % 按得分排序
            [sorted_scores, sort_idx] = sort(applicant_scores, 'descend');
            sorted_applicants = applicants(sort_idx);
            
            % 选择最佳申请者（在预算约束内）
            total_wage_cost = obj.calculate_current_wage_cost();
            hired_count = 0;
            
            for i = 1:min(length(sorted_applicants), positions_available)
                if hired_count >= positions_available
                    break;
                end
                
                applicant = sorted_applicants(i);
                
                % 确定工资报价
                if isfield(applicant, 'labor_categories') && ~isempty(applicant.labor_categories)
                    category = applicant.labor_categories{1};
                else
                    category = 'unskilled';
                end
                
                wage_offer = obj.determine_wage_offer(category, struct(), obj.hiring_urgency);
                monthly_cost = wage_offer * 160; % 假设月工作160小时
                
                if total_wage_cost + monthly_cost <= obj.max_wage_budget
                    hired_count = hired_count + 1;
                    hiring_decision.hired{hired_count} = applicant;
                    hiring_decision.wage_offered{hired_count} = wage_offer;
                    hiring_decision.hours_offered{hired_count} = 160;
                    total_wage_cost = total_wage_cost + monthly_cost;
                    
                    % 更新当前劳动力
                    obj.update_current_labor_force(category, 1, wage_offer);
                end
            end
            
            fprintf('需求方 %d 招聘了 %d 名工人\n', obj.agent_id, hired_count);
        end
        
        function scores = evaluate_applicants(obj, applicants)
            % 评估申请者
            
            scores = zeros(length(applicants), 1);
            
            for i = 1:length(applicants)
                applicant = applicants(i);
                score = 0;
                
                % 技能等级评分
                if isfield(applicant, 'skill_level')
                    skill_score = applicant.skill_level / 5 * 0.4;
                    score = score + skill_score;
                end
                
                % 经验评分
                if isfield(applicant, 'experience_years')
                    experience_score = min(applicant.experience_years / 10, 1) * 0.3;
                    score = score + experience_score;
                end
                
                % 技能匹配度评分
                if isfield(applicant, 'labor_categories')
                    match_score = obj.calculate_skill_match_score(applicant.labor_categories);
                    score = score + match_score * 0.2;
                end
                
                % 地理距离评分
                if isfield(applicant, 'location')
                    distance_score = obj.calculate_distance_score(applicant.location);
                    score = score + distance_score * 0.1;
                end
                
                scores(i) = score;
            end
        end
        
        function match_score = calculate_skill_match_score(obj, applicant_categories)
            % 计算技能匹配度评分
            
            if isempty(applicant_categories) || isempty(obj.required_labor_categories)
                match_score = 0;
                return;
            end
            
            % 计算交集
            matched_categories = intersect(applicant_categories, obj.required_labor_categories);
            match_ratio = length(matched_categories) / length(obj.required_labor_categories);
            
            match_score = match_ratio;
        end
        
        function distance_score = calculate_distance_score(obj, applicant_location)
            % 计算距离评分（距离越近评分越高）
            
            if length(obj.location) < 2 || length(applicant_location) < 2
                distance_score = 0.5; % 默认中等评分
                return;
            end
            
            distance = sqrt((obj.location(1) - applicant_location(1))^2 + ...
                           (obj.location(2) - applicant_location(2))^2);
            
            % 距离评分：距离越近评分越高
            max_acceptable_distance = 100;
            distance_score = max(0, 1 - distance / max_acceptable_distance);
        end
        
        function update_current_labor_force(obj, category, count, wage)
            % 更新当前劳动力状况
            
            if isfield(obj.current_labor_force, category)
                obj.current_labor_force.(category).count = obj.current_labor_force.(category).count + count;
                % 更新平均工资
                old_total = obj.current_labor_force.(category).count - count;
                old_wage = obj.current_labor_force.(category).wage;
                new_wage = (old_total * old_wage + count * wage) / obj.current_labor_force.(category).count;
                obj.current_labor_force.(category).wage = new_wage;
            else
                obj.current_labor_force.(category) = struct('count', count, 'wage', wage);
            end
        end
        
        function training_investment = decide_training_investment(obj, current_workforce, skill_gaps)
            % 培训投资决策
            
            if nargin < 2
                current_workforce = obj.current_labor_force;
            end
            if nargin < 3
                skill_gaps = obj.identify_skill_gaps();
            end
            
            training_investment = struct();
            
            if obj.training_willingness < 0.3 % 培训意愿低
                return;
            end
            
            % 识别技能缺口的严重程度
            critical_gaps = obj.identify_critical_skill_gaps(skill_gaps);
            
            remaining_budget = obj.training_budget;
            
            for i = 1:length(critical_gaps)
                if remaining_budget <= 0
                    break;
                end
                
                gap = critical_gaps{i};
                
                % 培训现有员工的成本
                training_cost = obj.estimate_training_cost(gap);
                
                % 招聘熟练工人的成本
                recruitment_cost = obj.estimate_recruitment_cost(gap);
                
                % 选择成本较低且预算允许的方案
                if training_cost < recruitment_cost && remaining_budget >= training_cost
                    training_investment.(gap) = struct('action', 'train', 'cost', training_cost);
                    remaining_budget = remaining_budget - training_cost;
                elseif remaining_budget >= recruitment_cost * 0.3 % 招聘的部分成本
                    training_investment.(gap) = struct('action', 'recruit', 'cost', recruitment_cost * 0.3);
                    remaining_budget = remaining_budget - recruitment_cost * 0.3;
                end
            end
        end
        
        function skill_gaps = identify_skill_gaps(obj)
            % 识别技能缺口
            
            skill_gaps = {};
            
            for i = 1:length(obj.required_labor_categories)
                category = obj.required_labor_categories{i};
                
                % 计算需求
                total_demand = 0;
                seasons = {'spring', 'summer', 'autumn', 'winter'};
                for j = 1:length(seasons)
                    season = seasons{j};
                    if isfield(obj.labor_demand_forecast, season) && ...
                       isfield(obj.labor_demand_forecast.(season), category)
                        total_demand = total_demand + obj.labor_demand_forecast.(season).(category);
                    end
                end
                
                % 计算当前供给
                current_supply = 0;
                if isfield(obj.current_labor_force, category)
                    current_supply = obj.current_labor_force.(category).count * 160; % 月小时数
                end
                
                % 如果需求大于供给，存在缺口
                if total_demand > current_supply * 1.1 % 10%缓冲
                    skill_gaps{end+1} = category;
                end
            end
        end
        
        function critical_gaps = identify_critical_skill_gaps(obj, skill_gaps)
            % 识别关键技能缺口
            
            critical_gaps = {};
            
            for i = 1:length(skill_gaps)
                gap = skill_gaps{i};
                
                % 根据生产重要性判断是否关键
                if ismember(gap, {'machinery_operator', 'skilled', 'management'})
                    critical_gaps{end+1} = gap;
                elseif ismember(gap, {'unskilled', 'seasonal'}) && length(skill_gaps) > 2
                    critical_gaps{end+1} = gap; % 如果缺口较多，非技能工也成为关键
                end
            end
        end
        
        function cost = estimate_training_cost(obj, skill_category)
            % 估计培训成本
            
            switch skill_category
                case 'machinery_operator'
                    cost = 5000; % 机械操作培训成本较高
                case 'skilled'
                    cost = 3000;
                case 'management'
                    cost = 8000;
                otherwise
                    cost = 2000;
            end
        end
        
        function cost = estimate_recruitment_cost(obj, skill_category)
            % 估计招聘成本
            
            % 招聘成本 = 广告费 + 面试成本 + 工资溢价
            base_cost = 1000; % 基础招聘成本
            
            switch skill_category
                case 'machinery_operator'
                    wage_premium = 500 * 12; % 年工资溢价
                case 'skilled'
                    wage_premium = 300 * 12;
                case 'management'
                    wage_premium = 1000 * 12;
                otherwise
                    wage_premium = 200 * 12;
            end
            
            cost = base_cost + wage_premium;
        end
        
        function max_offer = calculate_max_wage_offer(obj, supplier)
            % 计算对供给方的最大工资报价
            
            % 基于供给方生产力估算
            if isfield(supplier, 'skill_level')
                productivity = obj.estimate_supplier_productivity(supplier);
            else
                productivity = 15; % 默认生产力
            end
            
            % 最大支付意愿 = 边际生产力 × 利润分享率
            profit_sharing_rate = 0.7; % 70%的生产力用于支付工资
            max_offer = productivity * profit_sharing_rate;
            
            % 不超过预算约束
            max_affordable = obj.calculate_max_affordable_wage('unskilled');
            max_offer = min(max_offer, max_affordable);
        end
        
        function productivity = estimate_supplier_productivity(obj, supplier)
            % 估计供给方的生产力
            
            % 基础生产力（基于技能等级）
            if isfield(supplier, 'skill_level')
                base_productivity = 10 + supplier.skill_level * 5; % 10-35元/小时
            else
                base_productivity = 15;
            end
            
            % 经验调整
            if isfield(supplier, 'experience_years')
                experience_factor = 1 + supplier.experience_years * 0.02;
            else
                experience_factor = 1.0;
            end
            
            % 技能匹配调整
            if isfield(supplier, 'labor_categories')
                match_factor = obj.calculate_skill_match_score(supplier.labor_categories);
                match_factor = 0.8 + 0.4 * match_factor; % 0.8-1.2范围
            else
                match_factor = 1.0;
            end
            
            productivity = base_productivity * experience_factor * match_factor;
        end
        
        function can_afford = can_afford_wage(obj, wage)
            % 判断是否能够承受某个工资水平
            
            current_cost = obj.calculate_current_wage_cost();
            monthly_cost = wage * 160; % 月工作160小时
            
            can_afford = (current_cost + monthly_cost) <= obj.max_wage_budget;
        end
        
        function requires = requires_labor_category(obj, category)
            % 判断是否需要某个劳动力类别
            requires = ismember(category, obj.required_labor_categories);
        end
        
        function demand = get_category_demand(obj, category)
            % 获取某个类别的劳动力需求
            
            demand = 0;
            seasons = fieldnames(obj.labor_demand_forecast);
            
            for i = 1:length(seasons)
                season = seasons{i};
                if isfield(obj.labor_demand_forecast.(season), category)
                    demand = demand + obj.labor_demand_forecast.(season).(category);
                end
            end
        end
        
        function summary = get_agent_summary(obj)
            % 获取智能体摘要信息
            
            summary = struct();
            summary.agent_id = obj.agent_id;
            summary.agent_type = obj.agent_type;
            summary.production_scale = obj.production_scale;
            summary.technology_level = obj.technology_level;
            summary.max_wage_budget = obj.max_wage_budget;
            summary.current_wage_cost = obj.calculate_current_wage_cost();
            summary.required_categories = obj.required_labor_categories;
            summary.current_labor_force = obj.current_labor_force;
            summary.hiring_history_count = length(obj.hiring_history);
        end
        
        function print_agent_status(obj)
            % 打印智能体状态
            
            fprintf('\n=== 劳动力需求方 %d 状态 ===\n', obj.agent_id);
            fprintf('类型: %s\n', obj.agent_type);
            fprintf('生产规模: %.0f\n', obj.production_scale);
            fprintf('技术水平: %.2f\n', obj.technology_level);
            fprintf('最大工资预算: %.0f 元/月\n', obj.max_wage_budget);
            fprintf('当前工资成本: %.0f 元/月\n', obj.calculate_current_wage_cost());
            fprintf('需要的劳动力类别: %s\n', strjoin(obj.required_labor_categories, ', '));
            
            fprintf('\n当前劳动力:\n');
            categories = fieldnames(obj.current_labor_force);
            for i = 1:length(categories)
                category = categories{i};
                info = obj.current_labor_force.(category);
                fprintf('  %s: %d人, 平均工资%.2f元/小时\n', category, info.count, info.wage);
            end
            
            fprintf('招聘历史记录: %d次\n', length(obj.hiring_history));
            fprintf('========================\n\n');
        end
    end
end 
