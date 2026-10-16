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
