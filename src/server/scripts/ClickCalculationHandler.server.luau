debug.setmemorycategory("Click")

local ServerStorage = game:GetService("ServerStorage")
local PlayersService = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local serverFolder = ServerStorage.Server
local modulesFolder, bindablesFolder = serverFolder.Modules, serverFolder.BindableEvents

local clickCalculationManager = require(modulesFolder.ClickCalculationManager)
local multiplierConfig = require(modulesFolder.MultiplierConfig)

local dataInitBindable = bindablesFolder.DataInitBindable
local dataUpdateBindable = bindablesFolder.DataUpdateBindable

dataInitBindable.Event:Connect(function(player)
    clickCalculationManager:InitialisePlayer(player)
end)

dataUpdateBindable.Event:Connect(function(player, data, updatedCurrency)
    for sourceName, config in pairs(multiplierConfig) do
        local shouldUpdate = false

        if config.Type == "Level" and updatedCurrency == "Level" then
            shouldUpdate = true
        elseif config.Type == "Currency" and updatedCurrency == config.RelatedStat then
            shouldUpdate = true
        elseif config.Type == "Upgrade" and updatedCurrency == config.RelatedStat then
            shouldUpdate = true
        elseif config.Type == "Statistic" and updatedCurrency == config.RelatedStat then
            shouldUpdate = true
        elseif config.Type == "Rebirth" and updatedCurrency == "Rebirths" then
            shouldUpdate = true
        end

        if shouldUpdate then
            clickCalculationManager:UpdateMultiplier(player)
            break
        end
    end
end)

PlayersService.PlayerRemoving:Connect(function(player)
    clickCalculationManager:RemovePlayer(player)
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
    if wasPurchased then
        task.wait(1)
        clickCalculationManager:UpdateMultiplier(player)
    end
end)