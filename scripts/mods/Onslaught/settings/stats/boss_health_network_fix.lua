local mod = get_mod("Onslaught")

--[[
	Enemy health is sent to clients through two game object fields, health (max health) and
	damage. Clients read nothing else: HuskHealthExtension computes 1 - damage / health from them.
	Those fields have a fixed network range (highest value is 131071). If health goes past that, the
	values arrive clamped or wrapped on clients.

	So for bosses, the host sends health and damage divided by BOSS_NET_SCALE, and
	clients multiply the absolute values back. Real health and damage on the host
	are not changed.
]]

local BOSS_NET_SCALE = 4

local function _net_scale_for_unit(unit)
	local unit_data_extension = unit and ScriptUnit.has_extension(unit, "unit_data_system")
	local breed = unit_data_extension and unit_data_extension.breed and unit_data_extension:breed()

	if breed and breed.is_boss then
		return BOSS_NET_SCALE
	end

	return 1
end

-- HOST
mod:hook_require("scripts/extension_systems/health/health_extension", function(HealthExtension)
	local function _sync_damage(self)
		local scale = self._onslaught_net_scale

		if not scale or scale == 1 or not self._game_session or not self._game_object_id then
			return
		end

		local network_damage = math.min(self._damage, self._health) / scale

		GameSession.set_game_object_field(self._game_session, self._game_object_id, "damage", network_damage)
	end

	mod:hook(HealthExtension, "init", function(func, self, extension_init_context, unit, extension_init_data, game_object_data)
		func(self, extension_init_context, unit, extension_init_data, game_object_data)

		local scale = _net_scale_for_unit(unit)

		self._onslaught_net_scale = scale

		if scale ~= 1 then
			game_object_data.health = self._health / scale
			game_object_data.damage = math.min(self._damage, self._health) / scale
		end
	end)

	mod:hook(HealthExtension, "add_damage", function(func, self, ...)
		local actual_damage_dealt = func(self, ...)

		_sync_damage(self)

		return actual_damage_dealt
	end)

	mod:hook(HealthExtension, "add_heal", function(func, self, ...)
		local actual_heal_amount = func(self, ...)

		_sync_damage(self)

		return actual_heal_amount
	end)

	mod:hook(HealthExtension, "set_health_instant", function(func, self, ...)
		func(self, ...)
		_sync_damage(self)
	end)
end)

-- CLIENTS
mod:hook_require("scripts/extension_systems/health/husk_health_extension", function(HuskHealthExtension)
	mod:hook_safe(HuskHealthExtension, "init", function(self, extension_init_context, unit)
		self._onslaught_net_scale = _net_scale_for_unit(unit)
	end)

	local ABSOLUTE_VALUE_FUNCTIONS = {
		"current_health",
		"max_health",
		"damage_taken",
		"permanent_damage_taken",
		"total_damage_taken",
	}

	for _, function_name in ipairs(ABSOLUTE_VALUE_FUNCTIONS) do
		mod:hook(HuskHealthExtension, function_name, function(func, self, ...)
			local value = func(self, ...)
			local scale = self._onslaught_net_scale

			if value and scale and scale ~= 1 then
				return value * scale
			end

			return value
		end)
	end
end)