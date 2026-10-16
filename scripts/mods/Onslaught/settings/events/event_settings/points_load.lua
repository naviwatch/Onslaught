local mod = get_mod("Onslaught")

local Breeds = require("scripts/settings/breed/breeds")
local BreedTerrorEventSettings = require("scripts/settings/breed/breed_terror_event_settings")

local config = mod:io_dofile("Onslaught/scripts/mods/Onslaught/settings/events/event_settings/points")

if type(config) ~= "table" or type(config.breeds) ~= "table" then
	mod:error("Failed to load custom breed terror event settings!")
	return
end

local multiplier = config.multiplier or 1
local aligned = config.aligned or {}

for _, breed_name in ipairs(config.breeds) do
	local breed = Breeds[breed_name]
	local source_name = aligned[breed_name] or breed_name
	local vanilla = BreedTerrorEventSettings[source_name]

	if breed and vanilla and vanilla.point_cost then
		local cost = vanilla.point_cost * multiplier

		breed.point_cost = cost
	else
		mod:warning("[points] unknown breed or no vanilla cost: %s (source %s)", tostring(breed_name), tostring(source_name))
	end
end