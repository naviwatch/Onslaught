local mod = get_mod("Onslaught")

mod:echo("Onslaught v0.6.5")

-- Normal Pacing
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/pacing")

-- Horde Pacing
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/horde/horde_template")

-- Specials Pacing
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/specials/specials_template")

-- Ambients
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/roamer/roamer_template")

-- Monsters HP increase
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/stats/monster")

-- Boss Health Bars Network Fix
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/stats/boss_health_network_fix")

-- Mutators
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/havoc_mutators")

-- Enemy tweaks
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/stats/enemies")

-- Events
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/terror_event_template")

-- EventPractice
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/teleport")


-- Debug stuff
local hud_element = {
	class_name = "specials_debug",
	filename = "Onslaught/scripts/mods/Onslaught/settings/specials/specials_debug",
	use_hud_scale = true,
	visibility_groups = {
		"alive",
		"tactical_overlay",
		"communication_wheel",
	},
}

mod:add_require_path(hud_element.filename)

local function add_special_slots_hud(elements)
	if not table.find_by_key(elements, "class_name", hud_element.class_name) then
		table.insert(elements, hud_element)
	end
end

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
	add_special_slots_hud(elements)

	return func(self, elements, visibility_groups, params)
end)


-- Settings
mod.on_setting_changed = function()
    mod.debug_mode = mod:get("debug_mode")
end

mod.on_setting_changed()