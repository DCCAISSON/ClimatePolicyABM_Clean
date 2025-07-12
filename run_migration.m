function run_migration()
    % 主迁移脚本 - 按顺序执行所有迁移步骤
    % 运行此脚本前请确保在ClimatePolicyABM_Clean目录下
    
    fprintf('=== 开始项目结构迁移 ===\n');
    fprintf('当前工作目录: %s\n', pwd);
    
    % 步骤1: 检查目录结构
    fprintf('\n步骤1: 检查目录结构...\n');
    check_directory_structure();
    
    % 步骤2: 执行文件移动
    fprintf('\n步骤2: 执行文件移动...\n');
    fprintf('请运行PowerShell脚本: move_files.ps1\n');
    fprintf('或在PowerShell中执行:\n');
    fprintf('  .\\move_files.ps1\n');
    
    % 等待用户确认
    input('文件移动完成后，按回车键继续...', 's');
    
    % 步骤3: 修正classdef路径
    fprintf('\n步骤3: 修正classdef路径...\n');
    fix_classdef();
    
    % 步骤4: 修正类引用
    fprintf('\n步骤4: 修正类引用...\n');
    fix_references();
    
    % 步骤5: 创建.gitignore
    fprintf('\n步骤5: 创建.gitignore...\n');
    create_gitignore();
    
    % 步骤6: 验证迁移结果
    fprintf('\n步骤6: 验证迁移结果...\n');
    verify_migration();
    
    fprintf('\n=== 迁移完成! ===\n');
    fprintf('请检查以下事项:\n');
    fprintf('1. 所有文件已正确移动到包目录\n');
    fprintf('2. classdef路径已修正\n');
    fprintf('3. 类引用已更新\n');
    fprintf('4. 运行测试脚本验证功能正常\n');
end

function check_directory_structure()
    % 检查目录结构
    
    required_dirs = {'+core', '+agents', '+modules', '+analysis', '+utils', 'config', 'data', 'docs', 'tests', 'scripts'};
    
    for i = 1:length(required_dirs)
        if exist(required_dirs{i}, 'dir')
            fprintf('  ✓ %s 目录存在\n', required_dirs{i});
        else
            fprintf('  ✗ %s 目录不存在\n', required_dirs{i});
        end
    end
    
    % 检查core目录中的文件
    if exist('core', 'dir')
        core_files = dir('core/*.m');
        fprintf('  core目录中有 %d 个.m文件\n', length(core_files));
    end
end

function create_gitignore()
    % 创建.gitignore文件
    
    gitignore_content = {
        '# 忽略输出和中间结果'
        'data/output/'
        'results/'
        '*.asv'
        '*.mat'
        '*.fig'
        '*.log'
        '*.tmp'
        '*.bak'
        '*.DS_Store'
        '*.~*'
        ''
        '# MATLAB临时文件'
        '*.mex*'
        '*.p'
        ''
        '# 系统文件'
        'Thumbs.db'
        '.DS_Store'
        ''
        '# IDE文件'
        '.vscode/'
        '.idea/'
        ''
        '# 备份文件'
        '*_backup.m'
        '*_old.m'
    };
    
    fid = fopen('.gitignore', 'w');
    if fid ~= -1
        for i = 1:length(gitignore_content)
            fprintf(fid, '%s\n', gitignore_content{i});
        end
        fclose(fid);
        fprintf('  ✓ 已创建 .gitignore 文件\n');
    else
        fprintf('  ✗ 无法创建 .gitignore 文件\n');
    end
end

function verify_migration()
    % 验证迁移结果
    
    fprintf('验证包目录中的文件...\n');
    
    % 检查+core目录
    if exist('+core', 'dir')
        core_files = dir('+core/*.m');
        fprintf('  +core: %d 个文件\n', length(core_files));
        for i = 1:length(core_files)
            fprintf('    - %s\n', core_files(i).name);
        end
    end
    
    % 检查+agents目录
    if exist('+agents', 'dir')
        agent_files = dir('+agents/*.m');
        fprintf('  +agents: %d 个文件\n', length(agent_files));
        for i = 1:length(agent_files)
            fprintf('    - %s\n', agent_files(i).name);
        end
    end
    
    % 检查+modules目录
    if exist('+modules', 'dir')
        module_files = dir('+modules/*.m');
        fprintf('  +modules: %d 个文件\n', length(module_files));
        for i = 1:length(module_files)
            fprintf('    - %s\n', module_files(i).name);
        end
    end
    
    % 检查config目录
    if exist('config', 'dir')
        config_files = dir('config/*');
        fprintf('  config: %d 个文件\n', length(config_files));
        for i = 1:length(config_files)
            fprintf('    - %s\n', config_files(i).name);
        end
    end
    
    fprintf('\n验证完成!\n');
end 