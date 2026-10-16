local mod = get_mod("Onslaught")

--[[
	============================================================================
	SAND VORTEX FOR TERROR EVENTS

	Usage in any terror event:
		{
			"onslaught_spawn_vortex",
			tag = "dust_vortex",               -- used to despawn it later
			position = { x, y, z },            -- world coordinates
			duration = 60,                     -- optional: forced end after n seconds
			dissipation_time = 4,              -- optional: fade-out length (vanilla 10)
			overrides = {                      -- optional: vortex_template fields
				outer_radius = 10,
				forced_standing_still = true,
			},
		},
		{
			"onslaught_despawn_vortex",
			tag = "dust_vortex",
			instant = false,                   -- true = remove immediately, no fade
		},
	============================================================================
]]

local NavQueries = require("scripts/utilities/nav_queries")
local MinionVortexExtension = require("scripts/extension_systems/minion_vortex/minion_vortex_extension")

local BREED_NAME = "sand_vortex"
local DEFAULT_DISSIPATION_TIME = 10 -- 10
local STOP_SFX = "wwise/events/world/stop_vortex_loop"
local EXTRA_RESOURCES = {
	"content/fx/particles/environment/expeditions/wastes/sand_tornado_01",
	"content/fx/particles/environment/expeditions/wastes/sand_tornado_01_startup",
	"content/fx/particles/screenspace/player_screen_sand_tornado",
	"wwise/events/world/play_vortex_loop",
	"wwise/events/world/stop_vortex_loop",
}
local FALLBACK_PACKAGE = "packages/game_mode/expedition"

local function package_exists(name)
	return Application.can_get_resource("package", name)
end

