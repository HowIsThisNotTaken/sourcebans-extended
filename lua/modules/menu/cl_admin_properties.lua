properties.Add("sb_warn",
{

	MenuLabel	=	"Warn",
	Order		=	10,
	MenuIcon	=	"icon16/shield.png",

	Filter		=	function(self, ent, ply)
		if not IsValid(ent) or not ent:IsPlayer() then return end
			return ply:IsTrialModerator()
		end,

	Action		=	function(self, ent)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		sourcebans_gui_Warn(ent)
	end
})

properties.Add("sb_kick",
{

	MenuLabel	=	"Kick",
	Order		=	20,
	MenuIcon	=	"icon16/exclamation.png",

	Filter		=	function(self, ent, ply)
		if not IsValid(ent) or not ent:IsPlayer() then return end
			return ply:IsTrialModerator()
		end,

	Action		=	function(self, ent)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		sourceban_gui_Kick(ent)
	end
})

properties.Add("sb_ban",
{

	MenuLabel	=	"Ban",
	Order		=	30,
	MenuIcon	=	"icon16/cross.png",

	Filter		=	function(self, ent, ply)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		return ply:IsTrialModerator()
	end,

	Action		=	function(self, ent)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		sourceban_gui_Ban(ent)
	end
})

properties.Add("sb_BanHistory",
{
	MenuLabel	=	"Ban History",
	Order		=	40,
	MenuIcon	=	"icon16/information.png",

	Filter		=	function(self, ent, ply)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		return ply:IsTrialModerator()
	end,

	Action		=	function(self, ent)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		sourceban_gui_BanHistory(ent)
	end
})

properties.Add("sb_Freeze",
{
	MenuLabel	=	"Toggle Freeze",
	Order		=	50,
	MenuIcon	=	"icon16/error.png",

	Filter		=	function(self, ent, ply)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		return ply:IsTrialModerator()
	end,

	Action		=	function(self, ent)
		if not IsValid(ent) or not ent:IsPlayer() then return end
		sourceban_gui_Freeze(ent)
	end
})
