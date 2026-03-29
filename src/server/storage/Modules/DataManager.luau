local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local serverFolder = ServerStorage.Server
local sharedFolder = ReplicatedStorage.Shared
local sharedModulesFolder = sharedFolder.Modules

local dataUpdateBindable = serverFolder.BindableEvents.DataUpdateBindable

local gameUtils = require(sharedModulesFolder.GameUtils)
local gammaNum = require(sharedModulesFolder.GammaNum)

local DataManager = {}
DataManager.Profiles = {}

-- profile fetch
local function getProfile(profiles, player)
	local profile = profiles[player]
	if not profile then
		warn("[DataManager]: No profile for", player.Name)
	end
	return profile
end

local function updateLeaderstat(profile, player, currency)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then
		warn("[DataManager]: Player", player.Name, "has no leaderstats")
		return
	end
	local stat = ls:FindFirstChild(currency)
	if not stat then return end
	local value = profile.Data[currency]
	stat.Value = (currency == "Clicks") and gameUtils:FormatNum(value) or value
end

local function toGamma(value)
	if typeof(value) == "buffer" or (typeof(value) == "table" and value.toSuffix) then
		return value
	end
	return gammaNum.fromNumber(typeof(value) == "number" and value or 0)
end

-- util function for all main currency changes
local function mutateCurrency(self, player, currency, amount, op)
	local profile = getProfile(self.Profiles, player)
	if not profile then return end
	if profile.Data[currency] == nil then
		return warn("[DataManager]: Currency", currency, "does not exist.")
	end

	local current = profile.Data[currency]

	if currency == "Clicks" then
		local g = toGamma(amount)
		if     op == "add" then gammaNum.addeq(current, g)
		elseif op == "sub" then gammaNum.subeq(current, g)
		elseif op == "mul" then gammaNum.muleq(current, g)
		elseif op == "set" then profile.Data[currency] = g
		end
	else
		if     op == "add" then profile.Data[currency] += amount
		elseif op == "sub" then profile.Data[currency] -= amount
		elseif op == "mul" then profile.Data[currency] *= amount
		elseif op == "set" then profile.Data[currency] = amount
		end
	end

	updateLeaderstat(profile, player, currency)
	dataUpdateBindable:Fire(player, profile.Data, currency, "currency")
end

function DataManager:AddCurrency(player, currency, amount)
	mutateCurrency(self, player, currency, amount, "add")
end

function DataManager:DeductCurrency(player, currency, amount)
	mutateCurrency(self, player, currency, amount, "sub")
end

function DataManager:MultiplyCurrency(player, currency, amount)
	mutateCurrency(self, player, currency, amount, "mul")
end

function DataManager:SetCurrency(player, currency, amount)
	mutateCurrency(self, player, currency, amount, "set")
	if not amount or amount == 0 then
		warn("[DataManager]:", gameUtils:MakePossessive(player.Name), currency, "balance cleared.")
	end
end

function DataManager:RetrieveAmount(player, currency)
	local profile = getProfile(self.Profiles, player)
	if not profile then return end
	if not currency then return profile.Data end
	if profile.Data[currency] == nil then
		return warn(`[DataManager]: Currency ${currency} does not exist.`)
	end
	return profile.Data[currency]
end

-- util function for get/set functions for upgrades, settings and statistics
local function makeAccessors(key)
	return
		function(self, player, field)
			local profile = getProfile(self.Profiles, player)
			if not profile then return end
			if not profile.Data[key] then
				return warn("[DataManager]:", key, "data does not exist.")
			end
			return profile.Data[key][field]
		end,
		function(self, player, field, value)
			local profile = getProfile(self.Profiles, player)
			if not profile then return end
			if not profile.Data[key] then
				return warn("[DataManager]:", key, "data does not exist.")
			end
			profile.Data[key][field] = value
			dataUpdateBindable:Fire(player, profile.Data, field, key:lower())
		end
end

DataManager.GetUpgrade,   DataManager.SetUpgrade   = makeAccessors("Upgrades")
DataManager.GetSetting,   DataManager.SetSetting   = makeAccessors("Settings")
DataManager.GetStatistic, DataManager.SetStatistic = makeAccessors("Statistics")

return DataManager