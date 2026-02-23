local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = ReplicatedStorage.Shared
local modulesFolder, remotesFolder, bindablesFolder, soundsFolder = sharedFolder.Modules, sharedFolder.Remotes, sharedFolder.Bindables, sharedFolder.Sounds

local dataUpdateEvent = remotesFolder.DataUpdateEvent
local dataInitEvent = remotesFolder.DataInitEvent
local upgradeEvent = remotesFolder.UpgradeEvent
local sfxEvent = bindablesFolder.SFXEvent

local purchaseSound = soundsFolder.Interactive.PurchaseSuccess
local errorSound = soundsFolder.Interactive.PurchaseUnsuccessful

local upgradeConfig = require(modulesFolder.UpgradeConfig)
local gameUtils = require(modulesFolder.GameUtils)
local gammaNum = require(modulesFolder.GammaNum)

local mainFrame = script.Parent.MainUI.MainFrame
local upgradesFrame = mainFrame.Menus.UpgradesFrame.Holder
local upgradeTemplate = script.Parent.UpgradeTemplate

local formulaFolder = modulesFolder.UpgradeFormulas

local dataInitialised = false 
local dataCache = {}

local nestedTables = {Upgrades = true, Statistics = false, Settings = false}

local function flattenInto(target, source)
    for key, value in pairs(source) do
        if nestedTables[key] and type(value) == "table" then
            for innerKey, innerValue in pairs(value) do
                target[innerKey] = innerValue
            end
        else
            target[key] = value
        end
    end
end


local function getCost(config, level)
    if config.CostFormula then
        local module = formulaFolder:FindFirstChild(config.CostFormula)
        if module then
            return require(module)(level)
        end
    end
    
    if config.Type == "Tiered" and config.Tiers then
        local tier = config.Tiers[level + 1]
        if tier then
            return gameUtils:EnsureGammaNum(tier.Cost)
        end
    end
    
    return gameUtils:EnsureGammaNum(config.Cost or 0)
end

