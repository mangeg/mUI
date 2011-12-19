local _, ns = ...

local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local plugin = mUI:GetModule("Unitframes")

local db, gdb
local class = select(2, UnitClass("player"))

plugin:AddDbUpdateCallback(function()
	db = plugin.db.profile
	gdb = mUI.db.profile
end)

function plugin:CreateBossFrames(frame)
	frame.Health = plugin:CreateHealthBar(frame, true, true, "RIGHT")
	frame.Portrait = plugin:CreatePortrait(frame)
	frame.Name = self:CreateNameText(frame, "LEFT", 5, 0)
	frame.Castbar = self:CreateCastbar(frame, "LEFT")
	frame.Power = plugin:CreatePowerBar(frame, true, true)
	frame.Buffs = self:Create_Buffs(frame)
	frame.Debuffs = self:Create_Debuffs(frame)
	frame.RaidIcon = frame:CreateTexture()
end

function plugin:UpdateBossFrames(frame, db)
	plugin:UpdateFrame(frame)
end

plugin.GroupsToCreate["boss"] = MAX_BOSS_FRAMES