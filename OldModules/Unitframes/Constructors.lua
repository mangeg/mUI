local _, ns = ...

local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local plugin = mUI:GetModule("Unitframes")
if not plugin then return end

local db
local gdb
local mult = 768 / string.match(GetCVar("gxResolution"), "%d+x(%d+)") / 0.711111111111111

plugin:AddDbUpdateCallback(function()
	db = plugin.db.profile
	gdb = mUI.db.profile
end)

function plugin:SpawnMenu()
	local unit = plugin:TitleString(self.unit)
	if _G[unit.."FrameDropDown"] then
		ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
	elseif (self.unit:match("party")) then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
	end
end

function plugin.Scale(x)
	return mult * math.floor(x / mult + .5)
end

function plugin:CheckEnableState(frame, partName)
	if not frame[partName] then return end
	local part = frame[partName]
	
	local d = frame.db.Parts[partName]
	
	if d.Enabled then
		if not frame:IsElementEnabled(partName) then
			frame:EnableElement(partName)
			part:Show()
		end
	else
		if frame:IsElementEnabled(partName) then
			frame:DisableElement(partName)
			part:Hide()
		end
	end
	
	return d.Enabled
end

function plugin:CreateHealthBar(frame, bg, text, textPos)
	if DEBUG then
		expect(frame, "typeof", "frame")		
	end

	local health = CreateFrame("StatusBar", nil, frame)
	self.StatusBars[health] = true
	
	health.PostUpdate = self.PostUpdateHealth
	
	health:SetFrameStrata("LOW")
	health.frequentUpdates = true
	
	health.Smooth = true	
	
	if bg then
		health.bg = health:CreateTexture(nil, "BORDER")
		health.bg:SetAllPoints()
		health.bg:SetTexture(mUI.Media.Blank)
		
		health.bg.multiplier = 0.25
	end
	
	if text then
		health.value = self:FontString(health, nil, db.FontSize, "THINOUTLINE")
		health.value:SetParent(frame)
		
		local x = -2
		if textPos == "LEFT" then
			x = 2
		end
		health.value:SetPoint(textPos, health, textPos, x, 0)
	end
	
	if db.classcolor ~= true then	
		health.colorSmooth = true
		health.colorHealth = true
	else
		health.colorClass = true
		health.colorReaction = true
	end
	
	health.colorTapping = true
	health.colorDisconnected = true
	
	self:CreateBackdrop(health)
	self:CreateSharpBorder(health.backdrop)
	
	plugin:CreateDebugDisplay(health, (frame.unit or frame:GetName()).."Health")
	
	return health
end

function plugin:CreatePowerBar(frame, bg, text, textPos)
	if DEBUG then
		expect(frame, "typeof", "frame")		
	end

	local power = CreateFrame("StatusBar", nil, frame)
	self.StatusBars[power] = true
	
	power:SetFrameStrata("LOW")
	power.frequentUpdates = true
	
	power.Smooth = true
	
	if bg then
		power.bg = power:CreateTexture(nil, "BORDER")
		power.bg:SetAllPoints()
		power.bg:SetTexture(mUI.Media.Blank)
		
		power.bg.multiplier = 0.2
	end
	
	if text then
		power.value = self:FontString(power, nil, db.FontSize, "THINOUTLINE")
		power.value:SetParent(frame)
	end
	
	if db.classcolor ~= true then	
		power.colorPower = true
	else
		power.colorPower = true
	end
	power.colorTapping = true
	power.colorDisconnected = true
	
	self:CreateBackdrop(power)		
	self:CreateSharpBorder(power.backdrop)
	
	plugin:CreateDebugDisplay(power, (frame.unit or frame:GetName()).."Power")
	
	return power
end

