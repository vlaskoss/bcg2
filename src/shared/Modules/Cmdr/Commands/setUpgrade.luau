return {
	Name = "setUpgrade",
	Aliases = {"su"},
	Description = "Sets a user's upgrade value to a specified amount (or none, clearing the data).",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "The target player.",
		},
		{
			Type = "upgrades",
			Name = "Upgrade",
			Description = "The target upgrade."
		},
		{
			Type = "number",
			Name = "Amount",
			Description = "The amount related to the operation."
		},
		
	}
}