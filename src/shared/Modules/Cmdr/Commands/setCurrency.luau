return {
	Name = "setCurrency",
	Aliases = {"sc"},
	Description = "Sets a player's currency to a specified amount.",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "The player whose currency you want to change.",
		},
		{
			Type = "currency",
			Name = "Currency",
			Description = "The currency you want to change."
		},
		{
			Type = "number",
			Name = "Amount",
			Description = "The amount to set the currency to."
		},
	}
}
