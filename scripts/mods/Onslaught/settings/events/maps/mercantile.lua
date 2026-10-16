local mod = get_mod("Onslaught")

-- chunkname: @scripts/settings/terror_event/terror_event_templates/terror_events_fm_armoury.lua

local TerrorEventQueries = require("scripts/managers/terror_event/utilities/terror_event_queries")
local template = {
	random_events = {
		fm_armoury_gauntlet_wave_main = {
			"event_gauntlet_armoury_main_wave_a",
			1,
			"event_gauntlet_armoury_main_wave_b",
			1,
			"event_gauntlet_armoury_main_wave_c",
			0,
		},
		fm_armoury_gauntlet_wave_final = {
			"event_gauntlet_armoury_final_wave_a",
			1,
			"event_gauntlet_armoury_final_wave_b",
			0,
			"event_gauntlet_armoury_final_wave_c",
			0,
		},
		fm_armoury_fortification_wave_1 = {
			"event_fortification_armoury_wave1_a",
			1,
			"event_fortification_armoury_wave1_b",
			1,
			"event_fortification_armoury_wave1_c", -- too lazy
			0,
		},
		fm_armoury_fortification_wave_final = {
			"event_fortification_final_a",
			1,
			"event_fortification_final_b",
			0,
			"event_fortification_final_c",
			0,
		},
		fm_armoury_fortification_extra_right = {
			"fm_armoury_fortification_extra_right_a",
			1,
			"fm_armoury_fortification_extra_right_b",
			0,
		},
		fm_armoury_fortification_extra_left = {
			"fm_armoury_fortification_extra_left_a",
			1,
			"fm_armoury_fortification_extra_left_b",
			0,
		},
	},
	events = {
		event_pacing_off = {
			{
				"set_pacing_enabled",
				enabled = false,
			},
		},
		event_pacing_on = {
			{
				"set_pacing_enabled",
				enabled = true,
			},
		},
		event_setup_off = {
			{
				"control_pacing_spawns",
				enabled = false,
				spawn_types = {
					"hordes",
					"roamers",
					"trickle_hordes",
					"specials",
					"monsters",
				},
			},
		},
		event_only_roamers_specials_enabled = {
			{
				"control_pacing_spawns",
				enabled = true,
				spawn_types = {
					"roamers",
					"specials",
				},
			},
		},
		event_only_specials_enabled = {
			{
				"control_pacing_spawns",
				enabled = false,
				spawn_types = {
					"hordes",
					"roamers",
					"trickle_hordes",
				},
			},
		},
		event_pacing_on_stop_trickle = {
			{
				"stop_terror_trickle",
			},
			{
				"stop_terror_event",
				stop_event_name = "event_gauntlet_armoury_main_wave_a"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_gauntlet_armoury_main_wave_b"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_gauntlet_armoury_main_wave_c"
			},
			{
				"control_pacing_spawns",
				enabled = true,
				spawn_types = {
					"hordes",
					"roamers",
					"trickle_hordes",
					"specials",
					"monsters",
				},
			},
		},
		event_gauntlet_armoury_main_wave_a = {
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 24,
				max_breed_amount = 45,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_gauntlet_armoury_stoppers",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "renegade_executor",
                breed_amount = 6,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_plasma_gunner",
                breed_amount = 4,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers",
            },
            {
                "spawn_by_breed_name",
                breed_name = "chaos_ogryn_executor",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers"
            },
			{
				"continue_when",
				duration = 15,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 20
				end,
			},
			{
				"start_terror_event",
				start_event_name = "event_gauntlet_armoury_main_wave_b"
			},
		},
		event_gauntlet_armoury_main_wave_b = {
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 15,
				max_breed_amount = 25,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_gauntlet_armoury_stoppers",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 24,
				max_breed_amount = 45,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_gauntlet_armoury_stoppers",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "chaos_ogryn_bulwark",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers"
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_shocktrooper",
                breed_amount = 15,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_gunner",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers",
            },
			{
				"continue_when",
				duration = 15,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 20
				end,
			},
			{
				"start_terror_event",
				start_event_name = "event_gauntlet_armoury_main_wave_a"
			},
		},
		event_gauntlet_armoury_main_wave_c = {
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 24,
				max_breed_amount = 30,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_gauntlet_armoury_stoppers",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "chaos_ogryn_gunner",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers"
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 20,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_shocktrooper",
                breed_amount = 10,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers",
            },
			{
				"continue_when",
				duration = 15,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_armoury_gauntlet_wave_main",
			},
		},
		event_gauntlet_armoury_final_wave_a = {
            {
                "spawn_by_breed_name",
                breed_name = "cultist_grenadier",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers"
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_mutant",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_gauntlet_armoury_stoppers",
            },
			{
				"start_random_terror_event",
				start_event_name = "fm_armoury_gauntlet_wave_main",
			},
		},
		event_gauntlet_armoury_final_wave_b = {
			{
				"start_terror_trickle",
				delay = 1,
				spawner_group = "spawner_gauntlet_armoury_final_right",
				template_name = "standard_melee",
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 12,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_gauntlet_armoury_final_right",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 9,
				spawner_group = "spawner_gauntlet_armoury_final_right",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 2,
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 12,
				breed_tags = {
					{
						"special",
						"disabler",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 12,
				spawner_group = "spawner_gauntlet_armoury_final_right",
				breed_tags = {
					{
						"close",
						"elite",
					},
				},
			},
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 6
				end,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_armoury_gauntlet_wave_main",
			},
		},
		event_gauntlet_armoury_final_wave_c = {
			{
				"start_terror_trickle",
				delay = 1,
				spawner_group = "spawner_gauntlet_armoury_final_front",
				template_name = "standard_melee",
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 12,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_gauntlet_armoury_final_front",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 9,
				spawner_group = "spawner_gauntlet_armoury_final_front",
				breed_tags = {
					{
						"close",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 2,
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 6,
				breed_tags = {
					{
						"special",
						"scrambler",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 12,
				spawner_group = "spawner_gauntlet_armoury_final_front",
				breed_tags = {
					{
						"melee",
						"elite",
					},
				},
			},
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 6
				end,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_armoury_gauntlet_wave_main",
			},
		},
		event_gauntlet_armoury_guard = {
			{
				"spawn_by_points",
				limit_spawners = 3,
				max_breed_amount = 3,
				passive = true,
				points = 12,
				spawner_group = "spawner_gauntlet_passive_elite",
				breed_tags = {
					{
						"melee",
						"elite",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 10,
				max_breed_amount = 10,
				points = 16,
				spawner_group = "spawner_gauntlet_passive_guards",
				breed_tags = {
					{
						"close",
						"roamer",
					},
				},
			},
		},
		fm_armoury_passive_guards = {
			{
				"spawn_by_points",
				limit_spawners = 5,
				max_breed_amount = 5,
                passive = true,
				points = 12,
				spawner_group = "spawner_passive_guards",
				breed_tags = {
					{
						"melee",
						"roamer"
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"continue_when",
				duration = 60,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() == 0
				end,
			},
		},
		event_fortification_armoury_sniper_balcony = {
			{
				"try_inject_special_minion",
				max_breed_amount = 4,
				points = 20,
				spawner_group = "spawner_fortification_armoury_sniper_balcony",
				breed_tags = {
					{
						"special",
						"sniper",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"continue_when",
				duration = 60,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() == 0
				end,
			},
		},
		event_fortification_armoury_wave1_a = {
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 24,
				max_breed_amount = 30,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_armoury_right",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "chaos_ogryn_bulwark",
                breed_amount = 2,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_right",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 5,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_right",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_plasma_gunner",
                breed_amount = 4,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_right",
            },
            {
                "spawn_by_breed_name",
                breed_name = "chaos_ogryn_executor",
                breed_amount = 2,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_right"
            },
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 15
				end,
			},
			{
				"delay",
				duration = 5,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_armoury_fortification_wave_1",
			},
		},
		event_fortification_armoury_wave1_b = {
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 24,
				max_breed_amount = 30,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_armoury_left",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "renegade_rifleman",
                breed_amount = 15,
                delay_until_all_spawned = false,
                spawner_group = "spawner_fortification_armoury_left",
            },
            {
                "spawn_by_breed_name",
                breed_name = "chaos_ogryn_bulwark",
                breed_amount = 2,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_left",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_berzerker",
                breed_amount = 7,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_left",
            },
            {
                "spawn_by_breed_name",
                breed_name = "chaos_ogryn_executor",
                breed_amount = 2,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_left"
            },
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 15
				end,
			},
			{
				"delay",
				duration = 5,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_armoury_fortification_wave_1",
			},
		},
		event_fortification_armoury_wave1_c = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 16,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_armoury_stage",
				breed_tags = {
					{
						"close",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 16,
				spawner_group = "spawner_fortification_armoury_stage",
				breed_tags = {
					{
						"melee",
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 18,
				spawner_group = "spawner_fortification_armoury_stage",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 8,
				spawner_group = "spawner_fortification_armoury_stage",
				breed_tags = {
					{
						"special",
						"scrambler",
					},
				},
			},
			{
				"delay",
				duration = 4,
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 2,
				points = 12,
				spawner_group = "spawner_fortification_armoury_stage",
				breed_tags = {
					{
						"special",
						"disabler",
					},
				},
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_fortification_armoury_stage",
				template_name = "standard_melee",
			},
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 6
				end,
			},
			{
				"delay",
				duration = 5,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_armoury_fortification_wave_1",
			},
		},
		fm_armoury_fortification_extra_left_a = {
			{
				"delay",
				duration = 2,
			},
            {
                "spawn_by_breed_name",
                breed_name = "cultist_mutant",
                breed_amount = 2,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_left",
            },
            {
                "spawn_by_breed_name",
                breed_name = "chaos_ogryn_executor",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_fortification_armoury_left"
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_gunner",
                breed_amount = 1,
                delay_until_all_spawned = false,
                spawner_group = "spawner_fortification_armoury_left"
            },
			{
				"delay",
				duration = 40,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_armoury_fortification_extra_left",
			},
		},
		fm_armoury_fortification_extra_left_b = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 2,
				spawner_group = "spawner_fortification_armoury_left_bottom",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
			{
				"delay",
				duration = 6,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_armoury_fortification_extra_left",
			},
		},
		fm_armoury_fortification_extra_right_a = {
			{
				"delay",
				duration = 2,
			},
            {
                "spawn_by_breed_name",
                breed_name = "cultist_grenadier",
                breed_amount = 1,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_right_bottom",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_assault",
                breed_amount = 20,
                delay_until_all_spawned = false,
                spawner_group = "spawner_fortification_armoury_left"
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 4,
                delay_until_all_spawned = false,
                spawner_group = "spawner_fortification_armoury_left"
            },
			{
				"delay",
				duration = 40,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_armoury_fortification_extra_right",
			},
		},
		fm_armoury_fortification_extra_right_b = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 2,
				spawner_group = "spawner_fortification_armoury_right_bottom",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
			{
				"delay",
				duration = 6,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_armoury_fortification_extra_right",
			},
		},
		event_fortification_final_a = {
			{
				"continue_when",
				duration = 15,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 20
				end,
			},
            {
                "spawn_by_breed_name",
                breed_name = "chaos_beast_of_nurgle",
                breed_amount = 1,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_left",
            },
			{
				"delay",
				duration = 15,
			},
            {
                "spawn_by_breed_name",
                breed_name = "chaos_plague_ogryn",
                breed_amount = 1,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_right",
            },
			{
				"delay",
				duration = 15,
			},
            {
                "spawn_by_breed_name",
                breed_name = "chaos_spawn",
                breed_amount = 1,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_armoury_sniper_balcony",
            },
			{
				"delay",
				duration = 30,
			},
			{
				"continue_when",
				duration = 100,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 3
				end,
			},
			{
				"flow_event",
				flow_event_name = "event_fortification_armoury_final_completed",
			},
		},
		event_fortification_final_b = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 10,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_armoury_right",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 8,
				spawner_group = "spawner_fortification_armoury_right",
				breed_tags = {
					{
						"close",
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 12,
				spawner_group = "spawner_fortification_armoury_right",
				breed_tags = {
					{
						"close",
						"roamer",
					},
				},
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 8,
				spawner_group = "spawner_fortification_armoury_right",
				breed_tags = {
					{
						"special",
						"scrambler",
					},
				},
			},
			{
				"delay",
				duration = 4,
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 12,
				spawner_group = "spawner_fortification_armoury_right",
				breed_tags = {
					{
						"special",
						"disabler",
					},
				},
			},
			{
				"continue_when",
				duration = 100,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 5
				end,
			},
			{
				"flow_event",
				flow_event_name = "event_fortification_armoury_final_completed",
			},
		},
		event_fortification_final_c = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 10,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_armoury_right",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 8,
				spawner_group = "spawner_fortification_armoury_left",
				breed_tags = {
					{
						"close",
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 12,
				spawner_group = "spawner_fortification_armoury_right",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 8,
				spawner_group = "spawner_fortification_armoury_left",
				breed_tags = {
					{
						"special",
						"scrambler",
					},
				},
			},
			{
				"delay",
				duration = 4,
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 12,
				spawner_group = "spawner_fortification_armoury_left",
				breed_tags = {
					{
						"special",
						"disabler",
					},
				},
			},
			{
				"continue_when",
				duration = 100,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 5
				end,
			},
			{
				"flow_event",
				flow_event_name = "event_fortification_armoury_final_completed",
			},
		},
	},
}

return template
