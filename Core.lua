--- mUI
-- @module mUI

local name, mUI = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

Debug:AddGlobal("mUI", mUI)

local LSM = LibStub("LibSharedMedia-3.0")

local db

local defaults = {
	profile = {
		Modules = {
			["**"] = {
				Enabled = true,
			},
		},
		
		Media = {
			Textures = {
				StatusBar = LSM:GetDefault("statusbar"),
			},
			Fonts = {
				["**"] = {
					Font = LSM:GetDefault("font"),
					Scale = 1,
					Color = {1, 1, 1, 1},
					UseClassColor = false,
					Flags = "NONE",
					ShadowOffsetX = 0,
					ShadowOffsetY = 0,
					ShadowColor = {0, 0, 0, 1},
				},
				Normal = {},				
			},
			Borders = {
				["**"] = {
					IsSharp = true,
					SharpWidth = 0.5,
					SharpShadowWidth = 2.8,
					Color = {1, 1, 1},
					SharpShadowColor = {0, 0, 0},
					UseClassColor = true,
					Texture = LSM:GetDefault("border"),
				},
				Normal = {
					Name = "Normal Text",
				},
			}
		},
			
		Colors = {
			ClassColoredBorders = false,
			
			StatusBar = {0.23, 0.23, 0.23},
			Border = {0.23, 0.23, 0.23},
			Backdrop = {0.07, 0.07, 0.07},
			
			Class = {}
		},
	},
}

for class, color in pairs(RAID_CLASS_COLORS) do
	defaults.profile.Colors.Class[class] = {color.r, color.g, color.b, color.a or 1}
end

function mUI:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("mUIDB", defaults, "Default")
	defaults = nil
	
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	
	self.Callbacks = LibStub("CallbackHandler-1.0"):New(self)	
	
	LoadAddOn("LibDualSpec-1.0")
	LibStub("LibDualSpec-1.0"):EnhanceDatabase(self.db, name)
	
	self:RegisterEvent("ADDON_LOADED")
	self:ADDON_LOADED()
	
	LoadAddOn("LibDataBroker-1.1")
end

function mUI:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	self:OnProfileChanged()
	
	LSM.RegisterCallback(self, "LibSharedMedia_Registered", "MediaRegistered")
	self:UpdateMedia()
	
	local anch = self:CreateAnchor("TestAnchor")
	self.anch1 = anch
	anch:Show()
end

--- Load new settings after profile has been changed.
function mUI:OnProfileChanged()
	db = self.db.profile
	
	for _, module in self:IterateEnabledModules() do
		if module.OnProfileChanged then
			module:OnProfileChanged()
		end
	end
	
	self:LoadModules()
	
	for _,module in self:IterateModules() do
		if module.db.profile.Enabled then
			self:EnableModuleState(module)
		else
			self:DisableModuleState(module)
		end
	end
end

function mUI:MediaRegistered(_, mediaType, name)
	self:CallFunctionOnEnabledModules("MediaRegistered", mediaType, name)
end

function mUI:ADDON_LOADED(event, addon)	
	if not self.Options.LibDataBrokerLauncher then
		self.Options:SetupLDB()
	end
end

--- Load all Load-On-Demand modules
-- @usage mUI:LoadModules()
function mUI:LoadModules()
	local current_profile = self.db:GetCurrentProfile()
	
	local sv = self.db.sv
	local sv_namespaces = sv and sv.namespaces
	
	for i, name, moduleName in self:IterateLoadOnDemandModules() do
		local module_sv = sv_namespaces and sv_namespaces[moduleName]
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
			Debug:Print("Module failed to load", name, reason)
		elseif loaded then
			Debug:Print("Loaded module", name)
		else
			tinsert(self.ModulesNotLoaded, name)
		end
	end
end

do
	local function checkIfDependand(...)
		for i = 1, select("#", ...) do
			if (select(i, ...)) == "mUI" then
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
		
		if not IsAddOnLoadOnDemand(i) then
			return iterAddons(total, i)
		end
		
		local name = GetAddOnInfo(i)		
		local moduleName = name:match("mUI_([A-Za-z0-9]*)$")		
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
	
	--- Iterator for all modules that are loadable and should be loaded.
	-- @usage mUI:IterateLoadOnDemandModules()
	function mUI:IterateLoadOnDemandModules()
		return iterAddons, GetNumAddOns(), 0
	end
end

--- Call function on a module.
-- Will not do anything if the module does not have the function.
-- @param module The module to call the function on.
-- @param funcName The name of the function to call.
-- @param ... Parameters to pass to the function.
function mUI:CallFunctionOnModule(module, funcName, ...)
	if DEBUG then
		expect(module, "typeof", "table")
		expect(funcName, "typeof", "string")
	end
	if module[funcName] then
		module[funcName](module, ...)
	end
end

--- Call a function on all modules that have the function.
-- @param funcName Name of the function.
-- @param ... Parameters to pass to the function.
function mUI:CallFunctionOnModules(funcName, ...)
	if DEBUG then
		expect(funcName, "typeof", "string")
	end
	for _, module in self:IterateModules() do
		self:CallFunctionOnModule(module, funcName, ...)
	end
end

--- Call function on enabled modules.
-- @param funcName Name of the function.
-- @param ... Parameters to pass to the function.
function mUI:CallFunctionOnEnabledModules(funcName, ...)
	if DEBUG then
		expect(funcName, "typeof", "string")
	end
	for id, module in self:IterateEnabledModules() do
		self:CallFunctionOnModule(module, funcName, ...)
	end
end

--- Update media and bring values from SharedMedia and so on.
function mUI:UpdateMedia()
	--self.Media.StatusBarTexture = LSM:Fetch("statusbar", db.StatusBarTexture)
	---self.Media.NormalFont = LSM:Fetch("font", db.Fonts.NormalFont)
end

--- Wrap a function to only be executed out of combat.
-- @param func Function to run.
-- @usage local wrapped = mUI:OutOfCombatWrapper(function(param1)
--	doSecureStuff(param1) 
--end)
--wrapped("hello")
function mUI:OutOfCombatWrapper(func)
	if DEBUG then
		expect(func, "typeof", "function")
	end
	
	return function(...)
		return mUI:RunOnLeaveCombat(func, ...)
	end
end

do -- Out of combat wrapping
	local inCombat = false
	local inLockdown = false
	local toRun = {}
	local pool = setmetatable({}, {__mode = "k"})
	function mUI:PLAYER_REGEN_ENABLED()
		inCombat = false
		inLockdown = false
		for i, v in ipairs(toRun) do
			v.func(unpack(v, 1, v.count))
			toRun[i] = nil
			wipe(v)
			pool[v] = true
		end	
	end

	function mUI:PLAYER_REGEN_DISABLED()
		inCombat = true
	end	
	
	--- Runs a function when leaving combat.
	-- @param func Function to run.
	-- @param ... Params to send to the function.
	-- @usage mUI:RunOnLeaveCombat(function(param1) doSecureStuff(param1) end)
	function mUI:RunOnLeaveCombat(func, ...)
		if DEBUG then
			expect(func, "typeof", "function")
		end
		
		if not inCombat then
			func(...)
			return
		end		
		
		if not inLockdown then
			inLockdown = InCombatLockdown()
			if not inLockdown then
				func(...)
				return
			end
		end
		
		local v = next(pool) or {}
		pool[v] = nil
		
		v.func = func
		v.count = select("#", ...)
		for i = 1, v.count do
			v[i] = select(i, ...)
		end
		toRun[#toRun + 1] = v
	end
end
