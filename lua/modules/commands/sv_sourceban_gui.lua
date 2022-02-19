MsgC(Color(235, 245, 0), "Loading Server side functionality of SourceBans\n")

local function warn(target, adminID, reason)
    hook.Call("AWarnPlayerWarned", target, adminID, reason)
end

util.AddNetworkString("sm_BanPlayer")
net.Receive("sm_BanPlayer", function ( len, Player )
    if Player:IsAdmin() then
        local target = net.ReadEntity()
        local time = net.ReadUInt(32)
        local reason = net.ReadString()

        if reason == '' then
            sourcebans_notify(Player, "You must have a reason!", 1, 4)
        return end

        if !target:IsPlayer() and !IsValid(target) then
            sourcebans_notify(Player, "Not a valid player!", 0, 4)
        return end

        if !tonumber(time) then
            sourcebans_notify(Player, "Ban length must be a number!", 1, 4)
        return end

        if time == 0 and !Player:IsSeniorModerator() then
            sourcebans_notify(Player, "You cannot permanently ban a player; get a senior mod!", 1, 4)
        return end

        sourcebans.BanPlayer(target, time*60, reason, Player, callback)
        sourcebans_notify(Player, "Banned: " .. target:Nick(), 0, 4)
        sourcebans_chatact(Player, " has banned ", target)
        PrintMessage(3, target:Nick() .. " was banned for: " .. reason)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)

util.AddNetworkString("sm_AddBan")
net.Receive("sm_AddBan", function( len, Player )
    if Player:IsAdmin() then
        local steamid = net.ReadString()
        local time = net.ReadUInt(32)
        local reason = net.ReadString()
        local name = net.ReadString()

        if !tonumber(time) then
            sourcebans_notify(Player, "Ban Length must be a number", 1, 4)
        return end

        if time == 0 and !Player:IsSeniorModerator() then
            sourcebans_notify(Player, "You cannot permanently ban a player; get a senior mod!", 1, 4)
        return end

        for _, ply in pairs(player.GetAll()) do
            if (ply:SteamID() == steamid) then
                return sourcebans.BanPlayer(ply, time*60, reason, Player, callback);
            end
        end

        if reason == "" then
            sourcebans_notify(Player, "You must have a reason!", 1, 4)
        return end

        if time == 0 and !Player:IsSeniorModerator() then
            sourcebans_notify(Player, "You cannot permanently ban a player; get a senior mod!", 1, 4)
        return end

        if name == "" then
            name = "Unknown"
        return end

        sourcebans.BanPlayerBySteamID(steamid, time*60, reason, Player, name, callback)
        sourcebans_notify(Player, "Banned: " .. steamid .. " (" .. name .. ")", 0, 4)
        sourcebans_chatact(Player, " added a ban via SteamID")
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)

util.AddNetworkString("sm_Unban")
net.Receive("sm_Unban", function( len, Player )
    if Player:IsAdmin() then
        local steamid = net.ReadString()
        local reason = net.ReadString()

        if steamid == "" then
            sourcebans_notify(Player, "You must have a valid SteamID!", 1, 4)
        return end

        if reason == "" then
            sourcebans_notify(Player, "You must have a reason!", 1, 4)
        return end

        sourcebans.UnbanPlayerBySteamID(steamid, reason, Player)
        sourcebans_notify(Player, "Unbanned: " .. steamid, 0, 4)
        sourcebans_chatact(Player, " unbanned a SteamID")
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)

util.AddNetworkString("sm_KickPlayer")
net.Receive("sm_KickPlayer", function ( len, Player )
    if Player:IsAdmin() then
        local target = net.ReadEntity()
        local reason = net.ReadString()

        if reason == "" then
            sourcebans_notify(Player, "You must have a reason!", 1, 4)
        return end

        if !target:IsPlayer() and !IsValid(target) then
            sourcebans_notify(Player, "Not a valid player!", 0, 4)
        return end

        target:Kick("You were kicked for: " .. reason .. " \nAdmin: " .. Player:Nick())

        PrintMessage(3, target:Nick() .. " was kicked for: " .. reason)
        sourcebans_notify(Player, "Kicked: " .. target:Nick(), 0, 4)
        sourcebans_chatact(Player, " kicked ", target)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)

