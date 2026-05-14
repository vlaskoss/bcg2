local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modulesFolder = ServerStorage.Server.Modules
local sharedModulesFolder = ReplicatedStorage.Shared.Modules

local dataManager = require(modulesFolder.DataManager)
local gammaNum = require(sharedModulesFolder.GammaNum)

local TotalClicksManager = {}

function TotalClicksManager:UpdateClicksStatistic(player, amountToIncrease)
    local previousTotal = dataManager:GetStatistic(player, "TotalClicks")
    local newTotal = gammaNum.add(previousTotal, amountToIncrease)
    dataManager:SetStatistic(player, "TotalClicks", newTotal)
    previousTotal = nil
    newTotal = nil
end

function TotalClicksManager:UpdateClickedStatistic(player)
    local previousTotal = dataManager:GetStatistic(player, "TotalClicked")
    local newTotal = previousTotal + 1
    dataManager:SetStatistic(player, "TotalClicked", newTotal)
    previousTotal = nil
    newTotal = nil
end

function TotalClicksManager:UpdateAutoClickedStatistic(player)
    local previousTotal = dataManager:GetStatistic(player, "TotalAutoClicked")
    local newTotal = previousTotal + 1
    dataManager:SetStatistic(player, "TotalAutoClicked", newTotal)
    previousTotal = nil
    newTotal = nil
end

return TotalClicksManager