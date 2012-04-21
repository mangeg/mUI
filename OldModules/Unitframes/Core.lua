local _, ns = ...

local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local plugin = mUI:NewModule("Unitframes", "AceEvent-3.0")

local LSM = LibStub("LibSharedMedia-3.0")

--local mult = 768 / string.match(GetCVar("gxResolution"), "%d+x(%d+)") / 0.711111111111111
local oUF = oUF
local db
local gdb
local layout

plugin.DBUpdates = {}
plugin.CreatedUnits = {}
plugin.CreatedGroups = {}
plugin.CreatedGroupsList = {}
plugin.CreatedHeaders = {}
plugin.HandledGroups = {}
plugin.UnitsToCreate = {}
plugin.GroupsToCreate = {}
plugin.HeadersToCreate = {}
plugin.Strings = {}
plugin.StatusBars = {}
plugin.DebugDisplays = {}

local function SpellName(spellID)
	local name = GetSpellInfo(spellID)
	return name
end

function plugin:OnInitialize()
	gdb = mUI.db.profile
	
	local partDefaults = {
		["**"] = {
			Enabled = true,
			Text = true,	
			TextFormat = "percent-hidefull",
			Point = "CENTER",
			RelPoint = "CENTER",
			Anchor = "Health",
			X = 0,
			Y = 0,
			FrameLevel = 10,
			FrameStrata = "LOW",
			SetFrameLevels = false,
			WidthAsFrame = true,
			WidthOffsetAsPercent = true,
			WidthOffsetPercent = 1,
			WidthOffset = -8,
			Width = 100,
			Height = 100,
		},
		Health = {
			Text = false,
		},
		Portrait = {
			Enabled = false,
			InFrame = true,
			InFrameSide = "LEFT",
			Size = 85,
			X = -1,
			Point = "TOPRIGHT",
			RelPoint = "TOPLEFT",
		},
		Power = {
			Height = 8,	
			X = -4,
			Point = "RIGHT",
			RelPoint = "BOTTOMRIGHT",
			ShowAlternatePower = true,
			SetFrameLevels = true,
		},
		Castbar = {
			Height = 30,
			Icon = true,
			IconSide = "LEFT",
			Color = gdb.Colors.StatusBarColor,			
			Anchor = "parentFrame",
			Point = "TOP",
			RelPoint = "BOTTOM",
			Y = -5,
		},
		CPoints = {
			Height = 8,
			Spacing = 8,
			Anchor = "parentFrame",
			WidthOffsetAsPercent = false,
			WidthOffset = -8,
			Point = "CENTER",
			RelPoint = "TOP",
		},
		RaidIcon = {
			RelPoint = "TOP",
			Size = 15,
		},
		Buffs = {
			HideHeight = true,
			Rows = 2,
			PerRow = 8,
			Width = 270,
			Anchor = "parentFrame",
			Point = "BOTTOMLEFT",
			RelPoint = "TOPLEFT",
			StartPoint = "BOTTOMLEFT",
			XDir = "RIGHT",
			YDir = "UP",
			X = 0,
			Y = 15,									
			Spacing = 1,
			ShowTimerBar = true,
			TimerBarHeight = 6,
			UseFilter = true,
			FilterBlacklist = true,
			ShowPersonal = false,
			Filters = {										
			},
		},
		Debuffs = {
			HideHeight = true,
			Rows = 3,
			PerRow = 3,
			Width = 180,
			Anchor = "parentFrame",
			Point = "BOTTOMRIGHT",
			RelPoint = "TOPLEFT",
			StartPoint = "BOTTOMRIGHT",
			XDir = "LEFT",
			YDir = "UP",
			X = -4,
			Y = 15,
			WidthAsFrame = false,
			Spacing = 1,
			ShowTimerBar = true,
			TimerBarHeight = 6,
			UseFilter = true,
			FilterBlacklist = true,
			ShowPersonal = false,
			Filters = {										
			},
		},
		
		AltPowerBar = {
			Height = 8,
			Point = "BOTTOM",
			RelPoint = "BOTTOM",	
			Y = 2,
			ReplacePower = true,
			WidthAsFrame = true,
			WidthOffsetAsPercent = false,
			WidthOffset = -4,
			SetFrameLevels = true,
		},
		
		Runes = {
			Height = 8,
			Spacing = 8,
			Anchor = "parentFrame",
			RelPoint = "TOP",
			WidthAsFrame = true,
		},
	}
	
	local defaults = {
		profile = {
			FontSize = 12,
			
			MainSpecc = "Primary",
			
			Colors = {			
				Other = {
					Health = gdb.Colors.BorderColor,
					Tapped = { 0.55, 0.57, 0.61 },
					Disconnected = { 0.84, 0.75, 0.65} ,
					AltPower = { 1, 0, 0 },
				},
				Power = {
					["MANA"] = { 0.31, 0.45, 0.63 },
					["RAGE"] = { 0.78, 0.25, 0.25 },
					["FOCUS"] = { 0.71, 0.43, 0.27 },
					["ENERGY"] = { 0.65, 0.63, 0.35 },
					["RUNIC_POWER"] = { 0, 0.82, 1 },
				},
				Reaction = {
					["BAD"] = { 0.78, 0.25, 0.25 },
					["NEUTRAL"] = { 218/255, 197/255, 92/255 },
					["GOOD"] = { 75/255, 175/255, 76/255 },
				},
			},
			
			Filters = {
				["**"] = {
					spells = {					
					},
					name = "Unknown",
				},
				ProtBuffs = {
					name = "Saving buffs",
					spells = {
						[SpellName(33206)] = true, -- Pain Suppression
						[SpellName(47788)] = true, -- Guardian Spirit	
						[SpellName(1044)] = true, -- Hand of Freedom
						[SpellName(1022)] = true, -- Hand of Protection
						[SpellName(1038)] = true, -- Hand of Salvation
						[SpellName(6940)] = true, -- Hand of Sacrifice
						[SpellName(62618)] = true, --Power Word: Barrier
						[SpellName(70940)] = true, -- Divine Guardian 	
						[SpellName(53480)] = true, -- Roar of Sacrifice
					},
				},
				RaidDebuffs = {
					name = "Raid debuffs",
					spells = {
						--Firelands	
							--Beth'tilac
							[SpellName(99506)] = true, -- Widows Kiss
							
							--Alysrazor
							[SpellName(101296)] = true, -- Fiero Blast
							[SpellName(100723)] = true, -- Gushing Wound
							
							--Shannox
							[SpellName(99837)] = true, -- Crystal Prison
							[SpellName(99937)] = true, -- Jagged Tear
							
							--Baleroc
							[SpellName(99403)] = true, -- Tormented
							[SpellName(99256)] = true, -- Torment
							
							--Lord Rhyolith
								--<< NONE KNOWN YET >>
							
							--Majordomo Staghelm
							[SpellName(98450)] = true, -- Searing Seeds
							[SpellName(98565)] = true, -- Burning Orb
							
							--Ragnaros
							[SpellName(99399)] = true, -- Burning Wound
								
							--Trash
							[SpellName(99532)] = true, -- Melt Armor
						
						-- Dragon Soul
							-- Madness of Deathwing
							[SpellName(106444)] = true, -- Impale
					},					
				},
				BossDebuffs = {
					name = "Boss debuffs",
					spells = {
					},
				},
				FocusBuffs = {
					name = "Focus buffs",
					spells = {
					},
				},
				FocusDebuffs = {
					name = "Focus debuffs",
					spells = {
					},
				},
			},
			
			Layouts = {
				["**"] = {
					Units = {
						["**"] = {
							Enabled = true,
							Width = 250,
							Height = 50,
							X = -105,
							Y = -250,
							POINT = "RIGHT",
							RELPOINT = "CENTER",
							Anchor = "UIParent",
							Point = "RIGHT",
							RelPoint = "CENTER",							
							
							Parts = partDefaults
						},
						
						player = {
							Parts = {
								Castbar = {
									IconSide = "RIGHT",
								},
								Portrait = {
									Enabled = true,	
									InFrame = false,									
								},
								Power = {
									WidthOffsetPercent = 0.6,
								},
								RaidIcon = {
									RelPoint = "RIGHT",
								},
								AltPowerBar = {
									ReplacePower = false,
									FrameLevel = 12,
								},
								Buffs = {
									FilterBlacklist = false,
								},
								Runes = {
									WidthOffsetAsPercent = false,
									WidthOffset = -8,
								},
							},
						},
						
						target = {
							X = 105,
							Point = "LEFT",
							Parts = {
								Power = {
									X = 4,
									Point = "LEFT",
									RelPoint = "BOTTOMLEFT",
									SizeAsFrame = true,	
									WidthOffsetPercent = 0.6,								
								},
								AltPowerBar = {
									ReplacePower = false,
									FrameLevel = 12,
								},
								Portrait = {
									Enabled = true,
									InFrame = false,
									InFrameSide = "RIGHT",
									X = 1,
									Point = "TOPLEFT",
									RelPoint = "TOPRIGHT",
								},
								RaidIcon = {
									RelPoint = "LEFT",
								},
								Buffs = {
									Rows = 3,
									PerRow = 6,
									Width = 200,
									Point = "BOTTOMLEFT",
									RelPoint = "TOPRIGHT",
									StartPoint = "BOTTOMLEFT",
									XDir = "RIGHT",
									YDir = "UP",
									X = 4,
									Y = 10,
									Spacing = 1,
									WidthAsFrame = false,
								},
								Debuffs = {
									Rows = 2,
									PerRow = 8,
									Width = 270,
									Point = "BOTTOMLEFT",
									RelPoint = "TOPLEFT",
									StartPoint = "BOTTOMLEFT",
									XDir = "RIGHT",
									YDir = "UP",
									X = 0,
									Y = 10,
									Spacing = 1,
									WidthAsFrame = true,
								},
								CPoints = {
									Enabled = true,									
								},
							},
						},
						
						targettarget = {
							Width = 150,
							Height = 30,
							X = 0,
							Point = "CENTER",
							
							Parts = {
								Power = {
									Height = 6,
									WidthAsFrame = true,
									WidthOffsetAsPercent = false,
									X = -4,
									WidthOffset = -8
								},
								Castbar = {
									Height = 15,
								},
								Buffs = {
									Enabled = false,
								},
								Debuffs = {
									Rows = 1,
									PerRow = 4,
									Width = 150,
									Point = "BOTTOMLEFT",
									RelPoint = "TOPLEFT",
									StartPoint = "BOTTOMLEFT",
									XDir = "RIGHT",
									YDir = "UP",
									X = 0,
									Y = 5,
									Spacing = 1,
									WidthAsFrame = true,
								},
							},
						},		
						
						focus = {
							Width = 155,
							Height = 25,
							X = 0,
							Y = -40,
							Anchor = "mUI_Target",
							Point = "TOPRIGHT",
							RelPoint = "BOTTOMRIGHT",
							Parts = {
								Power = {
									Height = 6,
									WidthOffsetAsPercent = false,
								},
								Castbar = {
									Height = 20,
								},
								Buffs = {
									X = -1,
									Y = 0,
									Rows = 1,
									PerRow = 4,
									Width = 102,
									Point = "TOPRIGHT",
									RelPoint = "TOPLEFT",
									StartPoint = "BOTTOMRIGHT",
									XDir = "LEFT",
									YDir = "UP",
									Spacing = 1,
									TimerBarHeight = 5,
									
									FilterBlacklist = false,
									Filters = {
										FocusBuffs = true
									},
									WidthAsFrame = false,
								},
								Debuffs = {
									X = 1,
									Y = 0,
									Rows = 1,
									PerRow = 4,
									Width = 102,
									Point = "TOPLEFT",
									RelPoint = "TOPRIGHT",
									StartPoint = "BOTTOMLEFT",
									XDir = "RIGHT",
									YDir = "UP",
									Spacing = 1,
									TimerBarHeight = 5,
									
									FilterBlacklist = false,
									Filters = {
										FocusDebuffs = true
									},
									WidthAsFrame = false,
								},
							},							
						},
						
						focustarget = {
							Width = 155,
							Height = 25,
							X = 0,
							Y = -30,
							Anchor = "mUI_Focus",
							Point = "TOPRIGHT",
							RelPoint = "BOTTOMRIGHT",
							Parts = {
								Power = {
									Height = 6,
									WidthOffsetAsPercent = false,
								},
								Castbar = {
									Height = 20,
								},
								Buffs = {
									X = -1,
									Y = 0,
									Rows = 1,
									PerRow = 4,
									Width = 102,
									Point = "TOPRIGHT",
									RelPoint = "TOPLEFT",
									StartPoint = "BOTTOMRIGHT",
									XDir = "LEFT",
									YDir = "UP",
									Spacing = 1,
									TimerBarHeight = 5,
									
									FilterBlacklist = false,
									Filters = {
										FocusBuffs = true
									},
									WidthAsFrame = false,
								},
								Debuffs = {
									X = 1,
									Y = 0,
									Rows = 1,
									PerRow = 4,
									Width = 102,
									Point = "TOPLEFT",
									RelPoint = "TOPRIGHT",
									StartPoint = "BOTTOMLEFT",
									XDir = "RIGHT",
									YDir = "UP",
									Spacing = 1,
									TimerBarHeight = 5,
									
									FilterBlacklist = false,
									Filters = {
										FocusDebuffs = true
									},
									WidthAsFrame = false,
								},
							},							
						},
						
						pet = {
							Width = 155,
							Height = 25,
							X = 0,
							Y = -40,
							Anchor = "mUI_Player",
							Point = "TOPLEFT",
							RelPoint = "BOTTOMLEFT",
							Parts = {
								Power = {
									Height = 6,
									WidthOffsetAsPercent = false,
								},
								Castbar = {
									Height = 20,
								},
								Buffs = {
									X = -1,
									Y = 0,
									Rows = 1,
									PerRow = 4,
									Width = 100,
									Point = "TOPRIGHT",
									RelPoint = "TOPLEFT",
									StartPoint = "BOTTOMRIGHT",
									XDir = "LEFT",
									YDir = "UP",
									Spacing = 1,
									
									WidthAsFrame = false,
								},
								Debuffs = {
									X = 1,
									Y = 0,
									Rows = 1,
									PerRow = 4,
									Width = 100,
									Point = "TOPLEFT",
									RelPoint = "TOPRIGHT",
									StartPoint = "BOTTOMLEFT",
									XDir = "RIGHT",
									YDir = "UP",
									Spacing = 1,
									
									WidthAsFrame = false,
								},
							},	
						},
						
						pettarget = {
							Width = 155,
							Height = 25,
							X = 0,
							Y = -30,
							Anchor = "mUI_Pet",
							Point = "TOPLEFT",
							RelPoint = "BOTTOMLEFT",
							Parts = {
								Power = {
									Height = 6,
									WidthOffsetAsPercent = false,
								},
								Castbar = {
									Height = 20,
								},
								Buffs = {
									X = -1,
									Y = 0,
									Rows = 1,
									PerRow = 4,
									Width = 100,
									Point = "TOPRIGHT",
									RelPoint = "TOPLEFT",
									StartPoint = "BOTTOMRIGHT",
									XDir = "LEFT",
									YDir = "UP",
									Spacing = 1,
									
									WidthAsFrame = false,
								},
								Debuffs = {
									X = 1,
									Y = 0,
									Rows = 1,
									PerRow = 4,
									Width = 100,
									Point = "TOPLEFT",
									RelPoint = "TOPRIGHT",
									StartPoint = "BOTTOMLEFT",
									XDir = "RIGHT",
									YDir = "UP",
									Spacing = 1,
									
									WidthAsFrame = false,
								},
							},	
						},
					},
					
					Groups = {
						["**"] = {
							Enabled = true,
							Width = 220,
							Height = 35,
							X = 0,
							Y = 0,
							Point = "CENTER",
							RelPoint = "CENTER",
							Anchor = "UIParent",
							GrowDirection = "UP",
							Spacing = 35,
							
							Parts = partDefaults,
							
							Visibility = "",
							GroupBy = "GROUP",
							GroupByClass = "DEATHKNIGHT, DRUID, HUNTER, MAGE, PALADIN, PRIEST, SHAMAN, WARLOCK, WARRIOR",
							GroupByRole = "TANK, HEALER, DAMAGE",
							GroupByGroup = "1,2,3,4,5,6,7,8",
							SortBy = "INDEX",
							SortOrder = "ASC",
						},
						boss = {
							Point = "RIGHT",
							RelPoint = "RIGHT",
							X = -220,
							Y = -15,
							
							Parts = {
							
								Power = {
									WidthOffsetAsPercent = false,
								},
								Castbar = {
									Height = 25,
									Y = -6,
								},
								
								Portrait = {
									Enabled = true,
								},
								
								Buffs = {
									X = -1,
									Y = 0,
									Width = 215,
									XDir = "LEFT",
									Point = "BOTTOMRIGHT",
									RelPoint = "BOTTOMLEFT",
									StartPoint = "BOTTOMRIGHT",
									PerRow = 6,		
									Rows = 1,									
									
									WidthAsFrame = false,
								},
								
								Debuffs = {
									X = 1,
									Y = 0,
									Width = 215,
									XDir = "RIGHT",
									Point = "BOTTOMLEFT",
									RelPoint = "BOTTOMRIGHT",
									StartPoint = "BOTTOMLEFT",
									PerRow = 6,
									Rows = 1,
									
									WidthAsFrame = false,
									
									FilterBlacklist = false,
									Filters = {
										["BossDebuffs"] = true,
									},
								},
							},
						},
						
						raid25 = {
							
							Visibility = "[@raid1,exists] show;hide",
							
							Parts = {
								Power = {
									WidthOffsetAsPercent = false,
								},
							},
						},
					},
				},
			},
			
			UnitLayout = {
				["**"] = {
				},
			},
			
			HeaderLayout = {
				["**"] = {
					X = 0,
					Y = 0,
					Point = "CENTER",
					RelPoint = "CENTER",
					Scale = 1,
					
					Formations = {
						
					},
					
					Filtering = {
					},					
				},
			},
		},
	}	

	self.db = mUI.db:RegisterNamespace(self:GetName(), defaults)
	defaults = nil
	
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")		
	
	db = self.db.profile
	layout = db.Layouts[db.MainSpecc]
	
	for i, func in pairs(self.DBUpdates) do
		func()
	end
	
	oUF:RegisterStyle("mUIUF", function(frame, unit)
		plugin:CreateUF(frame, unit)
	end)
	
	self:LoadUnits()
