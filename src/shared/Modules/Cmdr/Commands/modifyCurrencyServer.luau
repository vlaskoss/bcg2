local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modulesFolder = ServerStorage.Server.Modules
local sharedModulesFolder = ReplicatedStorage.Shared.Modules

local dataManager = require(modulesFolder.DataManager)
local gammaNum = require(sharedModulesFolder.GammaNum)
local gameUtils = require(sharedModulesFolder.GameUtils)

local state
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

return function (context, player: Player, currency: string, operation: string, amount: number)
	local target = if player then player else context.Executor
	
	local operationFunction = operationFunctions[operation]
	if not operationFunction then return "Currency operation does not exist" end

	operationFunction(target, currency, amount)
	state = dataManager:RetrieveAmount(target, currency)

	if not state then return "Currency does not exist." end
	if currency == "Clicks" then
		return `{gameUtils:MakePossessive(target.Name)} {currency} balance is now {gammaNum.toSuffix(state)}.`
	else
		return `{gameUtils:MakePossessive(target.Name)} {currency} balance is now {state}.`
	end
end

