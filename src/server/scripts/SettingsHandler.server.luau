local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local sharedFolder, serverFolder = ReplicatedStorage.Shared, ServerStorage.Server
local remotesFolder = sharedFolder.Remotes
local modulesFolder = serverFolder.Modules

local settingUpdateEvent = remotesFolder.SettingUpdateEvent

local dataManager = require(modulesFolder.DataManager)
local saveTemplate = require(modulesFolder.SaveTemplate)

settingUpdateEvent.OnServerEvent:Connect(function(player, setting, value)
    if not player then return end
    if not saveTemplate.Settings[setting] then return end
    dataManager:SetSetting(player, setting, value)
end)