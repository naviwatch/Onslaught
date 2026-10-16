local mod = get_mod("Onslaught")

local cultist_trickle = {}

cultist_trickle.cultist_trickle_melee = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "cultist_melee",
				amount = { 
					25, 
					30 
				},
			},
		},
	},
}

cultist_trickle.cultist_trickle_assaulters_high = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "cultist_assault",
				amount = { 
					25, 
					30 
				},
			},
		},
	},
}

cultist_trickle.cultist_trickle_gunners = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "cultist_assault",
				amount = { 
					10, 
					10 
				},
			},
			{
				name = "cultist_gunner",
				amount = { 
					6, 
					6 
				},
			},
			{
				name = "cultist_shocktrooper",
				amount = { 
					6, 
					6 
				},
			},
		},
	},
}

cultist_trickle.cultist_trickle_melee_elites = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "cultist_melee",
				amount = { 
					10, 
					15 
				},
			},
			{
				name = "cultist_berzerker",
				amount = { 
					10, 
					10 
				},
			},
		},
	},
}

cultist_trickle.cultist_trickle_ogryn_gunners = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "cultist_assault",
				amount = { 
					10, 
					15 
				},
			},
			{
				name = "cultist_gunner",
				amount = { 
					3, 
					5 
				},
			},
			{
				name = "chaos_ogryn_gunner",
				amount = { 
					3, 
					3 
				},
			},
		},
	},
}

cultist_trickle.cultist_trickle_ogryn_bulwarks = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "cultist_melee",
				amount = { 
					10, 
					15 
				},
			},
			{
				name = "chaos_ogryn_bulwark",
				amount = { 
					3, 
					3 
				},
			},
			{
				name = "cultist_shocktrooper",
				amount = { 
					6, 
					6 
				},
			},
		},
	},
}

cultist_trickle.cultist_trickle_ogryn_executors = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "cultist_melee",
				amount = { 
					10, 
					15 
				},
			},
			{
				name = "cultist_berzerker",
				amount = { 
					6, 
					6 
				},
			},
			{
				name = "chaos_ogryn_executor",
				amount = { 
					4, 
					4 
				},
			},
		},
	},
}

return cultist_trickle