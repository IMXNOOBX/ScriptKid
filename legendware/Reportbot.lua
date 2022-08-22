--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.0       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

-- Was my first try dont blame me because of the poor code

local js = require('lib')
local ffi = require('ffi')

local on_unload = false 
local debug = false 

if debug then client.log('[debug] ReportBot loaded!') end

ffi.cdef[[
    typedef unsigned long DWORD;
    DWORD __stdcall GetTickCount( );

    typedef unsigned long DWORD, *PDWORD, *LPDWORD;  

    typedef void (__cdecl* chat_printf)(void*, int, int, const char*, ...);
]]

local FindHudElement = function(name)
    local pThis = ffi.cast(ffi.typeof("DWORD**"), utils.find_signature("client.dll", "B9 ? ? ? ? 68 ? ? ? ? E8 ? ? ? ? 89 46 24") + 1)[0]

    local find_hud_element = ffi.cast(ffi.typeof("DWORD(__thiscall*)(void*, const char*)"), utils.find_signature("client.dll", "55 8B EC 53 8B 5D 08 56 57 8B F9 33 F6 39 77 28"))

    return find_hud_element(pThis, name)
end

local g_ChatElement = FindHudElement("CHudChat")

local CHudChat_vtbl = ffi.cast(ffi.typeof("void***"), g_ChatElement)

print = ffi.cast("chat_printf", CHudChat_vtbl[0][27])
vtbl = CHudChat_vtbl

menu.add_check_box("Enable ReportBot")
menu.add_combo_box('Who', {'Enemies', 'Teammates', 'Everyone'})
menu.add_combo_box('Logs', {'Disabled', 'Local Chat', 'Team Chat', 'Chat All'})


local reportedplayers = { };
local toreport = { };
local nextreport = 0;

function IsPlayerReported(steamid)
    for i = 1, #reportedplayers, 1 do
        if(reportedplayers[i] == steamid) then
            return true;
        end
    end
    return false;
end

function IsPlayerToReport(inlist)
    for i = 1, #toreport, 1 do
        if(toreport[i] == inlist) then
            return true;
        end
    end
    return false;
end

function getTeam(i)
    local localplayer = entitylist.get_local_player() 
    local ent = entitylist.get_player_by_index(i)
    if ent and ent:is_player() then
        local player = entitylist.entity_to_player(ent)
        if player:get_team() == localplayer:get_team() then
            return true
        end
        return false;
    end
end

function logReport(index)
    if( index == nil ) then
        if debug then client.log( "Failed to get player info for player #" .. index ); end
        return;
    end

    local info = engine.get_player_info(index);

    if menu.get_int('Logs') == 1 then
        print(vtbl, 0, 0, "[\x03LW\x08|\x06ReportBot\x08] Reported User: \x02" .. info.name .. "\x08 Steam ID: \x02" .. info.steam_id .. "\x08 for 'aimbot, wallhack, grief' \x07")
    elseif menu.get_int('Logs') == 2 then
        console.execute("say_team [LW|ReportBot] Reported User: " .. info.name .. " Steam ID: " .. info.steam_id .. " for 'aimbot, wallhack, grief'" )
    elseif menu.get_int('Logs') == 3 then
        console.execute("say [LW|ReportBot] Reported User: " .. info.name .. " Steam ID: " .. info.steam_id .. " for 'aimbot, wallhack, grief'" )
    end

end

-- print(vtbl, 0, 0, "[\x01Color 1\x08] [\x02Color 2\x08] [\x03Color 3\x08] [\x04Color 4\x08] [\x05Color 5\x08] [\x06Color 6\x08] [\x07Color 7\x08] [\x08Color 8\x08] [\x09Color 9\x08] [\x010Color 10\x08] [\x011Color 11\x08]")
function ReportPlayer(index)
    if( index == nil ) then
        if menu.get_int('Who') ~= 0 then print(vtbl, 0, 0, "[\x03LW\x08|\x06ReportBot\x08] Fininished reporting: \x02" .. #reportedplayers .. "\x08 Players") end
        for i = 1, #reportedplayers, 1 do
            reportedplayers[i] = nil
        end

        return;
    end

    local info = engine.get_player_info(index);

    js.eval([[
        try {
            var xuid = GameStateAPI.GetPlayerXuidStringFromEntIndex( ]] .. index .. [[ );
            var name = GameStateAPI.GetPlayerName( xuid );

            GameStateAPI.SubmitPlayerReport( xuid, "aimbot, wallhack, grief" );
            // $.Msg( "Successfully reported player " + name );
        }
        catch(e) {
            $.Msg( "Exception while reporting player #]] .. index .. [[" );
        }
    ]]);
    logReport(index)

    table.insert(reportedplayers, info.steam_id);
end

function ProcessReportQueue()
    for i = 1, #toreport, 1 do

        if(nextreport > ffi.C.GetTickCount()) then return end;
        nextreport = ffi.C.GetTickCount( ) + 2200;
        -- client.log('Reporty queue next: '..toreport[i]..' From Ammount: '..tostring(#toreport))
        if(toreport[i] == nil) then return end;
        local info = engine.get_player_info(toreport[i]);
        if IsPlayerReported(info.steam_id) then table.remove(toreport, 1); end
        -- client.log('Reporting: '..tostring(info.bot) .." usrname: "..tostring(info.name).." stimid: "..tostring(info.steam_id).." i list: "..i)
        ReportPlayer(toreport[i]);
    end
end

function doReportBot()
    if not engine.is_in_game() then return end
    if on_unload then return end
    if not menu.get_bool("Enable ReportBot") then return end
    local localplayer = entitylist.get_local_player() 
    if not localplayer then return end

    for i=1, 64 do
        local entity = entitylist.get_player_by_index(i)
        local usr_info = engine.get_player_info(i)
        if ( usr_info and string.lower( usr_info.name ) ~= "gotv" and i ~= localplayer:get_index( ) and usr_info.steam_id64 ~= "0" and usr_info.steam_id ~= "" and usr_info.bot == false ) then
            if menu.get_int('Who') == 0 then
                if not getTeam(i) and not IsPlayerReported(usr_info.steam_id) and IsPlayerToReport(i) == false then
                if debug then client.log('Added to list 1: isbot: '..tostring(usr_info.bot) .." username: "..tostring(usr_info.name).." stimid: "..tostring(usr_info.steam_id).." i list: "..i)   end
          
                    -- Reportbot enemies
                    table.insert(toreport, i);
                end
            elseif menu.get_int('Who') == 1 then 
                if getTeam(i) and not IsPlayerReported(usr_info.steam_id) and IsPlayerToReport(i) == false then
                    if debug then client.log('Added to list 2: isbot: '..tostring(usr_info.bot) .." username: "..tostring(usr_info.name).." stimid: "..tostring(usr_info.steam_id)) end
                    -- Reportbot teammates
                    table.insert(toreport, i);
                end
            elseif menu.get_int('Who') == 2 then 
                if not IsPlayerReported(usr_info.steam_id) and IsPlayerToReport(i) == false then
                    if debug then client.log('Added to list 3: isbot: '..tostring(usr_info.bot) .." username: "..tostring(usr_info.name).." stimid: "..tostring(usr_info.steam_id)) end
                    -- Reportbot everyone
                    table.insert(toreport, i);
                end
            end
            ProcessReportQueue()
        end
    end
end


client.add_callback('on_paint', doReportBot)
client.add_callback("unload", function() 
    on_unload = true
end)
