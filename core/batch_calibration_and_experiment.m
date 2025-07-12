%% 批量校准与政策实验主控脚本
clear; clc;
logfile = 'batch_log.txt';
fid = fopen(logfile, 'w');

base_dir = '校准用数据库';
data_files = get_all_data_files(base_dir);

for i = 1:length(data_files)
    data_file = data_files{i};
    [~, prefix, ~] = fileparts(data_file);
    prefix = [prefix '_'];
    try
        fprintf(fid, '=== 处理数据源: %s ===\n', data_file);
        fprintf('=== 处理数据源: %s ===\n', data_file);
        % 数据标准化
        [data_struct, meta] = universal_data_interface(data_file);
        save([prefix 'standardized_data.mat'], 'data_struct', 'meta');
        % 校准与实验
        input_data_file = data_file;
        output_prefix = prefix;
        quick_calibration;
        visualize_policy_results;
        fprintf(fid, '完成: %s\n', data_file);
    catch ME
        fprintf(fid, '错误: %s\n', data_file);
        fprintf(fid, '%s\n', ME.message);
        fprintf('错误: %s\n', data_file);
        fprintf('%s\n', ME.message);
    end
end
fclose(fid);

function files = get_all_data_files(base_dir)
% 递归获取所有dta/xlsx/csv数据文件
files = {};
listing = dir(base_dir);
for i = 1:length(listing)
    name = listing(i).name;
    if listing(i).isdir && ~strcmp(name, '.') && ~strcmp(name, '..')
        subfiles = get_all_data_files(fullfile(base_dir, name));
        files = [files, subfiles];
    elseif ~listing(i).isdir && (endsWith(name, '.dta') || endsWith(name, '.xlsx') || endsWith(name, '.csv'))
        files{end+1} = fullfile(base_dir, name);
    end
end
end 