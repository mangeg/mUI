--- mUI.Module
-- @module mUI.Module

local name, mUI = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

mUI.ModulesNotLoaded = {}

local function enabledModulesIterator(modules, id)
	local id, module = next(modules, id)
	if not id then
		return nil
	end
	if not module:IsEnabled() then
		return enabledModulesIterator(modules, id)
	end
	return id, module
end

function mUI:IterateEnabledModules()
	return enabledModulesIterator, self.modules, nil	
end

--- Get a module by addon ID
-- @param id The full base name of the module
-- @usage module = mUI:GetModuleByID("mUI_Unitframes")
function mUI:GetModuleByID(id)
	if DEBUG then
		expect(id, "typeof", "string")
	end
	
	for name, module in self:IterateModules() do
		if module.baseName == id then
			return module
		end
	end
end

--- Enable a module and update the enabled state in the modules db
-- @param module
function mUI:EnableModuleState(module)
	if DEBUG then
		expect(module, "typeof", "table")
		expect(module.Enable, "typeof", "function")
	end

	if module:IsEnabled() then
		return
	end
	
	module.db.profile.Enabled = true
	module:Enable()
end

--- Disable a module and update the enabled state in the db.
-- @param module
function mUI:DisableModuleState(module)
	if DEBUG then
		expect(module, "typeof", "table")
		expect(module.Disable, "typeof", "function")
	end

	if not module:IsEnabled() then
		return
	end
	
	module.db.profile.Enabled = false
	module:Disable()
end

--- Load a load on demand module that is not loaded yet
-- @param id ID of the module to load, blizzard ID.
-- @param moduleName The real name of the module.
function mUI:LoadAndEnableModule(id, moduleName)
	local loaded, reason = LoadAddOn(id)
	if loaded then
		local module = self:GetModuleByID(id)
		assert(module)
		Debug:Print("Loaded module", module.baseName)
		self:EnableModuleState(module)
	else
		if reason then
			reason = _G["ADDON_"..reason]
		end
		if not reason then
			reason = UNKNOWN
		end
		DEFAULT_CHAT_FRAME:AddMessage(format(L["%s: Could not load module '%s': %s"], name, moduleName or id, reason))
	end
end

local newModules = {}
function mUI:OnModuleCreated(module)
	local id = module.moduleName
	if DEBUG then
		expect(id, "typeof", "string")
	end
	module.id = id
	self[id] = module
			
	tinsert(newModules, module)
end

--- Prototype for all modules.
-- @type table
local Module = {}
mUI:SetDefaultModulePrototype(Module)

do
	local event = {}
	LibStub("AceEvent-3.0").RegisterEvent(event, "ADDON_LOADED", function(event, addon)
		if not mUI.Options or not mUI.Options.HandleModuleLoaded then
			return
		end	
		while true do
			local module = table.remove(newModules, 1)
			if not module then
				break
			end
			
			mUI.Options:HandleModuleLoaded(module)
			mUI:CallFunctionOnModules("OnModuleLoaded", module)
		end
	end)
end

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
	
	if not db.profile.Enabled then
		module:Disable()
	else
		mUI:CallFunctionOnModule(module, "OnProfileChanged")
	end
end

--- Set the defaults for the module
-- @param defaults Table with the default values to be inserted into the profile.
function Module:SetDefaults(defaults)
	if DEBUG then
		expect(defaults, "typeof", "table")
	end
	
	createModuleDB(self, defaults)
end

--- Set the name of the module
-- @param name
-- @usage module:SetName("The One Module")
function Module:SetName(name)
	if DEBUG then
		expect(name, "typeof", "string")
	end
	
	self.name = name
end

--- Set the description of ht emodule
-- @param description
-- @usage module:SetDescription("Can handle many things and do great things")
function Module:SetDescription(description)
	if DEBUG then
		expect(description, "typeof", "string")
	end
	
	self.description = description
end

Module.IterateEnabledModules 		= mUI.IterateEnabledModules
Module.GetModuleByID 				= mUI.GetModuleByID
Module.LoadAndEnableModule 			= mUI.LoadAndEnableModule
Module.EnableModuleState 			= mUI.EnableModuleState
Module.DisableModuleState 			= mUI.DisableModuleState
Module.CallFunctionOnModule 		= mUI.CallFunctionOnModule
Module.CallFunctionOnModules 		= mUI.CallFunctionOnModules
Module.CallFunctionOnEnabledModules = mUI.CallFunctionOnEnabledModules
