net.Receive("sourcebans_notification", function()
	local Text = net.ReadString()
	local Type = net.ReadInt(4)
	local Time = net.ReadInt(8)

	print(Text);
	notification.AddLegacy(Text, Type, Time);
	surface.PlaySound( "buttons/button15.wav" )
end)