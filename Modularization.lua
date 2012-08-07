--- mUI.ModuleHandling
-- @module mUI.ModuleHandling

local name, mUI = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local moduleFullOptions = {}
local moduleFunctions = {}
local modulePrototype = {}
modulePrototype.SetName = mUI.defaultModulePrototype.SetName
modulePrototype.SetDescription = mUI.defaultModulePrototype.SetDescription

local pluginDatas = {}

function mUI:Modularize(name, plugin)
	if DEBUG then
		expect(name, "typeof", "string")
		expect(plugin, "typeof", "table")
	end
	
	plugin.NewModules = {}
	plugin.ModulesNotLoaded = {}
	
	tinsert(pluginDatas, {	
		name = name,
		module = plugin
	})
	
	for funcName, func in pairs(moduleFunctions) do
		plugin[funcName] = func
	end
	
	plugin:SetDefaultModulePrototype(modulePrototype)
end

do
	local event = {}
	local matches = {}
	LibStub("AceEvent-3.0").RegisterEvent(event, "ADDON_LOADED", function(event, addon)
		for i, pluginData in pairs(pluginDatas) do
			for i, newModule in pairs(pluginData.module.NewModules) do
				if pluginData.module.HandleModuleLoaded then	
					pluginData.module:HandleModuleLoaded(newModule)
				end
				pluginData.module:CallFunctionOnModules("OnModuleLoaded", module)
			end
			wipe(pluginData.module.NewModules)
		end
	end)
end

function moduleFunctions:OnModuleCreated(module)
	if DEBUG then
		expect(module, "typeof", "table")
		expect(module.moduleName, "typeof", "string")
	end
	
	local id = ("%s_%s"):format(self.id, module.moduleName)
	
	module.id = id
	self[id] = module
	
	tinsert(self.NewModules, module)
end

function moduleFunctions:LoadModules()
	wipe(self.ModulesNotLoaded)
	
	local current_profile = mUI.db:GetCurrentProfile()
	
	local sv = mUI.db.sv
	local sv_namespaces = sv and sv.namespaces
	
	for i, name, moduleName in self:IterateLoadOnDemandModules() do		
		local namespace = ("%s_%s"):format(self.name, moduleName)
		local module_sv = sv_namespaces[namespace]
		local module_profile_db = module_sv and module_sv.profiles and module_sv.profiles[current_profile]		
		local enabled = module_profile_db and module_profile_db.Enabled		
		
		if enabled == nil then
			local defaultState = GetAddOnMetadata(name, "X-mUI-DefaultState")
			local isEnabled = select(4, GetAddOnInfo(name))
			enabled = (default_state ~= "disabled") and isEnabled ~= nil
		end		
		
		local loaded, reason
		if enabled then
			loaded, reason = LoadAddOn(i)
		end
		
		if not loaded and reason then
			Debug:Print(("%s Module failed to load"):format(self.baseName), name, reason)
		elseif loaded then
			Debug:Print(("Loaded %s Module"):format(self.baseName), name)
		else
			tinsert(self.ModulesNotLoaded, name)
		end
	end
end

do
	local currentName
	local function checkIfDependand(...)
		for i = 1, select("#", ...) do
			if (select(i, ...)) == currentName then
				return true
			end			
		end	
		return false
	end

	local function iterAddons(total, i)
		i = i + 1
		if i >= total then
			return nil
		end
		
		if IsAddOnLoaded(i) then
			return iterAddons(total, i)
		end
		
		if not IsAddOnLoadOnDemand(i) then
			return iterAddons(total, i)
		end
		
		local name = GetAddOnInfo(i)		
		local moduleName = name:match(("%s_([A-Za-z0-9]*)$"):format(currentName))		
		if not moduleName then
			return iterAddons(total, i)
		end
		
		if not checkIfDependand(GetAddOnDependencies(i)) then
			return iterAddons(total, i)
		end
		
		local loadCheck = GetAddOnMetadata(name, "X-mUI-LoadCheck")
		if loadCheck then
			local func, err = loadstring(loadCheck)			
			if func then
				local success, ret = pcall(func)
				if not ret then
					return iterAddons(total, i)
				end
			else
				Debug:Print("Error loading X-mUI-LoadCeck", err)
			end
		end
		
		return i, name, moduleName
	end
	
	function moduleFunctions:IterateLoadOnDemandModules()
		currentName = self.baseName
		return iterAddons, GetNumAddOns(), 0
	end
