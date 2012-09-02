local name, mUI = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

Debug:AddGlobal("mUI", mUI)

local LSM = LibStub("LibSharedMedia-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")

local db

local defaults = {
	profile = {
		StatusBarTexture = LSM.DefaultMedia.statusbar,

		Fonts = {
			NormalFont = LSM.DefaultMedia.font,
			Scale = 1,
		},
			
		Colors = {
			ClassColoredBorders = true,
			
			StatusBarColor = {0.23, 0.23, 0.23},
			BorderColor = {0.23, 0.23, 0.23},
			BackdropColor = {0.07, 0.07, 0.07},
			
			ClassColors = {
				["DEATHKNIGHT"] = { 196/255,  30/255,  60/255 },
				["DRUID"]       = { 255/255, 125/255,  10/255 },
				["HUNTER"]      = { 171/255, 214/255, 116/255 },
				["MAGE"]        = { 104/255, 205/255, 255/255 },
				["PALADIN"]     = { 245/255, 140/255, 186/255 },
				["PRIEST"]      = { 212/255, 212/255, 212/255 },
				["ROGUE"]       = { 255/255, 243/255,  82/255 },
				["SHAMAN"]      = {  41/255,  79/255, 155/255 },
				["WARLOCK"]     = { 148/255, 130/255, 201/255 },
				["WARRIOR"]     = { 199/255, 156/255, 110/255 },
			},
		},
	},
}

for class, color in pairs(RAID_CLASS_COLORS) do
	local d = defaults.profile.Colors.ClassColors
	d[class][1] = color.r
	d[class][2] = color.g
	d[class][3] = color.b
	d[class][4] = color.a or 1
end

function mUI:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("mUIDB", defaults, "Default")
	defaults = nil
	
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
	
	self.Callbacks = LibStub("CallbackHandler-1.0"):New(self)	
	
	db = self.db.profile
	
	self:SetupLDB()
	
	self:UpdateMedia()
end

function mUI:OnEnable()
	AC:RegisterOptionsTable(name, self.Options)
	ACD:SetDefaultSize(name, DEFAULT_WIDTH, DEFAULT_HEIGHT)	
	self.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("mUIPorfiles", self.Options.args.profiles)
	self.Options.args.profiles.order = -10	
end

function mUI:ProfileChanged()
	db = self.db.profile
end

function mUI:ToggleConfig() 
	local mode = "Close"
	if not ACD.OpenFrames[name] then
		mode = "Open"
	end
	
	ACD[mode](ACD, name) 
	
	GameTooltip:Hide()
end

function mUI:SetupLDB()
	local LDB = LibStub("LibDataBroker-1.1", true)
	if not LDB then return end
	
	local l = LDB:NewDataObject(name)
	l.type = "launcher"
	l.icon = [[Interface\Icons\achievement_dungeon_throne of the tides]]
	l.OnClick = function(self, button)
		mUI:ToggleConfig()
	end
	l.OnTooltipShow = function(tt)
		tt:AddLine(name)
		tt:AddLine("Click to toggle configuration")
	end
	
	self.ldbojb = l
end

function mUI:UpdateMedia()
	self.Media.StatusBarTexture = LSM:Fetch("statusbar", db.StatusBarTexture)
	self.Media.NormalFont = LSM:Fetch("font", db.Fonts.NormalFont)
end

mUI.Media = {
	Blank = [[Interface\BUTTONS\WHITE8X8]],
}

local function TriggerOptionsChanged(name, ...)
	mUI:UpdateMedia()
	mUI.Callbacks:Fire("GlobalsChanged", name, ...)
end


mUI.Options = {
	type = "group",
	name = name,
	args = {
		general = {
			order = 1,
			type = "group",
			name = "General",
			get = function(info)
				return mUI.AceGUIGet(db, info)
			end,
			set = function(info, v1, v2, v3, v4)
				mUI.AceGUISet(db, info, v1, v2, v3, v4)
				TriggerOptionsChanged()
			end,
			args = {
				StatusBarTexture = {
					type = "select", dialogControl = "LSM30_Statusbar",
					name = "Statusbar texture",
					values = AceGUIWidgetLSMlists.statusbar,
				},
				Colors = {
					type = "group",
					name = "Colors",
					get = function(info)
						return mUI.AceGUIGet(db.Colors, info)
					end,
					set = function(info, r, g, b, a)
						mUI.AceGUISet(db.Colors, info, r, g, b, a)
						TriggerOptionsChanged()
					end,
					args = {
						ClassColoredBorders = {
							order = 1,
							type = "toggle",
							name = "Class colored borders",
							desc = "Will color all borders in your class color",
						},
						BorderColor = {
							order = 2,
							type = "color",
							name = "Border color",
							disabled = function() return db.ClassColoredBorders end,
						},
						BackdropColor = {
							order = 3,
							type = "color",
							name = "Backdrop color",
						},
						StatusBarColor = {
							order = 4,
							type = "color",
							name = "StatusBar color",
						},
						ClassColors = {
							type = "group",
							inline = true,
							name = "Class colors",
							get = function(info)
								return mUI.AceGUIGet(db.Colors.ClassColors, info)
							end,
							set = function(info, v1, v2, v3, v4)
								mUI.AceGUISet(db.Colors.ClassColors, info, v1, v2, v3, v4)
								TriggerOptionsChanged()
							end,
							args = {
								Reset = {
									type = "execute",
									name = "Reset",
									func = function(...)
										local d = db.Colors.ClassColors
										for class, color in pairs(RAID_CLASS_COLORS) do
											d[class][1] = color.r
											d[class][2] = color.g
											d[class][3] = color.b
											d[class][4] = color.a or 1
										end
										TriggerOptionsChanged()
									end,
									confirm = function() return "Reset class colors?" end,
								},
							},
						},
					},
				},
				Fonts = {
					type = "group",
					name = "Font",
					get = function(info)
						return mUI.AceGUIGet(db.Fonts, info)
					end,
					set = function(info, v1, v2, v3, v4)
						mUI.AceGUISet(db.Fonts, info, v1, v2, v3, v4)
						TriggerOptionsChanged()
					end,
					args = {
						NormalFont = {
							type = "select", dialogControl = "LSM30_Font",
							name = "Normal Font",
							values = AceGUIWidgetLSMlists.font,
						},
						Scale = {
							type = "range",
							name = "Scale",
							desc = "Scale all fonts with this value",
							min = 0.1,
							max = 5,
							step = 0.1
						},
					},
				},
			},
		},
		modules = {
			order = 10,
			type = "group",
			name = "Modules",
			args = {
			},
		}
	},
}

local classColorOptions = {
	type = "color",
	name = function(info) return LOCALIZED_CLASS_NAMES_MALE[info[#info]] end,
	order = 20,
	order = function(info) 
		for i, c in pairs(CLASS_SORT_ORDER) do
			if c == info[#info] then return i end
		end
	end,
}

for o, c in pairs(CLASS_SORT_ORDER) do
	mUI.Options.args.general.args.Colors.args.ClassColors.args[c] = classColorOptions
end