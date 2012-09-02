local _, ns = ...

local _, ns = ...

local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local plugin = mUI:GetModule("Unitframes")

local db, gdb

local orders = {
	Buffs = 1,
	Debuffs = 2,
	Power = 3,
	Castbar = 4,
	Portrait = 5,
}

local function orderFunc(info)
	return orders[info[#info]]
end

plugin:AddDbUpdateCallback(function()
	db = plugin.db.profile
	gdb = mUI.db.profile
end)

plugin.AceGUIFrames = {
	["UIParent"] = "UIParent",
	["mUI_Player"] = "Player",
	["mUI_Target"] = "Target",
	["mUI_TargetTarget"] = "Target of Target",
	["mUI_Focus"] = "Focus",
	["mUI_FocusTarget"] = "Focus target",
	["mUI_Pet"] = "Pet",
	["mUI_PetTarget"] = "Pet target",
	["Health"] = "Part - Health",
	["Power"] = "Part - Power",
	["Portrait"] = "Part - Portrait",
	["Castbar"] = "Part - Castbar",
	["parentFrame"] = "Frame",
}

local EnabledOption = {
	order = 1,
	type = "toggle",
	name = "Enabled",
}

local GeneralPartOptions = {
	order = 1,
	type = "group",
	name = "General",
	inline = true,
	get = function(info)
		local d = plugin:GetUnitDB(info[#info - 3]).Parts[info[#info - 2]]
		return mUI.AceGUIGet(d, info)
	end,
	set = function(info, v1, v2, v3, v4)
		local d = plugin:GetUnitDB(info[#info - 3]).Parts[info[#info - 2]]
		mUI.AceGUISet(d, info, v1, v2, v3, v4)
		plugin:UpdateUnit(info[#info - 3])
	end,
	args = {
		Enabled = EnabledOption,
		h1 = { order = 2, type = "header", name = "Size",
			hidden = function(info)  
				local d = plugin:GetUnitDB(info[#info - 3]).Parts[info[#info - 2]]
				return d.HideWidth and d.HideHeight and not d.WidthAsFrame
			end,
		},
		Width = { order = 3, type = "range", name = "Width", min = 1, max = 1000, step = 1,
			hidden = function(info)  
				local d = plugin:GetUnitDB(info[#info - 3]).Parts[info[#info - 2]]
				return d.HideWidth or d.WidthAsFrame
			end,
		},
		Height = { order = 4, type = "range", name = "Height", min = 1, max = 1000,  step = 1,
			hidden = function(info)  
				local d = plugin:GetUnitDB(info[#info - 3]).Parts[info[#info - 2]]
				return d.HideHeight
			end,
		},
		
		Sep1 = { order = 10, type = "description", name = "" },
		
		WidthAsFrame = { order = 15, type = "toggle", name = "Width as frame", desc = "Set the width to the same as the frame" },
		WidthOffsetAsPercent = { order = 16, type = "toggle", name = "Width offset as %",
			hidden = function(info)  
				local d = plugin:GetUnitDB(info[#info - 3]).Parts[info[#info - 2]]
				return not d.WidthAsFrame
			end,
		},	
		WidthOffset = { order = 17, type = "range", name = "Width offset", min = -1000, max = 1000, step = 1,
			hidden = function(info)  
				local d = plugin:GetUnitDB(info[#info - 3]).Parts[info[#info - 2]]
				return not d.WidthAsFrame or d.WidthOffsetAsPercent
			end,
		},
		WidthOffsetPercent = { order = 17, type = "range", name = "Width offset %", min = 0.01, max = 4, step = 0.01, isPercent = true,
			hidden = function(info)  
				local d = plugin:GetUnitDB(info[#info - 3]).Parts[info[#info - 2]]
				return not d.WidthAsFrame or not d.WidthOffsetAsPercent
			end,
		},
		
		h2 = { order = 50, type = "header", name = "Position" },
		
		Point = { order = 56, type = "select", name = "Point", values = mUI.AceGUIPoints },
		RelPoint = { order = 57, type = "select", name = "Relative point", values = mUI.AceGUIPoints },
		Anchor = { order = 58, type = "select", name = "Anchor", values = plugin.AceGUIFrames },	
		
		d1 = { order = 59, type = "description", name = "" },
		X = { order = 60, type = "range", name = "X", min = -1000, max = 1000, step = 1 },
		Y = { order = 61, type = "range", name = "Y", min = -1000, max = 1000, step = 1 },
		SetFrameLevels = { order = 79, type = "toggle", name = "Set frame levels", },
		FrameStrata = { order = 80, type = "select", name = "Frame strata", values = mUI.AceGUIStrata,
			hidden = function(info)  
				local d = plugin:GetUnitDB(info[#info - 3]).Parts[info[#info - 2]]
				return not d.SetFrameLevels
			end,
		},
		FrameLevel = { order = 81, type = "range", name = "Frame level", min = 1, max = 250, step = 1,
			hidden = function(info)  
				local d = plugin:GetUnitDB(info[#info - 3]).Parts[info[#info - 2]]
				return not d.SetFrameLevels
			end,
		},
	},
}

local PortraitOptions = {
	type = "group",
	name = "Portrait",
	--inline = true,
	order = orderFunc,	
	args = {
		General = GeneralPartOptions,
		InFrame = { order = 10, type = "toggle", name = "In Frame", desc = "Show the portrait as part of the health bar", },
		InFrameSide = { order = 11, type = "select", name = "Side", values = mUI.AceGUIXDir, 
			hidden = function(info)
				local d = plugin:GetLayoutDB().Units[info[#info - 2]].Parts[info[#info - 1]]
				return not d.InFrame
			end,
		},
		Size = { order = 12, type = "range", name = "Size", min = 1, max = 200, step = 1,
			hidden = function(info)
				local d = plugin:GetLayoutDB().Units[info[#info - 2]].Parts[info[#info - 1]]
				return d.InFrame
			end,
		},
	},
}

local PowerbarOptions = {
	type = "group",
	name = "Power",
	--inline = true,
	order = orderFunc,
	args = {
		General = GeneralPartOptions,			
	},
}

local AltPowerbarOptions = {
	type = "group",
	name = "Alt Power",
	order = orderFunc,
	args = {
		General = GeneralPartOptions,
		ReplacePower = { type = "toggle", name = "Replace normal powerbar", },
	},
}

local CastbarOptions = {
	type = "group",
	name = "Castbar",
	--inline = true,
	args = {
		General = GeneralPartOptions,
		Icon = { type = "toggle", name = "Show icon", },
		IconSide = { type = "select", name = "Icon side", values = mUI.AceGUIXDir },
	},
}

local CPointsOptions = {
	type = "group",
	name = "Combo Points",
	--inline = true,
	args = {
		General = GeneralPartOptions,
		Spacing = { order = 10, type = "range", name = "Spacing", min = 0, max = 20, step = 1 },
	},
}

local AuraOptions = {
	XDir = { order = 3, type = "select", name = "Growth X", values = mUI.AceGUIXDir },
	YDir = { order = 4, type = "select", name = "Growth Y", values = mUI.AceGUIYDir },
	Rows = { order = 11, type = "range", name = "Rows", min = 1, max = 20, step = 1 },
	PerRow = { order = 12, type = "range", name = "Per row", min = 0, max = 20, step = 1 },		
	StartPoint = { order = 7, type = "select", name = "Start point", values = mUI.AceGUIPoints },		
	Spacing = { order = 8, type = "range", name = "Spacing", min = 0, max = 10, step = 1 },
	ShowTimerBar = { order = 14, type = "toggle", name = "Show timer bar" },
	TimerBarHeight = { order = 15, type = "range", name = "Timer bar height", min = 5, max = 30, step = 1 },
	UseFilter = { order = 16, type = "toggle", name = "Use filter" },
	FilterBlacklist = { order = 17, type = "toggle", name = "Filter as blacklist", desc = "If set as blacklist all spells not on list will be shown, else hidden." },
	Filters = {
		order = 18,
		type = "multiselect",
		name = "Filter",
		values = function()
			local ret = {}
			for i, v in pairs(db.Filters) do
				ret[i] = v.name
			end
			return ret
		end,
		set = function(info, key, value)
			local d = plugin:GetUnitDB(info[#info - 2]).Parts[info[#info - 1]]			
			d.Filters[key] = value
			plugin:UpdateUnit(info[#info - 2])
		end,
		get = function(info, key)
			local d = plugin:GetUnitDB(info[#info - 2]).Parts[info[#info - 1]]
			return d.Filters[key]
		end,
	},
}

local BuffsOptions = {
	type = "group",
	name = "Buffs",
	--inline = true,
	order = orderFunc,
	args = {	
		General = GeneralPartOptions,
	},
}

local DebuffsOptions = {
	type = "group",
	name = "Debuffs",
	--inline = true,
	order = orderFunc,
	args = {
		General = GeneralPartOptions,
	},
}

for i, v in pairs(AuraOptions) do
	BuffsOptions.args[i] = v
	DebuffsOptions.args[i] = v
end

local RuneBarOptions = {
	type = "group",
	name = "Runes",
	--inline = true,
	args = {
		General = GeneralPartOptions,
		Spacing = { type = "range", name = "Spacing", min = 0, max = 20, step = 1 },
	},
}

local generalUnitSettings = {
	type = "group",
	name = "General",
	guiInline = true,
	get = function(info)
		local d = plugin:GetUnitDB(info[#info - 2])		
		return mUI.AceGUIGet(d, info)
	end,
	set = function(info, v1, v2, v3, v4)
		local d = plugin:GetUnitDB(info[#info - 2])		
		mUI.AceGUISet(d, info, v1, v2, v3, v4)
		plugin:UpdateUnit(info[#info - 2])
	end,
	args = {
		Enabled = EnabledOption,
		h1 = { order = 2, type = "header", name = "Size" },
		Width = { order = 3, type = "range", name = "Width", min = 1, max = 1000, step = 1 },
		Height = { order = 4, type = "range", name = "Height", min = 1, max = 1000,  step = 1 },
		
		h2 = { order = 5, type = "header", name = "Position" },
		
		Point = { order = 6, type = "select", name = "Point", values = mUI.AceGUIPoints },
		RelPoint = { order = 7, type = "select", name = "Relative point", values = mUI.AceGUIPoints },
		Anchor = { order = 8, type = "select", name = "Anchor", values = plugin.AceGUIFrames },	
		
		d1 = { order = 9, type = "description", name = "" },
		X = { order = 10, type = "range", name = "X", min = -1000, max = 1000, step = 1 },
		Y = { order = 11, type = "range", name = "Y", min = -1000, max = 1000, step = 1 },
	},
}

local GeneralGroupSettings = {
	type = "group",
	name = "General",
	guiInline = true,
	get = function(info)
		local d = plugin:GetLayoutDB().Groups[info[#info - 2]]
		return mUI.AceGUIGet(d, info)
	end,
	set = function(info, v1, v2, v3, v4)
		local unit = info[#info - 2]
		local d = plugin:GetLayoutDB().Groups[unit]
		mUI.AceGUISet(d, info, v1, v2, v3, v4)
		plugin:UpdateGroup(unit)
	end,
	args = {
		Spacing = { order = 50, type = "range", name = "Spacing", min = 0, max = 100, step = 1 },
	},
}

for i, v in pairs(generalUnitSettings.args) do
	GeneralGroupSettings.args[i] = v
end

local RaidGroupSettings = {
	type = "group",
	name = "General",
	guiInline = true,
	get = function(info)
		local d = plugin:GetLayoutDB().Groups[info[#info - 2]]
		return mUI.AceGUIGet(d, info)
	end,
	set = function(info, v1, v2, v3, v4)
		local unit = info[#info - 2]
		local d = plugin:GetLayoutDB().Groups[unit]
		mUI.AceGUISet(d, info, v1, v2, v3, v4)
		plugin:UpdateGroup(unit)
	end,
	args = {
		Enabled = EnabledOption,		
		
		h2 = { order = 5, type = "header", name = "Position" },		
		Point = { order = 6, type = "select", name = "Point", values = mUI.AceGUIPoints },
		RelPoint = { order = 7, type = "select", name = "Relative point", values = mUI.AceGUIPoints },
		d1 = { order = 9, type = "description", name = "" },
		X = { order = 10, type = "range", name = "X", min = -1000, max = 1000, step = 1 },
		Y = { order = 11, type = "range", name = "Y", min = -1000, max = 1000, step = 1 },
		
		d2 = { order = 20, type = "description", name = ""},
		Visibility = { type = "input", name = "Visibility", width = "full",},
		GroupBy = { type = "select", name = "Group By", values = {
				["GROUP"] = "Group",
				["CLASS"] = "Class",
				["ROLE"] = "Role",
			},
		},
		GroupByGroup = { type = "input", name = "Group order", desc = "1,2,3,4,5,6,7,8", width = "full", },
		GroupByClass = {type = "input", name = "Class order", desc = "DEATHKNIGHT, DRUID, HUNTER, MAGE, PALADIN, PRIEST, SHAMAN, WARLOCK, WARRIOR", width = "full", },
		GroupByRole = { type = "input", name = "Role order", desc = "TANK, HEALER, DAMAGE", width = "full", },
		SortBy = { type = "select", name = "Sort by", values = {
				["INDEX"] = "Index",
				["NAME"] = "Name",
			},
		},
		SortOrder = { type = "select", name = "Sort order", values = {
				["ASC"] = "Ascending",
				["DESC"] = "Descending",
			},
		},
	},
}



local selectedFilter
do	-- Main unit frame settings
	local debugDisplaysVisible = false
	mUI.Options.args.modules.args.unitframes = {
		type = "group",
		name = "Unitframes",
		icon = [[Interface\ICONS\Spell_Fire_FelImmolation]],
		get = function(info)
			return db[info[#info]]
		end,
		set = function(info, value)
			db[info[#info]] = value
		end,
		args = {			
			Units = {
				type = "group",
				name = "Units",
				get = function(info)
					local d = plugin:GetLayoutDB().Units[info[#info - 2]].Parts[info[#info - 1]]
					return mUI.AceGUIGet(d, info)
				end,
				set = function(info, v1, v2, v3, v4)
					local d = plugin:GetLayoutDB().Units[info[#info - 2]].Parts[info[#info - 1]]
					mUI.AceGUISet(d, info, v1, v2, v3, v4)
					plugin:UpdateUnit(info[#info - 2])
				end,
				args = {
					player = { order = 1, name = "Player", type = "group",	args = {
							General = generalUnitSettings,	
						},
					},
					target = { order = 2, name = "Target", type = "group", args = {
							General = generalUnitSettings,
						},
					},
					targettarget = { order = 3, name = "Target of Target", type = "group", args = {
							General = generalUnitSettings,
						},
					},
					focus = { order = 4, name = "Focus", type = "group", args = {
							General = generalUnitSettings,
						},
					},
					focustarget = { order = 5, name = "Focus Target", type = "group", args = {
							General = generalUnitSettings,
						},
					},
					pet = { order = 5, name = "Pet", type = "group", args = {
							General = generalUnitSettings,
						},
					},
					pettarget = { order = 6, name = "Pet Target", type = "group", args = {
							General = generalUnitSettings,
						},
					},
				},
			},
			
			Groups = {
				type = "group",
				name = "Groups",
				get = function(info)
					local d = plugin:GetLayoutDB().Groups[info[#info - 2]].Parts[info[#info - 1]]
					return mUI.AceGUIGet(d, info)
				end,
				set = function(info, v1, v2, v3, v4)
					local d = plugin:GetLayoutDB().Groups[info[#info - 2]].Parts[info[#info - 1]]
					mUI.AceGUISet(d, info, v1, v2, v3, v4)
					plugin:UpdateGroup(info[#info - 2])
				end,
				args = {
					boss = { type = "group", name = "Boss frames", args = {
							General = GeneralGroupSettings,
						},						
					},
					raid25 = { type = "group", name = "Raid 25", args = {
							General = RaidGroupSettings,
						},
					},
				},
			},
			
			Colors = {
				type = "group",
				name = "Colors",
				get = function(info)
					return mUI.AceGUIGet(db.Colors[info[#info-1]], info)
				end,
				set = function(info, v1, v2, v3, v4)
					mUI.AceGUISet(db.Colors[info[#info-1]], info, v1, v2, v3, v4)
					plugin:UpdateAllFrames()
				end,
				args = {
					Power = {
						order = 1,
						type = "group",
						inline = true,
						name = "Powers",
						args = {
							MANA = {
								type = "color",
								name = "Mana"
							},
							RAGE = {
								type = "color",
								name = "Rage"
							},
							FOCUS = {
								type = "color",
								name = "Focus"
							},
							RUNIC_POWER = {
								type = "color",
								name = "Runic power"
							},
							ENERGY = {
								type = "color",
								name = "Energy"
							},
						},
					},
					Reaction = {
						order = 2,
						type = "group",
						inline = true,
						name = "Reaction",
						args = {
							BAD = {
								type = "color",
								name = "Bad"
							},
							GOOD = {
								type = "color",
								name = "Good"
							},
							NEUTRAL = {
								type = "color",
								name = "Neutral"
							},
						},
					},
					Other = {
						order = 3,
						type = "group",
						inline = true,
						name = "Other",
						args = {
							Health = {
								type = "color",
								name = "Health",
							},
							Tapped = {
								type = "color",
								name = "Tapped",
							},
							Disconnected = {
								type = "color",
								name = "Disconnected",
							},
							AltPower = {
								type = "color",
								name = "Alternative power",
							},
						},
					},
				},
			},
			FontSize = {
				type = "range",
				min = 1,
				max = 40,
				step = 1,
				name = "Font size",
			},
			DebugDisplay = {
				type = "execute",
				name = "Show/Hide debug displays",
				hidden = function() return not DEBUG end,
				func = function() 
					if debugDisplaysVisible then
						for i, v in pairs(plugin.DebugDisplays) do
							i:Hide()
						end
					else
						for i, v in pairs(plugin.DebugDisplays) do
							i:Show()
						end
					end
					debugDisplaysVisible = not debugDisplaysVisible
				end,
			},
			Filters = {
				type = "group",
				name = "Filters",
				args = {
					Add = {
						order = 1,
						type = "input",
						name = "Create",
						set = function(info, value)
							db.Filters[value].name = value
						end,
					},
					Delete = {
						order = 2,
						type = "select",
						name = "Remove",
						values = function()
							local ret = {}
							for i, v in pairs(db.Filters) do
								ret[i] = v.name
							end
							return ret
						end,
						set = function(info, name)
							db.Filters[name] = nil
						end,				
						confirm = function(info, name)
							return "Are you sure you want to delete the filter "..name.."?"
						end,
					},
					Select = {
						order = 3,
						type = "select",
						name = "Select",
						values = function()
							local ret = {}
							for i, v in pairs(db.Filters) do
								ret[i] = v.name
							end
							return ret
						end,
						set = function(info, name)
							selectedFilter = name
							plugin:UpdateFilterOptions()
						end,
						get = function()
							return selectedFilter
						end,
					},
					Filter = {
						order = 10,
						type = "group",
						name = "Filter",
						inline = true,
						args = {
						},
					},
				},
			},
		},
	}
end

do	-- Add options to each unit
	local class = select(2, UnitClass("player"))
	local partsPerUnit = {
		Power = {
			option = PowerbarOptions,
			name = "Power",
			"player", "target", "targettarget", "focus", "focustarget", "pet", "pettarget", "boss"
		},
		AltPowerBar = {
			option = AltPowerbarOptions,
			name = "AltPowerBar",
			"player", "target", "targettarget", "focus", "focustarget", "pet", "pettarget", "boss"
		},
		Portrait = {
			option = PortraitOptions,
			name = "Portrait",
			"player", "target", "targettarget", "focus", "focustarget", "pet", "pettarget", "boss"
		},
		Castbar = {
			option = CastbarOptions,
			name = "Castbar",
			"player", "target", "targettarget", "focus", "focustarget", "pet", "pettarget", "boss"
		},
		Buffs = {
			option = BuffsOptions,
			name = "Buffs",
			"player", "target", "targettarget", "focus", "focustarget", "pet", "pettarget", "boss"
		},
		Debuffs = {
			option = DebuffsOptions,
			name = "Debuffs",
			"player", "target", "targettarget", "focus", "focustarget", "pet", "pettarget", "boss"
		},
		CPoints = {
			name = "CPoints",
			option = CPointsOptions,
			"target",
		},		
	}
	
	if class == "DEATHKNIGHT" then
		partsPerUnit["Runes"] = {
			name = "Runes",
			option = RuneBarOptions,
			"player",
		}
	end
	
	local groups = {
		["boss"] = true,
		["raid25"] = true,
	}

	for partName, units in pairs(partsPerUnit) do
		for i, unit in ipairs(units) do
			local partHolder
			if groups[unit] then
				partHolder = mUI.Options.args.modules.args.unitframes.args.Groups.args[unit].args
			else
				partHolder = mUI.Options.args.modules.args.unitframes.args.Units.args[unit].args
			end
			partHolder[units.name] = units.option
		end
	end
end

do	-- Filter options
	local fdb
	local spells = {}
	function plugin:UpdateFilterOptions()
		if not selectedFilter then return end
		local filter = mUI.Options.args.modules.args.unitframes.args.Filters.args.Filter
		fdb = db.Filters[selectedFilter]
		filter.name = string.format("Filter: %s", fdb.name)
		
		filter.args.h1 = filter.args.h1 or {
			order = 2,
			type = "description",
			name = "",
		}
		filter.args.add = filter.args.add or {
			order = 3,
			type = "input",
			name = "Add spell",
			set = function(info, value)
				fdb.spells[value] = true
				plugin:UpdateFilterOptions()
			end,
		}
		filter.args.delete = filter.args.delete or {
			order = 4,
			type = "input",
			name = "Add spell",
			set = function(info, value)
				fdb.spells[value] = nil
				plugin:UpdateFilterOptions()
			end,
		}
		
		filter.args.spells = filter.args.spells or {
			order = 10,
			type = "group",
			inline = true,
			name = "Spells",
			get = function(info)
				return fdb.spells[info[#info]]
			end,
			set = function(info, value)
				fdb.spells[info[#info]] = value
			end,
			args = {
			},
		}
		
		wipe(filter.args.spells.args)
		wipe(spells)
		
		for i, v in pairs(fdb.spells) do
			tinsert(spells, i)
		end
		table.sort(spells)
		local c = 1
		for i, v in pairs(spells) do
			filter.args.spells.args[v] = {
				order = c,
				type = "toggle",
				name = v,
			}
			c = c + 1
		end
	end
end