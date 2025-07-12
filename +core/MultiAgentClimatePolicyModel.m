% Version: 2.0-Simplified | Package: core
% Version: 2.0-Simplified | Package: core
classdef core.core
    % 多智能体气候变化政策模型
    % 包含农户、企业和政府三类智能体
    % 研究气候变化适应性、国家种粮补贴和农户决策的复杂关系
    
    properties
        % 模型参数
        params
        % 智能体集合
        households      % 农户智能体
        enterprises     % 企业智能体
        government      % 政府智能体
        % 空间网格
        spatial_grid
        % 时间步长
        current_time
        max_time
        % 结果记录
        results
        % 随机数生成器
        rng_state
        % 演化博弈模块
        evolutionary_game
        input_market
        land_market
        commodity_market  % 商品市场模块 (新增)
    end
    
    methods
        function obj = MultiAgentClimatePolicyModel(config_file)
            % 构造函数
            if nargin < 1
                config_file = 'default_config.json';
            end
            
            % 初始化模型
            obj.initialize_model(config_file);
        end
        
        function initialize_model(obj, config_file)
            % 初始化模型
            fprintf('=== 多智能体气候变化政策模型初始化 ===\n');
            
            % 加载配置
            obj.load_configuration(config_file);
            
            % 初始化空间网格
            obj.initialize_spatial_grid();
            
            % 创建智能体
            obj.create_agents();
            
            % 初始化时间
            obj.current_time = 0;
            obj.max_time = obj.params.simulation.max_time;
            
            % 初始化结果记录
            obj.initialize_results();
            
            % 保存随机数状态
            obj.rng_state = rng;
            
            % 初始化演化博弈模块（可选高级版本）
            if isfield(obj.params.simulation, 'advanced_game') && obj.params.simulation.advanced_game
                obj.evolutionary_game = EvolutionaryGameModuleAdvanced(obj);
            else
                obj.evolutionary_game = EvolutionaryGameModule(obj);
            end

            % 初始化投入品市场模块
            obj.input_market = InputMarketModule(obj);
            obj.land_market  = LandMarketModule(obj);
            
            % 初始化商品市场模块 (新增)
            obj.commodity_market = CommodityMarketModule(obj);
            
            fprintf('✓ 模型初始化完成\n');
        end
        
        function load_configuration(obj, config_file)
            % 加载模型配置
            try
                if exist(config_file, 'file')
                    config_data = jsondecode(fileread(config_file));
                else
                    % 使用默认配置
                    config_data = obj.get_default_config();
                end
                
                obj.params = config_data;
                fprintf('✓ 配置加载完成\n');
            catch ME
                fprintf('配置加载失败: %s\n', ME.message);
                obj.params = obj.get_default_config();
            end
        end
        
        function config = get_default_config(obj)
            % 获取默认配置
            config = struct();
            
            % 仿真参数
            config.simulation = struct();
            config.simulation.max_time = 100;
            config.simulation.time_step = 1;
            config.simulation.advanced_game = false;  % 是否使用高级演化博弈
            
            % 空间参数
            config.spatial = struct();
            config.spatial.grid_size = [50, 50];
            config.spatial.urban_ratio = 0.3;
            config.spatial.enterprise_density = 0.1;
            
            % 农户参数
            config.households = struct();
            config.households.count = 1000;
            config.households.age_distribution = struct('mean', 45, 'std', 15);
            config.households.family_size_distribution = struct('mean', 4, 'std', 1.5);
            config.households.gender_ratio = 0.5;
            config.households.education_distribution = struct('mean', 9, 'std', 3);
            config.households.land_holding_distribution = struct('mean', 5, 'std', 3);
            config.households.off_farm_income_ratio = struct('mean', 0.6, 'std', 0.2);
            
            % 企业参数
            config.enterprises = struct();
            config.enterprises.count = 100;
            config.enterprises.agricultural_ratio = 0.4;
            config.enterprises.size_distribution = struct('mean', 50, 'std', 20);
            config.enterprises.wage_distribution = struct('mean', 3000, 'std', 1000);
            config.enterprises.chemical_ratio = 0.1; % 化工企业比例
            config.enterprises.grain_farm_ratio = 0.3; % 粮食农场
            config.enterprises.cash_crop_farm_ratio = 0.1;
            
            % 政府参数
            config.government = struct();
            config.government.grain_subsidy_rate = 0.1;
            config.government.land_red_line_ratio = 0.8;
            config.government.climate_adaptation_policy = 0.5;
            config.government.rural_urban_mobility_policy = 0.7;
            config.government.fertilizer_subsidy_rate = 0.0;
            config.government.fertilizer_env_tax     = 0.0;
            % 粮食价格干预区间 (元/公斤)
            config.government.grain_price_floor = 2.0;
            config.government.grain_price_ceil  = 3.0;

            % 气候变化参数
            config.climate = struct();
            config.climate.base_productivity = 1.0;
            config.climate.variability = 0.2;
            config.climate.trend = 0.01;
            config.climate.extreme_event_probability = 0.05;
            
            % 经济参数
            config.economic = struct();
            config.economic.grain_price = 2.5;
            config.economic.cash_crop_price = 4.0;
            config.economic.input_price = 800;
            config.economic.input_application_rate = 0.1; % 吨/亩
            config.economic.rent_price_grain = 800;  % 元/亩/期
            config.economic.rent_price_cash  = 1000; % 经作地租更高
            config.economic.production_cost = 1.5;
            config.economic.transportation_cost = 0.5;
            config.economic.price_adjust_speed = 0.01;  % tâtonnement 速度
        end
        
        function initialize_spatial_grid(obj)
            % 初始化空间网格
            grid_size = obj.params.spatial.grid_size;
            obj.spatial_grid = struct();
            obj.spatial_grid.size = grid_size;
            obj.spatial_grid.cells = zeros(grid_size);
            obj.spatial_grid.land_use = zeros(grid_size);  % 0: 农业用地, 1: 城市用地
            obj.spatial_grid.enterprise_locations = [];
            obj.spatial_grid.household_locations = [];
            
            % 设置城市区域
            urban_ratio = obj.params.spatial.urban_ratio;
            urban_cells = round(prod(grid_size) * urban_ratio);
            urban_indices = randperm(prod(grid_size), urban_cells);
            [urban_rows, urban_cols] = ind2sub(grid_size, urban_indices);
            for i = 1:length(urban_rows)
                obj.spatial_grid.land_use(urban_rows(i), urban_cols(i)) = 1;
            end
            
            fprintf('✓ 空间网格初始化完成 (%dx%d)\n', grid_size(1), grid_size(2));
        end
        
        function create_agents(obj)
            % 创建智能体
            fprintf('创建智能体...\n');
            
            % 创建农户
            obj.create_households();
            
            % 创建企业
            obj.create_enterprises();
            
            % 创建政府
            obj.create_government();
            
            fprintf('✓ 智能体创建完成\n');
        end
        
        function create_households(obj)
            % 创建农户智能体
            household_count = obj.params.households.count;
            obj.households = cell(household_count, 1);
            
            for i = 1:household_count
                household = HouseholdAgent(i, obj.params.households, obj.spatial_grid);
                obj.households{i} = household;
            end
            
            fprintf('  创建了 %d 个农户智能体\n', household_count);
        end
        
        function create_enterprises(obj)
            % 创建企业智能体
            enterprise_count = obj.params.enterprises.count;
            obj.enterprises = cell(enterprise_count, 1);

            % 调整企业类型比例，使其与实际实现的企业类一致
            pesticide_ratio = 0.15;     % 农药企业比例
            fertilizer_ratio = 0.15;    % 化肥企业比例  
            agro_processing_ratio = 0.20; % 农产品加工企业比例
            grain_farm_ratio = obj.params.enterprises.grain_farm_ratio; % 粮食农场
            cash_farm_ratio = obj.params.enterprises.cash_crop_farm_ratio; % 经济作物农场
            
            % 剩余比例分配给通用企业
            total_specific_ratio = pesticide_ratio + fertilizer_ratio + agro_processing_ratio + ...
                                  grain_farm_ratio + cash_farm_ratio;
            remaining_ratio = max(0, 1 - total_specific_ratio);

            for i = 1:enterprise_count
                r = rand;
                if r < pesticide_ratio
                    % 创建农药企业
                    ent = PesticideEnterpriseAgent(i, obj.params.enterprises, obj.spatial_grid, obj.params.government);
                elseif r < pesticide_ratio + fertilizer_ratio
                    % 创建化肥企业
                    ent = FertilizerEnterpriseAgent(i, obj.params.enterprises, obj.spatial_grid, obj.params.government);
                elseif r < pesticide_ratio + fertilizer_ratio + agro_processing_ratio
                    % 创建农产品加工企业
                    ent = AgroProcessingEnterpriseAgent(i, obj.params.enterprises, obj.spatial_grid, obj.params.government);
                elseif r < pesticide_ratio + fertilizer_ratio + agro_processing_ratio + grain_farm_ratio
                    % 创建粮食农场企业
                    ent = GrainFarmAgent(i, obj.params.enterprises, obj.spatial_grid);
                elseif r < pesticide_ratio + fertilizer_ratio + agro_processing_ratio + grain_farm_ratio + cash_farm_ratio
                    % 创建经济作物农场企业
                    ent = CashCropFarmAgent(i, obj.params.enterprises, obj.spatial_grid);
                else
                    % 创建通用企业（工业/服务业）
                    ent = EnterpriseAgent(i, obj.params.enterprises, obj.spatial_grid);
                end
                obj.enterprises{i} = ent;
            end

            fprintf('  企业创建完毕: 农药 %.0f%% 化肥 %.0f%% 加工 %.0f%% 粮农 %.0f%% 经作 %.0f%% 其他 %.0f%%\n',...
                pesticide_ratio*100, fertilizer_ratio*100, agro_processing_ratio*100, ...
                grain_farm_ratio*100, cash_farm_ratio*100, remaining_ratio*100);
        end
        
        function create_government(obj)
            % 创建政府智能体
            obj.government = GovernmentAgent(obj.params.government);
            fprintf('  创建了政府智能体\n');
        end
        
        function initialize_results(obj)
            % 初始化结果记录
            obj.results = struct();
            obj.results.time_series = [];
            obj.results.household_data = [];
            obj.results.enterprise_data = [];
            obj.results.government_data = [];
            obj.results.climate_data = [];
            obj.results.policy_effects = [];
        end
        
        function run_simulation(obj)
            % 运行仿真
            fprintf('=== 开始仿真 ===\n');
            fprintf('仿真时长: %d 时间步\n', obj.max_time);
            
            % 记录初始状态
            obj.record_results(0);
            
            % 主仿真循环
            for t = 1:obj.max_time
                obj.current_time = t;
                
                % 更新气候条件
                obj.update_climate_conditions(t);
                
                % 更新智能体决策 (使用新的异质性决策机制)
                obj.update_agent_decisions(t);
                
                % 更新市场
                obj.update_markets(t);
                
                % 更新智能体状态
                obj.update_agent_states(t);
                
                % 更新政策效果
                obj.update_policy_effects(t);
                
                % 记录结果
                obj.record_results(t);
                
                % 显示进度
                if mod(t, 10) == 0
                    fprintf('仿真进度: %d/%d (%.1f%%)\n', t, obj.max_time, 100*t/obj.max_time);
                end
            end
            
            fprintf('✓ 仿真完成\n');
        end
        
        function update_agent_decisions(obj, current_time)
            % 更新智能体决策 (使用新的异质性决策机制)
            
            % 更新农户决策
            for i = 1:length(obj.households)
                obj.households{i}.update_decision(obj, current_time);
            end
            
            % 更新企业决策
            for i = 1:length(obj.enterprises)
                obj.enterprises{i}.update_decision(obj, current_time);
            end
            
            % 更新政府政策
            obj.government.update_policy(obj, current_time);
        end
        
        function update_climate(obj)
            % 更新气候变化
            climate_params = obj.params.climate;
            
            % 计算当前气候影响
            base_productivity = climate_params.base_productivity;
            variability = climate_params.variability;
            trend = climate_params.trend;
            
            % 随机气候冲击
            if rand < climate_params.extreme_event_probability
                climate_shock = randn * 0.5;  % 极端气候事件
            else
                climate_shock = randn * variability;  % 正常气候波动
            end
            
            % 长期气候变化趋势
            climate_trend = trend * obj.current_time;
            
            % 总气候影响
            climate_impact = base_productivity + climate_shock + climate_trend;
            
            % 记录气候数据
            climate_data = struct();
            climate_data.time = obj.current_time;
            climate_data.productivity = climate_impact;
            climate_data.shock = climate_shock;
            climate_data.trend = climate_trend;
            
            obj.results.climate_data = [obj.results.climate_data; climate_data];
        end
        
        function update_enterprises(obj)
            % 更新企业决策
            for i = 1:length(obj.enterprises)
                enterprise = obj.enterprises{i};
                enterprise.update_decision(obj.current_time, obj.government, obj.results);
            end
        end
        
        function update_households(obj)
            % 更新农户决策
            for i = 1:length(obj.households)
                household = obj.households{i};
                household.update_decision(obj.current_time, obj.government, obj.enterprises, obj.results);
            end
        end
        
        function update_household_consumption(obj)
            % 更新农户消费决策 (新增)
            for i = 1:length(obj.households)
                household = obj.households{i};
                household.update_consumption(obj.commodity_market);
            end
        end
        
        function update_market_prices(obj)
            % 粮食现货市场：供需出清 + 政府区间干预
            hh = obj.households;
            nH = numel(hh);
            % ⇢ 简化：每户产出=land_holding*base_yield*(plant_grain)
            base_yield = 1000;  % 单位产量
            supply = 0;
            for i=1:nH
                if hh{i}.decision.plant_grain
                    supply = supply + hh{i}.land_holding * base_yield;
                end
            end
            % 需求：假设常数/人
            demand = nH * 800;  % 每户需求 800 单位
            excess = supply - demand;
            % 当前价格
            p_old = obj.params.economic.grain_price;
            phi = obj.params.economic.price_adjust_speed;
            p_new = p_old + phi * excess / max(1,demand);
            % 政府干预区间
            floorP = obj.government.grain_price_floor;
            ceilP = obj.government.grain_price_ceil;
            gv = obj.government;
            if p_new < floorP
                % 政府收购
                p_new = floorP;
                gv.add_stock(abs(excess));
            elseif p_new > ceilP
                gv.remove_stock(abs(excess));
                p_new = ceilP;
            end
            % 写回价格
            obj.params.economic.grain_price = p_new;

            % ---- 重新计算农户农业收入 ----
            if ~isempty(obj.results.climate_data)
                climate_factor = obj.results.climate_data(end).productivity;
            else
                climate_factor = 1;
            end
            market_prices_struct = struct('grain', p_new, 'cash_crop', obj.params.economic.cash_crop_price, 'input', obj.current_input_price);
            for i = 1:nH
                hh{i}.update_agricultural_income(climate_factor, market_prices_struct, obj.params.economic.input_application_rate);
            end

            % 将价格写入农业企业
            for ei = 1:numel(obj.enterprises)
                if isa(obj.enterprises{ei}, 'ChemicalEnterpriseAgent')
                    continue; end
                if strcmp(obj.enterprises{ei}.type,'agricultural')
                    obj.enterprises{ei}.last_input_price = obj.current_input_price;
                end
            end
        end
        
        function agent_interactions(obj)
            % 智能体交互
            % 农户与企业之间的劳动力市场
            obj.labor_market_interaction();
            
            % 农户与政府之间的政策响应
            obj.policy_response_interaction();
            
            % 企业之间的竞争与合作
            obj.enterprise_competition();
        end
        
        function labor_market_interaction(obj)
            % 劳动力市场交互 —— 随机搜索与匹配
            % 1) 收集求职农户
            worker_idx = find(cellfun(@(h) h.decision.work_off_farm, obj.households));
            if isempty(worker_idx)
                return;
            end

            % 2) 生成企业空缺列表 (每个空缺为企业索引的一次重复)
            vacancy_enterprise_idx = [];
            for ei = 1:numel(obj.enterprises)
                e = obj.enterprises{ei};
                vacancies = max(0, e.max_workers - e.workers);
                if vacancies > 0
                    vacancy_enterprise_idx = [vacancy_enterprise_idx, repmat(ei, 1, vacancies)]; %#ok<AGROW>
                end
            end

            if isempty(vacancy_enterprise_idx)
                return; % 没有空缺
            end

            % 3) 依据距离的贪婪最近匹配
            worker_idx = worker_idx(randperm(numel(worker_idx))); % 保持随机到达顺序

            % vacancy map: enterprise idx -> remaining slots
            vacRemain = accumarray(vacancy_enterprise_idx',1);
            enterprise_ids = find(vacRemain>0);

            for wi = 1:numel(worker_idx)
                if isempty(enterprise_ids)
                    break; % 无空缺
                end

                h = obj.households{worker_idx(wi)};
                % 计算至每个有空缺企业的距离
                dists = zeros(numel(enterprise_ids),1);
                for j = 1:numel(enterprise_ids)
                    ent = obj.enterprises{enterprise_ids(j)};
                    dists(j) = norm(h.location - ent.location);
                end
                [~,minIdx] = min(dists);
                chosenEntID = enterprise_ids(minIdx);
                entObj = obj.enterprises{chosenEntID};
                h.work_at_enterprise(entObj);

                % 减少该企业空缺
                vacRemain(chosenEntID) = vacRemain(chosenEntID) - 1;
                if vacRemain(chosenEntID) <= 0
                    enterprise_ids(enterprise_ids==chosenEntID) = [];
                end
            end
        end
        
        function nearest_enterprise = find_nearest_enterprise(obj, household_location)
            % 寻找最近的可用企业
            nearest_enterprise = [];
            min_distance = inf;
            
            for i = 1:length(obj.enterprises)
                enterprise = obj.enterprises{i};
                if enterprise.can_hire_workers()
                    distance = norm(household_location - enterprise.location);
                    if distance < min_distance
                        min_distance = distance;
                        nearest_enterprise = enterprise;
                    end
                end
            end
        end
        
        function policy_response_interaction(obj)
            % 政策响应交互
            % 农户对政府政策的响应
            for i = 1:length(obj.households)
                household = obj.households{i};
                household.respond_to_policy(obj.government);
            end
            
            % 企业对政府政策的响应
            for i = 1:length(obj.enterprises)
                enterprise = obj.enterprises{i};
                enterprise.respond_to_policy(obj.government);
            end
        end
        
        function enterprise_competition(obj)
            % 企业竞争
            % 农业企业之间的竞争
            agricultural_enterprises = obj.get_agricultural_enterprises();
            if length(agricultural_enterprises) > 1
                obj.competition_among_agricultural_enterprises(agricultural_enterprises);
            end
        end
        
        function agricultural_enterprises = get_agricultural_enterprises(obj)
            % 获取农业企业
            agricultural_enterprises = {};
            for i = 1:length(obj.enterprises)
                if strcmp(obj.enterprises{i}.type, 'agricultural')
                    agricultural_enterprises{end+1} = obj.enterprises{i};
                end
            end
        end
        
        function competition_among_agricultural_enterprises(obj, enterprises)
            % 农业企业之间的竞争
            % 基于生产效率、地理位置等因素的竞争
            for i = 1:length(enterprises)
                enterprise = enterprises{i};
                enterprise.update_competitiveness(enterprises);
            end
        end
        
        function record_state(obj)
            % 记录当前状态
            state = struct();
            state.time = obj.current_time;
            
            % 农户状态
            state.households = obj.record_household_state();
            
            % 企业状态
            state.enterprises = obj.record_enterprise_state();
            
            % 政府状态
            state.government = obj.record_government_state();
            
            % 商品市场状态 (新增)
            state.commodity_market = obj.record_commodity_market_state();
            
            % 添加到时间序列
            obj.results.time_series = [obj.results.time_series; state];
        end
        
        function household_state = record_household_state(obj)
            % 记录农户状态
            stats = obj.calculate_household_statistics();
            household_state = stats;
        end
        
        function enterprise_state = record_enterprise_state(obj)
            % 记录企业状态
            stats = obj.calculate_enterprise_statistics();
            enterprise_state = stats;
        end
        
        function government_state = record_government_state(obj)
            % 记录政府状态
            stats = obj.calculate_government_statistics();
            government_state = stats;
        end
        
        function commodity_market_state = record_commodity_market_state(obj)
            % 记录商品市场状态 (新增)
            commodity_market_state = struct();
            
            if ~isempty(obj.commodity_market)
                % 市场价格
                commodity_market_state.prices = obj.commodity_market.market_prices;
                
                % 供需情况
                commodity_market_state.supply = obj.commodity_market.supply;
                commodity_market_state.demand = obj.commodity_market.demand;
                
                % 市场出清状态
                commodity_market_state.market_clearing = obj.commodity_market.market_clearing;
                
                % 福利指标
                if ~isempty(obj.commodity_market.welfare_history)
                    latest_welfare = obj.commodity_market.welfare_history(end);
                    commodity_market_state.consumer_surplus = latest_welfare.consumer_surplus;
                    commodity_market_state.producer_surplus = latest_welfare.producer_surplus;
                    commodity_market_state.social_welfare = latest_welfare.social_welfare;
                    commodity_market_state.price_index = latest_welfare.price_index;
                else
                    commodity_market_state.consumer_surplus = 0;
                    commodity_market_state.producer_surplus = 0;
                    commodity_market_state.social_welfare = 0;
                    commodity_market_state.price_index = 1.0;
                end
            else
                % 默认值
                commodity_market_state.prices = zeros(7, 1);
                commodity_market_state.supply = zeros(7, 1);
                commodity_market_state.demand = zeros(7, 1);
                commodity_market_state.market_clearing = false(7, 1);
                commodity_market_state.consumer_surplus = 0;
                commodity_market_state.producer_surplus = 0;
                commodity_market_state.social_welfare = 0;
                commodity_market_state.price_index = 1.0;
            end
        end
        
        function stats = calculate_household_statistics(obj)
            % 计算农户统计
            stats = struct();
            
            total_households = length(obj.households);
            stats.total_count = total_households;
            
            % 收入统计
            incomes = zeros(total_households, 1);
            off_farm_incomes = zeros(total_households, 1);
            agricultural_incomes = zeros(total_households, 1);
            
            for i = 1:total_households
                household = obj.households{i};
                incomes(i) = household.income.total;
                off_farm_incomes(i) = household.income.off_farm;
                agricultural_incomes(i) = household.income.agricultural;
            end
            
            stats.mean_income = mean(incomes);
            stats.std_income = std(incomes);
            stats.mean_off_farm_income = mean(off_farm_incomes);
            stats.mean_agricultural_income = mean(agricultural_incomes);
            
            % 决策统计
            work_off_farm_count = sum(cellfun(@(h) h.decision.work_off_farm, obj.households));
            stats.off_farm_ratio = work_off_farm_count / total_households;
            
            % 种植结构统计
            grain_planting_count = sum(cellfun(@(h) h.decision.plant_grain, obj.households));
            stats.grain_planting_ratio = grain_planting_count / total_households;
            
            % 韧性指标
            stats.income_resilience = obj.calculate_income_resilience();
            stats.production_resilience = obj.calculate_production_resilience();
            stats.nutrition_health = obj.calculate_nutrition_health();
        end
        
        function stats = calculate_enterprise_statistics(obj)
            % 计算企业统计
            stats = struct();
            
            total_enterprises = length(obj.enterprises);
            stats.total_count = total_enterprises;
            
            % 企业类型统计
            enterprise_types = cellfun(@(e) e.type, obj.enterprises, 'UniformOutput', false);
            agricultural_count = sum(strcmp(enterprise_types, 'agricultural'));
            stats.agricultural_ratio = agricultural_count / total_enterprises;
            
            % 生产效率统计
            productivities = cellfun(@(e) e.productivity, obj.enterprises);
            stats.mean_productivity = mean(productivities);
            stats.std_productivity = std(productivities);
            
            % 雇佣统计
            total_workers = sum(cellfun(@(e) e.workers, obj.enterprises));
            stats.total_workers = total_workers;
            stats.mean_workers_per_enterprise = total_workers / total_enterprises;
        end
        
        function stats = calculate_government_statistics(obj)
            % 计算政府统计
            stats = struct();
            
            % 政策参数
            stats.grain_subsidy_rate = obj.government.policy.grain_subsidy_rate;
            stats.land_red_line_ratio = obj.government.policy.land_red_line_ratio;
            stats.climate_adaptation_policy = obj.government.policy.climate_adaptation_policy;
            stats.rural_urban_mobility_policy = obj.government.policy.rural_urban_mobility_policy;
            
            % 政策效果统计
            stats.total_subsidy_cost = obj.government.total_subsidy_cost;
            stats.policy_compliance_rate = obj.government.policy_compliance_rate;
            
            % 财政统计 (新增)
            if isfield(obj.government, 'budget')
                stats.fiscal_revenue = obj.government.budget.revenue.total;
                stats.fiscal_expenditure = obj.government.budget.expenditure.total;
                stats.fiscal_balance = obj.government.budget.balance;
                stats.fiscal_deficit = obj.government.budget.deficit;
                stats.fiscal_debt = obj.government.budget.debt;
                
                % 收入结构
                stats.tax_income = obj.government.budget.revenue.tax_income;
                stats.tax_corporate = obj.government.budget.revenue.tax_corporate;
                stats.tax_consumption = obj.government.budget.revenue.tax_consumption;
                stats.tax_property = obj.government.budget.revenue.tax_property;
                stats.tax_land = obj.government.budget.revenue.tax_land;
                stats.social_insurance = obj.government.budget.revenue.social_insurance;
                
                % 支出结构
                stats.expenditure_consumption = obj.government.budget.expenditure.consumption;
                stats.expenditure_investment = obj.government.budget.expenditure.investment;
                stats.expenditure_transfers = obj.government.budget.expenditure.transfers;
                stats.expenditure_social_security = obj.government.budget.expenditure.social_security;
                stats.expenditure_health = obj.government.budget.expenditure.health;
                stats.expenditure_education = obj.government.budget.expenditure.education;
                stats.expenditure_infrastructure = obj.government.budget.expenditure.infrastructure;
                stats.expenditure_administration = obj.government.budget.expenditure.administration;
            else
                % 默认值
                stats.fiscal_revenue = 0;
                stats.fiscal_expenditure = 0;
                stats.fiscal_balance = 0;
                stats.fiscal_deficit = 0;
                stats.fiscal_debt = 0;
                stats.tax_income = 0;
                stats.tax_corporate = 0;
                stats.tax_consumption = 0;
                stats.tax_property = 0;
                stats.tax_land = 0;
                stats.social_insurance = 0;
                stats.expenditure_consumption = 0;
                stats.expenditure_investment = 0;
                stats.expenditure_transfers = 0;
                stats.expenditure_social_security = 0;
                stats.expenditure_health = 0;
                stats.expenditure_education = 0;
                stats.expenditure_infrastructure = 0;
                stats.expenditure_administration = 0;
            end
        end
        
        function resilience = calculate_income_resilience(obj)
            % 计算收入韧性
            % 基于收入波动性和恢复能力
            if length(obj.results.time_series) < 5
                resilience = 0.5;  % 默认值
                return;
            end
            
            recent_households = obj.results.time_series(end-4:end);
            recent_incomes = arrayfun(@(t) t.households.mean_income, recent_households);
            income_volatility = std(recent_incomes) / mean(recent_incomes);
            resilience = max(0, 1 - income_volatility);
        end
        
        function resilience = calculate_production_resilience(obj)
            % 计算生产韧性
            % 基于种植结构稳定性和产量波动
            if length(obj.results.time_series) < 5
                resilience = 0.5;  % 默认值
                return;
            end
            
            recent_households = obj.results.time_series(end-4:end);
            recent_grain_ratios = arrayfun(@(t) t.households.grain_planting_ratio, recent_households);
            production_stability = 1 - std(recent_grain_ratios);
            resilience = max(0, production_stability);
        end
        
        function health = calculate_nutrition_health(obj)
            % 计算营养健康指标
            % 基于收入水平和食物多样性
            if isempty(obj.results.time_series)
                health = 0.5;  % 默认值
                return;
            end
            
            final_state = obj.results.time_series(end);
            mean_income = final_state.households.mean_income;
            grain_ratio = final_state.households.grain_planting_ratio;
            
            % 简化的营养健康指标
            income_factor = min(1, mean_income / 10000);  % 收入因子
            diversity_factor = 1 - abs(grain_ratio - 0.5);  % 多样性因子
            
            health = (income_factor + diversity_factor) / 2;
        end
        
        function converged = check_convergence(obj)
            % 检查收敛条件
            if length(obj.results.time_series) < 10
                converged = false;
                return;
            end
            
            % 检查收入稳定性
            recent_states = obj.results.time_series(end-9:end);
            recent_incomes = arrayfun(@(t) t.households.mean_income, recent_states);
            income_change = abs(recent_incomes(end) - recent_incomes(1)) / recent_incomes(1);
            
            % 检查种植结构稳定性
            recent_grain_ratios = arrayfun(@(t) t.households.grain_planting_ratio, recent_states);
            grain_ratio_change = abs(recent_grain_ratios(end) - recent_grain_ratios(1));
            
            % 收敛条件
            converged = income_change < 0.01 && grain_ratio_change < 0.01;
        end
        
        function generate_results_report(obj)
            % 生成结果报告
            fprintf('\n=== 仿真结果报告 ===\n');
            
            % 总体统计
            final_state = obj.results.time_series(end);
            fprintf('最终农户数量: %d\n', final_state.households.total_count);
            fprintf('最终企业数量: %d\n', final_state.enterprises.total_count);
            fprintf('平均农户收入: %.2f\n', final_state.households.mean_income);
            fprintf('外出务工比例: %.2f%%\n', final_state.households.off_farm_ratio * 100);
            fprintf('粮食种植比例: %.2f%%\n', final_state.households.grain_planting_ratio * 100);
            
            % 商品市场统计 (新增)
            fprintf('\n商品市场统计:\n');
            fprintf('消费者剩余: %.2f\n', final_state.commodity_market.consumer_surplus);
            fprintf('生产者剩余: %.2f\n', final_state.commodity_market.producer_surplus);
            fprintf('社会福利: %.2f\n', final_state.commodity_market.social_welfare);
            fprintf('价格指数: %.3f\n', final_state.commodity_market.price_index);
            
            % 财政统计 (新增)
            fprintf('\n财政统计:\n');
            fprintf('政府总收入: %.2f\n', final_state.government.fiscal_revenue);
            fprintf('政府总支出: %.2f\n', final_state.government.fiscal_expenditure);
            fprintf('财政余额: %.2f\n', final_state.government.fiscal_balance);
            fprintf('财政赤字: %.2f\n', final_state.government.fiscal_deficit);
            fprintf('公共债务: %.2f\n', final_state.government.fiscal_debt);
            
            % 税收结构
            fprintf('\n税收结构:\n');
            fprintf('所得税: %.2f\n', final_state.government.tax_income);
            fprintf('企业所得税: %.2f\n', final_state.government.tax_corporate);
            fprintf('消费税: %.2f\n', final_state.government.tax_consumption);
            fprintf('财产税: %.2f\n', final_state.government.tax_property);
            fprintf('土地税: %.2f\n', final_state.government.tax_land);
            fprintf('社会保险: %.2f\n', final_state.government.social_insurance);
            
            % 支出结构
            fprintf('\n支出结构:\n');
            fprintf('政府消费: %.2f\n', final_state.government.expenditure_consumption);
            fprintf('政府投资: %.2f\n', final_state.government.expenditure_investment);
            fprintf('转移支付: %.2f\n', final_state.government.expenditure_transfers);
            fprintf('社会保障: %.2f\n', final_state.government.expenditure_social_security);
            fprintf('医疗支出: %.2f\n', final_state.government.expenditure_health);
            fprintf('教育支出: %.2f\n', final_state.government.expenditure_education);
            fprintf('基础设施: %.2f\n', final_state.government.expenditure_infrastructure);
            fprintf('行政管理: %.2f\n', final_state.government.expenditure_administration);
            
            % 韧性指标
            fprintf('\n韧性指标:\n');
            fprintf('收入韧性: %.3f\n', final_state.households.income_resilience);
            fprintf('生产韧性: %.3f\n', final_state.households.production_resilience);
            fprintf('营养健康: %.3f\n', final_state.households.nutrition_health);
            
            % 政策效果
            fprintf('\n政策效果:\n');
            fprintf('种粮补贴率: %.2f%%\n', final_state.government.grain_subsidy_rate * 100);
            fprintf('耕地红线比例: %.2f%%\n', final_state.government.land_red_line_ratio * 100);
            fprintf('总补贴成本: %.2f\n', final_state.government.total_subsidy_cost);
            
            % 保存结果
            save('multi_agent_climate_policy_results.mat', 'obj');
            fprintf('\n结果已保存到 multi_agent_climate_policy_results.mat\n');
        end
        
        function plot_results(obj)
            % 绘制结果图表
            if isempty(obj.results.time_series)
                fprintf('没有可用的结果数据\n');
                return;
            end
            
            % 创建图形
            figure('Position', [100, 100, 1400, 1000]);
            
            % 子图1: 收入变化
            subplot(3, 4, 1);
            times = arrayfun(@(t) t.time, obj.results.time_series);
            incomes = arrayfun(@(t) t.households.mean_income, obj.results.time_series);
            plot(times, incomes, 'b-', 'LineWidth', 2);
            title('农户平均收入变化');
            xlabel('时间步');
            ylabel('收入');
            grid on;
            
            % 子图2: 外出务工比例
            subplot(3, 4, 2);
            off_farm_ratios = arrayfun(@(t) t.households.off_farm_ratio * 100, obj.results.time_series);
            plot(times, off_farm_ratios, 'r-', 'LineWidth', 2);
            title('外出务工比例变化');
            xlabel('时间步');
            ylabel('比例 (%)');
            grid on;
            
            % 子图3: 粮食种植比例
            subplot(3, 4, 3);
            grain_ratios = arrayfun(@(t) t.households.grain_planting_ratio * 100, obj.results.time_series);
            plot(times, grain_ratios, 'g-', 'LineWidth', 2);
            title('粮食种植比例变化');
            xlabel('时间步');
            ylabel('比例 (%)');
            grid on;
            
            % 子图4: 韧性指标
            subplot(3, 4, 4);
            income_resilience = arrayfun(@(t) t.households.income_resilience, obj.results.time_series);
            production_resilience = arrayfun(@(t) t.households.production_resilience, obj.results.time_series);
            nutrition_health = arrayfun(@(t) t.households.nutrition_health, obj.results.time_series);
            
            plot(times, income_resilience, 'b-', 'LineWidth', 2);
            hold on;
            plot(times, production_resilience, 'r-', 'LineWidth', 2);
            plot(times, nutrition_health, 'g-', 'LineWidth', 2);
            title('韧性指标变化');
            xlabel('时间步');
            ylabel('韧性值');
            legend('收入韧性', '生产韧性', '营养健康');
            grid on;
            
            % 子图5: 气候影响
            subplot(3, 4, 5);
            if ~isempty(obj.results.climate_data)
                climate_times = arrayfun(@(c) c.time, obj.results.climate_data);
                climate_productivity = arrayfun(@(c) c.productivity, obj.results.climate_data);
                plot(climate_times, climate_productivity, 'm-', 'LineWidth', 2);
                title('气候生产力变化');
                xlabel('时间步');
                ylabel('生产力');
                grid on;
            end
            
            % 子图6: 政策效果
            subplot(3, 4, 6);
            subsidy_costs = arrayfun(@(t) t.government.total_subsidy_cost, obj.results.time_series);
            plot(times, subsidy_costs, 'k-', 'LineWidth', 2);
            title('政府补贴成本变化');
            xlabel('时间步');
            ylabel('补贴成本');
            grid on;
            
            % 子图7: 商品市场价格指数 (新增)
            subplot(3, 4, 7);
            price_indices = arrayfun(@(t) t.commodity_market.price_index, obj.results.time_series);
            plot(times, price_indices, 'c-', 'LineWidth', 2);
            title('商品市场价格指数');
            xlabel('时间步');
            ylabel('价格指数');
            grid on;
            
            % 子图8: 社会福利 (新增)
            subplot(3, 4, 8);
            social_welfare = arrayfun(@(t) t.commodity_market.social_welfare, obj.results.time_series);
            consumer_surplus = arrayfun(@(t) t.commodity_market.consumer_surplus, obj.results.time_series);
            producer_surplus = arrayfun(@(t) t.commodity_market.producer_surplus, obj.results.time_series);
            
            plot(times, social_welfare, 'b-', 'LineWidth', 2);
            hold on;
            plot(times, consumer_surplus, 'r-', 'LineWidth', 2);
            plot(times, producer_surplus, 'g-', 'LineWidth', 2);
            title('福利指标变化');
            xlabel('时间步');
            ylabel('福利值');
            legend('社会福利', '消费者剩余', '生产者剩余');
            grid on;
            
            % 子图9: 商品供需平衡 (新增)
            subplot(3, 4, 9);
            if ~isempty(obj.results.time_series)
                latest_state = obj.results.time_series(end);
                commodity_types = {'食品', '服装', '住房', '教育', '医疗', '娱乐', '交通'};
                supply = latest_state.commodity_market.supply;
                demand = latest_state.commodity_market.demand;
                
                bar([supply, demand]);
                xlabel('商品类型');
                ylabel('数量');
                title('商品供需平衡');
                legend('供给', '需求');
                set(gca, 'XTickLabel', commodity_types);
                grid on;
            end
            
            % 子图10: 市场出清状态 (新增)
            subplot(3, 4, 10);
            if ~isempty(obj.results.time_series)
                latest_state = obj.results.time_series(end);
                market_clearing = latest_state.commodity_market.market_clearing;
                
                imagesc(market_clearing');
                xlabel('时间步');
                ylabel('商品类型');
                title('市场出清状态');
                set(gca, 'YTickLabel', commodity_types);
                colorbar;
            end
            
            % 子图11: 价格趋势 (新增)
            subplot(3, 4, 11);
            if ~isempty(obj.results.time_series)
                latest_state = obj.results.time_series(end);
                prices = latest_state.commodity_market.prices;
                
                bar(prices);
                xlabel('商品类型');
                ylabel('价格');
                title('商品价格');
                set(gca, 'XTickLabel', commodity_types);
                grid on;
            end
            
            % 子图12: 消费结构 (新增)
            subplot(3, 4, 12);
            if ~isempty(obj.results.time_series)
                % 计算平均消费结构
                total_consumption = zeros(7, 1);
                for i = 1:length(obj.households)
                    household = obj.households{i};
                    if ~isempty(household.consumption.history)
                        latest_consumption = household.consumption.history(end);
                        total_consumption(1) = total_consumption(1) + latest_consumption.food;
                        total_consumption(2) = total_consumption(2) + latest_consumption.clothing;
                        total_consumption(3) = total_consumption(3) + latest_consumption.housing;
                        total_consumption(4) = total_consumption(4) + latest_consumption.education;
                        total_consumption(5) = total_consumption(5) + latest_consumption.health;
                        total_consumption(6) = total_consumption(6) + latest_consumption.entertainment;
                        total_consumption(7) = total_consumption(7) + latest_consumption.transportation;
                    end
                end
                
                pie(total_consumption, commodity_types);
                title('农户消费结构');
            end
            
            % 保存图形
            saveas(gcf, 'multi_agent_climate_policy_results.png');
            fprintf('结果图表已保存到 multi_agent_climate_policy_results.png\n');
        end
        
        function update_model_configuration(obj)
            % 更新模型配置
            % 当参数发生变化时，重新初始化相关组件
            
            fprintf('更新模型配置...\n');
            
            % 更新空间网格
            obj.initialize_spatial_grid();
            
            % 更新智能体参数
            for i = 1:length(obj.households)
                obj.households{i}.update_parameters(obj.params.households);
            end
            
            for i = 1:length(obj.enterprises)
                obj.enterprises{i}.update_parameters(obj.params.enterprises);
            end
            
            obj.government.update_parameters(obj.params.government);
            
            fprintf('✓ 模型配置更新完成\n');
        end
    end
end 
