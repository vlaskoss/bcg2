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

local STAT_TRIGGERS = {}

STAT_TRIGGERS["TotalTime"] = true
STAT_TRIGGERS["TimePlayed"] = true
STAT_TRIGGERS["BaseBoost"] = true

for _, config in pairs(multiplierConfig) do
    if config.Stat    then STAT_TRIGGERS[config.Stat]    = true end
    if config.Upgrade then STAT_TRIGGERS[config.Upgrade] = true end
    if config.Type == "Rebirth" then STAT_TRIGGERS["Rebirths"] = true end
    if config.Type == "PerStat" and config.Stat == "Level" then
        STAT_TRIGGERS["Level"] = true
    end
end

dataInitBindable.Event:Connect(function(player)
    clickCalculationManager:InitialisePlayer(player)
end)

dataUpdateBindable.Event:Connect(function(player, _data, updatedCurrency)
    if STAT_TRIGGERS[updatedCurrency] then
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
