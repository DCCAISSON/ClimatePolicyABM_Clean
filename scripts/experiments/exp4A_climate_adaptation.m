%% Experiment 4A – Climate Adaptation vs Red-Line Relaxation
%  Runs three scenarios and saves results + summary CSV.

addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

scenarios = { ...
    struct('name','Baseline','extreme_prob',0.05,'land_ratio',0.80), ...
    struct('name','Severe_RedLine','extreme_prob',0.20,'land_ratio',0.80), ...
    struct('name','Severe_Relax','extreme_prob',0.20,'land_ratio',0.70)};

outDir = fullfile('..','..','results','exp4A');
if ~exist(outDir,'dir'); mkdir(outDir); end

summaryArray = [];
for s = 1:numel(scenarios)
    cfg = MultiAgentClimatePolicyModel().get_default_config();
    cfg.climate.extreme_event_probability = scenarios{s}.extreme_prob;
    cfg.government.land_red_line_ratio    = scenarios{s}.land_ratio;

    model = MultiAgentClimatePolicyModel(cfg);
    model.run_simulation();

    summaryArray = [summaryArray; collect_summary(model, scenarios{s}.name)]; %#ok<AGROW>
    save(fullfile(outDir, [scenarios{s}.name '.mat']), 'model', '-v7.3');
end

% export CSV
writetable(struct2table(summaryArray), fullfile(outDir,'summary.csv')); 