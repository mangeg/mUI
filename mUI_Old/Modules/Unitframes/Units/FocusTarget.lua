local _, ns = ...

local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local plugin = mUI:GetModule("Unitframes")
if not plugin then return end

local oUF = oUF

local _, class = UnitClass("player")

function plugin:CreateUnit_FocusTarget(frame, unit)
	frame.Health = self:CreateHealthBar(frame, true, true, "RIGHT")
	frame.Power = self:CreatePowerBar(frame, true, true)
	frame.Name = self:CreateNameText(frame, "LEFT", 8, 0)
	frame.Portrait = self:CreatePortrait(frame)
	frame.Castbar = self:CreateCastbar(frame, "LEFT")
	
	frame.AltPowerBar = self:CreateAlternatePowerBar(frame, true , true, "LEFT")
	frame.AltPowerBar.unit = unit
	
	frame.Buffs = self:Create_Buffs(frame)
	frame.Debuffs = self:Create_Buffs(frame)
	frame.RaidIcon = frame:CreateTexture()
end


function plugin:UpdateUnit_FocusTarget(frame, db)
	plugin:UpdateFrame(frame)
end

tinsert(plugin.UnitsToCreate, "focustarget")