% Version: 2.0-Simplified | Package: agents
% Version: 2.0-Simplified | Package: agents
classdef agents.agents
    % 带有预期形成功能的政府智能体
    % 专注于基于预期的政策制定和调整，特别是农业环境政策
    
    properties
        % 政府基本属性
        government_level = 'central'    % 'central', 'provincial', 'local'
        jurisdiction_area = 100000      % 管辖面积（平方公里）
        budget_total = 50000000         % 年度预算（万元）
        administrative_capacity = 0.8   % 行政执行能力 [0-1]
        
        % 政策工具和参数
        current_policies = struct()     % 当前政策组合
        policy_effectiveness = struct() % 政策效果评估
        policy_constraints = struct()   % 政策约束条件
        
        % 环境和农业政策
        emission_tax_rate = 0.1         % 当前排放税率
        green_subsidy_rate = 0.05       % 绿色技术补贴率
        agricultural_subsidy_rate = 0.08 % 农业补贴率
        quality_standard = 0.6          % 产品质量标准
        
        % 政策目标和优先级
        policy_objectives = struct()    % 政策目标
        objective_weights = struct()    % 目标权重
        target_achievement = struct()   % 目标达成情况
        
        % 利益相关者关系
        farmer_satisfaction = 0.6       % 农户满意度
        enterprise_compliance = 0.7     % 企业合规度
        public_support = 0.65           % 公众支持度
        interest_group_influence = struct() % 利益集团影响
        
        % 政策学习和调整
        policy_history = []             % 政策调整历史
        policy_experiments = []         % 政策试验记录
        evidence_base = struct()        % 证据基础
        
        % 预期和预测模型
        policy_impact_models = struct() % 政策影响预测模型
        economic_indicators = struct()  % 经济指标预期
        environmental_indicators = struct() % 环境指标预期
        
        % 决策支持系统
        advisory_inputs = struct()      % 咨询建议输入
        expert_opinions = []            % 专家意见
        data_analytics = struct()       % 数据分析结果
    end
    
    methods
        function obj = GovernmentAgentWithExpectations(agent_id, government_level, params)
            % 构造函数
            
            % 定义政府特有的预期变量
            expectation_variables = obj.get_government_expectation_variables(government_level);
            
            % 调用父类构造函数
            obj = obj@AgentWithExpectations(agent_id, 'government', expectation_variables);
            
            obj.government_level = government_level;
            
            % 初始化政府参数
            if nargin > 2 && ~isempty(params)
                obj.initialize_government_parameters(params);
            else
                obj.initialize_default_government_parameters();
            end
            
            % 配置政府特有的预期设置
            obj.configure_government_expectations();
            
            fprintf('政府智能体 %d (%s级) 初始化完成，具备预期形成能力\n', agent_id, government_level);
        end
        
        function expectation_variables = get_government_expectation_variables(obj, government_level)
            % 根据政府级别获取预期变量
            
            % 通用政府预期变量
            common_variables = {'policy_effectiveness', 'economic_growth', 'environmental_quality', 
                               'farmer_welfare', 'enterprise_competitiveness', 'public_satisfaction',
                               'compliance_cost', 'implementation_difficulty', 'political_feasibility'};
            
            % 政府级别特有的预期变量
            switch government_level
                case 'central'
                    specific_variables = {'national_competitiveness', 'international_pressure', 
                                        'regional_coordination', 'macroeconomic_stability'};
                case 'provincial'
                    specific_variables = {'provincial_gdp', 'inter_provincial_competition', 
                                        'central_government_evaluation', 'local_coordination'};
                case 'local'
                    specific_variables = {'local_employment', 'fiscal_revenue', 
                                        'community_stability', 'upper_level_pressure'};
                otherwise
                    specific_variables = {};
            end
            
            expectation_variables = [common_variables, specific_variables];
        end
        
        function initialize_government_parameters(obj, params)
            % 初始化政府参数
            
            if isfield(params, 'budget_total')
                obj.budget_total = params.budget_total;
            end
            
            if isfield(params, 'administrative_capacity')
                obj.administrative_capacity = params.administrative_capacity;
            end
            
            if isfield(params, 'policy_objectives')
                obj.policy_objectives = params.policy_objectives;
            end
            
            if isfield(params, 'objective_weights')
                obj.objective_weights = params.objective_weights;
            end
        end
        
        function initialize_default_government_parameters(obj)
            % 根据政府级别初始化默认参数
            
            switch obj.government_level
                case 'central'
                    obj.budget_total = 80000000;           % 8000万预算
                    obj.administrative_capacity = 0.85;     % 较强执行能力
                    obj.emission_tax_rate = 0.12;
                    obj.green_subsidy_rate = 0.08;
                    obj.agricultural_subsidy_rate = 0.1;
                    
                case 'provincial'
                    obj.budget_total = 30000000;           % 3000万预算
                    obj.administrative_capacity = 0.75;     % 中等执行能力
                    obj.emission_tax_rate = 0.1;
                    obj.green_subsidy_rate = 0.06;
                    obj.agricultural_subsidy_rate = 0.08;
                    
                case 'local'
                    obj.budget_total = 10000000;           % 1000万预算
                    obj.administrative_capacity = 0.6;      % 有限执行能力
                    obj.emission_tax_rate = 0.08;
                    obj.green_subsidy_rate = 0.04;
                    obj.agricultural_subsidy_rate = 0.06;
            end
            
            % 设置默认政策目标
            obj.policy_objectives.emission_reduction = 0.25;    % 25%减排目标
            obj.policy_objectives.economic_growth = 0.06;       % 6%经济增长目标
            obj.policy_objectives.farmer_income_growth = 0.08;  % 8%农户收入增长目标
            obj.policy_objectives.environmental_quality = 0.15; % 15%环境质量改善目标
            
            % 设置目标权重
            obj.objective_weights.emission_reduction = 0.3;
            obj.objective_weights.economic_growth = 0.3;
            obj.objective_weights.farmer_welfare = 0.25;
            obj.objective_weights.environmental_quality = 0.15;
        end
        
        function configure_government_expectations(obj)
            % 配置政府特有的预期边界和参数
            
            % 设置变量边界
            bounds = struct();
            bounds.policy_effectiveness = [0.2, 0.9];       % 政策有效性
            bounds.economic_growth = [-0.05, 0.15];         % 经济增长率
            bounds.environmental_quality = [-0.1, 0.3];     % 环境质量变化
            bounds.farmer_welfare = [-0.1, 0.2];            % 农户福利变化
            bounds.enterprise_competitiveness = [-0.15, 0.25]; % 企业竞争力变化
            bounds.public_satisfaction = [0.3, 0.9];         % 公众满意度
            bounds.compliance_cost = [1000000, 50000000];    % 合规成本
            bounds.implementation_difficulty = [0.2, 0.8];   % 实施难度
            bounds.political_feasibility = [0.3, 0.9];       % 政治可行性
            
            % 政府级别特有边界
            switch obj.government_level
                case 'central'
                    bounds.national_competitiveness = [0.6, 0.9];
                    bounds.international_pressure = [0.2, 0.8];
                    bounds.regional_coordination = [0.4, 0.8];
                    bounds.macroeconomic_stability = [0.5, 0.9];
                    
                case 'provincial'
                    bounds.provincial_gdp = [0.03, 0.12];
                    bounds.inter_provincial_competition = [0.3, 0.8];
                    bounds.central_government_evaluation = [0.4, 0.9];
                    bounds.local_coordination = [0.5, 0.85];
                    
                case 'local'
                    bounds.local_employment = [0.9, 0.98];
                    bounds.fiscal_revenue = [0.05, 0.2];
                    bounds.community_stability = [0.7, 0.95];
                    bounds.upper_level_pressure = [0.3, 0.8];
            end
            
            % 应用边界
            variables = obj.expectation_module.expectation_variables;
            for i = 1:length(variables)
                var_name = variables{i};
                if isfield(bounds, var_name)
                    obj.expectation_module.variable_bounds.(var_name) = bounds.(var_name);
                end
            end
            
            % 设置政府特有的学习参数
            obj.expectation_module.learning_rate = 0.06;  % 政府学习相对较慢
            obj.expectation_module.memory_length = 48;    % 记忆4年
            obj.risk_attitude = 0.3;  % 政府相对风险厌恶
        end
        
        function decision = make_decision_with_expectations(obj, system_info, expectations)
            % 基于预期做出综合政策决策 - 实现父类的抽象方法
            
            if nargin < 3
                expectations = obj.expectation_module.form_expectations();
            end
            
            decision = struct();
            
            % 1. 环境政策调整
            decision.environmental_policy = obj.make_environmental_policy_decision(system_info, expectations);
            
            % 2. 农业政策调整
            decision.agricultural_policy = obj.make_agricultural_policy_decision(system_info, expectations);
            
            % 3. 监管政策调整
            decision.regulatory_policy = obj.make_regulatory_policy_decision(system_info, expectations);
            
            % 4. 财政政策调整
            decision.fiscal_policy = obj.make_fiscal_policy_decision(system_info, expectations);
            
            % 5. 支持政策调整
            decision.support_policy = obj.make_support_policy_decision(system_info, expectations);
            
            % 记录政策决策
            obj.record_policy_decision(decision);
            
            fprintf('政府智能体 %d 基于预期做出政策调整：排放税%.2f%%，农业补贴%.2f%%，质量标准%.2f\n', ...
                    obj.agent_id, decision.environmental_policy.emission_tax_rate * 100, ...
                    decision.agricultural_policy.subsidy_rate * 100, decision.regulatory_policy.quality_standard);
        end
        
        function env_policy = make_environmental_policy_decision(obj, system_info, expectations)
            % 基于预期的环境政策决策
            
            % 获取环境质量和政策有效性预期
            expected_env_quality = obj.get_expectation('environmental_quality', 2);
            expected_policy_effectiveness = obj.get_expectation('policy_effectiveness', 1);
            expected_compliance_cost = obj.get_expectation('compliance_cost', 2);
            
            % 获取经济影响预期
            expected_economic_growth = obj.get_expectation('economic_growth', 2);
            expected_enterprise_competitiveness = obj.get_expectation('enterprise_competitiveness', 2);
            
            env_policy = struct();
            
            % 排放税率调整
            current_tax_rate = obj.emission_tax_rate;
            
            % 基于环境目标调整
            env_target = obj.policy_objectives.emission_reduction;
            if ~isnan(expected_env_quality)
                env_gap = env_target - expected_env_quality;
                if env_gap > 0.05  % 环境目标差距大于5%
                    tax_adjustment = min(0.03, env_gap * 0.2); % 最大调整3%
                elseif env_gap < -0.02  % 超额完成目标
                    tax_adjustment = -min(0.02, abs(env_gap) * 0.1); % 适度降低
                else
                    tax_adjustment = 0; % 维持现状
                end
            else
                tax_adjustment = 0;
            end
            
            % 考虑经济影响和企业竞争力
            if ~isnan(expected_economic_growth) && expected_economic_growth < 0.03
                tax_adjustment = tax_adjustment * 0.5; % 经济增长缓慢时减半调整
            end
            
            if ~isnan(expected_enterprise_competitiveness) && expected_enterprise_competitiveness < -0.05
                tax_adjustment = tax_adjustment * 0.7; % 企业竞争力下降时减少调整
            end
            
            % 政策可行性约束
            political_feasibility = obj.get_expectation('political_feasibility', 1);
            if ~isnan(political_feasibility) && political_feasibility < 0.6
                tax_adjustment = tax_adjustment * 0.6; % 政治可行性低时减少调整
            end
            
            new_tax_rate = max(0, min(0.3, current_tax_rate + tax_adjustment));
            
            env_policy.emission_tax_rate = new_tax_rate;
            env_policy.tax_adjustment = tax_adjustment;
            env_policy.adjustment_rationale = sprintf('环境目标导向，考虑经济影响');
            
            % 绿色技术补贴调整
            current_subsidy_rate = obj.green_subsidy_rate;
            
            if tax_adjustment > 0 % 税率提高时，增加补贴缓解影响
                subsidy_adjustment = tax_adjustment * 0.5;
            else
                subsidy_adjustment = tax_adjustment * 0.3;
            end
            
            new_subsidy_rate = max(0, min(0.2, current_subsidy_rate + subsidy_adjustment));
            
            env_policy.green_subsidy_rate = new_subsidy_rate;
            env_policy.subsidy_adjustment = subsidy_adjustment;
        end
        
        function agri_policy = make_agricultural_policy_decision(obj, system_info, expectations)
            % 基于预期的农业政策决策
            
            % 获取农户福利和收入预期
            expected_farmer_welfare = obj.get_expectation('farmer_welfare', 2);
            expected_economic_growth = obj.get_expectation('economic_growth', 1);
            
            agri_policy = struct();
            
            % 农业补贴调整
            current_subsidy = obj.agricultural_subsidy_rate;
            welfare_target = obj.policy_objectives.farmer_income_growth;
            
            if ~isnan(expected_farmer_welfare)
                welfare_gap = welfare_target - expected_farmer_welfare;
                if welfare_gap > 0.02  % 农户福利目标差距大于2%
                    subsidy_adjustment = min(0.03, welfare_gap * 0.8);
                elseif welfare_gap < -0.01  % 超额完成目标
                    subsidy_adjustment = -min(0.01, abs(welfare_gap) * 0.5);
                else
                    subsidy_adjustment = 0;
                end
            else
                subsidy_adjustment = 0;
            end
            
            % 考虑财政约束
            budget_utilization = obj.calculate_budget_utilization();
            if budget_utilization > 0.9  % 预算使用率超过90%
                subsidy_adjustment = subsidy_adjustment * 0.5;
            end
            
            new_subsidy_rate = max(0, min(0.25, current_subsidy + subsidy_adjustment));
            
            agri_policy.subsidy_rate = new_subsidy_rate;
            agri_policy.adjustment = subsidy_adjustment;
            agri_policy.budget_allocation = new_subsidy_rate * obj.budget_total * 0.4; % 40%预算用于农业
            
            % 技术推广支持
            agri_policy.technology_support = struct();
            agri_policy.technology_support.training_programs = subsidy_adjustment > 0;
            agri_policy.technology_support.demonstration_projects = new_subsidy_rate > 0.1;
            agri_policy.technology_support.extension_services = true;
        end
        
        function reg_policy = make_regulatory_policy_decision(obj, system_info, expectations)
            % 基于预期的监管政策决策
            
            % 获取实施难度和合规成本预期
            expected_implementation_difficulty = obj.get_expectation('implementation_difficulty', 1);
            expected_compliance_cost = obj.get_expectation('compliance_cost', 2);
            expected_enterprise_competitiveness = obj.get_expectation('enterprise_competitiveness', 2);
            
            reg_policy = struct();
            
            % 质量标准调整
            current_standard = obj.quality_standard;
            
            % 基于环境和质量目标
            env_quality_target = obj.policy_objectives.environmental_quality;
            expected_env_quality = obj.get_expectation('environmental_quality', 3);
            
            if ~isnan(expected_env_quality)
                quality_gap = env_quality_target - expected_env_quality;
                if quality_gap > 0.05
                    standard_adjustment = min(0.1, quality_gap * 0.4);
                else
                    standard_adjustment = 0;
                end
            else
                standard_adjustment = 0;
            end
            
            % 考虑实施难度
            if ~isnan(expected_implementation_difficulty) && expected_implementation_difficulty > 0.7
                standard_adjustment = standard_adjustment * 0.6; % 实施难度大时减少调整
            end
            
            % 考虑企业负担
            if ~isnan(expected_compliance_cost) && expected_compliance_cost > obj.budget_total * 0.1
                standard_adjustment = standard_adjustment * 0.7; % 合规成本高时减少调整
            end
            
            new_standard = max(0.3, min(0.9, current_standard + standard_adjustment));
            
            reg_policy.quality_standard = new_standard;
            reg_policy.standard_adjustment = standard_adjustment;
            reg_policy.implementation_timeline = expected_implementation_difficulty > 0.6 ? 24 : 12; % 月
            
            % 监管执行强度
            enforcement_strength = 0.8 - expected_implementation_difficulty * 0.3;
            reg_policy.enforcement_strength = max(0.4, min(1.0, enforcement_strength));
            
            % 合规支持措施
            reg_policy.compliance_support = struct();
            reg_policy.compliance_support.technical_assistance = standard_adjustment > 0.05;
            reg_policy.compliance_support.financial_incentives = expected_compliance_cost > obj.budget_total * 0.05;
            reg_policy.compliance_support.grace_period = expected_implementation_difficulty > 0.6 ? 12 : 6; % 月
        end
        
        function fiscal_policy = make_fiscal_policy_decision(obj, system_info, expectations)
            % 基于预期的财政政策决策
            
            % 获取经济和财政预期
            expected_economic_growth = obj.get_expectation('economic_growth', 2);
            expected_policy_effectiveness = obj.get_expectation('policy_effectiveness', 1);
            
            fiscal_policy = struct();
            
            % 预算分配调整
            total_budget = obj.budget_total;
            
            % 环境政策预算
            env_budget_ratio = 0.25; % 基础25%
            if ~isnan(expected_policy_effectiveness) && expected_policy_effectiveness > 0.7
                env_budget_ratio = min(0.4, env_budget_ratio * 1.2); % 政策有效时增加投入
            end
            
            % 农业政策预算
            agri_budget_ratio = 0.4; % 基础40%
            if ~isnan(expected_economic_growth) && expected_economic_growth < 0.04
                agri_budget_ratio = min(0.5, agri_budget_ratio * 1.1); % 经济增长缓慢时增加农业支持
            end
            
            % 监管执行预算
            reg_budget_ratio = 0.15; % 基础15%
            
            % 其他支出预算
            other_budget_ratio = 1 - env_budget_ratio - agri_budget_ratio - reg_budget_ratio;
            
            fiscal_policy.budget_allocation = struct();
            fiscal_policy.budget_allocation.environmental = total_budget * env_budget_ratio;
            fiscal_policy.budget_allocation.agricultural = total_budget * agri_budget_ratio;
            fiscal_policy.budget_allocation.regulatory = total_budget * reg_budget_ratio;
            fiscal_policy.budget_allocation.other = total_budget * other_budget_ratio;
            
            % 财政工具选择
            fiscal_policy.instruments = struct();
            fiscal_policy.instruments.direct_subsidies = agri_budget_ratio > 0.35;
            fiscal_policy.instruments.tax_incentives = env_budget_ratio > 0.3;
            fiscal_policy.instruments.public_investment = total_budget > 20000000;
            fiscal_policy.instruments.loan_guarantees = expected_economic_growth < 0.05;
        end
        
        function support_policy = make_support_policy_decision(obj, system_info, expectations)
            % 基于预期的支持政策决策
            
            support_policy = struct();
            
            % 技术创新支持
            expected_enterprise_competitiveness = obj.get_expectation('enterprise_competitiveness', 3);
            if ~isnan(expected_enterprise_competitiveness) && expected_enterprise_competitiveness > 0.1
                support_policy.innovation_support = true;
                support_policy.rd_tax_credit = 0.15; % 15%研发税收抵免
                support_policy.innovation_fund = obj.budget_total * 0.05; % 5%预算用于创新基金
            else
                support_policy.innovation_support = false;
                support_policy.rd_tax_credit = 0.1;
                support_policy.innovation_fund = obj.budget_total * 0.03;
            end
            
            % 人才培训支持
            expected_implementation_difficulty = obj.get_expectation('implementation_difficulty', 1);
            if ~isnan(expected_implementation_difficulty) && expected_implementation_difficulty > 0.6
                support_policy.training_programs = true;
                support_policy.training_budget = obj.budget_total * 0.08;
                support_policy.technical_assistance = true;
            else
                support_policy.training_programs = false;
                support_policy.training_budget = obj.budget_total * 0.04;
                support_policy.technical_assistance = false;
            end
            
            % 信息服务支持
            support_policy.information_services = struct();
            support_policy.information_services.market_information = true;
            support_policy.information_services.technology_guidance = true;
            support_policy.information_services.policy_interpretation = true;
            
            % 基础设施支持
            if obj.government_level == 'central' || obj.government_level == 'provincial'
                support_policy.infrastructure_investment = obj.budget_total * 0.1;
                support_policy.infrastructure_priorities = {'transportation', 'communication', 'storage'};
            else
                support_policy.infrastructure_investment = obj.budget_total * 0.15;
                support_policy.infrastructure_priorities = {'local_roads', 'irrigation', 'waste_treatment'};
            end
        end
        
        function budget_utilization = calculate_budget_utilization(obj)
            % 计算预算使用率
            
            % 简化计算：基于当前政策工具的预算需求
            env_spending = obj.emission_tax_rate * 1000000 + obj.green_subsidy_rate * 5000000;
            agri_spending = obj.agricultural_subsidy_rate * 10000000;
            reg_spending = obj.quality_standard * 2000000;
            other_spending = obj.budget_total * 0.2; % 基础行政支出
            
            total_spending = env_spending + agri_spending + reg_spending + other_spending;
            budget_utilization = total_spending / obj.budget_total;
        end
        
        function record_policy_decision(obj, decision)
            % 记录政策决策历史
            
            policy_record = struct();
            policy_record.timestamp = now();
            policy_record.emission_tax_rate = decision.environmental_policy.emission_tax_rate;
            policy_record.green_subsidy_rate = decision.environmental_policy.green_subsidy_rate;
            policy_record.agricultural_subsidy_rate = decision.agricultural_policy.subsidy_rate;
            policy_record.quality_standard = decision.regulatory_policy.quality_standard;
            
            obj.policy_history = [obj.policy_history, policy_record];
            
            % 维护历史长度
            max_history = 60; % 保存5年历史
            if length(obj.policy_history) > max_history
                obj.policy_history = obj.policy_history(end-max_history+1:end);
            end
            
            % 更新当前政策参数
            obj.emission_tax_rate = decision.environmental_policy.emission_tax_rate;
            obj.green_subsidy_rate = decision.environmental_policy.green_subsidy_rate;
            obj.agricultural_subsidy_rate = decision.agricultural_policy.subsidy_rate;
            obj.quality_standard = decision.regulatory_policy.quality_standard;
        end
        
        function update_government_observations(obj, system_data, feedback_data, current_time)
            % 更新政府观测数据，触发预期学习
            
            % 准备观测数据
            observations = struct();
            
            % 政策效果观测
            if isfield(system_data, 'environmental_outcomes')
                observations.environmental_quality = system_data.environmental_outcomes.quality_improvement;
                observations.policy_effectiveness = system_data.environmental_outcomes.policy_success_rate;
            end
            
            if isfield(system_data, 'economic_outcomes')
                observations.economic_growth = system_data.economic_outcomes.growth_rate;
                observations.enterprise_competitiveness = system_data.economic_outcomes.competitiveness_index;
            end
            
            if isfield(system_data, 'social_outcomes')
                observations.farmer_welfare = system_data.social_outcomes.farmer_income_change;
                observations.public_satisfaction = system_data.social_outcomes.satisfaction_score;
            end
            
            % 实施反馈观测
            if isfield(feedback_data, 'implementation_feedback')
                observations.implementation_difficulty = feedback_data.implementation_feedback.difficulty_score;
                observations.compliance_cost = feedback_data.implementation_feedback.average_compliance_cost;
                observations.political_feasibility = feedback_data.implementation_feedback.political_support;
            end
            
            % 更新预期
            obj.update_expectations(observations, current_time);
            
            % 评估预测准确性并适应
            obj.evaluate_and_adapt_government_predictions(system_data, feedback_data);
        end
        
        function evaluate_and_adapt_government_predictions(obj, system_data, feedback_data)
            % 评估政府预测准确性并适应学习参数
            
            variables = obj.expectation_module.expectation_variables;
            
            for i = 1:length(variables)
                var_name = variables{i};
                
                if isfield(obj.expectation_module.current_expectations, var_name) && ...
                   ~isnan(obj.expectation_module.current_expectations.(var_name))
                    
                    predicted_value = obj.expectation_module.current_expectations.(var_name);
                    actual_value = obj.get_government_actual_value(var_name, system_data, feedback_data);
                    
                    if ~isnan(actual_value)
                        obj.adapt_to_forecast_errors(var_name, actual_value, predicted_value);
                    end
                end
            end
        end
        
        function actual_value = get_government_actual_value(obj, var_name, system_data, feedback_data)
            % 从系统和反馈数据中提取实际值
            
            actual_value = NaN;
            
            switch var_name
                case 'environmental_quality'
                    if isfield(system_data, 'environmental_outcomes')
                        actual_value = system_data.environmental_outcomes.quality_improvement;
                    end
                case 'economic_growth'
                    if isfield(system_data, 'economic_outcomes')
                        actual_value = system_data.economic_outcomes.growth_rate;
                    end
                case 'farmer_welfare'
                    if isfield(system_data, 'social_outcomes')
                        actual_value = system_data.social_outcomes.farmer_income_change;
                    end
                case 'policy_effectiveness'
                    if isfield(system_data, 'environmental_outcomes')
                        actual_value = system_data.environmental_outcomes.policy_success_rate;
                    end
                case 'implementation_difficulty'
                    if isfield(feedback_data, 'implementation_feedback')
                        actual_value = feedback_data.implementation_feedback.difficulty_score;
                    end
            end
        end
        
        function key_variables = identify_key_expectation_variables(obj)
            % 识别关键预期变量 - 实现父类的抽象方法
            
            % 基于政府级别和政策目标识别关键变量
            key_variables = {};
            
            % 政策效果和经济增长总是关键的
            key_variables = [key_variables, {'policy_effectiveness', 'economic_growth'}];
            
            % 根据政府级别添加特定关键变量
            switch obj.government_level
                case 'central'
                    key_variables = [key_variables, {'national_competitiveness', 'macroeconomic_stability'}];
                case 'provincial'
                    key_variables = [key_variables, {'provincial_gdp', 'central_government_evaluation'}];
                case 'local'
                    key_variables = [key_variables, {'local_employment', 'community_stability'}];
            end
            
            % 根据主要政策目标权重调整
            if obj.objective_weights.farmer_welfare > 0.2
                key_variables = [key_variables, {'farmer_welfare'}];
            end
            
            if obj.objective_weights.environmental_quality > 0.1
                key_variables = [key_variables, {'environmental_quality'}];
            end
            
            % 如果行政能力较低，实施难度是关键变量
            if obj.administrative_capacity < 0.7
                key_variables = [key_variables, {'implementation_difficulty', 'political_feasibility'}];
            end
        end
        
        function print_government_status(obj)
            % 打印政府状态，包括预期信息
            
            fprintf('\n=== 政府智能体 %d (%s级) 状态报告 ===\n', obj.agent_id, obj.government_level);
            
            % 基本政府状况
            fprintf('基本政府状况：\n');
            fprintf('  年度预算: %.0f 万元\n', obj.budget_total);
            fprintf('  行政能力: %.2f\n', obj.administrative_capacity);
            fprintf('  排放税率: %.2f%%\n', obj.emission_tax_rate * 100);
            fprintf('  绿色补贴率: %.2f%%\n', obj.green_subsidy_rate * 100);
            fprintf('  农业补贴率: %.2f%%\n', obj.agricultural_subsidy_rate * 100);
            fprintf('  质量标准: %.2f\n', obj.quality_standard);
            
            % 预期信息
            fprintf('\n关键变量预期：\n');
            key_vars = obj.identify_key_expectation_variables();
            for i = 1:length(key_vars)
                var_name = key_vars{i};
                expectation = obj.get_expectation(var_name, 1);
                confidence = obj.get_prediction_confidence(var_name);
                
                fprintf('  %s: %.4f (置信度: %.3f)\n', var_name, expectation, confidence);
            end
            
            % 政策目标达成情况
            fprintf('\n政策目标达成预期：\n');
            env_quality_exp = obj.get_expectation('environmental_quality', 2);
            economic_growth_exp = obj.get_expectation('economic_growth', 2);
            farmer_welfare_exp = obj.get_expectation('farmer_welfare', 2);
            
            if ~isnan(env_quality_exp)
                fprintf('  环境质量目标: %.1f%% (目标: %.1f%%)\n', ...
                        env_quality_exp * 100, obj.policy_objectives.environmental_quality * 100);
            end
            if ~isnan(economic_growth_exp)
                fprintf('  经济增长目标: %.1f%% (目标: %.1f%%)\n', ...
                        economic_growth_exp * 100, obj.policy_objectives.economic_growth * 100);
            end
            if ~isnan(farmer_welfare_exp)
                fprintf('  农户福利目标: %.1f%% (目标: %.1f%%)\n', ...
                        farmer_welfare_exp * 100, obj.policy_objectives.farmer_income_growth * 100);
            end
            
            % 预期学习表现
            summary = obj.get_expectation_summary();
            if ~isnan(summary.average_accuracy)
                fprintf('\n预期学习表现：\n');
                fprintf('  平均预测准确性: %.3f\n', summary.average_accuracy);
                fprintf('  学习率: %.4f\n', obj.expectation_module.learning_rate);
                fprintf('  风险态度: %.3f\n', obj.risk_attitude);
            end
            
            fprintf('===================================\n\n');
        end
    end
end 
