hook.Add("PlayerNoClip", "SourcebansNoclip", function(ply, desiredNoClipState )
		if not ply:IsModerator() then 
			sourcebans_notify(Player, "You must be a staff member to do this!", 1, 4)
		return false end

		if !ply:Alive() then
			sourcebans_notify(ply, "You must be alive to noclip!", 1, 4)
		return end

		if desiredNoClipState then
			ply:SetNoDraw(true)
			ply:SetNotSolid(true)
			ply:GodEnable()
			ply:DrawWorldModel(false)
			sourcebans_notify(ply, "Enabled Godmode and Cloak!", 0, 4)
		else
			ply:SetNoDraw(false)
			ply:SetNotSolid(false)
			ply:GodDisable()
			ply:DrawWorldModel(true)
			sourcebans_notify(ply, "Disabled Godmode and Cloak!", 0, 4)
		end
	return true
end)

hook.Add("PlayerSpawn", "RemoveNoclipEffects", function(Player)
	Player:SetNoDraw(false)
	Player:SetNotSolid(false)
	Player:GodDisable()
	Player:DrawWorldModel(true)
end)