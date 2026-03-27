local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modulesFolder = ServerStorage.Server.Modules
local sharedModulesFolder = ReplicatedStorage.Shared.Modules

local dataManager = require(modulesFolder.DataManager)
local gammaNum = require(sharedModulesFolder.GammaNum)
local gameUtils = require(sharedModulesFolder.GameUtils)

local operationFunctions = {
	["add"] = function(target, currency, amount)
		dataManager:AddCurrency(target, currency, amount)
	end,
	["deduct"] = function(target, currency, amount)
		dataManager:DeductCurrency(target, currency, amount)
	end,
	["multiply"] = function(target, currency, amount)
		dataManager:MultiplyCurrency(target, currency, amount)
	end
}

local function formatBalance(player: Player, currency: string, amount: number): string
	local formatted = if currency == "Clicks" then gammaNum.toSuffix(amount) else tostring(amount)
	return `{gameUtils:MakePossessive(player.Name)} {currency} balance is now {formatted}.`
end

return function(context, players: {Player}, currency: string, operation: string, amount: number)
	local operationFunction = operationFunctions[operation]
	if not operationFunction then return "Currency operation does not exist." end

	local isMultiple = #players > 1
	if isMultiple and operation == "multiply" then
		return "Multiply is disabled for multi-player currency changes for safety."
	end

	local results = {}
	for _, player in players do
		operationFunction(player, currency, amount)
		local state = dataManager:RetrieveAmount(player, currency)
		if state == nil then
			table.insert(results, `{gameUtils:MakePossessive(player.Name)} currency modification failed (currency does not exist).`)
		else
			table.insert(results, formatBalance(player, currency, state))
		end
	end

	return table.concat(results, "\n")
end
