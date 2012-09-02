local name, addon_table = ...

-- Up Values
local _G = _G
local DEBUG = addon_table.DEBUG
local Debug = addon_table.Debug
local expect = Debug.expect

local cache = {}
local active = {}
local ObjectCount = {}

--Debug:AddGlobal("ControlCache", cache)
--Debug:AddGlobal("ControlActive", active)

local Objects = {}
addon_table.Objects = Objects

local ObjectPrototype = {}
local SpecialObjectProtoypes = {}
local DeleteFuncs = {}
local RetrieveFuncs = {}

local frame = CreateFrame("Frame")
local AnimCache = frame:CreateAnimationGroup()
local DefaultFont, DefaultFontSize = GameFontNormal:GetFont()
local DefaultFontColor = {GameFontNormal:GetTextColor()}

local function CallObjectFunc(object, functionName, ...)
	if object[functionName] then
		object[functionName](object, ...)
	end
end

local function CreateObject(otype, name, parent, template, ...)
	if otype == "Texture" then
		return parent:CreateTexture(name, "BACKGROUND", 0)
	end
	if otype == "FontString" then
		return parent:CreateFontString(name, "BACKGROUND", template)
	end
	if otype == "Alpha" or otype == "Rotation" or otype == "Scale" or otype == "Translation" then
		return parent:CreateAnimation(otype, name, template, ...)
	end
	return CreateFrame(otype, name, parent, template, ...)
end

local function GetCacheObject(otype, customType, parent, realType, _OnCreate, _OnRetrieve, _OnDelete, template)
	ocache = cache[otype]
	if not ocache then
		ocache = {}
		cache[otype] = ocache
		ObjectCount[otype] = 1
	end
	
	local control = next(ocache)
	
	-- Create new control
	if not control then
		local name = ("%s_%s_%d"):format(name, otype, ObjectCount[otype])
		control = CreateObject(customType and realType or otype, name, parent, template)
		ObjectCount[otype] = ObjectCount[otype] + 1
		
		control.otype = otype
		
		for fname, func in pairs(ObjectPrototype) do
			control[fname] = func
		end
		
		if SpecialObjectProtoypes[otype] then
			for fname, func in pairs(SpecialObjectProtoypes[otype]) do
				control[fname] = func
			end
		end
		
		if _OnCreate then
			_OnCreate(control)
		end
	else
		ocache[control] = nil
		active[otype][control] = control
		control._OnDelete = _OnDelete
		return control
	end
	
	control._OnDelete = _OnDelete
	
	active[otype] = active[otype] or {}
	active[otype][control] = control	
	
	return control
end

local function GetObject(otype, customType, parent, ...)
	if DEBUG then
		expect(otype, "typeof", "string")
		expect(parent, "typeof", "frame")
	end

	local control = GetCacheObject(otype, customType, parent, ...)
	control._parent = parent
	
	
	local _OnRetrieve
	if customType then
		_, _, _OnRetrieve = ...
	end
	
	if _OnRetrieve then
		_OnRetrieve(control, select(6, ...))
	end
	
	CallObjectFunc(control, "SetParent", parent)
	CallObjectFunc(control, "Show")
	CallObjectFunc(control, "ClearAllPoints")
	
	return control
end

--- Get a frame object
-- @param parent Parent of frame type.
function Objects:GetFrame(parent)
	if DEBUG then
		expect(parent, "typeof", "frame")
	end
	
	return GetObject("Frame", false, parent)
end

--- Get a button object
-- @param parent Parent of frame type.
function Objects:GetButton(parent)
	if DEBUG then
		expect(parent, "typeof", "frame")
	end
	
	return GetObject("Button", false, parent)
end

--- Get a statusbarobject
-- @param parent Parent of frametype
function Objects:GetStatusBar(parent, strata, level)
	if DEBUG then
		expect(parent, "typeof", "frame")
	end
	
	local control = GetObject("StatusBar", false, parent)
	RetrieveFuncs.StatusBar(control, strata or "MEDIUM", level or 2)
	return control
end

