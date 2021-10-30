hook.Add( "PhysgunPickup", "AdminPhysgunPickup", function(ply, ent)
	if sourcebans.authorised(ply, sb_FLAG_GENERIC) then
		if not IsValid(ent) or not ent:IsPlayer() then return end
			ent:SetMoveType(MOVETYPE_NONE)
			ent:Freeze(true)
		return true
	end
end)
	
hook.Add( "PhysgunDrop", "AdminPhysgunDrop", function(ply, ent)
	if not IsValid(ent) or not ent:IsPlayer() then return end
		ent:SetMoveType(MOVETYPE_WALK)
		ent:Freeze(false)
	return false
end)
