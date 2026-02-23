--[[
    UpgradesHandler_server.luau
    ─────────────────────────────────────────────────────────────────────────────
    Handles upgrade purchase requests from clients.

    Security model
    ───────────────
    All validation (affordability, max level, unlock requirements) is done
    server-side. The client does optimistic UI updates for responsiveness, but
    the server is the source of truth.
--]]

debug.setmemorycategory("Upgrades")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")

local serverFolder      = ServerStorage.Server
local sharedFolder      = ReplicatedStorage.Shared
local remotesFolder     = sharedFolder.Remotes
local modulesFolder     = serverFolder.Modules
local sharedModulesFolder = sharedFolder.Modules

local upgradeEvent  = remotesFolder.UpgradeEvent

local dataManager   = require(modulesFolder.DataManager)
local upgradeConfig = require(sharedModulesFolder.UpgradeConfig)
local gameUtils     = require(sharedModulesFolder.GameUtils)
local gammaNum      = require(sharedModulesFolder.GammaNum)

local upgradeFormulas = sharedModulesFolder.UpgradeFormulas

-- ─── helpers ─────────────────────────────────────────────────────────────────

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

-- Returns true if the player meets all unlock requirements for this upgrade.
local function meetsRequirements(player, config)
    -- RequiredUpgrade: another upgrade must be at tier >= 1
    if config.RequiredUpgrade then
        local reqTier = dataManager:GetUpgrade(player, config.RequiredUpgrade)
        if not reqTier or reqTier < 1 then
            return false, "locked behind " .. config.RequiredUpgrade
        end
    end

    -- RequiredLevel: player's Level must be >= threshold
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

-- ─── purchase handler ────────────────────────────────────────────────────────

upgradeEvent.OnServerEvent:Connect(function(player, upgradeKey)
    -- 1. Config must exist
    local config = upgradeConfig[upgradeKey]
    if not config then
        warn(`[UpgradesHandler] Unknown upgradeKey "{upgradeKey}" from {player.Name}`)
        return
    end

    -- 2. Unlock requirements
    local unlocked, reason = meetsRequirements(player, config)
    if not unlocked then
        warn(`[UpgradesHandler] {player.Name} tried to buy locked upgrade "{upgradeKey}": {reason}`)
        return
    end

    -- 3. Not already maxed
    local currentTier = getCurrentTier(player, upgradeKey, config)
    if isMaxed(config, currentTier) then
        warn(`[UpgradesHandler] {player.Name} tried to buy maxed upgrade "{upgradeKey}"`)
        return
    end

    -- 4. Affordability
    local cost = getUpgradeCost(config, currentTier)

    -- Special case: level cost reduction applies to Level purchases
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
        print(`[UpgradesHandler] {player.Name} cannot afford "{upgradeKey}"`)
        return
    end

    -- 5. Apply purchase
    dataManager:DeductCurrency(player, "Clicks", cost)

    if config.StatType == "Level" then
        dataManager:AddCurrency(player, config.RelatedStat, 1)
    else
        dataManager:SetUpgrade(player, upgradeKey, currentTier + 1)
    end

    -- 6. Optional callback
    if config.OnUpgrade then
        config.OnUpgrade(player, currentTier + 1)
    end

    print(`[UpgradesHandler] {player.Name} purchased "{upgradeKey}" → tier {currentTier + 1}`)
end)
