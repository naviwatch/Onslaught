local mod = get_mod("Onslaught")

-- this is not used anywhere and is kept here for archive purposes

local breed_chaos_beast_of_nurgle = require("scripts/settings/breed/breeds/chaos/chaos_beast_of_nurgle_breed")
local breed_chaos_daemonhost = require("scripts/settings/breed/breeds/chaos/chaos_daemonhost_breed")
local breed_chaos_mutator_daemonhost = require("scripts/settings/breed/breeds/chaos/chaos_mutator_daemonhost_breed")
local breed_chaos_ogryn_bulwark = require("scripts/settings/breed/breeds/chaos/chaos_ogryn_bulwark_breed")
local breed_chaos_ogryn_executor = require("scripts/settings/breed/breeds/chaos/chaos_ogryn_executor_breed")
local breed_chaos_ogryn_gunner = require("scripts/settings/breed/breeds/chaos/chaos_ogryn_gunner_breed")
local breed_chaos_ogryn_houndmaster = require("scripts/settings/breed/breeds/chaos/chaos_ogryn_houndmaster_breed")
local breed_chaos_plague_ogryn = require("scripts/settings/breed/breeds/chaos/chaos_plague_ogryn_breed")
local breed_chaos_spawn = require("scripts/settings/breed/breeds/chaos/chaos_spawn_breed")
local breed_cultist_berzerker = require("scripts/settings/breed/breeds/cultist/cultist_berzerker_breed")
local breed_cultist_captain = require("scripts/settings/breed/breeds/cultist/cultist_captain_breed")
local breed_cultist_gunner = require("scripts/settings/breed/breeds/cultist/cultist_gunner_breed")
local breed_cultist_shocktrooper = require("scripts/settings/breed/breeds/cultist/cultist_shocktrooper_breed")
local breed_renegade_berzerker = require("scripts/settings/breed/breeds/renegade/renegade_berzerker_breed")
local breed_renegade_captain = require("scripts/settings/breed/breeds/renegade/renegade_captain_breed")
local breed_renegade_executor = require("scripts/settings/breed/breeds/renegade/renegade_executor_breed")
local breed_renegade_gunner = require("scripts/settings/breed/breeds/renegade/renegade_gunner_breed")
local breed_renegade_plasma_gunner = require("scripts/settings/breed/breeds/renegade/renegade_plasma_gunner_breed")
local breed_renegade_radio_operator = require("scripts/settings/breed/breeds/renegade/renegade_radio_operator_breed")
local breed_renegade_shocktrooper = require("scripts/settings/breed/breeds/renegade/renegade_shocktrooper_breed")
local breed_renegade_twin_captain = require("scripts/settings/breed/breeds/renegade/renegade_twin_captain_breed")
local breed_renegade_twin_captain_two = require("scripts/settings/breed/breeds/renegade/renegade_twin_captain_two_breed")

local HitZone = require("scripts/utilities/attack/hit_zone")
local hit_zone_names = HitZone.hit_zone_names

-- ADD HIT ZONE DAMAGE MULTIPLIER AGAINST ATTACK TYPE EXPLOSION
local function set_explosion_center_mass(breed, value)
	breed.hitzone_damage_multiplier = breed.hitzone_damage_multiplier or {}
	breed.hitzone_damage_multiplier.explosion = breed.hitzone_damage_multiplier.explosion or {}
	breed.hitzone_damage_multiplier.explosion[hit_zone_names.center_mass] = value
end

set_explosion_center_mass(breed_chaos_beast_of_nurgle, 0.5)
set_explosion_center_mass(breed_chaos_daemonhost, 0.5)
set_explosion_center_mass(breed_chaos_mutator_daemonhost, 0.5)
set_explosion_center_mass(breed_chaos_ogryn_bulwark, 0.5)
set_explosion_center_mass(breed_chaos_ogryn_executor, 0.5)
set_explosion_center_mass(breed_chaos_ogryn_gunner, 0.5)
set_explosion_center_mass(breed_chaos_ogryn_houndmaster, 0.5)
set_explosion_center_mass(breed_chaos_plague_ogryn, 0.5)
set_explosion_center_mass(breed_chaos_spawn, 0.5)
set_explosion_center_mass(breed_cultist_berzerker, 0.75)
set_explosion_center_mass(breed_cultist_captain, 0.5)
set_explosion_center_mass(breed_cultist_gunner, 0.75)
set_explosion_center_mass(breed_cultist_shocktrooper, 0.75)
set_explosion_center_mass(breed_renegade_berzerker, 0.75)
set_explosion_center_mass(breed_renegade_captain, 0.5)
set_explosion_center_mass(breed_renegade_executor, 0.75)
set_explosion_center_mass(breed_renegade_gunner, 0.75)
set_explosion_center_mass(breed_renegade_plasma_gunner, 0.75)
set_explosion_center_mass(breed_renegade_radio_operator, 0.75)
set_explosion_center_mass(breed_renegade_shocktrooper, 0.75)
set_explosion_center_mass(breed_renegade_twin_captain, 0.5)
set_explosion_center_mass(breed_renegade_twin_captain_two, 0.5)

-- NEUTER EXPLOSION POWER MULTIPLIER
breed_chaos_ogryn_gunner.explosion_power_multiplier = 1 -- 2
breed_chaos_plague_ogryn.explosion_power_multiplier = 1 -- 1.5
breed_chaos_spawn.explosion_power_multiplier = 1 -- 2

-- LOWER HEALTH DAMAGE CAP PER HIT
breed_renegade_twin_captain.clamp_health_percent_damage = 0.1 -- 0.2
breed_renegade_twin_captain_two.clamp_health_percent_damage = 0.1 -- 0.2