return {
	Name = "modifyCurrency",
	Aliases = {"mc"},
	Description = "Applies an arithmetic operation (add, deduct, multiply) to a player's currency. Use * for all players.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The target player(s). Use * for all players.",
		},
		{
			Type = "currency",
			Name = "Currency",
			Description = "The currency you want to change."
		},
		{
			Type = "operations",
			Name = "Operation",
			Description = "The operation you want to apply to the currency."
		},
		{
			Type = "number",
			Name = "Amount",
			Description = "The amount related to the operation."
		},
	}
}
