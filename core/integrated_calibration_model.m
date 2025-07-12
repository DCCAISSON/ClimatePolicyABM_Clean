function [model, calibration_results] = integrated_calibration_model(varargin)
% 集成校准和模型的脚本
% 将校准结果应用到多智能体气候变化政策模型中
%
% 输入参数:
%   varargin: 可选参数
%     'calibration_file': 校准结果文件路径
%     'config_file': 模型配置文件路径
%     'run_simulation': 是否运行仿真
%     'plot_results': 是否绘制结果
%
% 输出参数:
%   model: 校准后的多智能体模型
%   calibration_results: 校准结果

% 解析可选参数
p = inputParser;
addParameter(p, 'calibration_file', '', @ischar);
addParameter(p, 'config_file', 'params/climate_policy_config.json', @ischar);
addParameter(p, 'run_simulation', true, @islogical);
addParameter(p, 'plot_results', true, @islogical);
parse(p, varargin{:});

calibration_file = p.Results.calibration_file;
config_file = p.Results.config_file;
run_simulation = p.Results.run_simulation;
plot_results = p.Results.plot_results;

fprintf('=== 集成校准和模型 ===\n');

try
    %% 1. 加载校准结果
    fprintf('1. 加载校准结果...\n');
    
    if isempty(calibration_file)
        % 查找最新的校准结果文件
        calibration_dir = '../calibration/calibration_results';
        if exist(calibration_dir, 'dir')
            files = dir(fullfile(calibration_dir, 'calibration_results_*.mat'));
            if ~isempty(files)
                [~, idx] = max([files.datenum]);
                calibration_file = fullfile(calibration_dir, files(idx).name);
                fprintf('  使用最新校准结果: %s\n', files(idx).name);
            end
        end
    end
    
    if ~isempty(calibration_file) && exist(calibration_file, 'file')
        load(calibration_file, 'calibrated_params', 'calibration_results');
        fprintf('✓ 校准结果加载成功\n');
    else
        fprintf('⚠ 未找到校准结果文件，使用默认参数\n');
        calibrated_params = struct();
        calibration_results = struct();
    end
    
    %% 2. 创建多智能体模型
    fprintf('2. 创建多智能体模型...\n');
    
    % 创建模型实例
    model = MultiAgentClimatePolicyModel(config_file);
    
    %% 3. 应用校准参数
    fprintf('3. 应用校准参数...\n');
    
    if ~isempty(fieldnames(calibrated_params))
        model = apply_calibrated_parameters(model, calibrated_params);
        fprintf('✓ 校准参数应用成功\n');
    else
        fprintf('⚠ 使用默认参数\n');
    end
    
    %% 4. 运行仿真（可选）
    if run_simulation
        fprintf('4. 运行仿真...\n');
        model.run_simulation();
        
        %% 5. 绘制结果（可选）
        if plot_results
            fprintf('5. 绘制结果...\n');
            model.plot_results();
        end
        
        %% 6. 生成分析报告
        fprintf('6. 生成分析报告...\n');
        generate_integrated_report(model, calibration_results);
    end
    
    fprintf('=== 集成校准和模型完成 ===\n');
    
catch ME
    fprintf('集成校准和模型失败: %s\n', ME.message);
    fprintf('错误位置: %s (第%d行)\n', ME.stack(1).name, ME.stack(1).line);
    model = [];
    calibration_results = struct('error', ME.message);
end

end

function model = apply_calibrated_parameters(model, calibrated_params)
% 将校准参数应用到模型中

fprintf('  应用校准参数到模型...\n');

% 获取校准参数字段
param_fields = fieldnames(calibrated_params);

for i = 1:length(param_fields)
    param_name = param_fields{i};
    param_value = calibrated_params.(param_name);
    
    % 解析参数路径
    [section, field] = parse_parameter_path(param_name);
    
    % 应用参数到模型
    if ~isempty(section) && ~isempty(field)
        try
            if isfield(model.params, section)
                if isstruct(model.params.(section))
                    model.params.(section).(field) = param_value;
                else
                    model.params.(section) = param_value;
                end
                fprintf('    ✓ %s.%s = %.4f\n', section, field, param_value);
            else
                fprintf('    ⚠ 未找到参数段: %s\n', section);
            end
        catch ME
            fprintf('    ✗ 参数应用失败: %s.%s\n', section, field);
        end
    else
        fprintf('    ⚠ 无法解析参数路径: %s\n', param_name);
    end
