local mod = get_mod("Onslaught")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")

local PAD = 8
local HEADER_H = 22
local ROW_H = 20
local MAX_ROWS = 12
local WIDTH = 440

local BREED_COLORS = {
	renegade_sniper = { 255, 160, 210, 255 },
	cultist_grenadier = { 255, 180, 90, 255 },
	renegade_grenadier = { 230, 140, 70, 255 },
	renegade_netgunner = { 100, 210, 255, 255 },
	flamer = { 255, 120, 60, 255 },
	renegade_flamer = { 255, 120, 60, 255 },
	cultist_flamer = { 255, 155, 75, 255 },
	chaos_poxwalker_bomber = { 210, 140, 255, 255 },
	chaos_hound = { 180, 210, 255, 255 },
	chaos_armored_hound = { 130, 170, 225, 255 },
	cultist_mutant = { 195, 225, 120, 255 },
	default = { 255, 255, 255, 255 },
}

local STATE_COLORS = {
	LIVE = { 0, 255, 130, 255 },
	WAIT = { 255, 80, 80, 255 },
	SPAWNING = { 255, 210, 70, 255 },
	EMPTY = { 170, 170, 170, 255 },
}

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	container = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "top",
		horizontal_alignment = "left",
		size = { WIDTH, HEADER_H + PAD * 2 },
		position = { 20, 20, 200 },
	},
}

local function build_text_pass(value_id, style_id, color, offset, width)
	return {
		value_id = value_id,
		style_id = style_id,
		pass_type = "text",
		style = {
			font_size = 15,
			font_type = "machine_medium",
			text_color = color,
			size = { width, ROW_H },
			offset = offset,
			text_vertical_alignment = "top",
			text_horizontal_alignment = "left",
			drop_shadow = true,
		},
	}
end

local passes = {
	{
		style_id = "background",
		pass_type = "rect",
		style = {
			color = { 180, 18, 18, 20 },
			size = { WIDTH, HEADER_H + PAD * 2 },
			offset = { 0, 0, 1 },
		},
	},
	{
		value_id = "header",
		style_id = "header",
		pass_type = "text",
		style = {
			font_size = 18,
			font_type = "machine_medium",
			text_color = { 255, 240, 240, 240 },
			size = { WIDTH - PAD * 2, HEADER_H },
			offset = { PAD, PAD, 2 },
			text_vertical_alignment = "top",
			text_horizontal_alignment = "left",
		},
	},
}

for i = 1, MAX_ROWS do
	local timer_id = "row_timer_" .. i
	local breed_id = "row_breed_" .. i
	local state_id = "row_state_" .. i
	local y = PAD + HEADER_H + (i - 1) * ROW_H
	passes[#passes + 1] = build_text_pass(timer_id, timer_id, { 255, 255, 255, 255 }, { 10, y, 2 }, 70)
	passes[#passes + 1] = build_text_pass(breed_id, breed_id, { 255, 255, 255, 255 }, { 90, y, 2 }, 200)
	passes[#passes + 1] = build_text_pass(state_id, state_id, { 255, 255, 255, 255 }, { 300, y, 2 }, 110)
end

local widget_definition = UIWidget.create_definition(passes, "container")

local specials_debug = class("specials_debug", "HudElementBase")

specials_debug.init = function(self, parent, draw_layer, start_scale)
	specials_debug.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = {
			slots = widget_definition,
		},
	})
end

specials_debug._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
	local scenegraph = self._ui_scenegraph
	local container = scenegraph and scenegraph.container

	if container then
		local position = container.position
		position[1] = tonumber(mod:get("debug_hud_x")) or 20
		position[2] = tonumber(mod:get("debug_hud_y")) or 20
	end

	specials_debug.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
end

local function slot_status(slot)
	if slot.spawned then
		return "--", "LIVE"
	elseif slot.spawner_queue_id then
		return "--", "SPAWNING"
	elseif slot.breed_name then
		return string.format("%.1fs", math.max(0, tonumber(slot.spawn_timer) or 0)), "WAIT"
	end

	return "--", "EMPTY"
end

local function breed_color_name(breed_name)
	if BREED_COLORS[breed_name] then
		return BREED_COLORS[breed_name]
	end

	return BREED_COLORS.default
end

specials_debug.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	specials_debug.super.update(self, dt, t, ui_renderer, render_settings, input_service)

	local widget = self._widgets_by_name.slots
	local game_mode_name = Managers.state.game_mode:game_mode_name()

	if not mod.debug_mode or game_mode_name == "training_grounds" or game_mode_name == "shooting_range" then
		widget.content.header = ""
		widget.style.background.color[1] = 0
		widget.style.background.size[2] = HEADER_H + PAD * 2
		for i = 1, MAX_ROWS do
			widget.content["row_timer_" .. i] = ""
			widget.content["row_breed_" .. i] = ""
			widget.content["row_state_" .. i] = ""
		end
		widget.dirty = true
		self:_set_scenegraph_size("container", WIDTH, HEADER_H + PAD * 2)
		return
	end

	widget.style.background.color[1] = 180
	local pacing = Managers.state and Managers.state.pacing
	local specials_pacing = pacing and pacing._specials_pacing
	local slots = specials_pacing and specials_pacing._specials_slots
	local row_index = 0
	widget.content.header = "SPECIAL SLOTS"

	for i = 1, MAX_ROWS do
		widget.content["row_timer_" .. i] = ""
		widget.content["row_breed_" .. i] = ""
		widget.content["row_state_" .. i] = ""
	end

	if type(slots) == "table" then
		for i = 1, #slots do
			local slot = slots[i]
			if slot then
				row_index = row_index + 1
				local timer, status = slot_status(slot)
				local breed = slot.breed_name or "-"
				local timer_color = STATE_COLORS[status] or STATE_COLORS.EMPTY
				local breed_color = breed_color_name(breed)
				local state_color = timer_color
				local timer_id = "row_timer_" .. row_index
				local breed_id = "row_breed_" .. row_index
				local state_id = "row_state_" .. row_index

				widget.content[timer_id] = string.format("%02d %s", i, timer)
				widget.content[breed_id] = breed
				widget.content[state_id] = status

				widget.style[timer_id].text_color = timer_color
				widget.style[breed_id].text_color = breed_color
				widget.style[state_id].text_color = state_color
			end
		end
	end

	local max_visible_rows = math.max(1, row_index)
	local panel_height = PAD * 2 + HEADER_H + max_visible_rows * ROW_H
	widget.style.background.size[2] = panel_height
	widget.dirty = true
	self:_set_scenegraph_size("container", WIDTH, panel_height)
end

return specials_debug
