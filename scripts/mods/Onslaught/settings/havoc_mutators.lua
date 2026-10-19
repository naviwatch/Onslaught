local mod = get_mod("Onslaught")

local AttackSettings = require("scripts/settings/damage/attack_settings")
local BuffSettings = require("scripts/settings/buff/buff_settings")
local BuffTemplates = require("scripts/settings/buff/buff_templates")
local MasterItems = require("scripts/backend/master_items")
local NavQueries = require("scripts/utilities/nav_queries")
local PerceptionSettings = require("scripts/settings/perception/perception_settings")
local ProjectileTemplates = require("scripts/settings/projectile/projectile_templates")
local ProjectileLocomotionSettings = require("scripts/settings/projectile_locomotion/projectile_locomotion_settings")

local attack_types = AttackSettings.attack_types
local proc_events = BuffSettings.proc_events

mod:hook_require("scripts/settings/havoc_settings", function(settings)
    settings.modifier_templates.buff_monsters[5].add_num_monsters = 6
end)

mod:hook_require("scripts/settings/circumstance/templates/havoc_circumstance_template", function(template)
    -- fading light 2
	template.mutator_highest_difficulty.mutators = {
			"mutator_always_allow_all_spawn_types",
			"mutator_enable_auric",
			"mutator_auric_tension_modifier",
			"mutator_add_resistance",
			"havoc_mutator_more_captains_01",
		--	"havoc_higher_stagger_thresholds",
			"mutator_havoc_override_horde_pacing_02",
			"mutator_monster_havoc_twins",
			"havoc_mutator_monster_specials_02",
			"mutator_always_allow_elites_in_terror_events",
			"mutator_havoc_more_points_allowed_terror_event",
			"mutator_more_boss_patrols", -- more patrols
            "mutator_more_monsters",
			"special_elites",
    }	
	-- fading light 1
	template.mutator_increased_difficulty.mutators = table.clone(template.mutator_highest_difficulty.mutators)
end)

--[[
	VT TWINS
	When a buffed enemy dies it splits into two weaker enemies who can keep on
	splitting down until chaos_poxwalker / chaos_newly_infected is reached.
]]

local TWINS_BUFF_NAME = "vt_twins"

-- Only breeds listed here split. Breeds NOT listed are the end of the chain.
local breedlookup = {
	chaos_ogryn_bulwark = { "renegade_berzerker", "cultist_berzerker" },
	chaos_ogryn_executor = { "renegade_executor", "renegade_executor" },
	chaos_ogryn_gunner = { "renegade_plasma_gunner", "renegade_plasma_gunner" },
	renegade_berzerker = { "renegade_melee", "cultist_melee" },
	renegade_executor = { "renegade_vanguard", "renegade_vanguard" },
	renegade_gunner = { "renegade_assault", "renegade_rifleman" },
	renegade_plasma_gunner = { "renegade_assault", "renegade_assault" },
	renegade_shocktrooper = { "renegade_melee", "renegade_assault" },
	cultist_berzerker = { "cultist_melee", "renegade_melee" },
	cultist_gunner = { "cultist_assault", "cultist_assault" },
	cultist_shocktrooper = { "cultist_melee", "cultist_assault" },
	renegade_assault = { "chaos_poxwalker", "chaos_newly_infected" },
	renegade_melee = { "chaos_poxwalker", "chaos_newly_infected" },
	renegade_rifleman = { "chaos_poxwalker", "chaos_newly_infected" },
	renegade_vanguard = { "chaos_armored_infected", "chaos_armored_infected" },
	cultist_melee = { "chaos_poxwalker", "chaos_newly_infected" },
	cultist_assault = { "chaos_poxwalker", "chaos_newly_infected" },
	cultist_vanguard = { "chaos_armored_infected", "chaos_armored_infected" },
	chaos_plague_ogryn = { "chaos_ogryn_bulwark", "chaos_ogryn_executor" },
	chaos_spawn = { "cultist_mutant", "cultist_mutant" },
	renegade_captain = { "chaos_daemonhost", "chaos_daemonhost" },
	cultist_captain = { "chaos_daemonhost", "chaos_daemonhost" },
}

