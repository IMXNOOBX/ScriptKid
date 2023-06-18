if not menu.is_trusted_mode_enabled(1 << 2) then
	menu.notify("You must turn on trusted mode->Natives to use this script.", "InteligentKick", 10, 0xff0000ff)
	return menu.exit()
end
if not menu.is_trusted_mode_enabled(1 << 1) then
	menu.notify("You must turn on trusted mode->Globals/Locals to use this script.", "InteligentKick", 10, 0xff0000ff)
	return menu.exit()
end

local script_host = menu.get_feature_by_hierarchy_key("online.lobby.force_script_host")

function gen(arg)
    local args = {}
    for i = 1, arg do
        args[i] = math.random(-2147483648, 2147483647)
    end
    return args
end

menu.add_player_feature("Inteligent Kick", "action", 0, function(f, pid)
	if not player.is_player_valid(pid) then
		return HANDLER_POP
	end
	
	local name = player.get_player_name(pid)
	local reason = "Unknown"

	if player.get_host() == player.player_id() then 
		network.network_session_kick_player(pid)
		reason = 'Host'
		system.yield(1000)
	end

	if player.is_player_valid(pid) then
		script.trigger_script_event(210548496, pid, { -1091407522, 26, 1, 599432297 }) -- { -1091407522, 26, 1, 599432297 }
		reason = 'Script'
		system.yield(1000)
	end

	if player.is_player_valid(pid) then
		local pos = player.get_player_coords(pid)
		local plyped = player.get_player_ped(pid)
		local model = 1025210927
		for i= 0, 50 do ped.clear_ped_tasks_immediately(plyped) end
		system.yield(100)

		while not streaming.has_model_loaded(model) do
			streaming.request_model(model)
			system.yield(1)
		end

		native.call(0x673966A0C0FD7171, 0x2C014CA6, pos.x, pos.y, pos.z, 1, math.random(8989, 9090), model, true, true)
		reason = 'Pickup'
		system.yield(1000)
	end

	if player.is_player_valid(pid) then
		while script.get_host_of_this_script() ~= player.player_id() do
			script_host:toggle()
			system.yield(100)
		end
	
		script.set_global_i(1885447 + 1 + (pid * 1), 1)

		reason = 'Script Host Kick'
		system.yield(5 * 1000)
	end

	if player.is_player_valid(pid) then
		network.force_remove_player(pid)
		reason = 'Fallback'
		system.yield(1000)
	end

	menu.notify("Sent kick to ".. name .. " using "..reason, "Inteligent Kick", 10, 0x2C8FFE00)
end)

local flag = player.add_modder_flag('FutureBlacklist')

--[[
	menu.add_player_feature("Add player flag", "action", 0, function(f, pid)
		if not player.is_player_valid(pid) then
			return HANDLER_POP
		end
		-- local name = player.get_player_name(pid)
	
		-- for i = 1, 100, 1 do
		-- 	script.trigger_script_event(1757755807, pid, gen(2))
		-- end
		
		while script.get_host_of_this_script() ~= player.player_id() do
			script_host:toggle()
			system.yield(100)
		end
	
		local second = script.set_global_i(1885447 + 1 + (pid * 1), 1)
		print(second)
	
		menu.notify("Response: ".. tostring(second), "Inteligent Kick", 10, 0x2C8FFE00)
	end)
]]