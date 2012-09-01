local name, addon_table = ...

-- Up Values
local _G = _G
local DEBUG = addon_table.DEBUG
local Debug = addon_table.Debug
local expect = Debug.expect

local Objects = addon_table.Objects

local c1 = 1/3	
local c2 = 1 - c1

local borderNumbers = {}
local bordersPos = {
	"TOPLEFT",
	"TOPRIGHT",
	"BOTTOMLEFT",
	"BOTTOMRIGHT",
	"TOP",
	"BOTTOM",
	"LEFT",
	"RIGHT",		
}
for i, name in pairs(bordersPos) do
	borderNumbers[name] = i
end
local borderCoords = {
	TOPLEFT 	= { 0, c1,  0, c1},
	TOPRIGHT 	= {c2,  1,  0, c1},
	BOTTOMLEFT 	= { 0, c1, c2,  1},
	BOTTOMRIGHT = {c2,  1, c2,  1},
	TOP 		= {c1, c2,  0, c1},
	BOTTOM 		= {c1, c2, c2,  1},
	LEFT 		= { 0, c1, c1, c2},
	RIGHT 		= {c2,  1, c1, c2},		
}

-- Border prototype
local BorderPrototype = {}

--- Set texture
-- @name Border:SetTexture
-- @param texture Texture to set
function BorderPrototype:SetTexture(texture, isBlizz)
	if DEBUG then
		expect(texture, "typeof", "string;table")
	end
	
	if type(texture) == "table" then
		for i, border in pairs(self.borders) do
			if i == 1 then
				border:SetTexCoord(0, 0.5, 0, 0.5)
				border:SetTexture(texture[1])
			elseif i == 2 then
				border:SetTexCoord(0.5, 1, 0, 0.5)
				border:SetTexture(texture[1])
			elseif i == 3 then
				border:SetTexCoord(0, 0.5, 0.5, 1)
				border:SetTexture(texture[1])
			elseif i == 4 then
				border:SetTexCoord(0.5, 1, 0.5, 1)
				border:SetTexture(texture[1])
			else
				border:SetTexCoord(0, 1, 0, 1)
				border:SetTexture(texture[i-3])
			end
		end
	else
		local w, h
		for i, border in pairs(self.borders) do		
			border:SetTexture(nil)
			border:SetTexCoord(0, 1, 0, 1)			
			border:ClearAllPoints()
			border:SetPoint("CENTER")
			border:SetSize(0, 0)
			border:SetTexture(texture, true)
			w, h = border:GetSize()
			border:SetSize(self.borderWidth, self.borderWidth)
		end
		
		if not isBlizz then
			self:SetNormalCoords()
		else
			self:SetBlizzCoords()
		end
		self:SetAnchor()
	end
	
end

--- Set the coords used to the normal ones, for a square texture.
-- @name Border:SetNormalCoords
function BorderPrototype:SetNormalCoords()
	for i, border in pairs(self.borders) do
		local coords = borderCoords[bordersPos[i]]
		border:SetTexCoord(unpack(coords))
	end
end

--- Set the cords used to the blizzard format.
-- @name Border:SetBlizzCoords
function BorderPrototype:SetBlizzCoords()
	for i, border in pairs(self.borders) do
		local h = self.height - self.borderWidth * 2
		local w = self.width - self.borderWidth * 2
		if i == 1 then
			border:SetTexCoord(0.5, 0.625, 0, 1)
		elseif i == 2 then
			border:SetTexCoord(0.625, 0.75, 0, 1)
		elseif i == 3 then
			border:SetTexCoord(0.75, 0.875, 0, 1)
		elseif i == 4 then
			border:SetTexCoord(0.875, 1, 0, 1)
		elseif i == 5 then
			border:SetTexCoord(0.25, 0, 0.375, 0, 0.25, w / self.borderWidth, 0.375, w / self.borderWidth)
		elseif i == 6 then
			border:SetTexCoord(0.375, 0, 0.5, 0, 0.375, w / self.borderWidth, 0.5, w / self.borderWidth)
		elseif i == 7 then
			border:SetTexCoord(0, 0.125, 0, h / self.borderWidth)
		elseif i == 8 then
			border:SetTexCoord(0.125, 0.25, 0, h / self.borderWidth)
		end
	end
end

--- Set the width of the border
-- @name Border:SetWidth
-- @param width Width to set
function BorderPrototype:SetWidth(width)
	if DEBUG then
		expect(width, "typeof", "number")
		expect(width, ">=", 0)
	end
	self.borderWidth = width
	for i, border in pairs(self.borders) do
		border:SetSize(width, width)
	end
	self:SetAnchor()
end

