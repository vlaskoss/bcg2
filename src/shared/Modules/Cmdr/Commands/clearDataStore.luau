return {
	Name = "clearDataStore",
	Aliases = {"cds"},
	Description = "Clears the data store for a selected player and kicks them to force a rejoin.",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "The player whose data you want to clear.",
		}
	}
}
