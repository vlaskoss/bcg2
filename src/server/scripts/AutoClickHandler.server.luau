debug.setmemorycategory("Click")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local serverFolder = ServerStorage.Server
local modulesFolder, bindablesFolder = serverFolder.Modules, serverFolder.BindableEvents
local remotesFolder = ReplicatedStorage.Shared.Remotes

local autoClickManager = require(modulesFolder.AutoClickManager)
local dataManager = require(modulesFolder.DataManager)
local clickCalculationManager = require(modulesFolder.ClickCalculationManager)
local debugUtils = require(ReplicatedStorage.Shared.Modules.DebugUtils)

local autoClickEvent = remotesFolder.AutoClickEvent
local clickFXEvent = remotesFolder.ClickFXEvent
local dataUpdateBindable = bindablesFolder.DataUpdateBindable


local function runAutoClicker(player, level)
    local userId = player.UserId
    while autoClickManager:IsAutoClicking(userId) do
        local data = autoClickManager:GetAutoClickData(userId)
        if not data or data.level ~= level then break end

        if not player.Parent then break end
        local baseAmount = 1
        local amountToGive = clickCalculationManager:Calculate(player, baseAmount)
        dataManager:AddCurrency(player, "Clicks", amountToGive)
        clickFXEvent:FireClient(player)
        if data.rate and data.rate > 0 then
            task.wait(1 / data.rate)
        else
            task.wait()
        end
    end
end

autoClickEvent.OnServerEvent:Connect(function(player, action)
    local userId = player.UserId

    if action == "start" then
        if autoClickManager:IsAutoClicking(userId) then return end

        local level = dataManager:GetUpgrade(player, "AutoClicker")
        if level >= 1 then
            if autoClickManager:StartAutoClick(userId, level) then
                task.spawn(runAutoClicker, player, level)
            else
                debugUtils:Warn("[AutoClickHandler]: Player requested to autoclick, but does not have it unlocked")
            end
        end
    elseif action == "stop" then
        autoClickManager:StopAutoClick(userId)
    end
end)

PlayersService.PlayerRemoving:Connect(function(player)
    autoClickManager:StopAutoClick(player.UserId)
end)

dataUpdateBindable.Event:Connect(function(player, data, updatedCurrency)
    if updatedCurrency == "AutoClicker" then
        if autoClickManager:IsAutoClicking(player.UserId) then
            autoClickManager:StopAutoClick(player.UserId)
            local level = data.Upgrades.AutoClicker
            if autoClickManager:StartAutoClick(player.UserId, level) then
                task.spawn(runAutoClicker, player, level)
            end
        end
    end
end)