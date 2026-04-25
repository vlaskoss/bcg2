-- datainithandler.client.luau
-- handles server -> client and client -> client data initalised events, and sends a return event to the server to confirm that the user has recieved the event. if the return event is not recieved, the event from the server is fired repeatedly every 0.25s until so.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")

local sharedFolder = ReplicatedStorage.Shared
local remotesFolder, bindablesFolder = sharedFolder.Remotes, sharedFolder.Bindables

local dataInitEvent = remotesFolder.DataInitEvent
local dataInitReturnEvent = remotesFolder.DataInitReturnEvent

local dataInitBindable = bindablesFolder.DataInitEvent

local dataInitialisedValue = Instance.new("BoolValue")
dataInitialisedValue.Name = "DataInitialised"
dataInitialisedValue.Parent = PlayersService.LocalPlayer

local dataInitialised

dataInitEvent.OnClientEvent:Connect(function(data)
    if dataInitialised then return end
    dataInitialised = true
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end    
    dataInitReturnEvent:FireServer()
    dataInitBindable:Fire(data)
    dataInitialisedValue.Value = true
end)