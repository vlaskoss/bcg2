local AutoClickManager = {}

local autoClickerConfig = require(script.Parent.AutoClickerConfig)

AutoClickManager.Players = {}

function AutoClickManager:StartAutoClick(userId, level)
    if not autoClickerConfig[level] then
        warn("[AutoClickManager]: Invalid autoclick level " .. level)
        return false
    end

    self.Players[userId] = {
        level = level,
        rate = autoClickerConfig[level]
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