local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local name, plugin = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local db, gdb

function plugin:AddOptions()
	mUI.Options.args.modules.args[name] = mUI.Options.args.modules.args[name] or {
		type = "group",
		name = (select(2, GetAddOnInfo(name))),
		args = {
		}
	}
	
	local args = mUI.Options.args.modules.args[name].args
	
	args.Layouts = {
		type = "group",
		name = "Layouts",
		args = {
		},
	}
end