end

function moduleFunctions:GetModuleOptions()
	self:LoadModules()
	
	local moduleOptions = {
		type = "group",
		name = "Modules",
		desc = "Modules provide functionallity",
		args = {},
		childGroups = "tree",
	}
	
	local moduleArgs = {
		enabled = {
			type = "toggle",
			name = "Enable",
			desc = "Globally enable this module.",
			order = 1,
			get = function(info)
				return info.handler:IsEnabled()
			end,
			set = function(info, value)
				if value then
					self:EnableModuleState(info.handler)
				else
					self:DisableModuleState(info.handler)
				end
			end
		},
		moduleSplit = {
			type = "description",
			name = "",
			order = 2,
		},
	}
	
	local function merge_onto(dict, ...)
		for i = 1, select('#', ...), 2 do
			local k, v = select(i, ...)
			if not v.order then
				v.order = 100 + i
			end
			dict[k] = v
		end
	end	
	
	function self:HandleModuleLoaded(module)		
		if DEBUG then
			expect(module, "typeof", "table")
			expect(module.IsEnabled, "typeof", "function")
		end
		
		local id = module.id
		local opt = {
			type = "group",
			name = module.name,
			desc = module.description,
			handler = module,
			args = {},
		}
		
		moduleOptions.args[module.baseName] = opt
		for k, v in pairs(moduleArgs) do
			opt.args[k] = v
		end
		
		if moduleFullOptions[module] then
			merge_onto(opt.args, moduleFullOptions[module](module))
			moduleFullOptions[module] = false
		end
	end
	
	for id, module in self:IterateModules() do
		self:HandleModuleLoaded(module)
	end
	
	local function loadable(info)
		local id = info[#info - 1]
		local _,_,_,_,loadable = GetAddOnInfo(id)
		return loadable
	end

	local function unloadable(info)
		return not loadable(info)
	end

	local arg_enabled = {
		type = "toggle",
		name = "Enable",
		desc = "Globally enable this module.",
		get = function(info)
			return false
		end,
		set = function(info, value)
			local id = info[#info - 1]
			self:LoadAndEnableModule(id)
		end,
		disabled = unloadable,
	}
	
	local no_mem_notice = {
		type = "description",
		name = "This module is not loaded and will not take up and memory or processing power until enabled.",
		order = -1,
		hidden = unloadable,
	}
	
	local unloadable_notice = {
		type = "description",
		name = function(info)
			local id = info[#info - 1]
			local _,_,_,_,loadable,reason = GetAddOnInfo(id)
			if not loadable then
				if reason then
					if reason == "DISABLED" then
						reason = "Disabled in the Blizzard addon list."
					else
						reason = _G["ADDON_"..reason]
					end
				end
				if not reason then
					reason = UNKNOWN
				end
				return format("This module can not be loaded: %s", reason)
			end
		end,
		order = -1,
		hidden = loadable,
	}
	
	for i, moduleID in ipairs(self.ModulesNotLoaded) do
		if not moduleOptions.args[moduleID] then
			local title = GetAddOnMetadata(moduleID, "Title")
			local notes = GetAddOnMetadata(moduleID, "Notes")	
			
			local name = title:match("[[](.*)[]]$")
			if not name then
				name = moduleID
			else
				name = name:gsub("|r", ""):gsub("|c%x%x%x%x%x%x%x%x", "")
			end
		
			local opt = {
				type = "group",
				name = name,
				desc = notes,
				args = {
					enabled = arg_enabled,
					no_mem_notice = no_mem_notice,
					unloadable_notice = unloadable_notice,
				},
			}
			
			moduleOptions.args[moduleID] = opt
		end
	end
	
	return moduleOptions
end

function modulePrototype:SetOptions(func)
	if DEBUG then
		expect(func, "typeof", "function")		
		expect(moduleFullOptions[self], "==", nil)
	end
	
	moduleFullOptions[self] = func
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
	end
end

function modulePrototype:SetDefaults(defaults)
	if DEBUG then
		expect(defaults, "typeof", "table")
	end
	
	createModuleDB(self, defaults)
end