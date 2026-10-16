local mod = get_mod("Onslaught")

-- chunkname: @scripts/settings/terror_event/terror_event_templates/terror_events_fm_resurgence.lua

local TerrorEventQueries = require("scripts/managers/terror_event/utilities/terror_event_queries")
local template = {
	random_events = {
		fm_resurgence_wave_1 = {
			"event_luggable_resurgence_a",
			1,
			"event_luggable_resurgence_b",
			1,
		},
		fm_resurgence_wave_2 = {
			"event_luggable_resurgence_c",
			1,
			"event_luggable_resurgence_d",
			0,
		},
		fm_resurgence_wave_3 = {
			"event_luggable_resurgence_e",
			1,
			"event_luggable_resurgence_f",
			0,
		},
		fm_resurgence_fort_wave_1 = {
			"event_fort_resurgence_a",
			1,
			"event_fort_resurgence_b",
			1,
		},
		fm_resurgence_fort_wave_2 = {
			"event_fort_resurgence_c",
			1,
			"event_fort_resurgence_d",
			1,
		},
		fm_resurgence_fort_wave_3 = {
			"event_fort_resurgence_e",
			1,
			"event_fort_resurgence_f",
			0,
		},
		fm_resurgence_fort_flush = {
			"event_fort_upper_flush",
			1,
			"event_fort_upper_flush_2",
			0,
			"event_fort_upper_flush_3",
			0,
		},
		fm_resurgence_fort_ranged_flush = {
			"event_fort_ranged_flush_1",
			0,
			"event_fort_ranged_flush_2",
			0,
		},
	},
	events = {
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
		event_stop_trickle = {
			{
				"stop_terror_trickle",
			},
		},
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
		event_hordes_off = {
			{
				"control_pacing_spawns",
				enabled = false,
				spawn_types = {
					"hordes",
				},
			},
		},
		event_hordes_on = {
			{
				"control_pacing_spawns",
				enabled = true,
				spawn_types = {
					"hordes",
				},
			},
		},
		event_only_roamers_specials_enabled = {
			{
				"control_pacing_spawns",
				enabled = false,
				spawn_types = {
					"hordes",
					"trickle_hordes",
				},
			},
		},
		event_pacing_on_stop_trickle = {
			{
				"stop_terror_trickle",
			},
			{
				"set_pacing_enabled",
				enabled = true,
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
		event_luggable_resurgence_a = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 50,
				max_breed_amount = 45,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_resurgence_right",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "renegade_executor",
                breed_amount = 5,
                delay_until_all_spawned = true,
                spawner_group = "spawner_resurgence_right",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 5,
                delay_until_all_spawned = true,
                spawner_group = "spawner_resurgence_right",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_plasma_gunner",
                breed_amount = 3,
                delay_until_all_spawned = true,
                spawner_group = "spawner_resurgence_left",
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
				start_event_name = "fm_resurgence_wave_1",
			},
		},
		event_luggable_resurgence_b = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 50,
				max_breed_amount = 35,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_resurgence_right",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 15,
				max_breed_amount = 25,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_resurgence_right",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "renegade_executor",
                breed_amount = 2,
                delay_until_all_spawned = false,
                spawner_group = "spawner_resurgence_right",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_shocktrooper",
                breed_amount = 5,
                delay_until_all_spawned = true,
                spawner_group = "spawner_resurgence_left",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_gunner",
                breed_amount = 3,
                delay_until_all_spawned = true,
                spawner_group = "spawner_resurgence_right",
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
				start_event_name = "fm_resurgence_wave_1",
			},
		},
		event_luggable_resurgence_c = {
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "renegade_captain",
				breed_amount = 1,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_resurgence_upper",
				buffs = { "mutator_stimmed_minion_red" },
			},
		},
		event_luggable_resurgence_d = {
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 10,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_resurgence_left",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 6,
				spawner_group = "spawner_resurgence_left",
				breed_tags = {
					{
						"melee",
						"elite",
					},
				},
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
				"delay",
				duration = 7,
			},
			{
				"spawn_by_points",
				limit_spawners = 2,
				points = 20,
				spawner_group = "spawner_resurgence_upper",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
			{
				"start_terror_trickle",
				delay = 8,
				spawner_group = "spawner_resurgence_upper",
				template_name = "standard_melee",
			},
			{
				"continue_when",
				duration = 35,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 3
				end,
			},
			{
				"continue_when",
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_wave_2",
			},
		},
		event_luggable_resurgence_e = {
			{
				"try_inject_special_minion",
				max_breed_amount = 4,
				points = 6,
				breed_tags = {
					{
						"special",
						"scrambler",
					},
				},
			},
			{
				"start_terror_trickle",
				delay = 8,
				spawner_group = "spawner_resurgence_upper",
				template_name = "standard_melee",
			},
			{
				"continue_when",
				duration = 35,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 3
				end,
			},
			{
				"continue_when",
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_wave_3",
			},
		},
		event_luggable_resurgence_f = {
			{
				"spawn_by_points",
				limit_spawners = 2,
				points = 12,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_resurgence_left",
				breed_tags = {
					{
						"close",
						"roamer",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 6,
				spawner_group = "spawner_resurgence_left",
				breed_tags = {
					{
						"close",
						"elite",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 6,
				spawner_group = "spawner_resurgence_left",
				breed_tags = {
					{
						"close",
						"elite",
					},
				},
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
				"start_terror_trickle",
				delay = 8,
				spawner_group = "spawner_resurgence_upper",
				template_name = "standard_melee",
			},
			{
				"continue_when",
				duration = 35,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 3
				end,
			},
			{
				"continue_when",
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_wave_3",
			},
		},
		event_luggable_finale = {
			{
				"play_2d_sound",
				sound_event_name = "wwise/events/minions/play_mid_event_horde_signal",
			},
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 15,
				spawner_group = "spawner_resurgence_left",
				breed_tags = {
					{
						"melee",
						"elite",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 15,
				spawner_group = "spawner_resurgence_right",
				breed_tags = {
					{
						"melee",
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 7,
			},
		},
		event_bridge_reinforcements = {
           {
                "delay",
                duration = 10
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 25,
                delay_until_all_spawned = false,
                spawner_group = "spawner_resurgence_bridge_left",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_plasma_gunner",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_resurgence_bridge_left",
            },
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "chaos_ogryn_executor",
				breed_amount = 3,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_resurgence_bridge_left",
				buffs = { "havoc_encroaching_garden" },
			},
		},
		event_traitor_base_guards = {
			{
				"spawn_by_points",
				limit_spawners = 13,
				max_breed_amount = 13,
				passive = true,
				points = 8,
				spawner_group = "traitor_base_guards",
				breed_tags = {
					{
						"roamer",
						"far",
					},
				},
			},
		},
		event_fort_resurgence_a = {
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "chaos_spawn",
				breed_amount = 1,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_fort_event_wall",
				buffs = { "mutator_stimmed_minion_red" },
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "chaos_ogryn_executor",
				breed_amount = 5,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_fort_event_wall",
				buffs = { "mutator_rotten_armor" },
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "cultist_melee",
				breed_amount = 35,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_fort_event_left",
				buffs = { "mutator_stimmed_minion_red" },
			},
			{
				"delay",
				duration = 2
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_fort_wave_2",
			},
		},
		event_fort_resurgence_b = {
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "chaos_plague_ogryn",
				breed_amount = 1,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_fort_event_wall",
				buffs = { "mutator_stimmed_minion_red" },
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "chaos_ogryn_executor",
				breed_amount = 5,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_fort_event_wall",
				buffs = { "mutator_rotten_armor" },
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "cultist_melee",
				breed_amount = 35,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_fort_event_left",
				buffs = { "mutator_stimmed_minion_red" },
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_fort_wave_2",
			},
		},
		event_fort_resurgence_c = {
           {
                "delay",
                duration = 10
            },
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 50,
				max_breed_amount = 45,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fort_event_wall",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "renegade_executor",
                breed_amount = 5,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fort_event_wall",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 5,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fort_event_wall",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_plasma_gunner",
                breed_amount = 3,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fort_event_wall",
            },
			{
				"continue_when",
				duration = 20,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_fort_wave_3",
			},
		},
		event_fort_resurgence_d = {
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 15,
				max_breed_amount = 25,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fort_event_wall",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "renegade_executor",
                breed_amount = 2,
                delay_until_all_spawned = false,
                spawner_group = "spawner_fort_event_wall",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_shocktrooper",
                breed_amount = 5,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fort_event_wall",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_gunner",
                breed_amount = 3,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fort_event_wall",
            },
			{
				"continue_when",
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 12
				end,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_fort_wave_3",
			},
		},
		event_fort_resurgence_e = {
			{
				"try_inject_special_minion",
				max_breed_amount = 3,
				points = 6,
				breed_tags = {
					{
						"special",
						"scrambler",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_fort_flush",
			},
			{
				"delay",
				duration = 4,
			},
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 14,
				max_breed_amount = 4,
				spawner_group = "spawner_fort_event_left",
				breed_tags = {
					{
						"ogryn",
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 25,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_fort_wave_2",
			},
		},
		event_fort_resurgence_f = {
			{
				"spawn_by_points",
				limit_spawners = 2,
				points = 10,
				spawner_group = "spawner_fort_event_wall",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 2,
				points = 12,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fort_event_right",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_fort_flush",
			},
			{
				"delay",
				duration = 4,
			},
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 8,
				spawner_group = "spawner_fort_event_right",
				breed_tags = {
					{
						"melee",
						"elite",
					},
				},
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_fort_ranged_flush",
			},
			{
				"delay",
				duration = 5,
			},
			{
				"continue_when",
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 12,
				breed_tags = {
					{
						"special",
					},
				},
			},
			{
				"delay",
				duration = 7,
			},
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 12,
				spawner_group = "spawner_fort_event_upper",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
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
				"continue_when",
				duration = 35,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 3
				end,
			},
			{
				"continue_when",
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"start_random_terror_event",
				start_event_name = "fm_resurgence_fort_wave_2",
			},
		},
		event_fort_upper_flush = {
			{
				"spawn_by_points",
				limit_spawners = 2,
				points = 14,
				max_breed_amount = 20,
				proximity_spawners = true,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "traitor_base_upper_flush",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 3,
				points = 6,
				spawner_group = "traitor_base_side_flush",
				breed_tags = {
					{
						"special",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
		},
		event_fort_upper_flush_2 = {
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 14,
				proximity_spawners = true,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "traitor_base_side_flush",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 6,
				spawner_group = "traitor_base_side_flush",
				breed_tags = {
					{
						"special",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
		},
		event_fort_upper_flush_3 = {
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 10,
				proximity_spawners = true,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "traitor_base_side_flush",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 2,
				points = 6,
				proximity_spawners = true,
				spawner_group = "traitor_base_upper_flush",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
		},
		event_fort_ranged_flush_1 = {
			{
				"spawn_by_points",
				inverse_proximity_spawners = true,
				limit_spawners = 3,
				points = 12,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "traitor_base_side_flush",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
			{
				"spawn_by_points",
				inverse_proximity_spawners = true,
				limit_spawners = 3,
				points = 8,
				spawner_group = "traitor_base_side_flush",
				breed_tags = {
					{
						"far",
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
		},
		event_fort_ranged_flush_2 = {
			{
				"spawn_by_points",
				inverse_proximity_spawners = true,
				limit_spawners = 3,
				points = 16,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "traitor_base_side_flush",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
			{
				"try_inject_special_minion",
				inverse_proximity_spawners = true,
				limit_spawners = 1,
				max_breed_amount = 1,
				points = 6,
				spawner_group = "traitor_base_side_flush",
				breed_tags = {
					{
						"special",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
		},
		event_fort_finale = {
			{
				"play_2d_sound",
				sound_event_name = "wwise/events/minions/play_mid_event_horde_signal",
			},
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 15,
				spawner_group = "spawner_fort_event_right",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 15,
				spawner_group = "spawner_fort_event_left",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 1,
				points = 6,
				spawner_group = "spawner_fort_event_wall",
				breed_tags = {
					{
						"melee",
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 5,
			},
			{
				"continue_when",
				duration = 110,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() == 0
				end,
			},
			{
				"flow_event",
				flow_event_name = "event_fort_finale_completed",
			},
		},
	},
}

return template
