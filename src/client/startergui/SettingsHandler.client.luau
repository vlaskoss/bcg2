local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, remotesFolder = sharedFolder.Modules, sharedFolder.Remotes

local dataInitEvent = remotesFolder.DataInitEvent
local dataUpdateEvent = remotesFolder.DataUpdateEvent
local settingUpdateEvent = remotesFolder.SettingUpdateEvent

local mainFrame = script.Parent.MainUI.MainFrame
local settingsFrame = mainFrame.Menus.SettingsFrame
local settingsFolder = settingsFrame.Holder.Settings

local gameUtils = require(modulesFolder.GameUtils)

local function toggleButton(button, setting)
    if not button then return end
    if button.Interactable == false then return end
    if button.Image == "rbxassetid://11419719540" then
        settingUpdateEvent:FireServer(setting, false)
        button.Interactable = false
        gameUtils:Tween(button, {ImageTransparency = 1, ImageColor3 = Color3.fromRGB(255,255,255)}, 0.1)
        task.wait(0.1)
        button.Visible = false
        button.Image = "rbxassetid://11419709766"
        button.Visible = true
        gameUtils:Tween(button, {ImageTransparency = 0, ImageColor3 = Color3.fromRGB(255, 17, 25)}, 0.1)
        task.wait(0.1)
        button.Interactable = true
    elseif button.Image == "rbxassetid://11419709766" then   
        settingUpdateEvent:FireServer(setting, true)
        button.Interactable = false
        gameUtils:Tween(button, {ImageTransparency = 1, ImageColor3 = Color3.fromRGB(255,255,255)}, 0.1)
        task.wait(0.1)
        button.Visible = false
        button.Image = "rbxassetid://11419719540"
        button.Visible = true
        gameUtils:Tween(button, {ImageTransparency = 0, ImageColor3 = Color3.fromRGB(21, 126, 255)}, 0.1)
        task.wait(0.1)
        button.Interactable = true
    end
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

dataInitEvent.OnClientEvent:Connect(function(data)
    -- validate if settings exist based on initial data
    local settingsTable = data.Settings
    for _, setting in pairs(settingsFolder:GetChildren()) do
        if setting:IsA("Frame") and setting.Name == "SettingFrame" then
            setupSettingButton(setting.SettingButton, setting:GetAttribute("Setting"), settingsTable[setting:GetAttribute("Setting")])
        end
    end
end)
