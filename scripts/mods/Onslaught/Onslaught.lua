local mod = get_mod("Onslaught")

mod:echo("Onslaught v0.6.3")

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

mod.on_setting_changed = function()
    mod.debug_mode = mod:get("debug_mode")
end

mod.on_setting_changed()