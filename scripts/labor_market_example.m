%% 劳动力市场模块使用示例
% 演示如何使用劳动力市场模块进行气候政策分析
% 这个示例展示了劳动力市场的各种功能，包括：
% 1. 基本的劳动力供需匹配
% 2. 季节性劳动力需求变化
% 3. 气候变化对劳动力需求的影响
% 4. 政策干预（培训补贴、最低工资）的效果
% 5. 技能提升和培训决策

clear; clc;
fprintf('=== 劳动力市场模块示例 ===\n\n');

%% 1. 初始化劳动力市场模块
fprintf('1. 初始化劳动力市场模块...\n');

% 设置劳动力市场参数
labor_market_params = struct();
labor_market_params.minimum_wage = 15;                    % 最低工资 15元/小时
labor_market_params.search_cost_factor = 0.05;            % 搜寻成本系数
labor_market_params.geographic_search_radius = 50;        % 搜寻半径 50公里
labor_market_params.wage_elasticity = 0.3;                % 工资弹性

% 创建劳动力市场
labor_market = LaborMarketModule(labor_market_params);

% 显示初始状态
labor_market.print_market_status();

%% 2. 创建劳动力供给方智能体
fprintf('2. 创建劳动力供给方智能体...\n');

n_suppliers = 20;  % 创建20个劳动力供给方
suppliers = cell(n_suppliers, 1);

for i = 1:n_suppliers
    % 随机分配智能体类型
    agent_types = {'household', 'migrant_worker', 'external_worker'};
    agent_type = agent_types{randi(3)};
    
    % 设置智能体参数
    params = struct();
    params.skill_level = randi(5);                        % 随机技能等级 1-5
    params.available_work_hours = 1800 + randi(400);      % 年工作小时数 1800-2200
    params.reservation_wage = 10 + params.skill_level * 2; % 保留工资与技能相关
    params.commuting_tolerance = 20 + randi(60);          % 通勤容忍度 20-80公里
    params.location = [rand()*100, rand()*100];           % 随机位置
    
    % 创建智能体
    suppliers{i} = LaborSupplierAgent(i, agent_type, params);
    
    % 添加到劳动力市场
    labor_market.add_supplier(suppliers{i});
end

fprintf('创建了 %d 个劳动力供给方\n', n_suppliers);

%% 3. 创建劳动力需求方智能体
fprintf('\n3. 创建劳动力需求方智能体...\n');

n_demanders = 8;  % 创建8个劳动力需求方
demanders = cell(n_demanders, 1);

for i = 1:n_demanders
    % 随机分配农场类型
    farm_types = {'grain_farm', 'cash_crop_farm', 'mixed_crop_farm', 'agro_processing'};
    farm_type = farm_types{randi(4)};
    
    % 设置农场参数
    params = struct();
    params.production_scale = 50 + randi(150);            % 生产规模 50-200亩
    params.technology_level = 0.3 + rand() * 0.5;         % 技术水平 0.3-0.8
    params.max_wage_budget = 30000 + randi(40000);        % 工资预算 30000-70000元/月
    params.location = [rand()*100, rand()*100];           % 随机位置
    
    % 根据类型设置作物
    switch farm_type
        case 'grain_farm'
            params.crop_types = {'grain'};
        case 'cash_crop_farm'
            params.crop_types = {'cotton', 'tobacco'};
        case 'mixed_crop_farm'
            params.crop_types = {'grain', 'vegetables'};
        case 'agro_processing'
            params.crop_types = {'grain', 'vegetables'};
    end
    
    % 创建智能体
    demanders{i} = LaborDemanderAgent(i, farm_type, params);
    
    % 计算劳动力需求
    demanders{i}.calculate_labor_demand();
    
    % 添加到劳动力市场
    labor_market.add_demander(demanders{i});
end

fprintf('创建了 %d 个劳动力需求方\n', n_demanders);

%% 4. 基线情形：春季劳动力匹配
fprintf('\n4. 基线情形：春季劳动力匹配...\n');

% 设置春季条件
labor_market.set_season('spring');
climate_conditions = struct('temperature', 18, 'precipitation', 120, 'extreme_events', 0);

% 执行匹配
[matches_spring, wages_spring] = labor_market.match_labor_supply_demand(1, climate_conditions);

% 显示结果
fprintf('春季匹配结果：\n');
fprintf('  成功匹配: %d 对\n', length(matches_spring));
if ~isempty(wages_spring)
    categories = fieldnames(wages_spring);
    for i = 1:length(categories)
        category = categories{i};
        fprintf('  %s工资: %.2f 元/小时\n', category, wages_spring.(category));
    end
end

labor_market.print_market_status();

%% 5. 秋季劳动力匹配（高峰期）
fprintf('\n5. 秋季劳动力匹配（收获高峰期）...\n');

% 设置秋季条件
labor_market.set_season('autumn');
climate_conditions_autumn = struct('temperature', 20, 'precipitation', 80, 'extreme_events', 0);

% 执行匹配
[matches_autumn, wages_autumn] = labor_market.match_labor_supply_demand(9, climate_conditions_autumn);

