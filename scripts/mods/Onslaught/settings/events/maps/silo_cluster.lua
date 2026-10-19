local TerrorEventQueries = require("scripts/managers/terror_event/utilities/terror_event_queries")
local template = {
	random_events = {
		dm_stockpile_demo_wave_1 = {
			"event_demo_stockpile_a",
			1,
			"event_demo_stockpile_b",
			0,
			"event_demo_stockpile_c",
			0,
		},
		dm_stockpile_demo_wave_2 = {
			"event_demo_stockpile_d",
			0,
			"event_demo_stockpile_e",
			0,
			"event_demo_stockpile_f",
			0,
		},
		dm_stockpile_mid_event_1 = {
			"event_mid_stockpile_a",
			1,
			"event_mid_stockpile_b",
			1,
		},
		dm_stockpile_mid_event_2 = {
			"event_mid_stockpile_c",
			1,
			"event_mid_stockpile_d",
			1,
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
				"set_pacing_enabled",
				enabled = true,
			},
			{
				"stop_terror_event",
				stop_event_name = "event_mid_stockpile_a"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_mid_stockpile_b"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_mid_stockpile_c"
			},
			{
				"control_pacing_spawns",
				enabled = true,
				spawn_types = {
					"hordes",
					"roamers",
					"trickle_hordes",
					"monsters",
					"specials",
				},
			},
			{
				"stop_terror_trickle",
			},
		},
		event_mid_stockpile_a = {
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 50,
				max_breed_amount = 50,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_stockpile_elevator_far",
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
				breed_amount = 10,
				delay_until_all_spawned = false,
				spawner_group = "spawner_stockpile_elevator_far",
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "cultist_berzerker",
				breed_amount = 5,
				delay_until_all_spawned = false,
				spawner_group = "spawner_stockpile_elevator_far",
				buffs = { 
					"volatile_on_ranged_death"
				},
			},
            {
                "onslaught_spawn_buffed_breed",
                breed_name = "chaos_ogryn_executor",
                breed_amount = 2,
                limit_spawners = 1,
                spawner_group = "spawner_stockpile_elevator_far",
                buffs = {
					"havoc_bolstering"
				},
            },
            {
                "onslaught_spawn_buffed_breed",
                breed_name = "chaos_poxwalker_bomber",
                breed_amount = 2,
                delay_until_all_spawned = true,
                spawner_group = "spawner_stockpile_elevator_far",
				buffs = {
					"havoc_bolstering",
				}
            },
			{
				"continue_when",
				duration = 35,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 35
				end,
			},
			{
				"start_terror_event",
				start_event_name = "event_mid_stockpile_b",
			},
		},
		event_mid_stockpile_b = {
            {
                "delay",
                duration = 1,
            },
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 50,
				max_breed_amount = 50,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_stockpile_elevator_far",
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
				breed_amount = 2,
				delay_until_all_spawned = false,
				spawner_group = "spawner_stockpile_elevator_far",
			},
            {
                "spawn_by_breed_name",
                breed_name = "renegade_sniper",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_stockpile_elevator_far",
            },
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "cultist_berzerker",
				breed_amount = 20,
				delay_until_all_spawned = false,
				spawner_group = "spawner_stockpile_elevator_far",
				buffs = { 
					"volatile_on_ranged_death"
				},
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "chaos_ogryn_bulwark",
				breed_amount = 2,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_stockpile_elevator_far",
				buffs = { 
					"havoc_encroaching_garden",
					"havoc_bolstering",
                    "volatile_on_ranged_death"
				},
			},
            {
                "onslaught_spawn_buffed_breed",
                breed_name = "renegade_flamer_mutator",
                breed_amount = 1,
                delay_until_all_spawned = true,
                spawner_group = "spawner_stockpile_elevator_far",
				buffs = {
                    "mutator_stimmed_minion_red"
				}
            },
			{
				"continue_when",
				duration = 30,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 35
				end,
			},
			{
				"start_terror_event",
				start_event_name = "event_mid_stockpile_a",
			},
		},
		event_mid_stockpile_c = {
            {
                "spawn_by_breed_name",
                breed_name = "renegade_captain",
                breed_amount = 1,
                max_health_modifier = 0.01,
                delay_until_all_spawned = false,
                spawner_group = "spawner_stockpile_elevator_far",
            },
			{
				"start_terror_event",
				start_event_name = "event_mid_stockpile_a",
			},
		},
		event_mid_stockpile_d = {
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 6,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_stockpile_elevator_close",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 4,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 6,
				spawner_group = "spawner_stockpile_elevator_close",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 4,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 6,
				spawner_group = "spawner_stockpile_elevator_close",
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
				points = 6,
				spawner_group = "spawner_stockpile_elevator_close",
				breed_tags = {
					{
						"melee",
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 6,
			},
			{
				"continue_when",
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 4
				end,
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 12,
				spawner_group = "spawner_stockpile_elevator_far",
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
				spawner_group = "spawner_stockpile_elevator_close",
				template_name = "low_melee",
			},
			{
				"continue_when",
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 4
				end,
			},
			{
				"delay",
				duration = 6,
			},
			{
				"start_random_terror_event",
				start_event_name = "dm_stockpile_mid_event_2",
			},
		},
		event_demo_stockpile_a = {
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 7,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_stockpile_left",
				breed_tags = {
					{
						"horde",
						"melee",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 7,
				spawner_group = "spawner_stockpile_forward",
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
				points = 7,
				spawner_group = "spawner_stockpile_left",
				breed_tags = {
					{
						"horde",
						"melee",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 6,
				spawner_group = "spawner_stockpile_right",
				breed_tags = {
					{
						"melee",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_stockpile_left",
				template_name = "standard_melee",
			},
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 4
				end,
			},
			{
				"delay",
				duration = 8,
			},
			{
				"start_random_terror_event",
				start_event_name = "dm_stockpile_demo_wave_1",
			},
		},
		event_demo_stockpile_b = {
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 20,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_stockpile_forward",
				breed_tags = {
					{
						"horde",
						"melee",
					},
				},
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 12,
				spawner_group = "spawner_stockpile_forward",
				breed_tags = {
					{
						"special",
						"disabler",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_stockpile_forward",
				template_name = "standard_melee",
			},
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 4
				end,
			},
			{
				"delay",
				duration = 8,
			},
			{
				"start_random_terror_event",
				start_event_name = "dm_stockpile_demo_wave_1",
			},
		},
		event_demo_stockpile_c = {
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 8,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_stockpile_right",
				breed_tags = {
					{
						"close",
						"roamer",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 8,
				spawner_group = "spawner_stockpile_forward",
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
				spawner_group = "spawner_stockpile_left",
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
				points = 12,
				spawner_group = "spawner_stockpile_forward",
				breed_tags = {
					{
						"special",
						"scrambler",
					},
				},
			},
			{
				"delay",
				duration = 6,
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_stockpile_right",
				template_name = "standard_melee",
			},
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 4
				end,
			},
			{
				"delay",
				duration = 8,
			},
			{
				"start_random_terror_event",
				start_event_name = "dm_stockpile_demo_wave_1",
			},
		},
		event_demo_stockpile_d = {
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 8,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_stockpile_left",
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
				points = 10,
				spawner_group = "spawner_stockpile_forward",
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
				points = 12,
				spawner_group = "spawner_stockpile_forward",
				breed_tags = {
					{
						"special",
						"disabler",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_stockpile_right",
				template_name = "standard_melee",
			},
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 4
				end,
			},
			{
				"delay",
				duration = 8,
			},
			{
				"start_random_terror_event",
				start_event_name = "dm_stockpile_demo_wave_2",
			},
		},
		event_demo_stockpile_e = {
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 5,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_stockpile_right",
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
				points = 5,
				spawner_group = "spawner_stockpile_forward",
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
				points = 5,
				spawner_group = "spawner_stockpile_left",
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
				spawner_group = "spawner_stockpile_forward",
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
				points = 12,
				spawner_group = "spawner_stockpile_forward",
				breed_tags = {
					{
						"special",
						"scrambler",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_stockpile_forward",
				template_name = "standard_melee",
			},
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 4
				end,
			},
			{
				"delay",
				duration = 8,
			},
			{
				"start_random_terror_event",
				start_event_name = "dm_stockpile_demo_wave_2",
			},
		},
		event_demo_stockpile_f = {
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 12,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_stockpile_forward",
				breed_tags = {
					{
						"close",
						"roamer",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 8,
				spawner_group = "spawner_stockpile_right",
				breed_tags = {
					{
						"close",
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 4,
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_stockpile_right",
				template_name = "standard_melee",
			},
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 4
				end,
			},
			{
				"delay",
				duration = 8,
			},
			{
				"start_random_terror_event",
				start_event_name = "dm_stockpile_demo_wave_2",
			},
		},
		event_demo_stockpile_horde_escape = {
			{
				"delay",
				duration = 5,
			},
			{
				"spawn_by_points",
				points = 15,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_stockpile_forward",
				breed_tags = {
					{
						"horde",
					},
				},
			},
		},
	},
}

return template
