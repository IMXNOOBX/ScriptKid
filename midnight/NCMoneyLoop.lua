--[[
**  Developer: midnight.im/members/36367/ **
**  Version: 1.0.2      		          **
**  Gta5 Version: 1.64                    **
**  github.com/IMXNOOBX/ScriptKid         **
]]

local lua_name = "money_loop.lua"
local money_loop = false
local next = 0
local next2 = 0

local init_time = nil
local t = nil
local c = 600
local m = 0
local s = nil
local many = 0

local r, g, b, a = 0, 0, 0, 0 

function disp_time(time)
    local days = math.floor(time/86400)
    local remaining = time % 86400
    local hours = math.floor(remaining/3600)
    remaining = remaining % 3600
    local minutes = math.floor(remaining/60)
    remaining = remaining % 60
    local seconds = math.floor(remaining)
    if (hours < 10) then
      hours = "0" .. tostring(hours)
    end
    if (minutes < 10) then
      minutes = "0" .. tostring(minutes)
    end
    if (seconds < 10) then
      seconds = "0" .. tostring(seconds)
    end
    answer = tostring(days)..":"..hours..":"..minutes..":"..seconds
    return answer
end

local formats = { -- make it work with both gta online characters
	"MP0_%s",
	"MP1_%s"
}

local function STAT_SET_INT(hash, value)
	for _, f in ipairs(formats) do
        stats.set_u64(string.smart_joaat(f:format(hash)), value)
	end
end

function OnFeatureTick()
    if (money_loop == true) then

        local now = system.ticks()
	    if next > now then return end
	    next = now + 5000
        
        script_global:new(262145 + 24045):set_int64(300000) -- fremode.c:1028716 - Dont change or it will permanently bug the safe value
        script_global:new(262145 + 24041):set_int64(300000) -- fremode.c:979059  - Same

        STAT_SET_INT("CLUB_POPULARITY", 10000)
        STAT_SET_INT("CLUB_PAY_TIME_LEFT", -1)
        STAT_SET_INT("CLUB_POPULARITY", 100000)

    end

end

function OnWarningScreen(thread)
    if (money_loop == true) then
	    if thread == "shop_controller" then
	    	next = system.ticks() + 25000
	    end
    end
end

function OnFrame()

    if (money_loop == true) then
        local x, y = draw.get_window_width(), draw.get_window_height()
        x = x * 0.5
        y = y * 0.5

        t = disp_time(os.difftime(system.time(), init_time))
        s = next - system.ticks()
        str = "WorkingsHours: "..t.."\nTimeToIssue: "..s

        draw.set_color(0, 255, 255, 255, 255)
        draw.set_thickness(1)
        draw.text(x - draw.get_text_size_x(str), y, str)
    end

end

local pmloop = "/mloop"
function OnChatMsg(index, text)
	if index ~= player.index() then return end

	if text:sub(1, #pmloop) == pmloop then
		if (money_loop == false) then
			money_loop = true
            script_global:new(262145 + 23084):set_int64(133377) -- Thanks yo OxiGen, i couldnt find it in fremode.c
			if (init_time == nil) then
				init_time = system.time()
			end
			utils.notify(lua_name, "Enabled", gui_icon.scripts, notify_type.success)
		else
			money_loop = false
			c = 0
			utils.notify(lua_name, "Disabled", gui_icon.scripts, notify_type.success)
		end
	end

end