local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bindablesFolder = ReplicatedStorage.Shared.Bindables

local dataInitEvent = bindablesFolder.DataInitEvent

local cmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))

dataInitEvent.Event:Connect(function()
    cmdrClient:SetActivationKeys({Enum.KeyCode.RightAlt})
end)