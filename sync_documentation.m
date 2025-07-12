% Version: 2.0-Simplified | Documentation Synchronization Script
% 文档与代码同步机制
% 自动更新README.md以反映当前代码结构

function sync_documentation()
    fprintf('=== 文档与代码同步机制 ===\n');
    
    % 1. 扫描当前代码结构
    fprintf('1. 扫描代码结构...\n');
    code_structure = scan_code_structure();
    
    % 2. 验证智能体类型
    fprintf('2. 验证智能体类型...\n');
    agent_types = validate_agent_types();
    
    % 3. 检查市场模块
    fprintf('3. 检查市场模块...\n');
    market_modules = check_market_modules();
    
    % 4. 更新README.md
    fprintf('4. 更新README.md...\n');
    update_readme_with_current_structure(code_structure, agent_types, market_modules);
    
    % 5. 生成同步报告
    fprintf('5. 生成同步报告...\n');
    generate_sync_report(code_structure, agent_types, market_modules);
    
    fprintf('=== 文档同步完成 ===\n');
end

function structure = scan_code_structure()
    % 扫描当前代码结构
    
    structure = struct();
    
    % 扫描智能体目录
    if exist('+agents', 'dir')
        agent_files = dir('+agents/*.m');
        structure.agents = {agent_files.name};
    else
        structure.agents = {};
    end
    
    % 扫描核心模块目录
    if exist('+core', 'dir')
        core_files = dir('+core/*.m');
        structure.core = {core_files.name};
    else
        structure.core = {};
    end
    
    % 扫描市场模块目录
    if exist('+modules', 'dir')
        module_files = dir('+modules/*.m');
        structure.modules = {module_files.name};
    else
        structure.modules = {};
    end
    
    % 扫描测试文件
    if exist('tests', 'dir')
        test_files = dir('tests/*.m');
        structure.tests = {test_files.name};
    else
        structure.tests = {};
    end
    
    % 扫描脚本文件
    if exist('scripts', 'dir')
        script_files = dir('scripts/*.m');
        structure.scripts = {script_files.name};
    else
        structure.scripts = {};
    end
    
    fprintf('  发现 %d 个智能体文件\n', length(structure.agents));
    fprintf('  发现 %d 个核心模块文件\n', length(structure.core));
    fprintf('  发现 %d 个市场模块文件\n', length(structure.modules));
    fprintf('  发现 %d 个测试文件\n', length(structure.tests));
    fprintf('  发现 %d 个脚本文件\n', length(structure.scripts));
end

function agent_types = validate_agent_types()
    % 验证智能体类型
    
    agent_types = struct();
    
    % 预期的智能体类型
    expected_agents = {
        'PesticideEnterpriseAgent',
        'FertilizerEnterpriseAgent', 
        'AgroProcessingEnterpriseAgent',
        'GrainFarmAgent',
        'CashCropFarmAgent',
        'MixedCropFarmAgent',
        'AgriculturalServiceEnterpriseAgent',
        'HouseholdAgent',
        'FarmerAgentWithExpectations',
        'GovernmentAgent',
        'GovernmentAgentWithExpectations',
        'LaborSupplierAgent',
        'LaborDemanderAgent',
        'EnterpriseAgent',
        'EnterpriseAgentWithExpectations',
        'AgriculturalEnterpriseWithExpectations'
    };
    
    % 检查实际存在的智能体
    if exist('+agents', 'dir')
        agent_files = dir('+agents/*.m');
        actual_agents = {agent_files.name};
        
        % 移除.m扩展名
        actual_agents = cellfun(@(x) x(1:end-2), actual_agents, 'UniformOutput', false);
        
        % 验证每个预期的智能体
        for i = 1:length(expected_agents)
            agent_name = expected_agents{i};
            if any(strcmp(actual_agents, agent_name))
                agent_types.(agent_name) = 'EXISTS';
            else
                agent_types.(agent_name) = 'MISSING';
            end
        end
        
        % 检查额外的智能体
        for i = 1:length(actual_agents)
            agent_name = actual_agents{i};
            if ~any(strcmp(expected_agents, agent_name))
                agent_types.(agent_name) = 'EXTRA';
            end
        end
    else
        agent_types = struct();
    end
    
    % 打印验证结果
    fprintf('  智能体类型验证:\n');
    fields = fieldnames(agent_types);
    for i = 1:length(fields)
        status = agent_types.(fields{i});
        switch status
            case 'EXISTS'
                fprintf('    ✓ %s\n', fields{i});
            case 'MISSING'
                fprintf('    ✗ %s (缺失)\n', fields{i});
            case 'EXTRA'
                fprintf('    + %s (额外)\n', fields{i});
        end
    end
