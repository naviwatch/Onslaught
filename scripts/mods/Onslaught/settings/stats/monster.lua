local mod = get_mod("Onslaught")

local MinionDifficultySettings = require("scripts/settings/difficulty/minion_difficulty_settings")
local breed_chaos_ogryn_houndmaster = require("scripts/settings/breed/breeds/chaos/chaos_ogryn_houndmaster_breed")

-- HEALTH INCREASE MONSTERS & CAPTAINS
local function _monster_health_steps(health)
	return {
		health * 1,
		health * 1.25,
		health * 1.5,
		health * 2,
		health * 4.8, -- 3
	}
end

local function _captain_health_steps(health)
	return {
		health * 1,
		health * 1.2,
		health * 1.3,
		health * 1.5,
		health * 2,
	}
end

local function _ogryn_health_steps(health)
    return {
        health * 1,
        health * 1,
        health * 1,
        health * 1,
        health * 1,
    }
end

MinionDifficultySettings.health.chaos_beast_of_nurgle = _monster_health_steps(17500)
MinionDifficultySettings.health.chaos_ogryn_houndmaster = _ogryn_health_steps(11000) -- 22000
MinionDifficultySettings.health.chaos_plague_ogryn = _monster_health_steps(20000)
MinionDifficultySettings.health.chaos_spawn = _monster_health_steps(15750)
MinionDifficultySettings.health.chaos_daemonhost = _monster_health_steps(16000)
MinionDifficultySettings.health.chaos_mutator_daemonhost = _monster_health_steps(16000)
MinionDifficultySettings.health.cultist_captain = _captain_health_steps(50000)
MinionDifficultySettings.health.renegade_captain = _captain_health_steps(50000)
MinionDifficultySettings.health.renegade_twin_captain = _captain_health_steps(72000)
MinionDifficultySettings.health.renegade_twin_captain_two = _captain_health_steps(72000)

-- Havoc
mod:hook_require("scripts/managers/pacing/monster_pacing/templates/havoc_monster_pacing_template", function(template)
	if not template or not template.challenge_templates then
		mod:error("Could not find Havoc monster challenge templates")
		return
	end

	for _, challenge_template in ipairs(template.challenge_templates) do
		local breed_names = challenge_template.breed_names

		if breed_names then
			for _, category in ipairs({ "monsters", "witches" }) do
				local breeds = breed_names[category]

				if breeds then
					for i = #breeds, 1, -1 do
						local breed_name = breeds[i]

						if breed_name == "chaos_ogryn_houndmaster" or breed_name == "chaos_daemonhost" then
							table.remove(breeds, i)
						end
					end
				end
			end
		end

		if challenge_template.num_spawns then
			challenge_template.num_spawns.witches = { 0, 0 }
		end

		--[[
		if challenge_template.force_horde then
			challenge_template.force_horde = false
		end
		]]

		if challenge_template.despawn_distance_when_passive then
			challenge_template.despawn_distance_when_passive.chaos_daemonhost = nil
		end
	end
end)

-- Default
mod:hook_require("scripts/managers/pacing/monster_pacing/templates/default_monster_pacing_template", function(template)
	if not template or not template.challenge_templates then
		mod:error("Could not find Havoc monster challenge templates")
		return
	end

	for _, challenge_template in ipairs(template.challenge_templates) do
		local breed_names = challenge_template.breed_names

		if breed_names then
			for _, category in ipairs({ "monsters", "witches" }) do
				local breeds = breed_names[category]

				if breeds then
					for i = #breeds, 1, -1 do
						local breed_name = breeds[i]

						if breed_name == "chaos_ogryn_houndmaster" or breed_name == "chaos_daemonhost" then
							table.remove(breeds, i)
						end
					end
				end
			end
		end

		if challenge_template.num_spawns then
			challenge_template.num_spawns.witches = { 0, 0 }
		end

		--[[
		if challenge_template.force_horde then
			challenge_template.force_horde = false
		end
		]]

		if challenge_template.despawn_distance_when_passive then
			challenge_template.despawn_distance_when_passive.chaos_daemonhost = nil
		end
	end
end)

local NEW_MUTATOR = "special_elites"

local special_elites = {
    "chaos_ogryn_houndmaster",
--    "renegade_radio_operator",
}