--- Get a texture object
-- @param parent Parent of frametype.
-- @param layer Drawlayer
-- @param subLevel Sublevel within the drawlayer
function Objects:GetTexture(parent, layer, subLevel)
	if DEBUG then
		expect(parent, "typeof", "frame")
		expect(layer, "typeof", "string;nil")		
		expect(subLevel, "typeof", "number;nil")
		if layer then
			expect(layer, "inset", "BACKGROUND;BORDER;ARTWORK;OVERLAY;HIGHLIGHT")
		end
	end
	
	local control = GetObject("Texture", false, parent)
	RetrieveFuncs.Texture(control, layer, subLevel)
	
	return control
end

--- Get a FontString object
-- @param parent Parent of frame type
-- @param layer optional Drawlayer
-- @param inherit Template to inheerit from (GameFontNormal and so on)
-- @param subLevel Sublevel within the drawlayer.
function Objects:GetFontString(parent, layer, inherit, subLevel)
	if DEBUG then
		expect(parent, "typeof", "frame")		
		expect(layer, "typeof", "string;nil")
		expect(inherit, "typeof", "string;nil")
		expect(subLevel, "typeof", "number;nil")
		if layer then
			expect(layer, "inset", "BACKGROUND;BORDER;ARTWORK;OVERLAY;HIGHLIGHT")
		end
		if inherit then
			expect(inherit, "inset", _G)
		end
	end
	
	local control = GetObject("FontString", false, parent)
	RetrieveFuncs.FontString(control, layer, inherit, subLevel)
	return control
end

--- Get an alpha animation object
-- @param parent Parent of type AnimationGroup
function Objects:GetAlpha(parent)
	if DEBUG then
		expect(parent, "frametype", "AnimationGroup")
	end
	
	return  GetObject("Alpha", false, parent)
end

--- Get a translation anaimation object
-- @param parent Parent of type AnimationGroup
function Objects:GetTranslation(parent)
	if DEBUG then
		expect(parent, "frametype", "AnimationGroup")
	end
	
	return GetObject("Translation", false, parent)
end

--- Get a rotation animation object
-- @param parent Parent of type AnimationGroup
function Objects:GetRotation(parent)
	if DEBUG then
		expect(parent, "frametype", "AnimationGroup")
	end
	
	return GetObject("Rotation", false, parent)
end

--- Get a scale animation object
-- @param parent Parent of type AnimationGroup
function Objects:GetScale(parent)
	if DEBUG then
		expect(parent, "frametype", "AnimationGroup")
	end
	
	return GetObject("Scale", false, parent)
end

--- Create a new custom object type
-- @param name Name of the new type
-- @param realType Real frametype that this new type is based on
-- @param _OnCreate Function to call when first creating the object
-- @param _OnRetrieve Function to call each time an object of this type is pulled from the cache
-- @param _OnDelete Function to call when returning an object to the cache
-- @param template optional Teamplate to inherit this object from 
function Objects:CreateNewType(name, realType, _OnCreate, _OnRetrieve, _OnDelete, template, ...)
	if DEBUG then
		expect(name, "typeof", "string")
		expect(Objects["Get"..name], "typeof", "nil")
		expect(realType, "typeof", "string")
		expect(_OnCreate, "typeof", "function")
		expect(_OnRetrieve, "typeof", "function")
		expect(_OnDelete, "typeof", "function")
		expect(template, "typeof", "string;nil")
	end
	
	Objects["Get"..name] = function(self, parent, ...)
		return GetObject(name, true, parent, realType, _OnCreate, _OnRetrieve, _OnDelete, template, ...)
	end
end

----------------------------------------
-- Retrieve functions
function RetrieveFuncs:Texture(layer, subLevel)	
	self:SetDrawLayer(layer or "BACKGROUND", subLevel or 0)
end

function RetrieveFuncs:StatusBar(strata, level)
	self:SetFrameStrata(strata)
	self:SetFrameLevel(level)
end

function RetrieveFuncs:FontString(layer, template, subLevel)	
	self:SetDrawLayer(layer or "BACKGROUND", subLevel)
	local font, fontsize, flags = template and _G[template]:GetFont() or DefaultFont, DefaultFontSize, nil
	self:SetFont(font, fontsize, flags)
	self:SetFontObject(_G[template] or _G["GameFontNormal"])