end

function plugin:OnEnable()
	mUI.RegisterCallback(self, "GlobalsChanged")
end

function plugin:ProfileChanged()
	db = self.db.profile
	gdb = mUI.db.profile
	layout = db.Layouts[db.MainSpecc]
	
	for unit, frame in pairs(self.CreatedUnits) do
		frame.db = layout.Units[unit]
	end
	
	for group, frames in pairs(self.CreatedGroupsList) do
		for i, frame in pairs(frames) do
			frame.db = layout.Groups[group]
		end
	end
	
	for i, func in pairs(self.DBUpdates) do
		func()
	end
	
	self:GlobalsChanged()
end

function plugin:PLAYER_REGEN_ENABLED()
	self:UpdateAllFrames()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function plugin:AddDbUpdateCallback(callback)
	if DEBUG then
		expect(callback, "typeof", "function")
	end
	
	tinsert(self.DBUpdates, callback)
end

local function UnitframeEnter(self)
	self:UpdateAllElements()
end

function plugin:CreateUF(frame, unit)
	frame:RegisterForClicks("AnyUp")
	frame:SetScript("OnEnter", UnitFrame_OnEnter)
	frame:SetScript("OnLeave", UnitFrame_OnLeave)	
	
	frame.menu = plugin.SpawnMenu
	
	frame.colors = oUF.colors
	
	frame:SetFrameLevel(5)
	
	if not self.HandledGroups[unit] then
		local stringTitle = self:TitleString(unit)
		self[("CreateUnit_%s"):format(stringTitle)](self, frame, unit)
	else
		local funcName = ("Create%sFrames"):format(self:TitleString(self.HandledGroups[unit]))
		self[funcName](self, frame, unit)
	end
		
	frame:HookScript("OnEnter", UnitframeEnter)
	frame:HookScript("OnLeave", UnitframeEnter)
	
	self:UpdateStatusBars()
	self:UpdateStrings()	
	return frame
