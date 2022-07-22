--[[
**  github.com/IMXNOOBX            **
**  Version: 1.0.0       		   **
**  github.com/IMXNOOBX/ScriptKid  **
]]

local config = {
	admins = {
		reaction_to_admin = 'session', -- 'session' or 'bail' or 'crash'
	},
	developers = { --This can be a modder using the developer flag
		developer_flag = true, -- Check for this flag
		reaction_to_dev = 'session', -- 'session' or 'bail' or 'crash'
	}
}

local rstar_admins = {
	67241866,
	89288299,
	88439202,
	179848415,
	184360405,
	184359255,
	182860908,
	117639172,
	142582982,
	115642993,
	100641297,
	116815567,
	88435319,
	64499496,
	174623946,
	174626867,
	151972200,
	115643538,
	144372813,
	88047835,
	115670847,
	173426004,
	170727774,
	93759254,
	174247774,
	151975489,
	146999560,
	179930265,
	88435236,
	179936743,
	179848203,
	151158634,
	174623904,
	179936852,
	117639190,
	93759401,
	10381465,
	121970978,
	174623951,
	174624061,
	10552062,
	174625194,
	174625307,
	174625407,
	174625552,
	174625647,
	138273823,
	138302559,
	1398134,
	88435916,
	174875493,
	171094021,
	173213117,
	171093866,
	88435362,
	137601710,
	103054099,
	104041189,
	99453882,
	147604980,
	130291558,
	141884823,
	131037988,
	153219155,
	155527062,
	114982881,
	119266383,
	119958356,
	216820,
	121397532,
	121698158,
	18965281,
	56778561,
	63457,
	121943600,
	123017343,
	123849404,
	127448079,
	129159629,
	127403483,
	174194059,
	131973478,
	64234321,
	62409944,
	64074298,
	133709045,
	134412628,
	137579070,
	137714280,
	137851207,
	130291511,
	138075198,
	137663665,
	9284553,
	147111499,
	6597634,
	23659342,
	23659354,
	103318524,
	132521200,
	107713114,
	107713060,
	23659353,
	57233573,
	111439945,
	81691532,
	77205006,
	25695975,
	24646485,
	49770174,
	146452200,
	54468359,
	54462116,
	53309582,
	85593421,
	21088063,
	50850475,
	31586721,
	56583239,
	20158753,
	20158751,
	23659351,
	91031119,
	91003708,
	16396170,
	16396157,
	16396148,
	16396141,
	16396133,
	16396126,
	16396118,
	16396107,
	16396096,
	16396091,
	16396080,
	16395850,
	16395840,
	16395850,
	16395782,
	16395773,
	22577458,
	22577440,
	22577121,
	16395782,
	20158757
}

function reaction_to_admin(reaction)
	if reaction == 'session' then
		lobby.change_session(session_type.public_join)
		utils.notify('R* Admin', 'Reaction: Leaving session to another session!', gui_icon.warning, notify_type.success)
	elseif reaction == 'bail' then
		lobby.change_session(session_type.solo_new)
		utils.notify('R* Admin', 'Reaction: Leaving session to single player mode!', gui_icon.warning, notify_type.success)
	elseif reaction == 'crash' then
		player.crash_izuku_start(ply)
		utils.notify('R* Admin', 'Reaction: Reaction: Sending Crash To ' .. name..'!', gui_icon.warning, notify_type.success)
	end
end

function OnPlayerJoin(ply, name, rid, ip, host_key)
	if config.developers.developer_flag and player.is_rockstar_dev(ply) then
		utils.notify('R* Admin', name  .. ' is a Rockstar Developer!\nDetected by: Mindnight Analysis', gui_icon.warning, notify_type.important)
		reaction_to_admin(config.developers.reaction_to_dev)
	end
	for i = 0, #rstar_admins do
		if tonumber(rid) == rstar_admins[i] then
			utils.notify('R* Admin', name  .. ' is a Rockstar Developer!\nDetected by: RID Blacklist', gui_icon.warning, notify_type.important)
			reaction_to_admin(config.admins.reaction_to_admin)
		end
	end
end

function OnInit()
	utils.notify('R* Admin', 'Loaded!\nReaction to R* admin: ' .. config.admins.reaction_to_admin..(config.developers.developer_flag and '\nReaction to Developer Flag: '..config.developers.reaction_to_dev or '\nDeveloper Flags Reactions Disabled!') , gui_icon.warning, notify_type.success)
end