local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gammaNum = require(ReplicatedStorage.Shared.Modules.GammaNum)

-- utility function for most upgrades
local function exponential(base, multiplier)
	local base = gammaNum.fromNumber(base)
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
	AutoClicker      = exponential(50, 10),
	Base2            = exponential(256, 2),
	BaseBoost        = exponential(500, 2),
	ClickMultiplier  = exponential(100, 100),
	Exponents        = exponential(1000000, 1000),
	Recursion        = exponential(10000, 50),
	ReduceLevelCost  = exponential(1000, 1000),
	TimePlayed       = exponential(5000, 100),

	-- level formula uses a dynamic exponent
	Level = function(level)
		local lvl = gammaNum.fromNumber(level)
		local exponent = gammaNum.add(1.3, gammaNum.div(gammaNum.pow(gammaNum.log10(lvl), 2), 10))
		return gammaNum.floor(gammaNum.mul(gammaNum.fromNumber(10), gammaNum.pow(lvl, exponent)))
	end,
}
