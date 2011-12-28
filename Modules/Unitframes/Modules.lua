local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local plugin = mUI:GetModule("Unitframes")
if not plugin then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local newModules = {}
function plugin:OnModuleCreated(module)
	local id = module.moduleName
	if DEBUG then
		expect(id, "typeof", "string")
	end
	
	module.id = id
	self[id] = module
	
	tinsert(newModules, module)
end

do
	local event = {}
	LibStub("AceEvent-3.0").RegisterEvent(event, "ADDON_LOADED", function(event, addon)
		if not plugin.Options or not plugin.Options.HandleModuleLoaded then
			return
		end
		while true do
			local module = table.remove(newModules, 1)
			if not module then
				break
			end	
			plugin.Options:HandleModuleLoaded(module)
			plugin:CallFunctionOnModules("OnModuleLoaded", module)
		end
	end)
end

local Module = {}
plugin:SetDefaultModulePrototype(Module)

Module.SetName = plugin.SetName
Module.SetDescription = plugin.SetDescription

local function createModuleDB(module, defaults)
	if DEBUG then
		expect(module, "typeof", "table")
		expect(defaults, "typeof", "table")
	end
	
	local db = mUI.db:RegisterNamespace(module.id, {
		profile = defaults
	})
	module.db = db

	mUI.db.SetProfile(db, mUI.db:GetCurrentProfile())
	
	if not db.profile.enabled then
		module:Disable()
	end
end

function Module:SetDefaults(defaults)
	if DEBUG then
		expect(defaults, "typeof", "table")
	end
	
	createModuleDB(self, defaults)
end