end

----------------------------------------
-- Delete functions

function DeleteFuncs:Button()
	self:RegisterForClicks("LeftButtonUp")
	self:SetScript("OnClick", nil)
	self:SetScript("OnDoubleClick", nil)
end

function DeleteFuncs:Texture()
	self:SetTexture(nil)
	self:SetSize(0, 0)
	self:SetVertexColor(1, 1, 1, 1)
	self:SetDrawLayer("BACKGROUND", 0)
end

function DeleteFuncs:FontString()
	self:SetText()
	self:SetJustifyH("CENTER")
	self:SetJustifyV("MIDDLE")
	self:SetNonSpaceWrap(false)
	self:SetTextColor(unpack(DefaultFontColor))
	self:SetFont(DefaultFont, DefaultFontSize, nil)
	self:SetFontObject(nil)
end

function DeleteFuncs:StatusBar()
	--self:SetRotatesTexture(nil) TODO: Check why this crashes the game
	self:SetStatusBarColor(1, 1, 1, 1)
	self:SetStatusBarTexture(nil)
	self:SetMinMaxValues(0, 1)
	self:SetValue(1)
	self:SetOrientation("HORIZONTAL")	
end

function DeleteFuncs:Animation()
	self:Stop()
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnEvent", nil)
	self:SetScript("OnFinished", nil)
	self:SetScript("OnPause", nil)
	self:SetScript("OnPlay", nil)
	self:SetScript("OnStop", nil)
	self:SetDuration(0)
	self:SetOrder(1)
	self:SetMaxFramerate(0)
	self:SetSmoothing("NONE")
	self:SetStartDelay(0)
	self:SetEndDelay(0)
	self:SetParent(AnimCache)
end

function DeleteFuncs:Alpha()
	self:SetChange(0)
	DeleteFuncs.Animation(self)
end

function DeleteFuncs:Translation()
	self:SetOffset(0, 0)
	DeleteFuncs.Animation(self)
end

function DeleteFuncs:Rotation()
	self:SetDegrees(0)
	self:SetRadians(0)
	self:SetOrigin("CENTER", 0, 0)
	DeleteFuncs.Animation(self)
end

function DeleteFuncs:Scale()
	self:SetScale(1, 1)
	self:SetOrigin("CENTER", 0, 0)
	DeleteFuncs.Animation(self)
end


-- Prototype functions

--- Delete an object and return it to the cache.
-- @name Object:Delete
function ObjectPrototype:Delete()
	local otype = self.otype
	
	if self._OnDelete then
		self:_OnDelete()
		self._OnDelete = nil
	end
	
	if DeleteFuncs[otype] then
		DeleteFuncs[otype](self)
	end
	
	CallObjectFunc(self, "ClearAllPoints")
	CallObjectFunc(self, "Hide")
	CallObjectFunc(self, "SetPoint", "BOTTOM", UIParent, "TOP", 0, 10)
	CallObjectFunc(self, "SetParent", self.GetProgress and AnimCache or UIParent)
	CallObjectFunc(self, "SetAlpha", 1)
	CallObjectFunc(self, "SetScale", 1)
	CallObjectFunc(self, "SetWidth", 0)
	CallObjectFunc(self, "SetHeight", 0)
	CallObjectFunc(self, "SetMovable", false)
	CallObjectFunc(self, "RegisterForDrag", nil)
	CallObjectFunc(self, "EnableMouse", false)
	
	self._parent = nil
	
	active[otype][self] = nil
	cache[otype][self] = self
end

-- FontString prototype
local FontStringPrototype = {}
SpecialObjectProtoypes.FontString = FontStringPrototype

--- Set the font size
-- @name FontString:SetFontSize
-- @param size Font size
function FontStringPrototype:SetFontSize(size)
	if DEBUG then
		expect(size, "typeof", "number")
	end
	local font, _, flags = self:GetFont()
	self:SetFont(font, size, flags)
end