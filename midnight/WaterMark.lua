--[[
**  github.com/IMXNOOBX            **
**  Version: 1.1.2       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

local config = {
	enabled = true,
	only_menu_open = false,
	update_rate = 10 -- Every 10 seconds will try to get all the palyers in the session
}

local useful = {
	midnight_icon,
	-- text_font = draw.create_font("impact", 18),
	total_players = 0,
	timeount = 0,
	load_ticks = system.ticks(),
	old_x,
	old_y
}


local r, g, b, a = 30, 33, 35, 200
local y = draw.get_screen_height() or draw.get_window_height()
local x = draw.get_screen_width() or draw.get_window_width()

function OnFrame()
	if system.ticks() <= useful.load_ticks + 10000 then return end
	if not config.enabled then return end
	if config.only_menu_open and not menu.is_menu_opened() then
		return
	end
	if not useful.midnight_icon then useful.midnight_icon = draw.create_texture_from_file(fs.get_dir_script() .. "/watermark/midnight.png") end

	local rounding = menu.get_window_rounding()
	local wm_text = '| Midnight | ' .. (social.get_username() or 'Unknown') .. (useful.total_players > 0 and lobby.is_session_active() and ' | players: ' .. useful.total_players or '')..' | ' .. os.date('%H:%M:%S')
	
	local tz_x, tz_y = draw.get_text_size_x(wm_text), draw.get_text_size_y(wm_text) -- it sets at 0 when i open another script that reders something
	if tz_x == 0 or tz_y == 0 then
		tz_x = useful.old_x
		tz_y = useful.old_y
	else
		useful.old_x = tz_x
		useful.old_y = tz_y
	end

	-- Background
	draw.set_rounding(rounding)
	draw.set_color(0, r, g, b, a)
	draw.rect_filled(x - tz_x - 45, 10, x - 5, tz_y + 20)

	-- Text
	draw.set_color(0, 255, 255, 255, 255)
	draw.text(x - tz_x - 10, 15, wm_text)
	draw.texture(useful.midnight_icon, x - tz_x - 40, 12, tz_y + 7, tz_y + 5) -- 45 x 45 original
end


function getAllPlayers()
	local players = {}
	for i = 0, 32 do
		if player.is_valid(i) then
			table.insert(players, i)
		end
	end
	return players
end

local update_rate = 0
function OnFeatureTick()
	if not lobby.is_session_active() then return end
	if system.ticks() <= update_rate then return end

	useful.total_players = #getAllPlayers()
	update_rate = system.ticks() + config.update_rate * 1000 -- seconds to ms
end
