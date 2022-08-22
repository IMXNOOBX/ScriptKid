--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.2       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

function OnInit()
	if lobby.is_session_active() then utils.notify('StoryRecovery', 'Join "Story Mode" before doing anything!', gui_icon.settings, notify_type.warning) else utils.notify('StoryRecovery', 'Unload the script to\nset the maximun Story Mode money!', gui_icon.settings, notify_type.warning) end
end

function OnDone()
	if lobby.is_session_active() then return utils.notify('StoryRecovery', 'Join "Story Mode" before doing anything!', gui_icon.settings, notify_type.warning) end
	STATS.STAT_SET_INT(string.smart_joaat('SP0_TOTAL_CASH'), 2069696969, true) -- Michael
	STATS.STAT_SET_INT(string.smart_joaat('SP1_TOTAL_CASH'), 2069696969, true) -- Franklin
	STATS.STAT_SET_INT(string.smart_joaat('SP2_TOTAL_CASH'), 2069696969, true) -- Trevor

	utils.notify('StoryRecovery', 'Money set, Enjoy your game!', gui_icon.settings, notify_type.default)
end