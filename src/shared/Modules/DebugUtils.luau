local DebugUtils = {}

DebugUtils.DEBUG = false

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
