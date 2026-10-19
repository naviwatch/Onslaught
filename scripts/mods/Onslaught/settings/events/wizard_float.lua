local mod = get_mod("Onslaught")

--[[
	FLOATING WIZARD FOR TERROR EVENTS

	Usage in any terror event:
		{
			"onslaught_spawn_wizard_float",
			tag = "wizard",                     -- used to despawn him later; one living wizard per tag
			spawn_once = true,                  -- optional: never respawn the wizard in the same terror event
			position = { x, y, z },             -- optional: default = near a random player
			despawn_with_event = true,          -- default true: gone when THIS event ends/stops
			duration = 90,                      -- optional: forced despawn after n seconds
			invulnerable = true,                -- default true: health can't be damaged either
			show_health_bar = false,            -- optional: boss bar with the shield
			follow_distance = { 8, 14 },        -- teleport destination distance from target
			max_distance = 25,                  -- teleport if target is farther than this
			lost_los_time = 4,                  -- teleport after losing sight this long
			reposition_interval = { 12, 20 },   -- teleport anyway every n seconds
			teleport_cooldown = 5,
			shoot_cooldown_multiplier = 1,      -- scales only the short pause AFTER a cast (0.5s or 1.5s)
			enraged = true,						-- fast enraged cast anims
		},
		{
			"onslaught_despawn_wizard_float",
			tag = "wizard",
		},

	NOTE: with despawn_with_event, the event must still have nodes running after the
	spawn node, otherwise it ends that same frame and he despawns immediately
]]

local Blackboard = require("scripts/extension_systems/blackboard/utilities/blackboard")
local NavQueries = require("scripts/utilities/nav_queries")
local TerrorEventManager = require("scripts/managers/terror_event/terror_event_manager")

local BREED_NAME = "renegade_wizard"
local FLY_HEIGHT = 5.5 -- hardcoded offset in BtWizardTeleportAction._teleport
local HEAD_HEIGHT = 1.5
local MAX_POSITION_TRIES = 10
local LOS_FILTER = "filter_minion_line_of_sight_check"
local DESPAWN_VFX = "content/fx/particles/weapons/force_staff/force_staff_impact_01"

local DEFAULTS = {
	despawn_with_event = true,
	invulnerable = true,
	show_health_bar = false,
	follow_distance = { 8, 14 },
	max_distance = 25,
	lost_los_time = 4,
	reposition_interval = { 12, 20 },
	teleport_cooldown = 5,
	shoot_cooldown_multiplier = 1,
	enraged = true,
}

local wizard = {}
local wizard_by_tag = {}
local spawned_tags = {}

local function setting(node, key)
	local value = node[key]

	if value == nil then
		return DEFAULTS[key]
	end

	return value
end

local function random_range(range)
	return math.random_range(range[1], range[2])
end

-- POSITIONS
local function random_player_unit()
	local side_system = Managers.state.extension:system("side_system")
	local player_units = side_system:get_side(1).valid_player_units
	local num = #player_units

	return num > 0 and player_units[math.random(1, num)] or nil
end

local function raycast_clear(physics_world, from, to)
	local direction = to - from
	local distance = Vector3.length(direction)

	if distance < 0.01 then
		return true
	end

	local hit = PhysicsWorld.raycast(physics_world, from, Vector3.normalize(direction), distance, "closest", "collision_filter", LOS_FILTER)

	return not hit
end

-- Random navmesh spot around the target; prefers spots with room to fly and a clear shot
local function find_position_near_target(unit, target_unit, node, physics_world)
	local navigation_extension = ScriptUnit.extension(unit, "navigation_system")
	local nav_world, traverse_logic = navigation_extension:nav_world(), navigation_extension:traverse_logic()
	local target_navigation_extension = ScriptUnit.has_extension(target_unit, "navigation_system")
	local target_position = target_navigation_extension and target_navigation_extension:latest_position_on_nav_mesh() or POSITION_LOOKUP[target_unit]
	local target_head = target_position + Vector3.up() * HEAD_HEIGHT
	local distance_range = setting(node, "follow_distance")
	local fallback_position, fallback_fly

	for _ = 1, MAX_POSITION_TRIES do
		local angle = math.random() * math.two_pi
		local distance = random_range(distance_range)
		local candidate = target_position + Vector3(math.cos(angle) * distance, math.sin(angle) * distance, 0)
		local on_mesh = NavQueries.position_on_mesh(nav_world, candidate, 3, 3, traverse_logic)

		if on_mesh then
			local air_position = on_mesh + Vector3.up() * FLY_HEIGHT
			local can_fly = raycast_clear(physics_world, on_mesh + Vector3.up() * 0.5, air_position + Vector3.up() * 2) -- no ceiling
			local eye = (can_fly and air_position or on_mesh) + Vector3.up() * HEAD_HEIGHT

			if raycast_clear(physics_world, eye, target_head) then
				return on_mesh, can_fly
			end

			fallback_position = fallback_position or on_mesh
			fallback_fly = fallback_fly or can_fly
		end
	end

	return fallback_position, fallback_fly
