--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.2       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

function set_seat_belt(bool)
	-- if not player.is_in_vehicle(player.index()) then return end
	local id = player.id();
	PED.SET_PED_CONFIG_FLAG(id, 32, bool)
	PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(id, bool);
end

function OnTransitionEnd(is_multiplayer) 
	set_seat_belt(true)
end

function OnInit()
	set_seat_belt(true)
	utils.notify('Seat belt', 'Seat belt enabled, Drive as unsafe as you want!', gui_icon.players, notify_type.success)
end

function OnDone()
	set_seat_belt(false)
	utils.notify('Seat belt', 'Seat belt disabled, Drive carefully!', gui_icon.players, notify_type.success)
end