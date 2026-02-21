local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, remotesFolder, bindablesFolder, soundsFolder = sharedFolder.Modules, sharedFolder.Remotes, sharedFolder.Bindables, sharedFolder.Sounds

local dataInitEvent = remotesFolder.DataInitEvent
local dataUpdateEvent = remotesFolder.DataUpdateEvent
local rebirthEvent = remotesFolder.RebirthEvent
local SFXEvent = bindablesFolder.SFXEvent

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

local function calcLevelRequired(currentRebirths)
    return math.round(100 * (1.25 ^ currentRebirths))
end

local function updateUI(data)
    rebirthsAmount = data.Rebirths
    currentLevel = data.Level

    levelLabel.Text = "You are currently level " .. currentLevel
    
    local requiredLevel = calcLevelRequired(rebirthsAmount)

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
    if currentLevel >= calcLevelRequired(rebirthsAmount) then
        rebirthEvent:FireServer()
        SFXEvent:Fire(rebirthSound, 1, false)
    end
end)