end

% 更新模型配置
model.update_model_configuration();

end

function [section, field] = parse_parameter_path(param_name)
% 解析参数路径，返回段名和字段名

parts = strsplit(param_name, '_');
if length(parts) >= 2
    section = parts{1};
    field = strjoin(parts(2:end), '_');
else
    section = '';
    field = param_name;
end

end

function generate_integrated_report(model, calibration_results)
% 生成集成分析报告

fprintf('  生成集成分析报告...\n');

% 创建报告文件
report_file = sprintf('integrated_report_%s.txt', datestr(now, 'yyyymmdd_HHMMSS'));
fid = fopen(report_file, 'w');

fprintf(fid, '=== 集成校准和模型分析报告 ===\n');
fprintf(fid, '生成时间: %s\n\n', datestr(now));

% 模型基本信息
fprintf(fid, '模型基本信息:\n');
fprintf(fid, '  农户数量: %d\n', length(model.households));
fprintf(fid, '  企业数量: %d\n', length(model.enterprises));
fprintf(fid, '  仿真时长: %d 时间步\n', model.max_time);
fprintf(fid, '  空间网格: %dx%d\n', model.spatial_grid.size(1), model.spatial_grid.size(2));

% 校准结果信息
if ~isempty(fieldnames(calibration_results))
    fprintf(fid, '\n校准结果信息:\n');
    if isfield(calibration_results, 'method')
        fprintf(fid, '  校准方法: %s\n', calibration_results.method);
    end
    if isfield(calibration_results, 'objective_value')
        fprintf(fid, '  目标函数值: %.6f\n', calibration_results.objective_value);
    end
    if isfield(calibration_results, 'iterations')
        fprintf(fid, '  迭代次数: %d\n', calibration_results.iterations);
    end
end

% 仿真结果摘要
if ~isempty(model.results.time_series)
    final_state = model.results.time_series(end);
    fprintf(fid, '\n仿真结果摘要:\n');
    fprintf(fid, '  平均农户收入: %.2f\n', final_state.households.mean_income);
    fprintf(fid, '  外出务工比例: %.2f%%\n', final_state.households.off_farm_ratio * 100);
    fprintf(fid, '  粮食种植比例: %.2f%%\n', final_state.households.grain_planting_ratio * 100);
    fprintf(fid, '  收入韧性: %.3f\n', final_state.households.income_resilience);
    fprintf(fid, '  生产韧性: %.3f\n', final_state.households.production_resilience);
    fprintf(fid, '  营养健康: %.3f\n', final_state.households.nutrition_health);
end

% 政策效果分析
if ~isempty(model.results.time_series)
    fprintf(fid, '\n政策效果分析:\n');
    fprintf(fid, '  种粮补贴率: %.2f%%\n', final_state.government.grain_subsidy_rate * 100);
    fprintf(fid, '  耕地红线比例: %.2f%%\n', final_state.government.land_red_line_ratio * 100);
    fprintf(fid, '  总补贴成本: %.2f\n', final_state.government.total_subsidy_cost);
end

% 气候影响分析
if ~isempty(model.results.climate_data)
    fprintf(fid, '\n气候影响分析:\n');
    climate_times = [model.results.climate_data.time];
    climate_productivity = [model.results.climate_data.productivity];
    fprintf(fid, '  平均气候生产力: %.3f\n', mean(climate_productivity));
    fprintf(fid, '  气候生产力标准差: %.3f\n', std(climate_productivity));
    fprintf(fid, '  极端气候事件次数: %d\n', sum([model.results.climate_data.shock] > 0.3));
end

fprintf(fid, '\n=== 报告结束 ===\n');
fclose(fid);

fprintf('  报告已保存到: %s\n', report_file);

end 