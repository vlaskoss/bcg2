local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, remotesFolder, bindablesFolder, soundsFolder = sharedFolder.Modules, sharedFolder.Remotes, sharedFolder.Bindables, sharedFolder.Sounds

local autoClickEvent = remotesFolder.AutoClickEvent
local dataUpdateEvent = remotesFolder.DataUpdateEvent
local rebirthSuccessEvent = remotesFolder.RebirthSuccessEvent
local sfxEvent = bindablesFolder.SFXEvent

local autoClickSound = soundsFolder.Interactive.AutoClickSound
local autoClickButton = script.Parent.MainUI.AutoClickButton

local gameUtils = require(modulesFolder.GameUtils)

local debounce = false
local isEligible
local isActive = true

autoClickButton.Visible = false

local function toggleAutoClicker()
    sfxEvent:Fire(autoClickSound, 2)
    if isActive then
        autoClickButton.Text = "AUTOCLICKER<br />off"
        autoClickEvent:FireServer("stop")
    else
        autoClickButton.Text = "AUTOCLICKER<br />on"
        autoClickEvent:FireServer("start")
    end
end

dataUpdateEvent.OnClientEvent:Connect(function(data, updatedCurrency)
    if updatedCurrency == "AutoClicker" then
        if data.Upgrades.AutoClicker >= 1 then
            if not isEligible then
                if autoClickButton.Visible == false then
                    isEligible = true
                    autoClickButton.BackgroundTransparency = 1
                    autoClickButton.TextTransparency = 1
                    autoClickButton.Visible = true
                    autoClickButton.Interactable = true
                    
                    gameUtils:Tween(autoClickButton, {BackgroundTransparency = 0, TextTransparency = 0}, 0.5)
                end
            end
        end
    end
end)

autoClickButton.MouseButton1Click:Connect(function()
    if debounce == false then
        debounce = true
        isActive = not isActive
        toggleAutoClicker()
        task.wait(0.5)
        debounce = false
    end
end)

rebirthSuccessEvent.OnClientEvent:Connect(function()
    if isActive then
        isActive = not isActive
        toggleAutoClicker()
    end
end)