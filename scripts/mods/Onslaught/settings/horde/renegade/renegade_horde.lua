local mod = get_mod("Onslaught")

local renegade_comps = {}

-- Overwrite the specific composition
renegade_comps.havoc_renegade_medium = {
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 16, 20 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 16, 20 },
			},
			{
				name = "renegade_melee",
				amount = { 20, 25 }
			},
			{
				name = "cultist_berzerker",
				amount = { 1, 1 }
			},
			{
				name = "renegade_executor",
				amount = { 4, 4 }
			},
			{
				name = "chaos_ogryn_executor",
				amount = { 1, 1 }
			},
			{
				name = "renegade_shocktrooper",
				amount = { 3, 3 }
			},
		},
	},
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "renegade_executor",
				amount = { 4, 4 }
			},
			{
				name = "chaos_ogryn_bulwark",
				amount = { 2, 2 }
			},
			{
				name = "renegade_plasma_gunner",
				amount = { 1, 1 }
			},
			{
				name = "renegade_assault",
				amount = { 4, 4 }
			},
		},
	},
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "cultist_berzerker",
				amount = { 8, 8 }
			},
			{
				name = "chaos_ogryn_bulwark",
				amount = { 1, 1 }
			},
			{
				name = "chaos_ogryn_gunner",
				amount = { 0, 1 }
			}
		},
	},
}

-- renegade_comps.renegade_medium = table.clone(renegade_comps.havoc_renegade_medium)

renegade_comps.havoc_infected_medium = {
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "cultist_melee",
				amount = {
					20,
					25
				}
			},
			{
				name = "renegade_executor",
				amount = {
					2,
					2
				}
			},
			{
				name = "cultist_berzerker",
				amount = {
					5,
					5
				}
			},
			{
				name = "renegade_shocktrooper",
				amount = {
					5,
					5
				}
			},
			{
				name = "chaos_ogryn_executor",
				amount = {
					2,
					2
				}
			},
		},
	},
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "cultist_melee",
				amount = {
					20,
					25
				}
			},
			{
				name = "renegade_executor",
				amount = {
					5,
					5
				}
			},
			{
				name = "cultist_berzerker",
				amount = {
					2,
					2
				}
			},
			{
				name = "chaos_ogryn_gunner",
				amount = { 0, 1 }
			},
			{
				name = "chaos_ogryn_bulwark",
				amount = {
					2,
					2
				}
			}
		},
	},
}

renegade_comps.infected_medium = table.clone(renegade_comps.havoc_infected_medium)


renegade_comps.havoc_infected_large = {
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "cultist_melee",
				amount = {
					15,
					19,
				},
			},
			{
				name = "renegade_berzerker",
				amount = {
					2,
					2
				}
			},
			{
				name = "cultist_berzerker",
				amount = {
					2,
					2
				}
			},
			{
				name = "cultist_shocktrooper",
				amount = {
					5,
					5
				}
			},
			{
				name = "renegade_plasma_gunner",
				amount = {
					2,
					2
				}
			},
			{
				name = "chaos_ogryn_executor",
				amount = {
					2,
					2
				}
			},
		},
	},
}

renegade_comps.infected_small = {
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "cultist_melee",
				amount = { 20, 25 }
			},
			{
				name = "cultist_berzerker",
				amount = { 2, 2 }
			},
			{
				name = "renegade_berzerker",
				amount = { 2, 2 }
			},
			{
				name = "renegade_shocktrooper",
				amount = { 6, 6 }
			},

		},
	},
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "renegade_assault",
				amount = { 16, 20 },
			},
			{
				name = "cultist_melee",
				amount = { 20, 25 }
			},
			{
				name = "chaos_ogryn_bulwark",
				amount = { 1, 1 }
			},
			{
				name = "cultist_berzerker",
				amount = { 2, 2 }
			},
			{
				name = "renegade_executor",
				amount = { 2, 2 }
			},
			{
				name = "renegade_plasma_gunner",
				amount = { 1, 1 }
			},
		},
	},
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "renegade_assault",
				amount = { 16, 20 },
			},
			{
				name = "cultist_melee",
				amount = { 20, 25 }
			},
			{
				name = "cultist_berzerker",
				amount = { 2, 2 }
			},
			{
				name = "renegade_executor",
				amount = { 2, 2 }
			},
			{
				name = "chaos_ogryn_gunner",
				amount = { 1, 1 }
			}
		},
	},
}

