local _, ns = ...

local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local plugin = mUI:GetModule("Unitframes")
if not plugin then return end

local db
local gdb

local class = select(2, UnitClass("player"))

plugin:AddDbUpdateCallback(function()
	db = plugin.db.profile
	gdb = mUI.db.profile
end)

local function GetInfoText(frame, unit, r, g, b, min, max, reverse, type, mouseOver)
	local value = ""
	local db = frame.db
		
	
	if not db then return "" end
	
	local TextFormat = db.Parts[type].TextFormat
	if mouseOver then 
		TextFormat = "current-percent"
	end
	
	if reverse then
		if type == "Health" then
			if TextFormat == "current-percent" then
				if min ~= max then
					value = format("|cff%02x%02x%02x%d%%|r |cffD7BEA5-|r |cffAF5050%s|r", r * 255, g * 255, b * 255, floor(min / max * 100), mUI:ShortValue(min))
				else
					value = format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, mUI:ShortValue(max))	
				end
			elseif TextFormat == "current-max" then
				if min == max then
					value = format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, mUI:ShortValue(max))	
				else
					value = format("|cff%02x%02x%02x%s|r |cffD7BEA5-|r |cffAF5050%s|r", r * 255, g * 255, b * 255, mUI:ShortValue(max), mUI:ShortValue(min))
				end
			elseif TextFormat == "current" then
				value = format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, mUI:ShortValue(min))	
			elseif TextFormat == "percent" then
				value = format("|cff%02x%02x%02x%d%%|r", r * 255, g * 255, b * 255, floor(min / max * 100))
			elseif TextFormat == "deficit" then
				if min == max then
					value = ""
				else			
					value = format("|cffAF5050-|r|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, mUI:ShortValue(max - min))
				end
			end	
		else
			if TextFormat == "current-percent" then
				if min ~= max then
					value = format("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), mUI:ShortValue(min))
				else
					value = format("%s", mUI:ShortValue(max))	
				end
			elseif TextFormat == "current-max" then
				if min == max then
					value = format("%s", mUI:ShortValue(max))	
				else
					value = format("%s |cffD7BEA5-|r %s", mUI:ShortValue(max), mUI:ShortValue(min))
				end
			elseif TextFormat == "current" then
				value = format("%s", mUI:ShortValue(min))	
			elseif db[type].text_format == "percent" then
				value = format("%d%%", floor(min / max * 100))
			elseif TextFormat == "deficit" then
				if min == max then
					value = ""
				else			
					value = format("|cffAF5050-|r%s", mUI:ShortValue(max - min))
				end
			end			
		end
	else
		if type == "Health" then
			if TextFormat == "current-percent" then
				if min ~= max then
					value = format("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", mUI:ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
				else
					value = format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, mUI:ShortValue(max))
				end
			elseif TextFormat == "current-max" then
				if min == max then
					value = format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, mUI:ShortValue(max))	
				else
					value = format("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%s|r", mUI:ShortValue(min), r * 255, g * 255, b * 255, mUI:ShortValue(max))
				end
			elseif TextFormat == "current" then
				value = format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, mUI:ShortValue(min))	
			elseif TextFormat == "percent" then
				value = format("|cff%02x%02x%02x%d%%|r", r * 255, g * 255, b * 255, floor(min / max * 100))
			elseif TextFormat == "percent-hidefull" and not (min == max) then
				value = format("|cff%02x%02x%02x%d%%|r", r * 255, g * 255, b * 255, floor(min / max * 100))
			elseif TextFormat == "deficit" then
				if min == max then
					value = ""
				else			
					value = format("|cffAF5050-|r|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, mUI:ShortValue(max - min))
				end
			end
		else
			if TextFormat == "current-percent" then
				if min ~= max then
					value = format("%s |cffD7BEA5-|r %d%%", mUI:ShortValue(min), floor(min / max * 100))
				else
					value = format("%s", mUI:ShortValue(max))
				end
			elseif TextFormat == "current-max" then
				if min == max then
					value = format("%s", mUI:ShortValue(max))	
				else
					value = format("%s |cffD7BEA5-|r %s", mUI:ShortValue(min), r * 255, g * 255, b * 255, mUI:ShortValue(max))
				end
			elseif TextFormat == "current" then
				value = format("%s", mUI:ShortValue(min))	
			elseif TextFormat == "percent" then
				value = format("%d%%", floor(min / max * 100))
			elseif TextFormat == "deficit" then
				if min == max then
					value = ""
				else			
					value = format("|cffAF5050-|r%s", mUI:ShortValue(max - min))
				end
			end		
		end
	end
	
	return value
end

function plugin:PostUpdateHealth(unit, min, max)
	local r, g, b = self:GetStatusBarColor()
	self.defaultColor = self.defaultColor or {}
	self.defaultColor[1] = r
	self.defaultColor[2] = g
	self.defaultColor[3] = b
	
	if not self.value or self.value and not self.value:IsShown() then return end
	local mouseOver = self:GetParent():IsMouseOver()
	
	local connected, dead, ghost = UnitIsConnected(unit), UnitIsDead(unit), UnitIsGhost(unit)
	if not connected or dead or ghost then
		if not connected then
			self.value:SetText("|cffD7BEA5".."Offline".."|r")
		elseif dead then
			self.value:SetText("|cffD7BEA5"..DEAD.."|r")
		elseif ghost then
			self.value:SetText("|cffD7BEA5".."Ghost".."|r")
		end
	else
		local r, g, b = oUF.ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		local reverse
		if unit == "target" then
			reverse = true
		end
				
		self.value:SetText(GetInfoText(self:GetParent(), unit, r, g, b, min, max, reverse, "Health", mouseOver))
	end
	
end

function plugin:PortraitUpdate(unit)		
	if self:GetModel() and self:GetModel().find and self:GetModel():find("worgenmale") then
		self:SetCamera(1)
	end
	
	local d = self:GetParent().db
	
	self:SetCamDistanceScale(d.PortraitScale or 1)
end	

function plugin:CustomCastDelayText(duration)
	self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay))
