local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local name, plugin = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local db, gdb
local moduleFullOptions = {}

plugin = mUI:GetModule("Unitframes")

plugin:SetOptions(function(self)
	local order = 1
	local function newOrder()
		order = order + 1
		return order
	end
	
	-- Power options
	local function GetPowerOptions()
		local powerNames = {}
		local powerOptions = {}
		local powerOption = {
			type = "color",
			name = function(info)
				local token = info[#info]
				return _G[token] or token
			end,
		}
		for k, v in pairs(self.db.defaults.profile.Colors.Power) do
			powerOptions[k] = powerOption
			powerOptions[k].order = newOrder()
		end
		powerOptions.sep = {
			type = "header",
			name = "",
			order = -2,
		}
		powerOptions.reset = {
			type = "execute",
			name = "Reset",
			confirm = true,
			order = -1,
			func = function()
				for powerName, color in pairs(PowerBarColor) do
					if type(powerName) == "string" then
						if color.r then
							self.db.profile.Colors.Power[powerName] = {color.r, color.g, color.b, color.a or 1}
						elseif powerName == "ECLIPSE" then
							local pos, neg = color.positive, color.negative
							if neg then
								self.db.profile.Colors.Power["BALANCE_NEGATIVE_ENERGY"] = {neg.r, neg.g, neg.b, neg.a or 1}
							end
							if pos then
								self.db.profile.Colors.Power["BALANCE_POSITIVE_ENERGY"] = {pos.r, pos.g, pos.b, pos.a or 1}
							end
						end
					end
				end
			end,
		}
		
		return powerOptions
	end
	
	-- Reaction options
	local function GetReactionColorOptions()
		local reactionNames = {}
		local reactionOptions = {}
		local reactionOption = {
			type = "color",
			name = function(info)
				token = info[#info]
				local label = "FACTION_STANDING_LABEL" .. token
				return _G[label] or label
			end,
		}
		for k, v in pairs(self.db.defaults.profile.Colors.Reaction) do
			reactionOptions[k..""] = reactionOption
			reactionOptions[k..""].order = newOrder()
		end
		reactionOptions.sep = {
			type = "header",
			name = "",
			order = -2,
		}
		reactionOptions.reset = {
			type = "execute",
			name = "Reset",
			order = -1,
			func = function()
				for reaction, color in pairs(FACTION_BAR_COLORS) do
					local db_color = self.db.profile.Colors.Reaction[reaction..""]
					db_color[1], db_color[2], db_color[3] = color.r, color.g, color.b
				end
			end,
		}
		
		return reactionOptions
	end
	
	-- Other color options
	local function GetOthersColorOptions()
		local otherOptions = {
			Health = {
				type = "color",
				name = "Health",		
				order = newOrder(),
			},
			HalfHealth = {
				type = "color",
				name = "Half health",
				order = newOrder(),			
			},
			MinHealth = {
				type = "color",
				name = "Minimum health",
				order = newOrder(),
			},
			Tapped = {
				type = "color",
				name = "Tapped",
				order = newOrder(),
			},
			Disconnected = {
				type = "color",
				name = "Disconnected",				
				order = newOrder(),
			},
			AltPower = {
				type = "color",
				name = "Alternative power",
				order = newOrder(),
			},
		}
		
		return otherOptions
	end
	

	return "Colors", {
		type = "group",
		name = "Colors",
		get = function(info)
			return mUI.AceGUIGet(plugin.db.profile.Colors[info[#info-1]], info)
		end,
		set = function(info, ...)					
			mUI.AceGUISet(plugin.db.profile.Colors[info[#info-1]], info, ...)
		end,
		args = {
			Power = {
				type = "group",
				name = "Power",
				order = newOrder(),
				guiInline = true,
				args = GetPowerOptions(),
			},
			Reaction = {
				type = "group",
				name = "Reaction",
				order = newOrder(),
				guiInline = true,				
				args = GetReactionColorOptions(),
			},
			Other = {
				type = "group",
				name = "Other",
				order = newOrder(),
				guiInline = true,
				args = GetOthersColorOptions(),
			},
		},
	}, "Modules", self.Options:GetModuleOptions()
end)

local Options = {}
plugin.Options = Options

function Options:GetModuleOptions()
	local moduleOptions = {
		type = "group",
		name = "Modules",
		desc = "Modules provide functionallity and looks to the Unitframes.",
		args = {},
		childGroups = "tree",
	}
	
	local moduleArgs = {
		enabled = {
			type = "toggle",
			name = "Enable",
			desc = "Globally enable this module.",
			order = 1,
			get = function(info)
				return info.handler:IsEnabled()
			end,
			set = function(info, value)
				if value then
					plugin:EnableModuleState(info.handler)
				else
					plugin:DisableModuleState(info.handler)
				end
			end
		},
		moduleSplit = {
			type = "description",
			name = "",
			order = 2,
		},
	}
	
	local function merge_onto(dict, ...)
		for i = 1, select('#', ...), 2 do
			local k, v = select(i, ...)
			if not v.order then
				v.order = 100 + i
			end
			dict[k] = v
		end
	end
	
	function Options:HandleModuleLoaded(module)
		if DEBUG then
			expect(module, "typeof", "table")
			expect(module.IsEnabled, "typeof", "function")
		end
		
		local id = module.id
		local opt = {
			type = "group",
			name = module.name,
			desc = module.desc,
			handler = module,
			args = {},
		}
		
		moduleOptions.args[module.baseName] = opt
		for k, v in pairs(moduleArgs) do
			opt.args[k] = v
		end
		
		if moduleFullOptions[module] then
			merge_onto(opt.args, moduleFullOptions[module](module))
			moduleFullOptions[module] = false
		end
	end
	
	for id, module in plugin:IterateModules() do
		Options:HandleModuleLoaded(module)
	end
	
	return moduleOptions
end

function plugin.defaultModulePrototype:SetOptions(func)
	if DEBUG then
		expect(func, "typeof", "function")		
		expect(moduleFullOptions[self], "==", nil)
	end
	
	moduleFullOptions[self] = func
end