mod:hook_require("scripts/settings/mutator/mutator_templates", function(instance)
    -- really shitty way of making the game spawn more monsters, but because each map has a hard cap on how many monster spawn points there are, usually this maxes out at 6 monsters per run
    local more_monsters = instance.mutator_more_monsters

    if more_monsters and more_monsters.modify_pacing then
        local pacing_data = more_monsters.modify_pacing

        pacing_data.monsters_per_travel_distance = 120 -- literally the same as the original
        pacing_data.monster_breed_name = {
            "chaos_spawn",
        	"chaos_beast_of_nurgle",
            "chaos_plague_ogryn",
        }
    else
        mod:error("Could not find mutator_more_monsters in mutator_templates!")
    end

    -- havoc_mutator_monster_specials_02
    local monster_specials = instance.havoc_mutator_monster_specials_02

    if monster_specials and monster_specials.init_modify_pacing then
        monster_specials.init_modify_pacing.specials_monster_spawn_config = {
			chance_to_spawn_monster = 0.05,
            max_monsters = 1,
            health_modifiers = {
				chaos_beast_of_nurgle = 0.3,
				chaos_plague_ogryn = 0.3,
				chaos_spawn = 0.3,
            },
            max_monster_duration = {
				480,
				600,
            },
            breeds = {
				"chaos_beast_of_nurgle",
				"chaos_plague_ogryn",
				"chaos_spawn",
            },
        }
    else
        mod:error("Could not find havoc_mutator_monster_specials_02 in mutator_templates!")
    end

	local original = instance.havoc_mutator_monster_specials_02

	if not original or not original.init_modify_pacing then
		mod:error("Could not find havoc_mutator_monster_specials_02 to clone")
		return
	end

	local custom = table.clone(original)
	custom.name = NEW_MUTATOR
	custom.init_modify_pacing = nil
	custom.modify_pacing = nil
	custom.spawn_settings = {
		chance = 1,
		cooldown = { 90, 150 },
		health_modifier = 1,
	}

	instance[NEW_MUTATOR] = custom
end)

-- Special elites shit
local SpecialsPacing = require("scripts/managers/pacing/specials_pacing/specials_pacing")

-- Fix monster specials full health spawns
mod:hook_origin(SpecialsPacing, "_add_spawner_special", function(self, spawner, breed_name, side_id, target_side_id, optional_health_modifier)
    local param_table = spawner:request_param_table()

    param_table.target_side_id = target_side_id
    param_table.max_health_modifier = optional_health_modifier
    param_table.onslaught_specials_health_modifier = optional_health_modifier

    local spawner_queue_id = spawner:add_spawns({
        breed_name,
    }, side_id, param_table)

    return spawner_queue_id, spawner
end)

local pending_health_modifier

mod:hook(CLASS.MinionSpawnerExtension, "_spawn", function(func, self, breed_name, spawn_data)
	pending_health_modifier = spawn_data and (spawn_data.onslaught_specials_health_modifier or spawn_data.max_health_modifier)

	local unit = func(self, breed_name, spawn_data)

	pending_health_modifier = nil

	return unit
end)

local function _apply_spawn_buffs(unit, buffs)
	if not unit or not HEALTH_ALIVE[unit] then
		return
	end

	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

	if not buff_extension then
		return
	end

	local t = Managers.time:time("gameplay")

	for i = 1, #buffs do
		if buff_extension:is_valid_target(buffs[i]) then
			buff_extension:add_internally_controlled_buff(buffs[i], t)
		end
	end
end

local Breeds = require("scripts/settings/breed/breeds")

mod:hook(CLASS.MinionSpawnManager, "spawn_minion", function(func, self, breed_name, position, rotation, side_id, optional_param_table)
	-- BEFORE spawn: fix monster specials / terror event max_health_modifier
	if pending_health_modifier and optional_param_table and not optional_param_table.optional_health_modifier then
		optional_param_table.optional_health_modifier = pending_health_modifier
	end

	local unit = func(self, breed_name, position, rotation, side_id, optional_param_table)

	-- AFTER spawn: add buffs carried on the spawn params, e.g. vt_twins (in havoc_mutators.lua)
	local buffs = optional_param_table and optional_param_table.onslaught_buffs

	if buffs then
		_apply_spawn_buffs(unit, buffs)
	end

	return unit
end)