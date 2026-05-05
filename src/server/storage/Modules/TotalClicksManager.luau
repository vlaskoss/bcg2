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

return TotalClicksManager