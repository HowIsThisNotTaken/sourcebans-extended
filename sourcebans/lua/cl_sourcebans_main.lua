include("sh_sourcebans_shared.lua")

local function LoadModules()
	local root = "modules/"

	local _, folders = file.Find(root.."*", "LUA")

	for _, folder in SortedPairs(folders, true) do

		for _, File in SortedPairs(file.Find(root .. folder .."/sh_*.lua", "LUA"), true) do
			include(root.. folder .. "/" ..File)
		end
		for _, File in SortedPairs(file.Find(root .. folder .."/cl_*.lua", "LUA"), true) do
			include(root.. folder .. "/" ..File)
		end
	end
end

LoadModules()

--Fonts
surface.CreateFont("pogcp_navigationItem",{
	font = "Arial",
	extended = false,
	size = 22,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
	}
);

surface.CreateFont("pogcp_listItem",{
	font = "Arial",
	extended = false,
	size = 18,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
	}
);

surface.CreateFont("pogcp_listItemBold",{
	font = "Arial",
	extended = false,
	size = 18,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
	}
);