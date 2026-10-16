local mod = get_mod("Onslaught")

local SpecialPacingTemplateSettings = "scripts/managers/pacing/specials_pacing/templates/special_pacing_template_settings"

mod:hook_require(SpecialPacingTemplateSettings, function(settings)

	if type(settings) ~= "table" then
        mod:Error("Error: Special pacing settings is not a table!")
        return
    end

	-- settings.interrupter_patrols = INTERRUPTER_PATROLS
	settings.default_foreshadow_stingers = {
		chaos_hound = "wwise/events/minions/play_enemy_chaos_hound_spawn",
		renegade_netgunner = "wwise/events/minions/play_minion_special_netgunner_spawn",
	}

	settings.default_foreshadow_stinger_timers = {
		chaos_hound = 5,
		cultist_mutant = 5,
		renegade_netgunner = 4,
	}

	settings.default_spawn_stingers = {
		chaos_poxwalker_bomber = "wwise/events/minions/play_minion_special_poxwalker_bomber_spawn",
		cultist_mutant = "wwise/events/minions/play_minion_special_mutant_charger_spawn",
	}

	settings.default_optional_prefered_spawn_direction = {
		cultist_grenadier = "ahead",
		renegade_grenadier = "ahead",
		renegade_sniper = "ahead",
	}

	settings.default_optional_mainpath_offset = {
		cultist_grenadier = 30,
		renegade_grenadier = 30,
		renegade_sniper = 40,
	}

	-- Weighted breeds, this is really messy but better than trying to hook_origin special_pacing.lua and having something break every update
	settings.default_breeds = {
		all = {
			"chaos_hound",
			"chaos_poxwalker_bomber",
			"chaos_poxwalker_bomber",
			"cultist_mutant",
			"cultist_mutant",
			"grenadier",
			"grenadier",
			"renegade_netgunner",
			"renegade_sniper",
			"flamer",
			"flamer",
		},
		disablers = {
			"chaos_hound",
			"renegade_netgunner",
			"cultist_mutant",
			"cultist_mutant",
		},
		scramblers = {
			"chaos_poxwalker_bomber",
			"grenadier",
			"renegade_sniper",
			"flamer",
		},
	}

	settings.default_coordinated_strike_breeds = {
		"chaos_hound",
		"chaos_poxwalker_bomber",
		"cultist_mutant",
		"renegade_netgunner",
		"flamer",
		"grenadier"
	}

	settings.default_rush_prevention_breeds = {
		"chaos_hound",
		"cultist_mutant",
	}

	settings.default_loner_prevention_breeds = {
		"chaos_hound",
		"cultist_mutant",
		"renegade_netgunner",
	}

	settings.default_speed_running_prevention_breeds = {
		"chaos_hound",
		"cultist_mutant",
		"renegade_netgunner",
	}

	settings.faction_bound_breeds = {
		flamer = {
			cultist = "cultist_flamer",
			renegade = "renegade_flamer",
		},
		grenadier = {
			cultist = "cultist_grenadier",
			renegade = "renegade_grenadier",
		},
	}

	settings.havoc = {
		default_min_distances_from_target = {
			chaos_beast_of_nurgle = 30,
			chaos_hound = 25,
			chaos_plague_ogryn = 30,
			chaos_poxwalker_bomber = 35,
			chaos_spawn = 30,
			cultist_flamer = 20,
			cultist_grenadier = 20,
			cultist_mutant = 25,
			renegade_flamer = 15,
			renegade_grenadier = 20,
			renegade_netgunner = 28,
			renegade_sniper = 30,
		},
		default_min_spawners_ranges = {
			max = 49,
			min = 20,
		},
		default_num_allowed_disabled_per_alive_targets = {
			{
				0,
				0,
				1,
				1,
			},
			{
				0,
				1,
				1,
				2,
			},
			{
				2,
				2,
				3,
				3,
			},
			{
				3,
				3,
				3,
				3,
			},
			{
				4,
				4,
				4,
				4,
			},
		},
		default_disabler_override_duration = {
			360,
			240,
			160,
			100,
			80,
		},
		default_disabler_target_alone_player_chance = {
			chaos_hound = 0.75,
			cultist_mutant = 0.25,
			renegade_netgunner = 0.5,
		},
		low_max_of_same = {
			chaos_beast_of_nurgle = 1,
			chaos_hound = 1,
			chaos_plague_ogryn = 2,
			chaos_poxwalker_bomber = 1,
			chaos_spawn = 2,
			cultist_flamer = 2,
			cultist_grenadier = 1,
			cultist_mutant = 1,
			flamer = 2,
			grenadier = 2,
			renegade_flamer = 2,
			renegade_grenadier = 2,
			renegade_netgunner = 1,
			renegade_sniper = 2,
		},
		default_max_of_same = {
			chaos_beast_of_nurgle = 1,
			chaos_hound = 2,
			chaos_plague_ogryn = 2,
			chaos_poxwalker_bomber = 2,
			chaos_spawn = 2,
			cultist_flamer = 2,
			cultist_grenadier = 1,
			cultist_mutant = 3,
			flamer = 2,
			grenadier = 2,
			renegade_flamer = 2,
			renegade_grenadier = 2,
			renegade_netgunner = 2,
			renegade_sniper = 2,
		},
		high_max_of_same = {
			chaos_beast_of_nurgle = 1,
			chaos_hound = 3,
			chaos_plague_ogryn = 2,
			chaos_poxwalker_bomber = 3,
			chaos_spawn = 2,
			cultist_flamer = 3,
			cultist_grenadier = 3,
			cultist_mutant = 4,
			flamer = 3,
			grenadier = 3,
			renegade_flamer = 3,
			renegade_grenadier = 3,
			renegade_netgunner = 3,
			renegade_sniper = 2,
		},
		always_update_at_challange_rating_breeds = {
			cultist_grenadier = 2,
			cultist_mutant = 5,
			renegade_grenadier = 2,
			renegade_sniper = 0,
		},
	}

end)