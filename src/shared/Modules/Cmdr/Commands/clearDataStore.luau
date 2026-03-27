return {
	Name = "clearDataStore",
	Aliases = {"cds"},
	Description = "Clears the data store for a selected player and kicks them to force a rejoin.",
	Group = "Admin",
	Args = {
		{
			Type = "player?",
			Name = "Player",
			Description = "The in-game player whose data you want to clear. Leave blank if using UserId.",
		},
		{	Type = "number?",
			Name = "UserId",
			Description = "The UserId of an offline player whose data you want to clear. Leave blank if using Player."
		}
	}
}
