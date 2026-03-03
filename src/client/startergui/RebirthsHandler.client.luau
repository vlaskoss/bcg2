local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, remotesFolder, bindablesFolder, soundsFolder = sharedFolder.Modules, sharedFolder.Remotes, sharedFolder.Bindables, sharedFolder.Sounds

local dataUpdateEvent = remotesFolder.DataUpdateEvent
local rebirthEvent = remotesFolder.RebirthEvent
local rebirthSuccessEvent = remotesFolder.RebirthSuccessEvent
local sfxEvent = bindablesFolder.SFXEvent
local dataInitEvent = bindablesFolder.DataInitEvent

local mainFrame = script.Parent.MainUI.MainFrame
local rebirthsFrame = mainFrame.Menus.RebirthsFrame
local eligibilityLabel = rebirthsFrame.EligibilityLabel
local levelLabel = rebirthsFrame.LevelLabel
local rebirthButton = rebirthsFrame.RebirthButton

local rebirthSound = soundsFolder.Interactive.RebirthSound

local gameUtils = require(modulesFolder.GameUtils)
local menuManager = require(modulesFolder.MenuManager)

local currentLevel
local rebirthsAmount

rebirthButton.Visible = false

local function updateUI(data)
    rebirthsAmount = data.Rebirths
    currentLevel = data.Level

    levelLabel.Text = "You are currently level " .. gameUtils:FormatSeparators(currentLevel)
    
    local requiredLevel = gameUtils:CalcLevelRequired(rebirthsAmount)

    if currentLevel >= requiredLevel then
        eligibilityLabel.Text = "You are eligible to rebirth!"
        rebirthButton.Visible = true
    elseif currentLevel < requiredLevel then
        eligibilityLabel.Text = "You need to be level " .. gameUtils:FormatSeparators(requiredLevel) .. " to rebirth."
        rebirthButton.Visible = false
    end
end

dataInitEvent.Event:Connect(updateUI)
dataUpdateEvent.OnClientEvent:Connect(function(data, updatedCurrency)
    if updatedCurrency == "Level" or "Rebirths" then
        updateUI(data)
    end
end)

rebirthButton.MouseButton1Click:Connect(function()
    if currentLevel >= gameUtils:CalcLevelRequired(rebirthsAmount) then
        rebirthEvent:FireServer()
        print("[RebirthsHandler]: Rebirth request sent to server")
    end
end)

rebirthSuccessEvent.OnClientEvent:Connect(function()
    print("[RebirthsHandler]: Rebirth successful returned from server")
    menuManager:AnimateMenuClose(rebirthsFrame)
    sfxEvent:Fire(rebirthSound, 2, false)
end)