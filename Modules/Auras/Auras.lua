local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local name, globalPlugin = ...
local plugin = mUI:NewModule("Auras", "AceEvent-3.0")
setmetatable(globalPlugin, {
	__index = plugin
})

plugin:SetName("Auras")
plugin:SetDescription("Replacement for the default buff and debuff display")
plugin:SetDefaults({
	Enabled = true,
})