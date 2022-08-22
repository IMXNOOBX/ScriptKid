local config = {
	enabled = true,
	only_menu_open = true,
	x_add = 20,
	y_add = 10,
}

local useful = {
	load_ticks = system.ticks(),
}
local r, g, b, a = 30, 33, 35, 200

function OnFrame()
	if system.ticks() <= useful.load_ticks + 10000 then return end
	if not config.enabled then return end
	if config.only_menu_open and not menu.is_menu_opened() then
		return
	end

	local y = draw.get_screen_height() or draw.get_window_height()
	local x = draw.get_screen_width() or draw.get_window_width()
	local mx, my = menu.get_main_menu_pos_x(), menu.get_main_menu_pos_y()
	local mw, mh = menu.get_main_menu_size_x(), menu.get_main_menu_size_y()

	local rounding = menu.get_window_rounding()
	local pools = {
		vehicles = pools.get_all_vehicles(),
		peds = pools.get_all_peds(),
		objects = pools.get_all_objects(),
		entities = pools.get_all_ents(),
		pickups = pools.get_all_pickups()
	}	

	-- local tz_x, tz_y = draw.get_text_size_x(wm_text), draw.get_text_size_y(wm_text) -- it sets at 0 when i open another script that reders something

	-- -- Background
	draw.set_rounding(rounding)
	draw.set_color(0, r, g, b, a)
	draw.rect_filled(mw + mx + config.x_add - 5, my + config.y_add - 5, mw + mx + config.x_add + 150, my + config.y_add + 80)

	-- Text
	draw.set_color(0, 255, 255, 255, 255)
	draw.text(mw + mx + config.x_add, my + 15 + config.y_add, tostring('Peds: '.. #pools.peds..' / 256')) -- Peds
	draw.text(mw + mx + config.x_add, my + config.y_add, tostring('Vehicles: '.. #pools.vehicles..' / 300')) -- Vehicles
	draw.text(mw + mx + config.x_add, my + 30 + config.y_add, tostring('Objects: '.. #pools.objects..' / 2300')) -- Objects
	draw.text(mw + mx + config.x_add, my + 45 + config.y_add, tostring('Entities: '.. #pools.entities..' / ?')) -- Entities
	draw.text(mw + mx + config.x_add, my + 60 + config.y_add, tostring('Pickups: '.. #pools.pickups..' / 73')) -- Pickups
end