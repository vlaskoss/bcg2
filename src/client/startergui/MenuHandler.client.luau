local ReplicatedStorage = game:GetService("ReplicatedStorage")

local buttonsFolder = script.Parent.MainUI.MainFrame.ButtonFrame.Buttons
local menusFolder = script.Parent.MainUI.MainFrame.Menus

local dataInitEvent = ReplicatedStorage.Shared.Bindables.DataInitEvent

local menuManager = require(ReplicatedStorage.Shared.Modules.MenuManager)

dataInitEvent.Event:Connect(function()
    menuManager:SetupButton(buttonsFolder.UpgradesButton, menusFolder.UpgradesFrame)
    menuManager:SetupButton(buttonsFolder.ShopButton, menusFolder.ShopFrame)
    menuManager:SetupButton(buttonsFolder.SettingsButton, menusFolder.SettingsFrame)
    menuManager:SetupButton(buttonsFolder.RebirthsButton, menusFolder.RebirthsFrame)
end)
