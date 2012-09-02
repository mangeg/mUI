local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local plugin = mUI:GetModule("Unitframes")
if not plugin then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local _G = _G

function plugin:UpdateFrame(frame)
	if DEBUG then
		expect(frame, "typeof", "frame")
		expect(frame.db, "typeof", "table")
	end
	local gdb = mUI.db.profile
	local borderr, borderg, borderb
	local backr, backg, backb = unpack(gdb.Colors.BackdropColor)
	
	if gdb.Colors.ClassColoredBorders then						
		borderr, borderg, borderb = unpack(gdb.Colors.ClassColors[mUI.pClass])			
	else
		borderr, borderg, borderb = unpack(gdb.Colors.BorderColor)		
	end	
	
	plugin:Position(frame)
	
	local db = frame.db
	frame:SetSize(db.Width, db.Height)
	
	-- Health
	local health = frame.Health
	-----------------------------
	if health then		
		if self:CheckEnableState(frame, "Health") then			
			health.backdrop:ClearAllPoints()			
			if db.Parts.Portrait.Enabled and db.Parts.Portrait.InFrame then
				if db.Parts.Portrait.InFrameSide == "LEFT" then
					health.backdrop:SetPoint("TOPRIGHT", frame)
				else
					health.backdrop:SetPoint("TOPLEFT", frame)
				end
				health.backdrop:SetSize(db.Width - db.Height - 1, db.Height)
			else
				health.backdrop:SetAllPoints(frame)
			end
		
			health.backdrop:SetBackdropColor(backr, backg, backb)		
			health.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
		end
	end
	
	-- Power
	local power = frame.Power		
	-----------------------------
	if power then
		if self:CheckEnableState(frame, "Power") then
			local pdb = db.Parts.Power
			
			plugin:PartPosition(frame, "Power")
			plugin:PartWidth(frame, "Power")
			
			power.backdrop:SetHeight(pdb.Height)
			
			power.backdrop:SetBackdropColor(backr, backg, backb)		
			power.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
		end	
	end
	
	-- Alt Power
	local altPower = frame.AltPowerBar
	-----------------------------
	if altPower then		
		if self:CheckEnableState(frame, "AltPowerBar") then
			local pdb = db.Parts.AltPowerBar
			
			local ar, ag, ab = unpack(plugin.db.profile.Colors.Other.AltPower)
			local f = 0.2
			altPower:SetStatusBarColor(ar, ag, ab)
			altPower.bg:SetVertexColor(ar * f, ag * f, ab * f)
			
			if pdb.ReplacePower and db.Parts.Power.Enabled and frame.Power then
				altPower.backdrop:SetAllPoints(frame.Power.backdrop)
				altPower:SetFrameStrata(frame.Power.backdrop:GetFrameStrata())
				altPower:SetFrameLevel(frame.Power.backdrop:GetFrameLevel() + 10)
			else
				plugin:PartPosition(frame, "AltPowerBar")
				plugin:PartWidth(frame, "AltPowerBar")
			end
			
			altPower.backdrop:SetHeight(pdb.Height)	
			
			altPower.backdrop:SetBackdropColor(backr, backg, backb)		
			altPower.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
		end
	end
	
	-- Portrait
	local portrait = frame.Portrait
	if portrait then
	-----------------------------		
		local pdb = db.Parts.Portrait
		if self:CheckEnableState(frame, "Portrait") then
			portrait.backdrop:SetBackdropColor(backr, backg, backb)
			portrait.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
			
			if pdb.InFrame then	
				if pdb.InFrameSide == "LEFT" then
					portrait.backdrop:SetPoint("TOPLEFT", frame)
				else
					portrait.backdrop:SetPoint("TOPRIGHT", frame)
				end
				portrait.backdrop:SetSize(db.Height, db.Height)
			else
				plugin:PartPosition(frame, "Portrait")		
				portrait.backdrop:SetSize(pdb.Size, pdb.Size)
			end			
		end
	end
	
	-- Castbar
	local castbar = frame.Castbar
	-----------------------------
	if castbar then
		self:CheckEnableState(frame, "Castbar")
		if db.Parts.Castbar.Enabled then
			local pdb = db.Parts.Castbar
			
			local height, width = pdb.Height, 0
			if pdb.Icon then
				local offset
				if pdb.IconSide == "LEFT" and pdb.Point ~= "TOP" and pdb.Point ~= "BOTTOM" then
					offset = pdb.IconSide == "LEFT" and height or -height
				elseif pdb.IconSide == "LEFT" and (pdb.Point == "TOP" or pdb.Point == "BOTTOM") then
					offset = height / 2 + 1
				elseif pdb.IconSide ~= "LEFT" and (pdb.Point == "TOP" or pdb.Point == "BOTTOM") then
					offset = -height / 2
				end
				plugin:PartPosition(frame, "Castbar", offset)
				width = plugin:PartWidth(frame, "Castbar", -(height + 1))
			else
				plugin:PartPosition(frame, "Castbar")
				width = plugin:PartWidth(frame, "Castbar")
			end
			castbar.backdrop:SetHeight(height)
			
			if db.CastbarLatency then
				castbar.SafeZone = castbar.LatencyTexture
				castbar.LatencyTexture:Show()
			else
				castbar.SafeZone = nil
				castbar.LatencyTexture:Hide()
			end
			
			
			
			if pdb.Icon then				
				castbar.Icon = castbar.ButtonIcon
				
				castbar.Icon.bg.backdrop:ClearAllPoints()
				if pdb.IconSide == "LEFT" then
					castbar.Icon.bg.backdrop:SetPoint("RIGHT", castbar.backdrop, "LEFT", -1, 0)
				else
					castbar.Icon.bg.backdrop:SetPoint("LEFT", castbar.backdrop, "RIGHT", 1, 0)
				end
				
				castbar.Icon.bg.backdrop:SetSize(height, height)								
				castbar.Icon.bg:Show()		
				
				castbar.Icon.bg.backdrop:SetBackdropColor(backr, backg, backb)
				castbar.Icon.bg.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
			else			
				castbar.Icon = nil
				castbar.ButtonIcon.bg:Hide()
			end
			
			castbar.backdrop:SetBackdropColor(backr, backg, backb)
			castbar.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
			
		end
	end
	
	-- Combo bar
	local cbar = frame.CPoints
	-------------------------------
	if cbar then		
		if self:CheckEnableState(frame, "CPoints") then
			local pdb = db.Parts.CPoints
			
			cbar:ClearAllPoints()
			plugin:PartPosition(frame, "CPoints")
			local width = plugin:PartWidth(frame, "CPoints")
			cbar:SetHeight(10)
			
			for i = 1, MAX_COMBO_POINTS do
				cbar[i].backdrop:SetWidth((width - (MAX_COMBO_POINTS - 1) * pdb.Spacing) / MAX_COMBO_POINTS)
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
	end
	
	-- Raid Icon
	local raidIcon = frame.RaidIcon
	if raidIcon then
	-----------------------------	
		if self:CheckEnableState(frame, "RaidIcon") then
			local pdb = db.Parts.RaidIcon
			self:PartPosition(frame, "RaidIcon")
			raidIcon:SetSize(pdb.Size, pdb.Size)
		end
	end
	
	-- Resource bar
	-----------------------------
	do
		-- Runes
		-------------------------
		if mUI.pClass == "DEATHKNIGHT" and db.Parts.Runes.Enabled then	
			local runes = frame.Runes
			if runes then
				if self:CheckEnableState(frame, "Runes") then							
					local pdb = db.Parts.Runes
					local RUNE_SPACING = pdb.Spacing
					local NR_RUNES = 6			
				
					plugin:PartPosition(frame, "Runes")
					local width = plugin:PartWidth(frame, "Runes")
					
					runes:SetHeight(pdb.Height)			
					
					for i = 1, 6 do
						runes[i].backdrop:SetHeight(runes:GetHeight())
						runes[i].backdrop:SetWidth((width - (NR_RUNES - 1) * RUNE_SPACING) / NR_RUNES)
						
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
		end		
	end
	
	-- Buffs
	local buffs = frame.Buffs
	-----------------------------
	if buffs then
		if db.Parts.Buffs.Enabled then
			local pdb = db.Parts.Buffs
			
			local yoffset = pdb.ShowTimerBar and pdb.TimerBarHeight + 2 or 0
			
			plugin:PartPosition(frame, "Buffs")
			local width = plugin:PartWidth(frame, "Buffs")
			
			buffs.spacing = pdb.Spacing
			local rows = pdb.Rows			
			
			buffs.num = pdb.PerRow * rows
			buffs.size = ((((width - (buffs.spacing * (buffs.num/rows - 1))) / buffs.num)) * rows)

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
	end
	
	-- Debuffs
	local debuffs = frame.Debuffs
	-----------------------------
	if debuffs then
		if db.Parts.Debuffs.Enabled then
			local pdb = db.Parts.Debuffs
			
			local yoffset = pdb.ShowTimerBar and pdb.TimerBarHeight + 2 or 0
			
			plugin:PartPosition(frame, "Debuffs")
			local width = plugin:PartWidth(frame, "Debuffs")
			
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
	end
		
	if (not db.Parts.Debuffs.Enabled) and (not db.Parts.Buffs.Enabled) and frame:IsElementEnabled("Aura") then
		frame:DisableElement("Aura")
	elseif (not frame:IsElementEnabled("Aura")) then
		frame:EnableElement("Aura")
	end
