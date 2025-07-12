%% Experiment 4B – Grain Subsidy Gradient & Regional Heterogeneity
%  Loops over subsidy rates, saves summary per scenario.

addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

subsidy_rates = [0 0.05 0.10 0.20];
scenarios = cellfun(@(r) struct('name',sprintf('Sub%.0f',r*100), 'sub_rate',r), num2cell(subsidy_rates), 'UniformOutput',false);

outDir = fullfile('..','..','results','exp4B');
if ~exist(outDir,'dir'); mkdir(outDir); end

summaryArray = [];
for s = 1:numel(scenarios)
    cfg = MultiAgentClimatePolicyModel().get_default_config();
    cfg.government.grain_subsidy_rate = scenarios{s}.sub_rate;

    model = MultiAgentClimatePolicyModel(cfg);
    model.run_simulation();

    summaryArray = [summaryArray; collect_summary(model, scenarios{s}.name)]; %#ok<AGROW>
    save(fullfile(outDir, [scenarios{s}.name '.mat']), 'model', '-v7.3');
end

writetable(struct2table(summaryArray), fullfile(outDir,'summary.csv')); 