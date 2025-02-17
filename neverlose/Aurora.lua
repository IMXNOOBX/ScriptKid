-- _DEBUG = true
-- Aurora v1.0.5
local ffi = require 'ffi';
local version = '1.0.5'

local V = {} -- V: variables
local F = {} -- F: functions
local G = {} -- G: groups
local M = {} -- M: menu
local S = {} -- S: script

ffi.cdef[[
    typedef struct {float x, y, z;} Vector3_t;
]]

V = {
	client = {
		username = common.get_username(),
		screen_size = render.screen_size(),
	},
	icon = ui.get_icon('planet-ringed'), -- stars
	effects = {
		"Sparkling",
		"Energy"
	},
	animations = {
		"Happy Aurora",
		"Protective Aurora",
		"Lazy Aurora"
	},
	resources = {
		list = {
			{
				url = "https://cdn.discordapp.com/attachments/760822494419484672/1097939042236104865/aurora_banner.gif", -- replace with a valid url gif/image (480x174)
				size = vector(573, 100),
				name = "aurora_banner"
			},
		},
		aurora_banner = nil
	},
	neffects = {
		IEffects = nil
	}
}

F = {
	script = {
		open_url = function(url)
            panorama.SteamOverlayAPI.OpenExternalBrowserURL(url)
        end,
		load_resources = function()
			files.create_folder('nl\\aurora')
			local success = true
			for index, data in pairs(V.resources.list) do
				local success, read = pcall(function() return render.load_image_from_file('nl\\aurora\\'..data.name..".gif", data.size) end)
				if success and read then
					V.resources[data.name] = read
					if V.resources[data.name] == nil then
						print_raw("[aurora][error] loading local image: nl\\aurora\\"..data.name..".gif")
						success = false
					else
						print_raw("[aurora] loading local image: nl\\aurora\\"..data.name..".gif")
					end
				else
					network.get(data.url, nil, function(content) 
						if not content then goto skip success = false end
						print_raw("[aurora] downloading: "..data.name)
						V.resources[data.name] = render.load_image(content)
						files.write('nl\\aurora\\'..data.name..".gif", content, true)
						::skip::
					end)
				end
			end

			return success
		end,
		call_helper = function(...)
			local args = {...}
			local vTbl
			if #args == 1 and (type(args[1]) == "userdata" or type(args[1]) == "cdata" or type(args[1]) == "number") then
				vTbl = args[1]
			elseif #args == 2 then
				if type(args[1]) == "string" and type(args[2]) == "number" then
					local ct = ffi.typeof(args[1])
					return function(class, ...)
						local ok, ret = pcall(ffi.cast, ct, ffi.cast("void***", class)[0][args[2]])
						return ok and ret(class, ...) or nil
					end
				end
				vTbl = utils.create_interface(args[1], args[2])
			else
				return error("class not found.")
			end
			if ffi.cast("void*", vTbl) == ffi.new("void*") then
				return error("class not found.")
			end
			return {
				this = ffi.cast("void***", vTbl),
				getVFunc = function(self, name, arguments, index, ...)
					if not index then
						return error("no class member subscript provided.")
					end
					local this = self.this
					local args = {...}
					local type = "void"
					if args[1] then
						type = args[1]
					end
					arguments = arguments:len() == 0 and "void*" or "void*, " .. arguments
					local ok, ct = pcall(ffi.typeof, type .. "(__thiscall*)(" .. arguments .. ")")
					if not ok then
						error(ct, 2)
					end
					local func = ffi.cast(ct, this[0][index])
					self[(not name or #name > 0) and name or index] = function(...)
						return func(this, ...)
					end
				end
			}
		end,
	},
	math = {
		quad_in = function(t, b, c, d)
			t = t / d
			return c * t * t + b
		end,
		quad_out = function(t, b, c, d)
			t = t / d
			return -c * t * (t - 2) + b
		end,
		cubic_in_out = function(t, b, c, d)
			t = t / (d / 2)
			if t < 1 then
				return c / 2 * t * t * t + b
			else
				t = t - 2
				return c / 2 * (t * t * t + 2) + b
			end
		end,
		quart_in_out = function(t, b, c, d)
			t = t / d * 2
			if t < 1 then
				return c / 2 * t * t * t * t + b
			end
			t = t - 2
			return -c / 2 * (t * t * t * t - 2) + b
		end
	},
	effects = {}
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
}

if F.script.load_resources() then
	print_raw("[Aurora] Loading all assets was a success! Version loaded: "..version)
else
	print_raw("[Aurora] There was an error loading assets. using cloud image.")
end

M = {
	menu = {
		main_index = G.main.index:label('Welcome ' .. V.client.username .. ', to Aurora ' .. version .. ' script!\n'),
		main_index_banner = G.main.index:texture(V.resources.aurora_banner or render.load_image(network.get(V.resources.list[1].url), vector(270, 100)), vector(570, 100), color(), 'f', 3),
		main_index_script = G.main.index:switch('Aurora', false):tooltip("Enable all the settings for your loyal friend that will follow you to the end of the universe."),
		main_index_enable_effects = G.main.index:list('Auroras', V.effects),
		main_index_enable_animations = G.main.index:list('Animations', V.animations),
		main_index_enable_color = G.main.index:color_picker("Aurora color", color(255, 255, 255, 255)),
		main_index_enable_smooth = G.main.index:slider("Smooth", 0, 10, 10),
		main_index_enable_size = G.main.index:slider("Size", 10, 50, 30),
	}
}

	V.neffects.IEffects = F.script.call_helper("client.dll", "IEffects001")
	V.neffects.IEffects.vec1 = ffi.new("Vector3_t")
	V.neffects.IEffects.vec2 = ffi.new("Vector3_t")
	V.neffects.IEffects:getVFunc("Sparks", "const Vector3_t&, int, int", 3)
	V.neffects.IEffects:getVFunc("EnergySplash", "const Vector3_t&, const Vector3_t&, bool", 7)
	V.neffects.spark_material = materials.get("effects/spark") or nil -- error "invalid material"

	F.effects.sparks = function(position, magnitude, trail_length, clr)
		local clr = clr or color()
		if V.neffects.spark_material then
			V.neffects.spark_material:color_modulate(clr)
		end
		V.neffects.IEffects.vec1.x = position.x
		V.neffects.IEffects.vec1.y = position.y
		V.neffects.IEffects.vec1.z = position.z
		V.neffects.IEffects.Sparks(V.neffects.IEffects.vec1, magnitude or 1, trail_length or 1)
	end

	F.effects.energy_splash = function(position, direction, explosive, clr)
		local clr = clr or color()
		if V.neffects.spark_material then
			V.neffects.spark_material:color_modulate(clr)
		end
		V.neffects.IEffects.vec1.x = position.x
		V.neffects.IEffects.vec1.y = position.y
		V.neffects.IEffects.vec1.z = position.z
		V.neffects.IEffects.vec2.x = direction and direction.x or 0
		V.neffects.IEffects.vec2.y = direction and direction.y or 0
		V.neffects.IEffects.vec2.z = direction and direction.z or 0
		V.neffects.IEffects.EnergySplash(V.neffects.IEffects.vec1, V.neffects.IEffects.vec2, explosive or false)
	end

local prev 
function S.render_aurora() 
	if not M.menu.main_index_script:get() then return end
	local local_player = entity.get_local_player()
	if not local_player or not local_player:is_alive() then return end

	local type = M.menu.main_index_enable_effects:get()
	local animation = M.menu.main_index_enable_animations:get()

	local smooth = M.menu.main_index_enable_smooth:get()
	local curtime = globals.curtime * 5
	local thickness = vector(1, 1, 0.5)
	local size = local_player.m_vecVelocity:length() > 10 and M.menu.main_index_enable_size:get() or M.menu.main_index_enable_size:get() * 2
	local menu_color = M.menu.main_index_enable_color:get()
	local origin = local_player:get_origin() + vector(math.cos(curtime)*size, math.sin(curtime)*size, math.abs(math.sin(curtime/7)*60))
	prev = prev or origin

	if type == 1 then
		F.effects.sparks(prev, 1, 0, color(0, 0, 0))
	elseif type == 2 then
		F.effects.energy_splash(prev, nil, true, menu_color)
	end

	if animation == 1 then
		prev = smooth > 0 and F.math.quad_in(1, prev, origin-prev, smooth) or origin
	elseif animation == 2 then 
		prev = smooth > 0 and F.math.quad_out(1, prev, origin-prev, smooth) or origin
	elseif animation == 3 then
		prev = smooth > 0 and F.math.cubic_in_out(1, prev, origin-prev, smooth) or origin
	end
end 

function S.render_menu()
	M.menu.main_index:visibility(true)
	M.menu.main_index_script:visibility(true)
	M.menu.main_index_enable_effects:visibility(M.menu.main_index_script:get() == true)
	M.menu.main_index_enable_animations:visibility(M.menu.main_index_script:get() == true)
	M.menu.main_index_enable_color:visibility(M.menu.main_index_script:get() == true and M.menu.main_index_enable_effects:get() ~= 1)
	M.menu.main_index_enable_smooth:visibility(M.menu.main_index_script:get() == true and M.menu.main_index_enable_animations:get() == 1)
	M.menu.main_index_enable_size:visibility(M.menu.main_index_script:get() == true)
end

events.render:set(function()
	S.render_aurora() 

	if ui.get_alpha() == 1 then -- render menu items while the cheat menu is open
        S.render_menu()
    end
end)

ui.sidebar('Aurora', V.icon)