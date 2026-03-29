debug.setmemorycategory("Data")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")


local serverFolder = ServerStorage.Server
local modulesFolder, bindablesFolder = serverFolder.Modules, serverFolder.BindableEvents
local remotesFolder = ReplicatedStorage.Shared.Remotes

local remoteDataFunction = remotesFolder.RetrieveData
local dataUpdateEvent = remotesFolder.DataUpdateEvent
local dataUpdateBindable = bindablesFolder.DataUpdateBindable

local dataManager = require(modulesFolder.DataManager)
local debugUtils = require(ReplicatedStorage.Shared.Modules.DebugUtils)

dataUpdateBindable.Event:Connect(function(player, data, updatedCurrency, currencyType)
    dataUpdateEvent:FireClient(player, data, updatedCurrency, currencyType)
end)

remoteDataFunction.OnServerInvoke = function(player, dataType, key)
    debugUtils:Log(`[DataBroker]: Data requested by {player}, type {dataType}, key {key}`)
    if key ~= nil then
        if dataType == "Upgrade" then
            return dataManager:GetUpgrade(player, key)
        else
            return dataManager:RetrieveAmount(player, dataType)
        end
    else
        return dataManager:RetrieveAmount(player, dataType)
    end
end