function plugin:CreateAlternatePowerBar(frame, bg, text, textPos)
	if DEBUG then
		expect(frame, "typeof", "frame")		
	end

	local altPower = CreateFrame("StatusBar", nil, frame)
	self.StatusBars[altPower] = true
	
	--altPower.PostUpdate = self.PostUpdateHealth
	
	altPower:EnableMouse(true)
	altPower:SetFrameStrata("LOW")
	altPower.frequentUpdates = true
	
	altPower:HookScript("OnEnter", function(self)		
		GameTooltip:SetOwner(self)
		local name, desc = select(10, UnitAlternatePowerInfo(self.unit))
		GameTooltip:SetText(name, 1, 1, 1)
		GameTooltip:AddLine(desc, nil, nil, nil, 1)		
		GameTooltip:Show()
	end)
	altPower:HookScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	altPower.Smooth = true	
	
	if bg then
		altPower.bg = altPower:CreateTexture(nil, "BORDER")
		altPower.bg:SetAllPoints()
		altPower.bg:SetTexture(mUI.Media.Blank)
		
		altPower.bg.multiplier = 0.25
	end
	
	if text then
		altPower.value = self:FontString(altPower, nil, db.FontSize, "THINOUTLINE")
		altPower.value:SetParent(frame)
		
		local x = -2
		if textPos == "LEFT" then
			x = 2
		end
		altPower.value:SetPoint(textPos, altPower, textPos, x, 0)
	end
	
	self:CreateBackdrop(altPower)
	self:CreateSharpBorder(altPower.backdrop)
	
	plugin:CreateDebugDisplay(altPower, frame.unit.."AlternativePower")
	
	return altPower
end

function plugin:CreatePortrait(frame)
	local portrait = CreateFrame("PlayerModel", nil, frame)
	portrait:SetFrameStrata("LOW")
	
	self:CreateBackdrop(portrait)	
	self:CreateSharpBorder(portrait.backdrop)
	
	portrait.PostUpdate = self.PortraitUpdate
	
	plugin:CreateDebugDisplay(portrait, frame.unit.."Portrait")
	
	return portrait
end

function plugin:Create_Buffs(frame)
	local buffs = CreateFrame("Frame", nil, frame)
	buffs.spacing = 2
	buffs.PostCreateIcon = plugin.Create_AuraIcon
	buffs.PostUpdateIcon = plugin.PostUpdateAura
	buffs.CustomFilter = plugin.AuraFilter
	buffs.type = "buffs"
	buffs.disableCooldown = true
	buffs["spacing-y"] = 8
	
	plugin:CreateDebugDisplay(buffs, frame.unit.."Buffs")
	
	return buffs
end

function plugin:Create_Debuffs(frame)
	local buffs = CreateFrame("Frame", nil, frame)
	buffs.spacing = 2
	buffs.PostCreateIcon = plugin.Create_AuraIcon
	buffs.PostUpdateIcon = plugin.PostUpdateAura
	buffs.CustomFilter = plugin.AuraFilter
	buffs.type = "debuffs"
	buffs.disableCooldown = true
	buffs["spacing-y"] = 10		
	
	plugin:CreateDebugDisplay(buffs, frame.unit.."Debuffs")
	
	return buffs
end

function plugin:Create_AuraIcon(button)
	local f = CreateFrame("Frame", nil, button)
	f:SetAllPoints()
	button.text = plugin:FontString(f, nil, nil, "OUTLINE")
	button.text:SetPoint("TOP", 0, -4)
	button.text:SetJustifyH("CENTER")
	
	button.count:SetFont(mUI.Media.NormalFont, 10, "OUTLINE")
	plugin.Strings[button.count] = true
	
	--plugin:CreateBackdrop(button)
	plugin:CreateSharpBorder(button)

	button.cd2 = CreateFrame("StatusBar", nil, button)
	plugin:CreateBackdrop(button.cd2)
	plugin:CreateSharpBorder(button.cd2.backdrop)
	button.cd2:SetStatusBarTexture(mUI.Media.Blank)
	button.cd2:GetStatusBarTexture():SetHorizTile(false)
	button.cd2.backdrop:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -1)
	button.cd2.backdrop:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", 0, -1)
	button.cd2.backdrop:SetHeight(6)
	
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse()
	button.cd:ClearAllPoints()
	button.cd:SetPoint("TOPLEFT", 2, -2)
	button.cd:SetPoint("BOTTOMRIGHT", -2, 2)
	button.cd:Hide()
	
	
	button.icon:ClearAllPoints()
	button.icon:SetPoint("TOPLEFT", 2, -2)
	button.icon:SetPoint("BOTTOMRIGHT", -2, 2)
	button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon:SetDrawLayer("ARTWORK")
	
	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOMRIGHT", -1, 1)
	button.count:SetJustifyH("RIGHT")
	button.count:SetParent(f)	
	
	button.overlay:SetTexture(nil)
	button.stealable:SetTexture(nil)
