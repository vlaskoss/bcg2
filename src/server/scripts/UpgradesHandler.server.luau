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
local gameUtils     = require(sharedModulesFolder.GameUtils)
local gammaNum      = require(sharedModulesFolder.GammaNum)

local upgradeFormulas = sharedModulesFolder.UpgradeFormulas

local function getUpgradeCost(config, currentTier)
    if config.CostFormula then
        local formulaModule = upgradeFormulas:FindFirstChild(config.CostFormula)
        if formulaModule then
            return require(formulaModule)(currentTier)
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

local function isMaxed(config, currentTier)
    if config.Type == "Finite"   and currentTier >= (config.MaxLevel or math.huge) then return true end
    if config.Type == "Single"   and currentTier >= 1                               then return true end
    if config.Type == "Tiered"   and currentTier >= (config.MaxTier or (config.Tiers and #config.Tiers) or math.huge) then return true end
    return false
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
    if isMaxed(config, currentTier) then
        warn(`[UpgradesHandler]: {player.Name} tried to buy maxed upgrade {upgradeKey}`)
        upgradeReturnEvent:FireClient(player, upgradeKey, false, "maxed")
        return
    end

    local cost = getUpgradeCost(config, currentTier)

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

    if config.StatType == "Level" then
        dataManager:AddCurrency(player, config.RelatedStat, 1)
    else
        dataManager:SetUpgrade(player, upgradeKey, currentTier + 1)
    end

    if config.OnUpgrade then
        config.OnUpgrade(player, currentTier + 1)
    end
    upgradeReturnEvent:FireClient(player, upgradeKey, true, currentTier + 1)
    print(`[UpgradesHandler]: {player.Name} purchased {upgradeKey} tier {currentTier + 1}`)
end)
