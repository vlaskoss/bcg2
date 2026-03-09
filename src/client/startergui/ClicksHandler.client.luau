local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PlayersService = game:GetService("Players")

local remotesFolder, modulesFolder, bindablesFolder = ReplicatedStorage.Shared.Remotes, ReplicatedStorage.Shared.Modules, ReplicatedStorage.Shared.Bindables
local soundsFolder = ReplicatedStorage.Shared.Sounds
local clickEvent = remotesFolder.ClickEvent
local dataUpdateEvent = remotesFolder.DataUpdateEvent
local clickFXEvent = remotesFolder.ClickFXEvent
local sfxEvent = bindablesFolder.SFXEvent
local dataInitEvent = bindablesFolder.DataInitEvent

local mainUI = script.Parent.MainUI
local textFrame, clicksFrame = mainUI.MainFrame.TextFrame, mainUI.MainFrame.ClicksFrame
local clicksLabel = clicksFrame.ClicksLabel

local dataInitialised = PlayersService.LocalPlayer:WaitForChild("DataInitialised")
local debounce = false

local originalSize = mainUI.ClickButton.Size
local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true)

local gameUtils = require(modulesFolder.GameUtils)
local clickFXManager = require(modulesFolder.ClickFXManager)

local vfxEnabled 

local function updateText(clicks)
    clicksLabel.Text = "clicks: " .. gameUtils:FormatNum(clicks)
end

dataInitEvent.Event:Connect(function(data)
    task.wait(0.5)
    print("[ClicksHandler]: Click-related functions are now enabled")
    dataInitialised = true
    updateText(data.Clicks)
    vfxEnabled = data.Settings.VFX
end)

mainUI.ClickButton.MouseButton1Click:Connect(function()
    if dataInitialised then
        if not debounce then
            debounce = true
            clickEvent:FireServer()
            task.spawn(function()
                local tween = TweenService:Create(mainUI.ClickButton, tweenInfo, {Size = UDim2.new(originalSize.X.Scale* 1.05, 0, originalSize.Y.Scale * 1.05, 0)})
                tween:Play()
                if vfxEnabled then
                    clickFXManager:Display(textFrame)                    
                end
                sfxEvent:Fire(soundsFolder.Interactive.ClickSound, 2)
            end)
            task.wait(0.1)
            debounce = false
        end
    else
        warn("[ClicksHandler]: Data not initalised? im sure this is impossible lol")
    end
end)

dataUpdateEvent.OnClientEvent:Connect(function(data, updatedCurrency)
    if updatedCurrency == "Clicks" then
        updateText(data[updatedCurrency])
    elseif updatedCurrency == "VFX" then
        vfxEnabled = data.Settings.VFX
    end
end)

clickFXEvent.OnClientEvent:Connect(function()
    sfxEvent:Fire(soundsFolder.Interactive.ClickSound, 2)
    if not vfxEnabled then return end
    clickFXManager:Display(textFrame)
end)