return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Onslaught` encountered an error loading the Darktide Mod Framework.")

		new_mod("Onslaught", {
			mod_script       = "Onslaught/scripts/mods/Onslaught/Onslaught",
			mod_data         = "Onslaught/scripts/mods/Onslaught/Onslaught_data",
			mod_localization = "Onslaught/scripts/mods/Onslaught/Onslaught_localization",
		})
	end,
	packages = {},
}
