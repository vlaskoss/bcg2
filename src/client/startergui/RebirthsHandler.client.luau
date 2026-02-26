local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, remotesFolder, bindablesFolder, soundsFolder = sharedFolder.Modules, sharedFolder.Remotes, sharedFolder.Bindables, sharedFolder.Sounds

local dataInitEvent = remotesFolder.DataInitEvent
local dataUpdateEvent = remotesFolder.DataUpdateEvent
local rebirthEvent = remotesFolder.RebirthEvent
local rebirthSuccessEvent = remotesFolder.RebirthSuccessEvent
local sfxEvent = bindablesFolder.SFXEvent

local mainFrame = script.Parent.MainUI.MainFrame
local rebirthsFrame = mainFrame.Menus.RebirthsFrame
local eligibilityLabel = rebirthsFrame.EligibilityLabel
local levelLabel = rebirthsFrame.LevelLabel
local rebirthButton = rebirthsFrame.RebirthButton

local rebirthSound = soundsFolder.Interactive.RebirthSound

local gameUtils = require(modulesFolder.GameUtils)

local currentLevel
local rebirthsAmount

rebirthButton.Visible = false

local function updateUI(data)
    rebirthsAmount = data.Rebirths
    currentLevel = data.Level

    levelLabel.Text = "You are currently level " .. currentLevel
    
    local requiredLevel = gameUtils:CalcLevelRequired(rebirthsAmount)

    if currentLevel >= requiredLevel then
        eligibilityLabel.Text = "You are eligible to rebirth!"
        rebirthButton.Visible = true
    elseif currentLevel < requiredLevel then
        eligibilityLabel.Text = "You need to be level " .. requiredLevel .. " to rebirth."
    end
end

dataInitEvent.OnClientEvent:Connect(updateUI)
dataUpdateEvent.OnClientEvent:Connect(function(data, updatedCurrency)
    if updatedCurrency == "Level" or "Rebirths" then
        updateUI(data)
    end
end)

rebirthButton.MouseButton1Click:Connect(function()
    if currentLevel >= gameUtils:CalcLevelRequired(rebirthsAmount) then
        rebirthEvent:FireServer()
    end
end)

rebirthSuccessEvent.OnClientEvent:Connect(function()
    sfxEvent:Fire(rebirthSound, 2, false)
end)