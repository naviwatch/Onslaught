local mod = get_mod("Onslaught")

local SpecialPacingTemplateSettings = require("scripts/managers/pacing/specials_pacing/templates/special_pacing_template_settings")
local HavocSettings = SpecialPacingTemplateSettings.havoc
local SpecialsPacing = require("scripts/managers/pacing/specials_pacing/specials_pacing")

local onslaught_settings = {
    -- interrupter_patrols = INTERRUPTER_PATROLS
	default_foreshadow_stingers = {
		chaos_hound = "wwise/events/minions/play_enemy_chaos_hound_spawn",
		renegade_netgunner = "wwise/events/minions/play_minion_special_netgunner_spawn",
	},
	default_foreshadow_stinger_timers = {
		chaos_hound = 5,
		cultist_mutant = 5,
		renegade_netgunner = 4,
	},
	default_spawn_stingers = {
		chaos_poxwalker_bomber = "wwise/events/minions/play_minion_special_poxwalker_bomber_spawn",
		cultist_mutant = "wwise/events/minions/play_minion_special_mutant_charger_spawn",
	},
	default_optional_prefered_spawn_direction = {
		cultist_grenadier = "ahead",
		renegade_grenadier = "ahead",
		renegade_sniper = "ahead",
		chaos_ogryn_houndmaster = "ahead",
		renegade_radio_operator = "ahead",
	},
	default_optional_mainpath_offset = {
		cultist_grenadier = 30,
		renegade_grenadier = 30,
		renegade_sniper = 30,
	},
	-- Weighted breeds, this is really messy but better than trying to hook_origin special_pacing.lua and having something break every update
	default_breeds = {
		all = {
			"chaos_hound",
            "chaos_armored_hound",
			"chaos_poxwalker_bomber",
			"chaos_poxwalker_bomber",
			"cultist_mutant",
			"cultist_mutant",
            "cultist_grenadier",
            "renegade_grenadier",
			"renegade_netgunner",
			"renegade_sniper",
			"flamer",
			"flamer",
		},
		disablers = {
			"chaos_hound",
            "chaos_armored_hound",
			"renegade_netgunner",
			"cultist_mutant",
			"cultist_mutant",
		},
		scramblers = {
			"chaos_poxwalker_bomber",
            "cultist_grenadier",
            "renegade_grenadier",
			"renegade_sniper",
			"flamer",
			"flamer",
		},
	},
	default_coordinated_strike_breeds = {
		"chaos_hound",
        "chaos_armored_hound",
		"chaos_poxwalker_bomber",
		"cultist_mutant",
		"renegade_netgunner",
		"flamer",
	},
	default_rush_prevention_breeds = {
		"chaos_hound",
		"cultist_mutant", 
	},
	default_loner_prevention_breeds = {
		"chaos_hound",
		"cultist_mutant",
		"renegade_netgunner",
	},
	default_speed_running_prevention_breeds = {
		"chaos_hound",
		"cultist_mutant",
		"renegade_netgunner",
	},
	faction_bound_breeds = {
		flamer = {
			cultist = "cultist_flamer",
			renegade = "renegade_flamer",
		},
		--[[
		grenadier = {
			cultist = "cultist_grenadier",
			renegade = "renegade_grenadier",
		},
		]]
	},
	havoc = {
		default_min_distances_from_target = {
			chaos_beast_of_nurgle = 30,
			chaos_hound = 25,
			chaos_plague_ogryn = 30,
			chaos_poxwalker_bomber = 25,
			chaos_spawn = 30,
			cultist_flamer = 20,
			cultist_grenadier = 30,
			cultist_mutant = 25,
			renegade_flamer = 15,
			renegade_grenadier = 30,
			renegade_netgunner = 25,
			renegade_sniper = 25,
			chaos_armored_hound = 25,
			chaos_ogryn_houndmaster = 30,
			renegade_radio_operator = 25,
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
				10,
				10,
				10,
				10,
			},
		},
		default_disabler_override_duration = {
			360,
			240,
			160,
			100,
			40, -- 80
		},
		default_disabler_target_alone_player_chance = {
            chaos_armored_hound = 0.75,
			chaos_hound = 0.75,
			cultist_mutant = 0.5, -- 0.25
			renegade_netgunner = 0.5,
		},
		low_max_of_same = {
			chaos_beast_of_nurgle = 1,
			chaos_hound = 1,
			chaos_plague_ogryn = 2,
			chaos_poxwalker_bomber = 1,
			chaos_spawn = 2,
			cultist_flamer = 2,
			cultist_grenadier = 0,
			cultist_mutant = 1,
			flamer = 2,
		--	grenadier = 2,
			renegade_flamer = 2,
			renegade_grenadier = 0,
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
		--	grenadier = 2,
			renegade_flamer = 2,
			renegade_grenadier = 1,
			renegade_netgunner = 2,
			renegade_sniper = 2,
		},
		high_max_of_same = {
			chaos_beast_of_nurgle = 1,
			chaos_hound = 3,
			chaos_plague_ogryn = 2,
			chaos_poxwalker_bomber = 5,
			chaos_spawn = 2,
			cultist_flamer = 3,
			cultist_grenadier = 1,
			cultist_mutant = 4,
			flamer = 3,
		--	grenadier = 3,
			renegade_flamer = 3,
			renegade_grenadier = 1,
			renegade_netgunner = 3,
			renegade_sniper = 2,
			chaos_armored_hound = 3,
		},
		always_update_at_challange_rating_breeds = {
			cultist_mutant = 5,
			renegade_sniper = 0,
		},
	}
}

