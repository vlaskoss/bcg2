local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modulesFolder = ServerStorage.Server.Modules
local sharedModulesFolder = ReplicatedStorage.Shared.Modules

local dataManager = require(modulesFolder.DataManager)
local gameUtils = require(sharedModulesFolder.GameUtils)

local function getStoreName(): string
	return RunService:IsStudio() and "Test" or "PlayerStore"
end

return function(context, target: Player)
	if not target then return "No target player provided." end

	local profile = dataManager.Profiles[target]
	if not profile then return `{target.Name} has no active profile.` end

	local store = DataStoreService:GetDataStore(getStoreName())
	local success, err = pcall(function()
		store:RemoveAsync(tostring(target.UserId))
	end)

	if not success then
		return `Failed to clear {target.Name}'s data: {err}`
	end

	dataManager.Profiles[target] = nil
	profile:EndSession()
	target:Kick("Your data has been cleared. Please rejoin.")

	return `{gameUtils:MakePossessive(target.Name)} data has been cleared.`
end
