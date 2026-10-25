local mod = get_mod("Onslaught")

local HordePacing = require("scripts/managers/pacing/horde_pacing/horde_pacing")
local HordeCompositions = require("scripts/managers/pacing/horde_pacing/horde_compositions")

-- Distances are in meters; trickle.main_path_offset also accepts a { min, max } range.
local HORDE_SPAWN_DISTANCES = {
	far_vector = {
		main_path_distance_from_targets = { 70, 90 },
		euclidean_distance_from_targets = 50,
	},
	far_distance = {
		main_path_distance_from_targets = { 70, 90 },
		euclidean_distance_from_targets = 50,
	},
	ambush = {
		min_distance_from_players = 35,
		max_distance_from_players = 50,
		initial_offset = 2,
		minion_spawner_radius_checks = { 8, 12, 15, 25 },
		max_spawn_locations = 10,
	},
	trickle = {
		min_distance_from_players = 25,
		main_path_offset = 35,
		occluded_spawn_range = 3,
	},
}

local function apply_far_horde_distances(template, settings)
	template.main_path_distance_from_targets = table.clone(settings.main_path_distance_from_targets)
	template.euclidean_distance_from_targets = settings.euclidean_distance_from_targets
end

local HordeTemplates = require("scripts/managers/horde/horde_templates")

apply_far_horde_distances(assert(HordeTemplates.far_vector_horde), HORDE_SPAWN_DISTANCES.far_vector)
apply_far_horde_distances(assert(HordeTemplates.far_distance_horde), HORDE_SPAWN_DISTANCES.far_distance)

local function pack_returns(...)
	return {
		n = select("#", ...),
		...,
	}
end

local active_horde_spawn_distance_context

local function with_horde_spawn_distance_context(context, callback, ...)
	local args = pack_returns(...)
	local previous_context = active_horde_spawn_distance_context
	local results

	active_horde_spawn_distance_context = context

	local success, err = xpcall(function()
		results = pack_returns(callback(unpack(args, 1, args.n)))
	end, function(error_message)
		return error_message
	end)

	active_horde_spawn_distance_context = previous_context

	if not success then
		error(err, 0)
	end

	return unpack(results, 1, results.n)
end

local SpawnPointQueries = require("scripts/managers/main_path/utilities/spawn_point_queries")

mod:hook(SpawnPointQueries, "get_occluded_positions", function(func, nav_world, nav_spawn_points, from_position, human_positions, offset_range, num_groups, optional_min_distance, optional_max_distance, optional_initial_offset, optional_only_search_forward, optional_disallowed_positions)
	if active_horde_spawn_distance_context == "ambush" then
		local settings = HORDE_SPAWN_DISTANCES.ambush

		optional_min_distance = settings.min_distance_from_players
		optional_max_distance = settings.max_distance_from_players
		optional_initial_offset = settings.initial_offset
	end

	return func(nav_world, nav_spawn_points, from_position, human_positions, offset_range, num_groups, optional_min_distance, optional_max_distance, optional_initial_offset, optional_only_search_forward, optional_disallowed_positions)
end)

mod:hook(SpawnPointQueries, "get_random_occluded_position", function(func, nav_world, nav_spawn_points, from_position, side, offset_range, num_groups, optional_min_distance, optional_max_distance, optional_initial_offset, optional_only_search_forward, optional_disallowed_positions)
	if active_horde_spawn_distance_context == "trickle" then
		optional_min_distance = HORDE_SPAWN_DISTANCES.trickle.min_distance_from_players
	end

	return func(nav_world, nav_spawn_points, from_position, side, offset_range, num_groups, optional_min_distance, optional_max_distance, optional_initial_offset, optional_only_search_forward, optional_disallowed_positions)
end)

local ambush_template = assert(HordeTemplates.ambush_horde)
local ambush_settings = HORDE_SPAWN_DISTANCES.ambush

ambush_template.minion_spawner_radius_checks = table.clone(ambush_settings.minion_spawner_radius_checks)
ambush_template.max_spawn_locations = ambush_settings.max_spawn_locations

local ambush_execute = ambush_template.execute

ambush_template.execute = function(...)
	return with_horde_spawn_distance_context("ambush", ambush_execute, ...)
end

local trickle_template = assert(HordeTemplates.trickle_horde)

trickle_template.occluded_spawn_range = HORDE_SPAWN_DISTANCES.trickle.occluded_spawn_range

