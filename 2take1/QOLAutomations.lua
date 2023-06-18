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

event.add_event_listener("player_join", function(joined_player)
    if joined_player.player == player.player_id() then
        system.yield(2 * 1000)
		script_host:toggle()
		menu.notify("Automatically requested script host for faster join", "Dont thank me!", 10, 0x2C8FFE00)
    end
end)