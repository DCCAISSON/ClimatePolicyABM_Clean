% Version: 2.0-Simplified | Setup Git and GitHub
% 设置Git版本控制并同步到GitHub仓库
% 目标仓库: https://github.com/DCCAISSON

function setup_git_and_github()
    fprintf('=== Git版本控制和GitHub同步设置 ===\n');
    
    % 检查当前目录
    current_dir = pwd;
    fprintf('当前工作目录: %s\n', current_dir);
    
    % 检查是否在正确的项目目录
    if ~contains(current_dir, 'ClimatePolicyABM_Clean')
        error('请在ClimatePolicyABM_Clean目录中运行此脚本');
    end
    
    % 步骤1: 初始化Git仓库
    fprintf('\n步骤1: 初始化Git仓库...\n');
    try
        system('git init');
        fprintf('  ✓ Git仓库初始化完成\n');
    catch e
        fprintf('  ✗ Git初始化失败: %s\n', e.message);
        return;
    end
    
    % 步骤2: 配置Git用户信息
    fprintf('\n步骤2: 配置Git用户信息...\n');
    try
        % 设置用户名和邮箱（请根据实际情况修改）
        system('git config user.name "DCCAISSON"');
        system('git config user.email "your.email@example.com"');
        fprintf('  ✓ Git用户信息配置完成\n');
    catch e
        fprintf('  ✗ Git配置失败: %s\n', e.message);
    end
    
    % 步骤3: 添加所有文件到Git
    fprintf('\n步骤3: 添加文件到Git...\n');
    try
        system('git add .');
        fprintf('  ✓ 所有文件已添加到Git暂存区\n');
    catch e
        fprintf('  ✗ 添加文件失败: %s\n', e.message);
        return;
    end
    
    % 步骤4: 创建初始提交
    fprintf('\n步骤4: 创建初始提交...\n');
    try
        commit_message = 'Initial commit: Climate Policy ABM Model v2.0-Simplified';
        system(sprintf('git commit -m "%s"', commit_message));
        fprintf('  ✓ 初始提交完成\n');
    catch e
        fprintf('  ✗ 提交失败: %s\n', e.message);
        return;
    end
    
    % 步骤5: 添加GitHub远程仓库
    fprintf('\n步骤5: 配置GitHub远程仓库...\n');
    try
        % 添加远程仓库
        remote_url = 'https://github.com/DCCAISSON/ClimatePolicyABM_Clean.git';
        system(sprintf('git remote add origin %s', remote_url));
        fprintf('  ✓ 远程仓库配置完成: %s\n', remote_url);
    catch e
        fprintf('  ✗ 远程仓库配置失败: %s\n', e.message);
    end
    
    % 步骤6: 推送到GitHub
    fprintf('\n步骤6: 推送到GitHub...\n');
    fprintf('注意: 这需要您在GitHub上创建仓库并配置认证\n');
    fprintf('请按以下步骤操作:\n');
    fprintf('1. 访问 https://github.com/DCCAISSON\n');
    fprintf('2. 创建新仓库: ClimatePolicyABM_Clean\n');
    fprintf('3. 不要初始化README、.gitignore或license\n');
    fprintf('4. 配置GitHub认证（个人访问令牌或SSH密钥）\n');
    fprintf('5. 然后运行: git push -u origin main\n');
    
    % 显示Git状态
    fprintf('\n当前Git状态:\n');
    system('git status');
    
    fprintf('\n=== 设置完成 ===\n');
    fprintf('下一步操作:\n');
    fprintf('1. 在GitHub上创建仓库\n');
    fprintf('2. 配置认证\n');
    fprintf('3. 运行: git push -u origin main\n');
    fprintf('4. 验证文件已上传到GitHub\n');
end

% 辅助函数：检查GitHub仓库是否存在
function check_github_repo()
    fprintf('检查GitHub仓库状态...\n');
    try
        % 尝试获取远程仓库信息
        [status, result] = system('git ls-remote origin');
        if status == 0
            fprintf('  ✓ GitHub仓库连接正常\n');
        else
            fprintf('  ✗ 无法连接到GitHub仓库\n');
        end
    catch e
        fprintf('  ✗ 检查失败: %s\n', e.message);
    end
end

% 辅助函数：显示Git配置
function show_git_config()
    fprintf('当前Git配置:\n');
    system('git config --list');
end 