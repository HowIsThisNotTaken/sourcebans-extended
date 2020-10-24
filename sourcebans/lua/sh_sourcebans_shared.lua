//Taken from DarkRP
function sm_FindPlayer(info)
	    if not info or info == "" then return nil end
    local pls = player.GetAll()

    for k = 1, #pls do -- Proven to be faster than pairs loop.
        local v = pls[k]
        if tonumber(info) == v:UserID() then
            return v
        end

        if info == v:SteamID() then
            return v
        end

        if tonumber(info) == v:SteamID64() then
            return v
        end

        if string.find(string.lower(v:Nick()), string.lower(tostring(info)), 1, true) ~= nil then
            return v
        end

        if string.find(string.lower(v:SteamName()), string.lower(tostring(info)), 1, true) ~= nil then
            return v
        end
    end
    return nil
end
