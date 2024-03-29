--[[
    ~ Sourcebans GLua Module ~
    Copyright (c) 2011 Lexi Robinson

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction,
    including without limitation the rights to use, copy, modify, merge, publish, distribute,
    sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or
    substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
    NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    WARNING:
    Do *NOT* run with sourcemod active. It will have unpredictable effects!
--]]

require("mysqloo");

-- These are put here to lower the amount of upvalues and so they're grouped together
-- They provide something like the documentation the SM ones do. 
CreateConVar("sb_version", "1.531", FCVAR_SPONLY + FCVAR_REPLICATED + FCVAR_NOTIFY, "The current version of the SourceBans.lua module");
-- This creates a fake concommand that doesn't exist but makes the engine think it does. Useful.
AddConsoleCommand("sb_reload", "Doesn't do anything - Legacy from the SourceMod version.");

local error, ErrorNoHalt, GetConVarNumber, GetConVarString, Msg, pairs, print, ServerLog, tonumber, tostring, tobool, unpack =
      error, ErrorNoHalt, GetConVarNumber, GetConVarString, Msg, pairs, print, ServerLog, tonumber, tostring, tobool, unpack ;

local concommand, game, hook, math, os, player, string, table, timer, mysqloo, gatekeeper =
      concommand, game, hook, math, os, player, string, table, timer, mysqloo, gatekeeper ;

local HUD_PRINTCONSOLE, HUD_PRINTCENTER, HUD_PRINTNOTIFY, HUD_PRINTTALK = 
      HUD_PRINTCONSOLE, HUD_PRINTCENTER, HUD_PRINTNOTIFY, HUD_PRINTTALK ;
-- Sourcebans.lua provides an interface to SourceBans through GLua, so that SourceMod is not required.
-- It also attempts to duplicate the effects that would be had by running SourceBans, such as the concommand and convars it creates.
-- @release version 1.531, now GM13 compatible!
module("sourcebans");
--[[
    CHANGELOG
    1.531 Tiny change to make the source GM13 compatible (no more | operator!)
    1.53  sm_rehash now goes through all online players and makes sure their group is up to date.
    1.521 Fixed a hang if an admin had no srv_flags and no srv_group
    1.52  Added various sm_#say commands at a request, and added a SBANS_NO_COMMANDS global variable to disable all admin commands (for pure lua usage)
    1.51  Made it work again
    1.5   Made it support gatekeeper
    1.41  Fixed yet another 'stop loading admins' glitch
    1.4   Added GetAdmins(), made it work a bit more.
    1.317 Added even more error prevention when an admin doesn't have a server group but is assigned to the server
    1.316 Added error prevention when an admin doesn't have a server group but is assigned to the server
    1.315 Made sure callback was always actually a function even when not passed one, fixed a typo.
    1.31  Added some error checks, removed some sloppy assumptions and fixed queued ban checks not working.
    1.3   Pimped up the concommands and made them report more details
    1.22  Added dogroups to the config to disable automatic usergroup setting
    1.21  Made it so that the player is only kicked if their user object is available
    1.2   Made CheckForBan() and BanPlayerBySteamIDAndIP() accessable
    1.12  Made the concommands check that the right amount of arguments had been passed.
    1.11  Fixed a typo that stopped the fix working
    1.1   Fixed the module freezing the server by pinging the database 10 times a second
--]]
--[[ Config ]]--
local config = {
    hostname = "";
    username = "";
    password = "";
    database = "";
    dbprefix = "";
    website  = "";
    portnumb = 3306;
    serverid = 1;
    dogroups = true;
    showbanreason = true;
};
--[[ Automatic IP Locator ]]--
local serverport = GetConVarNumber("hostport");
local serverip;
do -- Thanks raBBish! http://www.facepunch.com/showpost.php?p=23402305&postcount=1382
    local function band( x, y )
        local z, i, j = 0, 1
        for j = 0,31 do
            if ( x%2 == 1 and y%2 == 1 ) then
                z = z + i
            end
            x = math.floor( x/2 )
            y = math.floor( y/2 )
            i = i * 2
        end
        return z
    end
    local hostip = tonumber(string.format("%u", GetConVarString("hostip")))
    local parts = {
        band( hostip / 2^24, 0xFF );
        band( hostip / 2^16, 0xFF );
        band( hostip / 2^8, 0xFF );
        band( hostip, 0xFF );
    }
    
    serverip = string.format( "%u.%u.%u.%u", unpack( parts ) )
