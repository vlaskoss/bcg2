debug.setmemorycategory("Upgrades")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")

local serverFolder      = ServerStorage.Server
local sharedFolder      = ReplicatedStorage.Shared
local remotesFolder     = sharedFolder.Remotes
local modulesFolder     = serverFolder.Modules
local sharedModulesFolder = sharedFolder.Modules

local upgradeEvent  = remotesFolder.UpgradeEvent
local upgradeReturnEvent = remotesFolder.UpgradeReturnEvent

local dataManager   = require(modulesFolder.DataManager)
local upgradeConfig = require(sharedModulesFolder.UpgradeConfig)
local upgradeFormulas = require(sharedModulesFolder.UpgradeFormulas)
local gameUtils     = require(sharedModulesFolder.GameUtils)
local gammaNum      = require(sharedModulesFolder.GammaNum)

local function getUpgradeCost(upgradeKey, config, currentTier)
    if config.CostFormula then
        local formula = upgradeFormulas[upgradeKey]
        if formula then 
            return formula(currentTier)
        end
    end
    return gameUtils:EnsureGammaNum(config.Cost or 0)
end

local function getCurrentTier(player, upgradeKey, config)
    if config.StatType == "Level" then
        local val = dataManager:RetrieveAmount(player, config.RelatedStat)
        return typeof(val) == "number" and val or 0
    else
        local val = dataManager:GetUpgrade(player, upgradeKey)
        return typeof(val) == "number" and val or 0
    end
end

local function meetsRequirements(player, config)
    if config.RequiredUpgrade then
        local minTier = config.RequiredUpgradeTier or 1
        local reqTier = dataManager:GetUpgrade(player, config.RequiredUpgrade)
        if not reqTier or reqTier < minTier then
            return false, "locked behind " .. config.RequiredUpgrade .. " tier " .. minTier
        end
    end

    if config.RequiredLevel then
        local level = dataManager:RetrieveAmount(player, "Level")
        if not level or level < config.RequiredLevel then
            return false, "requires level " .. config.RequiredLevel
        end
    end

    return true
end

local function canPurchaseUpgrade(config, currentTier)
    if config.Type == "Single" then
        return currentTier ~= true
    elseif config.Type == "Finite" then
        return currentTier < (config.MaxLevel or math.huge)
    elseif config.Type == "Tiered" then
        return currentTier < (config.MaxTier or (config.Tiers and #config.Tiers) or math.huge)
    end
    return true
end

upgradeEvent.OnServerEvent:Connect(function(player, upgradeKey)
    local config = upgradeConfig[upgradeKey]
    if not config then
        warn(`[UpgradesHandler]: unknown upgradeKey {upgradeKey} from {player.Name}`)
        upgradeReturnEvent:FireClient(player, upgradeKey, false, "does not exist")
        return
    end

    local unlocked, reason = meetsRequirements(player, config)
    if not unlocked then
        warn(`[UpgradesHandler]: {player.Name} tried to buy locked upgrade {upgradeKey}: {reason}`)
        upgradeReturnEvent:FireClient(player, upgradeKey, false, "locked")
        return
    end

    local currentTier = getCurrentTier(player, upgradeKey, config)
    
    if not canPurchaseUpgrade(config, currentTier) then
        warn(`[UpgradesHandler]: {player.Name} tried to buy maxed upgrade {upgradeKey}`)
        upgradeReturnEvent:FireClient(player, upgradeKey, false, "maxed")
        return
    end

    local cost = getUpgradeCost(upgradeKey, config, currentTier)

    if upgradeKey == "Level" then
        local reduction = dataManager:GetUpgrade(player, "ReduceLevelCost") or 0
        local factor    = gammaNum.div(
            gammaNum.sub(gammaNum.fromNumber(100), gammaNum.fromNumber(reduction)),
            gammaNum.fromNumber(100)
        )
        cost = gammaNum.mul(cost, factor)
    end

    local playerClicks = gameUtils:EnsureGammaNum(dataManager:RetrieveAmount(player, "Clicks"))

    if not gammaNum.gte(playerClicks, cost) then
        print(`[UpgradesHandler]: {player.Name} cannot afford {upgradeKey}`)
        upgradeReturnEvent:FireClient(player, upgradeKey, false, "no money :(")
        return
    end

    dataManager:DeductCurrency(player, "Clicks", cost)

    local newTier
    if config.StatType == "Level" then
        dataManager:AddCurrency(player, config.RelatedStat, 1)
        newTier = currentTier + 1
    elseif config.Type == "Single" then
        dataManager:SetUpgrade(player, upgradeKey, true)
        newTier = true
    else
        dataManager:SetUpgrade(player, upgradeKey, currentTier + 1)
        newTier = currentTier + 1
    end

    if config.OnUpgrade then
        config.OnUpgrade(player, newTier)
    end
    upgradeReturnEvent:FireClient(player, upgradeKey, true, newTier)
    print(`[UpgradesHandler]: {player.Name} purchased {upgradeKey} -> {tostring(newTier)}`)
end)