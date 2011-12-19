local _, ns = ...

local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local plugin = mUI:GetModule("Unitframes")
if not plugin then return end

local oUF = oUF

local _, class = UnitClass("player")
local CAN_HAVE_CLASSBAR = (class == "PALADIN" or class == "SHAMAN" or class == "DRUID" or class == "DEATHKNIGHT" or class == "WARLOCK")

function plugin:CreateUnit_Player(frame, unit)
	frame.Health = plugin:CreateHealthBar(frame, true, true, "RIGHT")
	frame.Power = plugin:CreatePowerBar(frame, true, true)
	frame.Portrait = plugin:CreatePortrait(frame)
	frame.Leader = frame:CreateTexture()
	frame.Assistant = frame:CreateTexture()
	frame.MasterLooter = frame:CreateTexture()
	frame.RaidIcon = frame:CreateTexture()
	frame.Combat = self:CreateCombatIndicator(frame)
	frame.Castbar = self:CreateCastbar(frame, "RIGHT")
	frame.AltPowerBar = self:CreateAlternatePowerBar(frame, true , true, "LEFT")
	
	frame.AltPowerBar.unit = unit
	
	frame.Buffs = self:Create_Buffs(frame)
	frame.Debuffs = self:Create_Debuffs(frame)
	
	if class == "DEATHKNIGHT" then
		frame.Runes = plugin:CreateResourceBar_DeathKnight(frame)
	end
	
end

