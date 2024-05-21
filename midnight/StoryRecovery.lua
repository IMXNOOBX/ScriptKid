--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.3       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

events.on_init(function()
	if lobby.is_session_active() then 
        ui.popup('StoryRecovery', 'Join "Story Mode" before doing anything!', Icons.SETTINGS, PopupType.BOX)
    else 
        ui.popup('StoryRecovery', 'Check the new tab to add the money!', Icons.SETTINGS, PopupType.BOX)
    end
end)

local run = false
local function set_money()
    if lobby.is_session_active() then return ui.popup('StoryRecovery', 'Join "Story Mode" before doing anything!', Icons.SETTINGS, PopupType.BOX) end
	STATS.STAT_SET_INT(string.smart_joaat('SP0_TOTAL_CASH'), 2069696969, true) -- Michael
	STATS.STAT_SET_INT(string.smart_joaat('SP1_TOTAL_CASH'), 2069696969, true) -- Franklin
	STATS.STAT_SET_INT(string.smart_joaat('SP2_TOTAL_CASH'), 2069696969, true) -- Trevor
    
    ui.popup('StoryRecovery', 'Money set, Make sure you save by sleeping & enjoy your game!', Icons.SETTINGS, PopupType.BOX)
end

-- Menu

local sr_page = ui.new_page('StoryRecovery', Icons.PLUS)

local main_group = sr_page:new_group('Main', PageColumn.FIRST)

local add_money_buttom = main_group:new_button('Add Story Max Money', function() 
    run = true
end)

events.on_script_tick(function()
    if run then
        set_money()
        run = false
    end
end) 