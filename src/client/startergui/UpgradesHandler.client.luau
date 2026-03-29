local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PlayersService = game:GetService("Players")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder = sharedFolder.Modules
local remotesFolder = sharedFolder.Remotes
local bindablesFolder = sharedFolder.Bindables
local soundsFolder = sharedFolder.Sounds

local dataUpdateEvent = remotesFolder.DataUpdateEvent
local upgradeEvent = remotesFolder.UpgradeEvent
local upgradeReturnEvent = remotesFolder.UpgradeReturnEvent
local sfxEvent = bindablesFolder.SFXEvent
local dataInitEvent = bindablesFolder.DataInitEvent

local purchaseSound = soundsFolder.Interactive.PurchaseSuccess
local errorSound = soundsFolder.Interactive.PurchaseUnsuccessful

local upgradeConfig = require(modulesFolder.UpgradeConfig)
local upgradeFormulas = require(modulesFolder.UpgradeFormulas)
local gameUtils = require(modulesFolder.GameUtils)
local gammaNum = require(modulesFolder.GammaNum)

local mainFrame = script.Parent.MainUI.MainFrame
local upgradesFrame = mainFrame.Menus.UpgradesFrame.Holder
local upgradeTemplate = script.Parent.UpgradeTemplate

local dataInitialised = PlayersService.LocalPlayer:WaitForChild("DataInitialised")

local upgradeState: {[string]: number} = {}
local reduceLevelCost
local cardConnections = {} -- Track connections for cleanup

local function getCost(upgradeKey, config, currentTier)
    if config.CostFormula then
        local formula = upgradeFormulas[upgradeKey]
        if formula then 
            return formula(currentTier)
        end
    end
    if config.Type == "Tiered" and config.Tiers then
        local tierData = config.Tiers[currentTier + 1]
        if tierData and tierData.Cost then
            return gameUtils:EnsureGammaNum(tierData.Cost)
        end
    end
    return gameUtils:EnsureGammaNum(config.Cost or 0)
end

local function getCurrentTier(upgradeKey, config)
    return upgradeState[config.RelatedStat] or upgradeState[upgradeKey] or 0
end

local function meetsRequirements(config)
    if config.RequiredUpgrade then
        local minTier = config.RequiredUpgradeTier or 1
        local reqTier = upgradeState[config.RequiredUpgrade] or 0
        if reqTier < minTier then return false end
    end
    if config.RequiredLevel then
        local level = upgradeState["Level"] or 0
        if level < config.RequiredLevel then return false end
    end
    return true
end

