local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, bindablesFolder = sharedFolder.Modules, sharedFolder.Bindables

local dataInitBindable = bindablesFolder.DataInitEvent

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

local dataInitialised = PlayersService.LocalPlayer:WaitForChild("DataInitialised")
local isOpen = false
local debounce = false
local uptimeUpdateThread

local function tweenText(parent, value)
    for _, child in pairs(parent:GetDescendants()) do
        if child:IsA("TextLabel") then
            gameUtils:Tween(child, {TextTransparency = value}, 0.3)
        end
    end
end

local function updateUptime()
    if dataInitialised.Value == true then
        local uptime = gameUtils:GetUptime()
        uptimeLabel.Text = "Server uptime: "  .. uptime
    end
end

local function startUptimeUpdates()
    if uptimeUpdateThread then return end
    uptimeUpdateThread = task.spawn(function()
        while isOpen and dataInitialised.Value do
            updateUptime()
            task.wait(1)
        end
        uptimeUpdateThread = nil
    end)
end

local function stopUptimeUpdates()
    if uptimeUpdateThread then
        uptimeUpdateThread = nil
    end
end

local function toggleFrame()
    if not debounce then
        if dataInitialised.Value == true then
            debounce = true
            if isOpen then
                stopUptimeUpdates()
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
                if menuManager:IsMenuOpen(menusFolder) then
                    menuManager:CloseAllMenus(menusFolder)
                    task.wait(0.35)
                end
                versionFrame.Visible = true
                coverFrame.Visible = true
                tweenText(versionFrame, 0)
                gameUtils:Tween(versionFrame, {BackgroundTransparency = 0}, 0.3)
                gameUtils:Tween(clickButton, {BackgroundTransparency = 1, ImageTransparency = 1}, 0.3)
                gameUtils:Tween(autoClickButton, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
                gameUtils:Tween(coverFrame, {BackgroundTransparency = 0.1}, 0.3)
                startUptimeUpdates()
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

dataInitBindable.Event:Connect(function()
    tweenText(versionFrame, 1)
    coverFrame.BackgroundTransparency = 1
    versionFrame.BackgroundTransparency = 1
    versionFrame.Visible = false
    coverFrame.Visible = false
    buildLabel.Text = "Build " .. game.PlaceVersion
    versionLabel.Text = "BCG (basic clicking game) - " .. gameVersion.FullName
    task.wait(5)
end)

coverFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isOpen then
            toggleFrame()
        end
    end
end)

versionButton.MouseButton1Click:Connect(toggleFrame)

-- Initial uptime display when data is loaded
dataInitBindable.Event:Connect(function()
    updateUptime()
end)


