local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local name, plugin = ...
local plugin = mUI:NewModule("Unitframes", plugin, "AceEvent-3.0")

local LSM = LibStub("LibSharedMedia-3.0")

local oUF = oUF

local db, gdb
local layout
local modulePattern = "mUI_%a*_%a*$"

local function SpellName(spellID)
	local name = GetSpellInfo(spellID)
	return name
end

function plugin:OnInitialize()
	local defaults = {
		profile = {
			Modules = {
				["**"] = {
					Enabled = true,
				},
			},
		},
	}

	self.db = mUI.db:RegisterNamespace(self:GetName(), defaults)
	defaults = nil
	
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")		
	
	db = self.db.profile
	
	mUI:CheckAndLoadModules(modulePattern)
	
	self:AddOptions()
end

function plugin:OnEnable()
	mUI.RegisterCallback(self, "GlobalsChanged")
end

function plugin:ProfileChanged()
	db = self.db.profile
	gdb = mUI.db.profile
	
	self:GlobalsChanged()
end

function plugin:GlobalsChanged()
end

function plugin:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

