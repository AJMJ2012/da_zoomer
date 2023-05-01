dofile("data/scripts/lib/mod_settings.lua")
dofile("mods/da_zoomer/lib/math-round.lua")

local mod_id = "da_zoomer"
mod_settings_version = 1
mod_settings = {
	{
		id = "resolution",
		ui_name = "Game Resolution",
		ui_description = "The higher the resolution, the more performance it eats and the buggier the sky gets",
		value_default = 240,
		value_max = 1080, -- Cannot go higher without breaking the fog of war
		value_min = 180,
		scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
	},
	{
		id = "chunks",
		ui_name = "Minimum Chunks",
		ui_description = "Bottoms out at resolution calculted",
		value_default = 4,
		value_max = 20,
		value_min = 4,
		scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
	},
	{
		id = "double_chunks",
		ui_name = "Double Chunks",
		ui_description = "Doubles the amount of chunks loaded",
		value_default = true,
		scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
	},
}

function ModSettingsUpdate( init_scope )
	mod_settings_update( mod_id, mod_settings, init_scope )
	local newRes_y = math.round(ModSettingGetNextValue("da_zoomer.resolution"))
	mod_settings[1].value_display_formatting = " "..newRes_y.."p"
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )

	local id = 968235714
	local function new_id() id = id + 1; return id end

	GuiOptionsAdd( gui, GUI_OPTION.None )

	GuiLayoutBeginHorizontal( gui, 0, 0 )
	GuiText( gui, 0, 0, "" )
	GuiLayoutEnd(gui)

	local newRes_y = math.round(ModSettingGetNextValue("da_zoomer.resolution"))
	local newRes_x = math.round(newRes_y / 0.5625) -- Game forces 16:9 aspect
	local chunks = math.max(math.round(ModSettingGetNextValue("da_zoomer.chunks")), math.ceil((newRes_x / 512) + 1) * math.ceil((newRes_y / 512) + 1))
	if (ModSettingGetNextValue("da_zoomer.double_chunks")) then chunks = chunks * 2 end

	GuiLayoutBeginHorizontal( gui, 0, 0 )
	GuiText( gui, 0, 0, "Resolution: " .. newRes_x.." x "..newRes_y )
	GuiLayoutEnd(gui)

	GuiLayoutBeginHorizontal( gui, 0, 0 )
	GuiText( gui, 0, 0, "Chunks: " .. chunks)
	GuiLayoutEnd(gui)

	GuiLayoutBeginHorizontal( gui, 0, 0 )
	GuiText( gui, 0, 0, "Resolution Presets:" )
	GuiLayoutEnd(gui)

	local heights = {720,900,1080}
	for i = 1, #heights do
		local height=(heights[i])
		GuiLayoutBeginHorizontal( gui, 0, 0 )
			GuiText( gui, 0, 0, "  " .. height .. "p Scale:" )
		GuiLayoutEnd(gui)
		local s = 1
		local e = 4
		if (height <= 720) then e = 3 end
		for scale = s, e do
			local h = height / ((e + s) - scale)
			GuiLayoutBeginHorizontal( gui, 0, 0 )
			if GuiButton( gui, new_id(), 4, 0, "    " .. math.round(h / 0.5625) .. " x " .. h ) then
				ModSettingSetNextValue("da_zoomer.resolution", h, false)
			end
			GuiLayoutEnd(gui)
		end
	end
end