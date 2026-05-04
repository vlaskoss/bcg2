debug.setmemorycategory("Click")

local ServerStorage      = game:GetService("ServerStorage")
local PlayersService     = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local serverFolder    = ServerStorage.Server
local modulesFolder   = serverFolder.Modules
local bindablesFolder = serverFolder.BindableEvents

local clickCalculationManager = require(modulesFolder.ClickCalculationManager)
local multiplierConfig        = require(modulesFolder.MultiplierConfig)

local dataInitBindable   = bindablesFolder.DataInitBindable
local dataUpdateBindable = bindablesFolder.DataUpdateBindable

-- ─── build trigger set from config ──────────────────────────────────────────
--
-- Any stat referenced by a config entry should trigger a recalc when it changes.
-- We derive this automatically so you never have to update the handler manually.

local statTriggers = {}


for key in pairs(multiplierConfig) do
    statTriggers[key] = true
end

dataInitBindable.Event:Connect(function(player)
    clickCalculationManager:InitialisePlayer(player)
end)

dataUpdateBindable.Event:Connect(function(player, _data, updatedCurrency)
    if statTriggers[updatedCurrency] then
        clickCalculationManager:UpdateMultiplier(player)
    end
end)

PlayersService.PlayerRemoving:Connect(function(player)
    clickCalculationManager:RemovePlayer(player)
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, _passId, wasPurchased)
    if wasPurchased then
        -- Small wait so dataManager has time to persist the purchase flag.
        task.wait(1)
        clickCalculationManager:UpdateMultiplier(player)
    end
end)
