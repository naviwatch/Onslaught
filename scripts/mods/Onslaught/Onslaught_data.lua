local mod = get_mod("Onslaught")

return {
	name = "Onslaught",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "debug_mode",
				type = "checkbox",
				default_value = false,
			},
			{
				setting_id = "giga_ambients",
				type = "checkbox",
				default_value = false,
			},
			{
				setting_id = "giga_specials",
				type = "checkbox",
				default_value = false,
			},
			{
				setting_id = "debug_hud_x",
				type = "numeric",
				default_value = 20,
				range = { -2000, 2000 },
				decimals_number = 0,
				step_size_value = 1,
			},
			{
				setting_id = "debug_hud_y",
				type = "numeric",
				default_value = 20,
				range = { -2000, 2000 },
				decimals_number = 0,
				step_size_value = 1,
			},
			{
				setting_id = "tp",
				type = "keybind",
				default_value = {},
				keybind_global = true,
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "toevent"
			}
		}
	}
}
