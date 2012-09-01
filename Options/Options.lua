--- mUI Options
-- @module mUI.Options

local name, mUI = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

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
		return mUI.Options:ToggleConfig()
	end
end

--- Togle holding all options related information
-- @type table
local Options = {}
mUI.Options = Options

local moduleFullOptions = {}

function Options:ToggleConfig() 

	function Options:ToggleConfig()
		local mode = "Close"
		if not ACD.OpenFrames[name] then
			mode = "Open"
		end
		
		ACD[mode](ACD, name) 
		
		GameTooltip:Hide()
	end
	
	local new_order
	do
		local current = 0
		function new_order()
			current = current + 1
			return current
		end
	end
	
	local function GetColorOptions()
		
		local colorOptions = {
			Class = {
				type = "group",
				name = "Class",
				guiInline = true,
				order = new_order(),
				args = {},
			},
			Other = {
				type = "group",
				name = "Other",
				guiInline = true,
				order = new_order(),
				get = function(info)
					local d = mUI.db.profile.Colors
					return mUI.AceGUIGet(d, info)
				end,
				set = function(info, v1, v2, v3, v4)
					local d = mUI.db.profile.Colors
					mUI.AceGUISet(d, info, v1, v2, v3, v4)
				end,
				args = {
					ClassColoredBorders = { type = "toggle", name = "Class color borders", order = new_order() },
					sep1 = { type = "description", name = "", order = new_order() },
					StatusBar = { type = "color", name = "Status Bar", order = new_order() },
					Border = { type = "color", name = "Border", order = new_order(),
						disabled = function(info)
							return mUI.db.profile.Colors.ClassColoredBorders
						end,
					},
					Backdrop = { type = "color", name = "Backdrop", order = new_order() },
				},
			},
		}
		
		local colorOption = {
			type = "color",
			hasAlpha = false,
			name = function(info)
				local class = info[#info]
				return LOCALIZED_CLASS_NAMES_MALE[class]
			end,
			get = function(info)
				local class = info[#info]
				return unpack(mUI.db.profile.Colors.Class[class])
			end,
			set = function(info, r, g, b, a)
				local class = info[#info]
				local color = mUI.db.profile.Colors.Class[class]
				color[1], color[2], color[3] = r, g, b
			end,
		}
		
		for class, _ in pairs(RAID_CLASS_COLORS) do
			colorOptions.Class.args[class] = colorOption
		end

		return colorOptions
	end
	
	local function GetMediaOptions()		
		local fontOptions
		local function GetFontOption()			
			local fontOption = {
				type = "select",
				name = "Font",
				order = new_order(),
				dialogControl = "LSM30_Font",
				values = LSM:HashTable("font"),
			}
			
			fontOptions = {
				type = "group",
				name = function(info) return info[#info] end,
				guiInline = true,
				get = function(info)
					local d = mUI.db.profile.Media.Fonts[info[#info-1]]
					return mUI.AceGUIGet(d, info)
				end,
				set = function(info, v1, v2, v3, v4)
					local d = mUI.db.profile.Media.Fonts[info[#info-1]]
					mUI.AceGUISet(d, info, v1, v2, v3, v4)
					mUI.Media:UpdateStrings()
				end,
				args = {
					Font = fontOption,
					Flags = {
						type = "select",
						name = "Flags",
						order = new_order(),
						values = mUI.AceGUIFontFlags,
					},
					Scale = {
						type = "range",
						name = "Scale",
						order = new_order(),
						min = 0.01,
						step = 0.01,
						max = 3,
					},
					UseClassColor = {						
						type = "toggle",
						name = "Use class color",
						order = new_order(),
					},
					Color = {
						type = "color",
						name = "Color",
						order = new_order(),
						hasAlpha = true,
						disabled = function(info)
							local d = mUI.db.profile.Media.Fonts[info[#info-1]]
							return d.UseClassColor
						end,
					},
					ShadowColor = {
						type = "color",
						name = "Shadow Color",
						order = new_order(),
						hasAlpha = true,
					},
					ShadowOffsetX = {
						type = "range",
						name = "Shadow offset X",
						order = new_order(),
						min = -5,
						max = 5,
						step = 0.1
					},
					ShadowOffsetY = {
						type = "range",
						name = "Shadow offset Y",
						order = new_order(),
						min = -5,
						max = 5,
						step = 0.1
					},
				},
			}
			
			return fontOptions
		end
		
		local function GetTextureOptions()
			textureOptions = {
				StatusBar = {
					type = "select",
					name = "Status Bar",
					dialogControl = "LSM30_Statusbar",
					values = LSM:HashTable("statusbar"),
				},
			}
			
			return textureOptions
		end
		
		local selectedBorder
		
		local function GetBorderDB()
			return mUI.db.profile.Media.Borders[selectedBorder]
		end
		
		local function GetBorderOptions()
			local borderOptions = {
			}
			
			return borderOptions
		end	
		
		local function GetBorders()
			local borders = {}
			
			for name, db in pairs(mUI.db.profile.Media.Borders) do
				borders[name] = db.Name
				local first
				if not selectedBorder then
					selectedBorder = name					
				end				
				if not first then first = name end
			end
			
			if not borders[selectedBorder] then
				selectedBorder = first
			end
				
			return borders
		end	
		
		
		local mediaOptions = {
			Fonts = {
				type = "group",
				name = "Fonts",
				args = {}
			},
			Textures = {
				type = "group",
				name = "Texture",
				get = function(info)
					local d = mUI.db.profile.Media.Textures
					return mUI.AceGUIGet(d, info)
				end,
				set = function(info, ...)
					local d = mUI.db.profile.Media.Textures
					mUI.AceGUISet(d, info, ...)
				end,
				args = GetTextureOptions()
			},
			Borders = {
				type = "group",
				name = "Borders",
				args = {				
					Top = {
						type = "group",
						name = "Other",						
						guiInline = true,
						args = {
							border = {
								type = "select",
								name = "Select border",
								order = new_order(),
								values = function() return GetBorders() end,
								get = function() return selectedBorder end,
								set = function(info, value) selectedBorder = value end,
							},
							createBorder = {
								type = "input",
								name = "Create",
								order = new_order(),
								get = function() return "" end,								
								set = function(info, value) mUI.db.profile.Media.Borders[value] = { Name = value } print(value) end,
							},
							deleteBorder = {
								type = "execute",
								name = "Delete",
								confirm = function() return "Are you sure?" end,
								func = function(info)
									mUI.db.profile.Media.Borders[selectedBorder] = nil
								end,
							},
							changeName = {
								type = "input",
								name = "Rename",
								order = new_order(),
								get = function() return GetBorderDB().Name end,								
								set = function(info, value) GetBorderDB().Name = value end,
							},
							bortderSettings = {
								type = "group",
								name = "asf",
								guiInline = true,
								args = {
								},
							},
						},
					},
				},
			},
		}
		
		for fontName, fontData in pairs(mUI.db.defaults.profile.Media.Fonts) do
			if fontName ~= "**" then
				mediaOptions.Fonts.args[fontName] = fontOptions or GetFontOption()
			end
		end
		
		return mediaOptions
	end	
	
	local options = {
		type = "group",
		name = (select(2, GetAddOnInfo(name))),
		childGroups = "tab",
		args = {
			General = {
				order = new_order(),
				type = "group",
				name = "General",
				args = {
					Colors = {
						type = "group",
						name = "Colors",
						order = new_order(),
						args = GetColorOptions(),
					},
					Media = {
						type = "group",
						name = "Media",
						order = new_order(),
						args = GetMediaOptions(),
					},
				},
			},
		},
	}

	
	options.args.modules = self:GetModuleOptions()
	options.args.modules.order = new_order()
	
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

--- Set up the LDB object
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
	
	self.LibDataBrokerLauncher = l
end

function mUI.defaultModulePrototype:SetOptions(func)
	if DEBUG then
		expect(func, "typeof", "function")		
		expect(moduleFullOptions[self], "==", nil)
	end
	
	moduleFullOptions[self] = func
end

function Options:GetModuleOptions()
	local moduleOptions = {
		type = "group",
		name = "Modules",
		desc = "Modules provide functionallity to mUI.",
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
					mUI:EnableModuleState(info.handler)
				else
					mUI:DisableModuleState(info.handler)
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
	
	local handledLoadedModules = {}
	function Options:HandleModuleLoaded(module)		
		if DEBUG then
			expect(module, "typeof", "table")
			expect(module.IsEnabled, "typeof", "function")
		end
		
		if handledLoadedModules[module] then
			return
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
		
		handledLoadedModules[module] = true
	end
	
	for id, module in mUI:IterateModules() do
		Options:HandleModuleLoaded(module)
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
			mUI:LoadAndEnableModule(id)
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
	
	for i, moduleID in ipairs(mUI.ModulesNotLoaded) do
		if not moduleOptions.args[moduleID] then
			local title = GetAddOnMetadata(moduleID, "Title")
			local notes = GetAddOnMetadata(moduleID, "Notes")	
			
			local name = title:match(".*-%s?(.*)$")
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