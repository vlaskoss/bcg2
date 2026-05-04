local DebounceManager = {}

DebounceManager.Players = {}

DebounceManager.LevelRate = {
    [0] = 0.1,
    [1] = 0.09,
    [2] = 0.08,
    [3] = 0.07,
    [4] = 0.06,
    [5] = 0.05,
    [6] = 0.04,
    [7] = 0.03,
    [8] = 0.02,
    [9] = 0.01,
    [10] = 0
}

function DebounceManager:AddPlayerDebounce(userId)
    self.Players[userId] = true
end

function DebounceManager:RemovePlayerDebounce(userId)
    self.Players[userId] = nil
end

function DebounceManager:IsDebounced(userId)
    local value = self.Players[userId]
    local result = value == true
    return result
end

return DebounceManager