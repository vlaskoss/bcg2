local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage.Shared
local remotesFolder, bindablesFolder = sharedFolder.Remotes, sharedFolder.Bindables

local dataInitEvent = bindablesFolder.DataInitEvent
local dataUpdateEvent = remotesFolder.DataUpdateEvent

local vfxEnabled

local function removeVFX()
    local vfxObjects = CollectionService:GetTagged("VFX")
    for _, object in pairs(vfxObjects) do
        if object:IsA("GuiObject") then
            object:Destroy()
        end
    end
end

dataInitEvent.Event:Connect(function(data)
    vfxEnabled = data.Settings.VFX
    if not vfxEnabled then removeVFX() end
end)

dataUpdateEvent.OnClientEvent:Connect(function(data, updatedCurrency)
    if updatedCurrency == "VFX" then
        vfxEnabled = data.Settings[updatedCurrency]
        if not vfxEnabled then removeVFX() end
    end
end)