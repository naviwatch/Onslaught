local mod = get_mod("Onslaught")

local roamer_melee = "cultist_melee"
local roamer_assault = "cultist_assault"
local roamer_rifleman = "cultist_assault"
local elite_berzerker = "cultist_berzerker"
local elite_gunner = "cultist_gunner"
local elite_gunner_two = "cultist_gunner"
local bulwark = "chaos_ogryn_bulwark"
local elite_shocktrooper = "cultist_shocktrooper"
local shocktrooper_two = "cultist_shocktrooper"
local ogryn_executor = "chaos_ogryn_executor"
local elite_plasma_gunner = "renegade_plasma_gunner"
local roamer_vanguard = "cultist_vanguard"

local roamer_packs = {
    cultist_mixed_high = {
        {
            weight = 1,
            breeds = {
                elite_berzerker,
                roamer_assault,
                roamer_melee,
                roamer_melee,
                roamer_rifleman,
                roamer_melee,
                elite_berzerker,
                roamer_assault,
                elite_berzerker,
                roamer_rifleman,
            },
        },
        {
            weight = 1,
            breeds = {
                ogryn_executor,
                elite_shocktrooper,
                roamer_melee,
                roamer_melee,
                elite_shocktrooper,
                roamer_assault,
                ogryn_executor,
                elite_shocktrooper,
                ogryn_executor,
                roamer_assault,
            },
        },
        {
            weight = 1,
            breeds = {
                elite_berzerker,
                roamer_assault,
                roamer_vanguard,
                roamer_melee,
                roamer_rifleman,
                roamer_vanguard,
                elite_berzerker,
                elite_plasma_gunner,
                elite_berzerker,
                elite_plasma_gunner,
            },
        },
        {
            weight = 0.5,
            breeds = {
                elite_berzerker,
                elite_shocktrooper,
                roamer_melee,
                roamer_melee,
                elite_shocktrooper,
                roamer_melee,
                elite_berzerker,
                elite_shocktrooper,
                elite_berzerker,
                roamer_melee,
            },
        },
        {
            weight = 1,
            breeds = {
                ogryn_executor,
                roamer_rifleman,
                roamer_melee,
                roamer_melee,
                elite_shocktrooper,
                roamer_rifleman,
                ogryn_executor,
                elite_gunner,
                elite_berzerker,
                roamer_rifleman,
            },
        },
        {
            weight = 1,
            breeds = {
                elite_berzerker,
                roamer_assault,
                elite_berzerker,
                roamer_melee,
                roamer_assault,
                elite_plasma_gunner,
                elite_berzerker,
                roamer_assault,
                elite_berzerker,
                roamer_assault,
            },
        },
    },
    cultist_mixed_low = {
        {
            weight = 1,
            breeds = {
                elite_berzerker,
                elite_shocktrooper,
                roamer_vanguard,
                roamer_melee,
                elite_plasma_gunner,
                roamer_assault,
                elite_berzerker,
                elite_shocktrooper,
                elite_berzerker,
                roamer_vanguard,
            },
        },
        {
            weight = 1,
            breeds = {
                elite_berzerker,
                elite_shocktrooper,
                roamer_vanguard,
                roamer_melee,
                elite_plasma_gunner,
                roamer_assault,
                elite_berzerker,
                elite_shocktrooper,
                elite_berzerker,
                roamer_vanguard,
            },
        },
        {
            weight = 1,
            breeds = {
                bulwark,
                roamer_rifleman,
                roamer_vanguard,
                roamer_melee,
                roamer_assault,
                roamer_vanguard,
                elite_berzerker,
                elite_gunner,
                elite_berzerker,
                elite_shocktrooper,
            },
        },
        {
            weight = 0.5,
            breeds = {
                elite_berzerker,
                elite_shocktrooper,
                roamer_vanguard,
                roamer_melee,
                elite_shocktrooper,
                roamer_rifleman,
                elite_berzerker,
                roamer_rifleman,
                elite_berzerker,
                elite_gunner,
            },
        },
        {
            weight = 1,
            breeds = {
                elite_berzerker,
                roamer_rifleman,
                roamer_vanguard,
                roamer_melee,
                elite_shocktrooper,
                roamer_assault,
                elite_berzerker,
                elite_gunner,
                elite_berzerker,
                roamer_rifleman,
            },
        },
        {
            weight = 1,
            breeds = {
                elite_berzerker,
                elite_shocktrooper,
                roamer_vanguard,
                roamer_melee,
                elite_shocktrooper,
                bulwark,
                elite_berzerker,
                elite_shocktrooper,
                bulwark,
                elite_plasma_gunner,
            },
        },
    }
}

return roamer_packs