% 显示结果
fprintf('秋季匹配结果：\n');
fprintf('  成功匹配: %d 对\n', length(matches_autumn));
if ~isempty(wages_autumn)
    categories = fieldnames(wages_autumn);
    for i = 1:length(categories)
        category = categories{i};
        fprintf('  %s工资: %.2f 元/小时\n', category, wages_autumn.(category));
    end
end

%% 6. 气候冲击场景分析
fprintf('\n6. 气候冲击场景分析...\n');

% 设置极端天气条件
climate_shock = struct('temperature', 25, 'precipitation', 40, 'extreme_events', 1);

% 执行匹配
[matches_shock, wages_shock] = labor_market.match_labor_supply_demand(10, climate_shock);

% 分析气候冲击影响
fprintf('气候冲击下的劳动力市场：\n');
fprintf('  匹配数量变化: %d -> %d\n', length(matches_autumn), length(matches_shock));

if ~isempty(wages_autumn) && ~isempty(wages_shock)
    fprintf('  工资变化：\n');
    categories = intersect(fieldnames(wages_autumn), fieldnames(wages_shock));
    for i = 1:length(categories)
        category = categories{i};
        wage_change = (wages_shock.(category) - wages_autumn.(category)) / wages_autumn.(category) * 100;
        fprintf('    %s: %.2f%% 变化\n', category, wage_change);
    end
end

%% 7. 培训决策分析
fprintf('\n7. 培训决策分析...\n');

% 选择几个供给方进行培训决策分析
training_candidates = suppliers(1:3);  % 选择前3个

fprintf('培训决策分析：\n');
for i = 1:length(training_candidates)
    candidate = training_candidates{i};
    
    % 获取可用培训项目
    available_programs = struct2cell(labor_market.training_programs);
    
    % 设置培训补贴
    subsidies = struct('rate', 0.3);  % 30%补贴
    
    % 做出培训决策
    training_decision = candidate.decide_training_participation(available_programs, subsidies);
    
    fprintf('  智能体 %d (%s):\n', candidate.agent_id, candidate.agent_type);
    fprintf('    当前技能等级: %d\n', candidate.skill_level);
    if training_decision.participate
        fprintf('    决定参与培训: %s\n', training_decision.program.name);
        fprintf('    预期净收益: %.0f 元\n', training_decision.expected_benefit);
        
        % 实际参与培训
        candidate.participate_training(training_decision.program);
    else
        fprintf('    决定不参与培训\n');
    end
end

%% 8. 政策实验：最低工资上调
fprintf('\n8. 政策实验：最低工资上调...\n');

% 保存原始最低工资
original_min_wage = labor_market.minimum_wage;

% 上调最低工资到20元/小时
labor_market.minimum_wage = 20;
labor_market.initialize_wage_rates();  % 重新初始化工资率

fprintf('最低工资从 %.0f 元/小时上调到 %.0f 元/小时\n', original_min_wage, labor_market.minimum_wage);

% 重新匹配
[matches_policy, wages_policy] = labor_market.match_labor_supply_demand(11, climate_conditions);

% 分析政策效果
fprintf('最低工资上调后的影响：\n');
fprintf('  匹配数量: %d -> %d\n', length(matches_spring), length(matches_policy));

if ~isempty(wages_spring) && ~isempty(wages_policy)
    categories = intersect(fieldnames(wages_spring), fieldnames(wages_policy));
    for i = 1:length(categories)
        category = categories{i};
        wage_change = wages_policy.(category) - wages_spring.(category);
        fprintf('  %s工资变化: +%.2f 元/小时\n', category, wage_change);
    end
end

%% 9. 季节性需求预测
fprintf('\n9. 季节性需求预测...\n');

% 设置气候预测
climate_forecast = struct('temperature_change', 1.5, 'precipitation_change', -10, 'extreme_events', 0.3);

% 预测季节性需求
demand_forecast = labor_market.forecast_seasonal_demand(climate_forecast, []);

fprintf('未来季节性劳动力需求预测：\n');
seasons = fieldnames(demand_forecast);
for i = 1:length(seasons)
    season = seasons{i};
    if strcmp(season, 'uncertainty')
        continue;
    end
    
    fprintf('  %s季：\n', season);
    seasonal_demand = demand_forecast.(season);
    categories = fieldnames(seasonal_demand);
    for j = 1:length(categories)
        category = categories{j};
        fprintf('    %s: %.0f 小时\n', category, seasonal_demand.(category));
    end
end

fprintf('  预测不确定性: %.1f%%\n', demand_forecast.uncertainty * 100);

%% 10. 全年仿真循环
fprintf('\n10. 全年仿真循环...\n');

seasons_list = {'spring', 'summer', 'autumn', 'winter'};
annual_results = struct();

