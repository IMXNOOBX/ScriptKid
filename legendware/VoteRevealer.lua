--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.0       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

local ffi = require('ffi')

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

local votes = {}

events.register_event("vote_cast", function(ev)
    local localplayer = entitylist.get_local_player()


	local vote = ev:get_int('vote_option')
	local team = ev:get_int('team')
	local index = ev:get_int('entityid')
	local lpteam = localplayer:get_team()

	local inf = engine.get_player_info(index)

	local vote_str = 'Unknown'
	if vote == 0 then vote_str = '\x06Yes' 
	elseif vote == 1 then vote_str = '\x02No' end

	if team == lpteam then
		print(vtbl, 0, 0, "[\x03LW\x08|\x06VoteRevealer\x08] Player \x03" .. inf.name .. "\x08 Voted \x02" .. vote_str)
	else
		print(vtbl, 0, 0, "[\x03LW\x08|\x06VoteRevealer\x08] \x03Other Vote\x08:  Player \x03" .. inf.name .. "\x08 Voted \x02" .. vote_str)
	end
end)