local name, addon_table = ...

-- Up Values
local _G = _G
local DEBUG = addon_table.DEBUG
local Debug = addon_table.Debug
local expect = Debug.expect

local Objects = addon_table.Objects

local borderNumbers = {}
local borderPositions = {	
	"TOP",
	"BOTTOM",
	"LEFT",
	"RIGHT",		
}
for i, name in pairs(borderPositions) do
	borderNumbers[name] = i
end

--[[function plugin:CreateSharpBorder(frame)
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
end]]

local SharpBorder = {}

function SharpBorder:SetAnchor(anchor)
	if DEBUG then
		expect(anchor, "typeof", "frame;nil")
	end
	
	local anchor = anchor or self.borders["TOP"]:GetParent()
	
	self:SetParent(anchor)
	self:ClearAllPoints()
	self:SetAllPoints(anchor)
	self.width, self.height = anchor:GetSize()	
	
	local shadowOffset = self.shadowWidth / 2 - self.borderWidth / 2
	
	for i, position in pairs(borderPositions) do
		
		local border = self.borders[position]
		local shadow = self.shadows[position]
		
		shadow:SetPoint(position, self)		
		if position == "TOP" then		
			shadow:SetPoint("LEFT", self, "TOPLEFT")
			shadow:SetPoint("RIGHT", self, "TOPRIGHT")
			border:SetPoint("TOP", self, 0, -shadowOffset)
			border:SetPoint("LEFT", self, "TOPLEFT", shadowOffset, -shadowOffset)
			border:SetPoint("RIGHT", self, "TOPRIGHT", -shadowOffset, -shadowOffset)
			
		elseif position == "BOTTOM" then
			shadow:SetPoint("LEFT", self, "BOTTOMLEFT")
			shadow:SetPoint("RIGHT", self, "BOTTOMRIGHT")
			border:SetPoint("BOTTOM", self, 0, shadowOffset)
			border:SetPoint("LEFT", self, "BOTTOMLEFT", shadowOffset, shadowOffset)
			border:SetPoint("RIGHT", self, "BOTTOMRIGHT", -shadowOffset, shadowOffset)
			
		elseif position == "LEFT" then
			shadow:SetPoint("TOP", self.shadows["TOP"], "BOTTOMLEFT")
			shadow:SetPoint("BOTTOM", self.shadows["BOTTOM"], "TOPLEFT")
			border:SetPoint("TOPLEFT", self.borders["TOP"], "BOTTOMLEFT")
			border:SetPoint("BOTTOMLEFT", self.borders["BOTTOM"], "TOPLEFT")
			
		elseif position == "RIGHT" then
			shadow:SetPoint("TOP", self.shadows["TOP"], "BOTTOMRIGHT")
			shadow:SetPoint("BOTTOM", self.shadows["BOTTOM"], "TOPRIGHT")
			border:SetPoint("TOPRIGHT", self.borders["TOP"], "BOTTOMRIGHT")
			border:SetPoint("BOTTOMRIGHT", self.borders["BOTTOM"], "TOPRIGHT")
		end
	end
end

function SharpBorder:SetColorWidth(width)
	if DEBUG then
		expect(width, "typeof", "number")
		expect(width, ">", 0)
	end
	
	self.borderWidth = width
	for i, position in pairs(borderPositions) do
		local border = self.borders[position]
		if position == "TOP" or position == "BOTTOM" then
			border:SetHeight(width)
		else
			border:SetWidth(width)
		end
	end
	self:SetAnchor()
end

function SharpBorder:SetShadowWidth(width)
	if DEBUG then
		expect(width, "typeof", "number")
		expect(width, ">", 0)
	end
	
	self.shadowWidth = width
	for i, position in pairs(borderPositions) do
		local shadow = self.shadows[position]
		if position == "TOP" or position == "BOTTOM" then
			shadow:SetHeight(width)
		else
			shadow:SetWidth(width)
		end
	end
	self:SetAnchor()
end

function SharpBorder:SetColor(r, g, b, a)
	if DEBUG then
		expect(r, "typeof", "number")
		expect(g, "typeof", "number")
		expect(b, "typeof", "number")
		expect(a, "typeof", "number;nil")
		expect(r, ">=", 0)
		expect(g, ">=", 0)
		expect(b, ">=", 0)
		expect(r, "<=", 1)
		expect(g, "<=", 1)
		expect(b, "<=", 1)
		if a then
			expect(a, ">=", 0)
			expect(a, "<=", 1)
		end
	end
	
	for i, border in pairs(self.borders) do
		border:SetTexture(r, g, b, a)
	end
end

function SharpBorder:SetShadowColor(r, g, b, a)
	if DEBUG then
		expect(r, "typeof", "number")
		expect(g, "typeof", "number")
		expect(b, "typeof", "number")
		expect(a, "typeof", "number;nil")
		expect(r, ">=", 0)
		expect(g, ">=", 0)
		expect(b, ">=", 0)
		expect(r, "<=", 1)
		expect(g, "<=", 1)
		expect(b, "<=", 1)
		if a then
			expect(a, ">=", 0)
			expect(a, "<=", 1)
		end
	end
	
	for i, shadow in pairs(self.shadows) do
		shadow:SetTexture(r, g, b, a)
	end
end

local function _OnCreate(self)
	for fname, func in pairs(SharpBorder) do
		self[fname] = func
	end
	self.borders = {}
	self.shadows = {}
end

local function _OnRetreive(self)
	for i, name in pairs(borderPositions) do		
		self.borders[name] = Objects:GetTexture(self._parent, "OVERLAY", 7)
		self.shadows[name] = Objects:GetTexture(self._parent, "OVERLAY", 6)
	end
	
	self.borderWidth = 1
	self.shadowWidth = 3
end

local function _OnDelete(self)
	for i, name in pairs(borderPositions) do
		self.borders[name]:Delete()
		self.shadows[name]:Delete()
	end
	wipe(self.borders)
	wipe(self.shadows)
	self.width = nil
	self.height = nil
	self.shadowWidth = nil
	self.borderWidth = nil
end

Objects:CreateNewType("SharpBorder", "Frame", _OnCreate, _OnRetreive, _OnDelete)