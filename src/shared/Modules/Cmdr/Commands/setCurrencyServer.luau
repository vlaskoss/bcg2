local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modulesFolder = ServerStorage.Server.Modules
local sharedModulesFolder = ReplicatedStorage.Shared.Modules

local dataManager = require(modulesFolder.DataManager)
local gammaNum = require(sharedModulesFolder.GammaNum)
local gameUtils = require(sharedModulesFolder.GameUtils)

return function(context, player: Player, currency: string, amount: number)
	dataManager:SetCurrency(player, currency, amount)
	local state = dataManager:RetrieveAmount(player, currency)

	if not state then return "Currency does not exist." end

	local formatted = if currency == "Clicks" then gammaNum.toSuffix(state) else tostring(state)
	return `{gameUtils:MakePossessive(player.Name)} {currency} balance is now {formatted}.`
end
