debug.setmemorycategory("Stats")

local PlayersService = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local serverFolder = ServerStorage.Server
local modulesFolder, bindablesFolder = serverFolder.Modules, serverFolder.BindableEvents

local dataInitBindable = bindablesFolder.DataInitBindable

local dataManager = require(modulesFolder.DataManager)

local joinTimestamps = {}

PlayersService.PlayerAdded:Connect(function(player)
    joinTimestamps[player.UserId] = os.time()
end)

dataInitBindable.Event:Connect(function(player)
    local profile = dataManager.Profiles[player]
    if not profile then return end

    local joinTime = joinTimestamps[player.UserId] or os.time()
    local startingTime = dataManager:GetStatistic(player, "TotalTime") or 0

    task.spawn(function()
        while player.Parent and dataManager.Profiles[player] do
            local sessionDuration = os.time() - joinTime 
            local newTime = startingTime + sessionDuration
            dataManager:SetStatistic(player, "TotalTime", newTime)
            task.wait(1)
        end
    end)
end)

PlayersService.PlayerRemoving:Connect(function(player)
    joinTimestamps[player.UserId] = nil
end)