end

function plugin:Position(frame)
	if DEBUG then
		expect(frame, "typeof", "frame")
		expect(frame.db, "typeof", "table")
	end
	local db = frame.db
	frame:ClearAllPoints()
	if frame.index and frame.index > 1 then
		local frameName = ("mUI_Boss%d"):format(frame.index - 1)
		local anchor = _G[frameName]
		if db.GrowDirection == "UP" then
			frame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, db.Spacing)
		else
			frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -db.Spacing)
		end
	else		
		local anchor = UIParent
		if db.Anchor then
			if _G[db.Anchor] then 
				anchor = _G[db.Anchor] 
			elseif frame[db.Anchor] then
				anchor = frame[db.Anchor]
			end
		end		
		
		frame:SetPoint(db.Point, anchor, db.RelPoint, db.X, db.Y)
	end
end

function plugin:PartPosition(frame, partName, x, y)
	if DEBUG then
		expect(frame, "typeof", "frame")
		expect(frame.db, "typeof", "table")
		expect(frame[partName], "typeof", "frame")
	end
	
	local db = frame.db.Parts[partName]
	local part = frame[partName]
	local anchor = plugin:GetPartAnchor(frame, partName)
	

	if db.SetFrameLevels then
		if part.SetFrameLevel then
			part:SetFrameLevel(db.FrameLevel)
		end
		if part.SetFrameStrata then
			part:SetFrameStrata(db.FrameStrata)
		end
	end
	
	if part.backdrop then part = part.backdrop end
	if anchor.backdrop then anchor = anchor.backdrop end
	
	part:ClearAllPoints()
	part:SetPoint(db.Point, anchor, db.RelPoint, db.X + (x or 0), db.Y + (y or 0))	
