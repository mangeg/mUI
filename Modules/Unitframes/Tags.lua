local _, ns = ...

local mUI = LibStub("AceAddon-3.0"):GetAddon("mUI")
if not mUI then return end

local plugin = mUI:GetModule("Unitframes")
if not plugin then return end

local oUF = oUF

oUF.TagEvents["mUI:diffcolor"] = "UNIT_LEVEL"
oUF.Tags["mUI:diffcolor"] = function(unit)
	if not unit then return end
	local r, g, b
	local level = UnitLevel(unit)
	if (level < 1) then
		r, g, b = 0.69, 0.31, 0.31
	else
		local DiffColor = UnitLevel("target") - UnitLevel("player")
		if (DiffColor >= 5) then
			r, g, b = 0.69, 0.31, 0.31
		elseif (DiffColor >= 3) then
			r, g, b = 0.71, 0.43, 0.27
		elseif (DiffColor >= -2) then
			r, g, b = 0.84, 0.75, 0.65
		elseif (-DiffColor <= GetQuestGreenRange()) then
			r, g, b = 0.33, 0.59, 0.33
		else
			r, g, b = 0.55, 0.57, 0.61
		end
	end
	return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local utf8sub = function(string, i, dots)
	if not string then return end
	local bytes = string:len()
	if (bytes <= i) then
		return string
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = string:byte(pos)
			if (c > 0 and c <= 127) then
				pos = pos + 1
			elseif (c >= 192 and c <= 223) then
				pos = pos + 2
			elseif (c >= 224 and c <= 239) then
				pos = pos + 3
			elseif (c >= 240 and c <= 247) then
				pos = pos + 4
			end
			if (len == i) then break end
		end

		if (len == i and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and "..." or "")
		else
			return string
		end
	end
end

oUF.TagEvents["mUI:getnamecolor"] = "UNIT_POWER"
oUF.Tags["mUI:getnamecolor"] = function(unit)
	if not unit then return end
	local reaction = UnitReaction(unit, "player")
	if (UnitIsPlayer(unit)) then
		return oUF.Tags["raidcolor"](unit)
	elseif (reaction) then
		local c = oUF.colors.reaction[reaction]
		return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
	else
		r, g, b = .84,.75,.65
		return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	end
end

oUF.TagEvents["mUI:getnamecolor"] = "UNIT_POWER"
oUF.Tags["mUI:getnamecolor"] = function(unit)
	if not unit then return end
	local reaction = UnitReaction(unit, "player")
	if (UnitIsPlayer(unit)) then
		return oUF.Tags["raidcolor"](unit)
	elseif (reaction) then
		local c = oUF.colors.reaction[reaction]
		return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
	else
		r, g, b = .84,.75,.65
		return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	end
end

oUF.TagEvents["mUI:namemedium"] = "UNIT_NAME_UPDATE"
oUF.Tags["mUI:namemedium"] = function(unit)
	if not unit then return end
	local name = UnitName(unit)
	local colorblind = GetCVarBool("colorblindMode")
	if colorblind ~= 1 then
		return utf8sub(name, 15, false)
	else
		if (UnitIsPlayer(unit)) then
			local class = select(2, UnitClass(unit))
			local texcoord = CLASS_BUTTONS[class]
			return (utf8sub((name), 15, false)).." |TInterface\\WorldStateFrame\\Icons-Classes:25:25:0:0:256:256:"..tostring(texcoord[1]*256)..":"..tostring(texcoord[2]*256)..":"..tostring(texcoord[3]*256)..":"..tostring(texcoord[4]*256).."|t"
		else
			return utf8sub(name, 15, false)
		end
	end
end

oUF.TagEvents["mUI:namelong"] = "UNIT_NAME_UPDATE"
oUF.Tags["mUI:namelong"] = function(unit)
	if not unit then return end
	local name = UnitName(unit)
	local colorblind = GetCVarBool("colorblindMode")
	if colorblind ~= 1 then
		return utf8sub(name, 20, false)
	else
		if (UnitIsPlayer(unit)) then
			local class = select(2, UnitClass(unit))
			local texcoord = CLASS_BUTTONS[class]
			return (utf8sub((name), 20, false)).." |TInterface\\WorldStateFrame\\Icons-Classes:25:25:0:0:256:256:"..tostring(texcoord[1]*256)..":"..tostring(texcoord[2]*256)..":"..tostring(texcoord[3]*256)..":"..tostring(texcoord[4]*256).."|t"
		else
			return utf8sub(name, 20, false)
		end
	end
end