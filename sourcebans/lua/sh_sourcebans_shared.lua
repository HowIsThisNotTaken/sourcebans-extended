local meta = FindMetaTable("Player")

function meta:IsAdmin()
	if self:IsModerator() then return true end
	if self:IsUserGroup("admin") then return true end

    return false
end

function meta:IsModerator()
	if self:IsAdministrator() then return true end
	if self:IsUserGroup("Moderator") then return true end
	
	return false
end


function meta:IsAdministrator()
	if self:IsDivisionDirector() then return true end
	if self:IsUserGroup("Administrator") then return true end
	
	return false
end

function meta:IsSuperAdmin() 
    if self:IsDivisionDirector() then return true end
	if self:IsUserGroup("superadmin") then return true end

    return false
end

function meta:IsDivisionDirector()
	if self:IsOwner() then return true end
	if self:IsUserGroup("Division Director") then return true end

	return false
end

function meta:IsOwner()
	if self:IsUserGroup("Owner") then return true end

	return false
end

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