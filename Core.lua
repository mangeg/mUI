--- mUI
-- @module mUI

local name, mUI = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

Debug:AddGlobal("mUI", mUI)

local LSM = LibStub("LibSharedMedia-3.0")

local db
local modulePattern = "mUI_%a*$"
local isModule, shouldLoadModule

local defaults = {
	profile = {
		Modules = {
			["**"] = {
				Enabled = true,
			},
		},
	
		StatusBarTexture = LSM.DefaultMedia.statusbar,

		Fonts = {
			NormalFont = LSM.DefaultMedia.font,
			Scale = 1,
		},
			
		Colors = {
			ClassColoredBorders = false,
			
			StatusBarColor = {0.23, 0.23, 0.23},
			BorderColor = {0.23, 0.23, 0.23},
			BackdropColor = {0.07, 0.07, 0.07},
			
			ClassColors = {
				["DEATHKNIGHT"] = { 196/255,  30/255,  60/255 },
				["DRUID"]       = { 255/255, 125/255,  10/255 },
				["HUNTER"]      = { 171/255, 214/255, 116/255 },
				["MAGE"]        = { 104/255, 205/255, 255/255 },
				["PALADIN"]     = { 245/255, 140/255, 186/255 },
				["PRIEST"]      = { 212/255, 212/255, 212/255 },
				["ROGUE"]       = { 255/255, 243/255,  82/255 },
				["SHAMAN"]      = {  41/255,  79/255, 155/255 },
				["WARLOCK"]     = { 148/255, 130/255, 201/255 },
				["WARRIOR"]     = { 199/255, 156/255, 110/255 },
			},
		},
	},
}

for class, color in pairs(RAID_CLASS_COLORS) do
	local d = defaults.profile.Colors.ClassColors
	d[class][1] = color.r
	d[class][2] = color.g
	d[class][3] = color.b
	d[class][4] = color.a or 1
end

function mUI:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("mUIDB", defaults, "Default")
	defaults = nil
	
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
	
	self.Callbacks = LibStub("CallbackHandler-1.0"):New(self)	
	
	LibStub("LibDualSpec-1.0"):EnhanceDatabase(self.db, name)
	db = self.db.profile
	
	--self:CheckAndLoadModules(modulePattern, shouldLoadModule)
	--self:AddModulesToOptions()
	
	self.Options:SetupLDB()	
	self:UpdateMedia()	
	
	LSM.RegisterCallback(self, "LibSharedMedia_Registered")
end

function mUI:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
end

function mUI:ProfileChanged()
	db = self.db.profile
end

function mUI:LibSharedMedia_Registered(mediaType, name)	
end

--- Call function on a module.
-- Will not do anything if the module does not have the function.
-- @param module The module to call the function on.
-- @param funcName The name of the function to call.
-- @param ... Parameters to pass to the function.
function mUI:CallFunctionOnModule(module, funcName, ...)
	if DEBUG then
		expect(mdule, "typeof", "table")
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
	for _, module in self:IterateEnabledModules() do
		self:CallFunctionOnModule(module, funcName, ...)
	end
end

--- Update media and bring values from SharedMedia and so on.
function mUI:UpdateMedia()
	self.Media.StatusBarTexture = LSM:Fetch("statusbar", db.StatusBarTexture)
	self.Media.NormalFont = LSM:Fetch("font", db.Fonts.NormalFont)
end

--- Load modules that match the patter passed the optional extra check
-- @param pattern The pattern for modules to match
-- @param extraCheck function to call that have to return true for the module to be loaded.
function mUI:CheckAndLoadModules(pattern, extraCheck)
	if DEBUG then
		expect(pattern, 	"typeof", "string")
		expect(stage, 		"typeof", "string;nil")
		expect(extraCheck, 	"typeof", "function;nil")		
	end	
	
	local reg = "(%a*)\\%a*.lua"
	local stack = debugstack(2, 1, 1):match(reg)
	
	for i = 1, GetNumAddOns() do
		name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		local loadState = GetAddOnMetadata(i, "X-LoadWhen")
		if enabled and (not IsAddOnLoaded(i)) and loadable and name:match(pattern) then
			local doLoad = true
			if extraCheck then
				doLoad = extraCheck(name)
			end
			if doLoad then
				Debug:Print(stack, "Loading Module", title)
				LoadAddOn(name)							
			end
		end
	end
end

function mUI:AddModulesToOptions()
	for i = 1, GetNumAddOns() do
		name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		if isModule(name) then
			self.Options.args.modules.args[name] = self.Options.args.modules.args[name] or {
				type = "group",
				name = title,
				args = {
				}
			}
			self.Options.args.modules.args[name].args.Enabled = {
				type = "toggle",
				name = "Enabled",
				get = function(info)
					return db.Modules[info[#info-1]].Enabled
				end,
				set = function(info, value)
					db.Modules[info[#info-1]].Enabled = value
					mUI:CheckAndLoadModules(modulePattern, isModule)
				end,
			}
		end
	end
end

mUI.Media = {
	Blank = [[Interface\BUTTONS\WHITE8X8]],
}

isModule = function(moduleName)
	return GetAddOnMetadata(moduleName, "X-mUI-Module") == "1"
end

shouldLoadModule = function(moduleName)
	return isModule(moduleName) and db.Modules[moduleName].Enabled
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

do
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