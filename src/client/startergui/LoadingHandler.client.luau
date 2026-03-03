local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local PlayersService = game:GetService("Players")
local TestService = game:GetService("TestService")


local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, bindablesFolder = sharedFolder.Modules, sharedFolder.Bindables

local dataInitEvent = bindablesFolder.DataInitEvent

local gameVersion = require(modulesFolder.GameVersion)
local gameUtils = require(modulesFolder.GameUtils)
local menuManager = require(modulesFolder.MenuManager)

local mainUI = script.Parent.MainUI
local clickButton, autoClickButton = mainUI.ClickButton, mainUI.AutoClickButton
local mainFrame = mainUI.MainFrame
local buttonsFolder = mainFrame.ButtonFrame.Buttons
local loadingLabel, versionLabel, gameLabel = mainFrame.LoadingLabel, mainFrame.VersionLabel, mainFrame.GameLabel
local clicksFrame = mainUI.MainFrame.ClicksFrame
local player = PlayersService.LocalPlayer

local dataInitialised = PlayersService.LocalPlayer:WaitForChild("DataInitialised")

local joinTime = os.date("%Y-%m-%d %H:%M:%S")

local uiDefaults = {
    [clickButton] = {ImageTransparency = 1, BackgroundTransparency = 1, Interactable = false},
    [autoClickButton] = {TextTransparency = 1, BackgroundTransparency = 1, Visible = false},
    [mainUI] = {Enabled = true},
    [loadingLabel] = {TextTransparency = 1, Visible = true},
    [versionLabel] = {TextTransparency = 1, Visible = true},
    [gameLabel] = {TextTransparency = 1, Visible = true},
    [clicksFrame] = {Visible = true, Position = UDim2.fromScale(0.5,-0.15)},
    [mainFrame] = {Visible = true}
}

local function timeoutCheck()
    task.wait(10)
    if dataInitialised then return end
    print("[LoadingHandler]: Data failed to initalise")
    loadingLabel.Text = "data failed to initialise :("
    task.wait(3.5)
    player:Kick("Your data failed to initalise in time.")
end

local function setupAutoClicker(level)
    if level >= 1 then
        autoClickButton.Visible = true
        gameUtils:Tween(autoClickButton, {BackgroundTransparency = 0}, 0.5)
        task.wait(0.5)
        gameUtils:Tween(autoClickButton, {TextTransparency = 0}, 0.75)
        autoClickButton.Interactable = true
    else
        autoClickButton.Visible = false
        autoClickButton.Interactable = false
    end
end

local coreCall do
	local maxRetries = 100
	function coreCall(method, ...)
		local result = {}
		for i = 1, maxRetries do
			result = {pcall(StarterGui[method], StarterGui, ...)}
			if result[1] then
				break
			end
			task.wait(1)
		end
		
		return unpack(result)
	end
end

TestService:Message(`Hi {player.Name}! Welcome to\n{gameUtils:GetASCII()}\n version {gameVersion.FullName}\n build {game.PlaceVersion}\n as at {joinTime}\n server uptime on join: {gameUtils:GetUptime()}`)                          

assert(coreCall("SetCore", "ResetButtonCallback", false))
assert(coreCall("SetCoreGuiEnabled", "All", false))
menuManager:DisableAllButtons(buttonsFolder)
versionLabel.Text = gameVersion.FullName

for obj, properties in uiDefaults do
    for property, value in properties do
        obj[property] = value
    end
end

gameUtils:Tween(loadingLabel, {TextTransparency = 0}, 0.5, 0.5)
gameUtils:Tween(versionLabel, {TextTransparency = 0}, 0.5, 0.5)


task.spawn(timeoutCheck)

dataInitEvent.Event:Connect(function(data)
    print("------------------DATA INITIALISED------------------")
    print("[LoadingHandler]: Data initalised")
    loadingLabel.Text = "data initalised!"
    task.wait(1)
    gameUtils:Tween(loadingLabel, {TextTransparency = 1}, 0.5, 0, true)
    task.wait(0.5)
    gameUtils:Tween(gameLabel, {TextTransparency = 0}, 0.5)
    gameUtils:Tween(versionLabel, {TextTransparency = 1}, 0.25, 0.25)
    task.wait(0.5)
    versionLabel.Size = UDim2.new(versionLabel.Size.X.Scale * 0.5, 0, versionLabel.Size.Y.Scale * 0.5, 0)
    gameUtils:Tween(gameLabel, {TextTransparency = 1}, 0.8)
    gameUtils:Tween(gameLabel.UIScale, {Scale = 67}, 1) 
    task.wait(0.5)
    gameUtils:Tween(gameLabel, {TextTransparency = 1}, 1, 0.25, true)
    gameUtils:Tween(versionLabel, {TextTransparency = 0}, 0.5, 0.25)
    task.wait(0.5)
    clickButton.Visible = true
    task.spawn(function()
        setupAutoClicker(data.Upgrades.AutoClicker)
    end)
    gameUtils:Tween(clicksFrame, {Position = UDim2.fromScale(0.5,0)}, 0.5)
    gameUtils:Tween(clickButton, {BackgroundTransparency = 0}, 0.5)
    task.wait(0.5)
    menuManager:EnableAllButtons(buttonsFolder)
    assert(coreCall("SetCoreGuiEnabled", "Chat", true))
    assert(coreCall("SetCoreGuiEnabled", "PlayerList", true))
    gameUtils:Tween(clickButton, {ImageTransparency = 0}, 0.75)

    clickButton.Interactable = true
    script:Destroy()
end)
