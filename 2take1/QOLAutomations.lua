--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.4       		   **
**  github.com/IMXNOOBX/ScriptKid  **
**  Features:					   **
**  Automatic PlayerSpoofer		   **
**  Automatic BusinessManager	   **
**  Automatic ScriptHostOnJoin	   **
**  Automatic SpecialCageRemoval   **
**  Automatic BlockGTA5Recordings  **
]]

local business_manager = menu.get_feature_by_hierarchy_key("online.business.enable_manager")
local player_spoofer = menu.get_feature_by_hierarchy_key("online.player_spoofer.enable")
local script_host = menu.get_feature_by_hierarchy_key("online.lobby.force_script_host")
local online_tab = menu.get_cat_children("online")
local player_spoofer_profile = nil

if not menu.is_trusted_mode_enabled(1 << 2) then
	menu.notify("You must turn on trusted mode->Natives to use this script.", "QOL Automations", 10, 0xff0000ff)
	return menu.exit()
end

menu.create_thread(function()
	while true do
		business_manager = menu.get_feature_by_hierarchy_key("online.business.enable_manager")
		player_spoofer = menu.get_feature_by_hierarchy_key("online.player_spoofer.enable")
		online_tab = menu.get_cat_children("online")
		
		for index, value in pairs(online_tab) do
			if value.name == 'Player Spoofer' then
				local first_profile = value.children[4] or nil -- first spoofing profile
				player_spoofer_profile = first_profile
			end
		end

		if (network.is_session_started()) then
			if (not business_manager.on) then
				business_manager.on = true
				menu.notify("Automatically enabled business manager", "Dont thank me!", 10, 0x2C8FFE00)
				system.yield(10 * 1000)
			end
		else
			if (not player_spoofer.on and player_spoofer_profile) then
				player_spoofer_profile:toggle()
				system.yield(100)
				player_spoofer.on = true
				menu.notify("Automatically enabled player spoofer", "Dont thank me!", 10, 0x2C8FFE00)
				system.yield(10 * 1000)
			end
		end
		
        native.call(0xEB2D525B57F42B40) -- REPLAY_PREVENT_RECORDING_THIS_FRAME

		system.yield(1000)
	end
end)

local cageModels =
{
	959275690, --'prop_gold_cont_01',
	1396140175, -- 'prop_gold_cont_01b',
	-1576911260, -- 'prop_feeder1_cr',
	2063962179, -- 'prop_rub_cage01a',
	2081936690, -- 'stt_prop_stunt_tube_s',
	779277682, -- 'stt_prop_stunt_tube_end',
	-1081534242, -- 'prop_jetski_ramp_01',
	1124049486, -- 'stt_prop_stunt_tube_xs',
	1001693768, -- 'prop_fnclink_03e',
	1765283457, -- 'prop_container_05a',
	1756664253, --'prop_elecbox_12',
    94602826
}

menu.create_thread(function()
	while true do
		local objects = object.get_all_objects()

		for _, value in pairs(objects) do
			local model_hash = entity.get_entity_model_hash(value)

			for i = 1, #cageModels do
				if (model_hash == cageModels[i]) then
					local ply = network.get_entity_net_owner(value)
					local name = ply and player.get_player_name(ply) or nil
					local cords = player.get_player_coords(player.player_id())

					network.request_control_of_entity(value)
					entity.set_entity_as_no_longer_needed(value)

					entity.set_entity_collision(value, false, true, true)
					entity.set_entity_alpha(value, 0, false)

					if (not entity.delete_entity(value)) then
						-- entity.set_entity_coords_no_offset(value, v3(9000, 9000, 9000))
						native.call(0x92C47782FDA8B2A3, cords.x, cords.y, cords.z, 10, value, -422877666, true) -- CREATE_MODEL_SWAP
					end

					menu.notify("Automatically removed cage" ..(name ~= nil and " from " .. name or "!"), "Dont thank me!", 3, 0x2C8FFE00)
				end
			end
		end

		system.yield(100)
	end
end)

event.add_event_listener("player_join", function(joined_player)
    if joined_player.player == player.player_id() then
        system.yield(3 * 1000)
		script_host:toggle() -- Causes crashes in some cases
		menu.notify("Automatically requested script host for faster join", "Dont thank me!", 10, 0x2C8FFE00)
    end
end)