% Version: 2.0-Simplified | Package: modules
% Version: 2.0-Simplified | Package: modules
classdef modules.modules
    % LandMarketModule  土地流转市场：农户出租 → 农业企业承租

    properties
        model
    end

    methods
        function obj = LandMarketModule(model)
            obj.model = model;
        end

        function update(obj)
            hh = obj.model.households;
            renters_idx = find(cellfun(@(h) h.decision.land_transfer, hh));
            if isempty(renters_idx)
                return; end

            % 划分按租出去的类型 (简单：若 household.plant_grain==true →租给 grain enterprise)
            supply_grain = [];% struct array {idx, land}
            supply_cash  = [];
            for i = renters_idx
                land_offer = hh{i}.land_holding;
                if hh{i}.decision.plant_grain
                    supply_grain(end+1,:) = [i, land_offer]; %#ok<AGROW>
                else
                    supply_cash(end+1,:) = [i, land_offer]; %#ok<AGROW>
                end
            end

            % Enterprise demand
            grain_ent = obj.get_enterprises('grain');
            cash_ent  = obj.get_enterprises('cash_crop');

            % Process matching separately
            obj.match_supply_demand(supply_grain, grain_ent, obj.model.params.economic.rent_price_grain);
            obj.match_supply_demand(supply_cash,  cash_ent,  obj.model.params.economic.rent_price_cash);
        end

        function ents = get_enterprises(obj, type)
            ents = {};
            for i = 1:numel(obj.model.enterprises)
                e = obj.model.enterprises{i};
                if isa(e,'GrainFarmAgent') && strcmp(type,'grain')
                    ents{end+1}=e; %#ok<AGROW>
                elseif isa(e,'CashCropFarmAgent') && strcmp(type,'cash_crop')
                    ents{end+1}=e; %#ok<AGROW>
                end
            end
            % random shuffle
            ents = ents(randperm(numel(ents)));
        end

        function match_supply_demand(obj, supply, enterprises, rent_price)
            if isempty(supply) || isempty(enterprises); return; end
            % shuffle supply order
            supply = supply(randperm(size(supply,1)),:);
            si = 1; % supply index
            for e = enterprises
                ent = e{1};
                desired = ent.size * 0.2; % wants 20% extra land
                while desired>0 && si<=size(supply,1)
                    hh_idx = supply(si,1);
                    land_avail = supply(si,2);
                    rent_land = min(land_avail, desired);
                    % transfer land
                    hh = obj.model.households{hh_idx};
                    hh.land_holding = hh.land_holding - rent_land;
                    hh.income.rent = hh.income.rent + rent_land * rent_price;
                    hh.update_total_income();
                    
                    ent.size = ent.size + rent_land;
                    supply(si,2) = supply(si,2) - rent_land;
                    desired = desired - rent_land;
                    if supply(si,2)<=0
                        si = si +1;
                    end
                end
                if si>size(supply,1)
                    break; end
            end
        end
    end
end 
