local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, remotesFolder, bindablesFolder = sharedFolder.Modules, sharedFolder.Remotes, sharedFolder.Bindables

local dataInitEvent = remotesFolder.DataInitEvent

local gameUtils = require(modulesFolder.GameUtils)
local gameVersion = require(modulesFolder.GameVersion)
local menuManager = require(modulesFolder.MenuManager)

local mainUI = script.Parent.MainUI
local mainFrame = mainUI.MainFrame
local coverFrame = mainFrame.CoverFrame
local versionFrame = mainFrame.VersionFrame
local buttonsFolder = mainFrame.ButtonFrame.Buttons
local menusFolder = mainFrame.Menus
local versionButton = mainFrame.VersionLabel
local clickButton, autoClickButton = mainUI.ClickButton, mainUI.AutoClickButton
local buildLabel, uptimeLabel, versionLabel = versionFrame.BuildLabel, versionFrame.UptimeLabel, versionFrame.VersionLabel

local dataInitialised = false
local isOpen = false
local debounce = false

local function tweenText(parent, value)
    for _, child in pairs(parent:GetDescendants()) do
        if child:IsA("TextLabel") then
            gameUtils:Tween(child, {TextTransparency = value}, 0.3)
        end
    end
end

local function toggleFrame()
    if not debounce then
        if dataInitialised == true then
            debounce = true
            if isOpen then
                autoClickButton.Interactable = true
                clickButton.Interactable = true
                menuManager:EnableAllButtons(buttonsFolder)
                local mainTween = gameUtils:Tween(versionFrame, {BackgroundTransparency = 1}, 0.3)
                gameUtils:Tween(clickButton, {BackgroundTransparency = 0, ImageTransparency = 0}, 0.3)
                gameUtils:Tween(autoClickButton, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
                gameUtils:Tween(coverFrame, {BackgroundTransparency = 1}, 0.3)
                tweenText(versionFrame, 1)
                mainTween.Completed:Connect(function()
                    versionFrame.Visible = false
                    coverFrame.Visible = false
                end)
            else
                autoClickButton.Interactable = false
                clickButton.Interactable = false
                menuManager:DisableAllButtons(buttonsFolder)
                menuManager:CloseAllMenus(menusFolder)
                versionFrame.Visible = true
                coverFrame.Visible = true
                tweenText(versionFrame, 0)
                gameUtils:Tween(versionFrame, {BackgroundTransparency = 0}, 0.3)
                gameUtils:Tween(clickButton, {BackgroundTransparency = 1, ImageTransparency = 1}, 0.3)
                gameUtils:Tween(autoClickButton, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
                gameUtils:Tween(coverFrame, {BackgroundTransparency = 0.1}, 0.3)
            end
            isOpen = not isOpen
            task.wait(0.5)
            debounce = false
        else
            print("[VersionInfoHandler]: Player has not loaded yet") 
            return
        end
    end
end

dataInitEvent.OnClientEvent:Connect(function()
    tweenText(versionFrame, 1)
    coverFrame.BackgroundTransparency = 1
    versionFrame.BackgroundTransparency = 1
    versionFrame.Visible = false
    coverFrame.Visible = false
    buildLabel.Text = "Build " .. game.PlaceVersion
    versionLabel.Text = "BCG (basic clicking game) - " .. gameVersion.FullName
    task.wait(5)
    dataInitialised = true
end)

coverFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isOpen then
            toggleFrame()
        end
    end
end)

versionButton.MouseButton1Click:Connect(toggleFrame)

while task.wait(1) do
    if dataInitialised == true then
        local uptime = gameUtils:GetASCII()
        uptimeLabel.Text = "Server uptime: "  .. uptime
    end
end