end

function plugin:CreateCastbar(frame, direction)
	local castbar = CreateFrame("StatusBar", nil, frame)	
	self.StatusBars[castbar] = true
	
	castbar.CustomDelayText = self.CustomCastDelayText
	castbar.PostCastStart = self.PostCastStart
	castbar.PostChannelStart = self.PostCastStart		
	castbar.PostCastInterruptible = self.PostCastInterruptible
	castbar.PostCastNotInterruptible = self.PostCastNotInterruptible
	
	self:CreateBackdrop(castbar)
	self:CreateSharpBorder(castbar.backdrop)
	
	castbar.Time = self:FontString(castbar)
	
	castbar.Time:SetPoint("RIGHT", castbar, "RIGHT", -4, 0)
	castbar.Time:SetTextColor(0.84, 0.75, 0.65)
	castbar.Time:SetJustifyH("RIGHT")
	--castbar.CustomTimeText = UF.CustomCastTimeText
	
	castbar.Text = self:FontString(castbar)	
	
	castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
	castbar.Text:SetTextColor(0.84, 0.75, 0.65)

	--Set to castbar.SafeZone
	castbar.LatencyTexture = castbar:CreateTexture(nil, "OVERLAY")
	castbar.LatencyTexture:SetTexture(mUI.Media.Blank)
	castbar.LatencyTexture:SetVertexColor(0.69, 0.31, 0.31, 0.75)	

	local button = CreateFrame("Frame", nil, castbar)
	
	self:CreateBackdrop(button)
	self:CreateSharpBorder(button.backdrop)
	
	if direction == "LEFT" then
		button.backdrop:SetPoint("RIGHT", castbar.backdrop, "LEFT", -1, 0)
	else
		button.backdrop:SetPoint("LEFT", castbar.backdrop, "RIGHT", 1, 0)
	end
	
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", button, 0, 0)
	icon:SetPoint("BOTTOMRIGHT", button, 0, 0)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon.bg = button
	
	--Set to castbar.Icon
	castbar.ButtonIcon = icon

	plugin:CreateDebugDisplay(castbar, frame.unit.."Castbar")
		
	return castbar
end

