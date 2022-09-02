--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.1       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

function OnInit()
	if not lobby.is_session_active() then utils.notify('Unlocker | Alert', 'Join "Online Mode" before doing anything!', gui_icon.settings, notify_type.warning) else utils.notify('Unlocker | Alert', 'Unload the script to unlock the m16!', gui_icon.settings, notify_type.warning) end
end

function OnDone()
	if not lobby.is_session_active() then return utils.notify('Unlocker | Alert', 'Join "Online Mode" before doing anything!', gui_icon.settings, notify_type.warning) end

	--script_global:new(262145 + 32775):set_int64(1)
	STATS._SET_PACKED_STAT_BOOL(32318, true, -1) -- Credits d6b.#1001
	utils.notify('Unlocker | Success', 'Weapon unlocked via globals.', gui_icon.settings, notify_type.default)

	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PLAYER.PLAYER_PED_ID(), MISC.GET_HASH_KEY("WEAPON_TACTICALRIFLE"), 1000, true)
	utils.notify('Unlocker | Success', 'Added weapon to player\'s inventory.', gui_icon.settings, notify_type.default)

	utils.notify('Unlocker | Success', 'Succesfully executed the script!', gui_icon.settings, notify_type.default)
end
