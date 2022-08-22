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
	-- draw.set_rounding(rounding)
	draw.set_color(0, r, g, b, a)
	draw.rect_filled(mw + mx + config.x_add - 5, my + config.y_add - 5, mw + mx + config.x_add + 150, my + config.y_add + 80)

	-- Text
	draw.set_color(0, 255, 255, 255, 255)
	draw.text(mw + mx + config.x_add, my + 15 + config.y_add, tostring('Peds: '.. #pools.peds..' / 256')) -- Peds
	draw.text(mw + mx + config.x_add, my + config.y_add, tostring('Vehicles: '.. #pools.vehicles..' / 300')) -- Vehicles
	draw.text(mw + mx + config.x_add, my + 30 + config.y_add, tostring('Objects: '.. #pools.objects..' / 2300')) -- Objects
	draw.text(mw + mx + config.x_add, my + 45 + config.y_add, tostring('Entities: '.. #pools.entities..' / 256')) -- Entities
	draw.text(mw + mx + config.x_add, my + 60 + config.y_add, tostring('Pickups: '.. #pools.pickups..' / 73')) -- Pickups
end



-- function OnScriptEvent(ply, event, args)
--     msg = 'ply: '..tostring(ply)..' | Event: '..tostring(event)
--     for i = 1, #args do
--         msg = msg .. ' | Args['..tostring(i)..']: '..tostring(args[i])
--     end
--     print(msg)
-- end


-- [08.08.2022 19:39:04] ply: 0 | Event: -555356783 | Args[1]: 1 | Args[2]: 32 | Args[3]: -818787917 | Args[4]: 0 | Args[5]: 0 | Args[6]: 0 | Args[7]: 0 | Args[8]: 0 | Args[9]: 0 | Args[10]: 0 | Args[11]: 0 | Args[12]: 0 | Args[13]: 0 | Args[14]: 0 | Args[15]: 0 | Args[16]: 0 | Args[17]: 0 | Args[18]: 0 | Args[19]: 0 | Args[20]: 0 | Args[21]: 0 | Args[22]: 0 | Args[23]: 0 | Args[24]: 0 | Args[25]: 0 | Args[26]: 0 | Args[27]: 0 | Args[28]: 0 | Args[29]: 0 | Args[30]: 0 | Args[31]: 0 | Args[32]: 0 | Args[33]: 0 | Args[34]: 0 | Args[35]: 1