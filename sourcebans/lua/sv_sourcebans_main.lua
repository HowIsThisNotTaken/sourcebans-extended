include("sv_sourcebans_database.lua")
include("sh_sourcebans_shared.lua")

AddCSLuaFile("cl_sourcebans_main.lua")
AddCSLuaFile("sh_sourcebans_shared.lua")


//Include Modules
local fol = "modules/"
local files, folders = file.Find(fol .. "*", "LUA")
for k,v in pairs(files) do
	include(fol .. v)
end

for _, folder in SortedPairs(folders, true) do
	if folder == "." or folder == ".." then continue end

	for _, File in SortedPairs(file.Find(fol .. folder .."/sh_*.lua", "LUA"), true) do
		AddCSLuaFile(fol..folder .. "/" ..File)
		include(fol.. folder .. "/" ..File)
	end
	for _, File in SortedPairs(file.Find(fol .. folder .."/sv_*.lua", "LUA"), true) do
		include(fol.. folder .. "/" ..File)
	end

	for _, File in SortedPairs(file.Find(fol .. folder .."/cl_*.lua", "LUA"), true) do
		AddCSLuaFile(fol.. folder .. "/" ..File)
	end
end