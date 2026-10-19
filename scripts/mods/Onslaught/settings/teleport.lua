local mod = get_mod("Onslaught")
local PlayerMovement = require("scripts/utilities/player_movement")
local Blackboard = require("scripts/extension_systems/blackboard/utilities/blackboard")

local function fmt(v)
    return string.format("%.2f, %.2f, %.2f", v.x, v.y, v.z)
end

mod:command("pos", "Print current coordinates and rotation", function()
    local player = Managers.player and Managers.player:local_player_safe(1)
    local unit = player and player.player_unit

    if unit and Unit.alive(unit) then
        local pos = Unit.world_position(unit, 1)
		local rot = math.deg(player:get_orientation().yaw)
		mod:echo(string.format("Coords: %s | Rota: %.1f", fmt(pos), rot))
    else
        mod:echo("No player unit (not in a mission, or dead/respawning)")
    end

    local ffm = Managers.free_flight

    if ffm and ffm:is_in_free_flight() then
        local cam_pos = ffm:camera_position_rotation("global")
        if cam_pos then
            mod:echo("Camera: " .. fmt(cam_pos))
        end
    end
end)

local tpLocations = {
	-- Archivum Sycorax
	["cm_archives"] = {
		{ 60.67, 36.41, -16.95, 180.0 },
		{ -348.40, -149.26, -45.92, 135.0 }
	},
	-- Ascension Riser
	-- ["dm_rise"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
	-- Chasm Logistratum
	-- ["lm_rails"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
	-- Chasm Station
	-- ["km_station"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
	-- Clandestium Gloriana
	-- ["core_research"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
	-- Comms Plex
	-- ["hm_complex"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
    -- Consignment Yard
    ["fm_cargo"] = {
        { -198.21, -43.18, -5.41, 198.7 },
        { -82.75, -178.70, -13.70, 135.3 }
    },
	-- Dark Communion
	["km_heresy"] = {
		{ -99.37, -46.01, -20.00, 315.6 },
		{ 151.98, 120.63, 19.06, 314.8 }
	},
    -- Enclavum Baross
    ["fm_resurgence"] = {
        { -39.53, 193.19, -2.98, 312.2 },
        { 338.50, -206.24, 7.03, 179.9 }
    },
	-- Excise Vault Spireside
	-- ["lm_scavenge"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
	-- Hab Dreyko
	-- ["cm_habs"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
	-- Magistrati Oubliette
	-- ["km_enforcer"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
    -- Mercantile
    ["fm_armoury"] = {
        { -215.69, -308.51, 1.67, 140.1 },
        { 152.17, -189.63, -34.98, 180.1 }
    },
    -- Power Matrix
    ["lm_cooling"] = {
        { -66.06, -110.53, -14.75, 345.3 },
        { -60.94, -70.40, -123.92, 323.0 }
    },
	-- Refinery Delta
	-- ["hm_strain"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
	-- Relay Station
	["dm_propaganda"] = {
		{ 46.68, -44.15, -1.00, 90.9 },
		{ -249.75, 112.96, -3.02, 72.7 }
	},
	-- Silo Cluster
	-- ["dm_stockpile"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
	-- Smelter Complex
	-- ["dm_forge"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
	-- Spillway
	-- ["spillway"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
	-- Vigil Station Oblivium
	-- ["hm_cartel"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
	-- Warren
	-- ["cm_raid"] = {
		-- { XX, XX, XX, XX },
		-- { XX, XX, XX, XX }
	-- },
}

local NDX = 0

mod.on_game_state_changed = function(status, state)
    NDX = 0
end

-- Teleport companions with owner
local function teleport_companions(player, destination_position)
    local player_unit = player.player_unit
    local companion_spawner_extension = ScriptUnit.has_extension(player_unit, "companion_spawner_system")
    local companion_units = companion_spawner_extension and companion_spawner_extension:companion_units()

    if companion_units then
        for i = 1, #companion_units do
            local companion_unit = companion_units[i]

            if companion_unit and ALIVE[companion_unit] then
                local companion_blackboard = BLACKBOARDS[companion_unit]
                local has_teleport_component = companion_blackboard and Blackboard.has_component(companion_blackboard, "teleport")

                if has_teleport_component then
                    local teleport_component = Blackboard.write_component(companion_blackboard, "teleport")

                    teleport_component.teleport_position:store(destination_position)
                    teleport_component.has_teleport_position = true
                end
            end
        end
    end
end

-- Teleport players to next event
mod:command("toevent", "", function()
    mod:toevent()
end)

mod.toevent = function()
    local mission_name = Managers.state.mission:mission_name()
    local locations = tpLocations[mission_name]

    if not locations then
        mod:echo("No teleport locations saved for this mission.")
        return
    end

    local is_server = Managers.state.game_session and Managers.state.game_session:is_server()
    if not is_server then
        mod:echo("Host only!")
        return
    end

    local idx = NDX + 1
    NDX = idx % #locations

    local entry = locations[idx]
    local position = Vector3(entry[1], entry[2], entry[3])
    local rotation = entry[4] and Quaternion(Vector3.up(), math.rad(entry[4])) or nil

    -- lots of warnings because this game is poorly made
    if mission_name == "lm_cooling" and idx == 1 then
        mod:echo("You HAVE to do the mid-event for the end-event elevator to spawn!")
    elseif mission_name == "fm_cargo" and idx == 2 then
        mod:echo("Do NOT move forward! DELETE ALL ENEMIES HERE before proceeding, or else you will despawn the passive enemies inside the end-event!")
    elseif mission_name == "fm_armoury" and idx == 2 then
        mod:echo("Do NOT move forward! DELETE ALL ENEMIES HERE before proceeding, or else you will despawn the passive enemies inside the end-event!")
	elseif mission_name == "km_heresy" and idx == 2 then
		mod:echo("Do NOT move forward! DELETE ALL ENEMIES HERE before proceeding, or else you will despawn the passive enemies inside the end-event!")
	elseif mission_name == "cm_archives" and idx == 1 then
		mod:echo("Horde pacing is active until you press the button. DELETE ONGOING HORDE WAVES HERE!")
	elseif mission_name == "cm_archives" and idx == 2 then
		mod:echo("Horde pacing is active until you start the event. DELETE ONGOING HORDE WAVES HERE!")
	end

    for _, player in pairs(Managers.player:human_players()) do
        local unit = player.player_unit
        if unit and ALIVE[unit] then
            pcall(PlayerMovement.teleport, player, position, rotation)
            pcall(teleport_companions, player, position)

            if rotation then
                local yaw = Quaternion.yaw(rotation)
                local channel_id = player:channel_id()

                if player.remote and channel_id then
                    RPC.rpc_client_set_local_player_orientation(channel_id, yaw, 0, 0)
                end
            end
        end
    end
end

-- Custom spawn locations in start area
local NavQueries = require("scripts/utilities/nav_queries")
local PlayerSpawnerSystem = require("scripts/extension_systems/player_spawner/player_spawner_system")

local spawnLocations = {
	-- Archivum Sycorax
	["cm_archives"] = { 266.56, 76.16, -7.00, 90 },
	-- Ascension Riser
	["dm_rise"] = { 182.93, 88.63, -8.98, 155.8 },
	-- Consignment Yard
	["fm_cargo"] = { 180.29, 43.77, 4.00, 90.2 },
	-- Chasm Logistratum
	["lm_rails"] = { 208.90, -159.20, -8.98, 359.6 },
	-- Chasm Station
	["km_station"] = { -52.57, -375.44, 9.61, 339.7 },
	-- Clandestium Gloriana
	["core_research"] = { -19.60, -325.73, 54.88, 50.7 },
	-- Comms Plex
	["hm_complex"] = { 151.23, 296.50, -10.05, 130.2 },
	-- Dark Communion
	["km_heresy"] = { 5.93, -310.70, 13.44, 45.3 },
	-- Enclavum Baross
	["fm_resurgence"] = { -297.36, 206.40, -2.25, 191.9 },
	-- Excise Vault Spireside
	["lm_scavenge"] = { 14.59, 173.99, 3.16, 89.5 },
	-- Hab Dreyko
	["cm_habs"] = { 204.34, -12.71, -0.93, 136.0 },
	-- Magistrati Oubliette
	["km_enforcer"] = { 211.36, -155.79, 7.82, 332.1 },
	-- Mercantile
	["fm_armoury"] = { -213.40, -332.99, 9.89, 324.7 },
	-- Power Matrix
	["lm_cooling"] = { 243.33, -319.94, -3.75, 26.7 },
	-- Refinery Delta
	["hm_strain"] = { -129.78, -63.70, -148.00, 89.9 },
	-- Relay Station
	["dm_propaganda"] = { 2.54, 137.27, 31.00, 240.2 },
	-- Silo Cluster
	["dm_stockpile"] = { 293.57, 317.40, 53.23, 125.4 },
	-- Smelter Complex
	["dm_forge"] = { -77.77, 310.51, 6.99, 210.1 },
	-- Spillway
	-- No custom spawn location since pacing starts super early in vanilla already
	-- Vigil Station Oblivium
	["hm_cartel"] = { -42.22, -263.78, -11.04, 14.9 },
	-- Warren
	["cm_raid"] = { 8.72, -105.58, 6.50, 24.5 },
}

mod:hook(PlayerSpawnerSystem, "next_free_spawn_point", function(func, self, optional_spawn_identifier)
    local position, rotation, parent, side = func(self, optional_spawn_identifier)

    local mission = Managers.state.mission
    local entry = mission and spawnLocations[mission:mission_name()]
    if not entry then
        return position, rotation, parent, side
    end

    local use_progression = not self._in_safe_volume or self:_use_progression_spawn_in_safe_zone()
    if use_progression then
        return position, rotation, parent, side
    end

    -- Snap onto the navmesh, fall back to the default spawn if that fails
    local wanted = Vector3(entry[1], entry[2], entry[3])
    local nav_world = Managers.state.nav_mesh and Managers.state.nav_mesh:nav_world()
    local snapped = nav_world and NavQueries.position_on_mesh_with_outside_position(nav_world, nil, wanted, 2, 2, 2)

    if not snapped then
        mod:echo("Custom spawn point is not on the navmesh, using default spawn.")
        return position, rotation, parent, side
    end

    if entry[4] then
        rotation = Quaternion(Vector3.up(), math.rad(entry[4]))
    end

    return snapped, rotation, nil, side
end)