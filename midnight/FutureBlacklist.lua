--[[
**  github.com/IMXNOOBX            **
**  Version: 1.1.7       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

local json = require("lib/json") -- download: https://github.com/IMXNOOBX/ScriptKid/blob/main/lib/json.lua

local config = {
	reaction = '', -- Dont put anything if you dont want to react to them
	exclude_frieds = true,
	notifications = true,
	timeout = 1500 -- Timeoutn before checking the next player. low values such as less that 200 mmight crash your game
}

local script = {
	host = "https://api.futuredb.shop",
	blacklisted_player = {},
	scan_players = {},
	next_timeout = 0,
}
local utl = {}

utl = {
	block_join = {},
	api_get_player = function(rid, callback)
		http.get(script.host.."/api/v1/user/"..rid, function(code, headers, content)
			if(code ~= 200) then return callback(-1) end
			local parsed = json.decode(content)
			if parsed['success'] == false then
				return callback(-1)
			end
			if parsed['data']['is_modder'] == true then 
				print(parsed['data']['player_note'])
				return callback(1, parsed['data']['player_note']:gsub("+", " "))
			end
			if parsed['data']['advertiser'] == true then 
				print(parsed['data']['player_note'])
				return callback(2, parsed['data']['player_note']:gsub("+", " "))
			end
			return callback(-1)
		end)
	end,
	flag_id = player.flags.create(function(ply) return script.blacklisted_player[ply] and script.blacklisted_player[ply] or false end, 'FB', 'Blacklisted Modder/Advertiser', 255, 0, 0) -- i think it works like this, not documented
}

function OnFeatureTick() 
	for i, player in ipairs(script.scan_players) do
		if system.ticks() <= script.next_timeout then return end
		utl.api_get_player(player.rid, function(res, msg) 
			if res and res ~= -1 then
				script.blacklisted_player[player.ply] = true
				if config.notifications then utils.notify('FutureBlackList', 'Blacklisted player detected: '..player.name..'\nDetected: '..(res == 1 and 'Modder' or 'Advertiser')..'\nReason: '..msg, gui_icon.players, notify_type.important) end
				if player.is_connected(player.ply) then 
					player.kick_idm(player.ply)
					if config.notifications then utils.notify('FutureBlackList', 'Name: '..player.get_name(ply)..'\nR* ID: '..player.get_rid(ply)..'\nReason: Blacklisted Player\nReaction: Block Join', gui_icon.players, notify_type.important) end
				else
					utl.block_join[player.ply] = true
				end
			end
		end)
		table.remove(script.scan_players, i)
		script.next_timeout = system.ticks() + config.timeout
	end
end

function OnPlayerJoin(ply, name, rid, ip, host_key)
	if config.exclude_frieds == true and player.is_friend(ply) then return end

	if config.scanner_mode == false then return end
	table.insert(script.scan_players, {
		ply = ply,
		name = name,
		rid = rid,
		ip = ip,
		host_key = host_key
	});
end

function OnPlayerActive(ply) 
	if not utl.block_join[ply] or utl.block_join[ply] == false then return end

	if config.reaction == 'block_join' then
		player.kick_idm(ply)
		if config.notifications then utils.notify('FutureBlackList', 'Name: '..player.get_name(ply)..'\nR* ID: '..player.get_rid(ply)..'\nReason: Blacklisted Player\nReaction: Block Join', gui_icon.players, notify_type.important) end
	end
end

function OnPlayerLeft(ply)
	script.blacklisted_player[ply] = false
	utl.block_join[ply] = false
end

function OnInit() -- Load
	if config.notifications then utils.notify('FutureBlackList', 'Script succesfully loaded!', gui_icon.players, notify_type.default) end
end

function OnDone() -- Unload
	if utl.flag_id then player.flags.delete(utl.flag_id) end
	if config.notifications then utils.notify('FutureBlackList', 'Script disabled, be careful!', gui_icon.players, notify_type.default) end
end