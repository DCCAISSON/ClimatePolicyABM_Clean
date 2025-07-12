# 文件移动脚本 - 将core目录下的文件移动到对应的包目录
# 运行前请确保在ClimatePolicyABM_Clean目录下

Write-Host "开始文件迁移..." -ForegroundColor Green

# 1. 移动核心类到 +core/
Write-Host "移动核心类到 +core/..." -ForegroundColor Yellow
$coreFiles = @(
    "MultiAgentClimatePolicyModel.m",
    "AgentWithExpectations.m", 
    "ExpectationFormationModule.m",
    "ModelValidationFramework.m"
)

foreach ($file in $coreFiles) {
    if (Test-Path "core\$file") {
        Move-Item "core\$file" "+core\" -Force
        Write-Host "  已移动: $file" -ForegroundColor Green
    } else {
        Write-Host "  文件不存在: $file" -ForegroundColor Red
    }
}

# 2. 移动智能体到 +agents/
Write-Host "移动智能体到 +agents/..." -ForegroundColor Yellow
$agentFiles = @(
    "EnterpriseAgent.m",
    "EnterpriseAgentWithExpectations.m",
    "HouseholdAgent.m", 
    "PesticideEnterpriseAgent.m",
    "FertilizerEnterpriseAgent.m",
    "AgroProcessingEnterpriseAgent.m",
    "GrainFarmAgent.m",
    "CashCropFarmAgent.m", 
    "MixedCropFarmAgent.m",
    "AgriculturalServiceEnterpriseAgent.m",
    "FarmerAgentWithExpectations.m",
    "GovernmentAgent.m",
    "GovernmentAgentWithExpectations.m",
    "AgriculturalEnterpriseWithExpectations.m",
    "LaborDemanderAgent.m",
    "LaborSupplierAgent.m",
    "ChemicalEnterpriseAgent.m"
)

foreach ($file in $agentFiles) {
    if (Test-Path "core\$file") {
        Move-Item "core\$file" "+agents\" -Force
        Write-Host "  已移动: $file" -ForegroundColor Green
    } else {
        Write-Host "  文件不存在: $file" -ForegroundColor Red
    }
}

# 3. 移动功能模块到 +modules/
Write-Host "移动功能模块到 +modules/..." -ForegroundColor Yellow
$moduleFiles = @(
    "CommodityMarketModule.m",
    "LandMarketModule.m",
    "InputMarketModule.m", 
    "PesticideMarketModule.m",
    "FertilizerMarketModule.m",
    "LaborMarketModule.m",
    "EvolutionaryGameModule.m",
    "EvolutionaryGameModuleAdvanced.m",
    "EvolutionaryGameAnalysis.m",
    "SimplifiedLaborMarket.m"
)

foreach ($file in $moduleFiles) {
    if (Test-Path "core\$file") {
        Move-Item "core\$file" "+modules\" -Force
        Write-Host "  已移动: $file" -ForegroundColor Green
    } else {
        Write-Host "  文件不存在: $file" -ForegroundColor Red
    }
}

# 4. 移动配置文件
Write-Host "移动配置文件到 config/..." -ForegroundColor Yellow
if (Test-Path "params\climate_policy_config.json") {
    Move-Item "params\climate_policy_config.json" "config\" -Force
    Write-Host "  已移动: climate_policy_config.json" -ForegroundColor Green
}

Write-Host "文件迁移完成!" -ForegroundColor Green 