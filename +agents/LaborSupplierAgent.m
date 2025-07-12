% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % 劳动力供给方智能体（农户、外来工等）
    % 负责做出劳动力供给决策和培训参与决策
    
    properties
        % 基本属性
        agent_id
        agent_type  % 'household', 'migrant_worker', 'external_worker'
        location = [0, 0]  % geographic location [x, y]
        
        % 劳动力资源
        available_work_hours = 2000  % 年可工作小时数
        current_employment_hours = 0  % 当前就业小时数
        monthly_work_capacity = 160   % 月工作能力（小时）
        
        % 技能和能力
        skill_level = 1  % 技能等级 [1-5]
        labor_categories = {'unskilled'}  % 可从事的工作类别
        experience_years = 0
        
        % 偏好和约束
        reservation_wage = 12  % 保留工资（元/小时）
        commuting_tolerance = 30  % 通勤容忍度（公里）
        seasonal_availability = [1, 1, 1, 1]  % 春夏秋冬季节可用性 [0-1]
        
        % 家庭约束
        family_labor_needs = 0  % 家庭农场劳动力需求（小时/月）
        care_responsibilities = 0  % 照料责任（小时/月）
        
        % 学习和发展
        training_history = []
        skill_upgrade_willingness = 0.5  % 技能提升意愿 [0-1]
        training_participation = []  % 培训参与历史
        
        % 收入和福利
        wage_history = []
        total_labor_income = 0
        employment_satisfaction = 0.5
        
        % 议价能力
        bargaining_power = 0.3  % 议价能力 [0-1]
        
        % 决策参数
        risk_aversion = 0.5  % 风险厌恶 [0-1]
        discount_rate = 0.05  % 折现率
        
        % 工作偏好
        working_conditions_preference = 0.5  % 工作条件偏好 [0-1]
        job_stability_preference = 0.6  % 工作稳定性偏好 [0-1]
    end
    
    methods
        function obj = LaborSupplierAgent(id, type, params)
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
            
            if isfield(params, 'skill_level')
                obj.skill_level = params.skill_level;
            end
            
            if isfield(params, 'available_work_hours')
                obj.available_work_hours = params.available_work_hours;
            end
            
            if isfield(params, 'reservation_wage')
                obj.reservation_wage = params.reservation_wage;
            end
            
            if isfield(params, 'commuting_tolerance')
                obj.commuting_tolerance = params.commuting_tolerance;
            end
            
            % 根据技能等级设置劳动力类别
            obj.set_labor_categories_by_skill();
            
            % 初始化其他属性
            obj.initialize_preferences();
            
            fprintf('劳动力供给方 %d (%s) 初始化完成\n', obj.agent_id, obj.agent_type);
        end
        
        function initialize_default_agent(obj)
            % 使用默认参数初始化
            default_params = struct();
            default_params.skill_level = 1;
            default_params.available_work_hours = 2000;
            default_params.reservation_wage = 12;
            default_params.commuting_tolerance = 30;
            default_params.location = [rand()*100, rand()*100];
            
            obj.initialize_agent(default_params);
        end
        
        function set_labor_categories_by_skill(obj)
            % 根据技能等级设置可从事的工作类别
            
            switch obj.skill_level
                case 1
                    obj.labor_categories = {'unskilled', 'seasonal'};
                case 2
                    obj.labor_categories = {'unskilled', 'skilled', 'seasonal'};
                case 3
                    obj.labor_categories = {'skilled', 'machinery_operator'};
                case 4
                    obj.labor_categories = {'skilled', 'machinery_operator', 'management'};
                case 5
                    obj.labor_categories = {'skilled', 'machinery_operator', 'management'};
                otherwise
                    obj.labor_categories = {'unskilled'};
            end
        end
        
        function initialize_preferences(obj)
            % 初始化偏好参数
            
            % 根据智能体类型调整偏好
            switch obj.agent_type
                case 'household'
                    obj.family_labor_needs = 40; % 农户有自家农场需求
                    obj.commuting_tolerance = 20; % 农户通勤距离较短
                    obj.job_stability_preference = 0.7; % 偏好稳定工作
                    
                case 'migrant_worker'
                    obj.commuting_tolerance = 100; % 外来工通勤距离较长
                    obj.job_stability_preference = 0.4; % 灵活性较高
                    obj.bargaining_power = 0.2; % 议价能力较低
                    
                case 'external_worker'
                    obj.commuting_tolerance = 50;
                    obj.job_stability_preference = 0.6;
                    obj.bargaining_power = 0.4;
                    
                otherwise
                    % 默认设置
            end
            
            % 随机初始化一些个人特征
            obj.risk_aversion = 0.3 + 0.4 * rand(); % 0.3-0.7
            obj.skill_upgrade_willingness = 0.2 + 0.6 * rand(); % 0.2-0.8
            obj.working_conditions_preference = 0.3 + 0.4 * rand(); % 0.3-0.7
        end
        
        function supply_decision = decide_labor_supply(obj, wage_offers, job_characteristics)
            % 劳动力供给决策
            % 输入：工资报价和工作特征
            % 输出：供给决策
            
            if isempty(wage_offers)
                supply_decision = struct('accept', false, 'offer_id', 0, 'hours_supplied', 0);
                return;
            end
            
            % 确保输入是cell array格式
            if ~iscell(wage_offers)
                wage_offers = {wage_offers};
            end
            if nargin > 2 && ~iscell(job_characteristics)
                job_characteristics = {job_characteristics};
            end
            
            utility_scores = zeros(length(wage_offers), 1);
            
            % 计算每个工作机会的效用
            for i = 1:length(wage_offers)
                offer = wage_offers{i};
                
                % 工资效用
                wage_utility = obj.calculate_wage_utility(offer);
                
                % 距离成本
                distance_cost = 0;
                if isfield(offer, 'location')
                    distance_cost = obj.calculate_commuting_cost(offer.location);
                end
                
                % 工作条件效用
                condition_utility = 0;
                if nargin > 2 && i <= length(job_characteristics)
                    condition_utility = obj.evaluate_job_conditions(job_characteristics{i});
                end
                
                % 综合效用
                utility_scores(i) = wage_utility - distance_cost + condition_utility;
            end
            
            % 选择最佳工作机会
            [max_utility, best_offer_idx] = max(utility_scores);
            
            % 判断是否接受
            if max_utility > obj.calculate_reservation_utility()
                best_offer = wage_offers{best_offer_idx};
                hours_supplied = obj.calculate_hours_supplied(best_offer);
                
                supply_decision = struct('accept', true, ...
                                       'offer_id', best_offer_idx, ...
                                       'hours_supplied', hours_supplied, ...
                                       'expected_utility', max_utility);
            else
                supply_decision = struct('accept', false, ...
                                       'offer_id', 0, ...
                                       'hours_supplied', 0, ...
                                       'expected_utility', max_utility);
            end
        end
        
        function wage_utility = calculate_wage_utility(obj, offer)
            % 计算工资效用
            
            if isfield(offer, 'wage')
                wage = offer.wage;
            else
                wage = offer; % 如果直接传入工资数值
            end
            
            % 基础工资效用（对数函数）
            wage_utility = log(max(wage, 1)) / log(obj.reservation_wage + 5);
            
            % 风险调整
            wage_utility = wage_utility * (1 - obj.risk_aversion * 0.1);
        end
        
        function distance_cost = calculate_commuting_cost(obj, job_location)
            % 计算通勤成本
            
            if length(obj.location) >= 2 && length(job_location) >= 2
                distance = sqrt((obj.location(1) - job_location(1))^2 + ...
                               (obj.location(2) - job_location(2))^2);
            else
                distance = 0;
            end
            
            % 超出容忍度的距离成本急剧上升
            if distance <= obj.commuting_tolerance
                distance_cost = distance * 0.01; % 线性成本
            else
                excess_distance = distance - obj.commuting_tolerance;
                distance_cost = obj.commuting_tolerance * 0.01 + excess_distance * 0.05;
            end
        end
        
        function condition_utility = evaluate_job_conditions(obj, job_conditions)
            % 评估工作条件效用
            
            condition_utility = 0;
            
            if isfield(job_conditions, 'working_environment')
                env_score = job_conditions.working_environment / 5; % 假设1-5评分
                condition_utility = condition_utility + obj.working_conditions_preference * env_score;
            end
            
            if isfield(job_conditions, 'job_stability')
                stability_score = job_conditions.job_stability;
                condition_utility = condition_utility + obj.job_stability_preference * stability_score;
            end
            
            if isfield(job_conditions, 'training_opportunities')
                training_score = job_conditions.training_opportunities;
                condition_utility = condition_utility + obj.skill_upgrade_willingness * training_score;
            end
        end
        
        function reservation_utility = calculate_reservation_utility(obj)
            % 计算保留效用
            
            % 基于保留工资的基础效用
            base_utility = log(obj.reservation_wage) / log(obj.reservation_wage + 5);
            
            % 考虑家庭农场收入
            family_income_utility = obj.family_labor_needs * obj.reservation_wage * 0.8 / 160; % 月收入
            
            % 考虑照料责任的机会成本
            care_cost = obj.care_responsibilities * obj.reservation_wage / 160;
            
            reservation_utility = base_utility + family_income_utility - care_cost;
        end
        
        function hours = calculate_hours_supplied(obj, offer)
            % 计算供给的工作小时数
            
            % 可用工作时间
            available_hours = obj.monthly_work_capacity - obj.family_labor_needs - obj.care_responsibilities;
            
            % 根据工资调整供给意愿
            if isfield(offer, 'wage')
                wage = offer.wage;
            else
                wage = offer;
            end
            
            wage_factor = min(wage / obj.reservation_wage, 2.0); % 最多2倍工资激励
            
            % 考虑工作强度偏好
            intensity_preference = 0.7 + 0.3 * (1 - obj.risk_aversion);
            
            hours = available_hours * wage_factor * intensity_preference;
            hours = max(0, min(hours, available_hours)); % 确保在合理范围内
        end
        
        function training_decision = decide_training_participation(obj, training_programs, subsidies)
            % 培训参与决策
            
            if isempty(training_programs)
                training_decision = struct('participate', false, 'program', [], 'expected_benefit', 0);
                return;
            end
            
            % 确保输入是struct array或cell array
            if ~iscell(training_programs) && ~isstruct(training_programs)
                training_programs = {training_programs};
            end
            
            best_program = [];
            max_net_benefit = 0;
            
            % 评估每个培训项目
            if iscell(training_programs)
                programs_to_evaluate = training_programs;
            else
                programs_to_evaluate = {training_programs};
            end
            
            for i = 1:length(programs_to_evaluate)
                program = programs_to_evaluate{i};
                
                % 检查资格
                if ~obj.is_eligible_for_training(program)
                    continue;
                end
                
                % 计算净收益
                net_benefit = obj.calculate_training_net_benefit(program, subsidies);
                
                if net_benefit > max_net_benefit
                    max_net_benefit = net_benefit;
                    best_program = program;
                end
            end
            
            % 考虑个人培训意愿
            participation_threshold = (1 - obj.skill_upgrade_willingness) * 1000; % 意愿越高，门槛越低
            
            if max_net_benefit > participation_threshold
                training_decision = struct('participate', true, ...
                                         'program', best_program, ...
                                         'expected_benefit', max_net_benefit);
            else
                training_decision = struct('participate', false, ...
                                         'program', [], ...
                                         'expected_benefit', max_net_benefit);
            end
        end
        
        function eligible = is_eligible_for_training(obj, program)
            % 检查是否符合培训资格
            
            eligible = true;
            
            % 检查目标群体
            if isfield(program, 'target_group')
                target = program.target_group;
                
                switch target
                    case 'unskilled'
                        eligible = obj.skill_level <= 2;
                    case 'skilled'
                        eligible = obj.skill_level >= 2 && obj.skill_level <= 3;
                    case 'experienced'
                        eligible = obj.skill_level >= 3 || obj.experience_years >= 3;
                    otherwise
                        eligible = true;
                end
            end
            
            % 检查技能等级限制
            if isfield(program, 'min_skill_level')
                eligible = eligible && (obj.skill_level >= program.min_skill_level);
            end
            
            if isfield(program, 'max_skill_level')
                eligible = eligible && (obj.skill_level <= program.max_skill_level);
            end
        end
        
        function net_benefit = calculate_training_net_benefit(obj, program, subsidies)
            % 计算培训的净收益
            
            % 培训成本
            training_cost = program.cost;
            if ~isempty(subsidies) && isfield(subsidies, 'rate')
                training_cost = training_cost * (1 - subsidies.rate);
            end
            
            % 机会成本（培训期间无法工作的收入损失）
            if isfield(program, 'duration')
                opportunity_cost = program.duration * obj.reservation_wage * 40; % 假设每月40小时
            else
                opportunity_cost = 0;
            end
            
            total_cost = training_cost + opportunity_cost;
            
            % 预期收益
            expected_wage_increase = obj.estimate_wage_increase(program);
            benefit_period = 36; % 收益期36个月
            discounted_benefit = obj.calculate_discounted_benefit(expected_wage_increase, benefit_period);
            
            % 考虑培训成功率
            if isfield(program, 'success_rate')
                discounted_benefit = discounted_benefit * program.success_rate;
            end
            
            net_benefit = discounted_benefit - total_cost;
        end
        
        function wage_increase = estimate_wage_increase(obj, program)
            % 估计培训后的工资增长
            
            % 基础工资增长（基于技能提升）
            if isfield(program, 'skill_improvement')
                skill_improvement = program.skill_improvement;
                base_increase = skill_improvement * obj.reservation_wage * 0.3; % 每级技能提升30%工资
            else
                base_increase = obj.reservation_wage * 0.2; % 默认20%增长
            end
            
            % 个人能力调整
            ability_factor = 0.7 + 0.6 * obj.skill_upgrade_willingness; % 0.7-1.3
            
            wage_increase = base_increase * ability_factor;
        end
        
        function discounted_benefit = calculate_discounted_benefit(obj, monthly_increase, periods)
            % 计算折现收益
            
            discounted_benefit = 0;
            for t = 1:periods
                monthly_benefit = monthly_increase * 40; % 假设每月40小时工作
                discounted_benefit = discounted_benefit + monthly_benefit / (1 + obj.discount_rate)^(t/12);
            end
        end
        
        function hours = calculate_optimal_hours(obj, wage_rate, own_farm_needs)
            % 计算最优工作小时数
            % 在外出务工和自家农场工作之间的权衡
            
            if nargin < 3
                own_farm_needs = obj.family_labor_needs;
            end
            
            % 自家农场机会成本
            own_farm_marginal_product = obj.calculate_own_farm_marginal_product();
            
            % 如果市场工资高于自家农场边际产品，选择外出务工
            if wage_rate > own_farm_marginal_product
                available_hours = obj.monthly_work_capacity - own_farm_needs - obj.care_responsibilities;
                labor_supply = obj.calculate_labor_supply_curve(wage_rate);
                hours = min(available_hours, labor_supply);
            else
                hours = 0;
            end
        end
        
        function marginal_product = calculate_own_farm_marginal_product(obj)
            % 计算自家农场的边际产品
            
            % 简化模型：基于技能水平和经验
            base_productivity = 8 + obj.skill_level * 2; % 基础生产力8-18元/小时
            experience_factor = 1 + obj.experience_years * 0.01; % 经验调整
            
            marginal_product = base_productivity * experience_factor;
        end
        
        function labor_supply = calculate_labor_supply_curve(obj, wage_rate)
            % 计算劳动力供给曲线
            
            % 弹性劳动力供给
            elasticity = 0.3 + 0.4 * (1 - obj.risk_aversion); % 风险厌恶程度影响供给弹性
            
            wage_ratio = wage_rate / obj.reservation_wage;
            supply_factor = wage_ratio^elasticity;
            
            max_supply = obj.monthly_work_capacity - obj.family_labor_needs - obj.care_responsibilities;
            labor_supply = max_supply * min(supply_factor, 1.5); % 最大150%激励
        end
        
        function update_employment_status(obj, employment_info)
            % 更新就业状态
            
            if isfield(employment_info, 'hours')
                obj.current_employment_hours = employment_info.hours;
            end
            
            if isfield(employment_info, 'wage')
                obj.wage_history = [obj.wage_history, employment_info.wage];
                monthly_income = employment_info.wage * employment_info.hours;
                obj.total_labor_income = obj.total_labor_income + monthly_income;
            end
            
            if isfield(employment_info, 'satisfaction')
                obj.employment_satisfaction = 0.7 * obj.employment_satisfaction + 0.3 * employment_info.satisfaction;
            end
        end
        
        function participate_training(obj, program)
            % 参与培训项目
            
            training_record = struct();
            training_record.program_id = program.id;
            training_record.program_name = program.name;
            training_record.start_time = datestr(now);
            training_record.duration = program.duration;
            training_record.cost = program.cost;
            
            obj.training_history = [obj.training_history, training_record];
            
            % 技能提升
            if isfield(program, 'skill_improvement')
                skill_gain = program.skill_improvement;
                if isfield(program, 'success_rate')
                    if rand() < program.success_rate
                        obj.skill_level = min(5, obj.skill_level + skill_gain);
                        training_record.success = true;
                        
                        % 更新劳动力类别
                        obj.set_labor_categories_by_skill();
                        
                        fprintf('智能体 %d 成功完成培训，技能等级提升到 %d\n', obj.agent_id, obj.skill_level);
                    else
                        training_record.success = false;
                        fprintf('智能体 %d 培训失败\n', obj.agent_id);
                    end
                end
            end
            
            % 更新培训参与记录
            obj.training_participation = [obj.training_participation, training_record];
        end
        
        function update_experience(obj, months)
            % 更新工作经验
            obj.experience_years = obj.experience_years + months / 12;
            
            % 经验可能带来技能提升
            if obj.experience_years > 0 && mod(floor(obj.experience_years), 2) == 0
                if rand() < 0.1 % 10%概率通过经验获得技能提升
                    obj.skill_level = min(5, obj.skill_level + 0.5);
                    obj.set_labor_categories_by_skill();
                end
            end
        end
        
        function update_reservation_wage(obj, market_conditions)
            % 根据市场条件更新保留工资
            
            if isfield(market_conditions, 'average_wage')
                market_avg = market_conditions.average_wage;
                
                % 渐进调整保留工资
                adjustment_speed = 0.1;
                wage_gap = market_avg - obj.reservation_wage;
                obj.reservation_wage = obj.reservation_wage + adjustment_speed * wage_gap;
                
                % 确保保留工资不低于最低生活标准
                obj.reservation_wage = max(obj.reservation_wage, 10);
            end
        end
        
        function summary = get_agent_summary(obj)
            % 获取智能体摘要信息
            
            summary = struct();
            summary.agent_id = obj.agent_id;
            summary.agent_type = obj.agent_type;
            summary.skill_level = obj.skill_level;
            summary.labor_categories = obj.labor_categories;
            summary.reservation_wage = obj.reservation_wage;
            summary.current_employment_hours = obj.current_employment_hours;
            summary.total_labor_income = obj.total_labor_income;
            summary.experience_years = obj.experience_years;
            summary.training_count = length(obj.training_history);
            summary.employment_satisfaction = obj.employment_satisfaction;
        end
        
        function print_agent_status(obj)
            % 打印智能体状态
            
            fprintf('\n=== 劳动力供给方 %d 状态 ===\n', obj.agent_id);
            fprintf('类型: %s\n', obj.agent_type);
            fprintf('技能等级: %d\n', obj.skill_level);
            fprintf('工作类别: %s\n', strjoin(obj.labor_categories, ', '));
            fprintf('保留工资: %.2f 元/小时\n', obj.reservation_wage);
            fprintf('工作经验: %.1f 年\n', obj.experience_years);
            fprintf('当前就业小时: %d\n', obj.current_employment_hours);
            fprintf('总劳动收入: %.2f 元\n', obj.total_labor_income);
            fprintf('就业满意度: %.2f\n', obj.employment_satisfaction);
            fprintf('参与培训次数: %d\n', length(obj.training_history));
            fprintf('=========================\n\n');
        end
    end
end 