end

-- BLACKBOARD HELPERS
local function request_teleport(data, position, should_fly)
	local teleport_component = data.teleport_component

	teleport_component.teleport_position:store(position)

	teleport_component.should_fly = should_fly or false
	teleport_component.teleport_state = "predefined"
	teleport_component.teleport_allowed = true
end

local function maintain_protection(unit, data)
	local toughness_extension = ScriptUnit.has_extension(unit, "toughness_system")

	if toughness_extension and not toughness_extension:is_invulnerable() then
		local spawn_component = data.blackboard.spawn

		toughness_extension:activate_shield()
		toughness_extension:set_invulnerable(true)
		GameSession.set_game_object_field(spawn_component.game_session, spawn_component.game_object_id, "is_toughness_invulnerable", true)
	end

	-- resets invulnerability after every teleport
	if data.invulnerable then
		local health_extension = ScriptUnit.has_extension(unit, "health_system")

		if health_extension then
			health_extension:set_invulnerable(true)
		end
	end
end

-- SPAWN / DESPAWN
local function tag_has_living_wizard(tag)
	local list = wizard_by_tag[tag]

	if list then
		for i = 1, #list do
			if HEALTH_ALIVE[list[i]] then
				return true
			end
		end
	end

	return false
end

local function spawn_wizard(node, event)
	local tag = node.tag or "default"

	if tag_has_living_wizard(tag) or (node.spawn_once and spawned_tags[tag]) then
		return
	end

	local nav_world = Managers.state.nav_mesh:nav_world()
	local position

	if node.position then
		local p = node.position
		local wanted = Vector3(p[1], p[2], p[3])

		position = NavQueries.position_on_mesh(nav_world, wanted, 5, 5) or GwNavQueries.inside_position_from_outside_position(nav_world, wanted, 5, 5, 5, 0.5)
	else
		local player_unit = random_player_unit()

		if player_unit then
			local player_position = POSITION_LOOKUP[player_unit]

			for _ = 1, MAX_POSITION_TRIES do
				local angle = math.random() * math.two_pi
				local candidate = player_position + Vector3(math.cos(angle) * 12, math.sin(angle) * 12, 0)

				position = NavQueries.position_on_mesh(nav_world, candidate, 3, 3)

				if position then
					break
				end
			end
		end
	end

	if not position then
		mod:error("onslaught_spawn_wizard_float: no navmesh spawn position found")

		return
	end

	local minion_spawn_manager = Managers.state.minion_spawn
	local side_id = Managers.state.extension:system("side_system"):get_side_from_name("villains").side_id
	local param_table = minion_spawn_manager:request_param_table()
	local unit = minion_spawn_manager:spawn_minion(BREED_NAME, position, Quaternion.identity(), side_id, param_table)

	if not unit then
		return
	end

	-- same as the vanilla boss template: no navmesh locomotion, he only moves by teleporting
	ScriptUnit.extension(unit, "locomotion_system"):set_movement_type("script_driven")

	local t = Managers.time:time("gameplay")
	local duration = node.duration

	wizard[unit] = {
		node = node,
		event = event,
		invulnerable = setting(node, "invulnerable"),
		needs_setup = true,
		next_teleport_t = t,
		reposition_t = t + random_range(setting(node, "reposition_interval")),
		end_t = duration and t + duration or nil,
	}

	local list = wizard_by_tag[tag] or {}

	wizard_by_tag[tag] = list
	list[#list + 1] = unit
	spawned_tags[tag] = true
end

local function despawn_wizard(unit)
	wizard[unit] = nil

	if not ALIVE[unit] then
		return
	end

	local fx_system = Managers.state.extension:system("fx_system")

	fx_system:trigger_vfx(DESPAWN_VFX, POSITION_LOOKUP[unit] + Vector3.up())
	Managers.state.minion_spawn:despawn_minion(unit)
end

local function despawn_tag(tag)
	tag = tag or "default"

	local list = wizard_by_tag[tag]

	if not list then
		return
	end

	for i = 1, #list do
		despawn_wizard(list[i])
	end

	wizard_by_tag[tag] = nil
end

-- UPDATE
local function event_is_running(manager, event)
	if event.stopped then
		return false
	end

	local active_events = manager._active_events

	for i = 1, #active_events do
		if active_events[i] == event then
			return true
		end
	end

	return false
end

local function first_setup(unit, data)
	local blackboard = BLACKBOARDS[unit]

	data.blackboard = blackboard
	data.teleport_component = Blackboard.write_component(blackboard, "teleport")
	data.abilities_component = Blackboard.write_component(blackboard, "abilites")
	data.abilities_component.current_ability = "" -- no boss abilities

	maintain_protection(unit, data)

	if setting(data.node, "show_health_bar") then
		local boss_extension = ScriptUnit.extension(unit, "boss_system")

		boss_extension:start_boss_encounter()
		Managers.state.game_session:send_rpc_clients("rpc_start_boss_encounter", blackboard.spawn.game_object_id)
	end

	request_teleport(data, POSITION_LOOKUP[unit], true)

	data.needs_setup = false
end

local function update_wizard(manager, unit, data, t)
	local node = data.node

	if (data.end_t and t > data.end_t) or (setting(node, "despawn_with_event") and data.event and not event_is_running(manager, data.event)) then
		despawn_wizard(unit)

		return
	end

	if data.needs_setup then
		first_setup(unit, data)

		return
	end

	maintain_protection(unit, data)

	local abilities_component = data.abilities_component

	abilities_component.basic_attack_multiplier = setting(node, "shoot_cooldown_multiplier")
	abilities_component.is_enraged = setting(node, "enraged")

	local perception_component = data.blackboard.perception
	local target_unit = perception_component.target_unit

	if not HEALTH_ALIVE[target_unit] then
		return
	end

	-- idle action
	abilities_component.default_look_at_position:store(POSITION_LOOKUP[target_unit])

	-- follow: never interrupt a shot or a running teleport
	if data.teleport_component.teleport_allowed or abilities_component.in_basic_attack then
		return
	end

	if perception_component.has_line_of_sight then
		data.lost_los_t = nil
	else
		data.lost_los_t = data.lost_los_t or t
	end

	local too_far = Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[target_unit]) > setting(node, "max_distance")
	local lost_sight = data.lost_los_t and t - data.lost_los_t > setting(node, "lost_los_time")
	local reposition = t > data.reposition_t

	if t < data.next_teleport_t or not (too_far or lost_sight or reposition) then
		return
	end

	local position, can_fly = find_position_near_target(unit, target_unit, node, data.blackboard.spawn.physics_world)

	data.next_teleport_t = t + setting(node, "teleport_cooldown")

	if position then
		request_teleport(data, position, can_fly)

		data.reposition_t = t + random_range(setting(node, "reposition_interval"))
		data.lost_los_t = nil
	end
end

mod:hook_safe(TerrorEventManager, "update", function(self, dt, t)
	if not self._is_server or next(wizard) == nil then
		return
	end

	local gameplay_t = Managers.time:time("gameplay")

	for unit, data in pairs(wizard) do
		if HEALTH_ALIVE[unit] then
			update_wizard(self, unit, data, gameplay_t)
		else
			wizard[unit] = nil
		end
	end
end)

-- New terror event nodes (called from functions.lua)
mod.register_wizard_float_nodes = function(TerrorEventNodes)
	TerrorEventNodes.onslaught_spawn_wizard_float = {
		init = function(node, event, t)
			spawn_wizard(node, event)
		end,
		update = function(node, scratchpad, t, dt)
			return true
		end,
	}

	TerrorEventNodes.onslaught_despawn_wizard_float = {
		init = function(node, event, t)
			despawn_tag(node.tag)
		end,
		update = function(node, scratchpad, t, dt)
			return true
		end,
	}
end

-- Cleanup (called from functions.lua)
mod.clear_wizard_float_state = function()
	table.clear(wizard)
	table.clear(wizard_by_tag)
	table.clear(spawned_tags)
end
