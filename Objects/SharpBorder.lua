local name, addon_table = ...

-- Up Values
local _G = _G
local DEBUG = addon_table.DEBUG
local Debug = addon_table.Debug
local expect = Debug.expect

local Objects = addon_table.Objects

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

local SharpBorder = {}

local function _OnCreate(self)
	for fname, func in pairs(SharpBorder) do
		self[fname] = func
	end	
end

local function _OnRetreive(self)
end

local function _OnDelete(self)
end

Objects:CreateNewType("SharpBorder", "Frame", _OnCreate, _OnRetreive, _OnDelete)