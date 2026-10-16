local mod = get_mod("Onslaught")

-- chunkname: @scripts/settings/terror_event/terror_event_templates/terror_events_fm_cargo.lua

local TerrorEventQueries = require("scripts/managers/terror_event/utilities/terror_event_queries")
local template = {
	random_events = {
		fm_cargo_hacking_wave_1 = {
			"event_hacking_cargo_a",
			1,
			"event_hacking_cargo_c",
			0,
		},
		fm_cargo_hacking_wave_2 = {
			"event_hacking_cargo_b",
			1,
			"event_hacking_cargo_d",
			0,
		},
		fm_cargo_fortification_wave_1 = {
			"event_fortification_a",
			1,
			"event_fortification_b",
			0,
			"event_fortification_c",
			0,
			"event_fortification_d",
			0,
		},
		fm_cargo_fortification_monsters = {
			"event_fortification_spawn_cs",
			1,
			"event_fortification_spawn_po",
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
				stop_event_name = "event_hacking_cargo_a"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_hacking_cargo_b"
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
		event_set_specials_pacing_spawner_groups = {
			{
				"set_specials_pacing_spawner_groups",
				spawner_groups = {
					"spawner_fortification_cargo_south",
					"spawner_fortification_cargo_north",
				},
			},
		},
		event_reset_specials_pacing_spawner_groups = {
			{
				"reset_specials_pacing_spawner_groups",
			},
		},
		event_stop_trickle = {
			{
				"stop_terror_trickle",
			},
		},
		event_hacking_cargo_a = {
			{
				"delay",
				duration = 1,
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "chaos_ogryn_executor",
				breed_amount = 1,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_hacking_cargo_a",
				buffs = { 
					"mutator_stimmed_minion_red"
				},
			},
            {
                "onslaught_spawn_buffed_breed",
                breed_name = "chaos_ogryn_bulwark",
                breed_amount = 2,
                delay_until_all_spawned = false,
                spawner_group = "spawner_hacking_cargo_a",
				buffs = {
					"havoc_encroaching_garden"
				}
            },
			{
				"delay",
				duration = 5,
			},
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 4,
                delay_until_all_spawned = false,
                spawner_group = "spawner_hacking_cargo_a"
            },
            {
                "spawn_by_breed_name",
                breed_name = "renegade_gunner",
                breed_amount = 3,
                delay_until_all_spawned = true,
                spawner_group = "spawner_hacking_cargo_a"
            },
            {
                "onslaught_spawn_buffed_breed",
                breed_name = "renegade_rifleman",
                breed_amount = 4,
                delay_until_all_spawned = true,
                spawner_group = "spawner_hacking_cargo_a",
				buffs = {
					"havoc_encroaching_garden"
				}
            },
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 50,
				max_breed_amount = 45,
				spawner_group = "spawner_hacking_cargo_a",
				breed_tags = {
					{
						"melee",
						"horde",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 50,
				max_breed_amount = 5,
				spawner_group = "spawner_hacking_cargo_a",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 20
				end,
			},
			{
				"start_terror_event",
				start_event_name = "event_hacking_cargo_a",
			},
		},
		event_hacking_cargo_b = {
			{
				"continue_when",
				duration = 25,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 15
				end,
			},
            {
                "spawn_by_breed_name",
                breed_name = "renegade_executor",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_hacking_cargo_b"
            },
			{
				"delay",
				duration = 8,
			},
            {
                "onslaught_spawn_buffed_breed",
                breed_name = "chaos_poxwalker_bomber",
                breed_amount = 3,
                delay_until_all_spawned = true,
                spawner_group = "spawner_hacking_cargo_b",
				buffs = {
					"havoc_bolstering"
				}
            },
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 50,
				max_breed_amount = 5,
				spawner_group = "spawner_hacking_cargo_b",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"start_terror_event",
				start_event_name = "event_hacking_cargo_b",
			},
		},
		event_hacking_cargo_c = {
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 15
				end,
			},
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 4,
				points = 20,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_hacking_cargo_c",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 4,
				points = 12,
				spawner_group = "spawner_hacking_cargo_c",
				breed_tags = {
					{
						"far",
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 8,
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_hacking_cargo_c",
				template_name = "standard_melee",
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 6,
				spawner_group = "spawner_hacking_cargo_special_3",
				breed_tags = {
					{
						"special",
						"scrambler",
					},
				},
			},
			{
				"continue_when",
				duration = 60,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 8
				end,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 14,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_hacking_cargo_c",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
		},
		event_hacking_cargo_d = {
			{
				"continue_when",
				duration = 40,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 15
				end,
			},
			{
				"delay",
				duration = 1,
			},
			{
				"spawn_by_points",
				limit_spawners = 4,
				points = 20,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_hacking_cargo_a",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 4,
				points = 12,
				spawner_group = "spawner_hacking_cargo_a",
				breed_tags = {
					{
						"far",
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 8,
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_hacking_cargo_e",
				template_name = "standard_melee",
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 12,
				spawner_group = "spawner_hacking_cargo_special_2",
				breed_tags = {
					{
						"special",
					},
				},
			},
			{
				"continue_when",
				duration = 60,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 8
				end,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 10,
				spawner_group = "spawner_hacking_cargo_d",
				breed_tags = {
					{
						"melee",
						"roamer",
					},
				},
			},
		},
		event_hacking_transit_guard = {
			{
				"spawn_by_points",
				limit_spawners = 3,
				max_breed_amount = 3,
				passive = true,
				points = 15,
				spawner_group = "spawner_station_hacking_elite",
				breed_tags = {
					{
						"elite",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 12,
				max_breed_amount = 9,
				passive = true,
				points = 12,
				spawner_group = "spawner_station_hacking_guard",
				breed_tags = {
					{
						"roamer",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
		},
		event_fortification_guard_a = {
			{
				"spawn_by_points",
				limit_spawners = 5,
				max_breed_amount = 5,
                passive = true,
				points = 12,
				spawner_group = "spawner_fortification_guard_elite_a",
				breed_tags = {
					{
						"melee",
						"elite"
					},
				},
				excluded_breed_tags = {
					"witch",
				},
			},
			{
				"delay",
				duration = 3,
			},
		},
		event_fortification_guard_b = {
			{
				"spawn_by_points",
				limit_spawners = 4,
				max_breed_amount = 4,
				passive = true,
				points = 22,
				spawner_group = "spawner_fortification_guard_elite_b",
				breed_tags = {
					{
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
		},
		event_fortification_guard_c = {
			{
				"spawn_by_points",
				limit_spawners = 4,
				max_breed_amount = 4,
				passive = true,
				points = 22,
				spawner_group = "spawner_fortification_guard_elite_c",
				breed_tags = {
					{
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
		},
		event_fortification_guard_d = {
			{
				"spawn_by_points",
				limit_spawners = 4,
				max_breed_amount = 4,
				passive = true,
				points = 22,
				spawner_group = "spawner_fortification_guard_elite_d",
				breed_tags = {
					{
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 3,
			},
		},
		event_fortification_horde_a = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 6,
				points = 30,
				max_breed_amount = 30,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_horde_a",
				breed_tags = {
					{
						"horde",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "cultist_mutant",
                breed_amount = 3,
                delay_until_all_spawned = false,
                spawner_group = "spawner_fortification_horde_a"
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 3,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_horde_a"
            },
		},
		event_fortification_horde_b = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 6,
				points = 30,
				max_breed_amount = 30,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_horde_b",
				breed_tags = {
					{
						"horde",
					},
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "chaos_armored_hound",
                breed_amount = 2,
                delay_until_all_spawned = false,
                spawner_group = "spawner_fortification_horde_a"
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 3,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_horde_a"
            },
		},
		event_fortification_horde_c = {
            {
                "spawn_by_breed_name",
                breed_name = "cultist_mutant",
                breed_amount = 5,
                delay_until_all_spawned = false,
                spawner_group = "spawner_fortification_horde_a"
            },
			{
				"continue_when",
				duration = 300,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 2
				end,
			},
		},
		event_fortification_elite_a = {
			{
				"spawn_by_points",
				limit_spawners = 4,
				points = 18,
				max_breed_amount = 30,
				proximity_spawners = true,
				spawner_group = "spawner_fortification_cargo_hatches",
				breed_tags = {
					{
						"horde",
					},
				},
			},
			{
				"delay",
				duration = 10,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 30,
				max_breed_amount = 5,
				spawner_group = "spawner_fortification_elite_a",
				breed_tags = {
					{
						"elite",
					},
				},
			},
			{
				"delay",
				duration = 20,
			},
			{
				"continue_when",
				duration = 15,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 5
				end,
			},
			{
				"delay",
				duration = 10,
			},
			{
				"flow_event",
				flow_event_name = "event_fortification_final_wave",
			},
		},
		event_fortification_trickle = {
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 50,
				max_breed_amount = 40,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_cargo_north",
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
                breed_amount = 10,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_cargo_north",
            },
            {
                "spawn_by_breed_name",
                breed_name = "cultist_berzerker",
                breed_amount = 25,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_cargo_north",
            },
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "renegade_shocktrooper",
				breed_amount = 30,
				delay_until_all_spawned = false,
				spawner_group = "spawner_fortification_cargo_north",
				buffs = { 
					"mutator_stimmed_minion_red",
					"havoc_bolstering"
				},
			},
			{
				"continue_when",
				duration = 15,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 20
				end,
			},
			{
				"spawn_by_points",
				limit_spawners = 3,
				points = 15,
				max_breed_amount = 15,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_cargo_north",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "renegade_executor",
				breed_amount = 15,
				delay_until_all_spawned = false,
				spawner_group = "spawner_fortification_cargo_north",
				buffs = { 
					"havoc_bolstering"
				},
			},
            {
                "spawn_by_breed_name",
                breed_name = "renegade_shocktrooper",
                breed_amount = 40,
                delay_until_all_spawned = false,
                spawner_group = "spawner_fortification_cargo_north",
            },
            {
                "spawn_by_breed_name",
                breed_name = "chaos_ogryn_gunner",
                breed_amount = 5,
                delay_until_all_spawned = true,
                spawner_group = "spawner_fortification_cargo_north",
            },
			{
				"continue_when",
				duration = 20,
				condition = function ()
					return TerrorEventQueries.num_alive_minions() < 10
				end,
			},
			{
				"start_terror_event",
				start_event_name = "event_fortification_trickle"
			}
		},
		event_fortification_spawn_cs = {
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "chaos_spawn",
				breed_amount = 1,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_fortification_monster_cs",
				buffs = { 
					"mutator_stimmed_minion_red",
					"havoc_encroaching_garden"
				},
			},
			{
				"play_3d_sound_from_spawners",
				sound_event_name = "wwise/events/minions/play_terror_event_alarm_monster_01",
				spawner_group = "spawner_fortification_monster_cs",
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_horde_a"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_horde_b"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_horde_c"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_elite_a"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_trickle"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_a"
			},
			{
				"delay",
				duration = 2,
			},
			{
				"flow_event",
				flow_event_name = "event_fortification_spawned_cs",
			},
			{
				"continue_when",
				condition = function ()
					return TerrorEventQueries.num_alive_minions() == 0
				end,
			},
			{
				"flow_event",
				flow_event_name = "event_fortification_monster_dead",
			},
		},
		event_fortification_spawn_po = {
			{
				"onslaught_spawn_buffed_breed",
				breed_name = "chaos_spawn",
				breed_amount = 1,
				limit_spawners = 1,
				delay_until_all_spawned = false,
				spawner_group = "spawner_fortification_monster_cs",
				buffs = { 
					"mutator_stimmed_minion_red",
					"havoc_encroaching_garden"
				},
			},
			{
				"play_3d_sound_from_spawners",
				sound_event_name = "wwise/events/minions/play_terror_event_alarm_monster_01",
				spawner_group = "spawner_fortification_monster_cs",
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_horde_a"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_horde_b"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_horde_c"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_elite_a"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_trickle"
			},
			{
				"stop_terror_event",
				stop_event_name = "event_fortification_a"
			},
			{
				"delay",
				duration = 2,
			},
			{
				"flow_event",
				flow_event_name = "event_fortification_spawned_po",
			},
			{
				"continue_when",
				condition = function ()
					return TerrorEventQueries.num_alive_minions() == 0
				end,
			},
			{
				"flow_event",
				flow_event_name = "event_fortification_monster_dead",
			},
		},
		event_fortification_a = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 4,
				points = 12,
				max_breed_amount = 30,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_cargo_south",
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
				limit_spawners = 5,
				points = 20,
				max_breed_amount = 5,
				proximity_spawners = true,
				spawner_group = "spawner_fortification_cargo_hatches",
				breed_tags = {
					{
						"elite",
						"melee"
					},
				},
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 3,
				points = 12,
				spawner_group = "spawner_fortification_cargo_special_1",
				breed_tags = {
					{
						"special",
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
				points = 8,
				spawner_group = "spawner_fortification_cargo_sniper_1",
				breed_tags = {
					{
						"special",
						"sniper",
					},
				},
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
				"flow_event",
				flow_event_name = "event_fortification_wave_dead",
			},
		},
		event_fortification_b = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 4,
				points = 18,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_cargo_north",
				breed_tags = {
					{
						"far",
						"roamer",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 4,
				points = 12,
				spawner_group = "spawner_fortification_cargo_north",
				breed_tags = {
					{
						"far",
						"elite",
					},
				},
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 12,
				spawner_group = "spawner_fortification_cargo_special_2",
				breed_tags = {
					{
						"special",
					},
				},
			},
			{
				"delay",
				duration = 4,
			},
			{
				"spawn_by_points",
				limit_spawners = 5,
				points = 20,
				proximity_spawners = true,
				spawner_group = "spawner_fortification_cargo_hatches",
				breed_tags = {
					{
						"horde",
					},
				},
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 8,
				spawner_group = "spawner_fortification_cargo_sniper_2",
				breed_tags = {
					{
						"special",
						"sniper",
					},
				},
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_fortification_cargo_north",
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
				"flow_event",
				flow_event_name = "event_fortification_wave_dead",
			},
		},
		event_fortification_c = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 4,
				points = 16,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_cargo_north",
				breed_tags = {
					{
						"close",
						"roamer",
					},
				},
			},
			{
				"spawn_by_points",
				limit_spawners = 4,
				points = 16,
				spawner_group = "spawner_fortification_cargo_north",
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
				spawner_group = "spawner_fortification_cargo_special_2",
				breed_tags = {
					{
						"special",
					},
				},
			},
			{
				"delay",
				duration = 4,
			},
			{
				"spawn_by_points",
				limit_spawners = 5,
				points = 20,
				proximity_spawners = true,
				spawner_group = "spawner_fortification_cargo_hatches",
				breed_tags = {
					{
						"horde",
					},
				},
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 12,
				spawner_group = "spawner_fortification_cargo_sniper_2",
				breed_tags = {
					{
						"special",
						"scrambler",
					},
				},
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_fortification_cargo_north",
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
				"flow_event",
				flow_event_name = "event_fortification_wave_dead",
			},
		},
		event_fortification_d = {
			{
				"delay",
				duration = 2,
			},
			{
				"spawn_by_points",
				limit_spawners = 6,
				points = 30,
				sound_event_name = "wwise/events/minions/play_terror_event_alarm",
				spawner_group = "spawner_fortification_horde_b",
				breed_tags = {
					{
						"horde",
					},
				},
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 12,
				spawner_group = "spawner_fortification_cargo_special_1",
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
				"spawn_by_points",
				limit_spawners = 5,
				points = 20,
				proximity_spawners = true,
				spawner_group = "spawner_fortification_cargo_hatches",
				breed_tags = {
					{
						"horde",
					},
				},
			},
			{
				"try_inject_special_minion",
				max_breed_amount = 1,
				points = 12,
				spawner_group = "spawner_fortification_cargo_special_1",
				breed_tags = {
					{
						"special",
						"scrambler",
					},
				},
			},
			{
				"start_terror_trickle",
				delay = 4,
				spawner_group = "spawner_fortification_cargo_south",
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
				"flow_event",
				flow_event_name = "event_fortification_wave_dead",
			},
		},
		event_fortification_final_timer = {
			{
				"continue_when",
				duration = 30,
				condition = function ()
					return TerrorEventQueries.num_aggroed_minions_in_level() < 7
				end,
			},
			{
				"flow_event",
				flow_event_name = "event_fortification_spawn_final",
			},
		},
	},
}

return template
