local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local serverFolder, sharedFolder = ServerStorage.Server, ReplicatedStorage.Shared
local sharedModulesFolder = sharedFolder.Modules
local bindablesFolder = serverFolder.BindableEvents

local dataUpdateBindable = bindablesFolder.DataUpdateBindable

local gameUtils = require(sharedModulesFolder.GameUtils)
local gammaNum = require(sharedModulesFolder.GammaNum)

local DataManager = {}
DataManager.Profiles = {}

local function checkAndUpdateLeaderstat(dataProfile: table, player: Player, currency: string)
	if player.leaderstats then
		local leaderstat = player.leaderstats:FindFirstChild(currency)
		if leaderstat then
			local value = dataProfile.Data[currency]
			if currency == "Clicks" and (typeof(value) == "buffer" or (typeof(value) == "table" and value.toSuffix)) then
				leaderstat.Value = gameUtils:FormatNum(value)
			else
				leaderstat.Value = value
			end
		end
	else
		warn(`[DataManager]: Player {player.Name} does not have a leaderstats folder`)
	end
end

local function ensureGammaNum(value)
	if typeof(value) == "buffer" then
		return value
	elseif typeof(value) == "number" then
		return gammaNum.fromNumber(value)
	elseif typeof(value) == "table" and value.toSuffix then
		return value
	else
		return gammaNum.fromNumber(0)
	end
end

function DataManager:AddCurrency(player: Player, currency: string, amount: number)
	local profile = self.Profiles[player]
	if not profile then return warn("[DataManager]: Player data profile does not exist.") end
	if not profile.Data[currency] then return warn("[DataManager]: Currency does not exist.") end
	local current = profile.Data[currency]
	if currency == "Clicks" then
		local amountGamma = ensureGammaNum(amount)
		gammaNum.addeq(current, amountGamma)
	else
		profile.Data[currency] += amount
	end
	checkAndUpdateLeaderstat(profile, player, currency)
	dataUpdateBindable:Fire(profile.Data, player, currency, "currency")
end

function DataManager:DeductCurrency(player: Player, currency: string, amount: number)
	local profile = self.Profiles[player]
	if not profile then return warn("[DataManager]: Player data profile does not exist.") end
	if not profile.Data[currency] then return warn("[DataManager]: Currency does not exist.") end
	local current = profile.Data[currency]
	
	if currency == "Clicks" then
		local amountGamma = ensureGammaNum(amount)
		gammaNum.subeq(current, amountGamma)
	else	
		profile.Data[currency] -= amount
	end
	checkAndUpdateLeaderstat(profile, player, currency)
	dataUpdateBindable:Fire(profile.Data, player, currency, "currency")
end

function DataManager:MultiplyCurrency(player: Player, currency: string, amount: number)
	local profile = self.Profiles[player]
	if not profile then return warn("[DataManager]: Player data profile does not exist.") end
	if not profile.Data[currency] then return warn("[DataManager]: Currency does not exist.") end
	local current = profile.Data[currency]

	if currency == "Clicks" then
		local amountGamma = ensureGammaNum(amount)
		gammaNum.muleq(current, amountGamma)
	else	
		profile.Data[currency] *= amount
	end
	checkAndUpdateLeaderstat(profile, player, currency)
	dataUpdateBindable:Fire(profile.Data, player, currency, "currency")
end

function DataManager:SetCurrency(player: Player, currency: string, amount: number)
	local profile = self.Profiles[player]
	if not profile then return warn("[DataManager]: Player data profile does not exist.") end
	if not profile.Data[currency] then return warn("[DataManager]: Currency does not exist.") end

	if currency == "Clicks" then
		if typeof(amount) == "number" then
			profile.Data[currency] = gammaNum.fromNumber(amount)
		else
			profile.Data[currency] = amount
		end
	else
		profile.Data[currency] = amount
	end
	checkAndUpdateLeaderstat(profile, player, currency)
	dataUpdateBindable:Fire(profile.Data, player, currency, "currency")
	if amount == 0 or amount == nil then
		warn(`[DataManager]: {gameUtils:MakePossessive(player.Name)} {currency} balance has been cleared.`)
	end
end

function DataManager:RetrieveAmount(player: Player, currency: string)
	local profile = self.Profiles[player]
	if not profile.Data then return warn("[DataManager]: Data non-existent.") end
	if not currency then
		if not profile then warn("[DataManager]: Player data profile does not exist.") return end
		return profile.Data
	else 
		if not profile.Data[currency] then return warn(`[DataManager]: Currency {currency} does not exist.`) end
		return profile.Data[currency]
	end
end

function DataManager:GetUpgrade(player, upgrade)
	local profile = self.Profiles[player]
	if not profile then warn("[DataManager]: Player data profile does not exist.") return end
	if not profile.Data.Upgrades then warn("[DataManager]: Upgrades data does not exist.") return end
	return profile.Data.Upgrades[upgrade]
end

function DataManager:SetUpgrade(player, upgrade, value)
	local profile = self.Profiles[player]
	if not profile then warn("[DataManager]: Player data profile does not exist.") return end
	if not profile.Data.Upgrades then warn("[DataManager]: Upgrades data does not exist.") return end
	profile.Data.Upgrades[upgrade] = value
	dataUpdateBindable:Fire(profile.Data, player, upgrade, "upgrade")
end

function DataManager:GetSetting(player, setting)
	local profile = self.Profiles[player]
	if not profile then warn("[DataManager]: Player data profile does not exist.") return end
	if not profile.Data.Settings then warn("[DataManager]: Settings data does not exist.") return end
	return profile.Data.Settings[setting]
end

function DataManager:SetSetting(player, setting, value)
	local profile = self.Profiles[player]
	if not profile then warn("[DataManager]: Player data profile does not exist.") return end
	if not profile.Data.Settings then warn("[DataManager]: Upgrades data does not exist.") return end
	profile.Data.Settings[setting] = value
	dataUpdateBindable:Fire(profile.Data, player, setting, "setting")
end

function DataManager:GetStatistic(player, stat)
	local profile = self.Profiles[player]
	if not profile then warn("[DataManager]: Player data profile does not exist.") return end
	if not profile.Data.Statistics then warn("[DataManager]: Statistics data does not exist.") return end
	return profile.Data.Statistics[stat]
end

function DataManager:SetStatistic(player, stat, value)
	local profile = self.Profiles[player]
	dataUpdateBindable:Fire(profile.Data, player, stat, "statistic")
	if not profile then warn("[DataManager]: Player data profile does not exist.") return end
	if not profile.Data.Statistics then warn("[DataManager]: Statistics data does not exist.") return end
	profile.Data.Statistics[stat] = value
end

return DataManager