for season_idx = 1:length(seasons_list)
    season = seasons_list{season_idx};
    
    % 设置季节
    labor_market.set_season(season);
    
    % 设置季节性气候条件
    switch season
        case 'spring'
            climate = struct('temperature', 18, 'precipitation', 120, 'extreme_events', 0);
        case 'summer'
            climate = struct('temperature', 28, 'precipitation', 180, 'extreme_events', 0.1);
        case 'autumn'
            climate = struct('temperature', 20, 'precipitation', 80, 'extreme_events', 0);
        case 'winter'
            climate = struct('temperature', 5, 'precipitation', 40, 'extreme_events', 0);
    end
    
    % 执行匹配
    [matches, wages] = labor_market.match_labor_supply_demand(season_idx, climate);
    
    % 记录结果
    annual_results.(season) = struct('matches', matches, 'wages', wages, 'climate', climate);
    
    % 更新智能体经验
    for i = 1:length(suppliers)
        suppliers{i}.update_experience(3);  % 每季度3个月经验
    end
    
    fprintf('  %s季: %d 对匹配\n', season, length(matches));
end

%% 11. 年度分析和总结
fprintf('\n11. 年度分析和总结...\n');

% 计算年度统计
total_matches = 0;
seasonal_wages = struct();

for season_idx = 1:length(seasons_list)
    season = seasons_list{season_idx};
    matches = annual_results.(season).matches;
    wages = annual_results.(season).wages;
    
    total_matches = total_matches + length(matches);
    
    if ~isempty(wages)
        categories = fieldnames(wages);
        for i = 1:length(categories)
            category = categories{i};
            if ~isfield(seasonal_wages, category)
                seasonal_wages.(category) = [];
            end
            seasonal_wages.(category) = [seasonal_wages.(category), wages.(category)];
        end
    end
end

fprintf('年度劳动力市场总结：\n');
fprintf('  全年总匹配数: %d\n', total_matches);
fprintf('  平均季度匹配: %.1f\n', total_matches/4);

fprintf('\n  各类别年平均工资：\n');
categories = fieldnames(seasonal_wages);
for i = 1:length(categories)
    category = categories{i};
    avg_wage = mean(seasonal_wages.(category));
    wage_volatility = std(seasonal_wages.(category)) / avg_wage;
    fprintf('    %s: %.2f 元/小时 (波动率: %.2f%%)\n', category, avg_wage, wage_volatility*100);
end

%% 12. 智能体状态总结
fprintf('\n12. 智能体状态总结...\n');

% 供给方总结
fprintf('劳动力供给方状态：\n');
skill_distribution = zeros(5, 1);
total_income = 0;
training_participation = 0;

for i = 1:length(suppliers)
    supplier = suppliers{i};
    skill_distribution(supplier.skill_level) = skill_distribution(supplier.skill_level) + 1;
    total_income = total_income + supplier.total_labor_income;
    training_participation = training_participation + length(supplier.training_history);
end

fprintf('  技能分布：\n');
for i = 1:5
    fprintf('    技能等级 %d: %d 人 (%.1f%%)\n', i, skill_distribution(i), skill_distribution(i)/n_suppliers*100);
end
fprintf('  平均收入: %.0f 元\n', total_income/n_suppliers);
fprintf('  培训参与率: %.1f%%\n', training_participation/n_suppliers*100);

% 需求方总结
fprintf('\n劳动力需求方状态：\n');
total_wage_cost = 0;
total_workers = 0;

for i = 1:length(demanders)
    demander = demanders{i};
    wage_cost = demander.calculate_current_wage_cost();
    total_wage_cost = total_wage_cost + wage_cost;
    
    categories = fieldnames(demander.current_labor_force);
    for j = 1:length(categories)
        category = categories{j};
        total_workers = total_workers + demander.current_labor_force.(category).count;
    end
end

fprintf('  平均月工资成本: %.0f 元\n', total_wage_cost/n_demanders);
fprintf('  平均雇佣工人数: %.1f 人\n', total_workers/n_demanders);

%% 13. 最终市场状态
fprintf('\n13. 最终市场状态...\n');
labor_market.print_market_status();

%% 14. 政策建议
fprintf('\n14. 基于仿真结果的政策建议...\n');

fprintf('基于劳动力市场仿真分析，我们提出以下政策建议：\n\n');

fprintf('1. 培训政策：\n');
fprintf('   - 当前培训参与率为 %.1f%%，建议提高培训补贴至50%%以上\n', training_participation/n_suppliers*100);
fprintf('   - 重点支持技能等级1-2的工人提升至技能等级3-4\n\n');

fprintf('2. 工资政策：\n');
fprintf('   - 最低工资调整对就业有一定负面影响，建议渐进式调整\n');
fprintf('   - 通过技能提升实现工资自然增长更为可持续\n\n');

fprintf('3. 季节性调节：\n');
fprintf('   - 秋季劳动力需求高峰明显，建议发展跨地区劳动力调配机制\n');
fprintf('   - 冬季可重点开展技能培训和设备维护\n\n');

fprintf('4. 气候适应：\n');
fprintf('   - 极端天气显著增加劳动力需求，建议建立应急劳动力储备\n');
fprintf('   - 提高农业机械化水平，减少对人工劳动的依赖\n\n');

fprintf('=== 劳动力市场仿真示例完成 ===\n');

%% 保存结果（可选）
% save('labor_market_simulation_results.mat', 'annual_results', 'labor_market', 'suppliers', 'demanders'); 