end

--[[ Tables ]]--
local admins, adminsByID, adminGroups, database;
local queries = {
    -- BanChkr
    ["Check for Bans"] = "SELECT bid, name, ends, authid, ip, reason, length FROM %s_bans WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL AND (authid = '%s' OR ip = '%s') LIMIT 1";
    ["Check for Bans by IP"] = "SELECT bid, name, ends, authid, ip, reason, length FROM %s_bans WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL AND ip = '%s' LIMIT 1";
    ["Check for Bans by SteamID"] = "SELECT bid, name, ends, authid, ip, reason, length FROM %s_bans WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL AND authid = '%s' LIMIT 1";
    ["Get All Active Bans"] = "SELECT ip, authid, name, created, ends, length, reason, aid  FROM %s_bans WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL;";
    
    ["Log Join Attempt"] = "INSERT INTO %s_banlog (sid, time, name, bid) VALUES( %i, %i, '%s', %i)";
    
    -- Admins
    ["Select Admin Groups"] = "SELECT flags, immunity, name FROM %s_srvgroups";
    ["Select Admins"] = "SELECT a.aid, a.user, a.authid, a.srv_group, a.srv_flags, a.immunity FROM %s_admins a, %s_admins_servers_groups g WHERE g.server_id = %i AND g.admin_id = a.aid";
    
    -- Bannin
    ["Ban Player"] = "INSERT INTO %s_bans (ip, authid, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES('%s', '%s', '%s', %i, %i, %i, '%s', %i, '%s', %i, ' ')";
    -- Unbannin
    ["Unban SteamID"] = "UPDATE %s_bans SET RemovedBy = %i, RemoveType = 'U', RemovedOn = UNIX_TIMESTAMP(), ureason = '%s' WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL AND authid = '%s'";
    ["Unban IPAddress"] = "UPDATE %s_bans SET RemovedBy = %i, RemoveType = 'U', RemovedOn = UNIX_TIMESTAMP(), ureason = '%s' WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND removetype IS NULL AND ip = '%s'";
};
local idLookup = {};

-- The mysqloo ones are descriptive, but a mouthful.
STATUS_READY    = mysqloo.DATABASE_CONNECTED;
STATUS_WORKING  = mysqloo.DATABASE_CONNECTING;
STATUS_OFFLINE  = mysqloo.DATABASE_NOT_CONNECTED;
STATUS_ERROR    = mysqloo.DATABASE_INTERNAL_ERROR;

--[[ Convenience Functions ]]--
local function notifyerror(...)
    ErrorNoHalt("[", os.date(), "][SourceBans.lua] ", ...);
    ErrorNoHalt("\n");
    print();
end

local function notifymessage(...)
    local words = table.concat({"[",os.date(),"][SourceBans.lua] ",...},"").."\n";
    Msg(words);
end

local function cleanIP(ip)
    return string.match(ip, "(%d+%.%d+%.%d+%.%d+)");
end

function getIP(ply)
    return cleanIP(ply:IPAddress());
end

local function getAdminDetails(admin)
    if (admin and admin:IsValid()) then
        local data = admins[admin:SteamID()]
        if (data) then
            return data.aid, getIP(admin);
        end
    end
    return 0, serverip;
end

local function blankCallback() end


