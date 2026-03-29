--[[
    DebugUtils.luau
    ─────────────────────────────────────────────────────────────────────────────
    Provides debug logging utilities with a global DEBUG flag to control output.
    
    Usage:
        local debugUtils = require(game.ReplicatedStorage.Shared.Modules.DebugUtils)
        debugUtils:Log("[ModuleName]: Message")
        debugUtils:Warn("[ModuleName]: Warning message")
--]]

local DebugUtils = {}

-- Set to false to disable all debug output
DebugUtils.DEBUG = true

function DebugUtils:Log(message)
    if self.DEBUG then
        print(message)
    end
end

function DebugUtils:Warn(message)
    if self.DEBUG then
        warn(message)
    end
end

function DebugUtils:SetEnabled(enabled)
    self.DEBUG = enabled
end

return DebugUtils
