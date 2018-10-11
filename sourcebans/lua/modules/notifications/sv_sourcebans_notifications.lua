/*
Type ENUMS
0 = Generic
1 = Error
2 = Undo
3 = Hint
4 = Clean up
*/

util.AddNetworkString("sourcebans_notification")
function sourcebans_notify(Player, Text, Type, Time)
	if not IsValid(Player) then print("Invalid Player") return end
	if (Text == nil) then print("No Text Given") return end
	if (Type == nil) then Type = 0 end
	if (Time == nil) then Time = 5 end

	net.Start("sourcebans_notification")
		net.WriteString(Text)
		net.WriteInt(Type, 4)
		net.WriteInt(Time, 8)
	net.Send(Player)
end
