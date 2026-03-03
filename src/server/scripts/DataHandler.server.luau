debug.setmemorycategory("Data")

local PlayersService = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local serverFolder, sharedFolder = ServerStorage.Server, ReplicatedStorage.Shared
local modulesFolder, bindablesFolder = serverFolder.Modules, serverFolder.BindableEvents
local remotesFolder, sharedModulesFolder = sharedFolder.Remotes, sharedFolder.Modules

local dataInitEvent = remotesFolder.DataInitEvent
local dataInitReturnEvent = remotesFolder.DataInitReturnEvent
local dataInitBindable = bindablesFolder.DataInitBindable

local profileStore = require(modulesFolder.ProfileStore)
local profileTemplate = require(modulesFolder.SaveTemplate)
local dataManager = require(modulesFolder.DataManager)
local debounceManager = require(modulesFolder.DebounceManager)
local gammaNum = require(sharedModulesFolder.GammaNum)
local gameUtils = require(sharedModulesFolder.GameUtils)

local dataInitReturnTable = {}

local function GetStoreName()
	return RunService:IsStudio() and "Test" or "PlayerStore"
end

local function SetandCreateLeaderstat(leaderstatName : string, dataProfile, leaderstatsFolder: Folder)
	if not dataProfile.Data[leaderstatName] then return end
	local value = dataProfile.Data[leaderstatName]

	if typeof(value) == "buffer" or (typeof(value) == "table" and value.toSuffix) then
		local leaderstat = Instance.new("StringValue")
		leaderstat.Name = leaderstatName
		leaderstat.Value = gameUtils:FormatNum(value)
		leaderstat.Parent = leaderstatsFolder
	else
		local leaderstat = Instance.new("NumberValue")
		leaderstat.Name =  leaderstatName
		leaderstat.Value = value
		leaderstat.Parent = leaderstatsFolder
	end
end

local playerStore = profileStore.New(GetStoreName(), profileTemplate)

-- Make and set leaderstats
local function Initalise(player: Player, profile: typeof(playerStore:StartSessionAsync()))
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	task.wait(1)
	SetandCreateLeaderstat("Rebirths", profile, leaderstats)
	SetandCreateLeaderstat("Level", profile, leaderstats)
	SetandCreateLeaderstat("Clicks", profile, leaderstats)
	leaderstats.Parent = player
end

local function PlayerAdded(player: Player)
	-- Start session for player data
	local profile = playerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= PlayersService
		end,
	})
	
	-- Sanity check
	if profile ~= nil then
		profile:AddUserId(player.UserId) 
		profile:Reconcile()
		
		profile.OnSessionEnd:Connect(function()
			if dataManager.Profiles[player] then
				dataManager.Profiles[player] = nil
				player:Kick("Error loading data profile. Please rejoin.")
			end
		end)
		
		if player.Parent == PlayersService then
			dataManager.Profiles[player] = profile
			Initalise(player, profile)
			print(`[DataHandler]: {gameUtils:MakePossessive(player.Name)} ({player.UserId}) data loaded successfully!`)
			dataInitReturnTable[player.UserId] = false
			dataInitBindable:Fire(player)
			dataInitEvent:FireClient(player, profile.Data)

			while dataInitReturnTable[player.UserId] == false do
				dataInitEvent:FireClient(player, profile.Data)
				task.wait(0.5)
			end

			dataInitReturnEvent.OnServerEvent:Connect(function(player)
				dataInitReturnTable[player.UserId] = true
				print("Player" .. player.Name .. "has returned the data init event")
			end)
			
			
		else
			profile:EndSession()
		end
	else
		-- Server shutdown while player is joining
		player:Kick("Error loading data profile. Please rejoin.")
	end
end

-- Players already in the game when the script runs
for _, player in PlayersService:GetPlayers() do
	task.spawn(PlayerAdded, player)
end

PlayersService.PlayerAdded:Connect(PlayerAdded)

PlayersService.PlayerRemoving:Connect(function(player)
	local profile = dataManager.Profiles[player]
	if not profile then return end
	profile:EndSession()
	dataManager.Profiles[player] = nil
	dataInitReturnTable[player.UserId] = nil
	debounceManager:RemovePlayerDebounce(player.UserId)
end)