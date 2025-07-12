% Version: 2.0-Simplified | Quick Push Function
% 快速推送函数 - 日常使用的简化版本

function quick_push(description)
    % 快速推送代码到GitHub
    % 参数: description - 更改描述（可选）
    
    if nargin < 1
        description = 'Code update';
    end
    
    % 生成提交信息
    timestamp = datestr(now, 'yyyy-mm-dd HH:MM');
    commit_message = sprintf('%s - %s', description, timestamp);
    
    fprintf('🚀 快速推送: %s\n', commit_message);
    
    try
        % 检查是否有更改
        [~, result] = system('git status --porcelain');
        if isempty(result)
            fprintf('✓ 没有需要推送的更改\n');
            return;
        end
        
        % 执行推送
        system('git add .');
        system(sprintf('git commit -m "%s"', commit_message));
        system('git push origin master');
        
        fprintf('✓ 推送成功！\n');
        fprintf('📁 仓库: https://github.com/DCCAISSON/ClimatePolicyABM_Clean\n');
        
    catch ME
        fprintf('✗ 推送失败: %s\n', ME.message);
    end
end 