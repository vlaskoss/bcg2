local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local sharedFolder = ReplicatedStorage.Shared
local soundsFolder = sharedFolder.Sounds.sixseven

local dataUpdateEvent = sharedFolder.Remotes.DataUpdateEvent
local sfxEvent = sharedFolder.Bindables.SFXEvent
local stopSFXEvent = sharedFolder.Bindables.StopSFXEvent

local gammaNum = require(sharedFolder.Modules.GammaNum)

local defaultRandom = Random.new()

local debounce = false

local function randomColor(random: Random?)
    local rng = random or defaultRandom
    return Color3.new(rng:NextNumber(), rng:NextNumber(), rng:NextNumber())
end

local function setUpUI()
    local TextUI = Instance.new("ScreenGui")
    TextUI.Name = "TextUI"
    TextUI.IgnoreGuiInset = true
    TextUI.Parent = PlayersService.LocalPlayer.PlayerGui
    return TextUI
end

local function createText(parent: ScreenGui, text)
    local label = Instance.new("TextLabel")
    label.Parent = parent

	label.Position = UDim2.new(
		math.random(0, 100) / 100, 
		0,
		math.random(0, 100) / 100, 
		0
	)
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Size = UDim2.new(0.2, 0, 0.1, 0)   

	label.Text = text
	label.TextScaled = true
	label.TextColor3 = randomColor()
	label.BackgroundTransparency = 1
	label.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
	
    return label
end

local messages = {
    "67",
    "six sevenn",
    "MANGOS",
    "mustardddddddddddd"
}

local screenUI = setUpUI()

dataUpdateEvent.OnClientEvent:Connect(function(data, updatedCurrency)
    if debounce == false then
        if updatedCurrency == "Clicks" then
            if gammaNum.eq(data[updatedCurrency], 67) then
                sfxEvent:Fire(soundsFolder.sixseven, 10, true, soundsFolder.sixseven.Name)
               task.wait(2)
               print("[67Handler]: SIX SEVENNNNN!!!")
               for i,v in pairs(soundsFolder:GetChildren()) do
                    task.wait()
                    task.spawn(function()
                        sfxEvent:Fire(v, 10, true, v.Name)
                    end)
                end
                for i=1, 1000 do
                    task.wait()
                    local randMsg = messages[math.random(1, #messages)]
                    createText(screenUI, randMsg)
                end
                task.wait(5)
                for i,v in pairs(soundsFolder:GetChildren()) do
                    task.wait()
                    stopSFXEvent:Fire(v.Name)
                end
                screenUI:ClearAllChildren()
                debounce = true
                task.wait(10)
                debounce = false
            end
        end
    end
end)