end

function plugin:UpdateStrings()
	for str, _ in pairs(self.Strings) do
		local font, size, flags = str:GetFont()		
		local oldScale = str.oldScale or gdb.Fonts.Scale
		str:SetFont(mUI.Media.NormalFont, size / oldScale * gdb.Fonts.Scale, flags)
		str.oldScale = gdb.Fonts.Scale
	end
end

function plugin:UpdateStatusBars()
	for bar, _ in pairs(self.StatusBars) do
		bar:SetStatusBarTexture(mUI.Media.StatusBarTexture)
	end
end

function plugin:CreateAndUpdateUF(unit)
	if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end
	
	local db = db.Layouts[db.MainSpecc].Units[unit]
	self:UpdateColors()
	
	local frame = self.CreatedUnits[unit]
	if db.Enabled then		
		if not self.CreatedUnits[unit] then
			frame = oUF:Spawn(unit, ("mUI_%s"):format(self:TitleString(unit)))
			frame.db = db
			self.CreatedUnits[unit] = frame
		end
		frame:Enable()
	else
		if frame then
			frame:Disable()
		end
	end
end

function plugin:CreateAndUpdateGroupUF(group, numGroup)
	if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end	
	
	local db = self:GetLayoutDB().Groups[group]
	
	for i = 1, numGroup do
		local unit = group..i
		local frame = self.CreatedGroups[unit]
		if db.Enabled then
			if not frame then
				self.CreatedGroupsList[group] = self.CreatedGroupsList[group] or {}
				self.HandledGroups[unit] = group;
				frame = oUF:Spawn(unit, ("mUI_%s"):format(self:TitleString(unit)))
				frame.index = i
				frame.groupType = group
				frame.db = db
				self.CreatedGroups[unit] = frame				
				tinsert(self.CreatedGroupsList[group], frame)
			end
			frame:Enable()
		elseif frame then
			frame:Disable()
		end
	end
