local mod = get_mod("Onslaught")

local roamer_melee = "renegade_melee"
local roamer_assault = "renegade_assault"
local roamer_rifleman = "renegade_rifleman"
local elite_executor = "renegade_executor"
local elite_berzerker = "renegade_berzerker"
local elite_gunner = "renegade_gunner"
local bulwark = "chaos_ogryn_bulwark"
local ogryn_gunner = "chaos_ogryn_gunner"
local ogryn_executor = "chaos_ogryn_executor"
local elite_shocktrooper = "renegade_shocktrooper"
local elite_plasma_gunner = "renegade_plasma_gunner"
local roamer_vanguard = "renegade_vanguard"

local roamer_packs = {
    renegade_mixed_high = {
        {
            weight = 1,
            breeds = {
                elite_berzerker,
                roamer_assault,
                roamer_melee,
                roamer_melee,
                roamer_assault,
                elite_gunner,
                elite_berzerker,
                elite_berzerker,
            },
        },
        {
            weight = 1,
            breeds = {
                ogryn_executor,
                ogryn_gunner,
                roamer_melee,
                roamer_melee,
                elite_shocktrooper,
                roamer_assault,
                elite_berzerker,
                elite_berzerker,
                elite_berzerker,
                roamer_assault,
            },
        },
        {
            weight = 1,
            breeds = {
                elite_executor,
                roamer_assault,
                roamer_vanguard,
                roamer_melee,
                roamer_assault,
                elite_gunner,
                elite_berzerker,
                elite_berzerker,
                roamer_vanguard,
                roamer_assault,
            },
        },
        {
            weight = 0.5,
            breeds = {
                elite_berzerker,
                ogryn_gunner,
                roamer_melee,
                roamer_melee,
                ogryn_gunner,
                elite_plasma_gunner,
                elite_berzerker,
                elite_berzerker,
                elite_berzerker,
                roamer_melee,
            },
        },
        {
            weight = 1,
            breeds = {
                ogryn_executor,
                elite_gunner,
                roamer_melee,
                roamer_melee,
                elite_plasma_gunner,
                roamer_rifleman,
                elite_executor,
                elite_berzerker,
                elite_berzerker,
                elite_gunner,
            },
        },
        {
            weight = 1,
            breeds = {
                elite_berzerker,
                roamer_assault,
                elite_executor,
                roamer_melee,
                roamer_assault,
                elite_gunner,
                elite_berzerker,
                elite_berzerker,
                elite_berzerker,
                roamer_assault,
            },
        },
    },
    renegade_mixed_low = {
        {
            weight = 1,
            breeds = {
                elite_executor,
                ogryn_gunner,
                roamer_vanguard,
                roamer_melee,
                elite_shocktrooper,
                roamer_assault,
                elite_executor,
                elite_executor,
                roamer_vanguard,
                elite_gunner,
            },
        },
        {
            weight = 1,
            breeds = {
                elite_executor,
                elite_plasma_gunner,
                roamer_vanguard,
                roamer_melee,
                elite_plasma_gunner,
                roamer_assault,
                elite_executor,
                elite_berzerker,
                roamer_vanguard,
                elite_gunner,
            },
        },
        {
            weight = 1,
            breeds = {
                bulwark,
                elite_gunner,
                roamer_vanguard,
                roamer_melee,
                elite_gunner,
                roamer_assault,
                elite_executor,
                elite_executor,
                roamer_vanguard,
                elite_shocktrooper,
            },
        },
        {
            weight = 1,
            breeds = {
                elite_executor,
                ogryn_gunner,
                roamer_vanguard,
                roamer_melee,
                elite_plasma_gunner,
                elite_shocktrooper,
                elite_executor,
                elite_executor,
                roamer_vanguard,
                elite_gunner,
            },
        },
        {
            weight = 1,
            breeds = {
                elite_executor,
                elite_plasma_gunner,
                elite_executor,
                roamer_melee,
                elite_plasma_gunner,
                roamer_assault,
                elite_executor,
                elite_executor,
                roamer_vanguard,
                elite_shocktrooper,
            },
        },
        {
            weight = 1,
            breeds = {
                elite_executor,
                elite_shocktrooper,
                bulwark,
                roamer_melee,
                elite_shocktrooper,
                elite_shocktrooper,
                elite_executor,
                bulwark,
                roamer_vanguard,
                elite_gunner,
            },
        },
    }
}

return roamer_packs