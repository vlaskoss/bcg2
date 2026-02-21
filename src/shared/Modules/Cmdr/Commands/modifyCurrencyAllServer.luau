local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local modulesFolder = ServerStorage.Server.Modules
local sharedModulesFolder = ReplicatedStorage.Shared.Modules

local dataManager = require(modulesFolder.DataManager)
local gammaNum = require(sharedModulesFolder.GammaNum)
local gameUtils = require(sharedModulesFolder.GameUtils)

local state
local resultString
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

return function (context, currency: string, operation: string, amount: number)
	local results = {}
	local operationFunction = operationFunctions[operation]
	if not operationFunction then return "Currency operation does not exist" end
	if operation == "multiply" then return "Selected operation (multiplication) is disabled for whole-server currency manipulation for safety purposes." end

	for _, player in PlayersService:GetPlayers() do
		operationFunction(player, currency, amount)
		state = dataManager:RetrieveAmount(player, currency)
		resultString = ""
		if state == nil then
			resultString = `{gameUtils:MakePossessive(player.Name)} currency modification failed (Currency does not exist).`
		else
			if currency == "Clicks" then
				resultString = `{gameUtils:MakePossessive(player.Name)} {currency} balance is now {gammaNum.toSuffix(state)}`
			else
				resultString = `{gameUtils:MakePossessive(player.Name)} {currency} balance is now {state}.`
			end
		end
		table.insert(results, resultString)
	end
	if not state then return "Currency does not exist." end
	return table.concat(results, "\n")
end