local trickle_execute = trickle_template.execute

trickle_template.execute = function(...)
	return with_horde_spawn_distance_context("trickle", trickle_execute, ...)
end


-- Custom horde compositions, load them all into one
local cultist_comps = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/horde/cultist/cultist_horde")
local cultist_trickle = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/horde/cultist/cultist_trickle")
local renegade_comps = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/horde/renegade/renegade_horde")
local renegade_trickle = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/horde/renegade/renegade_trickle")

local CUSTOM_COMPOSITIONS = {}

for name, comp in pairs(cultist_comps) do
    CUSTOM_COMPOSITIONS[name] = comp
end

for name, comp in pairs(cultist_trickle) do
    CUSTOM_COMPOSITIONS[name] = comp
end

for name, comp in pairs(renegade_comps) do
    CUSTOM_COMPOSITIONS[name] = comp
end

for name, comp in pairs(renegade_trickle) do
    CUSTOM_COMPOSITIONS[name] = comp
end

for name, comp in pairs(CUSTOM_COMPOSITIONS) do
	comp.name = name
end

-- mod:echo(string.format("Loaded %d custom compositions", table.size(CUSTOM_COMPOSITIONS)))

-- Trickle horde compositions
local function custom_comp(name)
	local comp = CUSTOM_COMPOSITIONS[name]

	if not comp then
		mod:error(string.format("[Onslaught] Missing custom trickle composition: %s", name))
	end

	return comp
end

local function trickle_faction_set(high_set, poxwalker_name)
	return {
		none = high_set,
		low = high_set,
		high = high_set,
		waiting_for_ramp_clear = high_set,
		poxwalkers = {
			custom_comp(poxwalker_name),
		},
	}
end

local DW_HIGH_TRICKLE_HORDE_COMPOSITIONS = {
	renegade = trickle_faction_set({
		custom_comp("renegade_trickle_riflemen_high"),
		custom_comp("renegade_trickle_gunners"),
		custom_comp("renegade_trickle_melee_elites"),
		custom_comp("renegade_trickle_ogryn_gunners"),
		custom_comp("renegade_trickle_ogryn_bulwarks"),
		custom_comp("renegade_trickle_ogryn_executors"),
	}, "renegade_trickle_melee"),
	cultist = trickle_faction_set({
		custom_comp("cultist_trickle_assaulters_high"),
		custom_comp("cultist_trickle_gunners"),
		custom_comp("cultist_trickle_melee_elites"),
		custom_comp("cultist_trickle_ogryn_gunners"),
		custom_comp("cultist_trickle_ogryn_bulwarks"),
		custom_comp("cultist_trickle_ogryn_executors"),
	}, "cultist_trickle_melee"),
}

-- Configuration
local COMPOSITION_OVERRIDES = {
	-- Renegade Hordes
	["havoc_renegade_medium"] = "havoc_renegade_medium",
	["havoc_infected_medium"] = "havoc_infected_medium",
	["infected_medium"] = "infected_medium",
	["havoc_infected_large"] = "havoc_infected_large",
	["infected_small"] = "infected_small",
	["renegade_medium"] = "renegade_medium",
	["renegade_small"] = "renegade_small",
	["renegade_coordinated_ranged_horde"] = "renegade_coordinated_ranged_horde",
	["havoc_renegade_coordinated_blockade_behind"] = "havoc_renegade_coordinated_blockade_behind",
	["havoc_renegade_coordinated_blockade_ahead"] = "havoc_renegade_coordinated_blockade_ahead",
	["renegade_coordinated_melee_mix"] = "renegade_coordinated_melee_mix",
	["renegade_coordinated_melee_mix_2"] = "renegade_coordinated_melee_mix_2",
	["renegade_small_coordinated_ranged_horde"] = "renegade_small_coordinated_ranged_horde",
	["renegade_elite_poxwalkers_small"] = "renegade_elite_poxwalkers_small",

	-- Cultist Hordes
	["havoc_cultist_coordinated_ranged_mixed_horde"] = "havoc_cultist_coordinated_ranged_mixed_horde",
	["havoc_cultist_coordinated_blockade_behind"] = "havoc_cultist_coordinated_blockade_behind",
	["havoc_cultist_coordinated_blockade_ahead"] = "havoc_cultist_coordinated_blockade_ahead",
	["cultist_coordinated_ranged_horde"] = "cultist_coordinated_ranged_horde",
	["cultist_coordinated_melee_mix"] = "cultist_coordinated_melee_mix",
	["cultist_coordinated_melee_mix_2"] = "cultist_coordinated_melee_mix_2",
	["cultist_small_coordinated_ranged_horde"] = "cultist_small_coordinated_ranged_horde",
	["cultist_elite_poxwalkers_small"] = "cultist_elite_poxwalkers_small",
}

