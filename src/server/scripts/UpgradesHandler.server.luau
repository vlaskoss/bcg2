debug.setmemorycategory("Upgrades")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local serverFolder, sharedFolder = ServerStorage.Server, ReplicatedStorage.Shared
local remotesFolder, sharedModulesFolder = sharedFolder.Remotes, sharedFolder.Modules
local modulesFolder = serverFolder.Modules

local upgradeFormulas = sharedModulesFolder.UpgradeFormulas
local upgradeEvent = remotesFolder.UpgradeEvent

local dataManager = require(modulesFolder.DataManager)
local upgradeConfig = require(sharedModulesFolder.UpgradeConfig)
local gameUtils = require(sharedModulesFolder.GameUtils)
local gammaNum = require(sharedModulesFolder.GammaNum)

local function getUpgradeCost(config, tier)
    if config.CostFormula then
        local formulaModule = upgradeFormulas:FindFirstChild(config.CostFormula)
        if formulaModule then
            return require(formulaModule)(tier)
        end
    end
    return gammaNum.fromNumber(0)
end

upgradeEvent.OnServerEvent:Connect(function(player, upgradeKey)
    local config = upgradeConfig[upgradeKey]
    if not config then return end
    
    local currentStatValue
    if config.StatType == "Level" then
        currentStatValue = dataManager:RetrieveAmount(player, config.RelatedStat)
    elseif config.StatType == "Upgrade" then
        currentStatValue = dataManager:GetUpgrade(player, upgradeKey)
    end
    
    local currentLevel = typeof(currentStatValue) == "number" and currentStatValue or 0
    
    if config.Type == "Finite" and currentLevel >= config.MaxLevel then
        warn(player.Name .. " reached max level for " .. upgradeKey)
        return
    end
    
    local cost = getUpgradeCost(config, currentLevel)   
    if upgradeKey == "Level" then
        local levelCostReduction = dataManager:GetUpgrade(player, "ReduceLevelCost")
        local finalCostReduction = gammaNum.div(gammaNum.sub(gammaNum.fromNumber(100), gammaNum.fromNumber(levelCostReduction)), gammaNum.fromNumber(100))
        cost = gammaNum.mul(cost, finalCostReduction)
    end
    local playerClicks = gameUtils:EnsureGammaNum(dataManager:RetrieveAmount(player, "Clicks")) 

    if gammaNum.gte(playerClicks, cost) then 
        if config.StatType == "Level" then
            dataManager:DeductCurrency(player, "Clicks", cost)
            dataManager:AddCurrency(player, config.RelatedStat, 1)
        elseif config.StatType == "Upgrade" then
            print(currentLevel)
            dataManager:DeductCurrency(player, "Clicks", cost)
            dataManager:SetUpgrade(player, upgradeKey, currentLevel + 1)
        end

        if config.OnUpgrade then
            config.OnUpgrade(player, currentLevel + 1) 
        end
    else
        
        print(`[UpgradesHandler] Player {player.Name} cannot afford {upgradeKey}`)
    end
end)