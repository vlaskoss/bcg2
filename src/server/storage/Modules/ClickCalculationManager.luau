local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local serverFolder, sharedFolder = ServerStorage.Server, ReplicatedStorage.Shared
local modulesFolder, sharedModulesFolder = serverFolder.Modules, sharedFolder.Modules
local multiplierFormulas = modulesFolder.MultiplierFormulas

local multiplierConfig = require(modulesFolder.MultiplierConfig)
local dataManager = require(modulesFolder.DataManager)
local gameUtils = require(sharedModulesFolder.GameUtils)
local gammaNum = require(sharedModulesFolder.GammaNum)

local ClickCalculationManager = {}
ClickCalculationManager.PlayerMultipliers = {}

local function getMultiplierFromFormula(config, relatedStat)
    if config.MultiplierFormula then
        local formulaModule = multiplierFormulas:FindFirstChild(config.MultiplierFormula)
        if formulaModule then
            return require(formulaModule)(relatedStat)
        end
    end
end

local function hasGamepass(player, gamepassId)
    local success, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
    end)
    return success and owns
end

local function checkGammaNum(value)
    if typeof(value) == "buffer" then
        return value 
    elseif typeof(value) == "number" then
        return gammaNum.fromNumber(value)
    elseif typeof(value) == "table" and value.toSuffix then
        return value 
    else
        return gammaNum.fromNumber(1)
    end
end

local function calcMultiplier(player, multiName, config)
    if config.Type == "Gamepass" then
        if hasGamepass(player, config.GamepassId) then
            return gammaNum.fromNumber(config.Multiplier)
        end

    elseif config.Type == "Currency" then
        local currency = dataManager:RetrieveAmount(player, config.RelatedStat) 
        if currency then
            return checkGammaNum(config.Multiplier)
        end

    elseif config.Type == "Upgrade" then
        local currency = dataManager:GetUpgrade(player, config.RelatedStat)
        if currency then
            local multiplier = checkGammaNum(config.Multiplier)
            local currencyNum = checkGammaNum(currency)
            return gammaNum.pow(multiplier, currencyNum)
        end
    
    elseif config.Type == "Statistic" then
        local required = dataManager:GetUpgrade(player, config.RequiredStat)
        local statistic = dataManager:GetStatistic(player, config.RelatedStat)
        if required >= 1 then
            if statistic then
                return getMultiplierFromFormula(config, statistic)
            end
        end
    
    elseif config.Type == "Level" then
        local level = dataManager:RetrieveAmount(player, "Level")
        if level then
            local levelNum = checkGammaNum(level)
            local perLevel = gammaNum.fromNumber(config.MultiplierPerLevel)
            local levelMulti = gammaNum.mul(levelNum, perLevel)
            return levelMulti
        end

    elseif config.Type == "Rebirth" then
        local rebirths = dataManager:RetrieveAmount(player, "Rebirths")
        if rebirths then
            local rebirthNum = checkGammaNum(rebirths)
            local perLevel = gammaNum.fromNumber(config.MultiplierPerLevel)
            local levelMulti = gammaNum.pow(perLevel, rebirthNum)
            if gammaNum.eq(rebirthNum, gammaNum.fromNumber(0)) then
                return gammaNum.fromNumber(1)
            end
            return levelMulti
        else
            return gammaNum.fromNumber(1)
        end
    end
    return gammaNum.fromNumber(1)
end

function ClickCalculationManager:UpdateMultiplier(player)
    local baseMultiplier = gammaNum.fromNumber(0)
    local finalMultiplier = gammaNum.fromNumber(1)


    for sourceName, config in pairs(multiplierConfig) do
        if config.Category == "Base" or not config.Category then
            local sourceMulti = calcMultiplier(player, sourceName, config)
            sourceMulti = checkGammaNum(sourceMulti)
            baseMultiplier = gammaNum.add(baseMultiplier, sourceMulti)
        end
    end

    for sourceName, config in pairs(multiplierConfig) do
        if config.Category == "Final" then
            local sourceMulti = calcMultiplier(player, sourceName, config)
            sourceMulti = checkGammaNum(sourceMulti)
            finalMultiplier = gammaNum.mul(finalMultiplier, sourceMulti)
        end
    end  

    local totalMultiplier = gammaNum.mul(baseMultiplier, finalMultiplier)

    self.PlayerMultipliers[player.UserId] = {
        Base = baseMultiplier,
        Final = finalMultiplier,
        Total = totalMultiplier
    }    
    
    print(`[ClickCalculationManager]: {gameUtils:MakePossessive(player.Name)} multiplier has been updated to {gammaNum.toSuffix(totalMultiplier)}`)
end

function ClickCalculationManager:GetMultiplier(player)
    local data = self.PlayerMultipliers[player.UserId]
    if data and data.Total then
        return data.Total
    end
    return gammaNum.fromNumber(1)
end

function ClickCalculationManager:Calculate(player, baseAmount)
    local multiplier = self:GetMultiplier(player)
    local base = checkGammaNum(baseAmount)
    
    local result = gammaNum.mul(base, multiplier)
    
    return gammaNum.floor(result)
end

function ClickCalculationManager:InitialisePlayer(player)
    self:UpdateMultiplier(player)
end

function ClickCalculationManager:RemovePlayer(player)
    self.PlayerMultipliers[player.UserId] = nil
end

return ClickCalculationManager