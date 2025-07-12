%% Experiment 4C – Policy-Decision Mismatch & Resilience Types

addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

scenarios = { ...
    struct('name','HighSub_HighRed','sub',0.15,'red',0.85), ...
    struct('name','MidSub_MidRed','sub',0.08,'red',0.78), ...
    struct('name','ZeroSub_LowRed','sub',0.0 ,'red',0.70)};

outDir = fullfile('..','..','results','exp4C');
if ~exist(outDir,'dir'); mkdir(outDir); end

summaryArray = [];
for s = 1:numel(scenarios)
    cfg = MultiAgentClimatePolicyModel().get_default_config();
    cfg.government.grain_subsidy_rate = scenarios{s}.sub;
    cfg.government.land_red_line_ratio = scenarios{s}.red;
    cfg.climate.extreme_event_probability = 0.15;   % moderate shock

    model = MultiAgentClimatePolicyModel(cfg);
    model.run_simulation();

    summaryArray = [summaryArray; collect_summary(model, scenarios{s}.name)]; %#ok<AGROW>
    save(fullfile(outDir, [scenarios{s}.name '.mat']), 'model', '-v7.3');
end

writetable(struct2table(summaryArray), fullfile(outDir,'summary.csv')); 