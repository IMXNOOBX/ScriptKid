--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.0       		   **
**  github.com/IMXNOOBX/ScriptKid  **
**  credits: https://github.com/YimMenu/YimMenu/commit/f360d7f4366d9a591f1d1ee6c26e5bdf52fcdfb6 **
]]

function OnScriptEvent(ply, event, args)
	if event == 1279059857 or event == -343495611 then 
		utils.notify('RCE Exploit | Blocked', 'Blocked RCE event from: '..player.get_name(ply), gui_icon.warning, notify_type.success)
		return false
	end
end
