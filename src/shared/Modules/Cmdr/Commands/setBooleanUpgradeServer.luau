local ServerStorage = game:GetService("ServerStorage")

local dataManager = require(ServerStorage.Server.Modules.DataManager)
local state
return function (context, player: Player, booleanUpgrades: string, boolean: number)
	local target = if player then player else context.Executor

	dataManager:SetUpgrade(target, booleanUpgrades, boolean)
	state = dataManager:GetUpgrade(target, booleanUpgrades)
	
	return `{target.Name}'s {booleanUpgrades} balance has been set to {state}.`
end

