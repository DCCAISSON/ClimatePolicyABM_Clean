function summary = collect_summary(model, scenarioName)
%COLLECT_SUMMARY Extract key indicators from a finished model run
%   Returns a struct suitable for table conversion / CSV export.

state = model.results.time_series(end);

summary = struct();
summary.scenario          = scenarioName;
summary.mean_income       = state.households.mean_income;
summary.nutrition_health  = state.households.nutrition_health;
summary.off_farm_ratio    = state.households.off_farm_ratio;
summary.grain_ratio       = state.households.grain_planting_ratio;
summary.land_efficiency   = state.households.production_resilience;  % proxy
summary.mean_off_farm_inc = state.households.mean_off_farm_income;
summary.mean_agri_inc     = state.households.mean_agricultural_income;
summary.income_resilience = state.households.income_resilience;
summary.prod_resilience   = state.households.production_resilience;
summary.subsidy_cost      = state.government.total_subsidy_cost;
summary.grain_subsidy_rate= state.government.grain_subsidy_rate;
summary.policy_compliance = state.government.policy_compliance_rate;
end 