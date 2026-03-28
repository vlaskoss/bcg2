local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gammaNum = require(ReplicatedStorage.Shared.Modules.GammaNum)

-- utility function for most upgrades
local function exponential(baseCost, multiplier)
	local base = gammaNum.fromNumber(baseCost)
	local mult = gammaNum.fromNumber(multiplier)
	return function(tier)
		local t = gammaNum.fromNumber(tier)
		if gammaNum.eq(t, gammaNum.fromNumber(0)) then
			return base
		else
			return gammaNum.mul(base, gammaNum.pow(mult, t))
		end
	end
end

return {
	AutoClickerCost      = exponential(50, 10),
	Base2Cost            = exponential(256, 2),
	BaseBoostCost        = exponential(500, 2),
	ClickMultiplierCost  = exponential(100, 100),
	ExponentsCost        = exponential(1000000, 1000),
	RecursionCost        = exponential(10000, 50),
	ReduceLevelCost      = exponential(1000, 1000),
	TimePlayedCost       = exponential(5000, 100),

	-- level formula uses a dynamic exponent
	LevelCost = function(level)
		local lvl = gammaNum.fromNumber(level)
		local exponent = gammaNum.add(1.3, gammaNum.div(gammaNum.pow(gammaNum.log10(lvl), 2), 10))
		return gammaNum.floor(gammaNum.mul(gammaNum.fromNumber(10), gammaNum.pow(lvl, exponent)))
	end,
}
