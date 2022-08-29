--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.1       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

local settings = {
	speed = 'slow', -- slow, normal, fast
}
local utils = {
	status = false,
	alpha = 1
}

function OnFrame()
	if system.ticks() <= 10000 then return end
	if not menu.is_menu_opened() then
		if utils.status == true then return end
		menu.set_alpha(0)
		utils.alpha = 1
		utils.status = true
	end

	if utils.status == false then return end
	if utils.alpha < 255 then
		utils.alpha = utils.alpha + ((settings.speed == 'slow' and 1) or (settings.speed == 'normal' and 5) or (settings.speed == 'fast' and 10) or 1)
		menu.set_alpha(utils.alpha)
	elseif utils.alpha >= 255 then
		utils.status = false 
	end
end

function OnDone()
    menu.set_alpha(255)
end
