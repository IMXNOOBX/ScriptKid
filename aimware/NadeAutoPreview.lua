--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.0       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

local status = false
local last_status = false
local last_cmd = common.Time()
local nades = {
	49, -- C4 
	48, 47, 45, 44, 43 -- Rest of nades
}

callbacks.Register("Draw", "Unique", function()
	if last_cmd < common.Time() then
		local lp = entities.GetLocalPlayer();

		for i = 1, #nades do
			if lp:GetWeaponID() == nades[i] then
				status = true
				break
			else
				status = false
			end
		end

		if (status ~= last_status) then
			client.Command(status and "+lookatweapon" or "-lookatweapon")
			last_status = status
		end

		last_cmd = common.Time() + 0.5
	end
end)

callbacks.Register("Unload", "Unique", function()
	if (status) then return end

	client.Command("-lookatweapon")
end)