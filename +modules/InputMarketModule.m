% Version: 2.0-Simplified | Package: modules
% Version: 2.0-Simplified | Package: modules
classdef modules.modules
    % InputMarketModule  农资投入品市场：撮合农户需求与化工企业供给

    properties
        model           % 主模型引用
        application_rate = 0.1;   % 吨/亩  (默认)
        price           % 当前市场价格 (元/吨)
    end

    methods
        function obj = InputMarketModule(model)
            obj.model = model;
            obj.price = model.params.economic.input_price;
            if isfield(model.params.economic,'input_application_rate')
                obj.application_rate = model.params.economic.input_application_rate;
            end
        end

        function update(obj)
            hh = obj.model.households;
            demand_hh = sum(cellfun(@(h) h.land_holding, hh)) * obj.application_rate;

            % 企业农场需求
            ag_ents = obj.get_ag_producers();
            demand_ent = 0;
            for k = 1:numel(ag_ents)
                demand_ent = demand_ent + ag_ents{k}.size * ag_ents{k}.application_rate;
            end

            demand = demand_hh + demand_ent;

            % 让化工企业按需供货
            supply = 0;
            chem_enterprises = obj.get_chemical_enterprises();
            % 随机顺序防止偏差
            chem_enterprises = chem_enterprises(randperm(numel(chem_enterprises)));
            remaining = demand;
            for i = 1:length(chem_enterprises)
                if remaining <= 0, break; end
                supplied = chem_enterprises{i}.supply_inputs(remaining);
                remaining = remaining - supplied;
                supply = supply + supplied;
            end

            % 调价 (简单处理)：p_{t+1}=p_t+phi*(excess/demand)
            phi = 0.05;
            excess = supply - demand;
            if demand>0
                obj.price = max(200, obj.price + phi*excess/demand*obj.price);
            end

            % 政府补贴/税
            gv = obj.model.government;
            consumer_price = obj.price * (1 - gv.policy.fertilizer_subsidy_rate + gv.policy.fertilizer_env_tax);

            % 分发价格到化工企业供参考 & 农户/企业成本
            for i = 1:numel(chem_enterprises)
                chem_enterprises{i}.input_price = consumer_price; %#ok<AGROW>
            end
            % 保存到模型供其他模块使用
            obj.model.current_input_price = consumer_price;

            % 写入结果记录
            record.time = obj.model.current_time;
            record.supply = supply;
            record.demand = demand;
            record.price  = consumer_price;
            obj.model.results.input_market = [obj.model.results.input_market; record];
        end

        function list = get_chemical_enterprises(obj)
            list = {};
            for i = 1:numel(obj.model.enterprises)
                if isa(obj.model.enterprises{i}, 'ChemicalEnterpriseAgent')
                    list{end+1} = obj.model.enterprises{i}; %#ok<AGROW>
                end
            end
        end

        function list = get_ag_producers(obj)
            list = {};
            for i = 1:numel(obj.model.enterprises)
                e = obj.model.enterprises{i};
                if isa(e,'GrainFarmAgent') || isa(e,'CashCropFarmAgent')
                    list{end+1} = e; %#ok<AGROW>
                end
            end
        end
    end
end 
