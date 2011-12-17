local name, mUI = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

if not AC then
	LoadAddOn("Ace3")
	AC = LibStub and LibStub("AceConfig-3.0", true)
	if not AC then
		error(("mUI requires the library %q and will not work without it."):format("AceConfig-3.0"))
	end
end

do
	for i, cmd in ipairs { "/MUI" } do
		_G["SLASH_MUI" .. (i*2 - 1)] = cmd
		_G["SLASH_MUI" .. (i*2)] = cmd:lower()
	end

	_G.hash_SlashCmdList["MUI"] = nil
	_G.SlashCmdList["MUI"] = function()
		return mUI.Options.OpenConfig()
	end
end

local Options = {}
mUI.Options = Options

function test(param1, param2)
end



function Options:ToggleConfig() 

	function Options:ToggleConfig()
		local mode = "Close"
		if not ACD.OpenFrames[name] then
			mode = "Open"
		end
		
		ACD[mode](ACD, name) 
		
		GameTooltip:Hide()
	end
	
	local options = {
		type = "group",
		name = (select(2, GetAddOnInfo(name))),
		args = {
		},
	}
	
	local new_order
	do
		local current = 0
		function new_order()
			current = current + 1
			return current
		end
	end
	
	
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(mUI.db)
	options.args.profile.order = new_order()
	local old_disabled = options.args.profile.disabled
	options.args.profile.disabled = function(info)
		return InCombatLockdown() or (old_disabled and old_disabled(info))
	end
	LibStub("LibDualSpec-1.0"):EnhanceOptions(options.args.profile, mUI.db)
	AC:RegisterOptionsTable(name, options)
	ACD:SetDefaultSize(name, 835, 550)
	
	-- Refresh options when entering and leaving combat
	LibStub("AceEvent-3.0").RegisterEvent(Options, "PLAYER_REGEN_ENABLED", function()
		LibStub("AceConfigRegistry-3.0"):NotifyChange(name)
	end)	
	LibStub("AceEvent-3.0").RegisterEvent(Options, "PLAYER_REGEN_DISABLED", function()
		LibStub("AceConfigRegistry-3.0"):NotifyChange(name)
	end)
	
	return Options:ToggleConfig()
end

function Options:SetupLDB()
	local LDB = LibStub("LibDataBroker-1.1", true)
	if not LDB then return end
	
	local l = LDB:NewDataObject(name)
	l.type = "launcher"
	l.icon = [[Interface\Icons\achievement_dungeon_throne of the tides]]
	l.OnClick = function(self, button)
		Options:ToggleConfig()
	end
	l.OnTooltipShow = function(tt)
		tt:AddLine(name)
		tt:AddLine("Click to toggle configuration")
	end
	
	self.ldbojb = l
end