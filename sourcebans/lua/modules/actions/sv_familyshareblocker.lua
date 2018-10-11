// Family Share Blocker
local APIKey = ""

local function HandleSharedPlayer(ply, lenderSteamID)
    print(string.format("FamilySharing: %s | %s has been lent Garry's Mod by %s",
		    ply:Nick(),
            ply:SteamID(),
            lenderSteamID
    ))

    for k, v in pairs( player.GetAll() ) do
        if v:IsModerator() then
            sourcebans_notify(v, ply:Nick() .." " .. ply:SteamID() .. " is a family shared account!", 0, 10)
        end
    end
-- Thanks xaviergmail https://facepunch.com/showthread.php?t=1480440&p=48420435&viewfull=1#post48420435
local steamid = ply:SteamID()  -- Save this in case we lose the player object between the two callbacks

	sourcebans.CheckForBan(lenderSteamID, function(banned)
	if not banned then return end  -- The sharer is not banned, no need to do anything else.
	
	sourcebans.CheckForBan(steamid, function(banned)
		if banned then return end  -- The person receiving the shared game is already banned, don't ban then again
		ply:Kick("You must purchase your own copy of Garry's Mod due to your original account being banned.")
	end)
end)
	
end

local function CheckFamilySharing(ply)
    http.Fetch(
        string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
            APIKey,
            ply:SteamID64()
        ),
       
        function(body)
            body = util.JSONToTable(body)
 
            if not body or not body.response or not body.response.lender_steamid then
                error(string.format("FamilySharing: Invalid Steam API response for %s | %s\n", ply:Nick(), ply:SteamID()))
            end
 
            local lender = body.response.lender_steamid
            if lender ~= "0" then
                HandleSharedPlayer(ply, util.SteamIDFrom64(lender))
            end
        end,
       
        function(code)
            error(string.format("FamilySharing: Failed API call for %s | %s (Error: %s)\n", ply:Nick(), ply:SteamID(), code))
        end
    )
end
 
hook.Add("PlayerAuthed", "CheckFamilySharing", CheckFamilySharing)