// Keeps track of ban history. Set true to record kicks, false to kick w/o record. Recommendation: false to save database space.
sourcebans_kickHistory = false

//SourceBans Flags. B is given to most functions as those are basic admin privileges. You can use kick and ban for something else or add as an extra check.
sourcebans_FLAG_RESERVED = "a"
sourcebans_FLAG_GENERIC = "b"
sourcebans_FLAG_KICK = "c"
sourcebans_FLAG_BAN = "d"
sourcebans_FLAG_UNBAN = "e"
sourcebans_FLAG_SLAY = "f"
sourcebans_FLAG_MAP = "g"
sourcebans_FLAG_CVARS = "h"
sourcebans_FLAG_EXECCONFIG = "i"
sourcebans_FLAG_ACHAT = "j"
sourcebans_FLAG_VOTES = "k"
sourcebans_FLAG_PASSW = "l"
sourcebans_FLAG_RCON = "m"
sourcebans_FLAG_CHEATS = "n"
sourcebans_FLAG_CUSTOM_O = "o"
sourcebans_FLAG_CUSTOM_P = "p"
sourcebans_FLAG_CUSTOM_Q = "q"
sourcebans_FLAG_CUSTOM_R = "r"
sourcebans_FLAG_CUSTOM_S = "s"
sourcebans_FLAG_CUSTOM_T = "t"

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