renegade_comps.renegade_medium = {
		{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "renegade_melee",
				amount = { 20, 25 }
			},
			{
				name = "renegade_berzerker",
				amount = { 3, 3 }
			},
			{
				name = "renegade_assault",
				amount = { 4, 4 }
			},
			{
				name = "chaos_ogryn_executor",
				amount = { 1, 1 }
			}
		},
	},
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "renegade_assault",
				amount = { 16, 20 },
			},
			{
				name = "renegade_shocktrooper",
				amount = {
					10,
					10
				},
			},
			{
				name = "chaos_ogryn_gunner",
				amount = {
					1,
					2
				},
			},
		},
	},
}


renegade_comps.renegade_small = {
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "renegade_melee",
				amount = { 20, 25 }
			},
			{
				name = "renegade_assault",
				amount = { 10, 15 }
			},
			{
				name = "cultist_berzerker",
				amount = { 3, 3 }
			},
			{
				name = "renegade_shocktrooper",
				amount = { 4, 4 }
			},

		},
	},
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "renegade_assault",
				amount = { 10, 25 }
			},
			{
				name = "renegade_melee",
				amount = { 20, 25 }
			},
			{
				name = "renegade_berzerker",
				amount = { 3, 3 }
			},
			{
				name = "renegade_plasma_gunner",
				amount = { 1, 1 }
			},
			{
				name = "renegade_sniper",
				amount = { 1, 1 }
			},
		},
	},
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "renegade_assault",
				amount = { 10, 25 }
			},
			{
				name = "renegade_melee",
				amount = { 20, 25 }
			},
			{
				name = "renegade_berzerker",
				amount = { 3, 3 }
			},
			{
				name = "chaos_ogryn_gunner",
				amount = { 1, 1 }
			}
		},
	},
}

renegade_comps.renegade_coordinated_ranged_horde = {
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "renegade_assault",
				amount = {
					14,
					17
				},
			},
			{
				name = "renegade_shocktrooper",
				amount = {
					10,
					12
				},
			},
			{
				name = "renegade_plasma_gunner",
				amount = {
					2,
					2
				},
			},
		},
	},
}

renegade_comps.havoc_renegade_coordinated_blockade_behind = {
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
				name = "renegade_berzerker",
				amount = {
					4,
					4
				},
			},
		},
	},
}

renegade_comps.havoc_renegade_coordinated_blockade_ahead = {
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
				name = "renegade_shocktrooper",
				amount = {
					10,
					10
				},
			},
			{
				name = "renegade_rifleman",
				amount = {
					8,
					9
				},
			},
		},
	},
}

renegade_comps.renegade_coordinated_melee_mix = {
	{
		breeds = {
			{
				name = "renegade_assault",
				amount = {
					20,
					22
				},
			},
			{
				name = "renegade_melee",
				amount = {
					11,
					13
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
				name = "renegade_vanguard",
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
	{
		breeds = {
			{
				name = "renegade_assault",
				amount = {
					20,
					22
				},
			},
			{
				name = "renegade_melee",
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
				name = "renegade_plasma_gunner",
				amount = { 1, 1 }
			},
			{
				name = "renegade_assault",
				amount = { 7, 7 }
			},
			{
				name = "chaos_ogryn_bulwark",
				amount = {
					1,
					1
				},
			},
		},
	},
}

renegade_comps.renegade_coordinated_melee_mix_2 = table.clone(renegade_comps.renegade_coordinated_melee_mix)

renegade_comps.renegade_small_coordinated_ranged_horde = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "renegade_assault",
				amount = {
					15,
					15
				},
			},
			{
				name = "renegade_shocktrooper",
				amount = {
					4,
					4
				}
			},
			{
				name = "renegade_plasma_gunner",
				amount = {
					2,
					2
				}
			},

		},
	},
}

renegade_comps.renegade_elite_poxwalkers_small = {
	-- CUSTOM HORDE
	{
		breeds = {
			{
				name = "chaos_poxwalker",
				amount = { 26, 30 },
			},
			{
				name = "chaos_mutated_poxwalker",
				amount = { 32, 40 },
			},
			{
				name = "renegade_plasma_gunner",
				amount = { 1, 1 }
			},
			{
				name = "renegade_assault",
				amount = { 7, 7 }
			},
			{
				name = "renegade_berzerker",
				amount = {
					2,
					2	
				},
			},
			{
				name = "renegade_shocktrooper",
				amount = {
					4,
					4
				}
			},
		},
	},
}

return renegade_comps