local function isMaxed(config, currentTier)
    if config.Type == "Finite"  and currentTier >= (config.MaxLevel or math.huge) then return true end
    if config.Type == "Single"  and currentTier == true                             then return true end
    if config.Type == "Tiered"  and currentTier >= (config.MaxTier or (config.Tiers and #config.Tiers) or math.huge) then return true end
    return false
end

local fadeDuration = 0.25
local fadeTweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function collectTransparencies(root)
    local targets = {}
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("GuiObject") then
            targets[#targets + 1] = { obj = obj, prop = "BackgroundTransparency" }
        end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            targets[#targets + 1] = { obj = obj, prop = "TextTransparency" }
        end
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            targets[#targets + 1] = { obj = obj, prop = "ImageTransparency" }
        end
        if obj:IsA("UIStroke") then
            targets[#targets + 1] = { obj = obj, prop = "Transparency" }
        end
    end
    return targets
end

local function getTransparencyGoal(obj, prop, isVisible)
    if not isVisible then return 1 end
    if prop == "TextTransparency" or prop == "ImageTransparency" then return 0 end
    if prop == "BackgroundTransparency" then
        if obj:IsA("TextButton") or obj:IsA("ImageButton") or obj:IsA("ImageLabel") then
            return 0
        end
        return 1
    end
    return 0
end

local function fadeCard(upgradeUI, isVisible)
    local targets = collectTransparencies(upgradeUI)
    local tweens = {}
    
    for _, entry in ipairs(targets) do
        local goal = getTransparencyGoal(entry.obj, entry.prop, isVisible)
        if isVisible then
            entry.obj[entry.prop] = 1
        end
        if goal < 1 or not isVisible then
            tweens[#tweens + 1] = TweenService:Create(entry.obj, fadeTweenInfo, { [entry.prop] = goal })
        end
    end
    
    for _, tween in ipairs(tweens) do tween:Play() end
end

local function getDisplayName(config, upgradeKey, nextTier, maxed)
    local tierData = config.Tiers and config.Tiers[nextTier]
    if tierData and tierData.DisplayName and tierData.DisplayName ~= "" then
        return tierData.DisplayName
    elseif typeof(config.DisplayName) == "function" then
        return config.DisplayName(maxed and getCurrentTier(upgradeKey, config) or nextTier)
    else
        return config.DisplayName or upgradeKey
    end
end

local function getDescription(config, nextTier)
    local tierData = config.Tiers and config.Tiers[nextTier]
    if config.Type == "Tiered" and tierData and tierData.Description then
        return tierData.Description
    end
    local desc = config.Description or "No description available."
    if config.IsPermanent then
        desc = "[PERMANENT] " .. desc
    end
    return desc
end

local function updateUI(upgradeUI, upgradeKey, config)
    if not dataInitialised then return end
    local currentTier = getCurrentTier(upgradeKey, config)
    if isMaxed(config, currentTier) then return end
    local nextTier    = currentTier + 1
    local maxed       = isMaxed(config, currentTier)

    local cost = getCost(upgradeKey, config, currentTier)
    local finalCost

    if upgradeKey == "Level" then
        local reductionMultiplier = gammaNum.div(gammaNum.sub(100, reduceLevelCost), 100)
        finalCost = gammaNum.mul(cost, reductionMultiplier)
    else
        finalCost = cost
    end

    if not upgradeUI:FindFirstChild("PurchaseButton") then return end

    upgradeUI.UpgradeNameLabel.Text  = getDisplayName(config, upgradeKey, nextTier, maxed)
    upgradeUI.InformationLabel.Text  = getDescription(config, nextTier)
    upgradeUI.CostLabel.Text         = "Cost: " .. gameUtils:FormatNum(finalCost) .. " clicks"
    upgradeUI.PurchaseButton.Visible = true
end


local function refreshCard(upgradeKey, config)
    local unlocked = meetsRequirements(config)
    local existing = upgradesFrame:FindFirstChild(upgradeKey)

    if not unlocked then
        if existing then 
            if cardConnections[upgradeKey] then
                cardConnections[upgradeKey]:Disconnect()
                cardConnections[upgradeKey] = nil
            end
            existing:Destroy() 
        end
        return
    end

    local currentTier = getCurrentTier(upgradeKey, config)
    if isMaxed(config, currentTier) then
        if existing then
            local cardToRemove = existing
            local btn = cardToRemove:FindFirstChild("PurchaseButton")
            if btn then btn.Interactable = false end
            task.spawn(function()
                fadeCard(cardToRemove, false)
                task.wait(0.5)
                if cardToRemove.Parent then
                    if cardConnections[upgradeKey] then
                        cardConnections[upgradeKey]:Disconnect()
                        cardConnections[upgradeKey] = nil
                    end
                    cardToRemove:Destroy()
                end
            end)
        end
        return 
    end

    if not existing then
        local upgradeUI       = upgradeTemplate:Clone()
        upgradeUI.Name        = upgradeKey
        upgradeUI.LayoutOrder = tonumber(config.Priority) or 100
        upgradeUI.Visible     = true
        upgradeUI.Parent      = upgradesFrame
        fadeCard(upgradeUI, true)

        if cardConnections[upgradeKey] then
            cardConnections[upgradeKey]:Disconnect()
        end
        cardConnections[upgradeKey] = upgradeUI.PurchaseButton.MouseButton1Down:Connect(function()
            upgradeUI.PurchaseButton.Interactable = false
            upgradeEvent:FireServer(upgradeKey)
            task.wait(0.1)
            if upgradeUI.Parent and upgradeUI:FindFirstChild("PurchaseButton") then
                upgradeUI.PurchaseButton.Interactable = true
            end
        end)
    end

    updateUI(upgradesFrame:FindFirstChild(upgradeKey), upgradeKey, config)
end

local function populateUpgrades()
    for _, child in ipairs(upgradesFrame:GetChildren()) do
        if child:IsA("Frame") and child ~= upgradeTemplate then
            child:Destroy()
        end
    end

    for upgradeKey, config in pairs(upgradeConfig) do
        refreshCard(upgradeKey, config)
    end
end

dataInitEvent.Event:Connect(function(data)
    if dataInitialised == "true" then return end
    for upgradeKey, tier in pairs(data.Upgrades) do
        local config = upgradeConfig[upgradeKey]
        upgradeState[upgradeKey] = tier
        if config and config.RelatedStat then
            upgradeState[config.RelatedStat] = tier
        end
    end
    if data.Upgrades and data.Upgrades["ReduceLevelCost"] then
        reduceLevelCost = data.Upgrades["ReduceLevelCost"]
    end
    if data.Level then
        upgradeState["Level"] = data.Level
    end

    populateUpgrades()
end)
 
dataUpdateEvent.OnClientEvent:Connect(function(newData, updatedStat, updateType)
    if not dataInitialised then return end

    if updateType == "upgrade" or updatedStat == "Rebirths" or updatedStat == "Level" then
        if updatedStat == "Level" and newData and newData.Level then
            upgradeState["Level"] = newData.Level
        end

        if updatedStat == "ReduceLevelCost" then
            reduceLevelCost = newData.Upgrades["ReduceLevelCost"]
        end

        if updatedStat == "Rebirths" then
            for upgradeKey, config in pairs(upgradeConfig) do
                if not config.IsPermanent then
                    upgradeState[upgradeKey] = nil
                    if config.RelatedStat then
                        upgradeState[config.RelatedStat] = nil
                    end
                end
            end
            upgradeState["Level"] = 0
        end

        for upgradeKey, config in pairs(upgradeConfig) do
            refreshCard(upgradeKey, config)
        end
    elseif updatedStat == "Clicks" then
        for _, child in ipairs(upgradesFrame:GetChildren()) do
            if child:IsA("Frame") and child ~= upgradeTemplate then
                local config = upgradeConfig[child.Name]
                if config then updateUI(child, child.Name, config) end
            end
        end
    end
end)

upgradeReturnEvent.OnClientEvent:Connect(function(upgradeKey, success, newTierOrReason)
    if not success then
        sfxEvent:Fire(errorSound, 1, false)
        local card = upgradesFrame:FindFirstChild(upgradeKey)
        if card and card:FindFirstChild("PurchaseButton") then
            card.PurchaseButton.Text             = tostring(newTierOrReason or "failed")
            card.PurchaseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            task.wait(0.5)
            if card.Parent and card:FindFirstChild("PurchaseButton") then
                card.PurchaseButton.Text             = "Purchase"
                card.PurchaseButton.BackgroundColor3 = Color3.fromRGB(53, 136, 9)
            end
        end
        return
    end

    local config = upgradeConfig[upgradeKey]
    if not config then return end

    local newTier = newTierOrReason
    if config.RelatedStat then
        upgradeState[config.RelatedStat] = newTier
    end
    upgradeState[upgradeKey] = newTier

    sfxEvent:Fire(purchaseSound, 1, false)

    refreshCard(upgradeKey, config)

    for otherKey, otherConfig in pairs(upgradeConfig) do
        if otherConfig.RequiredUpgrade == upgradeKey then
            refreshCard(otherKey, otherConfig)
        end
    end

    if upgradeKey == "ReduceLevelCost" then
        local levelCard = upgradesFrame:FindFirstChild("Level")
        if levelCard then
            updateUI(levelCard, "Level", upgradeConfig["Level"])
        end
    end
end)
