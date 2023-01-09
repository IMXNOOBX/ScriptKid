-- ScriptTemplate v1.0.0
local version = '1.0.0';
local developers = {
	'IMXNOOBX'
}
 
-- local ffi = require 'ffi';

local V = {} -- V: variables
local F = {} -- F: functions
local G = {} -- G: groups
local M = {} -- M: menu
local S = {} -- S: script


V = {
	client = {
		username = cheat.GetUserName(),
		screen_size = draw.GetScreenSize(),
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

G.root = gui.Tab(gui.Reference("Settings"), "root_tab", "ScriptTemplate")
G = {
	main = {
		index = gui.Groupbox(G.root, "Main", 16, 16, 300)
	}
}


M = {
	menu = {
		main_index = gui.Text(G.main.index, 'Welcome ' .. V.client.username .. '!\n'),
		main_toggle = gui.Checkbox(G.main.index, "main_toggle", "Enable Script", false),
		main_pop = gui.Text(G.main.index, 'Hi!!, im visible now'),

	}
}



function S.render_menu()
	M.menu.main_pop:SetInvisible(not M.menu.main_toggle:GetValue())
end

callbacks.Register("Draw", function() 
	S.render_menu()
end);