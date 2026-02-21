local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local serverFolder, sharedFolder = ServerStorage.Server, ReplicatedStorage.Shared
local remotesFolder, sharedModulesFolder = sharedFolder.Remotes, sharedFolder.Modules
local modulesFolder = serverFolder.Modules

local rebirthEvent = remotesFolder.RebirthEvent

local dataManager = require(modulesFolder.DataManager)
local saveTemplate = require(modulesFolder.SaveTemplate)
local upgradeConfig = require(sharedModulesFolder.UpgradeConfig)
local gammaNum = require(sharedModulesFolder.GammaNum)

local function calcLevelRequired(currentRebirths)
    return math.round(100 * (1.25 ^ currentRebirths))
end

rebirthEvent.OnServerEvent:Connect(function(player)
    local dataTable = dataManager:RetrieveAmount(player)
    if dataTable.Level >= calcLevelRequired(dataTable.Rebirths) then
        print("Player is eligible to rebirth, they are level " .. dataTable.Level .. " and to rebirth requires level " ..  calcLevelRequired(dataTable.Rebirths))
        dataManager:AddCurrency(player, "Rebirths", 1)
        dataManager:SetCurrency(player, "Level", saveTemplate.Level)
        dataManager:SetCurrency(player, "Clicks", gammaNum.fromNumber(10))

        for upgrade, key in pairs(upgradeConfig) do
            if key then
                if not key.IsPermanent then
                    print(key.IsPermanent)
                    dataManager:SetUpgrade(player, upgrade, saveTemplate.Upgrades[upgrade])
                end
            end
        end
    end
end)