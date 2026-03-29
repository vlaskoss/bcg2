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
local PlayersService = game:GetService("Players")

local serverFolder       = ServerStorage.Server
local sharedFolder       = ReplicatedStorage.Shared
local modulesFolder      = serverFolder.Modules
local sharedModulesFolder = sharedFolder.Modules

local multiplierConfig = require(modulesFolder.MultiplierConfig)
local dataManager      = require(modulesFolder.DataManager)
local gameUtils        = require(sharedModulesFolder.GameUtils)
local gammaNum         = require(sharedModulesFolder.GammaNum)

local function toGamma(value)
    if typeof(value) == "number" then
        return gammaNum.fromNumber(value)
    end
    return value -- already a gammaNum
end

local ZERO = gammaNum.fromNumber(0)
local ONE  = gammaNum.fromNumber(1)

local function hasGamepass(player, gamepassId)
    local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, gamepassId)
    return ok and owns
end



-- specific type handlers
-- each handler receives (player, config: optional) and returns a gammaNum contribution.
-- nil means no contribution

local Handlers = {}

function Handlers.Base2(player)
    local tier = dataManager:GetUpgrade(player, "Base2")
    if not tier or tier < 1 then return nil end
    local perUpgrade = gammaNum.pow(tier, 2)
    return perUpgrade
end

function Handlers.ServerAge(player)
    local tier = dataManager:GetUpgrade(player, "ServerAge")
    if not tier or tier == false then return nil end

    local serverAge = toGamma(math.floor(time()))
    local multiplier = gammaNum.div(gammaNum.log10(serverAge), 2)
    if gammaNum.gte(multiplier, ONE) then return multiplier else return nil end
end


function Handlers.ExponentRecursion(player)
    local tier = dataManager:GetUpgrade(player, "ExponentRecursion")
    if not tier or tier == false then return nil end

    local clicks = dataManager:RetrieveAmount(player, "Clicks")
    if not clicks then return nil end

    local logClicks = gammaNum.log10(clicks)
    local multiplier = gammaNum.div(logClicks, 100)
    
    return multiplier
end

function Handlers.PyramidScheme(player)
    local tier = dataManager:GetUpgrade(player, "PyramidScheme")
    if not tier or tier == false then return nil end
    
    local numPlayers = #PlayersService:GetPlayers()
    local perPlayer = gammaNum.mul(numPlayers, 0.01)
    
    return perPlayer
end

function Handlers.Exponents(player)
    local tier = dataManager:GetUpgrade(player, "Exponents")
    if not tier or tier < 1 then return nil end

    local perUpgrade = gammaNum.mul(tier, 0.05)

    return perUpgrade
end

function Handlers.Recursion(player)
    local tier = dataManager:GetUpgrade(player, "Recursion")
    if not tier or tier < 1 then return nil end

    local clicks = dataManager:RetrieveAmount(player, "Clicks")
    if not clicks then return nil end

    local logClicks = gammaNum.log10(clicks)
    local tierScale = gammaNum.div(tier, 20)
    local scaled = gammaNum.mul(logClicks, tierScale)
    local multiplier = gammaNum.add(scaled, ONE)
    return multiplier
end

function Handlers.TimePlayed(player)
    local tier = dataManager:GetUpgrade(player, "TimePlayed")
    if not tier or tier < 1 then return nil end

    local time = dataManager:GetStatistic(player, "TotalTime") 
    if not time then return nil end

    local t        = toGamma(time)
    local sqrtTime = gammaNum.pow(t, toGamma(0.5))
    local scaled   = gammaNum.div(sqrtTime, toGamma(30))
    local afterTierCalculation = gammaNum.mul(scaled, gammaNum.div(tier, 5))
    return gammaNum.add(afterTierCalculation, ONE)
end

function Handlers.PerStat(player, config)
    local stat = dataManager:RetrieveAmount(player, config.Stat)
    if not stat then return nil end
    local value = gammaNum.mul(toGamma(stat), toGamma(config.ValuePerUnit or 1))
    if config.Offset then
        value = gammaNum.add(value, toGamma(config.Offset))
    end
    return value
end

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

    if value == 0 then return nil end

    return toGamma(value)
end

function Handlers.Gamepass(player, config)
    if hasGamepass(player, config.GamepassId) then
        return toGamma(config.Value or 1)
    end
    return nil
end

function Handlers.Rebirth(player, config)
    local rebirths = dataManager:RetrieveAmount(player, "Rebirths")
    if not rebirths or rebirths == 0 then return ONE end

    local multiplierPerRebirth = toGamma(config.MultiplierPerRebirth or 2)
    return gammaNum.mul(toGamma(rebirths), multiplierPerRebirth)
end

-- calculations

local function evaluateSource(player, config)
    local handler = Handlers[config.Type]
    if not handler then
        warn(`[ClickCalculationManager]: Unknown upgrade type {config.Type} – skipping`)
        return nil
    end
    local ok, result = pcall(handler, player, config)
    if not ok then
        warn(`[ClickCalculationManager]: Handler error for type {config.Type}: {result}`)
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
            baseTotal = gammaNum.add(baseTotal, value or ZERO)

        elseif config.Category == "Final" then
            finalTotal = gammaNum.mul(finalTotal, value or ONE)

        elseif config.Category == "Exponent" then
            exponentTotal = gammaNum.add(exponentTotal, value or ZERO)

        else
            warn(`[ClickCalculationManager]: Unknown upgrade category {tostring(config.Category)} from source {sourceName} – skipping`)
        end
    end

    return baseTotal, finalTotal, exponentTotal
end

local ClickCalculationManager = {}
ClickCalculationManager.Cache = {}  

local function getCached(player, key, default)
    local data = ClickCalculationManager.Cache[player.UserId]
    return (data and data[key]) or default
end

function ClickCalculationManager:InitialisePlayer(player)
    self:UpdateMultiplier(player)
end

function ClickCalculationManager:RemovePlayer(player)
    self.Cache[player.UserId] = nil
end

function ClickCalculationManager:UpdateMultiplier(player)
    local baseTotal, finalTotal, exponentTotal = buildTotals(player)
    local combined = gammaNum.mul(baseTotal, finalTotal)
    local total = gammaNum.pow(combined, exponentTotal)

    self.Cache[player.UserId] = {
        Base  = baseTotal,
        Final = finalTotal,
        Exponent = exponentTotal,
        Total = total,
    }

    print(`[ClickCalculationManager]: {gameUtils:MakePossessive(player.Name)} multiplier - Base {baseTotal} x Final {finalTotal} ^ Exponent {exponentTotal} = {total}`)
end

function ClickCalculationManager:GetMultiplier(player)     return getCached(player, "Total",    ONE)  end
function ClickCalculationManager:GetBaseMultiplier(player) return getCached(player, "Base",     ZERO) end
function ClickCalculationManager:GetFinalMultiplier(player)return getCached(player, "Final",    ONE)  end
function ClickCalculationManager:GetExponent(player)       return getCached(player, "Exponent", ONE)  end

-- applies cached multiplier to a click amount (the base)
function ClickCalculationManager:Calculate(player, baseAmount)
    local multiplier = self:GetMultiplier(player)
    local base       = toGamma(baseAmount)
    return gammaNum.floor(gammaNum.mul(base, multiplier))
end

return ClickCalculationManager
