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
	visible:Hide()
	
	local text = visible:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetAllPoints()
	text:SetText(("Anchor: %s"):format(name))
	anchor.text = text	
	
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


