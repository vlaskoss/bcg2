local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, remotesFolder, bindablesFolder = sharedFolder.Modules, sharedFolder.Remotes, sharedFolder.Bindables

local dataInitEvent = bindablesFolder.DataInitEvent
local settingUpdateEvent = remotesFolder.SettingUpdateEvent

local mainFrame = script.Parent.MainUI.MainFrame
local settingsFrame = mainFrame.Menus.SettingsFrame
local settingsFolder = settingsFrame.Holder.Settings

local gameUtils = require(modulesFolder.GameUtils)

local enabledImage = "rbxassetid://11419719540"
local disabledImage = "rbxassetid://11419709766"
local enabledColour = Color3.fromRGB(21, 126, 255)
local disabledColour = Color3.fromRGB(255, 17, 25)

local function toggleButton(button, setting)
    if not button or button.Interactable == false then return end
    
    local isEnabled = button.Image == enabledImage
    local newState = not isEnabled
    local targetImage = newState and enabledImage or disabledImage
    local targetColor = newState and enabledColour or disabledColour
    
    settingUpdateEvent:FireServer(setting, newState)
    button.Interactable = false
    
    gameUtils:Tween(button, {ImageTransparency = 1}, 0.1)
    task.wait(0.1)
    button.Visible = false
    button.Image = targetImage
    button.Visible = true
    gameUtils:Tween(button, {ImageTransparency = 0, ImageColor3 = targetColor}, 0.1)
    task.wait(0.1)
    button.Interactable = true
end


local function setupSettingButton(button, setting, previousSetting)
    if setting then
        if previousSetting == true then
            -- ui is automatically visually enabled, no need to do anything
        else
            button.Image = "rbxassetid://11419709766"
            button.ImageColor3 = Color3.fromRGB(255, 17, 25)
        end
        button.MouseButton1Click:Connect(function()
            toggleButton(button, setting)
        end)
    end
end

dataInitEvent.Event:Connect(function(data)
    -- validate if settings exist based on initial data
    local settingsTable = data.Settings
    for _, setting in pairs(settingsFolder:GetChildren()) do
        if setting:IsA("Frame") and setting.Name == "SettingFrame" then
            setupSettingButton(setting.SettingButton, setting:GetAttribute("Setting"), settingsTable[setting:GetAttribute("Setting")])
        end
    end
end)
