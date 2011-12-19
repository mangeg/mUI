local name, addon_table = ...

-- Up Values
local _G = _G
local DEBUG = addon_table.DEBUG
local Debug = addon_table.Debug
local expect = Debug.expect

local Objects = addon_table.Objects

local Padding = 4

-- Anchor prototype
local AnchorPrototype = {}

--- Fade out the anchor instead of instant hiding
-- @name Anchor:FadeOut
function AnchorPrototype:FadeOut()
	self.Alpha.target = 0
	self.Alpha:SetChange(-1)
	self.ag:Play()
end

local function OnEnter(self)
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine(CLOSE)
	GameTooltip:Show()
end

local function OnLeave(self)
	GameTooltip:Hide()
end

local function OnClick(this, button, ...)
	local self = this:GetParent()
	self.Alpha.target = 0
	self.Alpha:SetChange(-1)
	self.ag:Play()
end

local function OnShow(self)
	self.ag:Stop()
	self.Alpha.target = 1
	self.Alpha:SetChange(1)
	self:SetAlpha(0)
	self.ag:Play()
end

local function AlpaFinished(this)
	self = this.obj
	if self.Alpha.target == 0 then
		self:Hide()
	else
		self:SetAlpha(self.Alpha.target)
	end
end

local function _OnCreate(self)
	for fname, func in pairs(AnchorPrototype) do
		self[fname] = func
	end	
	
	self.ag = self:CreateAnimationGroup()	
	self.ag:SetScript("OnFinished", AlpaFinished)
	self.ag.obj = self
end

local Backdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeSize = 2,
	insets = { left = 1, right = 1, top = 1, bottom = 1 }
}
local function _OnRetreive(self)	
	self:SetBackdrop(Backdrop)
	self:SetBackdropColor(41/255, 101/255, 123/255)
	self:SetBackdropBorderColor(0.86, 0.53, 0.24)
	
	self:SetScript("OnShow", OnShow)
	self:SetScript("OnSizeChanged", function(self, w, h)
		self.Button:SetWidth(h - Padding * 2)
	end)
	
	local button = Objects:GetButton(self)
	button:SetPoint("TOPRIGHT", -Padding, -Padding)
	button:SetPoint("BOTTOMRIGHT", -Padding, Padding)	
	button:SetNormalTexture([[Interface\AddOns\RaidWatch3\Media\Buttons\ButtonClose_Up]])
	button:SetPushedTexture([[Interface\AddOns\RaidWatch3\Media\Buttons\ButtonClose_Down]])
	button:SetHighlightTexture([[Interface\AddOns\RaidWatch3\Media\Buttons\ButtonHighlight]])
	button:SetScript("OnEnter", OnEnter)
	button:SetScript("OnLeave", OnLeave)	
	button:SetScript("OnClick", OnClick)
	button:RegisterForClicks("LeftButtonUp")
	self.Button = button	
	
	local text = Objects:GetFontString(self)
	text:SetPoint("TOPLEFT")
	text:SetPoint("BOTTOMLEFT")
	text:SetPoint("RIGHT", self.Button, "LEFT")
	text:SetText("Test Text")
	text:SetFontSize(16)
	text:SetTextColor(0.86, 0.53, 0.24)
	self.Text = text
	
	local alpha = Objects:GetAlpha(self.ag)	
	alpha:SetSmoothing("IN")
	alpha:SetDuration(0.4)
	self.Alpha = alpha
	
	self:RegisterForDrag("LeftButton")
	self:SetMovable(true)
	self:EnableMouse(true)
	
	self:SetWidth(250)
	self:SetHeight(30)
	self:Hide()
end

local function _OnDelete(self)
	self.Text = self.Text:Delete()
	self.Button = self.Button:Delete()
	self.Alpha = self.Alpha:Delete()
end

Objects:CreateNewType("Anchor", "Frame", _OnCreate, _OnRetreive, _OnDelete)