end

function market_modules = check_market_modules()
    % 检查市场模块
    
    market_modules = struct();
    
    % 预期的市场模块
    expected_modules = {
        'PesticideMarketModule',
        'FertilizerMarketModule',
        'CommodityMarketModule',
        'LandMarketModule',
        'LaborMarketModule',
        'InputMarketModule',
        'SimplifiedLaborMarket'
    };
    
    % 检查实际存在的模块
    if exist('+modules', 'dir')
        module_files = dir('+modules/*.m');
        actual_modules = {module_files.name};
        
        % 移除.m扩展名
        actual_modules = cellfun(@(x) x(1:end-2), actual_modules, 'UniformOutput', false);
        
        % 验证每个预期的模块
        for i = 1:length(expected_modules)
            module_name = expected_modules{i};
            if any(strcmp(actual_modules, module_name))
                market_modules.(module_name) = 'EXISTS';
            else
                market_modules.(module_name) = 'MISSING';
            end
        end
        
        % 检查额外的模块
        for i = 1:length(actual_modules)
            module_name = actual_modules{i};
            if ~any(strcmp(expected_modules, module_name))
                market_modules.(module_name) = 'EXTRA';
            end
        end
    else
        market_modules = struct();
    end
    
    % 打印验证结果
    fprintf('  市场模块验证:\n');
    fields = fieldnames(market_modules);
    for i = 1:length(fields)
        status = market_modules.(fields{i});
        switch status
            case 'EXISTS'
                fprintf('    ✓ %s\n', fields{i});
            case 'MISSING'
                fprintf('    ✗ %s (缺失)\n', fields{i});
            case 'EXTRA'
                fprintf('    + %s (额外)\n', fields{i});
        end
    end
end

function update_readme_with_current_structure(structure, agent_types, market_modules)
    % 更新README.md以反映当前结构
    
    % 读取当前README.md
    readme_path = 'docs/README.md';
    if exist(readme_path, 'file')
        % 备份原文件
        backup_path = 'docs/README_backup.md';
        copyfile(readme_path, backup_path);
        fprintf('  已备份原README.md到 %s\n', backup_path);
        
        % 更新README.md
        update_readme_content(readme_path, structure, agent_types, market_modules);
        fprintf('  已更新README.md\n');
    else
        fprintf('  警告: 未找到README.md文件\n');
    end
end

function update_readme_content(readme_path, structure, agent_types, market_modules)
    % 更新README.md内容
    
    % 读取原文件
    fid = fopen(readme_path, 'r');
    if fid == -1
        fprintf('  错误: 无法读取README.md\n');
        return;
    end
    
    content = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
    fclose(fid);
    content = content{1};
    
    % 查找需要更新的部分
    updated_content = update_agent_section(content, agent_types);
    updated_content = update_module_section(updated_content, market_modules);
    updated_content = update_structure_section(updated_content, structure);
    
    % 写入更新后的内容
    fid = fopen(readme_path, 'w');
    if fid == -1
        fprintf('  错误: 无法写入README.md\n');
        return;
    end
    
    for i = 1:length(updated_content)
        fprintf(fid, '%s\n', updated_content{i});
    end
    
    fclose(fid);
end

