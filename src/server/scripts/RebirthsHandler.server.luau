local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local serverFolder, sharedFolder = ServerStorage.Server, ReplicatedStorage.Shared
local remotesFolder, sharedModulesFolder = sharedFolder.Remotes, sharedFolder.Modules
local modulesFolder = serverFolder.Modules

local rebirthEvent = remotesFolder.RebirthEvent
local rebirthSuccessEvent = remotesFolder.RebirthSuccessEvent

local autoClickManager = require(modulesFolder.AutoClickManager)
local dataManager = require(modulesFolder.DataManager)
local saveTemplate = require(modulesFolder.SaveTemplate)
local upgradeConfig = require(sharedModulesFolder.UpgradeConfig)
local gameUtils = require(sharedModulesFolder.GameUtils)
local gammaNum = require(sharedModulesFolder.GammaNum)

rebirthEvent.OnServerEvent:Connect(function(player)
    local dataTable = dataManager:RetrieveAmount(player)
    if dataTable.Level >= gameUtils:CalcLevelRequired(dataTable.Rebirths) then
        autoClickManager:StopAutoClick(player.UserId)
        dataManager:AddCurrency(player, "Rebirths", 1)
        dataManager:SetCurrency(player, "Level", saveTemplate.Level)
        dataManager:SetCurrency(player, "Clicks", gammaNum.fromNumber(10))

        for upgrade, key in pairs(upgradeConfig) do
            if key then
                if not key.IsPermanent then
                    dataManager:SetUpgrade(player, upgrade, saveTemplate.Upgrades[upgrade])
                end
            end
        end
        rebirthSuccessEvent:FireClient(player)
    end
end)