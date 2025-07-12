function fix_classdef()
    % 批量修正classdef路径和添加版本注释
    % 运行此脚本前请确保文件已移动到对应的包目录
    
    fprintf('开始修正classdef路径...\n');
    
    % 包名与文件夹映射
    package_map = containers.Map();
    package_map('+core') = 'core';
    package_map('+agents') = 'agents';
    package_map('+modules') = 'modules';
    package_map('+analysis') = 'analysis';
    package_map('+utils') = 'utils';
    
    % 遍历所有包目录
    package_dirs = {'+core', '+agents', '+modules', '+analysis', '+utils'};
    
    for i = 1:length(package_dirs)
        pkg_dir = package_dirs{i};
        if exist(pkg_dir, 'dir')
            fprintf('处理目录: %s\n', pkg_dir);
            fix_package_classdef(pkg_dir, package_map(pkg_dir));
        end
    end
    
    fprintf('classdef路径修正完成!\n');
end

function fix_package_classdef(pkg_dir, package_name)
    % 修正指定包目录下的所有.m文件的classdef
    
    files = dir(fullfile(pkg_dir, '*.m'));
    
    for i = 1:length(files)
        file_path = fullfile(pkg_dir, files(i).name);
        fix_single_file_classdef(file_path, package_name);
    end
end

function fix_single_file_classdef(file_path, package_name)
    % 修正单个文件的classdef
    
    try
        % 读取文件内容
        fid = fopen(file_path, 'r');
        if fid == -1
            fprintf('  无法打开文件: %s\n', file_path);
            return;
        end
        
        content = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
        fclose(fid);
        lines = content{1};
        
        % 查找并修正classdef行
        modified = false;
        for j = 1:length(lines)
            line = lines{j};
            
            % 匹配classdef行
            classdef_pattern = '^\s*classdef\s+(\w+)\s*(<\s*([\w\.]+))?';
            tokens = regexp(line, classdef_pattern, 'tokens');
            
            if ~isempty(tokens)
                class_name = tokens{1}{1};
                base_class = '';
                if length(tokens{1}) > 2 && ~isempty(tokens{1}{3})
                    base_class = tokens{1}{3};
                end
                
                % 构建新的classdef行
                new_line = sprintf('%% Version: 2.0-Simplified | Package: %s\n', package_name);
                new_line = [new_line, sprintf('classdef %s.%s', package_name, class_name)];
                
                if ~isempty(base_class)
                    % 检查基类是否已有包前缀
                    if contains(base_class, '.')
                        new_line = [new_line, sprintf(' < %s', base_class)];
                    else
                        % 为基类添加包前缀（如果不是handle等内置类）
                        if ~ismember(base_class, {'handle', 'matlab.mixin.Copyable'})
                            new_line = [new_line, sprintf(' < %s.%s', package_name, base_class)];
                        else
                            new_line = [new_line, sprintf(' < %s', base_class)];
                        end
                    end
                end
                
                lines{j} = new_line;
                modified = true;
                fprintf('  修正: %s -> %s.%s\n', class_name, package_name, class_name);
                break;
            end
        end
        
        % 如果文件被修改，写回文件
        if modified
            fid = fopen(file_path, 'w');
            if fid ~= -1
                for j = 1:length(lines)
                    fprintf(fid, '%s\n', lines{j});
                end
                fclose(fid);
            end
        end
        
    catch ME
        fprintf('  处理文件时出错 %s: %s\n', file_path, ME.message);
    end
end 