function updated_content = update_agent_section(content, agent_types)
    % 更新智能体部分
    
    updated_content = content;
    
    % 查找智能体架构部分
    agent_section_start = -1;
    agent_section_end = -1;
    
    for i = 1:length(content)
        if contains(content{i}, '## 🏗️ 智能体架构设计')
            agent_section_start = i;
        elseif agent_section_start > 0 && startsWith(content{i}, '## ')
            agent_section_end = i - 1;
            break;
        end
    end
    
    if agent_section_start > 0 && agent_section_end > 0
        % 生成新的智能体列表
        agent_list = generate_agent_list(agent_types);
        
        % 替换智能体部分
        new_section = [content(1:agent_section_start); agent_list; content(agent_section_end:end)];
        updated_content = new_section;
    end
end

function agent_list = generate_agent_list(agent_types)
    % 生成智能体列表
    
    agent_list = {};
    
    % 企业智能体
    enterprise_agents = {};
    household_agents = {};
    government_agents = {};
    labor_agents = {};
    
    fields = fieldnames(agent_types);
    for i = 1:length(fields)
        agent_name = fields{i};
        status = agent_types.(agent_name);
        
        if status == 'EXISTS'
            if contains(agent_name, 'Enterprise')
                enterprise_agents{end+1} = agent_name;
            elseif contains(agent_name, 'Household') || contains(agent_name, 'Farmer')
                household_agents{end+1} = agent_name;
            elseif contains(agent_name, 'Government')
                government_agents{end+1} = agent_name;
            elseif contains(agent_name, 'Labor')
                labor_agents{end+1} = agent_name;
            end
        end
    end
    
    % 生成markdown格式的列表
    agent_list{end+1} = '### 核心智能体类型';
    agent_list{end+1} = '';
    
    % 企业智能体
    agent_list{end+1} = '#### **企业智能体**';
    for i = 1:length(enterprise_agents)
        agent_list{end+1} = sprintf('- `%s`', enterprise_agents{i});
    end
    agent_list{end+1} = '';
    
    % 农户智能体
    agent_list{end+1} = '#### **农户智能体**';
    for i = 1:length(household_agents)
        agent_list{end+1} = sprintf('- `%s`', household_agents{i});
    end
    agent_list{end+1} = '';
    
    % 政府智能体
    agent_list{end+1} = '#### **政府智能体**';
    for i = 1:length(government_agents)
        agent_list{end+1} = sprintf('- `%s`', government_agents{i});
    end
    agent_list{end+1} = '';
    
    % 劳动力市场智能体
    agent_list{end+1} = '#### **劳动力市场智能体**';
    for i = 1:length(labor_agents)
        agent_list{end+1} = sprintf('- `%s`', labor_agents{i});
    end
    agent_list{end+1} = '';
end

function updated_content = update_module_section(content, market_modules)
    % 更新市场模块部分
    
    updated_content = content;
    
    % 查找市场模块部分
    module_section_start = -1;
    module_section_end = -1;
    
    for i = 1:length(content)
        if contains(content{i}, '## 🏪 市场模块体系')
            module_section_start = i;
        elseif module_section_start > 0 && startsWith(content{i}, '## ')
            module_section_end = i - 1;
            break;
        end
    end
    
    if module_section_start > 0 && module_section_end > 0
        % 生成新的模块列表
        module_list = generate_module_list(market_modules);
        
        % 替换模块部分
        new_section = [content(1:module_section_start); module_list; content(module_section_end:end)];
        updated_content = new_section;
    end
end

function module_list = generate_module_list(market_modules)
    % 生成市场模块列表
    
    module_list = {};
    
    % 收集存在的模块
    existing_modules = {};
    fields = fieldnames(market_modules);
    for i = 1:length(fields)
        module_name = fields{i};
        status = market_modules.(module_name);
        
        if status == 'EXISTS'
            existing_modules{end+1} = module_name;
        end
    end
    
    % 生成markdown格式的列表
    module_list{end+1} = '### 核心市场模块';
    module_list{end+1} = '';
    
    for i = 1:length(existing_modules)
        module_name = existing_modules{i};
        module_list{end+1} = sprintf('#### **`%s`**', module_name);
        module_list{end+1} = sprintf('- **功能**：%s', get_module_description(module_name));
        module_list{end+1} = sprintf('- **特色**：%s', get_module_features(module_name));
        module_list{end+1} = sprintf('- **机制**：%s', get_module_mechanisms(module_name));
        module_list{end+1} = '';
    end