--[[ Query Functions ]]--
local checkBan, banCheckerOnData, banCheckerOnFailure;
local joinAttemptLoggerOnFailure;
local adminGroupLoaderOnSuccess, adminGroupLoaderOnFailure;
local loadAdmins, adminLoaderOnSuccess, adminLoaderOnData, adminLoaderOnFailure;
local doBan, doKick, banOnSuccess, banOnFailure;
local startDatabase, databaseOnConnected, databaseOnFailure;
local activeBansOnSuccess, activeBansOnFailure;
local doUnban, unbanOnFailure;
local checkBanBySteamID, checkSIDOnSuccess, checkSIDOnFailure;

-- Functions --
function checkBan(ply, steamID, ip, name, reason, length)
    local queryText = queries["Check for Bans"]:format(config.dbprefix, steamID, ip);
    local query = database:query(queryText);
    if (query) then
        query.steamID   = steamID;
        query.player    = ply;
        query.name      = name;
        query.onData    = banCheckerOnData;
        query.onFailure = banCheckerOnFailure;
        query:start();
    else
        table.insert(database.pending, {queryText, steamID, name, ply});
        CheckStatus();
    end
end

function checkBanBySteamID(steamID, callback)
    local query = database:query(queries["Check for Bans by SteamID"]:format(config.dbprefix, steamID));
        query.steamID   = steamID;
        query.callback  = callback;
        query.onSuccess = checkSIDOnSuccess;
        query.onFailure = checkSIDOnFailure;
        query:start();
end

function loadAdmins()
    admins = {};
    adminGroups = {};
    adminsByID = {};
    local query = database:query(queries["Select Admin Groups"]:format(config.dbprefix));
    query.onFailure = adminGroupLoaderOnFailure;
    query.onSuccess = adminGroupLoaderOnSuccess;
    query:start();
    notifymessage("Loading Admin Groups . . .");
end

function startDatabase()
    database = mysqloo.connect(config.hostname, config.username, config.password, config.database, config.portnumb);
    database.onConnected = databaseOnConnected;
    database.onConnectionFailed = databaseOnFailure;
    database.pending = {};
    database:connect();
end

function doUnban(query, id, reason, admin)
    local aid = getAdminDetails(admin)
    query = database:query(query:format(config.dbprefix, aid, database:escape(reason), id));
    query.onFailure = unbanOnFailure;
    query.id = id;
    query:start();
end

function doBan(steamID, ip, name, length, reason, admin, callback)
    local time = os.time();
    local adminID, adminIP = getAdminDetails(admin);
    --local length = time.SecondsToUnit(length, DAY);
    name = name or "";
    local query = database:query(queries["Ban Player"]:format(config.dbprefix, ip, steamID, database:escape(name), time, time + length, length, database:escape(reason), adminID, adminIP, config.serverid));
    query.onSuccess = banOnSuccess;
    query.onFailure = banOnFailure;
    query.callback = callback;
    query.name = name;
    query:start();
    if (config.showbanreason) then
        if (reason and string.Trim(reason) == "") then
            reason = nil;
        end

        if (reason == nil) then
            reason = "No reason specified.";
        end

        if length <= MINUTE then
            reason = "\nYou were banned for: " .. reason .. " \nLength: " .. length .. " Second(s)" .. " \nAdmin: " .. admin:Nick();
        elseif length <= HOUR then
            reason = "\nYou were banned for: " .. reason .. " \nLength: " .. SecondsToUnit(length, MINUTE) .. " Minute(s)" .. " \nAdmin: " .. admin:Nick();
        elseif length <= DAY then
            reason = "\nYou were banned for: " .. reason .. " \nLength: " .. SecondsToUnit(length, HOUR) .. " Hour(s)" .. " \nAdmin: " .. admin:Nick();
        elseif length <= WEEK then
            reason = "\nYou were banned for: " .. reason .. " \nLength: " .. SecondsToUnit(length, DAY) .. " Day(s)" .. " \nAdmin: " .. admin:Nick();
        elseif length <= YEAR then
            reason = "\nYou were banned for: " .. reason .. " \nLength: " .. SecondsToUnit(length, WEEK) .. " Week(s)" .. " \nAdmin: " .. admin:Nick();
		elseif length >= YEAR then
			reason = "\nYou were banned for: " .. reason .. " \nLength: " .. SecondsToUnit(length, YEAR) .. " Year(s)" .. " \nAdmin: " .. admin:Nick();
        else
            reason = "\nYou were banned for: " .. reason;
        end

    else
        reason = nil;
    end

    if (steamID ~= "") then
        game.KickID(steamID, reason)
    end
