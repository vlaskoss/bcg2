--[[
    ClickCalculationManager.luau
    ─────────────────────────────────────────────────────────────────────────────
    Owns per-player multiplier state and exposes clean public methods.

    Calculation pipeline
    ─────────────────────
    1. For every "Base" config entry  → evaluate → SUM  them  → baseTotal
    2. For every "Final" config entry → evaluate → PRODUCT them → finalTotal
    3. clickValue = floor( baseTotal * finalTotal )

    Adding a new multiplier type
    ──────────────────────────────
    1. Add a handler inside the `Handlers` table below.
    2. Define the config shape in MultiplierConfig (see its docs).
    That's it – no changes needed anywhere else.
--]]

local ServerStorage    = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")

local serverFolder       = ServerStorage.Server
local sharedFolder       = ReplicatedStorage.Shared
local modulesFolder      = serverFolder.Modules
local sharedModulesFolder = sharedFolder.Modules

local multiplierConfig = require(modulesFolder.MultiplierConfig)
local dataManager      = require(modulesFolder.DataManager)
local gameUtils        = require(sharedModulesFolder.GameUtils)
local gammaNum         = require(sharedModulesFolder.GammaNum)

-- ─── helpers ────────────────────────────────────────────────────────────────

local function toGamma(value)
    if typeof(value) == "number" then
        return gammaNum.fromNumber(value)
    end
    -- already a GammaNum (buffer or table with .toSuffix)
    return value
end

local ZERO = gammaNum.fromNumber(0)
local ONE  = gammaNum.fromNumber(1)

local function gammaAdd(a, b) return gammaNum.add(a, b) end
local function gammaMul(a, b) return gammaNum.mul(a, b) end
local function gammaPow(a, b) return gammaNum.pow(a, b) end

local function hasGamepass(player, gamepassId)
    local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, gamepassId)
    return ok and owns
end

-- ─── type handlers ──────────────────────────────────────────────────────────
--
-- Each handler receives (player, config) and returns a GammaNum contribution.
-- Return nil to mean "no contribution" (treated as identity for the category).

local Handlers = {}

-- Always-on flat value.
function Handlers.Flat(player, config)
    return toGamma(config.Value or 0)
end



function Handlers.Base2(player, config)
    local tier = dataManager:GetUpgrade(player, config.Upgrade)
    if not tier or tier < 1 then return nil end
    local perUpgrade = gammaPow(tier, 2)
    return perUpgrade
end


function Handlers.Exponents(player, config)
    local tier = dataManager:GetUpgrade(player, config.Upgrade)
    if not tier or tier < 1 then return nil end

    local perUpgrade = gammaMul(tier, 0.05)

    return perUpgrade
end


function Handlers.Recursion(player, config)
    local tier = dataManager:GetUpgrade(player, config.Upgrade)
    if not tier or tier < 1 then return nil end

    local clicks = dataManager:RetrieveAmount(player, "Clicks")
    if not clicks then return nil end

    local logClicks = gammaNum.log10(clicks)
    local tierScale = gammaNum.div(tier, 4)
    local scaled = gammaMul(logClicks, tierScale)
    local multiplier = gammaAdd(scaled, ONE)
    print(gammaNum.toSuffix(multiplier))
    return multiplier
end

function Handlers.TimePlayed(player, config)
    local tier
    if config.RequiredUpgrade then
        local tier = dataManager:GetUpgrade(player, config.RequiredUpgrade)
        if not tier or tier < 1 then return nil end
    end

    local time = dataManager:GetStatistic(player, config.Stat) 
    if not time then return nil end

    local t        = toGamma(time)
    local sqrtTime = gammaPow(t, toGamma(0.5))
    local scaled   = gammaNum.div(sqrtTime, toGamma(30))
    local afterTierCalculation = gammaMul(scaled, gammaNum.div(tier, 2))
    return gammaAdd(afterTierCalculation, ONE)
end

-- Linear: stat * ValuePerUnit
function Handlers.PerStat(player, config)
    local stat = dataManager:RetrieveAmount(player, config.Stat)
    if not stat then return nil end
    local value = gammaNum.mul(toGamma(stat), toGamma(config.ValuePerUnit or 1))
    if config.Offset then
        value = gammaAdd(value, toGamma(config.Offset))
    end
    return value
end