util.AddNetworkString("sm_FreezePlayer")
net.Receive("sm_FreezePlayer", function ( len, Player )
    if Player:IsAdmin() then
        local target = net.ReadEntity()

        if !target:IsPlayer() and !IsValid(target) then
            sourcebans_notify(Player, "Not a valid player!", 0, 4)
        return end

        if !target:IsFrozen() then
            target:Freeze(true)
            target:GodEnable()
            sourcebans_notify(Player, "Froze: " .. target:Nick(), 0, 4)
            sourcebans_chatact(Player, " froze ", target)
        else
            target:Freeze(false)
            target:GodDisable()
            sourcebans_notify(Player, "Unfroze: " .. target:Nick(), 0, 4)
            sourcebans_chatact(Player, " unfroze ", target)
        end
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)

util.AddNetworkString("sm_ChangeTeam")
net.Receive("sm_ChangeTeam", function( len, Player )
    if Player:IsAdmin() then

        local target = net.ReadEntity()
        local teamid = net.ReadUInt(32)

        if !target:IsPlayer() then
            sourcebans_notify(Player, "Invalid Player", 1, 4)
        return end

        if !tonumber(teamid) then
            sourcebans_notify(Player, "Invalid Team!", 1, 4)
        return end

        target:changeTeam(teamid, true, true)
        sourcebans_notify(Player, "Set Team: " .. target:Nick(), 0, 4)
        sourcebans_chatact(Player, " job changed ", target)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)

util.AddNetworkString("sm_RespawnPlayer")
net.Receive("sm_RespawnPlayer", function ( len, Player )
    if Player:IsAdmin() then
        local target = net.ReadEntity()

        if !target:IsPlayer() and !IsValid(target) then
            sourcebans_notify(Player, "Not a valid player!", 1, 4)
        return end

        target:SetNoDraw(false)
	    target:SetNotSolid(false)
	    target:GodDisable()
	    target:DrawWorldModel(true)
        target:Spawn();
        sourcebans_notify(Player, "Respawned: " .. target:Nick(), 0, 4)
        sourcebans_chatact(Player, " respawned ", target)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)

util.AddNetworkString("sm_KillPlayer")
net.Receive("sm_KillPlayer", function ( len, Player )
    if Player:IsAdmin() then
        local target = net.ReadEntity()

        if !target:IsPlayer() and !IsValid(target) then
            sourcebans_notify(Player, "Not a valid player!", 1, 4)
        return end

        target:SetNoDraw(false)
	    target:SetNotSolid(false)
	    target:GodDisable()
	    target:DrawWorldModel(true)
        target:Kill()
        sourcebans_notify(Player, "Killed: " .. target:Nick(), 0, 4)
        sourcebans_chatact(Player, " force killed ", Target)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)

util.AddNetworkString("sm_Godmode")
net.Receive("sm_Godmode", function ( len, Player )
    if Player:IsAdmin() then
        local target = net.ReadEntity()

        if !target:IsPlayer() and !IsValid(target) then
            sourcebans_notify(Player, "Not a valid player!", 0, 4)
        return end

        if !target:HasGodMode() then
            target:GodEnable()
            sourcebans_notify(Player, "Enabled god mode for: " .. target:Nick(), 0, 4)
            sourcebans_chatact(Player, " enabled god mode for ", Target)
        else
            target:GodDisable()
            sourcebans_notify(Player, "Disabled god mode for " .. target:Nick(), 0, 4)
            sourcebans_chatact(Player, " disabled got mode for ", Target)
        end
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)

util.AddNetworkString("sm_GotoPlayer")
net.Receive("sm_GotoPlayer", function ( len, Player )
    if Player:IsAdmin() then
        local target = net.ReadEntity()

        if Player:InVehicle() then
            Player:ExitVehicle()
        end

        if !target:IsPlayer() and !IsValid(target) then
            sourcebans_notify(Player, "Not a valid player!", 0, 4)
        return end

        Player:SetPos( target:GetPos() + target:GetForward() * 50 )
        sourcebans_notify(Player, "Teleported to: " .. target:Nick(), 0, 4)
        sourcebans_chatact(Player, " teleported to ", target)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)

    