end

function plugin:CreateAndUpdateGroupHeader(group)
	if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end	
	
	local db = self:GetLayoutDB().Groups[group]
	
	local header = self.CreatedHeaders[group]
	if db.Enabled then
		local str = self:TitleString(group)
		local style = ("mUI_%s"):format(str)
		if not header then			
			oUF:RegisterStyle(style, self[("Create%sFrames"):format(str)])
			oUF:SetActiveStyle(style)
			header = oUF:SpawnHeader(style, nil, nil, 
				"point", "CENTER", 
				"oUF-initialConfigFunction", ([[self:SetWidth(%d); self:SetHeight(%d); self:SetFrameLevel(5)]]):format(db.Width, db.Height))
			header.groupName = group
			
			self.CreatedHeaders[group] = header
		end
		
		self[("Update%sHeader"):format(str)](self, header, db)
		
		for i=1, header:GetNumChildren() do
			local child = select(i, header:GetChildren())
			self[("Update%sFrames"):format(str)](self, child, db)
		end
	elseif header then
		header:SetAttribute("showParty", false)
		header:SetAttribute("showRaid", false)
		header:SetAttribute("showSolo", false)
	end
end

function plugin:LoadUnits()
	for _, unit in pairs(self.UnitsToCreate) do
		self:CreateAndUpdateUF(unit)
	end
	for group, num in pairs(self.GroupsToCreate) do
		self:CreateAndUpdateGroupUF(group, num)
	end
	for header in pairs(self.HeadersToCreate) do
		self:CreateAndUpdateGroupHeader(header)
	end
	
	self.UnitsToCreate = nil
	self.GroupsToCreate = nil
	self.HeadersToCreate = nil
	
	self:UpdateAllFrames()	
	
	local str = "mUI_%s%d"
	
	for i = 1, MAX_BOSS_FRAMES do
		local f = str:format("Boss", i)
		--_G[f]:Show()
		--_G[f].Hide = function() end
		--_G[f].unit = "player"
	end
