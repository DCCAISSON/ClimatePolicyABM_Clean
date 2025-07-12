% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % 政府智能体类
    % 包含政府的政策制定、调控和效果评估
    
    properties
        % 政策参数
        policy          % 政策结构
        budget          % 预算信息
        objectives      % 政策目标
        
        % 政策效果
        policy_effects  % 政策效果
        compliance_rate % 政策执行率
        
        % 统计信息
        total_subsidy_cost      % 总补贴成本
        total_policy_cost       % 总政策成本
        policy_compliance_rate  % 政策合规率
        
        % 历史记录
        policy_history          % 政策历史
        effect_history          % 效果历史
        
        % 外部环境
        climate_conditions      % 气候条件
        economic_conditions     % 经济条件
        social_conditions       % 社会条件
        % 市场调控
        reserve_stock        % 粮食储备库存
        grain_price_floor    % 粮价下限
        grain_price_ceil     % 粮价上限
        
        % 土地征收相关属性 (新增)
        land_redline_mu      % 耕地红线 (亩)
        expropriation_rate   % 年征地比例
        total_expropriated_area % 累计征地面积
        expropriation_history % 征地历史记录

        % 公共支出 (新增)
        public_expenditure % 公共支出结构
        tax_rates % 税率
        consumption_coefficients % 政府消费系数
        fiscal_history % 财政历史

        % 新增：政府政策制定风格 (异质性)
        policy_style % 政策制定风格
        policy_learning_ability % 政策学习能力
        policy_feedback % 政策反馈机制
    end
    
    methods
        function obj = GovernmentAgent(params)
            % 构造函数
            % 初始化政策参数
            obj.initialize_policy(params);
            
            % 初始化预算
            obj.initialize_budget();
            
            % 初始化目标
            obj.initialize_objectives();
            
            % 初始化效果记录
            obj.initialize_effects();
            
            % 初始化历史记录
            obj.initialize_history();
            
            % 初始化土地征收参数 (新增)
            obj.initialize_land_expropriation_params(params);
        end
        
        function initialize_policy(obj, params)
            % 初始化政策参数 (增强异质性)
            obj.policy = struct();
            
            % 种粮补贴政策
            obj.policy.grain_subsidy_rate = params.grain_subsidy_rate;
            obj.policy.subsidy_target = 'households';  % 补贴目标：农户
            
            % 耕地红线政策
            obj.policy.land_red_line_ratio = params.land_red_line_ratio;
            obj.policy.land_protection_strictness = 0.8;  % 土地保护严格程度
            
            % 气候变化适应政策
            obj.policy.climate_adaptation_policy = params.climate_adaptation_policy;
            obj.policy.adaptation_investment_rate = 0.05;  % 适应投资率
            
            % 城乡流动政策
            obj.policy.rural_urban_mobility_policy = params.rural_urban_mobility_policy;
            obj.policy.mobility_support_rate = 0.3;  % 流动支持率
            
            % 技术推广政策
            obj.policy.technology_promotion_rate = 0.2;  % 技术推广率
            obj.policy.innovation_support_rate = 0.1;    % 创新支持率
            
            % 市场调控政策
            obj.policy.market_regulation_strength = 0.5;  % 市场调控强度
            obj.policy.price_stabilization_rate = 0.3;    % 价格稳定率

            % 化肥补贴/环保税
            obj.policy.fertilizer_subsidy_rate = 0.0;  % 0-1
            obj.policy.fertilizer_env_tax     = 0.0;  % 0-1

            % 价格区间（来自模型经济参数）
            if isfield(params, 'grain_price_floor')
                obj.policy.grain_price_floor = params.grain_price_floor;
            else
                obj.policy.grain_price_floor = 2.0;
            end
            if isfield(params, 'grain_price_ceil')
                obj.policy.grain_price_ceil = params.grain_price_ceil;
            else
                obj.policy.grain_price_ceil = 3.0;
            end
            % 初始化库存
            obj.reserve_stock = 0;
            obj.grain_price_floor = obj.policy.grain_price_floor;
            obj.grain_price_ceil  = obj.policy.grain_price_ceil;
            
            % 新增：政府政策制定风格 (异质性)
            obj.policy_style = struct();
            
            % 政策激进程度：基于历史表现和外部压力
            obj.policy_style.radicalism = 0.4 + 0.3 * rand;  % 政策激进程度
            
            % 政策稳定性：基于政府类型
            obj.policy_style.stability = 0.6 + 0.3 * rand;  % 政策稳定性
            
            % 政策响应速度：基于政府效率
            obj.policy_style.responsiveness = 0.5 + 0.4 * rand;  % 政策响应速度
            
            % 政策协调性：基于政府能力
            obj.policy_style.coordination = 0.5 + 0.3 * rand;  % 政策协调性
            
            % 新增：政策学习能力
            obj.policy_learning_ability = 0.4 + 0.4 * rand;  % 政策学习能力
            
            % 新增：政策反馈机制
            obj.policy_feedback = struct();
            obj.policy_feedback.effectiveness_threshold = 0.6;  % 政策效果阈值
            obj.policy_feedback.adjustment_speed = 0.1;  % 政策调整速度
            obj.policy_feedback.memory_length = 10;  % 政策记忆长度
            
            % 新增：政策历史记录
            obj.policy_history = [];
        end
        
        function initialize_land_expropriation_params(obj, params)
            % 初始化土地征收参数 (新增)
            
            % 从配置中获取土地征收参数，如果没有则使用默认值
            if isfield(params, 'land_module')
                land_module = params.land_module;
                obj.land_redline_mu = land_module.land_redline_mu;
                obj.expropriation_rate = land_module.expropriation_rate;
                obj.policy.theta_comp = land_module.theta_comp;
                obj.policy.years_comp = land_module.years_comp;
            else
                % 默认参数
                obj.land_redline_mu = 1.2e8;  % 18亿亩 = 1.2亿公顷
                obj.expropriation_rate = 0.006;  % 0.6%年征地比例
                obj.policy.theta_comp = 1.0;  % 征地补偿系数
                obj.policy.years_comp = 20;   % 征地补偿年数
            end
            
            % 初始化统计变量
            obj.total_expropriated_area = 0;
            obj.expropriation_history = [];
        end
        
        function initialize_budget(obj)
            % 初始化政府预算 (基于23年EER论文和顶级经济学文献)
            % 参考: Barro (1990), Alesina & Perotti (1996), Persson & Tabellini (2000)
            
            obj.budget = struct();
            
            % 政府收入结构 (基于现代公共财政理论)
            obj.budget.revenue = struct();
            obj.budget.revenue.tax_income = 0;        % 所得税收入
            obj.budget.revenue.tax_corporate = 0;     % 企业所得税
            obj.budget.revenue.tax_consumption = 0;   % 消费税/VAT
            obj.budget.revenue.tax_property = 0;      % 财产税
            obj.budget.revenue.tax_land = 0;          % 土地税
            obj.budget.revenue.social_insurance = 0;  % 社会保险缴费
            obj.budget.revenue.total = 0;             % 总收入
            
            % 政府支出结构 (基于公共经济学理论)
            obj.budget.expenditure = struct();
            obj.budget.expenditure.consumption = 0;   % 政府消费 (外生)
            obj.budget.expenditure.investment = 0;     % 政府投资
            obj.budget.expenditure.transfers = 0;      % 转移支付
            obj.budget.expenditure.social_security = 0; % 社会保障
            obj.budget.expenditure.health = 0;         % 医疗支出
            obj.budget.expenditure.education = 0;      % 教育支出
            obj.budget.expenditure.infrastructure = 0; % 基础设施
            obj.budget.expenditure.administration = 0; % 行政管理
            obj.budget.expenditure.total = 0;          % 总支出
            
            % 财政平衡
            obj.budget.balance = 0;                   % 财政余额
            obj.budget.deficit = 0;                   % 财政赤字
            obj.budget.debt = 0;                      % 公共债务
            
            % 税率设置 (基于最优税收理论)
            obj.tax_rates = struct();
            obj.tax_rates.income_tax = 0.15;          % 个人所得税率
            obj.tax_rates.corporate_tax = 0.25;       % 企业所得税率
            obj.tax_rates.consumption_tax = 0.13;     % 消费税率/VAT
            obj.tax_rates.property_tax = 0.01;        % 财产税率
            obj.tax_rates.land_tax = 0.005;           % 土地税率
            obj.tax_rates.social_insurance = 0.08;    % 社会保险缴费率
            
            % 政府消费系数 (外生设定，基于23年EER)
            obj.consumption_coefficients = struct();
            obj.consumption_coefficients.food = 0.05;      % 食品消费系数
            obj.consumption_coefficients.clothing = 0.10;  % 服装消费系数
            obj.consumption_coefficients.housing = 0.15;   % 住房消费系数
            obj.consumption_coefficients.education = 0.25; % 教育消费系数
            obj.consumption_coefficients.health = 0.20;    % 医疗消费系数
            obj.consumption_coefficients.entertainment = 0.10; % 娱乐消费系数
            obj.consumption_coefficients.transportation = 0.15; % 交通消费系数
            
            % 初始化公共支出
            obj.initialize_public_expenditure();
            
            % 初始化财政历史
            obj.fiscal_history = [];
        end
        
        function initialize_public_expenditure(obj)
            % 初始化公共支出 (基于公共经济学理论)
            % 参考: Musgrave (1959), Stiglitz (1988), Auerbach & Feldstein (2002)
            
            obj.public_expenditure = struct();
            
            % 公共品支出 (基于公共品理论)
            obj.public_expenditure.public_goods = struct();
            obj.public_expenditure.public_goods.education = 0.20;      % 教育支出比例
            obj.public_expenditure.public_goods.health = 0.15;         % 医疗支出比例
            obj.public_expenditure.public_goods.infrastructure = 0.25;  % 基础设施支出比例
            obj.public_expenditure.public_goods.social_security = 0.15; % 社会保障支出比例
            obj.public_expenditure.public_goods.environment = 0.10;     % 环境保护支出比例
            obj.public_expenditure.public_goods.defense = 0.05;         % 国防支出比例
            obj.public_expenditure.public_goods.culture = 0.10;         % 文化体育支出比例
            
            % 转移支付结构 (基于再分配理论)
            obj.public_expenditure.transfers = struct();
            obj.public_expenditure.transfers.unemployment = 0.30;       % 失业救济
            obj.public_expenditure.transfers.pension = 0.40;            % 养老金
            obj.public_expenditure.transfers.disability = 0.15;         % 残疾补助
            obj.public_expenditure.transfers.family = 0.15;             % 家庭补助
            
            % 支出历史
            obj.public_expenditure.history = [];
        end
        
        function initialize_objectives(obj)
            % 初始化政策目标
            obj.objectives = struct();
            
            % 粮食安全目标
            obj.objectives.grain_security = struct();
            obj.objectives.grain_security.target_production = 1000000;  % 目标产量
            obj.objectives.grain_security.min_self_sufficiency = 0.95;  % 最低自给率
            
            % 农民收入目标
            obj.objectives.farmer_income = struct();
            obj.objectives.farmer_income.target_growth_rate = 0.05;     % 目标增长率
            obj.objectives.farmer_income.min_income_level = 8000;       % 最低收入水平
            
            % 环境可持续目标
            obj.objectives.environmental_sustainability = struct();
            obj.objectives.environmental_sustainability.land_protection = 0.8;  % 土地保护率
            obj.objectives.environmental_sustainability.climate_adaptation = 0.7; % 气候适应率
            
            % 社会稳定目标
            obj.objectives.social_stability = struct();
            obj.objectives.social_stability.employment_rate = 0.9;      % 就业率
            obj.objectives.social_stability.income_equality = 0.6;      % 收入平等度
        end
        
        function initialize_effects(obj)
            % 初始化效果记录
            obj.policy_effects = struct();
            obj.policy_effects.grain_production = 0;      % 粮食产量
            obj.policy_effects.farmer_income = 0;         % 农民收入
            obj.policy_effects.land_use_efficiency = 0;   % 土地利用效率
            obj.policy_effects.climate_adaptation = 0;    % 气候适应
            obj.policy_effects.social_stability = 0;      % 社会稳定
            
            % 统计信息
            obj.total_subsidy_cost = 0;
            obj.total_policy_cost = 0;
            obj.policy_compliance_rate = 0.8;  % 初始合规率
        end
        
        function initialize_history(obj)
            % 初始化历史记录
            obj.policy_history = [];
            obj.effect_history = [];
        end
        
        function update_policy(obj, model, current_time)
            % 更新政府政策 (增强异质性决策机制)
            
            % 评估当前政策效果
            policy_effectiveness = obj.evaluate_policy_effectiveness(model);
            
            % 根据政策风格选择调整方式
            if rand < 0.3  % 30%概率使用经验法则
                obj.update_policy_rule_based(model, current_time);
            elseif rand < 0.3 + 0.3 * obj.policy_learning_ability  % 学习能力影响学习概率
                obj.update_policy_learning(model, policy_effectiveness, current_time);
            else
                obj.update_policy_stable(model, current_time);
            end
            
            % 记录政策历史
            obj.record_policy_history(current_time, policy_effectiveness);
        end
        
        function update_policy_rule_based(obj, model, current_time)
            % 经验法则政策调整 (基于简单规则)
            
            % 获取当前经济指标
            grain_production = obj.calculate_grain_production(model);
            land_transfer_rate = obj.calculate_land_transfer_rate(model);
            
            % 种粮补贴调整：基于粮食产量
            if grain_production < 0.8  % 产量低于目标
                obj.policy.grain_subsidy_rate = min(0.2, obj.policy.grain_subsidy_rate + 0.02);
            elseif grain_production > 1.2  % 产量高于目标
                obj.policy.grain_subsidy_rate = max(0.05, obj.policy.grain_subsidy_rate - 0.01);
            end
            
            % 土地流转政策调整：基于流转率
            if land_transfer_rate < 0.1  % 流转率过低
                obj.policy.rural_urban_mobility_policy = min(0.9, obj.policy.rural_urban_mobility_policy + 0.05);
            elseif land_transfer_rate > 0.3  % 流转率过高
                obj.policy.rural_urban_mobility_policy = max(0.3, obj.policy.rural_urban_mobility_policy - 0.03);
            end
        end
        
        function update_policy_learning(obj, model, policy_effectiveness, current_time)
            % 学习型政策调整 (基于政策效果反馈)
            
            % 获取历史政策效果
            if ~isempty(obj.policy_history)
                recent_policies = obj.policy_history(max(1, end-obj.policy_feedback.memory_length):end);
                
                % 分析历史政策效果
                effectiveness_trend = obj.analyze_policy_effectiveness_trend(recent_policies);
                
                % 基于效果趋势调整政策
                if effectiveness_trend > 0.1  % 效果改善
                    % 保持或微调当前政策
                    obj.policy.grain_subsidy_rate = obj.policy.grain_subsidy_rate * (1 + 0.01 * randn);
                elseif effectiveness_trend < -0.1  % 效果恶化
                    % 调整政策方向
                    obj.policy.grain_subsidy_rate = obj.policy.grain_subsidy_rate * (1 + 0.05 * randn);
                    obj.policy.rural_urban_mobility_policy = obj.policy.rural_urban_mobility_policy * (1 + 0.03 * randn);
                else
                    % 小幅调整
                    obj.policy.grain_subsidy_rate = obj.policy.grain_subsidy_rate * (1 + 0.02 * randn);
                end
                
                % 确保政策参数在合理范围内
                obj.policy.grain_subsidy_rate = max(0.05, min(0.2, obj.policy.grain_subsidy_rate));
                obj.policy.rural_urban_mobility_policy = max(0.3, min(0.9, obj.policy.rural_urban_mobility_policy));
            else
                % 无历史记录时使用默认调整
                obj.update_policy_rule_based(model, current_time);
            end
        end
        
        function update_policy_stable(obj, model, current_time)
            % 稳定型政策调整 (保持政策稳定性)
            
            % 只在必要时小幅调整
            if rand < 0.1  % 10%概率调整
                obj.update_policy_rule_based(model, current_time);
            end
            % 大部分时间保持政策稳定
        end
        
        function effectiveness = evaluate_policy_effectiveness(obj, model)
            % 评估政策效果 (简化)
            % 基于农户收入、粮食产量、土地流转等指标
            
            % 计算粮食产量
            grain_production = obj.calculate_grain_production(model);
            
            % 计算土地流转率
            land_transfer_rate = obj.calculate_land_transfer_rate(model);
            
            % 综合政策效果
            effectiveness = 0.6 * grain_production + 0.4 * land_transfer_rate;
            
            effectiveness = max(0, min(1, effectiveness));
        end
        
        function grain_production = calculate_grain_production(obj, model)
            % 计算粮食产量 (简化)
            grain_households = 0;
            total_households = length(model.households);
            
            for i = 1:total_households
                if model.households{i}.decision.plant_grain
                    grain_households = grain_households + 1;
                end
            end
            
            grain_production = grain_households / total_households;
        end
        
        function land_transfer_rate = calculate_land_transfer_rate(obj, model)
            % 计算土地流转率 (简化)
            transfer_households = 0;
            total_households = length(model.households);
            
            for i = 1:total_households
                if model.households{i}.decision.land_transfer
                    transfer_households = transfer_households + 1;
                end
            end
            
            land_transfer_rate = transfer_households / total_households;
        end
        
        function trend = analyze_policy_effectiveness_trend(obj, recent_policies)
            % 分析政策效果趋势
            trend = 0;
            
            if length(recent_policies) < 2
                return;
            end
            
            % 计算效果变化趋势
            recent_effectiveness = zeros(length(recent_policies), 1);
            for i = 1:length(recent_policies)
                recent_effectiveness(i) = recent_policies(i).effectiveness;
            end
            
            % 简单线性趋势
            if length(recent_effectiveness) > 1
                trend = (recent_effectiveness(end) - recent_effectiveness(1)) / length(recent_effectiveness);
            end
        end
        
        function record_policy_history(obj, current_time, effectiveness)
            % 记录政策历史
            policy_record = struct();
            policy_record.time = current_time;
            policy_record.grain_subsidy_rate = obj.policy.grain_subsidy_rate;
            policy_record.rural_urban_mobility_policy = obj.policy.rural_urban_mobility_policy;
            policy_record.effectiveness = effectiveness;
            
            obj.policy_history = [obj.policy_history; policy_record];
            
            % 保持历史记录长度
            if length(obj.policy_history) > obj.policy_feedback.memory_length
                obj.policy_history = obj.policy_history(end-obj.policy_feedback.memory_length+1:end);
            end
        end
        
        function evaluate_policy_effects(obj, results)
            % 评估政策效果
            if isempty(results.time_series)
                return;
            end
            
            % 获取最新状态
            latest_state = results.time_series(end);
            
            % 评估粮食生产效果
            grain_planting_ratio = latest_state.households.grain_planting_ratio;
            obj.policy_effects.grain_production = grain_planting_ratio;
            
            % 评估农民收入效果
            mean_income = latest_state.households.mean_income;
            obj.policy_effects.farmer_income = mean_income;
            
            % 评估土地利用效率
            land_efficiency = obj.calculate_land_use_efficiency(results);
            obj.policy_effects.land_use_efficiency = land_efficiency;
            
            % 评估气候适应效果
            climate_adaptation = obj.calculate_climate_adaptation(results);
            obj.policy_effects.climate_adaptation = climate_adaptation;
            
            % 评估社会稳定效果
            social_stability = obj.calculate_social_stability(results);
            obj.policy_effects.social_stability = social_stability;
        end
        
        function efficiency = calculate_land_use_efficiency(obj, results)
            % 计算土地利用效率
            % 基于耕地保护率和粮食种植比例
            
            if isempty(results.time_series)
                efficiency = 0.5;
                return;
            end
            
            latest_state = results.time_series(end);
            
            % 耕地保护率
            land_protection_rate = obj.policy.land_red_line_ratio;
            
            % 粮食种植比例
            grain_planting_ratio = latest_state.households.grain_planting_ratio;
            
            % 综合效率
            efficiency = (land_protection_rate + grain_planting_ratio) / 2;
        end
        
        function adaptation = calculate_climate_adaptation(obj, results)
            % 计算气候适应效果
            % 基于政策投入和农户适应性行为
            
            if isempty(results.time_series)
                adaptation = 0.5;
                return;
            end
            
            % 政策投入
            policy_investment = obj.policy.climate_adaptation_policy;
            
            % 农户适应性 (基于技术采用和作物多样化)
            latest_state = results.time_series(end);
            technology_adoption = 0.5;  % 简化计算
            crop_diversification = 0.5;  % 简化计算
            
            % 综合适应效果
            adaptation = (policy_investment + technology_adoption + crop_diversification) / 3;
        end
        
        function stability = calculate_social_stability(obj, results)
            % 计算社会稳定效果
            % 基于就业率、收入平等度等指标
            
            if isempty(results.time_series)
                stability = 0.5;
                return;
            end
            
            latest_state = results.time_series(end);
            
            % 就业率 (基于外出务工比例)
            employment_rate = 1 - latest_state.households.off_farm_ratio;
            
            % 收入稳定性 (基于收入韧性)
            income_stability = latest_state.households.income_resilience;
            
            % 营养健康
            nutrition_health = latest_state.households.nutrition_health;
            
            % 综合稳定效果
            stability = (employment_rate + income_stability + nutrition_health) / 3;
        end
        
        function adjust_policy_parameters(obj, current_time)
            % 调整政策参数
            % 基于目标达成情况调整政策强度
            
            % 调整种粮补贴率
            obj.adjust_grain_subsidy_rate();
            
            % 调整耕地红线比例
            obj.adjust_land_red_line_ratio();
            
            % 调整气候适应政策
            obj.adjust_climate_adaptation_policy();
            
            % 调整城乡流动政策
            obj.adjust_rural_urban_mobility_policy();
        end
        
        function adjust_grain_subsidy_rate(obj)
            % 调整种粮补贴率
            % 基于粮食生产效果和目标
            
            target_production = obj.objectives.grain_security.target_production;
            current_production = obj.policy_effects.grain_production;
            
            % 计算调整幅度
            if current_production < target_production * 0.8
                % 生产不足，增加补贴
                adjustment = 0.05;
            elseif current_production > target_production * 1.2
                % 生产过剩，减少补贴
                adjustment = -0.02;
            else
                % 生产适中，小幅调整
                adjustment = 0.01;
            end
            
            % 应用调整
            obj.policy.grain_subsidy_rate = max(0, min(0.3, obj.policy.grain_subsidy_rate + adjustment));
        end
        
        function adjust_land_red_line_ratio(obj)
            % 调整耕地红线比例
            % 基于土地利用效率和保护目标
            
            target_protection = obj.objectives.environmental_sustainability.land_protection;
            current_efficiency = obj.policy_effects.land_use_efficiency;
            
            % 计算调整幅度
            if current_efficiency < target_protection * 0.9
                % 效率不足，加强保护
                adjustment = 0.02;
            elseif current_efficiency > target_protection * 1.1
                % 效率过高，适度放松
                adjustment = -0.01;
            else
                % 效率适中，保持稳定
                adjustment = 0;
            end
            
            % 应用调整
            obj.policy.land_red_line_ratio = max(0.7, min(0.95, obj.policy.land_red_line_ratio + adjustment));
        end
        
        function adjust_climate_adaptation_policy(obj)
            % 调整气候适应政策
            % 基于气候适应效果和外部气候条件
            
            target_adaptation = obj.objectives.environmental_sustainability.climate_adaptation;
            current_adaptation = obj.policy_effects.climate_adaptation;
            
            % 计算调整幅度
            if current_adaptation < target_adaptation * 0.8
                % 适应不足，加强政策
                adjustment = 0.05;
            elseif current_adaptation > target_adaptation * 1.2
                % 适应良好，适度放松
                adjustment = -0.02;
            else
                % 适应适中，小幅调整
                adjustment = 0.01;
            end
            
            % 应用调整
            obj.policy.climate_adaptation_policy = max(0.2, min(0.8, obj.policy.climate_adaptation_policy + adjustment));
        end
        
        function adjust_rural_urban_mobility_policy(obj)
            % 调整城乡流动政策
            % 基于社会稳定和就业目标
            
            target_employment = obj.objectives.social_stability.employment_rate;
            current_stability = obj.policy_effects.social_stability;
            
            % 计算调整幅度
            if current_stability < target_employment * 0.9
                % 稳定不足，加强流动支持
                adjustment = 0.03;
            elseif current_stability > target_employment * 1.1
                % 稳定良好，适度调整
                adjustment = -0.01;
            else
                % 稳定适中，小幅调整
                adjustment = 0.01;
            end
            
            % 应用调整
            obj.policy.rural_urban_mobility_policy = max(0.5, min(0.9, obj.policy.rural_urban_mobility_policy + adjustment));
        end
        
        function add_subsidy_cost(obj, amount)
            % 添加补贴成本
            obj.total_subsidy_cost = obj.total_subsidy_cost + amount;
            obj.budget.allocated = obj.budget.allocated + amount;
            obj.budget.available = obj.budget.total - obj.budget.allocated;
        end

        function add_stock(obj, quantity)
            % 政府收购过剩粮食，增加库存
            if quantity <= 0
                return;
            end
            obj.reserve_stock = obj.reserve_stock + quantity;
            % 更新预算成本（简单假设按 floor 价收购）
            cost = quantity * obj.grain_price_floor;
            obj.total_policy_cost = obj.total_policy_cost + cost;
        end

        function remove_stock(obj, quantity)
            % 政府出售库存以平抑价格
            if quantity <= 0 || obj.reserve_stock <= 0
                return;
            end
            actual = min(quantity, obj.reserve_stock);
            obj.reserve_stock = obj.reserve_stock - actual;
            % 更新预算 (按 ceil 价出售，收入抵消成本)
            revenue = actual * obj.grain_price_ceil;
            obj.total_policy_cost = obj.total_policy_cost - revenue;
        end
        
        function record_policy_history(obj, current_time)
            % 记录政策历史
            policy_record = struct();
            policy_record.time = current_time;
            policy_record.grain_subsidy_rate = obj.policy.grain_subsidy_rate;
            policy_record.land_red_line_ratio = obj.policy.land_red_line_ratio;
            policy_record.climate_adaptation_policy = obj.policy.climate_adaptation_policy;
            policy_record.rural_urban_mobility_policy = obj.policy.rural_urban_mobility_policy;
            policy_record.total_subsidy_cost = obj.total_subsidy_cost;
            
            obj.policy_history = [obj.policy_history; policy_record];
        end
        
        function record_effect_history(obj, current_time)
            % 记录效果历史
            effect_record = struct();
            effect_record.time = current_time;
            effect_record.grain_production = obj.policy_effects.grain_production;
            effect_record.farmer_income = obj.policy_effects.farmer_income;
            effect_record.land_use_efficiency = obj.policy_effects.land_use_efficiency;
            effect_record.climate_adaptation = obj.policy_effects.climate_adaptation;
            effect_record.social_stability = obj.policy_effects.social_stability;
            
            obj.effect_history = [obj.effect_history; effect_record];
        end
        
        function effectiveness = calculate_policy_effectiveness(obj)
            % 计算政策有效性
            % 基于目标达成情况
            
            effectiveness = struct();
            
            % 粮食安全有效性
            target_grain = obj.objectives.grain_security.min_self_sufficiency;
            current_grain = obj.policy_effects.grain_production;
            effectiveness.grain_security = min(1, current_grain / target_grain);
            
            % 农民收入有效性
            target_income = obj.objectives.farmer_income.min_income_level;
            current_income = obj.policy_effects.farmer_income;
            effectiveness.farmer_income = min(1, current_income / target_income);
            
            % 环境可持续有效性
            target_land = obj.objectives.environmental_sustainability.land_protection;
            current_land = obj.policy_effects.land_use_efficiency;
            effectiveness.environmental_sustainability = min(1, current_land / target_land);
            
            % 社会稳定有效性
            target_stability = obj.objectives.social_stability.employment_rate;
            current_stability = obj.policy_effects.social_stability;
            effectiveness.social_stability = min(1, current_stability / target_stability);
            
            % 综合有效性
            effectiveness.overall = mean([effectiveness.grain_security, effectiveness.farmer_income, ...
                                        effectiveness.environmental_sustainability, effectiveness.social_stability]);
        end
        
        function cost_efficiency = calculate_cost_efficiency(obj)
            % 计算成本效率
            % 基于政策效果和成本投入
            
            effectiveness = obj.calculate_policy_effectiveness();
            total_cost = obj.total_subsidy_cost + obj.total_policy_cost;
            
            if total_cost > 0
                cost_efficiency = effectiveness.overall / total_cost * 1000;  % 标准化
            else
                cost_efficiency = 0;
            end
        end
        
        function generate_policy_report(obj)
            % 生成政策报告
            fprintf('\n=== 政府政策报告 ===\n');
            
            % 当前政策参数
            fprintf('当前政策参数:\n');
            fprintf('  种粮补贴率: %.2f%%\n', obj.policy.grain_subsidy_rate * 100);
            fprintf('  耕地红线比例: %.2f%%\n', obj.policy.land_red_line_ratio * 100);
            fprintf('  气候适应政策强度: %.2f\n', obj.policy.climate_adaptation_policy);
            fprintf('  城乡流动政策强度: %.2f\n', obj.policy.rural_urban_mobility_policy);
            
            % 政策效果
            fprintf('\n政策效果:\n');
            fprintf('  粮食生产效果: %.3f\n', obj.policy_effects.grain_production);
            fprintf('  农民收入效果: %.2f\n', obj.policy_effects.farmer_income);
            fprintf('  土地利用效率: %.3f\n', obj.policy_effects.land_use_efficiency);
            fprintf('  气候适应效果: %.3f\n', obj.policy_effects.climate_adaptation);
            fprintf('  社会稳定效果: %.3f\n', obj.policy_effects.social_stability);
            
            % 成本统计
            fprintf('\n成本统计:\n');
            fprintf('  总补贴成本: %.2f\n', obj.total_subsidy_cost);
            fprintf('  总政策成本: %.2f\n', obj.total_policy_cost);
            fprintf('  政策合规率: %.2f%%\n', obj.policy_compliance_rate * 100);
            
            % 有效性评估
            effectiveness = obj.calculate_policy_effectiveness();
            fprintf('\n政策有效性:\n');
            fprintf('  粮食安全有效性: %.3f\n', effectiveness.grain_security);
            fprintf('  农民收入有效性: %.3f\n', effectiveness.farmer_income);
            fprintf('  环境可持续有效性: %.3f\n', effectiveness.environmental_sustainability);
            fprintf('  社会稳定有效性: %.3f\n', effectiveness.social_stability);
            fprintf('  综合有效性: %.3f\n', effectiveness.overall);
            
            % 成本效率
            cost_efficiency = obj.calculate_cost_efficiency();
            fprintf('  成本效率: %.3f\n', cost_efficiency);
        end
        
        function [land_holdings, govt_budget] = apply_government_expropriation(obj, households, enterprises, avg_rent)
            % 政府征地流程 (基于现代土地政策文献)
            % 参考: 土地管理法 (2021), 征地补偿条例, 制度经济学理论
            % compensation_price = θ_comp · p̄_t · Y_comp
            
            land_holdings = struct();
            govt_budget = obj.budget;
            
            % 1. 统计当前总耕地面积
            total_land = 0;
            for i = 1:length(households)
                total_land = total_land + households{i}.land_holding;
            end
            for i = 1:length(enterprises)
                if strcmp(enterprises{i}.type, 'agricultural')
                    total_land = total_land + enterprises{i}.current_land;
                end
            end
            
            % 2. 检查是否超过红线 (考虑政策执行效率)
            policy_efficiency = obj.policy_compliance_rate;  % 政策执行效率
            effective_redline = obj.land_redline_mu * policy_efficiency;
            
            if total_land <= effective_redline
                % 未超过有效红线，不征地
                return;
            end
            
            % 3. 计算征地面积 (考虑政策强度)
            policy_intensity = obj.policy.land_protection_strictness;
            delta_area = obj.expropriation_rate * total_land * policy_intensity;
            
            % 4. 选择征地对象 (基于制度经济学理论)
            all_agents = [households; enterprises];
            agent_types = [repmat({'household'}, length(households), 1); 
                          repmat({'enterprise'}, length(enterprises), 1)];
            
            % 计算征地优先级 (基于土地效率、社会影响等)
            expropriation_priorities = zeros(length(all_agents), 1);
            for i = 1:length(all_agents)
                agent = all_agents{i};
                agent_type = agent_types{i};
                
                if strcmp(agent_type, 'household')
                    land_amount = agent.land_holding;
                    efficiency = agent.income.agricultural / (land_amount + 1);  % 土地效率
                    social_impact = 1 - agent.income.off_farm / (agent.income.total + 1);  % 对农业依赖度
                else
                    if strcmp(agent.type, 'agricultural')
                        land_amount = agent.current_land;
                        efficiency = agent.profit / (land_amount + 1);  % 土地效率
                        social_impact = 0.5;  % 企业社会影响中等
                    else
                        land_amount = 0;
                        efficiency = 0;
                        social_impact = 0;
                    end
                end
                
                % 综合优先级 (效率低、社会影响小的优先征收)
                expropriation_priorities(i) = (1 - efficiency/1000) * 0.6 + (1 - social_impact) * 0.4;
            end
            
            [~, sorted_idx] = sort(expropriation_priorities, 'descend');
            
            % 5. 执行征地 (考虑补偿标准)
            remaining_area = delta_area;
            expropriated_agents = [];
            total_compensation = 0;
            
            for i = 1:length(sorted_idx)
                if remaining_area <= 0
                    break;
                end
                
                agent_idx = sorted_idx(i);
                agent = all_agents{agent_idx};
                agent_type = agent_types{agent_idx};
                
                if strcmp(agent_type, 'household')
                    available_land = agent.land_holding;
                else
                    if strcmp(agent.type, 'agricultural')
                        available_land = agent.current_land;
                    else
                        available_land = 0;
                    end
                end
                
                if available_land > 0
                    expropriate_amount = min(remaining_area, available_land);
                    
                    % 征收土地
                    if strcmp(agent_type, 'household')
                        agent.land_holding = agent.land_holding - expropriate_amount;
                    else
                        agent.current_land = agent.current_land - expropriate_amount;
                    end
                    
                    % 计算补偿 (考虑土地质量和区位)
                    compensation = obj.calculate_enhanced_compensation(avg_rent, expropriated_area, agent, agent_type);
                    total_compensation = total_compensation + compensation;
                    
                    % 支付补偿
                    if strcmp(agent_type, 'household')
                        agent.income.rent = agent.income.rent + compensation;
                        agent.update_total_income();
                    else
                        agent.capital = agent.capital + compensation;
                    end
                    
                    % 记录征地
                    expropriated_agents = [expropriated_agents; struct('agent_id', agent.id, ...
                        'agent_type', agent_type, 'area', expropriate_amount, ...
                        'compensation', compensation)];
                    
                    remaining_area = remaining_area - expropriate_amount;
                end
            end
            
            % 6. 更新政府预算和统计
            govt_budget.available = govt_budget.available - total_compensation;
            obj.total_policy_cost = obj.total_policy_cost + total_compensation;
            obj.total_expropriated_area = obj.total_expropriated_area + delta_area;
            
            % 记录征地历史
            obj.expropriation_history = [obj.expropriation_history; struct('time', 0, ...
                'total_area', delta_area, 'total_compensation', total_compensation, ...
                'agents', expropriated_agents)];
            
            % 7. 返回更新后的土地持有量
            land_holdings.households = households;
            land_holdings.enterprises = enterprises;
        end
        
        function compensation = calculate_enhanced_compensation(obj, avg_rent, expropriated_area, agent, agent_type)
            % 计算增强版征地补偿 (基于现代土地政策)
            % 参考: 土地管理法 (2021), 征地补偿条例
            
            % 基础补偿
            base_compensation = obj.policy.theta_comp * avg_rent * obj.policy.years_comp * expropriated_area;
            
            % 土地质量调整 (简化处理)
            land_quality_factor = 1.0;  % 可从土地属性获取
            
            % 区位调整 (简化处理)
            location_factor = 1.0;  % 可从空间位置获取
            
            % 社会影响调整
            if strcmp(agent_type, 'household')
                % 农户补偿考虑生计影响
                livelihood_factor = 1.2;  % 农户补偿标准提高20%
            else
                % 企业补偿考虑投资损失
                investment_factor = 1.1;  % 企业补偿标准提高10%
            end
            
            % 政策强度调整
            policy_factor = 1 + 0.2 * obj.policy.land_protection_strictness;
            
            % 综合补偿
            compensation = base_compensation * land_quality_factor * location_factor * ...
                         livelihood_factor * policy_factor;
        end

        function update_public_expenditure(obj, commodity_market)
            % 更新公共支出决策 (基于公共经济学理论)
            
            % 获取政府总预算
            total_budget = obj.budget.total;
            
            % 计算公共支出分配
            expenditure_vector = obj.calculate_optimal_public_expenditure(total_budget);
            
            % 更新公共支出
            obj.update_public_expenditure_allocation(expenditure_vector);
            
            % 将政府支出加入商品市场需求
            obj.add_government_demand_to_market(commodity_market, expenditure_vector);
            
            % 记录公共支出历史
            obj.record_public_expenditure_history();
        end
        
        function expenditure_vector = calculate_optimal_public_expenditure(obj, total_budget)
            % 计算最优公共支出分配 (基于公共品理论)
            expenditure_vector = zeros(7, 1);  % 对应7种商品
            
            % 公共品支出分配
            public_goods_budget = total_budget * 0.4;  % 40%用于公共品
            
            % 教育支出
            expenditure_vector(4) = public_goods_budget * obj.public_expenditure.public_goods.education;
            
            % 医疗支出
            expenditure_vector(5) = public_goods_budget * obj.public_expenditure.public_goods.health;
            
            % 基础设施支出 (影响交通)
            infrastructure_budget = total_budget * 0.3;  % 30%用于基础设施
            expenditure_vector(7) = infrastructure_budget * obj.public_expenditure.infrastructure.transportation;
            
            % 其他公共服务支出
            services_budget = total_budget * 0.2;  % 20%用于公共服务
            expenditure_vector(6) = services_budget * obj.public_expenditure.public_services.culture;  % 文化娱乐
            
            % 行政管理支出 (影响住房和服装)
            admin_budget = total_budget * 0.1;  % 10%用于行政管理
            expenditure_vector(2) = admin_budget * 0.3;  % 部分用于服装
            expenditure_vector(3) = admin_budget * 0.7;  % 部分用于住房
        end
        
        function update_public_expenditure_allocation(obj, expenditure_vector)
            % 更新公共支出分配
            obj.public_expenditure.current_allocation = struct();
            obj.public_expenditure.current_allocation.education = expenditure_vector(4);
            obj.public_expenditure.current_allocation.health = expenditure_vector(5);
            obj.public_expenditure.current_allocation.transportation = expenditure_vector(7);
            obj.public_expenditure.current_allocation.entertainment = expenditure_vector(6);
            obj.public_expenditure.current_allocation.clothing = expenditure_vector(2);
            obj.public_expenditure.current_allocation.housing = expenditure_vector(3);
            obj.public_expenditure.current_allocation.food = expenditure_vector(1);
            
            % 更新总支出
            obj.public_expenditure.total_expenditure = sum(expenditure_vector);
        end
        
        function add_government_demand_to_market(obj, commodity_market, expenditure_vector)
            % 将政府需求加入商品市场
            if isfield(commodity_market, 'demand')
                % 将政府支出转换为需求
                market_prices = commodity_market.market_prices;
                
                for i = 1:length(expenditure_vector)
                    if market_prices(i) > 0
                        government_demand = expenditure_vector(i) / market_prices(i);
                        commodity_market.demand(i) = commodity_market.demand(i) + government_demand;
                    end
                end
            end
        end
        
        function record_public_expenditure_history(obj)
            % 记录公共支出历史
            expenditure_record = struct();
            expenditure_record.time = obj.model.current_time;
            expenditure_record.education = obj.public_expenditure.current_allocation.education;
            expenditure_record.health = obj.public_expenditure.current_allocation.health;
            expenditure_record.transportation = obj.public_expenditure.current_allocation.transportation;
            expenditure_record.entertainment = obj.public_expenditure.current_allocation.entertainment;
            expenditure_record.clothing = obj.public_expenditure.current_allocation.clothing;
            expenditure_record.housing = obj.public_expenditure.current_allocation.housing;
            expenditure_record.food = obj.public_expenditure.current_allocation.food;
            expenditure_record.total = obj.public_expenditure.total_expenditure;
            expenditure_record.budget = obj.budget.total;
            
            obj.public_expenditure.history = [obj.public_expenditure.history; expenditure_record];
        end
        
        function plot_public_expenditure_analysis(obj)
            % 绘制公共支出分析图表
            if ~isempty(obj.public_expenditure.history)
                figure('Name', 'Public Expenditure Analysis', 'Position', [100, 100, 1200, 800]);
                
                % 支出结构
                subplot(2, 3, 1);
                latest_record = obj.public_expenditure.history(end);
                expenditure_categories = {'Education', 'Health', 'Transportation', 'Entertainment', 'Clothing', 'Housing', 'Food'};
                expenditure_values = [latest_record.education, latest_record.health, latest_record.transportation, ...
                                   latest_record.entertainment, latest_record.clothing, latest_record.housing, latest_record.food];
                bar(expenditure_values);
                xlabel('Expenditure Category');
                ylabel('Amount');
                title('Public Expenditure Structure');
                set(gca, 'XTickLabel', expenditure_categories);
                grid on;
                
                % 支出趋势
                subplot(2, 3, 2);
                times = [obj.public_expenditure.history.time];
                total_expenditure = [obj.public_expenditure.history.total];
                budget = [obj.public_expenditure.history.budget];
                plot(times, total_expenditure, 'b-', 'LineWidth', 2);
                hold on;
                plot(times, budget, 'r--', 'LineWidth', 2);
                xlabel('Time');
                ylabel('Amount');
                title('Public Expenditure Trend');
                legend('Total Expenditure', 'Total Budget');
                grid on;
                
                % 支出比例
                subplot(2, 3, 3);
                expenditure_ratio = total_expenditure ./ budget;
                plot(times, expenditure_ratio, 'g-', 'LineWidth', 2);
                xlabel('Time');
                ylabel('Expenditure Ratio');
                title('Expenditure to Budget Ratio');
                grid on;
                
                % 各类支出趋势
                subplot(2, 3, 4);
                education = [obj.public_expenditure.history.education];
                health = [obj.public_expenditure.history.health];
                transportation = [obj.public_expenditure.history.transportation];
                
                plot(times, education, 'b-', 'LineWidth', 2);
                hold on;
                plot(times, health, 'r-', 'LineWidth', 2);
                plot(times, transportation, 'g-', 'LineWidth', 2);
                xlabel('Time');
                ylabel('Amount');
                title('Major Expenditure Categories');
                legend('Education', 'Health', 'Transportation');
                grid on;
                
                % 支出效率
                subplot(2, 3, 5);
                efficiency = obj.calculate_expenditure_efficiency();
                plot(times, efficiency, 'm-', 'LineWidth', 2);
                xlabel('Time');
                ylabel('Efficiency');
                title('Public Expenditure Efficiency');
                grid on;
                
                sgtitle('Public Expenditure Analysis Results');
            end
        end
        
        function efficiency = calculate_expenditure_efficiency(obj)
            % 计算公共支出效率
            if isempty(obj.public_expenditure.history)
                efficiency = 0.5;
                return;
            end
            
            % 基于支出结构和政策目标计算效率
            latest_record = obj.public_expenditure.history(end);
            
            % 教育支出效率
            education_efficiency = min(1, latest_record.education / 100000);
            
            % 医疗支出效率
            health_efficiency = min(1, latest_record.health / 80000);
            
            % 基础设施支出效率
            infrastructure_efficiency = min(1, latest_record.transportation / 120000);
            
            % 综合效率
            efficiency = (education_efficiency + health_efficiency + infrastructure_efficiency) / 3;
        end

        function update_fiscal_policy(obj, households, enterprises, commodity_market)
            % 更新财政政策 (基于23年EER论文)
            % 参考: Barro (1990), Alesina & Perotti (1996), Persson & Tabellini (2000)
            
            % 计算政府收入
            obj.calculate_government_revenue(households, enterprises);
            
            % 计算政府支出
            obj.calculate_government_expenditure(households, enterprises);
            
            % 计算财政平衡
            obj.calculate_fiscal_balance();
            
            % 更新政府消费 (外生设定)
            obj.update_government_consumption(commodity_market);
            
            % 记录财政历史
            obj.record_fiscal_history();
        end
        
        function calculate_government_revenue(obj, households, enterprises)
            % 计算政府收入 (基于现代税收理论)
            % 参考: Mirrlees (1971), Diamond & Mirrlees (1971), Saez (2001)
            
            % 所得税收入
            total_income = 0;
            for i = 1:length(households)
                household = households{i};
                total_income = total_income + household.income.total;
            end
            obj.budget.revenue.tax_income = total_income * obj.tax_rates.income_tax;
            
            % 企业所得税
            total_corporate_profit = 0;
            for i = 1:length(enterprises)
                enterprise = enterprises{i};
                if isfield(enterprise, 'profit')
                    total_corporate_profit = total_corporate_profit + max(0, enterprise.profit);
                end
            end
            obj.budget.revenue.tax_corporate = total_corporate_profit * obj.tax_rates.corporate_tax;
            
            % 消费税收入 (基于消费支出)
            total_consumption = 0;
            for i = 1:length(households)
                household = households{i};
                if isfield(household, 'consumption') && isfield(household.consumption, 'expenditure')
                    total_consumption = total_consumption + household.consumption.expenditure;
                end
            end
            obj.budget.revenue.tax_consumption = total_consumption * obj.tax_rates.consumption_tax;
            
            % 财产税收入
            total_property = 0;
            for i = 1:length(households)
                household = households{i};
                total_property = total_property + household.wealth;
            end
            obj.budget.revenue.tax_property = total_property * obj.tax_rates.property_tax;
            
            % 土地税收入
            total_land_value = 0;
            for i = 1:length(households)
                household = households{i};
                total_land_value = total_land_value + household.land_holding * 1000; % 假设每亩1000元
            end
            obj.budget.revenue.tax_land = total_land_value * obj.tax_rates.land_tax;
            
            % 社会保险缴费
            obj.budget.revenue.social_insurance = total_income * obj.tax_rates.social_insurance;
            
            % 总收入
            obj.budget.revenue.total = obj.budget.revenue.tax_income + ...
                                      obj.budget.revenue.tax_corporate + ...
                                      obj.budget.revenue.tax_consumption + ...
                                      obj.budget.revenue.tax_property + ...
                                      obj.budget.revenue.tax_land + ...
                                      obj.budget.revenue.social_insurance;
        end
        
        function calculate_government_expenditure(obj, households, enterprises)
            % 计算政府支出 (基于公共经济学理论)
            % 参考: Musgrave (1959), Stiglitz (1988), Auerbach & Feldstein (2002)
            
            % 政府消费 (外生设定，基于23年EER)
            base_consumption = 500000; % 基础政府消费
            gdp_factor = 1.0; % GDP因子，可根据经济规模调整
            obj.budget.expenditure.consumption = base_consumption * gdp_factor;
            
            % 政府投资 (基于基础设施需求)
            infrastructure_need = 0.05; % 基础设施投资占GDP比例
            total_gdp = obj.budget.revenue.total * 4; % 简化GDP估算
            obj.budget.expenditure.investment = total_gdp * infrastructure_need;
            
            % 转移支付 (基于社会保障理论)
            unemployment_rate = obj.calculate_unemployment_rate(households);
            poverty_rate = obj.calculate_poverty_rate(households);
            
            % 失业救济
            obj.budget.expenditure.transfers = unemployment_rate * 10000 * length(households);
            
            % 社会保障支出
            obj.budget.expenditure.social_security = (poverty_rate + unemployment_rate) * 50000 * length(households);
            
            % 医疗支出 (基于人口健康需求)
            population_health_need = 0.08; % 医疗支出占GDP比例
            obj.budget.expenditure.health = total_gdp * population_health_need;
            
            % 教育支出 (基于人力资本理论)
            education_need = 0.06; % 教育支出占GDP比例
            obj.budget.expenditure.education = total_gdp * education_need;
            
            % 基础设施支出
            infrastructure_need = 0.04; % 基础设施支出占GDP比例
            obj.budget.expenditure.infrastructure = total_gdp * infrastructure_need;
            
            % 行政管理支出
            administration_need = 0.03; % 行政管理支出占GDP比例
            obj.budget.expenditure.administration = total_gdp * administration_need;
            
            % 总支出
            obj.budget.expenditure.total = obj.budget.expenditure.consumption + ...
                                          obj.budget.expenditure.investment + ...
                                          obj.budget.expenditure.transfers + ...
                                          obj.budget.expenditure.social_security + ...
                                          obj.budget.expenditure.health + ...
                                          obj.budget.expenditure.education + ...
                                          obj.budget.expenditure.infrastructure + ...
                                          obj.budget.expenditure.administration;
        end
        
        function calculate_fiscal_balance(obj)
            % 计算财政平衡 (基于财政可持续性理论)
            % 参考: Barro (1979), Bohn (1998), Auerbach & Kotlikoff (1987)
            
            % 财政余额
            obj.budget.balance = obj.budget.revenue.total - obj.budget.expenditure.total;
            
            % 财政赤字
            if obj.budget.balance < 0
                obj.budget.deficit = abs(obj.budget.balance);
            else
                obj.budget.deficit = 0;
            end
            
            % 公共债务 (简化处理)
            debt_interest_rate = 0.03; % 债务利率
            obj.budget.debt = obj.budget.debt * (1 + debt_interest_rate) + obj.budget.deficit;
        end
        
        function update_government_consumption(obj, commodity_market)
            % 更新政府消费 (外生设定，基于23年EER论文)
            % 参考: Delli Gatti et al. (2011), 23年EER论文公式(A.47)
            
            if isempty(commodity_market)
                return;
            end
            
            % 政府总消费预算
            government_consumption_budget = obj.budget.expenditure.consumption;
            
            % 政府消费分配 (基于消费系数)
            consumption_allocation = zeros(7, 1);
            consumption_allocation(1) = government_consumption_budget * obj.consumption_coefficients.food;
            consumption_allocation(2) = government_consumption_budget * obj.consumption_coefficients.clothing;
            consumption_allocation(3) = government_consumption_budget * obj.consumption_coefficients.housing;
            consumption_allocation(4) = government_consumption_budget * obj.consumption_coefficients.education;
            consumption_allocation(5) = government_consumption_budget * obj.consumption_coefficients.health;
            consumption_allocation(6) = government_consumption_budget * obj.consumption_coefficients.entertainment;
            consumption_allocation(7) = government_consumption_budget * obj.consumption_coefficients.transportation;
            
            % 将政府消费需求加入商品市场
            market_prices = commodity_market.market_prices;
            for i = 1:length(consumption_allocation)
                if market_prices(i) > 0
                    government_demand = consumption_allocation(i) / market_prices(i);
                    commodity_market.demand(i) = commodity_market.demand(i) + government_demand;
                end
            end
            
            % 记录政府消费
            obj.current_government_consumption = consumption_allocation;
        end
        
        function unemployment_rate = calculate_unemployment_rate(obj, households)
            % 计算失业率
            unemployed_count = 0;
            total_count = length(households);
            
            for i = 1:length(households)
                household = households{i};
                if isfield(household, 'status') && isfield(household.status, 'employed')
                    if ~household.status.employed
                        unemployed_count = unemployed_count + 1;
                    end
                end
            end
            
            unemployment_rate = unemployed_count / total_count;
        end
        
        function poverty_rate = calculate_poverty_rate(obj, households)
            % 计算贫困率 (基于收入分布)
            poverty_threshold = 8000; % 贫困线
            poor_count = 0;
            total_count = length(households);
            
            for i = 1:length(households)
                household = households{i};
                if household.income.total < poverty_threshold
                    poor_count = poor_count + 1;
                end
            end
            
            poverty_rate = poor_count / total_count;
        end
        
        function record_fiscal_history(obj)
            % 记录财政历史
            fiscal_record = struct();
            fiscal_record.time = obj.model.current_time;
            
            % 收入记录
            fiscal_record.revenue = obj.budget.revenue;
            
            % 支出记录
            fiscal_record.expenditure = obj.budget.expenditure;
            
            % 财政平衡记录
            fiscal_record.balance = obj.budget.balance;
            fiscal_record.deficit = obj.budget.deficit;
            fiscal_record.debt = obj.budget.debt;
            
            % 政府消费记录
            if isfield(obj, 'current_government_consumption')
                fiscal_record.government_consumption = obj.current_government_consumption;
            end
            
            obj.fiscal_history = [obj.fiscal_history; fiscal_record];
        end
    end
end 
