local AutoClickManager = {}

AutoClickManager.Players = {}

AutoClickManager.LevelRate = {
    [1] = 2,
    [2] = 4,
    [3] = 6,
    [4] = 8,
    [5] = 10,
    [6] = 12,
    [7] = 14,
    [8] = 16,
    [9] = 18,
    [10] = 20,
    [11] = 25,
    [12] = 30,
    [13] = 35,
    [14] = 40,
    [15] = 50,
    [16] = 0 
}

function AutoClickManager:StartAutoClick(userId, level)
    if not self.LevelRate[level] then
        warn("[AutoClickManager]: Invalid autoclick level " .. level)
        return false
    end

    self.Players[userId] = {
        level = level,
        rate = self.LevelRate[level]
    }
    return true
end

function AutoClickManager:StopAutoClick(userId)
    self.Players[userId] = nil
end

function AutoClickManager:GetAutoClickData(userId)
    return self.Players[userId]
end

function AutoClickManager:IsAutoClicking(userId)
    return self.Players[userId] ~= nil
end

return AutoClickManager