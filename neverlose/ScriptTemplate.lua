_DEBUG = true
-- ScriptTemplate v1.0.0
local version = '1.0.0'
local developers = {'IMXNOOBX'}

local ffi = require 'ffi';

local V = {} -- V: variables
local F = {} -- F: functions
local G = {} -- G: groups
local M = {} -- M: menu
local S = {} -- S: script


V = {
	client = {
		username = common.get_username(),
		screen_size = render.screen_size(),
	}
}

F = {
	script = {
		is_developer = function()
            for i = 0, #developers do
                if developers[i] == V.client.username then
                    return true
                end
            end
            return false
        end,
		open_url = function(url)
            panorama.SteamOverlayAPI.OpenExternalBrowserURL(url)
        end,
	}
}

G = {
	main = {
		index = ui.create("Main", "Index"),
	},
	utils = {
		index = ui.create("Utils", "Index"),
	},
	misc = {
		index = ui.create("Misc", "Index"),
	},

	developer = F.script.is_developer() and {
		index = ui.create("Dev", "Index"),
	} or nil
}


M = {
	menu = {
		main_index = G.main.index:label('Welcome ' .. V.client.username .. '!\n'),
		main_index_script = G.main.index:switch('Enable Script', false):set_tooltip("Enable Script"),
		main_index_enable = G.main.index:switch('Enable Main', false):set_tooltip("Enable Main tab"),
		utils_index_enable = G.utils.index:switch('Enable Utils', false):set_tooltip("Enable Utils tab"),
		misc_index_enable = G.misc.index:switch('Enable Misc', false):set_tooltip("Enable Misc tab"),
		
		developer_index_enable = G.developer and G.developer.index:switch('Enable Developer', false):set_tooltip("Enable Developer tab") or nil,
	}
}



function S.render_menu()
	M.menu.main_index:set_visible(true)
	M.menu.main_index_script:set_visible(true)
	M.menu.main_index_enable:set_visible(M.menu.main_index_script:get() == true)

	M.menu.utils_index_enable:set_visible(M.menu.main_index_script:get() == true)
	M.menu.misc_index_enable:set_visible(M.menu.main_index_script:get() == true)
	
	if M.menu.developer_index_enable then
		M.menu.developer_index_enable:set_visible(M.menu.main_index_script:get() == true)
	end
end

events.render:set(function()


	if ui.get_alpha() == 1 then -- render menu items while the cheat menu is open
        S.render_menu()
    end
end)