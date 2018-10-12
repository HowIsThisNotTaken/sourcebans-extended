local function url(Player) --Change the localhost part to your ban page; this searches bans by steamid
	gui.OpenURL("http://localhost/bans/index.php?p=banlist&advSearch=" .. Player:SteamID() .. "&advType=steamid")
end

properties.Add("sb_kick",
{

	MenuLabel	=	"Kick",
	Order		=	10,
	MenuIcon	=	"icon16/exclamation.png",

	Filter		=	function(self, ent, ply)
		if not IsValid(ent) or not ent:IsPlayer() then return end
			return ply:IsModerator()
		end,

	Action		=	function(self, ent)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		sourceban_gui_Kick(ent)
	end
})

properties.Add("sb_ban",
{

	MenuLabel	=	"Ban",
	Order		=	20,
	MenuIcon	=	"icon16/delete.png",

	Filter		=	function(self, ent, ply)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		return ply:IsModerator()
	end,

	Action		=	function(self, ent)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		sourceban_gui_Ban(ent)
	end
})

properties.Add("sb_BanHistory",
{
	MenuLabel	=	"Ban History",
	Order		=	30,
	MenuIcon	=	"icon16/information.png",

	Filter		=	function(self, ent, ply)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		return ply:IsModerator()
	end,

	Action		=	function(self, ent)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		url(ent)
	end
})

properties.Add("sb_Freeze",
{
	MenuLabel	=	"Freeze",
	Order		=	40,
	MenuIcon	=	"icon16/error.png",

	Filter		=	function(self, ent, ply)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		return ply:IsModerator()
	end,

	Action		=	function(self, ent)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		sourceban_gui_Freeze(ent)
	end
})