end
-- Data --
function banCheckerOnData(self, data)
    notifymessage(self.name, " has been identified as ", data.name, ", who is banned. Kicking ... ");

        if data.length <= MINUTE then
            reason = "\nYou were banned for: " .. data.reason .. " \nLength: " .. data.length .. " Second(s) \nFor more info, goto " .. config.website;
        elseif data.length <= HOUR then
            reason = "\nYou were banned for: " .. data.reason .. " \nLength: " .. SecondsToUnit(data.length, MINUTE) .. " Minute(s)\nFor more info, goto " .. config.website;
        elseif data.length <= DAY then
            reason = "\nYou were banned for: " .. data.reason .. " \nLength: " .. SecondsToUnit(data.length, HOUR) .. " Hour(s)\nFor more info, goto " .. config.website;
        elseif data.length <= WEEK then
            reason = "\nYou were banned for: " .. data.reason .. " \nLength: " .. SecondsToUnit(data.length, DAY) .. " Day(s)\nFor more info, goto " .. config.website;
        elseif data.length <= YEAR then
            reason = "\nYou were banned for: " .. data.reason .. " \nLength: " .. SecondsToUnit(data.length, WEEK) .. " Week(s)\nFor more info, goto " .. config.website;
		elseif data.length >= YEAR then
			reason = "\nYou were banned for: " .. data.reason .. " \nLength: " .. SecondsToUnit(data.length, YEAR) .. " Year(s)\nFor more info, goto " .. config.website;
        else
            reason = "\nYou were banned for: " .. data.reason .. " \nFor more info, goto " .. config.website;
        end

        game.KickID(self.steamID, reason)

    local query = database:query(queries["Log Join Attempt"]:format(config.dbprefix, config.serverid, os.time(), self.name, data.bid));
    query.onFailure = joinAttemptLoggerOnFailure;
    query.name = self.name;
    query:start();
end

function adminLoaderOnSuccess(self)
    notifymessage("Finished loading admins!");
    for _, ply in pairs(player.GetAll()) do
        local info = admins[ply:SteamID()];
        if (info) then
            if (config.dogroups) then
                ply:SetUserGroup(info.srv_group)
            end
            ply.sourcebansinfo = info;
            notifymessage(ply:Name() .. " is now a " .. info.srv_group .. "!");
        end
    end
end

function adminLoaderOnData(self, data)
    data.srv_group = data.srv_group or "NO GROUP ASSIGNED";
    data.srv_flags = data.srv_flags or "";
    local group = adminGroups[data.srv_group];
    if (group) then
        data.srv_flags = data.srv_flags .. (group.flags or "");
        if (data.immunity < group.immunity) then
            data.immunity = group.immunity;
        end
    end
    if (string.find(data.srv_flags, 'z')) then
        data.zflag = true;
    end
    admins[data.authid] = data;
    adminsByID[data.aid] = data;
    notifymessage("Loaded admin ", data.user, " with group ", tostring(data.srv_group), ".");
end

-- Success --
function adminGroupLoaderOnSuccess(self)
    local data = self:getData();
    for _, data in pairs(data) do
        adminGroups[data.name] = data;
        notifymessage("Loaded admin group ", data.name);
    end
    local query = database:query(queries["Select Admins"]:format(config.dbprefix,config.dbprefix,config.serverid));
    query.onSuccess = adminLoaderOnSuccess;
    query.onFailure = adminLoaderOnFailure;
    query.onData = adminLoaderOnData;
    query:start();  
    notifymessage("Loading Admins . . .");
end

function banOnSuccess(self)
    self.callback(true);
end

