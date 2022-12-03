--[[
**  github.com/IMXNOOBX            **
**  Version: 1.1.5       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

local json = require("lib/json") -- download: https://github.com/IMXNOOBX/ScriptKid/blob/main/lib/json.lua

local config = {
	reaction = 'block_join', -- block_join, to block their join or dont put anything if you dont want to react to them
	exclude_frieds = true,
	notifications = true,
}

local script = {
	host = "https://api.futuredb.shop",
	blacklisted_player = {}
}

local utl = {
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

function OnPlayerJoin(ply, name, rid, ip, host_key)
	if config.exclude_frieds == true and player.is_friend(ply) then return end

	if config.scanner_mode == false then return end
	utl.api_get_player(rid, function(res, msg) 
		if res and res ~= -1 then
			script.blacklisted_player[ply] = true
			if config.notifications then utils.notify('FutureBlackList', 'Blacklisted player detected: '..name..'\nDetected: '..res == 1 and 'Modder' or 'Advertiser'..'\nReason: '..msg, gui_icon.players, notify_type.important) end
			utl.block_join[ply] = true
		end
	end)
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
	player.flags.delete(utl.flag_id)
	if config.notifications then utils.notify('FutureBlackList', 'Script disabled, be careful!', gui_icon.players, notify_type.default) end
end