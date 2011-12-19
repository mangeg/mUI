local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local plugin = mUI:GetModule("Unitframes")

local db, gdb

function plugin:CreateRaid25Frames(unitGroup)
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)	
	
	self.menu = plugin.SpawnMenu
	self.colors = oUF.colors
	
	self.Health = plugin:CreateHealthBar(self, true, true, "RIGHT")
	self.Power = plugin:CreatePowerBar(self, true, true, "RIGHT")
	self.Name = plugin:CreateNameText(self, "CENTER")
end

function plugin:UpdateRaid25Header(header, db)
	header.db = db
	
	self:ChangeVisibility(header, "custom [@raid1,exists] hide;show")
	self:ChangeVisibility(header, "custom "..db.Visibility)
	
	plugin:UpdateGroupChildren(header:GetChildren())
	header:SetAttribute("oUF-initialConfigFunction", 
		([[self:SetWidth(%d); self:SetHeight(%d); self:SetFrameLevel(5)]]):format(db.Width, db.Height))
	
	if db.GroupBy == "GROUP" then
		header:SetAttribute("groupingOrder", db.GroupByGroup)
	elseif db.GroupBy == "CLASS" then
		header:SetAttribute("groupingOrder", db.GroupByClass)
	else
		header:SetAttribute("groupingOrder", db.GroupByRole)
	end
	header:SetAttribute("groupBy", db.GroupBy)
	
	
	header:SetAttribute("sortMethod", db.SortBy)
	header:SetAttribute("sortDir", db.SortOrder)
	
	header:SetAttribute("showParty", nil)
	header:SetAttribute("showPlayer", nil)
	header:SetAttribute("showSolo", nil)
	header:SetAttribute("showRaid", true)
	
	header:SetAttribute("point", "TOP")
	
	header:SetAttribute("columnAnchorPoint", "LEFT")
	header:SetAttribute("maxColumns", 8)
	header:SetAttribute("unitsPerColumn", 5)
	header:SetAttribute("yOffset", -7)
	header:SetAttribute("columnSpacing", 10)		
	
	header:SetAttribute("groupFilter", "2,4,DEATHKNIGHT")
	header:SetAttribute("strictFiltering", false)
	
	header:ClearAllPoints()
	header:SetPoint(db.Point, UIParent, db.RelPoint, db.X, db.Y)
			
	plugin:UpdateGroupChildren(header:GetChildren())
end

function plugin:UpdateRaid25Frames(frame, db)
	frame.db = db
	plugin:UpdateFrame(frame)
end

function plugin:UpdateGroupChildren(...)
	for i=1, select("#", ...) do
		local child = select(i, ...)
		child:ClearAllPoints()
	end
end

plugin.HeadersToCreate["raid25"] = true