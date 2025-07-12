% Version: 2.0-Simplified | Auto Sync and Push to GitHub
% 自动同步文档并推送到GitHub
% 集成文档同步和GitHub推送功能

function auto_sync_and_push(commit_message)
    fprintf('=== 自动同步文档并推送到GitHub ===\n');
    
    if nargin < 1
        commit_message = 'Auto sync documentation with current code structure';
    end
    
    try
        % 1. 同步文档
        fprintf('1. 同步文档与代码结构...\n');
        sync_documentation();
        
        % 2. 检查Git状态
        fprintf('2. 检查Git状态...\n');
        git_status = check_git_status();
        
        if git_status.has_changes
            % 3. 添加所有更改
            fprintf('3. 添加更改到Git...\n');
            add_changes_to_git();
            
            % 4. 提交更改
            fprintf('4. 提交更改...\n');
            commit_changes(commit_message);
            
            % 5. 推送到GitHub
            fprintf('5. 推送到GitHub...\n');
            push_to_github();
            
            fprintf('✅ 自动同步和推送完成\n');
            fprintf('📝 提交信息: %s\n', commit_message);
            fprintf('🔗 查看更新: https://github.com/DCCAISSON/ClimatePolicyABM_Clean\n');
        else
            fprintf('ℹ️ 没有检测到更改，跳过推送\n');
        end
        
    catch ME
        fprintf('❌ 自动同步失败: %s\n', ME.message);
        fprintf('🔧 请检查错误并手动处理\n');
    end
end

function git_status = check_git_status()
    % 检查Git状态
    
    git_status = struct();
    git_status.has_changes = false;
    git_status.untracked_files = {};
    git_status.modified_files = {};
    
    try
        % 检查是否有未跟踪的文件
        [status, result] = system('git status --porcelain');
        
        if status == 0
            lines = strsplit(result, '\n');
            lines = lines(~cellfun(@isempty, lines));
            
            if ~isempty(lines)
                git_status.has_changes = true;
                
                for i = 1:length(lines)
                    line = lines{i};
                    if startsWith(line, '??')
                        % 未跟踪的文件
                        file_path = strtrim(line(3:end));
                        git_status.untracked_files{end+1} = file_path;
                    elseif startsWith(line, ' M') || startsWith(line, 'M ')
                        % 修改的文件
                        file_path = strtrim(line(3:end));
                        git_status.modified_files{end+1} = file_path;
                    end
                end
                
                fprintf('  发现 %d 个未跟踪文件\n', length(git_status.untracked_files));
                fprintf('  发现 %d 个修改文件\n', length(git_status.modified_files));
            else
                fprintf('  没有检测到更改\n');
            end
        else
            fprintf('  警告: 无法检查Git状态\n');
        end
        
    catch ME
        fprintf('  错误检查Git状态: %s\n', ME.message);
    end
end

function add_changes_to_git()
    % 添加所有更改到Git
    
    try
        [status, result] = system('git add .');
        
        if status == 0
            fprintf('  ✅ 成功添加所有更改\n');
        else
            fprintf('  ❌ 添加更改失败: %s\n', result);
            error('Git add failed');
        end
        
    catch ME
        fprintf('  错误添加更改: %s\n', ME.message);
        error('Failed to add changes');
    end
end

function commit_changes(commit_message)
    % 提交更改
    
    try
        % 转义提交信息中的特殊字符
        escaped_message = strrep(commit_message, '"', '\"');
        command = sprintf('git commit -m "%s"', escaped_message);
        
        [status, result] = system(command);
        
        if status == 0
            fprintf('  ✅ 成功提交更改\n');
            fprintf('  📝 提交信息: %s\n', commit_message);
        else
            fprintf('  ❌ 提交失败: %s\n', result);
            error('Git commit failed');
        end
        
    catch ME
        fprintf('  错误提交更改: %s\n', ME.message);
        error('Failed to commit changes');
    end
end

function push_to_github()
    % 推送到GitHub
    
    try
        % 获取当前分支
        [status, branch_result] = system('git branch --show-current');
        
        if status == 0
            current_branch = strtrim(branch_result);
            fprintf('  📍 当前分支: %s\n', current_branch);
            
            % 推送到远程仓库
            push_command = sprintf('git push origin %s', current_branch);
            [status, result] = system(push_command);
            
            if status == 0
                fprintf('  ✅ 成功推送到GitHub\n');
                fprintf('  🔗 仓库地址: https://github.com/DCCAISSON/ClimatePolicyABM_Clean\n');
            else
                fprintf('  ❌ 推送失败: %s\n', result);
                error('Git push failed');
            end
        else
            fprintf('  ❌ 无法获取当前分支\n');
            error('Cannot get current branch');
        end
        
    catch ME
        fprintf('  错误推送到GitHub: %s\n', ME.message);
        error('Failed to push to GitHub');
    end
end

function quick_sync_and_push()
    % 快速同步和推送（使用默认提交信息）
    
    timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    commit_message = sprintf('Auto sync documentation - %s', timestamp);
    
    auto_sync_and_push(commit_message);
end

function sync_with_custom_message()
    % 使用自定义消息同步和推送
    
    prompt = '请输入提交信息 (或按回车使用默认信息): ';
    custom_message = input(prompt, 's');
    
    if isempty(custom_message)
        timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
        custom_message = sprintf('Auto sync documentation - %s', timestamp);
    end
    
    auto_sync_and_push(custom_message);
end

function check_sync_status()
    % 检查同步状态
    
    fprintf('=== 检查同步状态 ===\n');
    
    % 检查文档同步状态
    fprintf('1. 检查文档同步状态...\n');
    if exist('docs/SYNC_REPORT.md', 'file')
        fprintf('  ✅ 同步报告存在\n');
        
        % 读取同步报告
        try
            fid = fopen('docs/SYNC_REPORT.md', 'r');
            if fid ~= -1
                content = textscan(fid, '%s', 'Delimiter', '\n');
                fclose(fid);
                content = content{1};
                
                % 查找生成时间
                for i = 1:length(content)
                    if contains(content{i}, '生成时间')
                        fprintf('  📅 %s\n', content{i});
                        break;
                    end
                end
            end
        catch ME
            fprintf('  ⚠️ 无法读取同步报告: %s\n', ME.message);
        end
    else
        fprintf('  ❌ 同步报告不存在\n');
    end
    
    % 检查Git状态
    fprintf('2. 检查Git状态...\n');
    git_status = check_git_status();
    
    if git_status.has_changes
        fprintf('  ⚠️ 检测到未提交的更改\n');
        fprintf('  💡 建议运行 auto_sync_and_push() 进行同步\n');
    else
        fprintf('  ✅ 没有未提交的更改\n');
    end
    
    % 检查远程仓库状态
    fprintf('3. 检查远程仓库状态...\n');
    try
        [status, result] = system('git remote -v');
        if status == 0
            fprintf('  ✅ 远程仓库配置正常\n');
            fprintf('  📍 %s\n', result);
        else
            fprintf('  ❌ 远程仓库配置异常\n');
        end
    catch ME
        fprintf('  ❌ 无法检查远程仓库: %s\n', ME.message);
    end
    
    fprintf('=== 同步状态检查完成 ===\n');
end 