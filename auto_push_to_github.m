% Version: 2.0-Simplified | Auto Push to GitHub
% 自动化推送代码到GitHub仓库
% 每次代码修改后运行此脚本即可自动同步

function auto_push_to_github(commit_message)
    % 自动化推送代码到GitHub
    % 参数: commit_message - 提交信息（可选）
    
    if nargin < 1
        % 生成默认提交信息
        timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
        commit_message = sprintf('Auto update: %s', timestamp);
    end
    
    fprintf('=== 自动化GitHub推送 ===\n');
    fprintf('提交信息: %s\n', commit_message);
    
    % 检查当前目录
    current_dir = pwd;
    if ~contains(current_dir, 'ClimatePolicyABM_Clean')
        error('请在ClimatePolicyABM_Clean目录中运行此脚本');
    end
    
    try
        % 步骤1: 检查Git状态
        fprintf('\n步骤1: 检查Git状态...\n');
        [status, result] = system('git status --porcelain');
        
        if isempty(result)
            fprintf('  ✓ 没有需要提交的更改\n');
            return;
        end
        
        % 显示更改的文件
        changed_files = strsplit(result, '\n');
        changed_files = changed_files(~cellfun(@isempty, changed_files));
        fprintf('  发现 %d 个文件有更改:\n', length(changed_files));
        for i = 1:min(5, length(changed_files))
            fprintf('    %s\n', changed_files{i});
        end
        if length(changed_files) > 5
            fprintf('    ... 还有 %d 个文件\n', length(changed_files) - 5);
        end
        
        % 步骤2: 添加所有更改
        fprintf('\n步骤2: 添加更改到暂存区...\n');
        [status, result] = system('git add .');
        if status == 0
            fprintf('  ✓ 所有更改已添加到暂存区\n');
        else
            error('添加文件失败: %s', result);
        end
        
        % 步骤3: 提交更改
        fprintf('\n步骤3: 提交更改...\n');
        commit_cmd = sprintf('git commit -m "%s"', commit_message);
        [status, result] = system(commit_cmd);
        if status == 0
            fprintf('  ✓ 更改已提交\n');
        else
            error('提交失败: %s', result);
        end
        
        % 步骤4: 推送到GitHub
        fprintf('\n步骤4: 推送到GitHub...\n');
        [status, result] = system('git push origin master');
        if status == 0
            fprintf('  ✓ 成功推送到GitHub\n');
            fprintf('  仓库地址: https://github.com/DCCAISSON/ClimatePolicyABM_Clean\n');
        else
            error('推送失败: %s', result);
        end
        
        % 步骤5: 显示最新状态
        fprintf('\n步骤5: 显示最新状态...\n');
        system('git log --oneline -3');
        
        fprintf('\n=== 自动化推送完成 ===\n');
        fprintf('所有更改已成功同步到GitHub！\n');
        
    catch ME
        fprintf('\n✗ 自动化推送失败: %s\n', ME.message);
        fprintf('请检查:\n');
        fprintf('1. 网络连接是否正常\n');
        fprintf('2. GitHub令牌是否有效\n');
        fprintf('3. 远程仓库是否正确配置\n');
        
        % 显示详细错误信息
        fprintf('\n详细错误信息:\n');
        fprintf('%s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('错误位置: %s (第%d行)\n', ME.stack(1).name, ME.stack(1).line);
        end
    end
end

% 辅助函数：检查GitHub连接
function check_github_connection()
    fprintf('检查GitHub连接...\n');
    [status, result] = system('git ls-remote origin');
    if status == 0
        fprintf('  ✓ GitHub连接正常\n');
    else
        fprintf('  ✗ GitHub连接失败\n');
    end
end

% 辅助函数：显示Git配置
function show_git_info()
    fprintf('Git配置信息:\n');
    system('git remote -v');
    system('git branch -v');
end 