local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local name, globalPlugin = ...
local plugin = mUI:NewModule("Monk", "AceEvent-3.0")
setmetatable(globalPlugin, {
	__index = plugin
})

local db, gdb

plugin:SetName("Monk")
plugin:SetDescription("Collection of helpful Monk addons.")
plugin:SetDefaults({
	Enabled = true,
	HideBlizz = true,
})

db = plugin.db.profile

function plugin:OnInitialize()	
end

function plugin:OnEnable()
	self:OnProfileChanged()
end

function plugin:OnDisable()
	PlayerFrameAlternateManaBar:Show()
	MonkHarmonyBar:Show()
end

function plugin:OnProfileChanged()
	db = self.db.profile
	gdb = mUI.db.profile	
	
	self:ApplySettings()
end

function plugin:ApplySettings()
	if db.HideBlizz then
		MonkHarmonyBar:Hide()
		PlayerFrameAlternateManaBar:Hide()
	else
		MonkHarmonyBar:Show()
		PlayerFrameAlternateManaBar:Show()
	end
end

plugin:SetOptions(function(self)
	local order = 1
	local function newOrder()
		order = order + 1
		return order
	end
	
	return "HideBlizz", {
		type = "toggle",
		name = "Hide blizzard default",
		get = function(info)
			return mUI.AceGUIGet(plugin.db.profile, info)
		end,
		set = function(info, ...)
			mUI.AceGUISet(plugin.db.profile, info, ...)
			plugin:ApplySettings()
		end
	}
end)