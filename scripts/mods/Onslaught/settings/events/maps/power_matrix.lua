local mod = get_mod("Onslaught")

local TerrorEventQueries = require("scripts/managers/terror_event/utilities/terror_event_queries")
local template = {
	random_events = {
		lm_cooling_wave_1 = {
			"event_hacking_cooling_a",
			1,
			"event_hacking_cooling_b",
			0,
		},
		lm_cooling_wave_2 = {
			"event_hacking_cooling_c",
			1,
			"event_hacking_cooling_d",
			0,
		},
		lm_cooling_wave_3 = {
			"event_hacking_cooling_e",
			1,
			"event_hacking_cooling_f",
			0,
		},
		lm_cooling_reactor_1 = {
			"event_reactor_cooling_a",
			1,
		},
		lm_cooling_reactor_2 = {
			"event_reactor_cooling_b",
			1,
			"event_reactor_cooling_c",
			0,
		},
		lm_cooling_reactor_3 = {
			"event_reactor_cooling_d",
			1,
			"event_reactor_cooling_e",
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
		event_pacing_on_stop_trickle = {
			{
				"stop_terror_trickle",
			},
            {
                "stop_terror_event",
                stop_event_name = "event_hacking_cooling_b"
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
		event_pacing_on_specials_only = {
			{
				"set_pacing_enabled",
				enabled = true,
			},
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
		event_hacking_cooling_outside_guards = {
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 25,
				max_breed_amount = 25,
				passive = true,
				points = 25,
				spawner_group = "spawner_control_room_guards",
				breed_tags = {
                    {
                        "far",
                        "roamer"
                    },
				},
			},
		},
		event_hacking_cooling_a = {
			{
				"debug_print",
				duration = 3,
				text = "event_hacking_cooling_a",
			},
            {
                "spawn_by_breed_name",
                breed_name = "renegade_executor",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 15,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "chaos_armored_infected",
                breed_amount = 50,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
			{
				"continue_when",
				duration = 15,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 20
				end,
			},
            {
                "spawn_by_breed_name",
                breed_name = "cultist_grenadier",
                breed_amount = 2,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_far",
            },
            {
                "delay",
                duration = 7
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_plasma_gunner",
                breed_amount = 4,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 15,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_gunner",
                breed_amount = 4,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_far",
            },
			{
				"continue_when",
				duration = 20,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 20
				end,
			},
			{
				"start_terror_event",
				start_event_name = "event_hacking_cooling_b",
			},
		},
		event_hacking_cooling_b = {
			{
				"debug_print",
				duration = 3,
				text = "event_hacking_cooling_b",
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 50,
				max_breed_amount = 45,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_cooling_hacking_close",
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
                breed_amount = 15,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_plasma_gunner",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_far",
            },
			{
				"continue_when",
				duration = 20,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 20
				end,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 50,
				max_breed_amount = 45,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_cooling_hacking_close",
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
                breed_amount = 15,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_shocktrooper",
                breed_amount = 15,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_gunner",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_far",
            },
			{
				"continue_when",
				duration = 15,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"start_terror_event",
				start_event_name = "event_hacking_cooling_b",
			},
		},
		event_hacking_cooling_c = {
			{
				"debug_print",
				duration = 3,
				text = "event_hacking_cooling_c",
			},
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 30,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "chaos_ogryn_executor",
				breed_amount = 5,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_cooling_hacking_close",
				buffs = { 
					"mutator_rotten_armor",
					"mutator_stimmed_minion_red",
					"havoc_bolstering"
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "chaos_armored_infected",
                breed_amount = 30,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_far",
            },
			{
				"continue_when",
				duration = 20,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 20
				end,
			},
		},
		event_hacking_cooling_d = {
			{
				"debug_print",
				duration = 3,
				text = "event_hacking_cooling_d",
			},
            {
                "delay",
                duration = 15
            },
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 24,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_cooling_hacking_close",
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
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_plasma_gunner",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_far",
            },
			{
				"continue_when",
				duration = 20,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 24,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_cooling_hacking_close",
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
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_shocktrooper",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_gunner",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_far",
            },
			{
				"continue_when",
				duration = 20,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
		},
		event_hacking_cooling_e = {
			{
				"debug_print",
				duration = 3,
				text = "event_hacking_cooling_e",
			},
			{
				"start_terror_trickle",
				delay = 8,
				spawner_group = "spawner_cooling_hacking_far",
				template_name = "low_ranged",
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "renegade_shocktrooper",
				breed_amount = 30,
				delay_until_all_spawned = false,
				spawner_group = "spawner_cooling_hacking_close",
				buffs = { 
					"havoc_bolstering",
					"mutator_stimmed_minion_red",
					"volatile_on_ranged_death"
				},
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "cultist_berzerker",
				breed_amount = 10,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_cooling_hacking_close",
				buffs = { 
					"havoc_bolstering",
				},
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "renegade_executor",
				breed_amount = 10,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_cooling_hacking_close",
				buffs = { 
					"havoc_bolstering",
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "cultist_grenadier",
                breed_amount = 2,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_far",
            },
            {
                "delay",
                duration = 20
            },
		},
		event_hacking_cooling_f = {
			{
				"debug_print",
				duration = 3,
				text = "event_hacking_cooling_f",
			},
            {
                "delay",
                duration = 15
            },
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 24,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_cooling_hacking_close",
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
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_plasma_gunner",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_far",
            },
			{
				"continue_when",
				duration = 20,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 24,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_cooling_hacking_close",
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
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_shocktrooper",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_close",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_gunner",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_hacking_far",
            },
			{
				"continue_when",
				duration = 20,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
		},
		event_reactor_outside_guards = {
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 25,
				max_breed_amount = 15,
				points = 30,
				spawner_group = "spawner_reactor_guards",
				breed_tags = {
					{
						"roamer",
						"far",
					},
				},
			},
		},
		event_reactor_cooling_a = {
			{
				"play_2d_sound",
				sound_event_name = "wwise/events/minions/play_mid_event_horde_signal",
			},
			{
				"delay",
				duration = 10,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 60,
				max_breed_amount = 50,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_cooling_reactor_1",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 20,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_plasma_gunner",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_shocktrooper",
                breed_amount = 20,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
            },
			{
				"continue_when",
				duration = 20,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 60,
				max_breed_amount = 50,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_cooling_reactor_1",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "renegade_berzerker",
                breed_amount = 10,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_gunner",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
            },
			{
				"continue_when",
				duration = 15,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"start_terror_event",
				start_event_name = "event_reactor_cooling_a",
			},
		},
		event_reactor_cooling_b = {
            {
                "spawn_by_breed_name",
                breed_name = "chaos_beast_of_nurgle",
                breed_amount = 2,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_mutant",
                breed_amount = 10,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
            },
		},
		event_reactor_cooling_c = {
            {
                "spawn_by_breed_name",
                breed_name = "chaos_beast_of_nurgle",
                breed_amount = 2,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_mutant",
                breed_amount = 10,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
            },
		},
		event_reactor_cooling_d = {
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 25,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_executor",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
            },
		},
		event_reactor_cooling_e = {
			{
				"spawn_by_points",
				points = 20,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_cooling_reactor_1",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "chaos_ogryn_executor",
				breed_amount = 7,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_cooling_reactor_1",
				buffs = { 
					"mutator_rotten_armor",
					"havoc_bolstering"
				},
			},
		},
		event_reactor_finale = {
			{
				"debug_print",
				duration = 3,
				text = "event_reactor_finale",
			},
			{
				"play_2d_sound",
				sound_event_name = "wwise/events/minions/play_mid_event_horde_signal",
			},
            {
                "onslaught_spawn_buffed_breed",
                breed_name = "cultist_berzerker",
                breed_amount = 50,
                delay_until_all_spawned = false,
                spawner_group = "spawner_cooling_reactor_1",
				buffs = { 
					"mutator_stimmed_minion_red",
					"havoc_encroaching_garden",
					"volatile_on_ranged_death"
				},
            },
			{
				"continue_when",
				duration = 300,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() == 0
				end,
			},
			{
				"flow_event",
				flow_event_name = "event_reactor_finale_completed",
			},
		},
		event_cooling_end = {
			{
				"debug_print",
				duration = 3,
				text = "event_cooling_end",
			},
		},
	},
}

return template