end

function plugin:UpdateAllFrames()
	if InCombatLockdown() then return end
	self:UpdateColors()
	for unit, frame in pairs(self.CreatedUnits) do
		self:UpdateUnit(unit)
	end
	for unit, frame in pairs(self.CreatedGroups) do
		self:UpdateGroup(self.HandledGroups[unit])
	end
	for unit, header in pairs(self.CreatedHeaders) do
		self:UpdateHeader(unit)
	end	
	
	self:UpdateStatusBars()
	self:UpdateStrings()
end

function plugin:UpdateUnit(unit)
	if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end
	
	self:UpdateColors()
	if self.CreatedHeaders[unit] then
		self:UpdateHeader(unit)
	elseif self.CreatedGroupsList[unit] then
		self:UpdateGroup(unit)
	else
		local frame = self.CreatedUnits[unit]
		if not frame then return end
		local db = db.Layouts[db.MainSpecc].Units[unit]
		if db.Enabled then
			frame:Enable()		
			local stringTile = self:TitleString(unit)
			self[("UpdateUnit_%s"):format(stringTile)](self, frame, db)
			frame:UpdateAllElements()
		else
			frame:Disable()
		end
	end
end

function plugin:UpdateGroup(group)
	if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end
	
	if self.CreatedHeaders[group] then
		self:UpdateHeader(group)
		return
	end
	
	if not self.CreatedGroupsList[group] then return end
	
	self:UpdateColors()
	local db = self:GetLayoutDB().Groups[group]	
	if db.Enabled then	
		for i, frame in pairs(self.CreatedGroupsList[group]) do
			frame:Enable()
			local str = self:TitleString(group)
			self[("Update%sFrames"):format(str)](self, frame, db)
		end
	else
		for i, frame in pairs(self.CreatedGroupsList[group]) do
			frame:Disable()
		end
	end
