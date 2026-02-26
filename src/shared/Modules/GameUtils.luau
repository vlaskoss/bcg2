local GameUtils = {}

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modulesFolder = ReplicatedStorage.Shared.Modules

local gammaNum = require(modulesFolder.GammaNum)

local ASCII = [[

bbbbbbbb                                                    
b::::::b                                                    
b::::::b                                                    
b::::::b                                                    
 b:::::b                                                    
 b:::::bbbbbbbbb        cccccccccccccccc   ggggggggg   ggggg
 b::::::::::::::bb    cc:::::::::::::::c  g:::::::::ggg::::g
 b::::::::::::::::b  c:::::::::::::::::c g:::::::::::::::::g
 b:::::bbbbb:::::::bc:::::::cccccc:::::cg::::::ggggg::::::gg
 b:::::b    b::::::bc::::::c     cccccccg:::::g     g:::::g 
 b:::::b     b:::::bc:::::c             g:::::g     g:::::g 
 b:::::b     b:::::bc:::::c             g:::::g     g:::::g 
 b:::::b     b:::::bc::::::c     cccccccg::::::g    g:::::g 
 b:::::bbbbbb::::::bc:::::::cccccc:::::cg:::::::ggggg:::::g 
 b::::::::::::::::b  c:::::::::::::::::c g::::::::::::::::g 
 b:::::::::::::::b    cc:::::::::::::::c  gg::::::::::::::g 
 bbbbbbbbbbbbbbbb       cccccccccccccccc    gggggggg::::::g 
                                                    g:::::g 
                                        gggggg      g:::::g 
                                        g:::::gg   gg:::::g 
                                         g::::::ggg:::::::g 
                                          gg:::::::::::::g  
                                            ggg::::::ggg    
                                               gggggg       
]]

function GameUtils:Tween(obj, goal, duration, delay, destroyOnCompletion)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, delay or 0)
    local newTween = TweenService:Create(obj, tweenInfo, goal)
    newTween:Play()
    newTween.Completed:Connect(function()
        newTween:Destroy()
        if destroyOnCompletion == true then
            obj:Destroy()
        end
    end)
    return newTween
end

function GameUtils:GetUptime()
    local totalSeconds = time()
    local seconds = math.floor(totalSeconds % 60)
    local mins = math.floor((totalSeconds / 60) % 60) 
    local hours = math.floor((totalSeconds / 3600) % 24)
    local days = math.floor(totalSeconds / 86400)
    return string.format("%d:%02d:%02d:%02d", days, hours, mins, seconds)
end

function GameUtils:GetASCII()
    return ASCII
end

function GameUtils:MakePossessive(username)
    if string.sub(username, -1) == "s" then
        return username .. "'"
    else
        return username .. "'s"
    end
end

function GameUtils:FormatNum(value)
    if not value then return "0" end
    local s, l, e = gammaNum.totuple(value)
    -- small numbers
    if l == 0 and e < 1000 then
        return tostring(math.floor(s * e))
    end
    -- big numbers >1k
    local oldDigits = gammaNum.DefaultDigits
    gammaNum.DefaultDigits = 2 
    local result = gammaNum.toSuffix(value)
    -- cleanup to 2 decimal places
    result = string.gsub(result, "(%d+%.%d%d)%d+", "%1")
    
    gammaNum.DefaultDigits = oldDigits
    return result
end

function GameUtils:EnsureGammaNum(value)
    if typeof(value) == "buffer" then return value end
    if typeof(value) == "number" then return gammaNum.fromNumber(value) end
    if typeof(value) == "table" and value.toSuffix then return value end
    return gammaNum.fromNumber(0)
end

function GameUtils:CalcLevelRequired(currentRebirths)
    return math.round(100 * (1.25 ^ currentRebirths))
end

return GameUtils