local VT_TWINS_BUFF = { TWINS_BUFF_NAME }

local function _queue_twinned_minion(nav_world, position, rotation, breed_name, side_id, target_unit)
	local spawn_position = NavQueries.position_on_mesh_with_outside_position(nav_world, nil, position, 1, 1, 1)

	if not spawn_position then
		return
	end

	local params = Managers.state.minion_spawn:queue_minion_to_spawn(breed_name, spawn_position, rotation, side_id)

	params.optional_aggro_state = PerceptionSettings.aggro_states.aggroed

	if ALIVE[target_unit] then
		params.optional_target_unit = target_unit
	end

	if breedlookup[breed_name] then
		params.onslaught_buffs = VT_TWINS_BUFF
	end
end

local function _vt_twins_split(template_context)
	local unit = template_context.unit
	local possible_breeds = breedlookup[template_context.breed.name]

	if not possible_breeds then
		return
	end

	local side_system = Managers.state.extension:system("side_system")
	local side = side_system.side_by_unit[unit]
	local side_id = side and side.side_id or 2
	local blackboard = BLACKBOARDS[unit]
	local target_unit = blackboard and blackboard.perception.target_unit
	local nav_world = Managers.state.nav_mesh:nav_world()
	local breed = possible_breeds[math.random(1, #possible_breeds)]
	local base_position = Unit.world_position(unit, 1)
	local rotation = Unit.local_rotation(unit, 1)
	local right = Quaternion.right(rotation)
	local fx_system = Managers.state.extension:system("fx_system")

	fx_system:trigger_vfx("content/fx/particles/enemies/purple_stimmed_explosion", base_position + Vector3(0, 0, 0.25), rotation)
	fx_system:trigger_wwise_event("wwise/events/minions/play_minion_twins_disappear_explosion", base_position)

	_queue_twinned_minion(nav_world, base_position - right, rotation, breed, side_id, target_unit)
	_queue_twinned_minion(nav_world, base_position + right, rotation, breed, side_id, target_unit)

	Managers.state.minion_death:minion_ragdoll():remove_ragdoll_safe(unit)
end

-- Twinned enemies get their buffs through onslaught_buffs on the queue entry (in monster.lua)

-- Register buff ID helper
local function register_buff(name, template)
	template.name = name
	template.buff_category = template.buff_category or BuffSettings.buff_categories.generic

	BuffTemplates[name] = template

	local lookup = NetworkLookup.buff_templates

	if not rawget(lookup, name) then
		local id = #lookup + 1

		rawset(lookup, id, name)
		rawset(lookup, name, id)
	end
end

-- Register buff to NetworkLookup
register_buff(TWINS_BUFF_NAME, {
	class_name = "buff",
	predicted = false,
	max_stacks = 1,
	target = BuffSettings.targets.minion_only,
	minion_effects = table.clone(BuffTemplates.mutator_stimmed_minion_purple.minion_effects),
	conditional_exit_func = function(template_data, template_context)
		return not HEALTH_ALIVE[template_context.unit]
	end,
	stop_func = function(template_data, template_context, extension_destroyed)
		if extension_destroyed or not template_context.is_server then
			return
		end

		_vt_twins_split(template_context)
	end,
})

-- VOLATILE BALL ON RANGED DEATH
local VOLATILE_BUFF_NAME = "volatile_on_ranged_death"
local TRUE_FLIGHT = ProjectileLocomotionSettings.states.true_flight
local VOLATILE_BALL_SPEED = 4.2

local VALID_ATTACK_TYPES = {
	[attack_types.ranged] = true,
	[attack_types.explosion] = true,
}

local function _pick_target(attacking_unit, position)
	if HEALTH_ALIVE[attacking_unit] and Managers.state.player_unit_spawn:owner(attacking_unit) then
		return attacking_unit
	end

	local heroes = Managers.state.extension:system("side_system"):get_side_from_name("heroes")
	local players = heroes and heroes.valid_player_units or {}
	local best, best_dist = nil, math.huge

	for i = 1, #players do
		local p = players[i]

		if HEALTH_ALIVE[p] then
			local distance = Vector3.distance_squared(position, POSITION_LOOKUP[p])

			if distance < best_dist then
				best, best_dist = p, distance
			end
		end
	end

	return best
end

local SPAWN_HEIGHT = 3.0
local MIN_SPAWN_HEIGHT = 1.2
local SPAWN_PUSH = 1.0
local WALL_MARGIN = 0.4

local function _raycast_statics(physics_world, from, direction, distance)
	local hit, _, hit_distance = PhysicsWorld.raycast(physics_world, from, direction, distance, "closest", "types", "statics", "collision_filter", "filter_player_character_shooting_raycast_statics")

	return hit and hit_distance or nil
end

local function _clear_spawn_position(physics_world, corpse_position, target_unit)
	-- move spawn up
	local up_origin = corpse_position + Vector3.up() * 0.5
	local height = SPAWN_HEIGHT
	local ceiling_distance = _raycast_statics(physics_world, up_origin, Vector3.up(), SPAWN_HEIGHT)

	if ceiling_distance then
		height = math.max(0.5 + ceiling_distance - WALL_MARGIN, MIN_SPAWN_HEIGHT)
	end

	local origin = corpse_position + Vector3.up() * height

	-- move spawn toward target
	local target_position = POSITION_LOOKUP[target_unit] or Unit.world_position(target_unit, 1)
	local flat = Vector3.normalize(Vector3.flat(target_position - corpse_position))
	local push = SPAWN_PUSH
	local wall_distance = _raycast_statics(physics_world, origin, flat, SPAWN_PUSH)

	if wall_distance then
		push = math.max(wall_distance - WALL_MARGIN, 0)
	end

	return origin + flat * push
end

local function _spawn_volatile_ball(position, target_unit)
	local projectile_template = ProjectileTemplates.renegade_wizard_force_ball_nurgle
	local item = MasterItems.get_cached()[projectile_template.item_name]
	local target_position = POSITION_LOOKUP[target_unit] or Unit.world_position(target_unit, 1)
	local direction = Vector3.normalize(target_position + Vector3.up() - position)
	local rotation = Quaternion.look(direction, Vector3.up())

	Managers.state.unit_spawner:spawn_network_unit(nil, "item_projectile", position, rotation, nil, item, projectile_template, TRUE_FLIGHT, direction, VOLATILE_BALL_SPEED, Vector3.zero(), nil, false, nil, nil, target_unit, nil, nil, nil, "villains")
end

-- Register buff to NetworkLookup
register_buff(VOLATILE_BUFF_NAME, {
	class_name = "proc_buff",
	predicted = false,
	max_stacks = 1,
	target = BuffSettings.targets.minion_only,
	minion_effects = table.clone(BuffTemplates.mutator_minion_nurgle_blessing_tougher.minion_effects),
	proc_events = {
		[proc_events.on_death] = 1,
	},
	check_proc_func = function(params, template_data, template_context)
		return template_context.is_server
			and not template_data.done
			and VALID_ATTACK_TYPES[params.attack_type] == true
	end,
	proc_func = function(params, template_data, template_context)
		template_data.done = true

		local unit = template_context.unit
		local corpse_position = params.position and params.position:unbox() or Unit.world_position(unit, 1)
		local target_unit = _pick_target(params.attacking_unit, corpse_position)

		if target_unit then
			local spawn_position = _clear_spawn_position(template_context.physics_world, corpse_position, target_unit)

			_spawn_volatile_ball(spawn_position, target_unit)
		end
	end,
})