end

function plugin:PostCastStart(unit, name, rank, castid)
	if unit == "vehicle" then unit = "player" end
	self.Text:SetText(string.sub(name, 0, math.floor((((32/245) * self:GetWidth()) / 12 * 12))))

	local db = self:GetParent().db
	
	local color
	if not db then return end
	db = db.Parts.Castbar
	if self.interrupt and unit ~= "player" then
		if UnitCanAttack("player", unit) then
			color = db.Color
			self:SetStatusBarColor(unpack(color))
		else
			color = db.Color
			self:SetStatusBarColor(unpack(color))
		end
	else
		color = db.Color
		self:SetStatusBarColor(unpack(color))
	end
end

function plugin:PostCastInterruptible(unit)
	local db = self:GetParent().db
	
	if not db then return end
	db = db.Parts.Castbar
	
	if unit == "vehicle" then unit = "player" end
	if unit ~= "player" then
		local color
		if UnitCanAttack("player", unit) then
			color = db.Color
		else
			color = db.Color
		end		
		self:SetStatusBarColor(unpack(color))
	end
end

function plugin:PostCastNotInterruptible(unit)
	local db = self:GetParent().db
	if not db then return end
	db = db.Parts.Castbar
	local color = db.Color
	self:SetStatusBarColor(unpack(color))
end

function plugin:UpdateAuraTimer(elapsed)	
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = mUI:FormatTime(self.timeLeft)
				if self.reverse then time = mUI:FormatTime(abs(self.timeLeft - self.duration), true) end
				self.text:SetText(time)
				if self.timeLeft <= 5 then
					self.text:SetTextColor(0.99, 0.31, 0.31)
				else
					self.text:SetTextColor(1, 1, 1)
				end
			else
				self.text:Hide()
				self:SetScript("OnUpdate", nil)
			end
			
			self.elapsed = 0			
			
			local p = 1 - self.timeLeft / self.duration
			self.cd2:SetMinMaxValues(0, self.duration)
			self.cd2:SetValue(self.timeLeft)
			self.cd2:SetStatusBarColor(0.75 + 0.75 * p, 0.75 - 0.75 * p, 0.75 - 0.75 * p) 
		end
	end
end

function plugin:PostUpdateAura(unit, button, index, offset, filter, isDebuff, duration, timeLeft)	
	--local name, _, _, _, dtype, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, button.filter)
	local name, rank, texture, count, dtype, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura(unit, index, button.filter)
	local borderr, borderg, borderb
	
	if gdb.Colors.ClassColoredBorders then						
		borderr, borderg, borderb = unpack(gdb.Colors.ClassColors[select(2, UnitClass("player"))])			
	else
		borderr, borderg, borderb = unpack(gdb.Colors.BorderColor)		
	end	
		
	if button.debuff then		
		if (not UnitIsFriend("player", unit) and button.owner ~= "player" and button.owner ~= "vehicle") then
			button:SetBackdropBorderColor(borderr, borderg, borderb)
			button.icon:SetDesaturated(true)
		else
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			if (name == "Unstable Affliction" or name == "Vampiric Touch") and class ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94)
				button.cd2.backdrop:SetBackdropBorderColor(0.05, 0.85, 0.94)
			else
				button:SetBackdropBorderColor(color.r, color.g, color.b)
				button.cd2.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
			end
			button.icon:SetDesaturated(false)		
		end
	else	
		button:SetBackdropBorderColor(borderr, borderg, borderb)
		button.cd2.backdrop:SetBackdropBorderColor(borderr, borderg, borderb)
	end
	
	if button:GetParent().timerbar and (expirationTime and expirationTime > 0) then
		button.cd2:Show()
		button.cd2.backdrop:SetBackdropColor(unpack(gdb.Colors.BackdropColor))
	else
		button.cd2:Hide()
	end
	
	button.text:SetFont(mUI.Media.NormalFont, button:GetParent().fontSize or 12, "OUTLINE")
	button.count:SetFont(mUI.Media.NormalFont, button:GetParent().fontSize or 12, "OUTLINE")
	
	button.duration = duration
	button.timeLeft = expirationTime
	button.first = true	
	
	button:SetScript("OnUpdate", plugin.UpdateAuraTimer)
end

function plugin.AuraFilter(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff)
	local isPlayer, isFriend
	
	local db = icons:GetParent().db
	
	if icons.type == "buffs" then 
		db = db.Parts.Buffs 
	else
		db = db.Parts.Debuffs 
	end
	
	if(caster == "player" or caster == "vehicle") then
		isPlayer = true
	end
	if UnitIsFriend("player", unit) then
		isFriend = true
	end
	
	icon.isPlayer = isPlayer
	icon.owner = caster
	
	if db.ShowPersonal and isPlayer then		
		return true
	elseif db.UseFilter then	
		for i, v in pairs(db.Filters) do
			if rawget(plugin.db.profile.Filters, i) and v then
				local filter = plugin.db.profile.Filters[i]		
				if db.FilterBlacklist then	
					if filter.spells[name] then
						return false					
					end
				else
					if filter.spells[name] then
						return true
					end
				end
			end
		end
		
		if db.FilterBlacklist then
			return true
		else
			return false
		end
		
	else
		if not db.ShowPersonal then
			return true
		else
			return false
		end
	end
end