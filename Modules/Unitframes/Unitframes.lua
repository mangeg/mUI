local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local name, globalPlugin = ...
local plugin = mUI:NewModule("Unitframes", "AceEvent-3.0")
setmetatable(globalPlugin, {
	__index = plugin
})

local LSM = LibStub("LibSharedMedia-3.0")
local oUF = oUF

local db, gdb
local layout

local defaults = {
	Enabled = true,
	
	Layouts = {
		["**"] = {
			Name = "Normal",
			SizeX = 200,
			SizeY = 60,
			Scale = 1,
			Strata = "MEDIUM",
			Level = 1,
		},
		Normal = {},
	},
	
	Units = {
		["**"] = {
			Enabled = false,
			X = 0,
			Y = 0,
			SizeX = 1,
			SizeY = 1,
			FontScale = 1,
			Scale = 1,
			Layout = "Normal",
		},
		player = { Enabled = true },
		target = { Enabled = true },
		targettarget = { Enabled = true },
		focus = { Enabled = true },
		focustarget = { Enabled = true },
		pet = { Enabled = true },
		pettarget = { Enabled = true },
	},
	
	Groups = {
		["**"] = {
			Enabled = false,
			X = 0,
			Y = 0,
			SizeX = 1,
			SizeY = 1,
			FonstScale = 1,
			Scale = 1,
			Layout = "Normal",
			
			Sorting = "INDEX",
			SortDir = "ASC",
			VerticalSpacing = 10,
			HorizontalSpacing = 10,
			Direction = "DownRight",
			UnitsPerCol = MAX_RAID_MEMBERS,
			IncludePlayer = false,
			GroupFilter = nil,
			GroupBy = nil,
			
			UsePetHeader = nil,
		},
		
	},
	
	Colors = {
		Power = {},
		Reaction = {},
		Other = {
			Health = mUI.db.profile.Colors.Border,
			HalfHealth = {1, 1, 0},
			MinHealth = {1, 0, 0},
			Tapped = { 0.55, 0.57, 0.61 },
			Disconnected = { 0.84, 0.75, 0.65} ,
			AltPower = { 1, 0, 0 },
		},
	},
}

do -- Power and reaction color defaults
	for powerName, color in pairs(PowerBarColor) do
		if type(powerName) == "string" then
			if color.r then
				defaults.Colors.Power[powerName] = {color.r, color.g, color.b, color.a or 1}
			elseif powerName == "ECLIPSE" then
				local pos, neg = color.positive, color.negative
				if neg then
					defaults.Colors.Power["BALANCE_NEGATIVE_ENERGY"] = {neg.r, neg.g, neg.b, neg.a or 1}
				end
				if pos then
					defaults.Colors.Power["BALANCE_POSITIVE_ENERGY"] = {pos.r, pos.g, pos.b, pos.a or 1}
				end
			end
		end
	end
	defaults.Colors.Power["POWER_TYPE_PYRITE"] = { 0, 0.79215693473816, 1 }
	defaults.Colors.Power["POWER_TYPE_STEAM"] = { 0.94901967048645, 0.94901967048645, 0.94901967048645 }
	defaults.Colors.Power["POWER_TYPE_HEAT"] = { 1, 0.490019610742107, 0 }
	defaults.Colors.Power["POWER_TYPE_BLOOD_POWER"] = { 0.73725494556129, 0, 1 }
	defaults.Colors.Power["POWER_TYPE_OOZE"] = { 0.75686281919479, 1, 0 }
	for reaction, color in pairs(FACTION_BAR_COLORS) do
		defaults.Colors.Reaction[reaction..""] = {color.r, color.g, color.b, color.a or 1}
	end	
end

plugin:SetName("Unitframes")
plugin:SetDescription("Display unitframes, including raid, boss, assist and more")
plugin:SetDefaults(defaults)
db = plugin.db.profile

local function SpellName(spellID)	
	return (GetSpellInfo(spellID))
end

function plugin:OnInitialize()
end

function plugin:OnEnable()
	self:OnProfileChanged()
	self:UpdateColors()
end

function plugin:OnProfileChanged()
	db = self.db.profile
	gdb = mUI.db.profile	
	
	for unit, unitDB in pairs(db.Units) do
		if unitDB.Enabled then
			oUF:Spawn(unit)
		else
		end
	end
	
	self:LoadModules()
end

function plugin:UpdateColors()
	local db = db.Colors
	local tapped = db.Other.Tapped
	local dc = db.Other.Disconnected
	local health = db.Other.Health
	local halfHealth = db.Other.HalfHealth
	local minHealth = db.Other.MinHealth
	
	local reaction = db.Reaction
	local power = db.Power
	
	oUF.colors = setmetatable({
		tapped = tapped,
		disconnected = dc,
		health = health,
		power = setmetatable({
			["MANA"] = power["MANA"],
			["RAGE"] = power["RAGE"],
			["FOCUS"] = power["FOCUS"],
			["ENERGY"] = power["ENERGY"],
			["RUNES"] = power["RUNES"],
			["RUNIC_POWER"] = power["RUNIC_POWER"],
			["AMMOSLOT"] = power["AMMOSLOT"],
			["FUEL"] = power["FUEL"],
			["POWER_TYPE_STEAM"] = power["POWER_TYPE_STEAM"],
			["POWER_TYPE_PYRITE"] = power["POWER_TYPE_PYRITE"],
			["POWER_TYPE_HEAT"] = power["POWER_TYPE_HEAT"],
			["POWER_TYPE_OOZE"] = power["POWER_TYPE_OOZE"],
		}, getmetatable(oUF.colors.power)),
		runes = setmetatable({
				[1] = {.69,.31,.31},
				[2] = {.33,.59,.33},
				[3] = {.31,.45,.63},
				[4] = {.84,.75,.65},
		}, getmetatable(oUF.colors.runes)),
		reaction = setmetatable({
			[1] = reaction[1], -- Hated
			[2] = reaction[2], -- Hostile
			[3] = reaction[3], -- Unfriendly
			[4] = reaction[4], -- Neutral
			[5] = reaction[5], -- Friendly
			[6] = reaction[6], -- Honored
			[7] = reaction[7], -- Revered
			[8] = reaction[8], -- Exalted	
		}, getmetatable(oUF.colors.reaction)),
		class = setmetatable({
			["DEATHKNIGHT"] = gdb.Colors.Class.DEATHKNIGHT,
			["DRUID"]       = gdb.Colors.Class.DRUID,
			["HUNTER"]      = gdb.Colors.Class.HUNTER,
			["MAGE"]        = gdb.Colors.Class.MAGE,
			["PALADIN"]     = gdb.Colors.Class.PALADIN,
			["PRIEST"]      = gdb.Colors.Class.PRIEST,
			["ROGUE"]       = gdb.Colors.Class.ROGUE,
			["SHAMAN"]      = gdb.Colors.Class.SHAMAN,
			["WARLOCK"]     = gdb.Colors.Class.WARLOCK,
			["WARRIOR"]     = gdb.Colors.Class.WARRIOR,
		}, getmetatable(oUF.colors.class)),
		smooth = setmetatable({
			minHealth[1], minHealth[2], minHealth[3],
			halfHealth[1], halfHealth[2], halfHealth[3],
			health[1], health[2], health[3],
		}, getmetatable(oUF.colors.smooth)),
		
	}, getmetatable(oUF.colors))
end

local function CreateUnitFrame(frame, unit)
	--print(frame, frame:GetName(), unit)
end

oUF:RegisterStyle(("%s_"):format(name), CreateUnitFrame)

mUI:Modularize(name, plugin)
