-- FutureBlackList v1.2.4
util.require_natives(1660775568)
util.keep_running()
local json
local path_root = filesystem.scripts_dir() .. "lib/FBL/"

if not filesystem.exists(path_root .. "FBL") then
    filesystem.mkdir(path_root)
end
if (not filesystem.exists(path_root .. 'json.lua')) then
    async_http.init('raw.githubusercontent.com', '/IMXNOOBX/ScriptKid/main/lib/json.lua', function(req)
        local err = select(2, load(req))
        if err then
            util.toast("Failed to download lib/json.lua")
            return
        end
        local f = io.open(path_root .. 'json.lua', "wb")
        f:write(req)
        f:close()
        util.toast("Successfully downloaded json.lua")
        util.restart_script()
    end)
    async_http.dispatch()
else
    json = require "lib/json"
end

local script = {
    host = "https://api.futuredb.shop",

    friend_handle_ptr = memory.alloc(13 * 8),

    detection_limiter = {},
}

local settings = {
    check_modders = true,
    check_advertisers = true,

    ignore_friends = true,

    react_to_m = {"Block Join (Temporal)", "BJ & Blacklist Locally", "Remove By Any Means"}, m_opt = 1,
    react_to_adv = {"Block Join (Temporal)", "BJ & Blacklist Locally", "Remove By Any Means"}, adv_opt = 1
}

local functions = {
    api_player_exists = function(rid, callback)
        async_http.init(script.host, "/api/v1/user/exist/" .. rid, function(body, header_fields, status_code)
            if (tonumber(status_code) ~= 200) then
                return callback(false)
            end
            local parsed = json.decode(body)
            if parsed['success'] == false then
                return callback(false)
            end
            if parsed['exist'] == true then
                return callback(true)
            end
        end, function()
            return callback(false)
        end)
        async_http.dispatch()
    end,
    api_get_player = function(rid, callback)
        async_http.init(script.host, "/api/v1/user/" .. rid, function(body, header_fields, status_code)
            if (tonumber(status_code) ~= 200) then
                return callback(-1)
            end
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
        end, function()
            return callback(-1)
        end)
        async_http.dispatch()
    end,
    pid_to_handle = function(pid) -- Credits: lancescript_reloaded
        NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, script.friend_handle_ptr, 13)
        return script.friend_handle_ptr
    end,
    to_ipv4 = function(ip) -- Same
        return string.format("%i.%i.%i.%i", ip >> 24 & 0xFF, ip >> 16 & 0xFF, ip >> 8 & 0xFF, ip & 0xFF)
    end,
    notify = function(string)
        string = tostring(string)
        util.toast('[FutureBlacklist] ' .. string)
        print('[FutureBlacklist] | ' .. string)
    end,
    player_join_reaction = function(pid, type, callback)
        local reaction = type == 1 and settings.m_opt or settings.adv_opt
        local name = players.get_name(pid)
        if (reaction == 1) then
            util.create_thread(function()
                menu.trigger_command(menu.ref_by_path('Online>Player History>' .. name ..
                                                          '>Player Join Reactions>Block Join'), 'on')
                util.yield(30000)
                menu.trigger_command(menu.ref_by_path('Online>Player History>' .. name ..
                                                          '>Player Join Reactions>Block Join'), 'off')
                util.stop_thread()
            end)
        elseif (reaction == 2) then
            menu.trigger_command(menu.ref_by_path('Online>Player History>' .. name ..
                                                      '>Player Join Reactions>Block Join'), 'on')
        elseif (reaction == 3) then
            if menu.get_edition() >= 2 then
                menu.trigger_commands("breakup" .. name)
            else
				menu.trigger_commands("kick" .. name)
            end
        end
        return callback('Applying reaction to ' .. name .. ' for ' .. (type == 1 and "Modding" or "Advertising"))
    end
}

local root = menu.my_root()
menu.divider(root, "Future Blacklist")
menu.toggle(root, 'Check For Modders', {'fbimodders'}, 'Future Blacklist Inspect for modders', function(val)
    settings.check_modders = val
end, settings.check_modders)
menu.toggle(root, 'Check For Advertisers', {'fbiadvertisers'}, 'Future Blacklist Inspect for advertiser', function(val)
    settings.check_advertisers = val
end, settings.check_advertisers)

menu.divider(root, "Reactions")
menu.list_select(root, "Reaction To Modders", {}, "The reaction that will be applied if the blacklisted user is modder",
    settings.react_to_m, settings.m_opt, function(val)
        settings.m_opt = val
        functions.notify('Reaction To Modders set to ' .. settings.react_to_m[settings.m_opt])
    end)
menu.list_select(root, "Reaction To Advertisers", {},
    "The reaction that will be applied if the blacklisted user is modder", settings.react_to_adv, settings.adv_opt,
    function(val)
        settings.adv_opt = val
        functions.notify('Reaction To Advertisers set to ' .. settings.react_to_adv[settings.adv_opt])
    end)

menu.divider(root, 'Aditional Settings')
menu.toggle(root, 'Ignore Friends', {'fbignorefr'}, 'Future Blacklist ignore friends', function(val)
    settings.ignore_friends = val
end, settings.ignore_friends)

--[[
	****************************************************************
]]

players.on_join(function(pid)
    if players.user() == pid then
        return
    end
    script.detection_limiter[pid] = {
        ['modder'] = false,
        ['advertiser'] = false
    }

    local hdl = functions.pid_to_handle(pid)
    if settings.ignore_friends == true and NETWORK.NETWORK_IS_FRIEND(hdl) then
        return
    end
    local rid = players.get_rockstar_id(pid)
    local name = players.get_name(pid)
    local ip = functions.to_ipv4(players.get_connect_ip(pid))
    local modder = players.is_marked_as_modder_or_admin(pid)
    functions.api_get_player(rid, function(result, note)
        if (result == 1 and settings.check_modders == true) or (result == 2 and settings.check_advertisers == true) then
            functions.player_join_reaction(pid, result, function(message)
                functions.notify(message)
            end)
        end
    end)
end)
players.dispatch_on_join() -- Calls your join handler(s) for every player that is already in the session.

players.on_leave(function(pid)
    script.detection_limiter[pid] = { -- reset to avoid errors
        ['modder'] = false,
        ['advertiser'] = false
    }
end)

functions.notify('Script has been loaded!')
