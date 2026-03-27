return {
	Name = "setUpgrade",
	Aliases = {"su"},
	Description = "Sets a player's upgrade to a specified value. Works for both numeric and boolean upgrades.",
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
			Type = "string", 
			Name = "Value",
			Description = "The value to set, either a number or boolean."
		},
	}
}
