local ClickFXManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder = sharedFolder.Modules

local player = PlayersService.LocalPlayer

local gameUtils = require(modulesFolder.GameUtils)

local function createText(parent: Frame, text)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    local randomX = math.random(10, 90) / 100
    local randomY = math.random(10, 90) / 100
    label.Position = UDim2.fromScale(randomX, randomY)
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Size = UDim2.new(0.2, 0, 0.1, 0) 
    label.Text = text
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium)
    label.TextTransparency = 1
    CollectionService:AddTag(label, "VFX")
    return label
end

local messages = {
    "wow so good clicking",
    "OMG such skill",
    "plz autograph?",
    `im so jealous of {player.Name}`
}

function ClickFXManager:Display(textFrame)
    local randMsg = messages[math.random(1, #messages)]
    local text = createText(textFrame, randMsg)
    gameUtils:Tween(text, {TextTransparency = 0}, 0.5)
    task.spawn(function()
       task.wait(3)
       gameUtils:Tween(text, {TextTransparency = 1}, 0.3)
       task.wait(0.4) 
       text:Destroy()
    end)
end

return ClickFXManager