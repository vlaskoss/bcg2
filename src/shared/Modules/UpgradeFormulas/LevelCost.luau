local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gammaNum = require(ReplicatedStorage.Shared.Modules.GammaNum)
local baseCost = gammaNum.fromNumber(10)

return function (level)
    local exponent = gammaNum.add(1.3, gammaNum.div(gammaNum.pow(gammaNum.log10(level), 2), 10)) 
    local cost = gammaNum.mul(baseCost, gammaNum.pow(level, exponent))
    return gammaNum.floor(cost)
end