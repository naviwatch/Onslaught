local mod = get_mod("Onslaught")

-- Cut vanilla point costs in half
return {
	multiplier = 0.5,

	breeds = {
		-- CHAOS BREEDS
		"chaos_plague_ogryn",
		"chaos_beast_of_nurgle",
		"chaos_spawn",
		"chaos_daemonhost",
		"chaos_mutator_daemonhost",
		"chaos_hound",
		"chaos_armored_hound",
		"chaos_newly_infected",
		"chaos_armored_infected",
		"chaos_mutated_poxwalker",
		"chaos_lesser_mutated_poxwalker",
		"chaos_ogryn_bulwark",
		"chaos_ogryn_gunner",
		"chaos_ogryn_executor",
		-- "chaos_ogryn_houndmaster",
		"chaos_poxwalker_bomber",
		"chaos_poxwalker",

		-- RENEGADE BREEDS
		"renegade_assault",
		"renegade_executor",
		"renegade_grenadier",
		"renegade_gunner",
		"renegade_plasma_gunner",
		-- "renegade_radio_operator",
		"renegade_melee",
		"renegade_vanguard",
		"renegade_captain",
		"renegade_netgunner",
		"renegade_rifleman",
		"renegade_shocktrooper",
		"renegade_flamer",
		"renegade_sniper",
		"renegade_berzerker",

		-- CULTIST BREEDS
		"cultist_vanguard",
		"cultist_mutant",
		"cultist_flamer",
		"cultist_shocktrooper",
		"cultist_gunner",
		"cultist_grenadier",
		"cultist_melee",
		"cultist_assault",
		"cultist_berzerker",
		"cultist_captain",

		-- ENVIRONMENTAL
		"nurgle_flies",
		"sand_vortex",
	},

	aligned = {
		chaos_armored_infected = "chaos_poxwalker",
		chaos_mutated_poxwalker = "chaos_poxwalker",
		chaos_lesser_mutated_poxwalker = "chaos_poxwalker",
		chaos_armored_hound = "chaos_hound",
		cultist_grenadier = "renegade_grenadier",
	},
}