local mod = get_mod("Onslaught")

local renegade_trickle = {}

renegade_trickle.renegade_trickle_melee = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "renegade_melee",
				amount = { 
					25, 
					30 
				},
			},
		},
	},
}

renegade_trickle.renegade_trickle_riflemen_high = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "renegade_rifleman",
				amount = { 
					25, 
					30 
				},
			},
		},
	},
}

renegade_trickle.renegade_trickle_gunners = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "renegade_rifleman",
				amount = { 
					10, 
					10 
				},
			},
			{
				name = "renegade_gunner",
				amount = { 
					3, 
					5 
				},
			},
			{
				name = "renegade_plasma_gunner",
				amount = { 
					3, 
					6 
				},
			},
			{
				name = "renegade_shocktrooper",
				amount = { 
					4, 
					4 
				},
			},
		},
	},
}

renegade_trickle.renegade_trickle_melee_elites = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "renegade_melee",
				amount = { 
					7, 
					10 
				},
			},
			{
				name = "renegade_executor",
				amount = { 
					3, 
					4 
				},
			},
			{
				name = "renegade_berzerker",
				amount = { 
					3, 
					4 
				},
			},
		},
	},
}

renegade_trickle.renegade_trickle_ogryn_gunners = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "renegade_rifleman",
				amount = { 
					10, 
					15 
				},
			},
			{
				name = "renegade_gunner",
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

renegade_trickle.renegade_trickle_ogryn_bulwarks = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "renegade_melee",
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
				name = "renegade_executor",
				amount = { 
					3, 
					3 
				},
			},
		},
	},
}

renegade_trickle.renegade_trickle_ogryn_executors = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "renegade_melee",
				amount = { 
					10, 
					15 
				},
			},
			{
				name = "renegade_berzerker",
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

return renegade_trickle