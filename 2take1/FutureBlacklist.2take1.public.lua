--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.3       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

if not menu.is_trusted_mode_enabled(1 << 2) then
	menu.notify("You must turn on trusted mode->Natives to use this script.", "FutureBlacklist", 10, 0xff0000ff)
	return menu.exit()
end
if not menu.is_trusted_mode_enabled(1 << 3) then
	menu.notify("You must turn on trusted mode->Http to use this script.", "FutureBlacklist", 10, 0xff0000ff)
	return menu.exit()
end

local path_root = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\scripts\\", "FBL")

local status, json = pcall(require, "FBL/json")
if (not status) then
	utils.make_dir(path_root)
	utils.to_clipboard("https://github.com/IMXNOOBX/ScriptKid/blob/main/lib/json.lua")
	menu.notify("Error, please download json library from the repository and add it to FBL/json.lua\nThe link has been compied to your clipboard!", "FutureBlacklist", 10, 0xff0000ff)
	return menu.exit()
end

local script = {
	host = "https://api.futuredb.shop",

	flag = player.add_modder_flag('FutureBlacklist'),
	bail = menu.get_feature_by_hierarchy_key("online.lobby.bail")
}

local settings = {
	check_modders = true,
	check_advertisers = true,

	ignore_friends = true,

	modder_opt = 1,
	advertiser_opt = 1,
}

local functions = {
	api_get_player = function(rid, callback)
		local code, body, headers = web.get(script.host.."/api/v1/user/"..rid)
		if(tonumber(code) ~= 200) then return callback(-1) end
		local parsed = json.decode(body)

		if parsed['success'] == false then
			return callback(-2)
		end
		if parsed['data']['is_modder'] == true then 
			return callback(1, parsed['data']['player_note']:gsub("+", " "))
		end
		if parsed['data']['advertiser'] == true then 
			return callback(2, parsed['data']['player_note']:gsub("+", " "))
		end
		if parsed['success'] == true then
			return callback(0, parsed['data']['player_note']:gsub("+", " "))
		end
		return callback(-1)
	end,
	api_get_stats = function(callback)
		local code, body, headers = web.get(script.host.."/api/v1/stats")
		if(tonumber(code) ~= 200) then return callback(false) end
		local parsed = json.decode(body)
		if parsed["data"] ~= "" then 
			return callback({
				total_players =  parsed["data"].total_players or 0,
				legit_players = parsed["data"].legit_players or 0,
				modders = parsed["data"].modders or 0,
				advertisers = parsed["data"].advertisers or 0
			})
		end
	end,
	to_ipv4 = function(ip) -- Same
		return string.format("%i.%i.%i.%i", ip >> 24 & 255, ip >> 16 & 255, ip >> 8 & 255, ip & 255)
	end,
	notify = function(string, type)
		string = tostring(string)
		local color = 0x2C7CFE00
		if type == 'success' then
			color = 0x00FF00FF
		elseif type == 'error' then
			color = 0xFF0000FF
		end
		menu.notify(string, "FutureBlacklist", 10, color)
		print('[FutureBlacklist] | '..string)
	end,
	player_join_reaction = function(pid, type, callback)
		local reaction = type == 1 and settings.modder_opt or settings.advertiser_opt

		local name = player.get_player_name(pid)

		if reaction == 0 then
			player.set_player_as_modder(pid, script.flag)
		elseif reaction == 1 then
			player.set_player_as_modder(pid, script.flag)
			network.force_remove_player(pid) -- this doesnt work.
		end
		
		return callback('Apliying reaction to '..name..' for '..(type == 1 and "Modding" or "Advertising") .. ' Reaction: '.. (reaction == 1 and 'Kick' or 'Flag'))
	end	
}

local root = menu.add_feature("FutureBlacklist", "parent", 0)
menu.add_feature(">\tFutureBlacklist", "action", root.id)
local modder_check = menu.add_feature("Check For Modders", "toggle", root.id, function(val)
	settings.check_modders = val.on
end)
modder_check.on = settings.check_modders
local advertiser_check = menu.add_feature("Check For Advertisers", "toggle", root.id, function(val)
	settings.check_advertisers = val.on
end)
advertiser_check.on = settings.check_advertisers
menu.add_feature(">\tReactions", "action", root.id)
local modder_action = menu.add_feature("Reaction To Modders", "autoaction_value_str", root.id, function(val)
	settings.modder_opt = val.value
end)
-- modder_action.value = settings.modder_opt
settings.modder_opt = modder_action.value 
local advertiser_action = menu.add_feature("Reaction To Advertisers", "autoaction_value_str", root.id, function(val)
	settings.advertiser_opt = val.value
end)
-- advertiser_action.value = settings.advertiser_opt
settings.advertiser_opt = advertiser_action.value
modder_action.str_data = {"Flag", "Kick & Flag"}
advertiser_action.str_data = {"Flag", "Kick & Flag"}


event.add_event_listener("player_join", function(joined_player)
	local ply = joined_player.player

	if ply == player.player_id() then return end
	if settings.ignore_friends and player.is_player_friend(ply) then return end

	local rid = player.get_player_scid(ply)

	functions.api_get_player(rid, function(result, note) 
		if (result == 1 and settings.check_modders == true) or (result == 2 and settings.check_advertisers == true) then
			functions.player_join_reaction(ply, result, function(message) 
				functions.notify(message)
			end)
		end
	end)
end)

local thread_id
thread_id = menu.create_thread(function() 
	functions.api_get_stats(function(stats)
		if not stats then return end
		
		functions.notify("Blacklist Stats\nTotal Players: "..stats.total_players.."\nLegit Players: "..stats.legit_players.."\nModders: "..stats.modders.."\nAdvertisers: "..stats.advertisers)
	end)

	while (not menu.has_thread_finished(thread_id)) do system.yield(1) end
	menu.delete_thread(thread_id)
end)
