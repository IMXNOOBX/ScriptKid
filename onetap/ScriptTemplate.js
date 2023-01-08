// ScriptTemplate v1.0.0
const version = '1.0.0';
const developers = ['IXMNOOBX']; // I know, i wrote wrong the name while creating the account


var V, F, G, M = {} // V: variables, F: functions, G: groups,  M: menu, S: script

V = {
	client: {
		username: Cheat.GetUsername(),
		screen_size: Render.GetScreenSize()
	}
}

F = {
	script: {
		is_developer: function () {
			for (i = 0; i < developers.length; i++) {
				if (username == developers[i])
					return true
			}
			return false
		},
	}
}

G = {
	create: UI.AddSubTab(['Config', 'SUBTAB_MGR'], 'ScriptTemplate'),
	root: ['Config', 'ScriptTemplate', 'ScriptTemplate']
}

M = {
	menu: {
		main_dropdown: F.script.is_developer() ? UI.AddDropdown(G.root, 'Menu', ['Main', 'Utils', 'Misc', 'Developer'], 0) : UI.AddDropdown(G.root, 'Menu', ['Main', 'Utils', 'Misc'], 0),

		main_index: UI.AddCheckbox(g.root, 'Enable Main'),
		utils_index: UI.AddCheckbox(g.root, 'Enable Utils'),
		misc_index: UI.AddCheckbox(g.root, 'Enable Misc'),
		developer_index: UI.AddCheckbox(g.root, 'Enable Developer'),
	}
}


function render_menu() {
	UI.SetEnabled(M.menu.main_dropdown, 1);
	UI.SetEnabled(M.menu.main_index, UI.GetValue(script.menu.main_dropdown) == 0 ? 1 : 0);
	UI.SetEnabled(M.menu.utils_index, UI.GetValue(script.menu.main_dropdown) == 1 ? 1 : 0);
	UI.SetEnabled(M.menu.misc_index, UI.GetValue(script.menu.main_dropdown) == 2 ? 1 : 0);
	UI.SetEnabled(M.menu.developer_index, UI.GetValue(script.menu.main_dropdown) == 3 ? 1 : 0);
}



function on_draw() {
	if (UI.IsMenuOpen()) {

	}
}