local function build_resource_list()
	local list, missing = {}, {}

	for i = 1, #EXTRA_RESOURCES do
		local name = EXTRA_RESOURCES[i]

		if package_exists(name) then
			list[#list + 1] = name
		else
			missing[#missing + 1] = name
		end
	end

	if #missing > 0 then
		if package_exists(FALLBACK_PACKAGE) then
			list[#list + 1] = FALLBACK_PACKAGE
		else
			mod:warning("[sand_vortex] no package for: %s (and no fallback package)", table.concat(missing, ", "))
		end
	end

	if mod.debug_mode then
		mod:echo("[sand_vortex] loading: %s", table.concat(list, ", "))
	end

	return list
end

-- Load necessary resources
local resource_list = build_resource_list()
local loose_resources = {}
local extra_packages = {}

for i = 1, #resource_list do
	local name = resource_list[i]

	if string.sub(name, 1, 8) == "content/" or string.sub(name, 1, 6) == "wwise/" then
		loose_resources[#loose_resources + 1] = name
	else
		extra_packages[#extra_packages + 1] = name
	end
end

mod:hook_require("scripts/settings/breed/breeds", function(Breeds)
	local breed = Breeds[BREED_NAME]

	if breed then
		breed.onslaught_extra_resources = loose_resources
	end
end)

local BreedLoader = require("scripts/loading/loaders/breed_loader")

mod:hook_safe(BreedLoader, "start_loading", function(self, context)
	local Missions = require("scripts/settings/mission/mission_templates")
	local mission = Missions[context.mission_name]

	if not mission or mission.is_hub or #extra_packages == 0 or self._onslaught_vortex_package_ids then
		return
	end

	local ids = {}

	for i = 1, #extra_packages do
		ids[#ids + 1] = Managers.package:load(extra_packages[i], "Onslaught_sand_vortex")
	end

	self._onslaught_vortex_package_ids = ids
end)

mod:hook_safe(BreedLoader, "cleanup", function(self)
	local ids = self._onslaught_vortex_package_ids

	if not ids then
		return
	end

	for i = 1, #ids do
		Managers.package:release(ids[i])
	end

	self._onslaught_vortex_package_ids = nil
end)

-- Apply overrides to vortex_template fields
local default_template = nil

local function vortex_template()
	local Breeds = require("scripts/settings/breed/breeds")

	return Breeds[BREED_NAME].vortex_template
end

local function apply_overrides(overrides)
	local template = vortex_template()

	default_template = default_template or table.clone(template)

	for key in pairs(template) do
		if default_template[key] == nil then
			template[key] = nil
		end
	end

	for key, value in pairs(default_template) do
		template[key] = type(value) == "table" and table.clone(value) or value
	end

	if overrides then
		for key, value in pairs(overrides) do
			template[key] = value
		end
	end
end

-- Custom lifetime
local vortices_by_tag = {}
local end_data = {}

local function force_dissipate(extension, t, dissipation_time)
	if extension._lifetime_end then
		return
	end

	extension._dissipate_t = t
	extension._lifetime_end = t + (dissipation_time or DEFAULT_DISSIPATION_TIME)

	if extension._sfx_id then
		local _, wwise_world = extension:_game_world()

		WwiseWorld.stop_event(wwise_world, extension._sfx_id)
		WwiseWorld.trigger_resource_event(wwise_world, STOP_SFX, extension._sfx_source_id)

		extension._sfx_id = nil
	end
end

local function despawn_now(unit)
	if not ALIVE[unit] then
		return
	end

	local navigation_extension = ScriptUnit.has_extension(unit, "navigation_system")

	if navigation_extension then
		navigation_extension:stop()
	end

	Managers.state.minion_spawn:despawn_minion(unit)
end

mod:hook_safe(MinionVortexExtension, "update", function(self, context, dt, t)
	local unit = self._unit
	local data = end_data[unit]

	if data and t >= data.end_t then
		end_data[unit] = nil

		force_dissipate(self, t, data.dissipation_time)
	end
end)

-- Spawn vortex
local function spawn_vortex(node, t)
	local position = node.position

	if not position then
		mod:error("onslaught_spawn_vortex: missing position")
		return
	end

	local wanted_position = Vector3(position[1], position[2], position[3])
	local nav_world = Managers.state.nav_mesh:nav_world()
	local nav_position = NavQueries.position_on_mesh(nav_world, wanted_position, 5, 5)
		or GwNavQueries.inside_position_from_outside_position(nav_world, wanted_position, 5, 5, 5, 0.5)

	if not nav_position then
		mod:error("onslaught_spawn_vortex: no navmesh near %s", tostring(wanted_position))
		return
	end

	for i = 1, #extra_packages do
		if not Managers.package:has_loaded(extra_packages[i]) then
			mod:warning("onslaught_spawn_vortex: %s not loaded yet, vortex skipped", extra_packages[i])
			return
		end
	end

	apply_overrides(node.overrides)

	local side_system = Managers.state.extension:system("side_system")
	local side_id = side_system:get_side_from_name("villains").side_id
	local params = {}
	local unit = Managers.state.minion_spawn:spawn_minion(BREED_NAME, nav_position, Quaternion.identity(), side_id, params)

	if not unit then
		return
	end

	local tag = node.tag or "default"
	local list = vortices_by_tag[tag] or {}

	vortices_by_tag[tag] = list
	list[#list + 1] = unit

	if node.duration then
		end_data[unit] = {
			end_t = t + node.duration,
			dissipation_time = node.dissipation_time,
		}
	end
end

-- End vortex
local function end_vortices(tag, instant, dissipation_time)
	local list = vortices_by_tag[tag or "default"]

	if not list then
		return
	end

	for i = 1, #list do
		local unit = list[i]

		if ALIVE[unit] then
			if instant then
				end_data[unit] = nil

				despawn_now(unit)
			else
				end_data[unit] = {
					end_t = -math.huge,
					dissipation_time = dissipation_time,
				}
			end
		end
	end

	vortices_by_tag[tag or "default"] = nil
end

-- New terror event nodes (called from functions.lua)
mod.register_vortex_nodes = function(TerrorEventNodes)
	TerrorEventNodes.onslaught_spawn_vortex = {
		init = function(node, event, t)
			spawn_vortex(node, t)
		end,
		update = function(node, scratchpad, t, dt)
			return true
		end,
	}

	TerrorEventNodes.onslaught_despawn_vortex = {
		init = function(node, event, t)
			end_vortices(node.tag, node.instant, node.dissipation_time)
		end,
		update = function(node, scratchpad, t, dt)
			return true
		end,
	}
end

-- Cleanup (called from functions.lua)
mod.clear_vortex_state = function()
	table.clear(vortices_by_tag)
	table.clear(end_data)

	if default_template then
		apply_overrides(nil)
	end
end