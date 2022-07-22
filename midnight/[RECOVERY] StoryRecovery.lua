--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.0       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

function OnInit()
	utils.notify('StoryRecovery', 'Unload the script to\nset the maximun Story Mode money!', gui_icon.settings, notify_type.warning)
end

function OnDone()
	STATS.STAT_SET_INT('SP0_TOTAL_CASH', 2069696969, true) -- Michael
	STATS.STAT_SET_INT('SP1_TOTAL_CASH', 2069696969, true) -- Franklin
	STATS.STAT_SET_INT('SP2_TOTAL_CASH', 2069696969, true) -- Trevor
	utils.notify('StoryRecovery', 'Money set!', gui_icon.settings, notify_type.default)
end