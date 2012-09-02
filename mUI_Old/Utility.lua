local name, mUI = ...

local DEBUG = mUI.DEBUG
local Debug = mUI.Debug
local expect = Debug.expect

_, mUI.pClass = UnitClass("player")

function mUI:ShortValue(v)
	if v >= 1e6 then
		return ("%.1fm"):format(v / 1e6):gsub("%.?0+([km])$", "%1")
	elseif v >= 1e3 or v <= -1e3 then
		return ("%.1fk"):format(v / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return v
	end
end

function mUI:ShortValueNegative(v)
	if v <= 999 then return v end
	if v >= 1000000 then
		local value = string.format("%.1fm", v / 1000000)
		return value
	elseif v >= 1000 then
		local value = string.format("%.1fk", v / 1000)
		return value
	end
end

function mUI:Round(v, decimals)
	if not decimals then decimals = 0 end
    return (("%%.%df"):format(decimals)):format(v)
end

function mUI:Truncate(v, decimals)
	if not decimals then decimals = 0 end
    return v - (v % (0.1 ^ decimals))
end

function mUI:RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

function mUI:HexToRGB(hex)
	local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	return tonumber(rhex, 16), tonumber(ghex, 16), tonumber(bhex, 16)
end

do
	local day, hour, minute, second = 86400, 3600, 60, 1
	function mUI:FormatTime(s, reverse)
		if s >= day then
			return format("%dd", ceil(s / hour))
		elseif s >= hour then
			return format("%dh", ceil(s / hour))
		elseif s >= minute then
			return format("%dm", ceil(s / minute))
		elseif s >= minute / 12 then
			return floor(s)
		end
		
		if reverse and reverse == true and s >= second then
			return floor(s)
		else	
			return format("%.1f", s)
		end
	end
end

function mUI:ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end

	local num = select('#', ...) / 3
	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

mUI.AceGUIPoints = {
	TOPLEFT = "Top left",
	TOP = "Top",
	TOPRIGHT = "Top right",
	RIGHT = "Right",
	BOTTOMRIGHT = "Bottom right",
	BOTTOM = "Bottom",
	BOTTOMLEFT = "Bottom left",
	LEFT = "Left",
	CENTER = "Center",
}

mUI.AceGUIXDir = {
	LEFT = "Left",
	RIGHT = "Right",
}

mUI.AceGUIYDir = {
	UP = "Up",
	DOWN = "Down",
}

mUI.AceGUIDir = {
	LEFT = "Left",
	RIGHT = "Right",
	UP = "Up",
	DOWN = "Down",
}

mUI.AceGUIStrata = {
	["PARENT"] = "Parent",
	["BACKGROUND"] = "Background",
	["LOW"] = "Low",
	["MEDIUM"] = "Medium",
	["HIGH"] = "High",
	["DIALOG"] = "Dialog",
	["FULLSCREEN"] = "Full screen",
	["FULLSCREEN_DIALOG"] = "Full screen dialog",
	["TOOLTIP"] = "Tooltip",
}

function mUI.AceGUIGet(d, info)	
	if DEBUG then
		expect(d, "typeof", "table")
		expect(d[info[#info]], "~=", nil, ("Missing data for %s"):format(info[#info]))
		--expect(d[info[#info]], "~=", nil)
	end
	if info.type == "color" then
		return unpack(d[info[#info]])
	else
		return d[info[#info]]
	end
end

function mUI.AceGUISet(d, info, v1, v2, v3, v4)		
	if info.type == "color" then
		d = d[info[#info]]
		d[1] = v1
		d[2] = v2
		d[3] = v3
		d[4] = v4
	else
		d[info[#info]] = v1
	end
end

function mUI:AceGUIDumpInfo(info)
	for i, v in ipairs(info) do
		print(string.format("%s: %s", i, v))
	end
end