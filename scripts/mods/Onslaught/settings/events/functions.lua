local mod = get_mod("Onslaught")

-- ============================================================================
-- CUSTOM TERROR EVENT NODES
-- ============================================================================

local NODE_NAME = "onslaught_spawn_buffed_breed"

--[[
	Same as vanilla spawn_by_breed_name, but with buffs!!!!!
	Usage in any event:
		{
			"onslaught_spawn_buffed_breed",
			breed_name = "chaos_ogryn_executor",
			breed_amount = 1,
			limit_spawners = 1,
			delay_until_all_spawned = false,
			spawner_group = "spawner_cooling_hacking_close",
			buffs = { "havoc_encroaching_garden" },
		},
]]

local pending = {}
local buffed = {}

mod:hook_require("scripts/managers/terror_event/terror_event_nodes", function(TerrorEventNodes)
	local vanilla = TerrorEventNodes.spawn_by_breed_name

	TerrorEventNodes[NODE_NAME] = {
		init = function(node, event, t)
			local spawned_minion_data = event.spawned_minion_data

			-- snapshot existing queue ids so we can tell which ones are ours
			local counts_before = {}
			local queue_map = spawned_minion_data.spawner_queue_id

			if queue_map then
				for spawner, queue_ids in pairs(queue_map) do
					counts_before[spawner] = #queue_ids
				end
			end

			vanilla.init(node, event, t)

			queue_map = spawned_minion_data.spawner_queue_id

			if not queue_map then
				return
			end

			local gameplay_t = Managers.time:time("gameplay")

			for spawner, queue_ids in pairs(queue_map) do
				for i = (counts_before[spawner] or 0) + 1, #queue_ids do
					local entries = pending[spawner] or {}

					pending[spawner] = entries
					entries[#entries + 1] = {
						queue_id = queue_ids[i],
						buffs = node.buffs,
						expire_t = gameplay_t + 120, -- safety net; normally cleared when the spawner goes idle
					}
				end
			end
		end,
		update = vanilla.update,
	}
 
	-- onslaught_spawn_vortex / onslaught_despawn_vortex (in sand_vortex.lua)
	if mod.register_vortex_nodes then
		mod.register_vortex_nodes(TerrorEventNodes)
	end
end)

local function apply_buffs(unit, buffs, t)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

	if not buff_extension then
		return
	end

	for k = 1, #buffs do
		local buff_name = buffs[k]

		if buff_extension:is_valid_target(buff_name) then
			buff_extension:add_internally_controlled_buff(buff_name, t)
		end
	end
end

-- Apply buffs to spawned enemies
local MinionSpawnerExtension = require("scripts/extension_systems/minion_spawner/minion_spawner_extension")

mod:hook_safe(MinionSpawnerExtension, "update", function(self, unit, dt, t)
	local entries = pending[self]

	if not entries then
		return
	end

	local gameplay_t = Managers.time:time("gameplay")
	local still_spawning = self:is_spawning()

	for i = #entries, 1, -1 do
		local entry = entries[i]
		local units = self:spawned_minions_by_queue_id(entry.queue_id)

		if units then
			for j = 1, #units do
				local minion = units[j]

				if not buffed[minion] and HEALTH_ALIVE[minion] then
					buffed[minion] = true

					apply_buffs(minion, entry.buffs, gameplay_t)
				end
			end
		end

		if not still_spawning or entry.expire_t < gameplay_t then
			table.remove(entries, i)
		end
	end

	if #entries == 0 then
		pending[self] = nil
	end
end)

mod.on_game_state_changed = function(status, state_name)
	table.clear(pending)
	table.clear(buffed)
	
	-- clear sand vortex
	if mod.clear_vortex_state then
		mod.clear_vortex_state()
	end
end