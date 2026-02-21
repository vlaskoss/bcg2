local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local remotesFolder, modulesFolder = ReplicatedStorage.Shared.Remotes, ReplicatedStorage.Shared.Modules
local clickEvent = remotesFolder.ClickEvent
local dataUpdateEvent = remotesFolder.DataUpdateEvent
local dataInitEvent = remotesFolder.DataInitEvent
local clickFXEvent = remotesFolder.ClickFXEvent

local mainUI = script.Parent.MainUI
local textFrame, clicksFrame = mainUI.MainFrame.TextFrame, mainUI.MainFrame.ClicksFrame
local clicksLabel = clicksFrame.ClicksLabel

local dataInitialised = false
local debounce = false

local originalSize = mainUI.ClickButton.Size
local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true)

local gameUtils = require(modulesFolder.GameUtils)
local clickFXManager = require(modulesFolder.ClickFXManager)


local function updateText(clicks)
    clicksLabel.Text = "clicks: " .. gameUtils:FormatNum(clicks)
end

dataInitEvent.OnClientEvent:Connect(function(data)
    task.wait(0.5)
    print("[ClicksHandler]: Click-related functions are now enabled")
    dataInitialised = true
    updateText(data.Clicks)
end)

mainUI.ClickButton.MouseButton1Click:Connect(function()
    if dataInitialised then
        if not debounce then
            debounce = true
            clickEvent:FireServer()
            task.spawn(function()
                local tween = TweenService:Create(mainUI.ClickButton, tweenInfo, {Size = UDim2.new(originalSize.X.Scale* 1.05, 0, originalSize.Y.Scale * 1.05, 0)})
                tween:Play()
                clickFXManager:Display(textFrame)
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
    end
end)

clickFXEvent.OnClientEvent:Connect(function()
    clickFXManager:Display(textFrame)
end)