local function updateUI(upgradeUI, upgradeKey, data)
    if not dataInitialised then return end 
    
    local currentLevel = dataCache[data.RelatedStat] or 0
    local nextLevel = currentLevel + 1
    local nextCost = getCost(data, currentLevel)
    if upgradeKey == "Level" then
        local finalCostReduction = gammaNum.div(gammaNum.sub(gammaNum.fromNumber(100), gammaNum.fromNumber(dataCache.ReduceLevelCost)), gammaNum.fromNumber(100))
        nextCost = gammaNum.mul(getCost(data, currentLevel), finalCostReduction)
    end
    
    local isMaxed = false
    if data.Type == "Finite" and currentLevel >= data.MaxLevel then
        isMaxed = true
    elseif data.Type == "Single" and currentLevel >= 1 then
        isMaxed = true
    elseif data.Type == "Tiered" then
        if data.MaxTier and currentLevel >= data.MaxTier then
            isMaxed = true
        elseif not data.MaxTier and (not data.Tiers or currentLevel >= #data.Tiers) then
            isMaxed = true
        end
    end

    local displayDescription = data.Description 
    local tierData = data.Tiers and data.Tiers[nextLevel]
    
    if data.Type == "Tiered" and tierData and tierData.Description then
        displayDescription = tierData.Description
    end

    local finalName = ""
    if tierData and tierData.DisplayName and tierData.DisplayName ~= "" then
        finalName = tierData.DisplayName
    elseif typeof(data.DisplayName) == "function" then
        if isMaxed then
            finalName = data.DisplayName(currentLevel)
        else
            finalName = data.DisplayName(nextLevel)
        end
    else
        finalName = data.DisplayName or upgradeKey
    end

    if data.IsPermanent then
        displayDescription = displayDescription .. " [PERMANENT]"
    end

    upgradeUI.UpgradeNameLabel.Text = finalName
    upgradeUI.CostLabel.Text = isMaxed and "MAXED" or "Cost: " .. gameUtils:FormatNum(nextCost) .. " clicks"
    upgradeUI.InformationLabel.Text = displayDescription or "no description available :("
    upgradeUI.PurchaseButton.Visible = not isMaxed
end

local function createUpgradeUI(upgradeKey, data)
    local upgradeUI = upgradeTemplate:Clone()
    upgradeUI.Name = upgradeKey
    upgradeUI.LayoutOrder = tonumber(data.Priority) or 100 

    updateUI(upgradeUI, upgradeKey, data)

    upgradeUI.Visible = true
    upgradeUI.Parent = upgradesFrame

    upgradeUI.PurchaseButton.MouseButton1Down:Connect(function()
        local currentLevel = dataCache[data.RelatedStat] or 0
        local nextCost = getCost(data, currentLevel)
        local currentClicks = gameUtils:EnsureGammaNum(dataCache.Clicks)
        
        if upgradeKey == "Level" then
            local finalCostReduction = gammaNum.div(gammaNum.sub(gammaNum.fromNumber(100), gammaNum.fromNumber(dataCache.ReduceLevelCost)), gammaNum.fromNumber(100))
            nextCost = gammaNum.mul(getCost(data, currentLevel), finalCostReduction)
        end
        if gammaNum.gte(currentClicks, nextCost) then
            upgradeEvent:FireServer(upgradeKey)
            sfxEvent:Fire(purchaseSound, 1, false)
            dataCache[data.RelatedStat] = currentLevel + 1
            dataCache.Clicks = gammaNum.sub(currentClicks, nextCost)
            updateUI(upgradeUI, upgradeKey, data)
            if upgradeKey == "ReduceLevelCost" then
                local levelFrame = upgradesFrame:FindFirstChild("Level")
                local levelConfig = upgradeConfig["Level"]
                if levelFrame and levelConfig then
                    updateUI(levelFrame, "Level", levelConfig)
                end
            end
        else
            sfxEvent:Fire(errorSound, 1, false)
            upgradeUI.PurchaseButton.Text = "no money :("
            upgradeUI.PurchaseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            task.wait(0.5)
            upgradeUI.PurchaseButton.Text = "Purchase"
            upgradeUI.PurchaseButton.BackgroundColor3 = Color3.fromRGB(53, 136, 9)
        end
    end)
end

local function populateUpgrades()
    if not dataInitialised then return end

    for _, child in ipairs(upgradesFrame:GetChildren()) do
        if child:IsA("Frame") and child ~= upgradeTemplate then 
            child:Destroy() 
        end
    end
    
    for upgradeKey, data in pairs(upgradeConfig) do
        createUpgradeUI(upgradeKey, data)
    end
end

dataInitEvent.OnClientEvent:Connect(function(data)
    if dataInitialised then return end 
    if data then
        flattenInto(dataCache, data)
    end
    dataInitialised = true
    populateUpgrades()
end)

dataUpdateEvent.OnClientEvent:Connect(function(newData, updatedStat, updateType)
    if not dataInitialised then return end

    if typeof(newData) == "table" then
        for key, value in pairs(newData) do
            if nestedTables[key] and type(value) == "table" then
                for innerKey, innerValue in pairs(value) do
                    dataCache[innerKey] = innerValue
                end
            else
                dataCache[key] = value
            end
        end
    end

    if updateType == "upgrade" then
        for _, child in pairs(upgradesFrame:GetChildren()) do
            if child:IsA("Frame") and child ~= upgradeTemplate then
                local childData = upgradeConfig[child.Name]
                if childData and (childData.RelatedStat == updatedStat or updatedStat == "Clicks") then
                    updateUI(child, child.Name, childData)
                end
            end
        end
    elseif updatedStat == "Rebirths" then
        for _, child in pairs(upgradesFrame:GetChildren()) do
            if child:IsA("Frame") and child ~= upgradeTemplate then
                local childData = upgradeConfig[child.Name]
                if childData then
                    updateUI(child, child.Name, childData)
                end
            end
        end
    end
end)
