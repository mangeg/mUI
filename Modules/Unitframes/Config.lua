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

	return "Layouts", {
		type = "group",
		name = "Layouts",
		childGroups = "select",
		args = self.Options:GetLayoutOptions(),
	},	
	"Units", {
		type = "group",
		name = "Units",
		childGroups = "select",
		args = self.Options:GetUnitOptions(),
	},
	"Colors", {
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
	},	
	"Modules", self.Options:GetModuleOptions()
end)

local Options = {}
plugin.Options = Options

function Options:GetModuleOptions()
	plugin:LoadModules()
	
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
			desc = module.description,
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
	
	local function loadable(info)
		local id = info[#info - 1]
		local _,_,_,_,loadable = GetAddOnInfo(id)
		return loadable
	end

	local function unloadable(info)
		return not loadable(info)
	end

	local arg_enabled = {
		type = "toggle",
		name = "Enable",
		desc = "Globally enable this module.",
		get = function(info)
			return false
		end,
		set = function(info, value)
			local id = info[#info - 1]
			plugin:LoadAndEnableModule(id)
		end,
		disabled = unloadable,
	}
	
	local no_mem_notice = {
		type = "description",
		name = "This module is not loaded and will not take up and memory or processing power until enabled.",
		order = -1,
		hidden = unloadable,
	}
	
	local unloadable_notice = {
		type = "description",
		name = function(info)
			local id = info[#info - 1]
			local _,_,_,_,loadable,reason = GetAddOnInfo(id)
			if not loadable then
				if reason then
					if reason == "DISABLED" then
						reason = "Disabled in the Blizzard addon list."
					else
						reason = _G["ADDON_"..reason]
					end
				end
				if not reason then
					reason = UNKNOWN
				end
				return format("This module can not be loaded: %s", reason)
			end
		end,
		order = -1,
		hidden = loadable,
	}
	
	for i, moduleID in ipairs(plugin.ModulesNotLoaded) do
		if not moduleOptions.args[moduleID] then
			local title = GetAddOnMetadata(moduleID, "Title")
			local notes = GetAddOnMetadata(moduleID, "Notes")	
			
			local name = title:match("[[](.*)[]]$")
			if not name then
				name = moduleID
			else
				name = name:gsub("|r", ""):gsub("|c%x%x%x%x%x%x%x%x", "")
			end
		
			local opt = {
				type = "group",
				name = name,
				desc = notes,
				args = {
					enabled = arg_enabled,
					no_mem_notice = no_mem_notice,
					unloadable_notice = unloadable_notice,
				},
			}
			
			moduleOptions.args[moduleID] = opt
		end
	end
	
	return moduleOptions
end

local units = {
	player = true,
	target = true,
	targettarget = true,
}

function Options:GetUnitOptions()
	local order = 1
	local function newOrder()
		order = order + 1
		return order
	end

	local unitOptions = {
	}
	
	for k, v in pairs(units) do
		unitOptions[k] = {
			type = "group",
			name = k,
			get = function(info)				
				local unit = info[#info-1]
				local unitDB = plugin.db.profile.Units[unit]
				return mUI.AceGUIGet(unitDB, info)
			end,
			set = function(info, ...)
				local unit = info[#info-1]
				local unitDB = plugin.db.profile.Units[unit]
				mUI.AceGUISet(unitDB, info, ...)
			end,
			args = {
				Enabled = {
					type = "toggle",
					name = "Enabled",
					order = newOrder(),
				},
				Layout = {
					type = "select",
					name = "Layout",
					order = newOrder(),
					values = function(info)
						local t = {}
						for layout, v in pairs(plugin.db.profile.Layouts) do						
							t[layout] = v.Name
						end
						return t
					end,
				},
				s1 = { type = "description", name = "", order = newOrder() },				
				X = { 
					type = "range", 
					name = "Horizontal position",
					order = newOrder(),
					softMin = -math.floor(GetScreenWidth() / 10) * 5,
					softMax = math.floor(GetScreenWidth() / 10) * 5,
					step = 1,
					bigStep = 5,
				},
				Y = { 
					type = "range", 
					name = "Vertical position",
					order = newOrder(),
					softMin = -math.floor(GetScreenHeight() / 10) * 5,
					softMax = math.floor(GetScreenHeight() / 10) * 5,
					step = 1,
					bigStep = 5,
				},
				s2 = { type = "description", name = "", order = newOrder() },
				SizeX = {
					type = "range",
					name = "Width multiplyer",
					order = newOrder(),
					softMin = 0.5,
					softMax = 2,
					isPercent = true,
					step = 0.01,
					bigStep = 0.05,
				},
				SizeY = {
					type = "range",
					name = "Height multiplyer",
					order = newOrder(),
					softMin = 0.5,
					softMax = 2,
					isPercent = true,
					step = 0.01,
					bigStep = 0.05,
				},
				s3 = { type = "description", name = "", order = newOrder() },
				Scale = {
					type = "range",
					name = "Scale",
					order = newOrder(),
					softMin = 0.5,
					softMax = 2,
					isPercent = true,
					step = 0.01,
					bigStep = 0.05,
				},
				FontScale = {
					type = "range",
					name = "Font scale",
					order = newOrder(),
					softMin = 0.5,
					softMax = 2,
					isPercent = true,
					step = 0.01,
					bigStep = 0.05,
				},
			},
		}
	end
	
	return unitOptions
end

function Options:GetLayoutOptions()
	local order = 1
	local function newOrder()
		order = order + 1
		return order
	end
	
	local CURRENT_LAYOUT = "Normal"
	local layoutOptions = {
		currentLayout = {
			type = "select",
			name = "Current layout",
			order = newOrder(),
			values = function(info)
				local t = {}
				for layout, v in pairs(plugin.db.profile.Layouts) do
					t[layout] = v.Name
				end
				return t
			end,
			get = function(info)
				return CURRENT_LAYOUT
			end,
			set = function(info, value)
				CURRENT_LAYOUT = value
			end
		},
		newLayout = {
			type = "input",
			name = "New layout",
			order = newOrder(),
		},
		sep1 = { type = "description", name = "", order = newOrder() },
		renameLayout = {
			type = "input",
			name = "Rename layout",
			get = function(info)
				local layoutDB = plugin.db.profile.Layouts[CURRENT_LAYOUT]
				return layoutDB.Name
			end,
			set = function(info, value)
				local layoutDB = plugin.db.profile.Layouts[CURRENT_LAYOUT]
				layoutDB.Name = value
			end,
		},
	}
	
	return layoutOptions
end

function plugin.defaultModulePrototype:SetOptions(func)
	if DEBUG then
		expect(func, "typeof", "function")		
		expect(moduleFullOptions[self], "==", nil)
	end
	
	moduleFullOptions[self] = func
end