end

function plugin:UpdateHeader(group)
	local header = self.CreatedHeaders[group]
	local str = self:TitleString(group)
	local db = self:GetLayoutDB().Groups[group]
	if db.Enabled then
		for i=1, header:GetNumChildren() do
			local frame = select(i, header:GetChildren())
			frame:UpdateAllElements()
			if frame and frame.unit then
				plugin[("Update%sFrames"):format(str)](self, frame, db)
			end
		end	
		plugin[("Update%sHeader"):format(str)](self, header, db)
	elseif header then
		header:SetAttribute("showParty", false)
		header:SetAttribute("showRaid", false)
		header:SetAttribute("showSolo", false)
	end
end

function plugin:TitleString(str)
	str = str:gsub("(.)", string.upper, 1)
	if str:find("target") then
		str = gsub(str, "target", "Target")
	end
	return str
end

function plugin:GlobalsChanged()
	self:UpdateAllFrames()
	self:UpdateStatusBars()
	self:UpdateStrings()
end

function plugin:UpdateColors()
	local db = db.Colors
	local tapped = db.Other.Tapped
	local dc = db.Other.Disconnected
	local mana = db.Power.MANA
	local rage = db.Power.RAGE
	local focus = db.Power.FOCUS
	local energy = db.Power.ENERGY
	local runic = db.Power.RUNIC_POWER
	local good = db.Reaction.GOOD
	local bad = db.Reaction.BAD
	local neutral = db.Reaction.NEUTRAL
	local health = db.Other.Health
	
	oUF.colors = setmetatable({
		tapped = tapped,
		disconnected = dc,
		health = health,
		power = setmetatable({
			["MANA"] = mana,
			["RAGE"] = rage,
			["FOCUS"] = focus,
			["ENERGY"] = energy,
			["RUNES"] = {0.55, 0.57, 0.61},
			["RUNIC_POWER"] = runic,
			["AMMOSLOT"] = {0.8, 0.6, 0},
			["FUEL"] = {0, 0.55, 0.5},
			["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
			["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
		}, getmetatable(oUF.colors.power)),
		runes = setmetatable({
				[1] = {.69,.31,.31},
				[2] = {.33,.59,.33},
				[3] = {.31,.45,.63},
				[4] = {.84,.75,.65},
		}, getmetatable(oUF.colors.runes)),
		reaction = setmetatable({
			[1] = bad, -- Hated
			[2] = bad, -- Hostile
			[3] = bad, -- Unfriendly
			[4] = neutral, -- Neutral
			[5] = good, -- Friendly
			[6] = good, -- Honored
			[7] = good, -- Revered
			[8] = good, -- Exalted	
		}, getmetatable(oUF.colors.reaction)),
		class = setmetatable({
			["DEATHKNIGHT"] = gdb.Colors.ClassColors.DEATHKNIGHT,
			["DRUID"]       = gdb.Colors.ClassColors.DRUID,
			["HUNTER"]      = gdb.Colors.ClassColors.HUNTER,
			["MAGE"]        = gdb.Colors.ClassColors.MAGE,
			["PALADIN"]     = gdb.Colors.ClassColors.PALADIN,
			["PRIEST"]      = gdb.Colors.ClassColors.PRIEST,
			["ROGUE"]       = gdb.Colors.ClassColors.ROGUE,
			["SHAMAN"]      = gdb.Colors.ClassColors.SHAMAN,
			["WARLOCK"]     = gdb.Colors.ClassColors.WARLOCK,
			["WARRIOR"]     = gdb.Colors.ClassColors.WARRIOR,
		}, getmetatable(oUF.colors.class)),
		smooth = setmetatable({
			1, 0, 0,
			1, 1, 0,
			health[1], health[2], health[3],
		}, getmetatable(oUF.colors.smooth)),
		
	}, getmetatable(oUF.colors))
end

function plugin:GetLayoutDB(layout)
	return db.Layouts[layout or db.MainSpecc]
end

function plugin:GetUnitDB(unit)
	local layout = self:GetLayoutDB()
	if rawget(layout.Units, unit) then
		return layout.Units[unit]
	elseif rawget(layout.Groups, unit) then
		return layout.Groups[unit] 
	end
end

function plugin:ChangeVisibility(header, visibility)
	if(visibility) then
		local type, list = string.split(' ', visibility, 2)
		if(list and type == "custom") then
			RegisterAttributeDriver(header, "state-visibility", list)
		end
	end	
end

do
	--UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "CONVERT_TO_PARTY", "CONVERT_TO_RAID", "LEAVE", "CANCEL" };
	--UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
	--UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	--UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	--UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" };
	--UnitPopupMenus["RAID"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "RAID_TARGET_ICON", "SELECT_ROLE", "LOOT_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" };
	--UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
	--UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
	--UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
	--UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
	--UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }
end


