local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end
local UF = mUI:GetModule("Unitframes")
if not UF then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local name, globalPlugin = ...
local plugin = UF:NewModule("HealthBar", "AceEvent-3.0")

plugin:SetName("Health bar")
plugin:SetDescription("Provides health bars for unitframes")
plugin:SetDefaults({
})