function plugin:UpdateUnit_Player(frame, db)
	plugin:UpdateFrame(frame)
		--[[
		local gdb = mUI.db.profile	
		
		if db.Parts.Portrait.Enabled and db.Parts.Portrait.InFrame then
			CLASS_BAR_WIDTH = db.Width - 8 - db.Height
		else
			CLASS_BAR_WIDTH = db.Width
		end		
		
		-- Icons
		local leader = frame.Leader
		local assist = frame.Assistant
		local mlooter = frame.MasterLooter
		-----------------------------		
		leader:SetPoint("LEFT", frame, "BOTTOMLEFT", 4, 0 )
		if leader:IsShown() then			
			leader:SetSize(15, 15)
		else
			leader:SetSize(0.0001, 0.0001)
		end
		
		assist:SetPoint("LEFT", frame, "BOTTOMLEFT", 4, 0)
		if assist:IsShown() then			
			assist:SetSize(15, 15)
		else
			assist:SetSize(0.0001, 0.0001)
		end
		
		if mlooter:IsShown() then
			mlooter:SetPoint("LEFT", leader, "RIGHT", 2, 0)
			mlooter:SetSize(15, 15)
		else
			mlooter:SetSize(0.0001, 0.0001)
		end
		
		frame.RaidIcon:SetPoint("CENTER", frame, "RIGHT")
		frame.RaidIcon:SetSize(15, 15)
		
		local borderr, borderg, borderb
		local backr, backg, backb = unpack(gdb.Colors.BackdropColor)
		
		if gdb.Colors.ClassColoredBorders then						
			borderr, borderg, borderb = unpack(gdb.Colors.ClassColors[class])			
		else
			borderr, borderg, borderb = unpack(gdb.Colors.BorderColor)		
		end				
		
		-- Alt Power
		local altPower = frame.AltPowerBar
		-----------------------------
		self:CheckEnableState(frame, "AltPower")
		if db.Parts.AltPower.Enabled then
			local pdb = db.Parts.Power
			
			local ar, ag, ab = unpack(plugin.db.profile.Colors.Other.AltPower)
			local f = 0.2
			altPower:SetStatusBarColor(ar, ag, ab)
			altPower.bg:SetVertexColor(ar * f, ag * f, ab * f)
			
			altPower.backdrop:ClearAllPoints()
			altPower.backdrop:SetPoint("BOTTOM", power.backdrop, "TOP", 0, 2)
			altPower.backdrop:SetPoint("LEFT", frame, 4, 0)
			altPower.backdrop:SetPoint("RIGHT", frame, -4, 0)
			altPower.backdrop:SetHeight(8)
			altPower:SetFrameStrata("MEDIUM")	
			
			altPower.backdrop:SetBackdropColor(backr, backg, backb)		
			altPower.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
		end
		
		-- Portrait
		local portrait = frame.Portrait
		-----------------------------
		self:CheckEnableState(frame, "Portrait")
		if db.Parts.Portrait.Enabled then
			portrait.backdrop:SetBackdropColor(backr, backg, backb)
			portrait.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
			
			portrait.backdrop:ClearAllPoints()
			if db.Parts.Portrait.InFrame then				
				portrait.backdrop:SetPoint("TOPLEFT", frame)
				portrait.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", db.Height, 0)
			else
				portrait.backdrop:SetPoint("TOPRIGHT", frame, "TOPLEFT", -1, 0)				
				portrait.backdrop:SetSize(db.Parts.Portrait.Size, db.Parts.Portrait.Size)
			end
		end
		
		
		if db.Parts.Resource.Enabled then
			-- Resource bar
			-----------------------------
			self:CheckEnableState(frame, "Runes")
			if class == "DEATHKNIGHT" and db.Parts.Resource.Runes.Enabled then				
				local pdb = db.Parts.Resource.Runes
				local RUNE_SPACING = pdb.Spacing
				local NR_RUNES = 6
			
				local runes = frame.Runes
				runes:ClearAllPoints()
				runes:SetPoint("LEFT", frame, "TOPLEFT", pdb.Margin, 0)
				runes:SetFrameStrata("MEDIUM")			
				runes:SetWidth(CLASS_BAR_WIDTH)
				runes:SetHeight(pdb.Height)			
				
				for i = 1, 6 do
					runes[i].backdrop:SetHeight(runes:GetHeight())
					runes[i].backdrop:SetWidth((db.Width - (NR_RUNES - 1) * pdb.Spacing - pdb.Margin * 2) / NR_RUNES)
					
					runes[i].backdrop:ClearAllPoints()
					if i == 1 then
						runes[i].backdrop:SetPoint("LEFT", runes)
					else
						runes[i].backdrop:SetPoint("LEFT", runes[i-1].backdrop, "RIGHT", RUNE_SPACING, 0)
					end	
					
					runes[i].backdrop:SetBackdropColor(backr, backg, backb)
					runes[i].backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
					runes[i].backdrop:Show()					
				end
			end
		end
		
		
		-- Castbar
		local castbar = frame.Castbar
		-----------------------------
		self:CheckEnableState(frame, "Castbar")
		if db.Parts.Castbar.Enabled then
			local pdb = db.Parts.Castbar
			
			castbar.backdrop:SetHeight(pdb.Height)
			
			if db.CastbarLatency then
				castbar.SafeZone = castbar.LatencyTexture
				castbar.LatencyTexture:Show()
			else
				castbar.SafeZone = nil
				castbar.LatencyTexture:Hide()
			end
			
			castbar.backdrop:ClearAllPoints()
			castbar.backdrop:SetPoint("TOP", power.backdrop, "BOTTOM", 0, -1)
			if pdb.Icon then				
				castbar.Icon = castbar.ButtonIcon
				
				castbar.Icon.bg.backdrop:SetSize(pdb.Height, pdb.Height)								
				castbar.Icon.bg:Show()				
				
				castbar.backdrop:SetPoint("LEFT", frame)
				castbar.backdrop:SetPoint("RIGHT", frame, -pdb.Height - 1, 0)
				
				castbar.Icon.bg.backdrop:SetBackdropColor(backr, backg, backb)
				castbar.Icon.bg.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
			else			
				castbar.Icon = nil
				castbar.ButtonIcon.bg:Hide()
				castbar.backdrop:SetPoint("RIGHT", frame)
				castbar.backdrop:SetPoint("LEFT", frame)
			end
			
			castbar.backdrop:SetBackdropColor(backr, backg, backb)
			castbar.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
			
		end
		
		
		-- Buffs
		local buffs = frame.Buffs
		-----------------------------
		if db.Parts.Buffs.Enabled then
			local pdb = db.Parts.Buffs
			
			local yoffset = pdb.ShowTimerBar and pdb.TimerBarHeight + 2 or 0
			
			buffs:ClearAllPoints()
			buffs:SetPoint(pdb.Point, frame, pdb.RelPoint, pdb.XOffset, pdb.YOffset + yoffset)
			buffs:SetWidth(pdb.Width)
			
			buffs.spacing = pdb.Spacing
			local rows = pdb.Rows			
			
			buffs.num = pdb.PerRow * rows
			buffs.size = ((((buffs:GetWidth() - (buffs.spacing * (buffs.num/rows - 1))) / buffs.num)) * rows)

			buffs:SetHeight(buffs.size * rows)
			buffs.initialAnchor = pdb.StartPoint
			buffs["growth-y"] = pdb.YDir
			buffs["growth-x"] = pdb.XDir
			buffs["spacing-y"] = pdb.ShowTimerBar and pdb.Spacing + pdb.TimerBarHeight + 1 or nil

			buffs.timerbar = pdb.ShowTimerBar
			buffs.disableCooldown = pdb.ShowTimerBar
				
			buffs:Show()
			
			buffs.fontSize = buffs.size / 30 * 10
			
			for i, b in ipairs(buffs) do
				b:SetSize(buffs.size, buffs.size)
				b.text:SetFont(mUI.Media.NormalFont, buffs.fontSize, "OUTLINE")	
				b.count:SetFont(mUI.Media.NormalFont, buffs.fontSize, "OUTLINE")
				b.cd2.backdrop:SetHeight(pdb.TimerBarHeight)
			end
			buffs:ForceUpdate()
		else
			buffs:Hide()
		end
		
		-- Debuffs
		local debuffs = frame.Debuffs
		-----------------------------
		if db.Parts.Debuffs.Enabled then
			local pdb = db.Parts.Debuffs
			
			local yoffset = pdb.ShowTimerBar and pdb.TimerBarHeight + 2 or 0
			
			debuffs:ClearAllPoints()
			debuffs:SetPoint(pdb.Point, frame, pdb.RelPoint, pdb.XOffset, pdb.YOffset + yoffset)
			debuffs:SetWidth(pdb.Width)
			
			debuffs.spacing = pdb.Spacing
			local rows = pdb.Rows			
			
			debuffs.num = pdb.PerRow * rows
			debuffs.size = ((((debuffs:GetWidth() - (debuffs.spacing * (debuffs.num/rows - 1))) / debuffs.num)) * rows)

			debuffs:SetHeight(debuffs.size * rows)
			debuffs.initialAnchor = pdb.StartPoint
			debuffs["growth-y"] = pdb.YDir
			debuffs["growth-x"] = pdb.XDir
			debuffs["spacing-y"] = pdb.ShowTimerBar and pdb.Spacing + pdb.TimerBarHeight + 1 or nil

			debuffs.timerbar = pdb.ShowTimerBar
			debuffs.disableCooldown = pdb.ShowTimerBar
			
			debuffs:Show()
			
			debuffs.fontSize = debuffs.size / 30 * 10
			
			for i, b in ipairs(debuffs) do
				b:SetSize(debuffs.size, debuffs.size)
				b.text:SetFont(mUI.Media.NormalFont, debuffs.fontSize, "OUTLINE")
				b.count:SetFont(mUI.Media.NormalFont, debuffs.fontSize, "OUTLINE")				
				b.cd2.backdrop:SetHeight(pdb.TimerBarHeight)
			end
			debuffs:ForceUpdate()
		else
			debuffs:Hide()
		end
		
		if (not db.Parts.Debuffs.Enabled) and (not db.Parts.Buffs.Enabled) and frame:IsElementEnabled("Aura") then
			frame:DisableElement("Aura")
		elseif (not frame:IsElementEnabled("Aura")) then
			frame:EnableElement("Aura")
		end
		--]]
end

tinsert(plugin.UnitsToCreate, "player")