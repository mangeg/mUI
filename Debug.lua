local addonName, addon_table = ...

local _G = _G
local DEBUG = addon_table.DEBUG

local function is_list(t)
	local n = #t
	
	for k in pairs(t) do		
		if type(k) ~= "number" or k < 1 or k > n or math.floor(k) ~= k then
			return false
		end
	end
	return true
end

local function simple_pretty_tostring(value)
	if not value then return "nil" end
	if type(value) == "string" then
		value = value:gsub("|r", "|r|cff15f1ff")
		return ("\"|cff15f1ff%s|r\""):format(value)
	else
		return ("|cff15f1ff%s|r"):format(tostring(value))
	end
end

local function pretty_tostring(value)
	if type(value) ~= "table" then
		return simple_pretty_tostring(value)
	end
	
	local t = {}
	if is_list(value) then
		local last = 1
		for i, v in pairs(value) do
			if i > last then
				local diff = i - last
				for c = 1, diff do
					t[#t+1] = "nil"
				end				
			end
			t[#t+1] = simple_pretty_tostring(v)
			last = i + 1
		end
	else
		local last = 1
		for k, v in pairs(value) do
			--if i > last then
			--	local diff = i - last
			--	for c = 1, diff do
			--		t[#t+1] = "nil"
			--	end				
			--end
			t[#t+1] = "[" .. simple_pretty_tostring(k) .. "] = " .. simple_pretty_tostring(v)
			--last = i + 1
		end
	end	
	return "|cffff5522{|r" .. table.concat(t, ", ") .. "|cffff5522}|r"
end

local conditions = {}
local function helper(alpha, ...)
	for i = 1, select('#', ...) do
		if alpha == select(i, ...) then
			return true
		end
	end
	return false
end
conditions['inset'] = function(alpha, bravo)
	if type(bravo) == "table" then
		return bravo[alpha] ~= nil
	elseif type(bravo) == "string" then
		return helper(alpha, (";"):split(bravo))
	else
		error(("Bad argument #3 to `expect'. Expected %q or %q, got %q"):format("table", "string", type(bravo)))
	end
end
conditions['typeof'] = function(alpha, bravo)
	local type_alpha = type(alpha)
	if type_alpha == "table" and type(rawget(alpha, 0)) == "userdata" and type(alpha.IsObjectType) == "function" then
		type_alpha = 'frame'
	end
	return conditions['inset'](type_alpha, bravo)
end
conditions['frametype'] = function(alpha, bravo)
	if type(bravo) ~= "string" then
		error(("Bad argument #3 to `expect'. Expected %q, got %q"):format("string", type(bravo)), 3)
	end
	return type(alpha) == "table" and type(rawget(alpha, 0)) == "userdata" and type(alpha.IsObjectType) == "function" and alpha:IsObjectType(bravo)
end
conditions['match'] = function(alpha, bravo)
	if type(alpha) ~= "string" then
		error(("Bad argument #1 to `expect'. Expected %q, got %q"):format("string", type(alpha)), 3)
	end
	if type(bravo) ~= "string" then
		error(("Bad argument #3 to `expect'. Expected %q, got %q"):format("string", type(bravo)), 3)
	end
	return alpha:match(bravo)
end
conditions['=='] = function(alpha, bravo)
	return alpha == bravo
end
conditions['~='] = function(alpha, bravo)
	return alpha ~= bravo
end
conditions['>'] = function(alpha, bravo)
	return type(alpha) == type(bravo) and alpha > bravo
end
conditions['>='] = function(alpha, bravo)
	return type(alpha) == type(bravo) and alpha >= bravo
end
conditions['<'] = function(alpha, bravo)
	return type(alpha) == type(bravo) and alpha < bravo
end
conditions['<='] = function(alpha, bravo)
	return type(alpha) == type(bravo) and alpha <= bravo
end

local t = {}
for k, v in pairs(conditions) do
	t[#t+1] = k
end
for _, k in ipairs(t) do
	conditions["not_" .. k] = function(alpha, bravo)
		return not conditions[k](alpha, bravo)
	end
end

local function expect(alpha, condition, bravo, customMessage)
	if not conditions[condition] then
		error(("Unknown condition %s"):format(pretty_tostring(condition)), 2)
	end
	if not conditions[condition](alpha, bravo) then
		if customMessage then
			error(("Expectation failed: %s %s %s - %s"):format(pretty_tostring(alpha), condition, pretty_tostring(bravo), customMessage), 2)
		else
			error(("Expectation failed: %s %s %s"):format(pretty_tostring(alpha), condition, pretty_tostring(bravo)), 2)
		end
	end
end


local Debug = {}
Debug.expect = expect

function Debug:AddGlobal(name, data)
	if DEBUG then
		expect(name, "typeof", "string")
		expect(data, "~=", nil)
		
		_G[("%s_%s"):format(addonName, name)] = data
	end	
end

function Debug:Print(...)
	if DEBUG then		
		local t = ...
		if not t then return end
		if select(2, ...) then
			t = {...}
		end
		print(("|cffff7e00%s |r|cffff7e00:|r %s"):format(addonName, pretty_tostring(t)))
	end
end

addon_table.Debug = Debug