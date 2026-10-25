local mod = get_mod("Onslaught")


mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/event_settings/points_load")
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/sand_vortex")
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/wizard_float")
mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/functions") 

-- because i dont know when fatshark will decide to change up the events, so we'll hook into terror_event_templates and override it with our own version of the same template
-- and also because im way more familiar with how vermintide does it so i want to keep the code structure as similar to it for myself

mod:hook_require("scripts/settings/terror_event/terror_event_templates", function(instance)
    local lm_cooling = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/maps/power_matrix") 
    local fm_cargo = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/maps/consignment_yard") 
    local fm_armoury = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/maps/mercantile") 
    local fm_resurgence = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/maps/baross")
	local dm_propaganda = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/maps/relay_station")
    local km_heresy = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/maps/dark_communion")
    local cm_archives = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/maps/archivum_sycorax")
    local dm_stockpile = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/maps/silo_cluster") 
	
    --[[
    for key, _ in pairs(instance) do
        mod:echo(string.format("[DEBUG] Terror Event Template Key: %s", key))
    end
    ]]

    -- Power Matrix
    instance["terror_events_lm_cooling"] = lm_cooling
    -- Consignment Yard
    instance["terror_events_fm_cargo"] = fm_cargo
    -- Mercantile
    instance["terror_events_fm_armoury"] = fm_armoury
    -- Baross
    instance["terror_events_fm_resurgence"] = fm_resurgence
	-- Relay Station
	instance["terror_events_dm_propaganda"] = dm_propaganda
	-- Silo Cluster
	instance["terror_events_dm_stockpile"] = dm_stockpile
    -- Dark Communion
    instance["terror_events_km_heresy"] = km_heresy
	-- Archivum Sycorax
	instance["terror_events_cm_archives"] = cm_archives
end)

local TerrorEventManager = require("scripts/managers/terror_event/terror_event_manager")

mod:hook_safe(TerrorEventManager, "start_event", function(self, event_name, optional_seed, optional_level)
    if mod.debug_mode then
        mod:echo(event_name)
    end
end)