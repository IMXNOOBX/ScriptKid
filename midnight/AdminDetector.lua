--[[
**  github.com/IMXNOOBX            **
**  Version: 1.2.1       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

local config = {
	admins = { -- This is script's admin detection
		reaction = 'session', -- 'session' or 'bail' or 'crash'
	},
	midnigh_detection = { -- This is midnight's admin detection 
		developer_flag = true, -- Check for this flag
		reaction = 'session', -- 'session' or 'bail' or 'crash'
	},
	modders = { -- Spoofed admin rid/name missmatch detection
		reaction = 'kick', -- 'crash' or 'kick'
	}
}

local rstar_admins = {}
local reactions = {}

function split_str(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

function getRStarAdmins()
	http.get('https://raw.githubusercontent.com/IMXNOOBX/ScriptKid/main/midnight/AdminList/README.md', function(code, headers, content)
		if code ~= 200 then return utils.notify('R* Admin | Error', 'Invalid Response', gui_icon.warning, notify_type.error) end
		
		lines = split_str(content, "\n")
		for k,l in pairs(lines) do
			if k > 3 then
				parts = split_str(l, "|")
				name = string.gsub(parts[1], ' ', '')
				rid = string.gsub(parts[2], ' ', '')

				table.insert(rstar_admins, {name, rid})
			end
		end
		utils.notify('R* Admin | Success', 'All known admins added.', gui_icon.warning, notify_type.success)
	end)
end

function reaction_to_admin(reaction, ply, name)
	if reaction == 'session' then
		lobby.change_session(session_type.public_join)
		utils.notify('R* Admin | Admin > Reaction', 'Leaving session to another session!', gui_icon.warning, notify_type.success)
	elseif reaction == 'bail' then
		-- lobby.change_session(-1) -- Pls midnight add this its much cleaner
		NETWORK._SHUTDOWN_AND_LOAD_MOST_RECENT_SAVE() --KARLEND#5838 ty for the native
		utils.notify('R* Admin | Admin > Reaction', 'Leaving session to single player mode!', gui_icon.warning, notify_type.success)
	elseif reaction == 'crash' then
		player.crash_izuku_start(ply)
		utils.notify('R* Admin | Admin > Reaction', 'Sending Crash To ' .. name..'!', gui_icon.warning, notify_type.success)
	else
		utils.notify('R* Admin | Error', 'Invalid reaction in configuration. Use: session, bail, crash', gui_icon.warning, notify_type.success)
		-- lobby.change_session(-1)
		NETWORK._SHUTDOWN_AND_LOAD_MOST_RECENT_SAVE()
	end
end

function reaction_to_modder(reaction, ply, name)
	if reaction == 'kick' then
		player.kick_idm(ply)
		utils.notify('R* Admin | Modder > Reaction', 'Sending kick To ' .. name..'!', gui_icon.warning, notify_type.success)
	elseif reaction == 'crash' then
		player.crash_izuku_start(ply)
		utils.notify('R* Admin | Modder > Reaction', 'Sending Crash To ' .. name..'!', gui_icon.warning, notify_type.success)
	else
		player.kick_idm(ply)
		utils.notify('R* Admin | Error', 'Invalid reaction in configuration. Use: kick, crash', gui_icon.warning, notify_type.success)
	end
end

function OnPlayerJoin(ply, name, rid, ip, host_key)
	for i = 1, #rstar_admins do
		if tonumber(rid) == tonumber(rstar_admins[i][2]) and tostring(name) == tostring(rstar_admins[i][1]) then
			utils.notify('R* Admin | Script > Detected', name  .. ' is a Rockstar Developer!\nDetected by: RID Blacklist', gui_icon.warning, notify_type.important)
			reaction_to_admin(config.admins.reaction, ply, name)
		elseif (tostring(name) == tostring(rstar_admins[i][1]) and tonumber(rid) ~= tonumber(rstar_admins[i][2])) or (tostring(name) ~= tostring(rstar_admins[i][1]) and tonumber(rid) == tonumber(rstar_admins[i][2])) then
			utils.notify('R* Admin | Modder > Detected', name  .. ' is faking to be a Rockstar Developer!\nDetected by: RID Blacklist Missmatch', gui_icon.warning, notify_type.important)
			reactions[ply] = true
		end
	end
	
	if config.midnigh_detection.developer_flag and player.is_rockstar_dev(ply) then
		utils.notify('R* Admin | Midnight > Detected', name  .. ' is a Rockstar Developer!\nDetected by: Mindnight Analysis', gui_icon.warning, notify_type.important)
		reaction_to_admin(config.midnigh_detection.reaction, ply, name)
	end
end

function OnPlayerActive(ply)
	if not reactions[ply] then return end
	reaction_to_modder(config.modders.reaction, ply, player.get_name(ply))
end

function OnPlayerLeft(ply)
	reactions[ply] = nil
end

function OnInit()
	utils.notify('R* Admin | Success', 'Reaction to R* admin: ' .. config.admins.reaction..(config.midnigh_detection.developer_flag and '\nReaction to Midnight Detection: '..config.midnigh_detection.reaction or '\nDeveloper Flags Reactions Disabled!') ..'\nReaction to Modder: ' .. config.modders.reaction, gui_icon.warning, notify_type.success)
	getRStarAdmins()
end