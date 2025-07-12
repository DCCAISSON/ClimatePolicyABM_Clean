%% 一键运行“多智能体气候政策”主模型（无合作社版本）
% 执行步骤：
%   1. 恢复 MATLAB 默认搜索路径，避免第三方函数重名冲突（如 contains.m ）
%   2. 将当前项目所有子目录加入搜索路径
%   3. 创建并运行 MultiAgentClimatePolicyModel
%   4. 绘制并保存结果
% 使用方法：在 MATLAB 当前文件夹切换到项目根目录后，直接运行此脚本即可。

% ------------------- 1. 清理并设置路径 -------------------
restoredefaultpath;             % 恢复 MATLAB 默认 Path，移除启动文件里残留路径
warning('off','MATLAB:dispatcher:nameConflict');      % 关闭同名函数冲突警告
warning('off','MATLAB:path:directoryNotFound');       % 关闭不存在目录警告
clear classes;                   % 清除已加载的类，避免旧定义缓存
rehash toolboxcache;             % 刷新工具箱缓存
project_root = fileparts(mfilename('fullpath'));
addpath(genpath(project_root));  % 加入项目全部子目录
savepath;                        % 可选：保存到下次启动

% ------------------- 2. 创建并运行模型 -------------------
fprintf('\n==== 启动多智能体气候政策模型 ====?\n');
model = MultiAgentClimatePolicyModel();   % 使用默认配置（无合作社）
model.run_simulation();                    % 执行 100 时间步仿真

% ------------------- 3. 可视化并保存输出 -------------------
model.plot_results();
fprintf('\n✓ 仿真及可视化完成，结果已保存到工作目录\n'); 