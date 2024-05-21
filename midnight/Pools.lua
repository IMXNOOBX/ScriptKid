--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.9       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

local config = {
	enabled = true,
	only_menu_open = true,
	x_add = 20,
	y_add = 10,
}

local useful = {
	load_ticks = utils.get_current_time_millis(),
}
local r, g, b, a = 30, 33, 35, 200

events.on_frame(function()
	if utils.get_current_time_millis() <= useful.load_ticks + 10000 then return end
	if not config.enabled then return end
	if config.only_menu_open and not ui.is_opened() then
		return
	end

	local y = draw.get_screen_height() or draw.get_window_height()
	local x = draw.get_screen_width() or draw.get_window_width()
	local mx, my = ui.get_position()
	local mw, mh = ui.get_size()

	local rounding = 5
	local pools = {
		vehicles = pools.get_all_vehicles(),
		peds = pools.get_all_peds(),
		objects = pools.get_all_objects(),
		entities = pools.get_all_ents(),
		pickups = pools.get_all_pickups()
	}	

	-- -- Background
	draw.set_rounding(rounding)
	draw.set_color(0, r, g, b, a)
	draw.rect_filled(mw + mx + config.x_add - 5, my + config.y_add - 5, mw + mx + config.x_add + 150, my + config.y_add + 95)

	-- Text
	draw.set_color(0, 255, 255, 255, 255)
	draw.text(mw + mx + config.x_add, my + config.y_add - 4, tostring('Pools'))
	
	draw.line(mw + mx + config.x_add, my + config.y_add + 14, mw + mx + config.x_add + 145, my + config.y_add + 14)

	draw.text(mw + mx + config.x_add, my + 15 +config.y_add, tostring('Vehicles: '.. #pools.vehicles..' / 300')) -- Vehicles
	draw.text(mw + mx + config.x_add, my + 30 + config.y_add, tostring('Peds: '.. #pools.peds..' / 256')) -- Peds
	draw.text(mw + mx + config.x_add, my + 45 + config.y_add, tostring('Objects: '.. #pools.objects..' / 2300')) -- Objects
	draw.text(mw + mx + config.x_add, my + 60 + config.y_add, tostring('Entities: '.. #pools.entities..' / 700')) -- Entities
	draw.text(mw + mx + config.x_add, my + 75 + config.y_add, tostring('Pickups: '.. #pools.pickups..' / 73')) -- Pickups
end)