-- Settings
mod:hook_require("scripts/managers/pacing/specials_pacing/specials_pacing_templates", function(all_templates)
    if not all_templates or not all_templates.havoc_specials then
        mod:error("Error: Could not find havoc_specials template")
        return
    end
	
	local mas = 6
	if mod:get("giga_specials") then
		mas = 10
	end

	local function modify_template(template_name, template_data, max_alive_specials)
		if not template_data or not template_data.resistance_templates then
			mod:error(string.format("Error: %s has no special_pacing_templates", template_name))
			return
		end

		for _, level in pairs(template_data.resistance_templates) do
			level.timer_range = { 30, 65 } 
			level.max_alive_specials = max_alive_specials  -- turns out havoc 35 adds FIVE more slots and i never fucking knew, total 11, extra reserved for packmaster
			level.coordinated_surge_chance = 0
			level.chance_for_coordinated_strike = 0.3
			level.num_coordinated_surges_range = { 0, 0 }
			level.move_timer_when_challenge_rating_above = 0
			level.first_spawn_timer_modifer = 1
			level.travel_distance_spawning = false

			level.max_of_same = onslaught_settings.havoc.high_max_of_same
			
			level.spawners_min_range = onslaught_settings.havoc.default_min_spawners_ranges.min
			level.spawners_max_range = onslaught_settings.havoc.default_min_spawners_ranges.max

			level.coordinated_strike_timer_range = { 30, 65 }
			level.coordinated_strike_num_breeds = { max_alive_specials, max_alive_specials }

			level.breeds = onslaught_settings.default_breeds
			level.coordinated_strike_breeds = onslaught_settings.default_coordinated_strike_breeds
			level.rush_prevention_breeds = onslaught_settings.default_rush_prevention_breeds
			level.loner_prevention_breeds = onslaught_settings.default_loner_prevention_breeds
			level.speed_running_prevention_breeds = onslaught_settings.default_speed_running_prevention_breeds
			level.faction_bound_breeds = onslaught_settings.faction_bound_breeds
			level.always_update_breeds = onslaught_settings.havoc.always_update_at_challange_rating_breeds

			level.disabler_override_duration = onslaught_settings.havoc.default_disabler_override_duration
			level.disabler_target_alone_player_chance = onslaught_settings.havoc.default_disabler_target_alone_player_chance
			level.min_distances_from_target = onslaught_settings.havoc.default_min_distances_from_target
			level.num_allowed_disablers_per_alive_targets = onslaught_settings.havoc.default_num_allowed_disabled_per_alive_targets

			level.optional_prefered_spawn_direction = onslaught_settings.default_optional_prefered_spawn_direction
			level.optional_mainpath_offset = onslaught_settings.default_optional_mainpath_offset
		end
	end


	modify_template("default_specials", all_templates.default_specials, 11)
    modify_template("havoc_specials", all_templates.havoc_specials, mas)
end)

-- Special elites shit
local NEW_MUTATOR = "special_elites"
local MONSTER_OVERRIDE_DELAY = 180
local special_elites = {
    "chaos_ogryn_houndmaster",
--    "renegade_radio_operator",
}

