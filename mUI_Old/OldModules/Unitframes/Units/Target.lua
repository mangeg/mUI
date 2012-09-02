local _, ns = ...

local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local plugin = mUI:GetModule("Unitframes")
if not plugin then return end

local oUF = oUF

local _, class = UnitClass("player")
local CAN_HAVE_CLASSBAR = (class == "PALADIN" or class == "SHAMAN" or class == "DRUID" or class == "DEATHKNIGHT" or class == "WARLOCK")

function plugin:CreateUnit_Target(frame, unit)
	frame.Health = self:CreateHealthBar(frame, true, true, "RIGHT")
	frame.Power = self:CreatePowerBar(frame, true, true)
	frame.Portrait = self:CreatePortrait(frame)
	frame.Castbar = self:CreateCastbar(frame, "LEFT")
	frame.AltPowerBar = self:CreateAlternatePowerBar(frame, true , true, "LEFT")
	frame.Name = self:CreateNameText(frame)
	frame.Leader = frame:CreateTexture()
	frame.Assistant = frame:CreateTexture()
	frame.MasterLooter = frame:CreateTexture()
	frame.RaidIcon = frame:CreateTexture()
	frame.CPoints = self:CreateCombobar(frame)
	--[[
	frame.Leader = frame:CreateTexture()
	frame.Assistant = frame:CreateTexture()
	frame.MasterLooter = frame:CreateTexture()
	frame.Name = self:CreateNameText(frame)
	frame.Castbar = self:CreateCastbar(frame, "LEFT")]]
	
	frame.Buffs = self:Create_Buffs(frame)
	frame.Debuffs = self:Create_Buffs(frame)
	
	frame.AltPowerBar.unit = unit
end

function plugin:UpdateUnit_Target(frame, db)
		plugin:UpdateFrame(frame)
		--[[
		
		local gdb = mUI.db.profile			
		
		local borderr, borderg, borderb
		local backr, backg, backb = unpack(gdb.Colors.BackdropColor)
		
		if gdb.Colors.ClassColoredBorders then						
			borderr, borderg, borderb = unpack(gdb.Colors.ClassColors[class])			
		else
			borderr, borderg, borderb = unpack(gdb.Colors.BorderColor)		
		end	
		
		frame:SetSize(db.Width, db.Height)
		frame:ClearAllPoints()
		frame:SetPoint(db.POINT, (db.Anchor and _G[db.Anchor]) or UIParent, db.RELPOINT, db.X, db.Y)
		
		-- Icons
		local leader = frame.Leader
		local assist = frame.Assistant
		local mlooter = frame.MasterLooter
		-----------------------------		
		if leader:IsShown() then
			leader:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -4, 0)
			leader:SetSize(15, 15)
		else
			leader:SetSize(0.0001, 0.0001)
		end
		
		if assist:IsShown() then
			assist:SetPoint("LEFT", frame, "BOTTOMRIGHT", -4, 0)
			assist:SetSize(15, 15)
		else
			assist:SetSize(0.0001, 0.0001)
		end
		
		if mlooter:IsShown() then
			local a
			if assist:IsShown() then a = assist else a = leader end
			mlooter:SetPoint("RIGHT", leader, "LEFT", -2, 0)
			mlooter:SetSize(15, 15)
		else
			mlooter:SetSize(0.0001, 0.0001)
		end
		
		frame.RaidIcon:SetPoint("CENTER", frame, "LEFT")
		frame.RaidIcon:SetSize(15, 15)
		
		-- Health
		local health = frame.Health
		-----------------------------
		self:CheckEnableState(frame, "Health")
		if db.Parts.Health.Enabled then	
			health.backdrop:ClearAllPoints()
			if db.Parts.Portrait.Enabled and db.Parts.Portrait.InFrame then
				health.backdrop:SetPoint("TOPLEFT", frame)
				health.backdrop:SetPoint("BOTTOMRIGHT", frame, -db.Height - 1, 0)
			else
				health.backdrop:SetPoint("TOPRIGHT", frame)
				health.backdrop:SetPoint("BOTTOMLEFT", frame)		
			end
			
			health.backdrop:SetBackdropColor(backr, backg, backb)		
			health.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
		end
		
		-- Power
		local power = frame.Power		
		-----------------------------
		self:CheckEnableState(frame, "Power")
		if db.Parts.Power.Enabled then
			local pdb = db.Parts.Power
			power.backdrop:ClearAllPoints()
			power.backdrop:SetPoint("LEFT", health.backdrop, "BOTTOMLEFT", 4, 0)
			power.backdrop:SetPoint("RIGHT", health.backdrop, "BOTTOMLEFT", 4 + db.Width / 2, 0)
			power.backdrop:SetHeight(pdb.Height)
			
			power:SetFrameStrata("MEDIUM")		
			power.backdrop:SetBackdropColor(backr, backg, backb)		
			power.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
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
				portrait.backdrop:SetPoint("TOPRIGHT", frame)
				portrait.backdrop:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -db.Height, 0)
			else
				portrait.backdrop:SetPoint("TOPLEFT", frame, "TOPRIGHT", 1, 0)				
				portrait.backdrop:SetSize(db.Parts.Portrait.Size, db.Parts.Portrait.Size)
			end
		end
		
		-- Castbar
		local castbar = frame.Castbar
		-----------------------------
		self:CheckEnableState(frame, "Castbar")
		if db.Parts.Castbar.Enabled then
			local pdb = db.Parts.Castbar
			--castbar.backdrop:SetSize(db.Width, pdb.Height)
			castbar.backdrop:SetHeight(pdb.Height)
			
			if pdb.CastbarLatency then
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
				
				castbar.backdrop:SetPoint("LEFT", frame, pdb.Height + 1, 0)			
				castbar.backdrop:SetPoint("RIGHT", frame)
				
				castbar.Icon.bg.backdrop:SetBackdropColor(backr, backg, backb)
				castbar.Icon.bg.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
			else			
				castbar.Icon = nil
				castbar.ButtonIcon.bg:Hide()
				castbar.backdrop:SetPoint("LEFT", frame)		
				castbar.backdrop:SetPoint("RIGHT", frame)
			end
			
			castbar.backdrop:SetBackdropColor(backr, backg, backb)
			castbar.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
			
		end
		
		-- Combo bar
		local cbar = frame.CPoints
		-------------------------------
		self:CheckEnableState(frame, "CPoints")
		if db.Parts.CPoints.Enabled then
			local pdb = db.Parts.CPoints
			
			cbar:ClearAllPoints()
			cbar:SetPoint("LEFT", frame, "TOPLEFT", pdb.Margin, 0)
			cbar:SetPoint("RIGHT", frame, "TOPRIGHT", -pdb.Margin, 0)
			cbar:SetHeight(10)
			
			for i = 1, MAX_COMBO_POINTS do
				cbar[i].backdrop:SetWidth((db.Width - (MAX_COMBO_POINTS - 1) * pdb.Spacing - pdb.Margin * 2) / MAX_COMBO_POINTS)
				cbar[i].backdrop:SetHeight(pdb.Height)
							
				cbar[i].backdrop:ClearAllPoints()
				if i == 1 then
					cbar[i].backdrop:SetPoint("LEFT", cbar)
				else
					cbar[i].backdrop:SetPoint("LEFT", cbar[i-1].backdrop, "RIGHT", pdb.Spacing, 0)
				end	
				
				cbar[i].backdrop:SetBackdropColor(backr, backg, backb)
				cbar[i].backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
			end
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
		--]]
end

tinsert(plugin.UnitsToCreate, "target")