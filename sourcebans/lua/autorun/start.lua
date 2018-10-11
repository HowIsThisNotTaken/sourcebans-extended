if (SERVER) then
	include("sv_sourcebans_main.lua")
elseif (CLIENT) then
	include("cl_sourcebans_main.lua")
end