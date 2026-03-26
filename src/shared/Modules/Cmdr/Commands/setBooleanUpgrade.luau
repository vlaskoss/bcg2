return {
	Name = "setBooleanUpgrade",
	Aliases = {"sbu"},
	Description = "Sets a user's upgrade value to a boolean.",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "The target player.",
		},
		{
			Type = "booleanUpgrades",
			Name = "Upgrade",
			Description = "The target upgrade."
		},
		{
			Type = "boolean",
			Name = "Boolean",
			Description = "The boolean related to the operation."
		},
		
	}
}