-- Helpers
local function find_composition_name(target_comp)
	if type(target_comp) ~= "table" then
		return nil
	end

	if target_comp.name then
		return target_comp.name
	end

	for name, comp in pairs(HordeCompositions) do
		if comp == target_comp then
			return name
		end
	end

	return nil
end

-----------
-- Hooks --
-----------

local COORDINATED_STRIKE_CHANCE = 0.5

mod:hook(HordePacing, "_evaluate_coordinated_horde_strike", function(func, self, target_side_id)
	if math.random() >= COORDINATED_STRIKE_CHANCE then
		return nil
	end

	return func(self, target_side_id)
end)

mod:hook(HordePacing, "_spawn_horde_wave", function(func, self, template, side_id, target_side_id, current_wave, horde_type, horde_template, compositions, optional_main_path_offset, optional_num_tries, optional_disallowed_positions, optional_spawn_max_health_modifier, optional_prefered_direction, optional_target_unit, optional_skip_spawners)
	if not compositions then
		return nil
	end

	local comp_name = find_composition_name(compositions)
	local override_comp_name = comp_name and COMPOSITION_OVERRIDES[comp_name]
	local custom = override_comp_name and CUSTOM_COMPOSITIONS[override_comp_name]

	if custom and #custom > 0 then
		local random_index = math.random(1, #custom)
		local chosen_variant = {
			custom[random_index],
			name = override_comp_name,
		}

		if mod.debug_mode then
			mod:echo(string.format("[HORDE SPAWN] %s -> %s (variant %d/%d)", comp_name, override_comp_name, random_index, #custom))
		end

		return func(self, template, side_id, target_side_id, current_wave, horde_type, horde_template, chosen_variant, optional_main_path_offset, optional_num_tries, optional_disallowed_positions, optional_spawn_max_health_modifier, optional_prefered_direction, optional_target_unit, optional_skip_spawners)
	end

	return func(self, template, side_id, target_side_id, current_wave, horde_type, horde_template, compositions, optional_main_path_offset, optional_num_tries, optional_disallowed_positions, optional_spawn_max_health_modifier, optional_prefered_direction, optional_target_unit, optional_skip_spawners)
end)

-- Replace _update_horde_allowance() to strip travel_distance_allowed check
mod:hook(HordePacing, "_update_horde_allowance", function(func, self, t, dt, side_id, target_side_id)
	local pacing_manager = Managers.state.pacing
	local template = self._template
	local total_minions_spawned = Managers.state.minion_spawn:num_spawned_minions()
	local minion_spawn_limit_reached = total_minions_spawned >= template.max_active_minions
	local furthest_travel_distance, time_since_forward_travel_changed = pacing_manager:get_mission_progression()
	local allowed_hordes_per_travel_distance = math.ceil(furthest_travel_distance / self._required_travel_distance) - self._triggered_hordes
	local hordes_enabled = pacing_manager:spawn_type_enabled("hordes") and allowed_hordes_per_travel_distance > 0
	local horde_started = self._triggered_pre_stinger or self._current_wave > 0
	local hordes_allowed = not minion_spawn_limit_reached and (horde_started or hordes_enabled)
	local traveled_this_frame = furthest_travel_distance - self._old_furthest_travel_distance

	self._old_furthest_travel_distance = furthest_travel_distance
	self._time_since_forward_travel_changed = time_since_forward_travel_changed
	self._traveled_this_frame = traveled_this_frame
	self._horde_started = horde_started

	return hordes_allowed
end)

--[[
local TRICKLE_FAILED_RETRY_TIME = { 3, 5 } -- seconds

local function is_main_trickle_horde(self, trickle_horde)
	return trickle_horde.template == self._template and not trickle_horde.num_waves
end

mod:hook(HordePacing, "_update_trickle_horde_pacing", function(func, self, t, dt, side_id, target_side_id)
	local trickle_hordes = self._trickle_hordes

	if not trickle_hordes then
		return func(self, t, dt, side_id, target_side_id)
	end

	for i = 1, #trickle_hordes do
		local trickle_horde = trickle_hordes[i]

		if is_main_trickle_horde(self, trickle_horde) then
			local retry_at = trickle_horde.onslaught_retry_at

			if retry_at and t < retry_at then
				trickle_horde.next_trickle_horde_travel_distance_trigger = math.huge
			else
				trickle_horde.onslaught_retry_at = nil
				trickle_horde.trickle_horde_travel_distance = 0
				trickle_horde.next_trickle_horde_travel_distance_trigger = 0
			end
		end
	end

	func(self, t, dt, side_id, target_side_id)

	for i = 1, #trickle_hordes do
		local trickle_horde = trickle_hordes[i]

		if is_main_trickle_horde(self, trickle_horde) and not trickle_horde.onslaught_retry_at then
			local trigger = trickle_horde.next_trickle_horde_travel_distance_trigger

			if trigger > 0 and trigger < math.huge then
				trickle_horde.onslaught_retry_at = t + math.random_range(TRICKLE_FAILED_RETRY_TIME[1], TRICKLE_FAILED_RETRY_TIME[2])

				if mod.debug_mode then
					mod:echo("[TRICKLE] Spawn failed or not allowed, retrying by time")
				end
			end
		end
	end
end)
]]

-- Horde pacing settings
local MAX_ACTIVE_MINIONS = 200 -- keep in sync with HARD_ALLOCATED_LIMIT in pacing.lua

mod:hook_require("scripts/managers/pacing/horde_pacing/horde_pacing_templates", function(all_templates)
	local function modify_template(template_name, template_data)
		if not template_data or not template_data.resistance_templates then
			mod:error(string.format("Error: %s has no resistance_templates", template_name))
			return
		end

		for _, level in pairs(template_data.resistance_templates) do
			level.horde_timer_range = { 130, 160 }
			level.max_active_minions = MAX_ACTIVE_MINIONS
			level.max_active_minions_for_ambush = MAX_ACTIVE_MINIONS
			level.num_waves = {
				ambush_horde = 2,
				far_vector_horde = 3, -- 3
			}
			level.time_between_waves = 25
			level.travel_distance_spawning = false
			level.num_trickle_hordes_active_for_cooldown = 0 -- 0 to disable trickle hordes
			level.travel_distance_required_for_horde = { 0, 0 }
			level.trickle_horde_travel_distance_range = { 0, 0 }
			level.aggro_nearby_roamers_zone_range = 1

			if level.horde_compositions then
				level.horde_compositions.trickle_horde = DW_HIGH_TRICKLE_HORDE_COMPOSITIONS
			end

			if level.coordinated_horde_strike_settings then
				for strike_type, strike_data in pairs(level.coordinated_horde_strike_settings) do
					strike_data.conditions = {}

					if strike_type == "long_horde" then
						strike_data.total_num_allowed = { 0, 0 }
					end

					if strike_type == "ranged_push_from_behind" then
						strike_data.chance = 0.2
						strike_data.high_chance = 0.8
					end

					if strike_data.horde_setup then
						for _, setup_step in ipairs(strike_data.horde_setup) do
							setup_step.time_to_first_wave = 10
							setup_step.time_between_waves = 25
						--	setup_step.num_waves = { 3, 3 }
						end

						if strike_type == "coordinated_special_attack" then
							for _, setup_step in ipairs(strike_data.horde_setup) do
								setup_step.trigger_special_coordinated_attack_num_breeds = 5
								setup_step.trigger_special_coordinated_attack_on_first_wave = true
								setup_step.trigger_special_coordinated_attack_timer_offset = 5
							end
						end
					end
				end
			end
		end
	end

--	modify_template("default_horde", all_templates.default_horde) -- if you want to play auric then use fading light 1
	modify_template("havoc_horde", all_templates.havoc_horde)
	modify_template("mutator_horde", all_templates.mutator_horde)
end)

--[[
		{
			aggro_nearby_roamers_zone_range = 3,
			max_active_minions = 95,
			max_active_minions_for_ambush = 50,
			num_trickle_hordes_active_for_cooldown = 4,
			time_between_waves = 10,
			travel_distance_spawning = true,
			trigger_heard_dialogue = true,
			horde_timer_range = {
				160,
				320,
			},
			first_spawn_timer_modifer = {
				0.4,
				0.8,
			},
			num_waves = {
				ambush_horde = 1,
				far_vector_horde = 3,
			},
			max_active_hordes = {
				ambush_horde = 1,
				far_vector_horde = 3,
			},
			travel_distance_required_for_horde = {
				40,
				70,
			},
			horde_templates = {
				HordeTemplates.far_vector_horde,
				HordeTemplates.ambush_horde,
			},
			horde_compositions = {
				far_vector_horde = {
					HordeCompositions.renegade_medium,
					HordeCompositions.infected_medium,
				},
				ambush_horde = {
					HordeCompositions.infected_large,
				},
				trickle_horde = HIGH_TRICKLE_HORDE_COMPOSITIONS,
				flood_horde = {
					HordeCompositions.renegade_flood,
				},
			},
			stinger_sound_events = STINGER_SOUND_EVENTS,
			pre_stinger_sound_events = PRE_STINGER_SOUND_EVENTS,
			horde_group_sound_events = HORDE_GROUP_SOUND_EVENTS,
			pre_stinger_delays = PRE_STINGER_DELAYS,
			trickle_horde_travel_distance_range = {
				40,
				120,
			},
			trickle_horde_cooldown = {
				30,
				45,
			},
			coordinated_horde_strike_settings = {
				[COORDINATED_HORDE_STRIKE_TYPES.long_horde] = {
					chance = 0.2,
					pre_stinger = "wwise/events/minions/play_signal_horde_poxwalkers_2d",
					conditions = {
						has_build_up_tension_or_high,
						has_high_challenge_rating,
					},
					total_num_allowed = {
						0,
						2,
					},
					horde_setup = {
						{
							horde_type = "far_vector_horde",
							stinger = "wwise/events/minions/play_signal_horde_poxwalkers_3d",
							time_between_waves = 5,
							time_to_first_wave = 7,
							num_waves = {
								6,
								7,
							},
							composition = HordeCompositions.renegade_medium,
						},
					},
				},
				[COORDINATED_HORDE_STRIKE_TYPES.coordinated_special_attack] = {
					chance = 0.2,
					high_chance = 0.8,
					pre_stinger = "wwise/events/minions/play_minion_horde_poxwalker_ambush_2d",
					conditions = {
						has_build_up_tension_or_low,
						more_than_one_num_alive_players,
					},
					high_chance_conditions = {
						long_low_period,
					},
					total_num_allowed = {
						3,
						6,
					},
					horde_setup = {
						{
							horde_type = "ambush_horde",
							stinger = "wwise/events/minions/play_minion_horde_poxwalker_ambush_3d",
							time_between_waves = 12,
							time_to_first_wave = 7,
							trigger_special_coordinated_attack_num_breeds = 10,
							trigger_special_coordinated_attack_on_first_wave = true,
							trigger_special_coordinated_attack_timer_offset = 5,
							num_waves = {
								3,
								4,
							},
							composition = HordeCompositions.infected_medium,
						},
					},
				},
				[COORDINATED_HORDE_STRIKE_TYPES.push_from_behind] = {
					chance = 0.2,
					high_chance = 0.8,
					pre_stinger = "wwise/events/minions/play_signal_horde_poxwalkers_2d",
					conditions = {
						has_build_up_tension_or_high,
						more_than_one_num_alive_players,
						has_high_challenge_rating,
						has_high_combat_vector_minions,
					},
					high_chance_conditions = {
						has_high_combat_vector_minions,
					},
					total_num_allowed = {
						1,
						3,
					},
					horde_setup = {
						{
							horde_type = "far_vector_horde",
							prefered_direction = "behind",
							stinger = "wwise/events/minions/play_signal_horde_poxwalkers_3d",
							time_between_waves = 9,
							time_to_first_wave = 7,
							num_waves = {
								7,
								8,
							},
							composition = HordeCompositions.renegade_small,
						},
					},
				},
				[COORDINATED_HORDE_STRIKE_TYPES.ranged_push_from_behind] = {
					chance = 0.05,
					high_chance = 0.5,
					pre_stinger = "wwise/events/minions/play_signal_horde_poxwalkers_2d",
					conditions = {
						has_build_up_tension_or_low,
						more_than_one_num_alive_players,
						has_medium_challenge_rating,
					},
					high_chance_conditions = {
						has_high_combat_vector_minions,
					},
					total_num_allowed = {
						1,
						3,
					},
					horde_setup = {
						{
							horde_type = "far_vector_horde",
							prefered_direction = "behind",
							stinger = "wwise/events/minions/play_signal_horde_poxwalkers_3d",
							time_between_waves = 9,
							time_to_first_wave = 7,
							num_waves = {
								4,
								5,
							},
							composition = HordeCompositions.renegade_small,
						},
						{
							horde_type = "far_vector_horde",
							prefered_direction = "ahead",
							time_between_waves = 9,
							time_to_first_wave = 12,
							num_waves = {
								2,
								3,
							},
							faction_composition = {
								renegade = {
									HordeCompositions.renegade_coordinated_ranged_horde,
								},
								cultist = {
									HordeCompositions.cultist_coordinated_ranged_horde,
								},
							},
						},
					},
				},
				[COORDINATED_HORDE_STRIKE_TYPES.elite_roamer_mix_vector] = {
					chance = 0.2,
					high_chance = 0.8,
					pre_stinger = "wwise/events/minions/play_signal_horde_poxwalkers_2d",
					conditions = {
						has_build_up_tension_or_low,
						more_than_one_num_alive_players,
						has_below_high_challenge_rating,
					},
					high_chance_conditions = {
						long_low_period,
					},
					total_num_allowed = {
						1,
						3,
					},
					horde_setup = {
						{
							horde_type = "far_vector_horde",
							stinger = "wwise/events/minions/play_signal_horde_poxwalkers_3d",
							time_between_waves = 7,
							time_to_first_wave = 6,
							num_waves = {
								3,
								4,
							},
							faction_composition = {
								renegade = {
									HordeCompositions.renegade_coordinated_melee_mix,
								},
								cultist = {
									HordeCompositions.cultist_coordinated_melee_mix,
								},
							},
						},
					},
				},
				[COORDINATED_HORDE_STRIKE_TYPES.spread_ambush] = {
					chance = 0.5,
					high_chance = 0.8,
					pre_stinger = "wwise/events/minions/play_minion_horde_poxwalker_ambush_2d",
					conditions = {
						has_build_up_tension_or_low,
						more_than_one_num_alive_players,
					},
					high_chance_conditions = {
						low_coherency,
					},
					total_num_allowed = {
						2,
						4,
					},
					horde_setup = {
						{
							horde_type = "ambush_horde",
							random_targets = true,
							stinger = "wwise/events/minions/play_minion_horde_poxwalker_ambush_3d",
							time_between_waves = 5,
							time_to_first_wave = 3,
							num_waves = {
								6,
								7,
							},
							faction_composition = {
								renegade = {
									HordeCompositions.infected_small,
								},
								cultist = {
									HordeCompositions.infected_small,
								},
							},
						},
					},
				},
				[COORDINATED_HORDE_STRIKE_TYPES.sandwich] = {
					chance = 0.3,
					high_chance = 0.8,
					pre_stinger = "wwise/events/minions/play_signal_horde_poxwalkers_2d",
					conditions = {
						has_build_up_tension_or_low,
						more_than_one_num_alive_players,
						has_below_high_challenge_rating,
					},
					high_chance_conditions = {
						long_low_period,
					},
					total_num_allowed = {
						2,
						4,
					},
					horde_setup = {
						{
							horde_type = "far_vector_horde",
							stinger = "wwise/events/minions/play_signal_horde_poxwalkers_3d",
							time_between_waves = 7,
							time_to_first_wave = 6,
							two_waves_ahead_and_behind = true,
							num_waves = {
								5,
								6,
							},
							faction_composition = {
								renegade = {
									HordeCompositions.renegade_medium,
								},
								cultist = {
									HordeCompositions.infected_medium,
								},
							},
						},
					},
				},
				[COORDINATED_HORDE_STRIKE_TYPES.elite_sandwich_waves] = {
					chance = 0.3,
					high_chance = 0.8,
					pre_stinger = "wwise/events/minions/play_signal_horde_poxwalkers_2d",
					conditions = {
						has_build_up_tension_or_low,
						more_than_one_num_alive_players,
						has_below_high_challenge_rating,
					},
					high_chance_conditions = {
						long_low_period,
					},
					total_num_allowed = {
						2,
						4,
					},
					horde_setup = {
						{
							horde_type = "far_vector_horde",
							stinger = "wwise/events/minions/play_signal_horde_poxwalkers_3d",
							time_between_waves = 7,
							time_to_first_wave = 6,
							two_waves_ahead_and_behind = true,
							num_waves = {
								5,
								6,
							},
							faction_composition = {
								renegade = {
									HordeCompositions.renegade_coordinated_melee_mix,
									HordeCompositions.renegade_coordinated_melee_mix_2,
								},
								cultist = {
									HordeCompositions.cultist_coordinated_melee_mix,
									HordeCompositions.renegade_coordinated_melee_mix_2,
								},
							},
						},
					},
				},
				[COORDINATED_HORDE_STRIKE_TYPES.elite_coordinated_special_attack] = {
					chance = 0.3,
					high_chance = 0.8,
					pre_stinger = "wwise/events/minions/play_signal_horde_poxwalkers_2d",
					conditions = {
						has_build_up_tension_or_low,
						more_than_one_num_alive_players,
						has_below_high_challenge_rating,
					},
					high_chance_conditions = {
						long_low_period,
					},
					total_num_allowed = {
						2,
						4,
					},
					horde_setup = {
						{
							horde_type = "far_vector_horde",
							stinger = "wwise/events/minions/play_signal_horde_poxwalkers_3d",
							time_between_waves = 7,
							time_to_first_wave = 6,
							trigger_special_coordinated_attack_num_breeds = 10,
							trigger_special_coordinated_attack_on_first_wave = true,
							trigger_special_coordinated_attack_timer_offset = 5,
							two_waves_ahead_and_behind = true,
							num_waves = {
								3,
								4,
							},
							faction_composition = {
								renegade = {
									HordeCompositions.renegade_coordinated_melee_mix,
									HordeCompositions.renegade_coordinated_melee_mix_2,
								},
								cultist = {
									HordeCompositions.cultist_coordinated_melee_mix,
									HordeCompositions.renegade_coordinated_melee_mix_2,
								},
							},
						},
					},
				},
				[COORDINATED_HORDE_STRIKE_TYPES.ranged_trickle_forward_horde_push_from_behind] = {
					chance = 0.2,
					high_chance = 0.8,
					pre_stinger = "wwise/events/minions/play_signal_horde_poxwalkers_2d",
					conditions = {
						has_build_up_tension_or_low,
						more_than_one_num_alive_players,
					},
					high_chance_conditions = {
						long_low_period,
					},
					total_num_allowed = {
						1,
						3,
					},
					horde_setup = {
						{
							horde_type = "far_vector_horde",
							prefered_direction = "behind",
							stinger = "wwise/events/minions/play_signal_horde_poxwalkers_3d",
							time_between_waves = 9,
							time_to_first_wave = 7,
							num_waves = {
								4,
								5,
							},
							composition = HordeCompositions.renegade_small,
						},
						{
							horde_type = "far_vector_horde",
							prefered_direction = "ahead",
							time_between_waves = 9,
							time_to_first_wave = 8,
							num_waves = {
								4,
								5,
							},
							faction_composition = {
								renegade = {
									HordeCompositions.renegade_small_coordinated_ranged_horde,
								},
								cultist = {
									HordeCompositions.cultist_small_coordinated_ranged_horde,
								},
							},
						},
					},
				},
				[COORDINATED_HORDE_STRIKE_TYPES.elite_spread_ambush] = {
					chance = 0.2,
					high_chance = 0.8,
					pre_stinger = "wwise/events/minions/play_minion_horde_poxwalker_ambush_2d",
					conditions = {
						has_build_up_tension_or_low,
						more_than_one_num_alive_players,
					},
					high_chance_conditions = {
						long_low_period,
					},
					total_num_allowed = {
						2,
						4,
					},
					horde_setup = {
						{
							horde_type = "ambush_horde",
							random_targets = true,
							skip_spawners = true,
							stinger = "wwise/events/minions/play_minion_horde_poxwalker_ambush_3d",
							time_between_waves = 2,
							time_to_first_wave = 4,
							num_waves = {
								6,
								7,
							},
							faction_composition = {
								renegade = {
									HordeCompositions.renegade_elite_poxwalkers_small,
								},
								cultist = {
									HordeCompositions.cultist_elite_poxwalkers_small,
								},
							},
						},
					},
				},
			},
		},

]]