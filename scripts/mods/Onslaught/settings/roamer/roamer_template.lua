local mod = get_mod("Onslaught")
local RoamerPacing = require("scripts/managers/pacing/roamer_pacing/roamer_pacing")
local RoamerLimits = require("scripts/settings/roamer/roamer_limits")
local RoamerPacks = require("scripts/settings/roamer/roamer_packs")
local limits = RoamerLimits.havoc
local default_packs = {
	melee_low = {
		renegade = RoamerPacks.renegade_melee_low,
		cultist = RoamerPacks.cultist_melee_low,
	},
	melee_high = {
		renegade = RoamerPacks.renegade_melee_high,
		cultist = RoamerPacks.cultist_melee_high,
	},
	close_low = {
		renegade = RoamerPacks.renegade_close_low,
		cultist = RoamerPacks.cultist_close_low,
	},
	close_high = {
		renegade = RoamerPacks.renegade_close_high,
		cultist = RoamerPacks.cultist_close_high,
	},
	far_low = {
		renegade = RoamerPacks.renegade_far_low_uprising,
		cultist = RoamerPacks.cultist_far_low,
	},
	far_high = {
		renegade = RoamerPacks.renegade_far_high,
		cultist = RoamerPacks.cultist_far_high,
	},
	mixed_low = {
		renegade = RoamerPacks.renegade_mixed_low,
		cultist = RoamerPacks.cultist_mixed_low,
	},
	mixed_high = {
		renegade = RoamerPacks.renegade_mixed_high,
		cultist = RoamerPacks.cultist_mixed_high,
	},
	none = {
		renegade = RoamerPacks.renegade_traitor_mix_none,
		cultist = RoamerPacks.cultist_infected_mix_none,
	},
	encampment = {
		renegade = RoamerPacks.chaos_poxwalker_encampment,
		cultist = RoamerPacks.chaos_poxwalker_encampment,
	},
}

--[[
	============================================================================
	ROAMER PACKS
	============================================================================
]]

local RoamerPacks = require("scripts/settings/roamer/roamer_packs") -- cached table, safe to mutate

local sources = {
    mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/roamer/roamer_packs/cultist_roamer_pack"),
    mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/roamer/roamer_packs/renegade_roamer_pack"),
}

local CUSTOM = {}
for _, source in ipairs(sources) do
    for vanilla_name, packs in pairs(source) do
        local name = "onslaught_" .. vanilla_name
        packs.name = name          -- RoamerPacing looks up the dice by this name
        RoamerPacks[name] = packs  -- must exist before a mission starts (RoamerPacing.init)
        CUSTOM[vanilla_name] = packs
    end
end

local onslaught_packs = {
    mixed_high = { renegade = CUSTOM.renegade_mixed_high, cultist = CUSTOM.cultist_mixed_high },
    mixed_low  = { renegade = CUSTOM.renegade_mixed_low,  cultist = CUSTOM.cultist_mixed_low },
}

--[[
	============================================================================
	ROAMER LIMITS
	============================================================================
]]

mod:hook_require("scripts/settings/roamer/havoc_roamer_limits", function(roamer_limits)
    if type(roamer_limits) ~= "table" or not roamer_limits.limits then return end

    local NEW_LIMITS = {
        -- Melee trash
        renegade_melee = 999,
        cultist_melee = 999,
		renegade_vanguard = 4,
		cultist_vanguard = 4,
        -- Ranged trash
        cultist_assault = 10,
        renegade_assault = 10,
        renegade_rifleman = 10,
        -- Melee elites
        renegade_executor = 8,
        renegade_berzerker = 8,
        cultist_berzerker = 8,
        -- Ranged elites
        renegade_gunner = 4,
        cultist_gunner = 4,
        renegade_plasma_gunner = 3,
        renegade_shocktrooper = 8,
        cultist_shocktrooper = 8,
        -- Ogryns
        chaos_ogryn_executor = 2,
        chaos_ogryn_bulwark = 1,
        chaos_ogryn_gunner = 1,
    }

    local DISABLED_TAG_LIMITS = {
        elite = 7, 
        ogryn = 3,
    }

    for density_name, configs in pairs(roamer_limits.limits) do
        if type(configs) == "table" then
            for i, config in ipairs(configs) do
                config.tag_limits = DISABLED_TAG_LIMITS

                for key, value in pairs(config) do
                    if type(value) == "table" and (value.max or value.extra_replacement) then
                        -- Check if this breed is in our whitelist
                        if NEW_LIMITS[key] then
                            value.max = NEW_LIMITS[key]
                            value.num_limitations_to_add_extra = 999
                        end

                    elseif type(value) == "number" then
                        if NEW_LIMITS[key] then
                            config[key] = NEW_LIMITS[key]
                        else
                            config[key] = 0
                        end
                    end
                end

                for breed_name, max in pairs(NEW_LIMITS) do
                    if config[breed_name] == nil then
                        config[breed_name] = {
                            max = max,
                            num_limitations_to_add_extra = 999,
                            extra_replacement = breed_name,
                        }
                    end
                end
            end
        end
    end

    -- mod:echo("Roamer limits updated")
end)

--[[
	============================================================================
	ROAMER PACING
	============================================================================
]]

mod:hook_require("scripts/managers/pacing/roamer_pacing/templates/havoc_roamer_pacing_template", function(template)
    if type(template) ~= "table" then return end

	template.density_types = { "high" }
    template.density_order = {
        default = "high",
        low = "high",
        none = "high",
        high = "high",
    }

    for i, level in ipairs(template.density_settings) do
        if level.high then
            level.high.zone_range = { 1, 2 }
            level.high.num_roamers_range = {
                renegade = { 20, 20 },  
                cultist = { 20, 20 },
            }

            -- Melee, Close (Assault/Riflemen+Shotgunners), Far (Assault/Riflemen+Gunners), Mixed (we change this one)

            level.high.packs = {
                onslaught_packs.mixed_high,
                onslaught_packs.mixed_low
            }
            
        --    mod:echo("Done")
        end
    end

end)

mod:hook_require("scripts/managers/pacing/roamer_pacing/templates/havoc_roamer_pacing_template", function(template)
    if type(template) ~= "table" then return end

    local max = 20

    if mod:get("giga_ambients") then
        max = 40
    end

	template.density_types = { "high" }
    template.density_order = {
        default = "high",
        low = "high",
        none = "high",
        high = "high",
    }

    for i, level in ipairs(template.density_settings) do
        if level.high then
            level.high.zone_range = { 1, 2 }
            level.high.num_roamers_range = {
                renegade = { max, max },
                cultist = { max, max },
            }

            level.high.packs = {
                onslaught_packs.mixed_high,
                onslaught_packs.mixed_low
            }
            
        end
    end
end)

mod:hook_require("scripts/managers/pacing/roamer_pacing/templates/default_roamer_pacing_template", function(template)
    if type(template) ~= "table" then return end

    local max = 20

    if mod:get("giga_ambients") then
        max = 40
    end

	template.density_types = { "high" }
    template.density_order = {
        default = "high",
        low = "high",
        none = "high",
        high = "high",
    }

    for i, level in ipairs(template.density_settings) do
        if level.high then
            level.high.zone_range = { 1, 2 }
            level.high.num_roamers_range = {
                renegade = { max, max },
                cultist = { max, max },
            }

            level.high.packs = {
                onslaught_packs.mixed_high,
                onslaught_packs.mixed_low
            }
            
        end
    end
end)