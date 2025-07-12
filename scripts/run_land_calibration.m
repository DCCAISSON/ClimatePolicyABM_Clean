% RUN_LAND_CALIBRATION  Quick driver script to estimate land-transfer module parameters
%
% Example usage (from MATLAB command window):
%   >> run_land_calibration
%
% The script assumes that the *calibration database* lives in
%   ../我们的完善路径/校准用数据库
% relative to this script location. Adjust `db_path` below if your
% directory structure differs.

current_file = mfilename('fullpath');
[script_dir, ~, ~] = fileparts(current_file);
% Build path to calibration DB (two folders up then 校准用数据库)
proj_root  = fileparts(fileparts(script_dir));
db_path    = fullfile(proj_root, '我们的完善路径', '校准用数据库');

if ~exist(db_path, 'dir')
    error('Calibration database folder not found: %s', db_path);
end

fprintf('[run_land_calibration] Using database at: %s\n', db_path);

[land_params, summary] = calibrate_land_transfer_params(db_path);

% Save to results folder for easy import into main config
results_dir = fullfile(proj_root, 'results');
if ~exist(results_dir, 'dir'), mkdir(results_dir); end
save(fullfile(results_dir, 'land_params_calibrated.mat'), 'land_params', 'summary');

fprintf('[run_land_calibration] Parameters saved to %s\n', fullfile(results_dir, 'land_params_calibrated.mat')); 