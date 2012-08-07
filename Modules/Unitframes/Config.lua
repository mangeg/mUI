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
	"Modules", self:GetModuleOptions()
end)

local Options = {}
plugin.Options = Options

local units = {
	player = "Player",
	target = "Target",
	targettarget = "Target of Target",
	focus = "Focus",
	focustarget = "Focus target",
	pet = "Pet",
	pettarget = "Pet target",
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
			name = v,
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