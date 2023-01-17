--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.8       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

util.require_natives(1651208000)

local x, y = 0.992, 0.008

local settings = {
	show_name = true,
	show_date = true,
	show_players = true,
    show_firstl = 2,

    add_x = 0.0055,
    add_y = 0.0,
    
    bg_color = {
        ["r"] = 0.8,
        ["g"] = 0.35,
        ["b"] = 0.8,
        ["a"] = 0.8
    },
    tx_color = {
        ["r"] = 1.0,
        ["g"] = 1.0,
        ["b"] = 1.0,
        ["a"] = 1.0
    }
}
local utils = {
    edition = menu.get_edition(),
    editions = {
        'Free',
        'Basic',
        'Regular',
        'Ultimate'
    }
}

local icon
if not filesystem.exists(filesystem.scripts_dir() .. '/watermark/icon.png') then
    util.toast('[FS|WaterMark] Watermark icon not found, downloading...')
    local path_root = filesystem.scripts_dir() .."watermark/"
    async_http.init('raw.githubusercontent.com', '/IMXNOOBX/ScriptKid/main/stand/watermark/stand_icon.png', function(req)
		if not req then
			util.toast("Failed to download watermak/stand_icon.png, please download it manually.\nThe link is copied in your clipboard.")
            util.copy_to_clipboard("https://github.com/IMXNOOBX/ScriptKid/blob/main/stand/watermark/stand_icon.png", true)
            return 
        end

        filesystem.mkdir(path_root)
		local f = io.open(path_root..'icon.png', "wb")
		f:write(req)
		f:close()
		util.toast("Successfully downloaded icon.png from the repository.")
        icon = directx.create_texture(filesystem.scripts_dir() .. '/watermark/icon.png')
	end)
	async_http.dispatch()
else
    icon = directx.create_texture(filesystem.scripts_dir() .. '/watermark/icon.png')
end

menu.divider(menu.my_root(), "Settings")
local pos_settings = menu.list(menu.my_root(), "Position", {}, "", function() end)
menu.slider(pos_settings, "X position", {"watermark-x"}, "Move the watermark in the x position", -100000, 100000, x * 10000, 1, function(x_)
    x = x_ / 10000
end)
menu.slider(pos_settings, "Y position", {"watermark-y"}, "Move the watermark in the y position", -100000, 100000, y * 10000, 1, function(y_)
    y = y_ / 10000
end)
menu.slider(pos_settings, "Add X", {"watermark-addx"}, "Add x ammount to the background", -100000, 100000, settings.add_x * 10000, 1, function(x_)
    settings.add_x = x_ / 10000
end)
menu.slider(pos_settings, "Add Y", {"watermark-addy"}, "Add y ammount to the background", -100000, 100000, settings.add_y * 10000, 1, function(y_)
    settings.add_y = y_ / 10000
end)

local color_settings = menu.list(menu.my_root(), "Colors", {}, "", function() end)
local rgb_background = menu.colour(color_settings, 'Background Color', {'watermark-bg_color'}, 'Select background color', settings.bg_color, true, function(col)
    settings.bg_color = col
end)
menu.rainbow(rgb_background)
local rgb_text = menu.colour(color_settings, 'Text Color', {'watermark-tx_color'}, 'Select text color', settings.tx_color, true, function(col)
    settings.tx_color = col
end)
menu.rainbow(rgb_text)

menu.divider(menu.my_root(), "Aditional Settings")
menu.list_select(menu.my_root(), 'First Label', {}, 'Change the first label in the watermak', {'Disable', 'Stand', 'Version'}, settings.show_firstl, function (val)
    settings.show_firstl = val
end)
menu.toggle(menu.my_root(), 'Name', {}, 'Show the name in the watermark', function(val)
	settings.show_name = val
end, settings.show_name)
menu.toggle(menu.my_root(), 'Player Count', {}, 'Show the name in the watermark', function(val)
	settings.show_players = val
end, settings.show_players)
menu.toggle(menu.my_root(), 'Date', {}, 'Show the name in the watermark', function(val)
	settings.show_date = val
end, settings.show_date)

menu.divider(menu.my_root(), "")
menu.toggle_loop(menu.my_root(), "Enable Watermark", {"watermark"}, "Enable/Disable Watermark", function()
    if menu.is_in_screenshot_mode() then return end
	local wm_text = (settings.show_firstl == 2 and 'Stand | ' or settings.show_firstl == 3 and utils.editions[utils.edition+1]..' | ' or '') .. (settings.show_name and players.get_name(players.user())..' | ' or '') .. (settings.show_players and NETWORK.NETWORK_IS_SESSION_STARTED() and 'players: '..#players.list(true, true, true)..' | ' or '') .. (settings.show_date and os.date('%H:%M:%S') or '')

    local tx_size = directx.get_text_size(wm_text, 0.5)

	directx.draw_rect(
        x + settings.add_x * 0.5, 
        y, 
        -(tx_size + 0.0105 + settings.add_x),  -- add watermark size
        0.025 + settings.add_y, 
        settings.bg_color
    )
    
	directx.draw_texture(icon, 
        0.0055, 
        0.0055, 
        0.5, 
        0.5, 
        x - tx_size - 0.0055, 
        y + 0.013, 
        0, 
        {["r"] = 1.0,["g"] = 1.0,["b"] = 1.0,["a"] = 1.0}
    )

    directx.draw_text(
        x, 
        y + 0.004, 
        wm_text, 
        ALIGN_TOP_RIGHT, 
        0.5, 
        settings.tx_color, 
        false
    )
end)

util.keep_running()
