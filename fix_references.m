function fix_references()
    % 批量修正所有文件中的类引用
    % 将类名替换为包名.类名的形式
    
    fprintf('开始修正类引用...\n');
    
    % 类名与包名映射
    class_map = containers.Map();
    
    % 核心类
    class_map('MultiAgentClimatePolicyModel') = 'core';
    class_map('AgentWithExpectations') = 'core';
    class_map('ExpectationFormationModule') = 'core';
    class_map('ModelValidationFramework') = 'core';
    
    % 智能体
    class_map('EnterpriseAgent') = 'agents';
    class_map('EnterpriseAgentWithExpectations') = 'agents';
    class_map('HouseholdAgent') = 'agents';
    class_map('PesticideEnterpriseAgent') = 'agents';
    class_map('FertilizerEnterpriseAgent') = 'agents';
    class_map('AgroProcessingEnterpriseAgent') = 'agents';
    class_map('GrainFarmAgent') = 'agents';
    class_map('CashCropFarmAgent') = 'agents';
    class_map('MixedCropFarmAgent') = 'agents';
    class_map('AgriculturalServiceEnterpriseAgent') = 'agents';
    class_map('FarmerAgentWithExpectations') = 'agents';
    class_map('GovernmentAgent') = 'agents';
    class_map('GovernmentAgentWithExpectations') = 'agents';
    class_map('AgriculturalEnterpriseWithExpectations') = 'agents';
    class_map('LaborDemanderAgent') = 'agents';
    class_map('LaborSupplierAgent') = 'agents';
    class_map('ChemicalEnterpriseAgent') = 'agents';
    
    % 功能模块
    class_map('CommodityMarketModule') = 'modules';
    class_map('LandMarketModule') = 'modules';
    class_map('InputMarketModule') = 'modules';
    class_map('PesticideMarketModule') = 'modules';
    class_map('FertilizerMarketModule') = 'modules';
    class_map('LaborMarketModule') = 'modules';
    class_map('EvolutionaryGameModule') = 'modules';
    class_map('EvolutionaryGameModuleAdvanced') = 'modules';
    class_map('EvolutionaryGameAnalysis') = 'modules';
    class_map('SimplifiedLaborMarket') = 'modules';
    
    % 需要处理的目录
    dirs_to_process = {'.', 'scripts', 'tests', 'docs'};
    
    for i = 1:length(dirs_to_process)
        dir_path = dirs_to_process{i};
        if exist(dir_path, 'dir')
            fprintf('处理目录: %s\n', dir_path);
            process_directory_references(dir_path, class_map);
        end
    end
    
    fprintf('类引用修正完成!\n');
end

function process_directory_references(dir_path, class_map)
    % 处理指定目录下的所有.m文件中的类引用
    
    % 获取所有.m文件
    files = dir(fullfile(dir_path, '*.m'));
    
    for i = 1:length(files)
        file_path = fullfile(dir_path, files(i).name);
        fix_file_references(file_path, class_map);
    end
    
    % 递归处理子目录（除了包目录）
    subdirs = dir(dir_path);
    for i = 1:length(subdirs)
        if subdirs(i).isdir && ~strcmp(subdirs(i).name, '.') && ~strcmp(subdirs(i).name, '..')
            subdir_name = subdirs(i).name;
            % 跳过包目录（以+开头的目录）
            if ~strcmp(subdir_name(1), '+')
                subdir_path = fullfile(dir_path, subdir_name);
                process_directory_references(subdir_path, class_map);
            end
        end
    end
end

function fix_file_references(file_path, class_map)
    % 修正单个文件中的类引用
    
    try
        % 读取文件内容
        fid = fopen(file_path, 'r');
        if fid == -1
            return;
        end
        
        content = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
        fclose(fid);
        lines = content{1};
        
        modified = false;
        
        % 遍历所有行
        for j = 1:length(lines)
            line = lines{j};
            original_line = line;
            
            % 对每个类名进行替换
            class_names = keys(class_map);
            for k = 1:length(class_names)
                class_name = class_names{k};
                package_name = class_map(class_name);
                
                % 替换模式：确保不会替换已经有包前缀的类名
                % 1. 替换 new ClassName( 为 new package.ClassName(
                pattern1 = sprintf('\\bnew\\s+%s\\s*\\(', class_name);
                replacement1 = sprintf('new %s.%s(', package_name, class_name);
                line = regexprep(line, pattern1, replacement1);
                
                % 2. 替换 ClassName( 为 package.ClassName( (函数调用)
                pattern2 = sprintf('\\b%s\\s*\\(', class_name);
                replacement2 = sprintf('%s.%s(', package_name, class_name);
                line = regexprep(line, pattern2, replacement2);
                
                % 3. 替换 @ClassName 为 @package.ClassName (函数句柄)
                pattern3 = sprintf('@%s\\b', class_name);
                replacement3 = sprintf('@%s.%s', package_name, class_name);
                line = regexprep(line, pattern3, replacement3);
                
                % 4. 替换 isa(obj, 'ClassName') 为 isa(obj, 'package.ClassName')
                pattern4 = sprintf('isa\\s*\\([^,]+,\\s*''%s''\\)', class_name);
                replacement4 = sprintf('isa($1, ''%s.%s'')', package_name, class_name);
                line = regexprep(line, pattern4, replacement4);
            end
            
            % 如果行被修改，更新lines数组
            if ~strcmp(line, original_line)
                lines{j} = line;
                modified = true;
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
                fprintf('  修正: %s\n', file_path);
            end
        end
        
    catch ME
        fprintf('  处理文件时出错 %s: %s\n', file_path, ME.message);
    end
end 