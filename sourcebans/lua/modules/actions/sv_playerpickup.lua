local function AdminPhysgunPickup( ply, ent )
	if ply:IsAdmin() then
		if not IsValid(ent) or not ent:IsPlayer() then return end
			ent:SetMoveType(MOVETYPE_NONE)
			ent:Freeze(true)
		return true
	end
end
hook.Add( "PhysgunPickup", "AdminPhysgunPickup", AdminPhysgunPickup )
	
local function AdminPhysgunDrop( ply, ent )
	if not IsValid(ent) or not ent:IsPlayer() then return end
		ent:SetMoveType(MOVETYPE_WALK)
		ent:Freeze(false)
	return false
end
hook.Add( "PhysgunDrop", "AdminPhysgunDrop", AdminPhysgunDrop)
