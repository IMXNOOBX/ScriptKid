--[[
**  github.com/IMXNOOBX            **
**  Version: 1.2.0      	   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

local root = fs.get_dir_script()..'/'
local json = fs.file_exists(root .. 'lib/json.lua') and require("lib/json") or print('json lib not found') -- download: https://github.com/IMXNOOBX/ScriptKid/blob/main/lib/json.lua

local config = {
    reaction = '', -- Dont put anything if you dont want to react to them
    exclude_frieds = true,
    notifications = true,
    timeout = 1500, -- Timeout before checking the next player. low values such as less that 200 mmight crash your game
	
	x_add = 20,
	y_add = 10,
}

local script = {
    host = "https://api.futuredb.shop",
	load_ticks = system.ticks(),
    blacklisted_player = {},
    scan_players = {},
    next_timeout = 0,
	stats = {
		total_players = 0,
		legit_players = 0,
		modders = 0,
		advertisers = 0
	}
}

local utl = {
    block_join = {},
    api_get_player = function(rid, callback)
        http.get(script.host .. "/api/v1/user/" .. rid, function(code, headers, content)
            if (code ~= 200) then
                return callback(-1)
            end
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
	api_get_stats = function(callback)
        http.get(script.host .. "/api/v1/stats", function(code, headers, content)
            if (code ~= 200) then
                return callback(nil)
            end
            local parsed = json.decode(content)
            if parsed['success'] == false then
                return callback(nil)
            end
            if parsed['data'] then
                return callback({
					total_players = parsed['data']['total_players'] or '0',
					legit_players =  parsed['data']['legit_players'] or '0',
					modders =  parsed['data']['modders'] or '0',
					advertisers =  parsed['data']['advertisers'] or '0'
				})
            end

            return callback(nil)
        end)
    end,
    flag_id = player.flags.create(function(ply)
        return script.blacklisted_player[ply] and script.blacklisted_player[ply] or false
    end, 'FB', 'Blacklisted Modder/Advertiser', 255, 0, 0) -- i think it works like this, not documented
}

function OnFeatureTick()
    if system.ticks() <= 10000 then
        return
    end
    for i, player in ipairs(script.scan_players) do
        if system.ticks() <= script.next_timeout then
            return
        end
        utl.api_get_player(player.rid, function(res, msg)
            if res and res ~= -1 then
                script.blacklisted_player[player.ply] = true
                if config.notifications then
                    utils.notify('FutureBlackList',
                        'Blacklisted player detected: ' .. player.name .. '\nDetected: ' ..
                            (res == 1 and 'Modder' or 'Advertiser') .. '\nReason: ' .. msg, gui_icon.players,
                        notify_type.important)
                end
                if config.reaction == 'block_join' and player.is_connected(player.ply) then
                    player.kick_idm(player.ply)
                    if config.notifications then
                        utils.notify('FutureBlackList',
                            'Name: ' .. player.get_name(ply) .. '\nR* ID: ' .. player.get_rid(ply) ..
                                '\nReason: Blacklisted Player\nReaction: Block Join', gui_icon.players,
                            notify_type.important)
                    end
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
    if config.exclude_frieds == true and player.is_friend(ply) then
        return
    end

    if config.scanner_mode == false then
        return
    end
    table.insert(script.scan_players, {
        ply = ply,
        name = name,
        rid = rid,
        ip = ip,
        host_key = host_key
    });
end

function OnPlayerActive(ply)
    if not utl.block_join[ply] or utl.block_join[ply] == false then
        return
    end

    if config.reaction == 'block_join' then
        player.kick_idm(ply)
        if config.notifications then
            utils.notify('FutureBlackList', 'Name: ' .. player.get_name(ply) .. '\nR* ID: ' .. player.get_rid(ply) ..
                '\nReason: Blacklisted Player\nReaction: Block Join', gui_icon.players, notify_type.important)
        end
    end
end

function OnPlayerLeft(ply)
    script.blacklisted_player[ply] = false
    utl.block_join[ply] = false
end

function OnInit() -- Load
    if config.notifications then
        utils.notify('FutureBlackList', 'Script succesfully loaded!', gui_icon.players, notify_type.default)
    end

    if not fs.file_exists(root .. '/lib/json.lua') or not json then
        http.get('https://raw.githubusercontent.com/IMXNOOBX/ScriptKid/main/lib/json.lua', function(code, headers, content)
			if (code ~= 200) then
				return error(
					'Could not download json.lib, please download https://raw.githubusercontent.com/IMXNOOBX/ScriptKid/main/lib/json.lua and put it in lua/lib/json.lua')
			end
			if not fs.exists(root .. '/lib') then
				fs.create_dir(root .. '/lib')
			end

			local file = io.open(root .. '/lib/json.lua', "w+")
			file:write(content)
			file:close()

			utils.notify('FutureBlackList', 'Succesfully downloaded json library.', gui_icon.players,
				notify_type.default)
			json = require('lib/json')
		end)
    end

	utl.api_get_stats(function(res)
		if not res then return end
		script.stats = res
	end)

	for i, file in pairs(fs.get_files(fs.get_dir_script())) do -- check if pools.lua exists and if so move down the window
		if (string.match(file, "pool") and string.match(file, ".lua")) then 
			print('file: '..tostring(file))
			config.y_add = 120
		end
	end
end

function OnDone() -- Unload
    if utl.flag_id then
        player.flags.delete(utl.flag_id)
    end
    if config.notifications then
        utils.notify('FutureBlackList', 'Script disabled, be careful!', gui_icon.players, notify_type.default)
    end
end


local r, g, b, a = 30, 33, 35, 200

function OnFrame()
	if system.ticks() <= script.load_ticks + 10000 then return end
	-- if not config.enabled then return end
	if not menu.is_menu_opened() then
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

	-- -- Background
	draw.set_rounding(rounding)
	draw.set_color(0, r, g, b, a)
	draw.rect_filled(mw + mx + config.x_add - 5, my + config.y_add - 5, mw + mx + config.x_add + 150, my + config.y_add + 80)

	-- Text
	draw.set_color(0, 255, 255, 255, 255)
	draw.text(mw + mx + config.x_add, my + config.y_add - 4, tostring('FutureBlacklist'))
	
	draw.line(mw + mx + config.x_add, my + config.y_add + 14, mw + mx + config.x_add + 145, my + config.y_add + 14)

	draw.text(mw + mx + config.x_add, my + 15 +config.y_add, tostring('Total Players: '.. script.stats.total_players)) -- total players
	draw.text(mw + mx + config.x_add, my + 30 + config.y_add, tostring('Legit Players: '.. script.stats.legit_players)) -- legit players
	draw.text(mw + mx + config.x_add, my + 45 + config.y_add, tostring('Modders: '.. script.stats.modders)) -- modders
	draw.text(mw + mx + config.x_add, my + 60 + config.y_add, tostring('Advertisers: '.. script.stats.advertisers)) -- advertisers
	draw.set_rounding(0) -- reset
end
