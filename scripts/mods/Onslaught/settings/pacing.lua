local mod = get_mod("Onslaught")

local PacingManager = require("scripts/managers/pacing/pacing_manager")
local TerrorEventManager = require("scripts/managers/terror_event/terror_event_manager")
local TerrorEventNodes = require("scripts/managers/terror_event/terror_event_nodes")

-- Increase challenge rating thresholds to silly numbers
mod:hook_require("scripts/managers/pacing/pacing_templates", function(instance)
    local new_thresholds = {
        specials       = { math.huge },
        hordes         = { math.huge },
        trickle_hordes = { math.huge },
        roamers        = { math.huge },
        terror_events  = { math.huge },
    }

    for template_name, template in pairs(instance) do
        if type(template) == "table" and template.challenge_rating_thresholds then
            template.challenge_rating_thresholds = new_thresholds
            if mod.debug_mode then
                mod:echo(string.format("Modified challenge_rating_thresholds for: %s", template_name))
            end
        end
    end
end)

-- Replace spawn_type_enabled() to ignore tension state per spawn type, increase hard enemy limit during regular pacing
local HARD_ALLOCATED_LIMIT = 200 -- 145
local IGNORE_TENSION_STATE = {
    hordes = true,
    trickle_hordes = true,
	roamers = true,
}

mod:hook(PacingManager, "spawn_type_enabled", function(func, self, spawn_type)
    if self._disabled and spawn_type ~= "terror_events" then
        return false, "pacing_is_disabled"
    end

    local total_allocated_num_enemies = Managers.state.minion_spawn:total_allocated_num_enemies()

    if total_allocated_num_enemies > HARD_ALLOCATED_LIMIT then
        return false, "Hard_allocated_limit_reached"
    end

    local challenge_rating_threshold = self._challenge_rating_thresholds[spawn_type]

    if challenge_rating_threshold and challenge_rating_threshold < self._total_challenge_rating then
        return false, "disabled_by_challenge_rating"
    end

    if self._paused_spawn_types[spawn_type] then
        return false, "paused"
    end

    local heat_active = self._heat_pacing:active()

    if not IGNORE_TENSION_STATE[spawn_type] then
        if not self._allowed_spawn_types or not self._allowed_spawn_types[spawn_type] and not heat_active then
            return false, "not_allowed"
        end
    end

    if heat_active then
        local allowed_spawn_types = self._heat_pacing:current_stage_settings().allowed_spawn_types

        if not allowed_spawn_types[spawn_type] then
            return false, "disabled_by_heat_stage"
        end
    end

    return true
end)

-- Neutralize ramp up
local IGNORE_RAMP_UP = {
    hordes = true,
    terror_events = true,
}

mod:hook(PacingManager, "get_ramp_up_frequency_modifier", function(func, self, spawn_type)
    if IGNORE_RAMP_UP[spawn_type] then
        return 1
    end

    return func(self, spawn_type)
end)

-- Increase wait limit for spawn_by_points() during terror events 
local AGGRO_WAIT_LIMIT = 150
local in_spawn_by_points = false

mod:hook(PacingManager, "num_aggroed_minions", function(func, self)
	local num_aggroed = func(self)

	if in_spawn_by_points then
		return num_aggroed < AGGRO_WAIT_LIMIT and 0 or math.huge
	end

	return num_aggroed
end)

mod:hook(TerrorEventNodes.spawn_by_points, "update", function(func, node, scratchpad, t, dt)
	in_spawn_by_points = true

	local result = func(node, scratchpad, t, dt)

	in_spawn_by_points = false

	return result
end)

-- Make terror event trickles ignore challenge_rating and tension state
mod:hook_safe(TerrorEventManager, "start_terror_trickle", function(self)
	local template = self._terror_trickle_data.template

	if template then
		template.tension_stop_threshold = math.huge
		template.challenge_rating_stop_threshold = math.huge
	end
end)