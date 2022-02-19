net.Receive("sourcebans_notification", function()
	local Text = net.ReadString()
	local Type = net.ReadInt(4)
	local Time = net.ReadInt(8)

	print(Text);
	notification.AddLegacy(Text, Type, Time);
	surface.PlaySound( "buttons/button15.wav" )
end)

net.Receive("sourcebans_chatact", function()
	local admin = net.ReadEntity()
	local action = net.ReadString()
	local target = net.ReadEntity()
	local actionC = Color(19, 252, 3)
	local playerC = Color(3, 152, 252)

	if IsValid(target) then
		--chat.AddText(playerC, admin, actionC, action, target, playerC)
		chat.AddText(playerC, admin:Nick(), actionC, action, playerC, target:Nick())
	else
		chat.AddText(playerC, admin:Nick(), actionC, action)
	end
end)

function sourcebans_chatact(Player, text, Target)
	net.Start("sourcebans_chatact")
		net.WriteEntity(Player)
		net.WriteString(text)
		net.WriteEntity(Target)
	net.SendToServer()
end