function databaseOnConnected(self)
    self.automaticretry = nil;
    if (config.serverid < 0) then
        local query = self:query("SELECT sid FROM %s_servers WHERE ip = '" .. serverip .. "' AND port = '" .. serverport .. "' LIMIT 1")
        query.onSuccess = function(self, data) config.serverid = data.sid; end;
        query:start();
    end
    if (not admins) then
        loadAdmins();
    end
    if (#self.pending == 0) then return; end
    local query, ply, steamID;
    for _, info in pairs(self.pending) do
        query           = self:query(info[1]);
        query.steamID   = info[2];
        query.name      = info[3];
        query.player    = info[4];
        query.onData    = banCheckerOnData;
        query.onFailure = banCheckerOnFailure;
        query:start();
    end
    self.pending = {};
end

function activeBansOnSuccess(self)
    local ret = {}
    local adminName, adminID;
    for _, data in pairs(self:getData()) do
        if (data.aid ~= 0) then
            local admin = adminsByID[data.aid];
            if (not admin) then -- 
                adminName = "Unknown";
                adminID = "STEAM_ID_UNKNOWN";
            else
                adminName = admin.user;
                adminID = admin.authid
            end
        else
            adminName = "Console";
            adminID = "STEAM_ID_SERVER";
        end
        
        ret[#ret + 1] = {
            IPAddress   = data.ip;
            SteamID     = data.authid;
            Name        = data.name;
            BanStart    = data.created;
            BanEnd      = data.ends;
            BanLength   = data.length;
            BanReason   = data.reason;
            AdminName   = adminName;
            AdminID     = adminID;
        }
    end
    self.callback(ret);
end

function checkSIDOnSuccess(self)
    self.callback(#self:getData() > 0);
end

-- Failure --
function banCheckerOnFailure(self, err)
    notifyerror("SQL Error while checking ", self.name, "'s ban status! ", err);
    game.KickID(steamID, "Failed to detect if you are banned!")
end

function joinAttemptLoggerOnFailure(self, err)
    notifyerror("SQL Error while storing ", self.name, "'s foiled join attempt! ", err);
end

function adminGroupLoaderOnFailure(self, err)
    notifyerror("SQL Error while loading the admin groups! ", err);
end

function adminLoaderOnFailure(self, err)
    notifyerror("SQL Error while loading the admins! ", err);
end

function banOnFailure(self, err)
    notifyerror("SQL Error while storing ", self.name, "'s ban! ", err);
    self.callback(false, err);
end

function databaseOnFailure(self, err)
    notifyerror("Failed to connect to the database: ", err, ". Retrying in 60 seconds.");
    self.automaticretry = true;
    timer.Simple(60, self.connect, self);
end

function activeBansOnFailure(self, err)
    notifyerror("SQL Error while loading all active bans! ", err);
    self.callback(false, err);
    RunConsoleCommand("kickall", "SourceBans Error")
end

function unbanOnFailure(self, err)
    notifyerror("SQL Error while removing the ban for ", self.id, "! ", err);
end

function checkSIDOnFailure(self, err)
    notifyerror("SQL Error while checking ", self.steamID, "'s ban status! ", err);
    self.callback(false, err);
end
--[[ Hooks ]]--
do
    local function ShutDown()
        if (database) then
            database:abortAllQueries();
        end
    end

    local function PlayerAuthed(ply, steamID)
        -- Always have this running.
        idLookup[steamID] = ply:UserID();

        if (not database) then
            notifyerror("Player ", ply:Name(), " joined, but SourceBans.lua is not active!");
            return;
        end
        checkBan(ply, steamID, getIP(ply), ply:Name());
        if (not admins) then
            return;
        end
        local info = admins[ply:SteamID()];
        if (info) then
            if (config.dogroups) then
                ply:SetUserGroup(info.srv_group)
            end
            ply.sourcebansinfo = info;
            notifymessage(ply:Name(), " has joined, and they are a ", tostring(info.srv_group), "!");
        end
    end
    
    local function PlayerDisconnected(ply)
        idLookup[ply:SteamID()] = nil;
    end
        

    hook.Add("ShutDown", "SourceBans.lua - ShutDown", ShutDown);
    hook.Add("PlayerAuthed", "SourceBans.lua - PlayerAuthed", PlayerAuthed);
    hook.Add("PlayerDisconnected", "SourceBans.lua - PlayerDisconnected", PlayerDisconnected);
end


--[[ Exported Functions ]]--        
local function checkConnection()
    return database and database:query("") ~= nil;
end

---
-- Starts the database and activates the module's functionality.
function Activate()
    startDatabase();
    notifymessage("Starting the database.");
end

---
-- Bans a player by object
-- @param ply The player to ban
-- @param time How long to ban the player for (in seconds)
-- @param reason Why the player is being banned
-- @param admin (Optional) The admin who did the ban. Leave nil for CONSOLE.
-- @param callback (Optional) A function to call with the results of the ban. Passed true if it worked, false and a message if it didn't.
function BanPlayer(ply, time, reason, admin, callback)
    callback = callback or blankCallback;
    if (not checkConnection()) then
        return callback(false, "No Database Connection");
    elseif (not ply:IsValid()) then
        error("Expected player, got NULL!", 2);
    end
    doBan(ply:SteamID(), getIP(ply), ply:Name(), time, reason, admin, callback);
end
---
-- Bans a player by steamID
-- @param steamID The SteamID to ban
-- @param time How long to ban the player for (in seconds)
-- @param reason Why the player is being banned
-- @param admin (Optional) The admin who did the ban. Leave nil for CONSOLE.
-- @param name (Optional) The name to give the ban if no active player matches the SteamID.
-- @param callback (Optional) A function to call with the results of the ban. Passed true if it worked, false and a message if it didn't.
function BanPlayerBySteamID(steamID, time, reason, admin, name, callback)
    callback = callback or blankCallback;
    if (not checkConnection()) then
        return callback(false, "No Database Connection");
    end
    for _, ply in pairs(player.GetAll()) do
        if (ply:SteamID() == steamID) then
            return BanPlayer(ply, time, reason, admin, callback);
        end
    end
    doBan(steamID, '', name, time, reason, admin, callback)
end

---
-- Bans a player by IPAddress
-- @param ip The IPAddress to ban
-- @param time How long to ban the player for (in seconds)
-- @param reason Why the player is being banned
-- @param admin (Optional) The admin who did the ban. Leave nil for CONSOLE.
-- @param name (Optional) The name to give the ban if no active player matches the IP.
-- @param callback (Optional) A function to call with the results of the ban. Passed true if it worked, false and a message if it didn't.
function BanPlayerByIP(ip, time, reason, admin, name, callback)
    callback = callback or blankCallback;
    if (not checkConnection()) then
        return callback(false, "No Database Connection");
    end
    for _, ply in pairs(player.GetAll()) do
        if (getIP(ply) == ip) then
            return BanPlayer(ply, time, reason, admin, callback);
        end
    end
    doBan('', cleanIP(ip), name, time, reason, admin, callback);
end

---
-- Bans a player by SteamID and IPAddress
-- @param steamID The SteamID to ban
-- @param ip The IPAddress to ban
-- @param time How long to ban the player for (in seconds)
-- @param reason Why the player is being banned
-- @param admin (Optional) The admin who did the ban. Leave nil for CONSOLE.
-- @param name (Optional) The name to give the ban
-- @param callback (Optional) A function to call with the results of the ban. Passed true if it worked, false and a message if it didn't.
function BanPlayerBySteamIDAndIP(steamID, ip, time, reason, admin, name, callback)
    callback = callback or blankCallback;
    if (not checkConnection()) then
        return callback(false, "No Database Connection");
    end
    doBan(steamID, cleanIP(ip), name, time, reason, admin, callback);
end


---
-- Unbans a player by SteamID
-- @param steamID The SteamID to unban
-- @param reason The reason they are being unbanned.
-- @param admin (Optional) The admin who did the unban. Leave nil for CONSOLE.
function UnbanPlayerBySteamID(steamID, reason, admin)
    if (not checkConnection()) then
        return false, "No Database Connection";
    end
    doUnban(queries["Unban SteamID"], steamID, reason, admin);
end

---
-- Unbans a player by IPAddress. If multiple players match the IP, they will all be unbanned.
-- @param ip The IPAddress to unban
-- @param reason The reason they are being unbanned.
-- @param admin (Optional) The admin who did the unban. Leave nil for CONSOLE.
function UnbanPlayerByIPAddress(ip, reason, admin)
    if (not checkConnection()) then
        return false, "No Database Connection";
    end
    doUnban(queries["Unban IPAddress"], ip, reason, admin);
end

---
-- Fetches all currently active bans in a table.
-- If the ban was inacted by the server, the AdminID will be "STEAM_ID_SERVER".<br />
-- If the server does not know who the admin who commited the ban is, the AdminID will be "STEAM_ID_UNKNOWN".<br/>
-- Example table structure: <br/>
-- <pre>{ <br/>
-- &nbsp; BanStart = 1271453312, <br/>
-- &nbsp; BanEnd = 1271453312, <br/>
-- &nbsp; BanLength = 0, <br/>
-- &nbsp; BanReason = "'Previously banned for repeately crashing the server'", <br/>
-- &nbsp; IPAddress = "99.101.125.168", <br/>
-- &nbsp; SteamID = "STEAM_0:0:20924001", <br/>
-- &nbsp; Name = "MINOTAUR", <br/>
-- &nbsp; AdminName = "Lexi", <br/>
-- &nbsp; AdminID = "STEAM_0:1:16678762" <br/>
-- }</pre> <br/>
-- Bear in mind that SteamID or IPAddress may be a blank string.
-- @param callback The function to be given the table
function GetAllActiveBans(callback)
    if (not callback) then
        error("Function expected, got nothing!", 2);
    elseif (not checkConnection()) then
        return callback(false, "No Database Connection");
    end
    local query = database:query(queries["Get All Active Bans"]:format(config.dbprefix));
    query.onSuccess = activeBansOnSuccess;
    query.onFailure = activeBansOnFailure;
    query.callback = callback;
    query:start();
end

---
-- Set the config variables. Most will not take effect until the next database connection.<br />
-- NOTE: These settings do *NOT* persist. You will need to set them all each time.
-- @param key The settings key to set
-- @param value The value to set the key to.
-- @usage Acceptable keys: hostname, username, password, database, dbprefix, portnumb, serverid, website, showbanreason and dogroups.
function SetConfig(key, value)
    if (config[key] == nil) then
        error("Invalid key provided. Please check your information.",2);
    end
    if (key == "portnumb" or key == "serverid") then
        value = tonumber(value);
    elseif (key == "showbanreason" or key == "dogroups") then
        value = tobool(value);
    end
    config[key] = value;
end


---
-- Checks the status of the database and recovers if there are errors
-- WARNING: This function is blocking. It is auto-called every 5 minutes.
function CheckStatus()
    if (not database or database.automaticretry) then return; end
    local status = database:status();
    if (status == STATUS_WORKING or status == STATUS_READY) then
        return;
    elseif (status == STATUS_ERROR) then
        notifyerror("The database object has suffered an inernal error and will be recreated.");
        local pending = database.pending;
        startDatabase();
        database.pending = pending;
    else
        notifyerror("The server has lost connection to the database. Retrying...")
        database:connect();
    end
end
timer.Create("SourceBans.lua - Status Checker", 300, 0, CheckStatus);

---
-- Checks to see if a SteamID is banned from the system
-- @param steamID The SteamID to check
-- @param callback The callback function to tell the results to
function CheckForBan(steamID, callback)
    if (not checkConnection()) then
        return callback(false, "No Database Connection");
    elseif (not callback) then
        error("Callback function required!", 2);
    elseif (not steamID) then
        error("SteamID required!", 2);
    end
    checkBanBySteamID(steamID, callback);
end

---
-- Gets all the admins active on this server
-- @returns A table.
function GetAdmins()
    local ret = {}
    for id,data in pairs(admins) do
        ret[id] = {
            Name = data.user;
            SteamID = id;
            UserGroup = data.srv_group;
            AdminID = data.aid;
            Flags = data.srv_flags;
            ZFlagged = data.zflag;
            Immunity = data.immunity;
        }
    end
    return ret;
end

function authorised(ply, flag)
    if (not (ply and ply:IsValid())) then
        return true;
    elseif (not ply.sourcebansinfo) then
        return false;
    end
    return ply.sourcebansinfo.zflag or string.find(ply.sourcebansinfo.srv_flags, flag);
end

concommand.Add("sm_rehash", function(ply, cmd)
    if (ply:IsValid()) then return end
    notifymessage("Rehash command recieved, reloading admins:");
    loadAdmins();
end, nil, "Reload the admin list from the SQL");

-- Unit Definitions
YEAR    = 31556926;
WEEK    = 604800;
DAY     = 86400;
HOUR    = 3600;
MINUTE  = 60;

---
-- Converts time of one unit to seconds
-- @param time The time
-- @param unit The unit the time is in
-- @return The time in seconds
function UnitToSeconds(time, unit)
    if (not time) then
        error("No time specified!", 2);
    elseif (not (unit and tonumber(unit))) then
        error("Invalid unit specified!", 2);
    end
    return math.floor(time * unit);
end

---
-- Converts a time in seconds into units
-- @param time The time
-- @param unit The unit to convert the time to
-- @return The time in the unit specified
function SecondsToUnit(time, unit)
    if (not time) then
        error("No time specified!", 2);
    elseif (not (unit and tonumber(unit))) then
        error("Invalid unit specified!", 2);
    end
    return math.floor(time / unit);
end

---
-- Converts a timestring into seconds
-- @param str The timestring to converty
-- @return The specified time
function TimestringToSeconds(str)
    if (not str) then
        error("No timestring specified!", 2);
    elseif (str == "") then
        return 0;
    end
    local years, weeks, days, hours, mins, secs;
    years = tonumber(string.match(str,"(%d+)%s?y")) or 0;
    weeks = tonumber(string.match(str,"(%d+)%s?w")) or 0;
    days  = tonumber(string.match(str,"(%d+)%s?d")) or 0;
    hours = tonumber(string.match(str,"(%d+)%s?h")) or 0;
    mins  = tonumber(string.match(str,"(%d+)%s?m")) or 0;
    secs  = tonumber(string.match(str,"(%d+)%s?s")) or 0;
    return  secs + 
            mins  * MINUTE + 
            hours * HOUR   +
            days  * DAY    +
            weeks * WEEK   +
            years * YEAR   ;
end

---
-- Converts a time into a timestring
-- @param time The time in seconds
-- @return A human readable timestring
function SecondsToTimestring(time)
    if (not time) then
        error("No time specified!", 2);
    end
    time = math.floor(time);
    local years, weeks, days, hours, minutes, seconds;
    years = SecondsToUnit(time, YEAR);
    time = time - years * YEAR;
    weeks = SecondsToUnit(time, WEEK);
    time = time - weeks * WEEK;
    days = SecondsToUnit(time, DAY);
    time = time - days * DAY;
    hours = SecondsToUnit(time, HOUR);
    time = time - hours * HOUR;
    minutes = SecondsToUnit(time, MINUTE);
    time = time - minutes * MINUTE;
    seconds = time;
    local str = "";
    if (years > 0) then
        str = str .. years .. "Year(s)";
    end if (weeks > 0) then
        str = str .. weeks .. "Week(s)";
    end if (days > 0) then
        str = str .. days .. "Day(s)";
    end if (hours > 0) then
        str = str .. hours .. "Hour(s)";
    end if (minutes > 0) then
        str = str .. minutes .. "Minute(s)";
    end if (seconds > 0) then
        str = str .. seconds .. "Second(s)";
    end
    return str;
end
