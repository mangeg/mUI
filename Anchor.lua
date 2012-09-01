local name, mUI = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local anchorPrototype = {}
local anchorItemPrototype = {}

function mUI:CreateAnchor(name, db)
	local anchor = setmetatable({
		name = name,
		db = db
	}, {__index = anchorPrototype})
	
	local visible = CreateFrame("Frame")
	anchor.visible = visible
	visible:SetPoint("TOPLEFT", UIParent, "CENTER", 0, 84)
	visible:SetWidth(301)
	visible:SetHeight(99)
	visible:Hide()
	
	local text = mUI.Media:GetFontString(visible, "OVERLAY")
	text:SetAllPoints(visible)
	text:SetText(("Anchor: %s"):format(name))
	text:Update()
	anchor.text = text	
		
	local border = mUI.Objects:GetSharpBorder(visible)
	border:SetColorWidth(2.3)
	border:SetColor(unpack(mUI.db.profile.Colors.Class.MONK))
	border:SetShadowWidth(3.6)
	border:SetShadowColor(0, 0, 0)
	--border:SetTexture("Interface\\AddOns\\mUI\\Media\\Borders\\Sharp")
	--border:SetWidth(15)
	--border:SetColor(unpack(mUI.db.profile.Colors.Class.MONK))
	anchor.border = border
	
	local back = visible:CreateTexture("BACKGROUND")
	back:SetAllPoints()
	back:SetTexture(0.2, 0.2, 0.2)
	
	return anchor
end

function anchorPrototype:Show()
	self.visible:Show()
end

function anchorPrototype:Hide()
	self.visible:Hide()
end

function anchorPrototype:CreateItem()
	local item = setmetatable({
		},
		anchorItemPrototype)
		
	return item
end

function anchorItemPrototype:SetType(type)
	if DEBUG then
		expect(type, "typeof", "number")
	end	
end