end

function plugin:PartWidth(frame, partName, offset)
	if DEBUG then
		expect(frame, "typeof", "frame")
		expect(frame.db, "typeof", "table")
		expect(frame[partName], "typeof", "frame")
	end
	
	local db = frame.db
	local pdb = frame.db.Parts[partName]
	local part = frame[partName]
	
	if part.backdrop then part = part.backdrop end
	
	local width
	if pdb.WidthAsFrame then
		width = db.Width
	else
		width = pdb.Width
	end
	
	width = width + (offset or 0)
	
	if pdb.WidthOffsetAsPercent then
		width = width * pdb.WidthOffsetPercent
	else	
		width = width + pdb.WidthOffset
	end
	
	part:SetWidth(width)
	
	return width
end

function plugin:GetPartAnchor(frame, partName)
	if DEBUG then
		expect(frame, "typeof", "frame")
		expect(frame.db, "typeof", "table")
	end
	
	local db = frame.db.Parts[partName]
	local anchor = UIParent
	if db.Anchor then
		if db.Anchor == "parentFrame" then
			anchor = frame
		elseif _G[db.Anchor] then 
			anchor = _G[db.Anchor] 
		elseif frame[db.Anchor] then
			anchor = frame[db.Anchor]
		end
	end
	if anchor.backdrop then
		return anchor.backdrop
	end
	return anchor
end