--- Set the frame that the border should anchor to
-- @param anchor Anchor of frame type, or nil to use the borders parent.
function BorderPrototype:SetAnchor(anchor)
	if DEBUG then
		expect(anchor, "typeof", "frame;nil")
	end
	
	local anchor = anchor or self.borders[1]:GetParent()
	
	self:SetParent(anchor)
	self:ClearAllPoints()
	self:SetAllPoints(anchor)
	self.width, self.height = anchor:GetSize()	
	local offset = 0.25
	
	--[[
	for i, border in pairs(self.borders) do
		if i == 1 then
			border:SetPoint("TOPLEFT", anchor)
		elseif i == 2 then
			border:SetPoint("TOPRIGHT", anchor)
		elseif i == 3 then
			border:SetPoint("BOTTOMLEFT", anchor)
		elseif i == 4 then
			border:SetPoint("BOTTOMRIGHT", anchor)
		elseif i == 5 then
			border:SetPoint("TOPLEFT", self.borders[1], "TOPRIGHT", -offset, 0)
			border:SetPoint("TOPRIGHT", self.borders[2], "TOPLEFT", offset, 0)
		elseif i == 6 then
			border:SetPoint("BOTTOMLEFT", self.borders[3], "BOTTOMRIGHT", -offset, 0)
			border:SetPoint("BOTTOMRIGHT", self.borders[4], "BOTTOMLEFT", offset, 0)
		elseif i == 7 then
			border:SetPoint("TOPLEFT", self.borders[1], "BOTTOMLEFT", 0, offset)			
			border:SetPoint("BOTTOMLEFT", self.borders[3], "TOPLEFT", 0, -offset)
		elseif i == 8 then
			border:SetPoint("TOPRIGHT", self.borders[2], "BOTTOMRIGHT", 0, offset)
			border:SetPoint("BOTTOMRIGHT", self.borders[4], "TOPRIGHT", 0, -offset)
		end
	end
	--]]
	--[[
	for i, border in pairs(self.borders) do
		if i == 1 then
			border:SetPoint("TOPLEFT", anchor)
		elseif i == 2 then
			border:SetPoint("TOPLEFT", self.borders[5], "TOPRIGHT")
		elseif i == 3 then
			border:SetPoint("TOPLEFT", self.borders[7], "BOTTOMLEFT")
		elseif i == 4 then
			border:SetPoint("BOTTOMLEFT", self.borders[6], "BOTTOMRIGHT")
		elseif i == 5 then
			border:SetPoint("TOPLEFT", self.borders[1], "TOPRIGHT")
			border:SetPoint("TOPRIGHT", anchor, -self.borderWidth, 0)
		elseif i == 6 then	
			border:SetPoint("BOTTOMLEFT", self.borders[3], "BOTTOMRIGHT")
			border:SetPoint("BOTTOMRIGHT", anchor, -self.borderWidth, 0)
		elseif i == 7 then
			border:SetPoint("TOPLEFT", self.borders[1], "BOTTOMLEFT")
			border:SetPoint("BOTTOMLEFT", anchor, 0, self.borderWidth)
		elseif i == 8 then
			border:SetPoint("TOPRIGHT", self.borders[2], "BOTTOMRIGHT")
			border:SetPoint("BOTTOMRIGHT", self.borders[4], "TOPRIGHT")
		end
	end
	--]]
	
	for i, border in pairs(self.borders) do
		local anchorPoint = bordersPos[i]
		border:SetPoint(anchorPoint, anchor)
		if i > 4 then
			if i == 5 then
				border:SetPoint("LEFT", self.borders[borderNumbers["TOPLEFT"]], "RIGHT")
				border:SetPoint("RIGHT", self.borders[borderNumbers["TOPRIGHT"]], "LEFT")
			elseif i == 6 then
				border:SetPoint("LEFT", self.borders[borderNumbers["BOTTOMLEFT"]], "RIGHT")
				border:SetPoint("RIGHT", self.borders[borderNumbers["BOTTOMRIGHT"]], "LEFT")
			elseif i == 7 then
				border:SetPoint("TOP", self.borders[borderNumbers["TOPLEFT"]], "BOTTOM")
				border:SetPoint("BOTTOM", self.borders[borderNumbers["BOTTOMLEFT"]], "TOP")
			elseif i == 8 then
				border:SetPoint("TOP", self.borders[borderNumbers["TOPRIGHT"]], "BOTTOM")
				border:SetPoint("BOTTOM", self.borders[borderNumbers["BOTTOMRIGHT"]], "TOP")
			end
		end
	end
end

--- Set the color of the border
-- @name Border:SetColor
-- @param r Red value 0-1
-- @param g Green value 0-1
-- @param b Blue value 0-1
-- @param a optional Alpha value, default is 1
function BorderPrototype:SetColor(r, g, b, a)
	for i, border in pairs(self.borders) do
		border:SetVertexColor(r, g, b, a or 1)
	end
end

local function _OnCreate(self)
	for fname, func in pairs(BorderPrototype) do
		self[fname] = func
	end
	
	self.borders = {}
end

local function _OnRetreive(self)
	for i = 1, 8 do
		local border = Objects:GetTexture(self._parent, "OVERLAY", 7)
		tinsert(self.borders, border)
	end
	
	self:SetScript("OnSizeChanged", function(self, width, height)
		self.width = width
		self.height = height
	end)
	
	self.borderWidth = 10
	self.width = 100
	self.height = 100
	
	self:SetAnchor()
end

local function _OnDelete(self)
	self:SetScript("OnSizeChanged", nil)
	for i, border in pairs(self.borders) do
		border:Delete()
	end
	wipe(self.borders)	
	
	self.width = nil
	self.height = nil
end

Objects:CreateNewType("Border", "Frame", _OnCreate, _OnRetreive, _OnDelete)