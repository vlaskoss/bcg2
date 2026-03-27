local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modulesFolder = ServerStorage.Server.Modules
local sharedModulesFolder = ReplicatedStorage.Shared.Modules

local dataManager = require(modulesFolder.DataManager)
local gameUtils = require(sharedModulesFolder.GameUtils)

local function validateString(raw: string): (boolean | number)?
	if raw == "true" then return true end
	if raw == "false" then return false end
	local n = tonumber(raw)
	return n 
end

return function(context, player: Player, upgrade: string, rawValue: string)
	local value = validateString(rawValue)
	if value == nil then
		return `Invalid value "{rawValue}". Use a number or true/false.`
	end

	dataManager:SetUpgrade(player, upgrade, value)
	local state = dataManager:GetUpgrade(player, upgrade)

	if state == nil then return "Upgrade does not exist." end
	return `{gameUtils:MakePossessive(player.Name)} {upgrade} has been set to {tostring(state)}.`
end
