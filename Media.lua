local name, mUI = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local LSM = LibStub("LibSharedMedia-3.0")

local Objects = mUI.Objects

local media = {}
mUI.Media = media

media.Textures = {}
media.Textures.Blank = [[Interface\BUTTONS\WHITE8X8]]

Debug:AddGlobal("Media", media)

local strings = {}

function updateString(text)
	local scale = mUI.db.profile.Media.Fonts.Normal.Scale
	local font, size, flags = text:GetFont()	
	local oldScale = text.oldScale or 1
	
	if not text.overrides.flags then
		flags = mUI.db.profile.Media.Fonts.Normal.Flags
	else
		flags = text.overrides.flags
	end
	
	if not text.overrides.font then
		font = LSM:Fetch("font", mUI.db.profile.Media.Fonts.Normal.Font)
	else
		font = LSM:Fetch("font", text.overrides.font)
	end		
	
	text:SetFont(font, size / oldScale * scale, flags)
	
	if mUI.db.profile.Media.Fonts.Normal.UseClassColor then
		text:SetTextColor(unpack(mUI.db.profile.Colors.Class[mUI.pClass]))
	else
		if not text.overrides.color then
			text:SetTextColor(unpack(mUI.db.profile.Media.Fonts.Normal.Color))
		else
			text:SetTextColor(unpack(text.overrides.color))
		end
	end
	
	if not text.overrides.shadowcolor then
		text:SetShadowColor(unpack(mUI.db.profile.Media.Fonts.Normal.ShadowColor))
	else
		text:SetShadowColor(unpack(text.overrides.shadowcolor))
	end	
	
	if not text.overrides.shadowoffset then
		text:SetShadowOffset(mUI.db.profile.Media.Fonts.Normal.ShadowOffsetX, mUI.db.profile.Media.Fonts.Normal.ShadowOffsetY)	
	else
		text:SetShadowOffset(text.overrides.shadowoffset[1], text.overrides.shadowoffset[2])
	end
	
	text.oldScale = scale
end

function deleteText(text)
	strings[text] = nil
	text.Delete = text._OldDelete
	text._OldDelete = nil
	text.Update = nil
	text.overrides = mUI:Del(text.overrides)
	text = text:Delete()
end

function media:GetFontString(parent, ...)
	local text = Objects:GetFontString(parent, ...)
	text._OldDelete = text.Delete
	text.Delete = deleteText
	text.Update = updateString
	
	text.overrides = mUI:New()
	
	updateString(text)
	
	strings[text] = true
	return text
end

function media:UpdateStrings()
	for text in pairs(strings) do
		text:Update()
	end
end

