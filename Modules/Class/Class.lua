local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local name, globalPlugin = ...
local plugin = mUI:NewModule("Class", "AceEvent-3.0")
setmetatable(globalPlugin, {
	__index = plugin
})

local db, gdb

plugin:SetName("Class")
plugin:SetDescription("Base addon for separate class addons.")
plugin:SetDefaults({
	Enabled = true,
})

db = plugin.db.profile

function plugin:OnInitialize()	
end

function plugin:OnEnable()
	self:OnProfileChanged()
end

function plugin:OnDisable()
end

function plugin:OnProfileChanged()
	db = self.db.profile
	gdb = mUI.db.profile	
	
	self:ApplySettings()
	
	self:LoadModules()
end

function plugin:ApplySettings()
end

plugin:SetOptions(function(self)
	local order = 1
	local function newOrder()
		order = order + 1
		return order
	end
	
	return "Modules", self:GetModuleOptions()
end)

mUI:Modularize(name, plugin)