function plugin:CreateCombobar(frame)
	local CPoints = CreateFrame("Frame", nil, frame)
	
	--self:CreateBackdrop(CPoints)
	--self:CreateSharpBorder(button.backdrop)
	
	--CPoints.Override = UF.UpdateComboDisplay

	for i = 1, MAX_COMBO_POINTS do
		CPoints[i] = CreateFrame("StatusBar", nil, CPoints)
		CPoints[i]:SetStatusBarTexture(mUI.Media.Blank)
		CPoints[i]:GetStatusBarTexture():SetHorizTile(false)
		
		self:CreateBackdrop(CPoints[i])
		self:CreateSharpBorder(CPoints[i].backdrop)
		
		CPoints[i].backdrop:SetParent(CPoints[i])
	end
	
	CPoints[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
	CPoints[2]:SetStatusBarColor(0.69, 0.31, 0.31)
	CPoints[3]:SetStatusBarColor(0.65, 0.63, 0.35)
	CPoints[4]:SetStatusBarColor(0.65, 0.63, 0.35)
	CPoints[5]:SetStatusBarColor(0.33, 0.59, 0.33)	
	
	plugin:CreateDebugDisplay(CPoints, frame.unit.."Combo Points")
	
	return CPoints
end

function plugin:CreateResourceBar_DeathKnight(frame)
	local runes = CreateFrame("Frame", nil, frame)
	runes.Smooth = true
	for i = 1, 6 do
		runes[i] = CreateFrame("StatusBar", nil, runes)		
		runes[i]:SetStatusBarTexture(mUI.Media.Blank)
		runes[i]:GetStatusBarTexture():SetHorizTile(false)
		
		runes[i].Smooth = true
		
		self:CreateBackdrop(runes[i])
		self:CreateSharpBorder(runes[i].backdrop)
		
		runes[i].backdrop:SetParent(runes)
	end
	
	return runes
end

function plugin:CreateNameText(frame, point, x, y)
	local name = self:FontString(frame)
	if frame.unit == "player" or frame.unit == "target" then
		frame:Tag(name, "[mUI:getnamecolor][mUI:namelong] [mUI:diffcolor][level] [shortclassification]")
	else
		frame:Tag(name, "[mUI:getnamecolor][mUI:namemedium]")
	end
	name:SetPoint(point or "CENTER", frame.Health, x or 0, y or 0)
	
	return name
end

function plugin:CreateCombatIndicator(frame, side)
	local combat = frame:CreateTexture(nil, "OVERLAY")
	combat:SetSize(19, 19)
	combat:SetPoint("CENTER", frame.Health, side or "LEFT", 0, 0)
	combat:SetVertexColor(0.69, 0.31, 0.31)
	
	return combat
end

function plugin:CreateSharpBorder(frame)
	frame:SetBackdrop({
	  bgFile = mUI.Media.Blank, 
	  edgeFile = mUI.Media.Blank, 
	  tile = false, tileSize = 0, edgeSize = 1, 
	  insets = { left = -1, right = -1, top = -1, bottom = -1}
	})
	
	if not frame.oborder and not frame.iborder then
		local border = CreateFrame("Frame", nil, frame)
		border:SetPoint("TOPLEFT", (1), -(1))
		border:SetPoint("BOTTOMRIGHT", -(1), (1))
		border:SetBackdrop({
			edgeFile = mUI.Media.Blank, 
			edgeSize = 1, 
			insets = { left = 1, right = 1, top = 1, bottom = 1 }
		})
		border:SetBackdropBorderColor(0, 0, 0, 1)
		frame.iborder = border
		if frame.oborder then return end
		local border = CreateFrame("Frame", nil, frame)
		border:SetPoint("TOPLEFT", -(1), (1))
		border:SetPoint("BOTTOMRIGHT", (1), -(1))
		border:SetFrameLevel(frame:GetFrameLevel() + 1)
		border:SetBackdrop({
			edgeFile = mUI.Media.Blank, 
			edgeSize = 1, 
			insets = { left = 1, right = 1, top = 1, bottom = 1 }
		})
		border:SetBackdropBorderColor(0, 0, 0, 1)
		frame.oborder = border				
	end
end

function plugin:CreateBackdrop(frame)
	if frame.backdrop then return end
	frame.backdrop = CreateFrame("Frame", nil, frame)
	frame:SetPoint("TOPLEFT", frame.backdrop, 2, -2)
	frame:SetPoint("BOTTOMRIGHT", frame.backdrop, -2, 2)
	frame.backdrop:SetFrameLevel(frame:GetFrameLevel() - 1)	
	return frame.backdrop
end

function plugin:FontString(parent, fontName, fontHeight, fontStyle)
	if DEBUG then
		expect(parent, "typeof", "frame")		
	end
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName or mUI.Media.NormalFont, (fontHeight or 12) * gdb.Fonts.Scale, fontStyle or "NONE")
	fs.oldScale = gdb.Fonts.Scale
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0, 0.4)
	fs:SetShadowOffset(1, 1)
	
	self.Strings[fs] = true
	
	return fs
end

function plugin:CreateDebugDisplay(frame, name)
	local dragger = CreateFrame("Frame", nil)
	local t = dragger:CreateTexture(nil, "OVERLAY")
	t:SetTexture(0, 0, 0, 0.5)
	t:SetAllPoints(frame.backdrop or frame)
	
	local text = plugin:FontString(dragger, nil, 8)
	text:SetTextColor(1, 1, 1)
	text:SetText(name)
	text:SetPoint("CENTER", frame)
	
	dragger:Hide()
	
	plugin.DebugDisplays[dragger] = true
end