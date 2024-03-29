local chatcommands = {};

hook.Add("PlayerSay", "ChatCommandAPI", function (ply, text, teamC)
	local chat_string = string.Explode(" ", text);
	
	for k, v in pairs( chatcommands ) do
		if( chat_string[1] == k ) then
			table.remove(chat_string, 1);
			v(ply, chat_string);
			
			return "";
		end
		
		if( string.find(k, chat_string[1]) != nil ) then
			local start, endp, word = string.find(k, chat_string[1]);
			
			if( endp - (start - 1) > 2 ) then
				ply:ChatPrint("Invalid command! Did you mean '"..tostring( k ).."'?");
				
				return "";
			end
		end
	end
	
	return text;
end)

function RegisterChatCommand(strCommand, Func)
	if( !strCommand || !Func ) then return; end
	
	for k, v in pairs( chatcommands ) do
		if( strCommand == k ) then
			return;
		end
	end
	
	chatcommands[ tostring( strCommand ) ] = Func;
end

--[[Chat commands :D]]--
util.AddNetworkString("sm_reportmenu")
RegisterChatCommand("/report", function(ply, args)
	if IsValid(ply) then
		net.Start("sm_reportmenu")
        net.Send(ply)
	end
end)

RegisterChatCommand("/respawn", function(ply, args)
	if ply:IsTrialModerator() then
		local target = sm_FindPlayer(args[1])

		if target == nil then
			sourcebans_notify(ply, "No target!", 1, 4) 
		return end

		target:Spawn()
		target:SetNoDraw(false)
		target:SetNotSolid(false)
		target:GodDisable()
		target:DrawWorldModel(true)
		sourcebans_notify(ply, "Respawned: " .. target:Nick(), 0, 4)
		sourcebans_chatact(ply, " respawned ", target)
	end
end)

RegisterChatCommand("/goto", function(ply, args)
	if ply:IsTrialModerator() then
		local target = sm_FindPlayer(args[1])

		if target == nil then
			sourcebans_notify(ply, "No target!", 1, 4) 
		return end

		if ply:InVehicle() then
			ply:ExitVehicle()
		end

		ply:SetPos( target:GetPos() + target:GetForward() * 50 )
		sourcebans_notify(ply, "Teleported to: " .. target:Nick(), 0, 4)
		sourcebans_chatact(ply, " teleported to ", target)
	end
end)

RegisterChatCommand("/bring", function(ply, args)
	if ply:IsTrialModerator() then
		local target = sm_FindPlayer(args[1])

		if target == nil then
			sourcebans_notify(ply, "No target!", 1, 4) 
		return end

		if target:InVehicle() then
			target:ExitVehicle()
		end

		if !target:Alive() then
			sourcebans_notify(ply, target:Nick() .. " is dead!", 1, 4)
		return end

		target:SetPos( ply:GetPos() + ply:GetForward() * 50 )
		sourcebans_notify(ply, "Brought: " .. target:Nick(), 0, 4)
		sourcebans_chatact(ply, " brought ", target)
	end
end)

RegisterChatCommand("/fbring", function(ply, args)
	if ply:IsTrialModerator() then
		local target = sm_FindPlayer(args[1])

		if target == nil then
			sourcebans_notify(ply, "No target!", 1, 4) 
		return end

		if target:InVehicle() then
			target:ExitVehicle()
		end

		if !target:Alive() then
			sourcebans_notify(ply, target:Nick() .. " is dead!", 1, 4)
		return end

		target:SetPos( ply:GetPos() + ply:GetForward() * 50 )
		target:Freeze(true)
		sourcebans_notify(ply, "Brought: " .. target:Nick(), 0, 4)
		sourcebans_chatact(ply, " froze and brought ", target)
	end
end)

RegisterChatCommand("/freeze", function(ply, args)
	if ply:IsTrialModerator() then
		local target = sm_FindPlayer(args[1])

		if target == nil then
			sourcebans_notify(ply, "No target!", 1, 4) 
		return end

		if !target:Alive() then
			sourcebans_notify(ply, target:Nick() .. " is dead!", 1, 4)
		return end

		target:Freeze(true)
		sourcebans_notify(ply, "Froze: " .. target:Nick(), 0, 4)
		sourcebans_chatact(ply, " froze ", target)
	end
end)

RegisterChatCommand("/unfreeze", function(ply, args)
	if ply:IsTrialModerator() then
		local target = sm_FindPlayer(args[1])

		if target == nil then
			ply:ChatPrint("No target!") 
		return end

		target:Freeze(false)
		sourcebans_notify(ply, "Unfroze: " .. target:Nick(), 0, 4)
		sourcebans_chatact(ply, " unfroze ", target)
	end
end)

RegisterChatCommand("/kill", function(ply, args)
	if ply:IsTrialModerator() then
		local target = sm_FindPlayer(args[1])

		if target == nil then
			sourcebans_notify(ply, "No target!", 1, 4) 
		return end

		if !target:Alive() then
			sourcebans_notify(ply, target:Nick() .. " is dead!", 1, 4)
		return end
		
		target:Kill()
		sourcebans_notify(ply, "Killed: " .. target:Nick(), 0, 4)
		sourcebans_chatact(ply, " force killed ", target)
	end
end)

RegisterChatCommand("/god", function(ply, args)
	if ply:IsTrialModerator() then
		local target = sm_FindPlayer(args[1])

		if target == nil then
			ply:GodEnable()
			sourcebans_notify(ply, "Enabled God Mode!", 0, 4)
			sourcebans_chatact(ply, " enabled god mode for themself")
		end

		target:GodEnable()
		sourcebans_notify(ply, "Enabled God Mode for: " .. target:Nick(), 0, 4)
		sourcebans_chatact(ply, " enabled god mode for ", target)
	end
end)

RegisterChatCommand("/ungod", function(ply, args)
	if ply:IsTrialModerator() then
		local target = sm_FindPlayer(args[1])

		if target == nil then
			ply:GodDisable()
			sourcebans_notify(ply, "Disabled god mode!", 0, 4)
			sourcebans_chatact(ply, " disabled god mode for themself")
		end

		target:GodDisable()
		sourcebans_notify(ply, "Disabled god mode for: " .. target:Nick(), 0, 4)
		sourcebans_chatact(ply, " disabled got mode for ", target)
	end
end)

RegisterChatCommand("/strip", function(ply, args)
	if ply:IsTrialModerator() then
		local target = sm_FindPlayer(args[1])

		if target == nil then
			sourcebans_notify(ply, "No target!", 1, 4) 
		return end

		target:StripWeapons()
		sourcebans_notify(ply, "Stripped: " .. target:Nick(), 0, 4)
		sourcebans_chatact(ply, " stripped weapons from ", target)
	end
end)
MsgC(Color(0, 0, 255), "[SourceBans]Loading up chat commands\n")