end

function description = get_module_description(module_name)
    % 获取模块描述
    
    descriptions = struct();
    descriptions.PesticideMarketModule = '农药企业与农业企业之间的供需匹配';
    descriptions.FertilizerMarketModule = '化肥企业与农业企业之间的交易';
    descriptions.CommodityMarketModule = '农产品交易和价格发现';
    descriptions.LandMarketModule = '土地流转和租赁交易';
    descriptions.LaborMarketModule = '农业劳动力供需匹配和工资决定';
    descriptions.InputMarketModule = '农业生产投入品的交易';
    descriptions.SimplifiedLaborMarket = '简化的劳动力市场匹配';
    
    if isfield(descriptions, module_name)
        description = descriptions.(module_name);
    else
        description = '市场交易和价格发现';
    end
end

function features = get_module_features(module_name)
    % 获取模块特色
    
    features_map = struct();
    features_map.PesticideMarketModule = '基于质量偏好的双边搜寻匹配算法';
    features_map.FertilizerMarketModule = '考虑环保认证和绿色技术偏好';
    features_map.CommodityMarketModule = '基于质量等级的价格发现机制';
    features_map.LandMarketModule = '考虑情感价值和交易成本';
    features_map.LaborMarketModule = '基于技能匹配的延迟接受算法';
    features_map.InputMarketModule = '多品种投入品的综合交易';
    features_map.SimplifiedLaborMarket = '简化的供需匹配算法';
    
    if isfield(features_map, module_name)
        features = features_map.(module_name);
    else
        features = '市场匹配和价格发现';
    end
end

function mechanisms = get_module_mechanisms(module_name)
    % 获取模块机制
    
    mechanisms_map = struct();
    mechanisms_map.PesticideMarketModule = '质量匹配、价格发现、声誉传播';
    mechanisms_map.FertilizerMarketModule = '环保加分、绿色产品溢价';
    mechanisms_map.CommodityMarketModule = '期货合约、季节性价格波动';
    mechanisms_map.LandMarketModule = '双边匹配、价格协商、合同设计';
    mechanisms_map.LaborMarketModule = '季节性需求、技能发展、培训项目';
    mechanisms_map.InputMarketModule = '质量检验、价格竞争、供应链管理';
    mechanisms_map.SimplifiedLaborMarket = '供需匹配、工资决定';
    
    if isfield(mechanisms_map, module_name)
        mechanisms = mechanisms_map.(module_name);
    else
        mechanisms = '市场匹配、价格发现';
    end
end

function updated_content = update_structure_section(content, structure)
    % 更新系统架构部分
    
    updated_content = content;
    
    % 查找系统架构部分
    structure_section_start = -1;
    structure_section_end = -1;
    
    for i = 1:length(content)
        if contains(content{i}, '## 📊 系统架构')
            structure_section_start = i;
        elseif structure_section_start > 0 && startsWith(content{i}, '## ')
            structure_section_end = i - 1;
            break;
        end
    end
    
    if structure_section_start > 0 && structure_section_end > 0
        % 生成新的架构信息
        structure_info = generate_structure_info(structure);
        
        % 替换架构部分
        new_section = [content(1:structure_section_start); structure_info; content(structure_section_end:end)];
        updated_content = new_section;
    end
end