util.AddNetworkString("sm_BringPlayer")
net.Receive("sm_BringPlayer", function ( len, Player )
    if Player:IsAdmin() then
        local target = net.ReadEntity()

        if target:InVehicle() then
            target:ExitVehicle()
        end

        if !target:Alive() then
            sourcebans_notify(Player, target:Nick() .. " is dead!", 1, 4)
        return end

        if !target:IsPlayer() and !IsValid(target) then
            sourcebans_notify(Player, "Not a valid player!", 0, 4)
        return end

        target:SetPos( Player:GetPos() + Player:GetForward() * 50 )
		sourcebans_notify(Player, "Brought: " .. target:Nick(), 0, 4)
        sourcebans_chatact(Player, " brought ", target)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)
    
util.AddNetworkString("sm_StripPlayer")
net.Receive("sm_StripPlayer", function( len, Player )
    if Player:IsAdmin() then
        local target = net.ReadEntity()

        if !target:IsPlayer() then 
            sourcebans_notify(Player, "Not a valid player!", 1, 4)
        return end

        target:StripWeapons()
        sourcebans_notify(Player, "Stripped weapons from: " .. target:Nick(), 0, 4)
        sourcebans_chatact(Player, " stripped weapons from ", target)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)
util.AddNetworkString("sm_GetIP")
net.Receive("sm_GetIP", function(len, Player)
    if Player:IsSuperAdmin() then
        local target = net.ReadEntity()

        if !target:IsPlayer() then
            sourcebans_notify(Player, "Not a valid player!", 1, 4)
        return end

        net.Start("sm_GetIP")
            net.WriteString(sourcebans.getIP(target))
        net.Send(Player)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)
util.AddNetworkString("sm_AddBanIP")
net.Receive("sm_AddBanIP", function(len, Player)
    if Player:IsSuperAdmin() then
        local ip = net.ReadString()
        local time = net.ReadUInt(32)
        local reason = net.ReadString()
        local name = net.ReadString()

        if !tonumber(time) then
                sourcebans_notify(Player, "Ban Length must be a number", 1, 4)
        return end



        if reason == "" then
                sourcebans_notify(Player, "You must have a reason!", 1, 4)
        return end

        if name == "" then
            name = "Unknown"
        return end

        sourcebans.BanPlayerByIP(ip, time*60, reason, Player, name, callback)
        sourcebans_notify(Player, "Banned: " .. ip .. "(" .. name .. ")", 0, 4)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)
util.AddNetworkString("sm_UnbanIP")
net.Receive("sm_UnbanIP", function(len, Player)
    if Player:IsSuperAdmin() then
        local ip = net.ReadString()
        local reason = net.ReadString()

        if reason == "" then
            sourcebans_notify(Player, "You must have a reason!", 1, 4)
        return end

        if ip == "" then
            sourcebans_notify(Player, "You must have a valid IP Address!", 1, 4)
        return end

        sourcebans.UnbanPlayerByIPAddress(ip, reason, Player)
        sourcebans_notify(Player, "Unbanned: " .. ip, 0, 4)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)
util.AddNetworkString("sm_SetTempRank")
net.Receive("sm_SetTempRank", function(len, Player)
    if Player:IsDivisionDirector() then
        local target = net.ReadEntity()
        local rank = net.ReadString()

        if !IsValid(target) then
            sourcebans_notify(Player, "Invalid player!", 1, 4)
        return end

        if rank == "Owner" and !Player:IsOwner() then
            sourcebans_notify(Player, "Silly goose you cant do that :)", 1, 4)
        return end

        target:SetUserGroup(rank)
    else
        sourcebans_notify(Player, "You are not authorized to perform this action!", 1, 4)
    end
end)
    --[[ MENU NETWORKING BELOW]]--
util.AddNetworkString("sm_AdminMenu")
concommand.Add("sm_adminmenu", function( Player, cmd )
    if Player:IsAdmin() then
        net.Start("sm_AdminMenu")
            net.WriteEntity(Player)
        net.Send(Player)
    end
end)

timer.Create("SourceBans.lua - Refresh Admin", 60, 0, function() RunConsoleCommand("sm_rehash") end)