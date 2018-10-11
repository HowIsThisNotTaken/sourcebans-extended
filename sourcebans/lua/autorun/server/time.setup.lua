--[[
	~ Time Example ~
	~ Lexi ~
--]]

local secs = 1 + sourcebans.UnitToSeconds(2, sourcebans.MINUTE) + sourcebans.UnitToSeconds(3, sourcebans.HOUR) + sourcebans.UnitToSeconds(4, sourcebans.DAY) + sourcebans.UnitToSeconds(5, sourcebans.WEEK) + sourcebans.UnitToSeconds(6, sourcebans.YEAR);
print(sourcebans.SecondsToTimestring(secs)); -- 6y5w4d3h2m1s

function ParsePotentialTimeString(words)
	local num = tonumber(words);
	return num and num or sourcebans.TimestringToSeconds(words);
end