mod:hook(SpecialsPacing, "_check_monster_override", function(func, self, template, ...)
	local t = Managers.time:time("gameplay")
	local start_t = self._onslaught_monster_override_start_t

	if not start_t then
		self._onslaught_monster_override_start_t = t

		return
	end

	if t - start_t < MONSTER_OVERRIDE_DELAY then
		return
	end

	return func(self, template, ...)
end)

local function _special_elite_slot_is_active(specials_slots)
	for i = 1, #specials_slots do
		local slot = specials_slots[i]
		local breed_name = slot.breed_name

		-- Check if any of ours annoying fucks are currently active in a slot
		for _, target_breed in ipairs(special_elites) do
			if breed_name == target_breed then
				if slot.spawner_queue_id then
					return true
				end

				local unit = slot.spawned_unit
				if slot.spawned and unit and ALIVE[unit] then
					return true
				end
			end
		end
	end

	return false
end

mod:hook(SpecialsPacing, "_spawn_special", function(func, self, specials_slot, side_id, target_side_id)
	local manager = Managers.state.mutator
	local mutator = manager and manager:mutator(NEW_MUTATOR)
	local settings = mutator and mutator._template.spawn_settings
	local t = Managers.time:time("gameplay")
	local can_override = settings
		and not specials_slot.injected
		and not specials_slot.coordinated_strike
		and not specials_slot.monster_breed_override
		and t >= (self._houndmaster_cooldown_t or 0)
		and not _special_elite_slot_is_active(self._specials_slots)

	if not can_override or math.random() >= settings.chance then
		return func(self, specials_slot, side_id, target_side_id)
	end

	local chosen_breed = special_elites[math.random(1, #special_elites)]

	local original_breed_name = specials_slot.breed_name
	local original_health_modifier = specials_slot.optional_health_modifier
	local original_monster_breed_override = specials_slot.monster_breed_override

	specials_slot.breed_name = chosen_breed
	specials_slot.optional_health_modifier = settings.health_modifier
	specials_slot.monster_breed_override = true

	local success, spawned_unit, spawner_queue_id, spawner = func(self, specials_slot, side_id, target_side_id)

	if success then
		self._houndmaster_cooldown_t = t + math.random_range(settings.cooldown[1], settings.cooldown[2])
	else
		specials_slot.breed_name = original_breed_name
		specials_slot.optional_health_modifier = original_health_modifier
		specials_slot.monster_breed_override = original_monster_breed_override
	end

	return success, spawned_unit, spawner_queue_id, spawner
end)

-- SNIPER REPLACEMENTS
local SNIPER_CHECK_INTERVAL = 1
local MAX_SNIPER_LIFETIME = 30 -- in seconds

mod:hook(SpecialsPacing, "update", function(func, self, dt, t, side_id, target_side_id)
    func(self, dt, t, side_id, target_side_id)

    if not self._onslaught_sniper_check_t then
        self._onslaught_sniper_check_t = t
    end

    if t - self._onslaught_sniper_check_t >= SNIPER_CHECK_INTERVAL then
        self._onslaught_sniper_check_t = t
        
        local specials_slots = self._specials_slots
        if specials_slots then
            for i = 1, #specials_slots do
                local slot = specials_slots[i]
                
                if slot.spawned and slot.breed_name == "renegade_sniper" then
                    local unit = slot.spawned_unit
                    
                    if unit and ALIVE[unit] then
                        if not slot._onslaught_sniper_start_time then
                            slot._onslaught_sniper_start_time = t
                        else
                            if t - slot._onslaught_sniper_start_time >= MAX_SNIPER_LIFETIME then
                                -- "Pretend" the sniper is dead to free the slot
                                self._num_spawned_specials = math.max(0, self._num_spawned_specials - 1)
                                
                                slot.spawned_unit = nil
                                slot.spawned = false
                                slot._onslaught_sniper_start_time = nil
                                
                                self:_setup_specials_slot(specials_slots, slot, self._template, self._timer_modifier)
                                
								if mod.debug_mode then
                                	mod:echo("Forcibly freed slot " .. i .. " from this fuckass sniper who wont die")
								end
                            end
                        end
                    else
                        slot._onslaught_sniper_start_time = nil
                    end
                else
                    slot._onslaught_sniper_start_time = nil
                end
            end
        end
    end
end)