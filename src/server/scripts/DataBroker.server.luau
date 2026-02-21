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

dataUpdateBindable.Event:Connect(function(data, player, updatedCurrency, type)
    dataUpdateEvent:FireClient(player, data, updatedCurrency, type)
end)

remoteDataFunction.OnServerInvoke = function(player, dataType, key)
    print(`[DataBroker]: Data requested by {player}, type {dataType}, key {key}`)
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