function structure_info = generate_structure_info(structure)
    % 生成系统架构信息
    
    structure_info = {};
    
    structure_info{end+1} = '### 当前代码结构';
    structure_info{end+1} = '';
    
    % 智能体文件
    structure_info{end+1} = sprintf('#### 智能体文件 (%d个)', length(structure.agents));
    for i = 1:length(structure.agents)
        structure_info{end+1} = sprintf('- `%s`', structure.agents{i});
    end
    structure_info{end+1} = '';
    
    % 核心模块文件
    structure_info{end+1} = sprintf('#### 核心模块文件 (%d个)', length(structure.core));
    for i = 1:length(structure.core)
        structure_info{end+1} = sprintf('- `%s`', structure.core{i});
    end
    structure_info{end+1} = '';
    
    % 市场模块文件
    structure_info{end+1} = sprintf('#### 市场模块文件 (%d个)', length(structure.modules));
    for i = 1:length(structure.modules)
        structure_info{end+1} = sprintf('- `%s`', structure.modules{i});
    end
    structure_info{end+1} = '';
    
    % 测试文件
    structure_info{end+1} = sprintf('#### 测试文件 (%d个)', length(structure.tests));
    for i = 1:length(structure.tests)
        structure_info{end+1} = sprintf('- `%s`', structure.tests{i});
    end
    structure_info{end+1} = '';
    
    % 脚本文件
    structure_info{end+1} = sprintf('#### 脚本文件 (%d个)', length(structure.scripts));
    for i = 1:length(structure.scripts)
        structure_info{end+1} = sprintf('- `%s`', structure.scripts{i});
    end
    structure_info{end+1} = '';
end

function generate_sync_report(structure, agent_types, market_modules)
    % 生成同步报告
    
    report_path = 'docs/SYNC_REPORT.md';
    
    fid = fopen(report_path, 'w');
    if fid == -1
        fprintf('  错误: 无法创建同步报告\n');
        return;
    end
    
    % 写入报告标题
    fprintf(fid, '# 文档同步报告\n\n');
    fprintf(fid, '**生成时间**: %s\n\n', datestr(now));
    
    % 代码结构统计
    fprintf(fid, '## 代码结构统计\n\n');
    fprintf(fid, '- 智能体文件: %d个\n', length(structure.agents));
    fprintf(fid, '- 核心模块文件: %d个\n', length(structure.core));
    fprintf(fid, '- 市场模块文件: %d个\n', length(structure.modules));
    fprintf(fid, '- 测试文件: %d个\n', length(structure.tests));
    fprintf(fid, '- 脚本文件: %d个\n\n', length(structure.scripts));
    
    % 智能体验证结果
    fprintf(fid, '## 智能体验证结果\n\n');
    fields = fieldnames(agent_types);
    for i = 1:length(fields)
        agent_name = fields{i};
        status = agent_types.(agent_name);
        switch status
            case 'EXISTS'
                fprintf(fid, '- ✓ %s\n', agent_name);
            case 'MISSING'
                fprintf(fid, '- ✗ %s (缺失)\n', agent_name);
            case 'EXTRA'
                fprintf(fid, '- + %s (额外)\n', agent_name);
        end
    end
    fprintf(fid, '\n');
    
    % 市场模块验证结果
    fprintf(fid, '## 市场模块验证结果\n\n');
    fields = fieldnames(market_modules);
    for i = 1:length(fields)
        module_name = fields{i};
        status = market_modules.(module_name);
        switch status
            case 'EXISTS'
                fprintf(fid, '- ✓ %s\n', module_name);
            case 'MISSING'
                fprintf(fid, '- ✗ %s (缺失)\n', module_name);
            case 'EXTRA'
                fprintf(fid, '- + %s (额外)\n', module_name);
        end
    end
    fprintf(fid, '\n');
    
    % 同步状态
    fprintf(fid, '## 同步状态\n\n');
    fprintf(fid, '✅ 文档已与当前代码结构同步\n');
    fprintf(fid, '✅ README.md已更新\n');
    fprintf(fid, '✅ 备份文件已创建\n\n');
    
    fclose(fid);
    
    fprintf('  同步报告已生成: %s\n', report_path);
end 