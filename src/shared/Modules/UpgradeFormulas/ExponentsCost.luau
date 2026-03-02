local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gammaNum = require(ReplicatedStorage.Shared.Modules.GammaNum)
local baseCost = gammaNum.fromNumber(1000000)
local costMultiplier = gammaNum.fromNumber(1000)

return function (tier)
    local currentTier = gammaNum.fromNumber(tier)
    if gammaNum.eq(currentTier, gammaNum.fromNumber(0)) then
        return baseCost
    else
        return gammaNum.mul(baseCost, gammaNum.pow(costMultiplier, currentTier))
    end
end