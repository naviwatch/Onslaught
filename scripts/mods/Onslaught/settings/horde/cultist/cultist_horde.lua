local mod = get_mod("Onslaught")

local cultist_comps = {}


cultist_comps.havoc_cultist_coordinated_ranged_mixed_horde = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "cultist_berzerker",
				amount = { 
					5,
					5
				},
			},
			{
				name = "cultist_gunner",
				amount = { 
					14,
					14
				},
			},
		},
	},
}

cultist_comps.havoc_cultist_coordinated_blockade_behind = {
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
			{
				name = "chaos_ogryn_gunner",
				amount = {
					4,
					4
				},
			},
			{
				name = "renegade_executor",
				amount = {
					4,
					4
				},
			},
			{
				name = "cultist_berzerker",
				amount = {
					4,
					4
				},
			},
		},
	},
}

cultist_comps.havoc_cultist_coordinated_blockade_ahead = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "chaos_ogryn_bulwark",
				amount = {
					6,
					6
				},
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = {
					25,
					30
				},
			},
			{
				name = "cultist_shocktrooper",
				amount = {
					10,
					10
				},
			},
			{
				name = "cultist_assault",
				amount = {
					8,
					9
				},
			},
		},
	},
}

cultist_comps.cultist_coordinated_melee_mix = {
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 
					20, 
					22 
				},
			},
			{
				name = "cultist_melee",
				amount = { 
					11, 
					13 
				},
			},
			{
				name = "cultist_berzerker",
				amount = { 
					3, 
					4 
				},
			},
			{
				name = "cultist_shocktrooper",
				amount = {
					5,
					5
				}
			},
			{
				name = "cultist_vanguard",
				amount = { 
					2, 
					3 
				},
			},
			{
				name = "chaos_ogryn_executor",
				amount = { 
					1, 
					1 
				},
			},
		},
	},
}

cultist_comps.cultist_coordinated_melee_mix_2 = table.clone(cultist_comps.cultist_coordinated_melee_mix)

cultist_comps.cultist_small_coordinated_ranged_horde = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "cultist_assault",
				amount = { 
					10, 
					12 
				},
			},
			{
				name = "chaos_ogryn_gunner",
				amount = {
					1,
					1
				}
			}
		},
	},
}

cultist_comps.cultist_elite_poxwalkers_small = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 
					40, 
					40 
				},
			},
			{	
				name = "cultist_berzerker",
				amount = { 
					5, 
					5 
				},
			},
			{
				name = "chaos_ogryn_gunner",
				amount = {
					0,
					1
				}
			}
		},
	},
}

return cultist_comps