-- Upgrade tier → value via Steps table (preferred) or BaseValue + tier*ValuePerTier.
function Handlers.PerUpgrade(player, config)
    local tier = dataManager:GetUpgrade(player, config.Upgrade)
    if not tier then return nil end

    local value
    if config.Steps then
        value = config.Steps[tier] or config.Steps[0] or 0
    else
        local base  = config.BaseValue    or 0
        local slope = config.ValuePerTier or 0
        value = base + tier * slope
    end

    -- a Final source returning 0 would wipe everything — treat as no contribution
    if value == 0 then return nil end

    return toGamma(value)
end

-- Gamepass flat bonus.
function Handlers.Gamepass(player, config)
    if hasGamepass(player, config.GamepassId) then
        return toGamma(config.Value or 1)
    end
    return nil
end

-- Exponential rebirth scaling: MultiplierPerRebirth ^ rebirths
-- Returns 1 when rebirths = 0 (safe identity).
function Handlers.Rebirth(player, config)
    local rebirths = dataManager:RetrieveAmount(player, "Rebirths")

    -- no data or zero rebirths → identity (1x), not 0
    if not rebirths or rebirths == 0 then return ONE end

    local base  = toGamma(config.MultiplierPerRebirth or 2)
    local expnt = toGamma(rebirths)

    if gammaNum.eq(expnt, ZERO) then return ONE end
    return gammaMul(base, expnt)
end

-- ─── core calculation ────────────────────────────────────────────────────────

local function evaluateSource(player, config)
    local handler = Handlers[config.Type]
    if not handler then
        warn("[ClickCalculationManager]: Unknown Type '" .. tostring(config.Type) .. "' – skipping")
        return nil
    end
    local ok, result = pcall(handler, player, config)
    if not ok then
        warn("[ClickCalculationManager]: Handler error for Type '" .. tostring(config.Type) .. "': " .. tostring(result))
        return nil
    end
    return result
end

local function buildTotals(player)
    local baseTotal  = ZERO
    local finalTotal = ONE
    local exponentTotal = ONE

    for sourceName, config in pairs(multiplierConfig) do
        local value = evaluateSource(player, config)

        if config.Category == "Base" then
            baseTotal = gammaAdd(baseTotal, value or ZERO)

        elseif config.Category == "Final" then
            finalTotal = gammaMul(finalTotal, value or ONE)

        elseif config.Category == "Exponent" then
            exponentTotal = gammaAdd(exponentTotal, value or ZERO)

        else
            warn("[ClickCalculationManager]: Unknown Category '" .. tostring(config.Category) .. "' on source '" .. sourceName .. "' – skipping")
        end
    end

    return baseTotal, finalTotal, exponentTotal
end

-- ─── public API ─────────────────────────────────────────────────────────────

local ClickCalculationManager = {}
ClickCalculationManager._cache = {}   -- [userId] = { Base, Final, Total }

function ClickCalculationManager:InitialisePlayer(player)
    self:UpdateMultiplier(player)
end

function ClickCalculationManager:RemovePlayer(player)
    self._cache[player.UserId] = nil
end

function ClickCalculationManager:UpdateMultiplier(player)
    local baseTotal, finalTotal, exponentTotal = buildTotals(player)
    local combined = gammaMul(baseTotal, finalTotal)
    local total = gammaPow(combined, exponentTotal)

    self._cache[player.UserId] = {
        Base  = baseTotal,
        Final = finalTotal,
        Total = total,
    }

    print(string.format(
        "[ClickCalculationManager]: %s multiplier → Base %s × Final %s ^ Exponent %s = %s",
        gameUtils:MakePossessive(player.Name),
        gammaNum.toSuffix(baseTotal),
        gammaNum.toSuffix(finalTotal),
        gammaNum.toSuffix(exponentTotal),
        gammaNum.toSuffix(total)
    ))
end

-- Returns the cached Total GammaNum (defaults to 1 if not yet computed).
function ClickCalculationManager:GetMultiplier(player)
    local data = self._cache[player.UserId]
    return (data and data.Total) or ONE
end

-- Returns just the base portion (useful for UI breakdowns).
function ClickCalculationManager:GetBaseMultiplier(player)
    local data = self._cache[player.UserId]
    return (data and data.Base) or ZERO
end

-- Returns just the final-multiplier portion.
function ClickCalculationManager:GetFinalMultiplier(player)
    local data = self._cache[player.UserId]
    return (data and data.Final) or ONE
end

-- Applies the cached multiplier to a base click amount.
function ClickCalculationManager:Calculate(player, baseAmount)
    local multiplier = self:GetMultiplier(player)
    local base       = toGamma(baseAmount)
    return gammaNum.floor(gammaMul(base, multiplier))
end

return ClickCalculationManager
