hook.Add( "PhysgunPickup", "AdminPhysgunPickup", function(ply, ent)
	if ply:IsTrialModerator() then
		if not IsValid(ent) or not ent:IsPlayer() then return end
			if ply:IsTrialModerator() and ent:IsOwner() then return end
			ent:SetMoveType(MOVETYPE_NONE)
			ent:Freeze(true)
			ent:SetCollisionGroup(10)
		return true
	end
end)
	
hook.Add( "PhysgunDrop", "AdminPhysgunDrop", function(ply, ent)
	if not IsValid(ent) or not ent:IsPlayer() then return end
		ent:SetMoveType(MOVETYPE_WALK)
		ent:Freeze(false)
		ent:SetCollisionGroup(0)
	return false
end)