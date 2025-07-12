% Version: 2.0-Simplified | Cleanup Redundant Files
% 清理冗余文件脚本
% 删除迁移完成后的冗余文件和旧版本文件

function cleanup_redundant_files()
    fprintf('=== 清理冗余文件 ===\n');
    
    % 要删除的文件列表
    files_to_delete = {
        % 旧版本核心文件
        'core/agri_abm.m',
        'core/agri_abm_enhanced.m', 
        'core/agri_abm_extended.m',
        'core/run_enhanced_abm.m',
        'core/run_extended_agri_abm.m',
        'core/MAIN_RUN_SCRIPT.m',
        
        % 空文件
        '+agents/ChemicalEnterpriseAgent.m',
        
        % 迁移工具（已完成）
        'run_migration.m',
        'fix_classdef.m', 
        'fix_references.m',
        'move_files.ps1',
        
        % Git设置文件（已完成）
        'setup_git.ps1',
        'setup_git_and_github.m',
        'push_to_github.bat',
        
        % 重复的文档
        'GITHUB_TOKEN_SETUP.md',
        'PUSH_TO_GITHUB.md'
    };
    
    % 删除文件
    deleted_count = 0;
    for i = 1:length(files_to_delete)
        file_path = files_to_delete{i};
        if exist(file_path, 'file')
            try
                delete(file_path);
                fprintf('✓ 删除: %s\n', file_path);
                deleted_count = deleted_count + 1;
            catch ME
                fprintf('✗ 删除失败: %s - %s\n', file_path, ME.message);
            end
        else
            fprintf('- 文件不存在: %s\n', file_path);
        end
    end
    
    fprintf('\n=== 清理完成 ===\n');
    fprintf('共删除 %d 个冗余文件\n', deleted_count);
    
    % 显示当前目录结构
    fprintf('\n当前目录结构:\n');
    list_current_structure();
end

function list_current_structure()
    % 显示主要目录结构
    dirs = {'+agents', '+core', '+modules', '+utils', '+analysis', ...
            'core', 'config', 'data', 'docs', 'tests', 'scripts', 'results'};
    
    for i = 1:length(dirs)
        if exist(dirs{i}, 'dir')
            files = dir(dirs{i});
            fprintf('  %s/ (%d个文件)\n', dirs{i}, length(files)-2); % 减去.和..
        end
    end
end 