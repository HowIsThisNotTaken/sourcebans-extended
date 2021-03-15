MsgC(Color(150, 0, 230), "Loading client side functionality of SourceBans\n")
function sourceban_gui_Kick(Player)
	Derma_StringRequest("Kick Player",
	"Reason to kick " .. Player:Nick(),
	"",
	function(reason)
		net.Start("sm_KickPlayer")
			net.WriteEntity(Player)
			net.WriteString(reason)
		net.SendToServer()
	end)
end

function sourceban_gui_Ban(Player)
	Derma_StringRequest("Ban reason for " .. Player:Nick(),
		"Ban reason for " .. Player:Nick(),
		"",
		function(reason)
	Derma_StringRequest("Ban length for ".. Player:Nick(),
		"Ban length for ".. Player:Nick(),
		"",
		function(time)
			if !tonumber(time) then
				Player:ChatPrint("Ban length must be a number!")
			return end
				net.Start("sm_BanPlayer")
					net.WriteEntity(Player)
					net.WriteUInt(time, 32)
					net.WriteString(reason)
				net.SendToServer()
		end)
	end)
end

function sourcebans_gui_teamban(Player)
        local menu = DermaMenu()

        local Padding = vgui.Create("DPanel")
        Padding:SetPaintBackgroundEnabled(false)
        Padding:SetSize(1,5)
        menu:AddPanel(Padding)

        local Title = vgui.Create("DLabel")
        Title:SetText("  Jobs:\n")
        Title:SetFont("UiBold")
        Title:SizeToContents()
        Title:SetTextColor(color_black)
        menu:AddPanel(Title)

        local command = "teamban"
        local uid = Player:UserID()
        for k, v in SortedPairsByMemberValue(RPExtraTeams, "name") do
            local submenu = menu:AddSubMenu(v.name)
            submenu:AddOption("5 minutes",     function() RunConsoleCommand("darkrp", command, uid, k, 300)  end)
            submenu:AddOption("Half an hour",  function() RunConsoleCommand("darkrp", command, uid, k, 1800) end)
            submenu:AddOption("An hour",       function() RunConsoleCommand("darkrp", command, uid, k, 3600) end)
            submenu:AddOption("Until restart", function() RunConsoleCommand("darkrp", command, uid, k, 0)    end)
			submenu:AddOption("Other", function()
				Derma_StringRequest("Length (In minutes)", 
					"Job ban length for " .. Player:Nick(), 
					"", 
					function(time) 
					RunConsoleCommand("darkrp", command, uid, k, time*60) 	
				end) 
			end)
        end
    menu:Open()
end

function sourcebans_gui_ChangeTeam(Player)
	local team_menu = DermaMenu() 
	for _, t in SortedPairsByMemberValue(team.GetAllTeams(), "Name") do
		team_menu:AddOption( t.Name, 
			function() 
				net.Start("sm_ChangeTeam")
					net.WriteEntity(Player)
					net.WriteUInt(_, 32)
				net.SendToServer()
			end)
	end
	team_menu:AddOption( "Close", function() end )
	team_menu:Open()	
end

function sourceban_gui_BanHistory(Player)
	gui.OpenURL("http://yourwebsite.net/bans/index.php?p=banlist&advSearch=" .. Player:SteamID() .. "&advType=steamid")
end

function sourceban_gui_Freeze(Player)
	net.Start("sm_FreezePlayer")
		net.WriteEntity(Player)
	net.SendToServer()
end

function sourceban_gui_Respawn(Player)
	net.Start("sm_RespawnPlayer")
		net.WriteEntity(Player)
	net.SendToServer()
end

function sourceban_gui_kill(Player)
	net.Start("sm_KillPlayer")
		net.WriteEntity(Player)
	net.SendToServer()
end

function sourceban_gui_godmode(Player)
	net.Start("sm_Godmode")
		net.WriteEntity(Player)
	net.SendToServer()
end

function sourceban_gui_Spectate(Player)
	LocalPlayer():ConCommand("fspectate " .. Player:Nick())
end

function sourceban_gui_Goto(Player)
	net.Start("sm_GotoPlayer")
		net.WriteEntity(Player)
	net.SendToServer()
end

function sourceban_gui_Bring(Player)
	net.Start("sm_BringPlayer")
		net.WriteEntity(Player)
	net.SendToServer()
end

function sourceban_gui_StripWeapon(Player)
	net.Start("sm_StripPlayer")
		net.WriteEntity(Player)
	net.SendToServer()
end

local mainContentContainer;
local playerDetailsContainer;

local pogcp_themeColorPrimary = Color(52, 152, 219, 255)
local pogcp_themeColorSecondary = Color(149, 165, 166, 255)
local pogcp_themeColorWhite = Color(255, 255, 255, 255);
local pogcp_themeColorBlack = Color( 0, 0, 0, 255);
local pogcp_themeColorEmerald = Color( 46, 204, 113, 255 )

--Creates a navigation list item for the main menu
local function createNavigationItem(text, width, height, func, lastItem)
	local navigationItem = vgui.Create("DButton")
	navigationItem:SetText(text)
	navigationItem:SetTextColor( Color( 255, 255, 255, 255 ) )
	navigationItem:SetSize(width, height)
	navigationItem:SetFont("pogcp_navigationItem")
	navigationItem.Paint = function(self, w, h)
		draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 128, 185, 250 ))
		draw.RoundedBox( 0, 0, 0, w, 1, pogcp_themeColorBlack)
		if(lastItem) then
			draw.RoundedBox( 0, 0, h-1, w, 1, Color( 0, 0, 0, 255))
		end
	end
	navigationItem.DoClick = func

	return navigationItem;
end

//Create an item within the Player Details Container
local function createPlayerInfoItem(label, content, w, h)
	local playerInfoItem = vgui.Create("DPanel")
	playerInfoItem:SetSize(w, h)

	playerInfoItem.label = vgui.Create("DLabel", playerInfoItem)
	playerInfoItem.label:SetText(label);
	playerInfoItem.label:SetSize(w / 3, h);
	playerInfoItem.label:SetTextColor( Color( 0, 0, 0, 255 ) )
	playerInfoItem.label:SetFont("pogcp_listItem")
	playerInfoItem.label:Dock(LEFT)
	playerInfoItem.label:DockMargin(5, 0, 0, 0)

	playerInfoItem.content = vgui.Create("DLabel", playerInfoItem)
	playerInfoItem.content:SetText(content);
	playerInfoItem.content:SetTextColor( Color( 0, 0, 0, 255 ) )
	playerInfoItem.content:SetFont("pogcp_listItem")
	playerInfoItem.content:Dock(FILL)
	playerInfoItem.content:DockMargin(0, 0, 0, 0)

	return playerInfoItem
end

local function createCommandListItem(label, w, h, fn)
	local commandListItem = vgui.Create("DButton");
	commandListItem:SetText( label )
	commandListItem:SetTextColor( Color( 255, 255, 255, 255 ) )
	commandListItem:SetSize( w, h )
	commandListItem.Paint = function() 
		draw.RoundedBox( 0, 0, 0, w, h, pogcp_themeColorBlack)
		draw.RoundedBox( 0, 1, 1, w-2, h-2, pogcp_themeColorEmerald)
	end
	commandListItem.DoClick = fn

	return commandListItem;
end

//Populate the Player Details Container with info regarding player and command buttons for player
local function populatePlayerDetailsContainer(Player)
	local width = playerDetailsContainer.ProfileContainer:GetWide();
	local height = 30;
	playerDetailsContainer.TitleLabel:SetText(" " .. Player:Nick() .. "'s Profile Information")
	playerDetailsContainer.profileListItems:Clear()
	playerDetailsContainer.profileListItems:Add(createPlayerInfoItem("RP Name:", Player:Nick(), width, height))
	playerDetailsContainer.profileListItems:Add(createPlayerInfoItem("Rank:", Player:GetUserGroup() or "", width, height))
	playerDetailsContainer.profileListItems:Add(createPlayerInfoItem("Rank:", Player:GetUserGroup() or "", width, height))
	if gmod.GetGamemode() == "darkrp" then
		playerDetailsContainer.profileListItems:Add(createPlayerInfoItem("Money:", Player:getDarkRPVar("money") or 0, width, height))
		playerDetailsContainer.profileListItems:Add(createPlayerInfoItem("Job:", Player:getDarkRPVar("job") or "", width, height))
		playerDetailsContainer.profileListItems:Add(createPlayerInfoItem("Currently Arrested:", Player:getDarkRPVar("Arrested") or "No", width, height))
	end

	local wantedText = "No"
	if gmod.GetGamemode() == "darkrp" then	
		if Player:getDarkRPVar("wanted") then
			wantedText = "Yes"
		end
	end

	playerDetailsContainer.profileListItems:Add(createPlayerInfoItem("Currently Wanted:", wantedText, width, height))
	if gmod.GetGamemode() == "darkrp" then
		playerDetailsContainer.profileListItems:Add(createPlayerInfoItem("Wanted Reason:", Player:getDarkRPVar("wantedReason") or "", width, height))
	end
	playerDetailsContainer.profileListItems:SizeToContents();

	local heightCommands = 25;
	playerDetailsContainer.commandListItems:Clear();
	playerDetailsContainer.commandListItems:Add(createCommandListItem("Kick", width, heightCommands, 
		function()
			sourceban_gui_Kick(Player)
		end)
	)
	playerDetailsContainer.commandListItems:Add(createCommandListItem("Ban", width, heightCommands, 
		function()
			sourceban_gui_Ban(Player)
		end)
	)
	playerDetailsContainer.commandListItems:Add(createCommandListItem("View Ban History", width, heightCommands, 
		function()
			sourceban_gui_BanHistory(Player)
		end)
	)
	if gmod.GetGamemode() == "darkrp" then
		playerDetailsContainer.commandListItems:Add(createCommandListItem("Team Ban", width, heightCommands, 
			function()
				sourcebans_gui_teamban(Player)
			end)
		)
	end
	playerDetailsContainer.commandListItems:Add(createCommandListItem("Respawn", width, heightCommands, 
		function()
			sourceban_gui_Respawn(Player)
		end)
	)
	playerDetailsContainer.commandListItems:Add(createCommandListItem("Kill", width, heightCommands, 
		function()
			sourceban_gui_kill(Player)
		end)
	)
	playerDetailsContainer.commandListItems:Add(createCommandListItem("Freeze", width, heightCommands, 
		function()
			sourceban_gui_Freeze(Player)
		end)
	)
	playerDetailsContainer.commandListItems:Add(createCommandListItem("Go To", width, heightCommands, 
		function()
			sourceban_gui_Goto(Player)
		end)
	)
	playerDetailsContainer.commandListItems:Add(createCommandListItem("Bring", width, heightCommands, 
		function()
			sourceban_gui_Bring(Player)
		end)
	)
	playerDetailsContainer.commandListItems:Add(createCommandListItem("God", width, heightCommands, 
		function()
			sourceban_gui_godmode(Player)
		end)
	)
	if gmod.GetGamemode() == "darkrp" then
		playerDetailsContainer.commandListItems:Add(createCommandListItem("Change Team", width, heightCommands, 
			function()
				sourcebans_gui_ChangeTeam(Player)
			end)
		)
	end
	playerDetailsContainer.commandListItems:Add(createCommandListItem("Strip Weapons", width, heightCommands, 
		function()
			sourceban_gui_StripWeapon(Player)
		end)
	)
	


	playerDetailsContainer.commandListItems:SizeToContents();
end

//Create an item within the Player List Container
local function createPlayerItem(Player, width, height)
	local playerItem = vgui.Create("DButton")
	playerItem:SetText(Player:Nick())
	playerItem:SetTextColor( Color( 255, 255, 255, 255 ) )
	playerItem:SetSize(width, height)
	playerItem.Paint = function(self, w, h)
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 255 ))
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color(241, 196, 15, 255))
	end

	playerItem.DoClick = function()
		populatePlayerDetailsContainer(Player);
	end

	return playerItem;
end

local function showPlayerManagement()
	if(mainContentContainer.currentContentContainer != nil) then
		mainContentContainer.currentContentContainer:Remove();
	end

	local width = mainContentContainer:GetWide();
	local height = mainContentContainer:GetTall();

	local playerManagementContainer = vgui.Create("DPanel", mainContentContainer)
	playerManagementContainer:Dock(FILL);

	mainContentContainer.currentContentContainer = playerManagementContainer;

	--Player List
	local playerListContainerWidth = width / 3;
	local playerListContainerLabelHeight = 25;
	local playerListContainerLabel = vgui.Create("DLabel", playerManagementContainer);
	playerListContainerLabel:SetPos(0, 0)
	playerListContainerLabel:SetSize(playerListContainerWidth, playerListContainerLabelHeight);
	playerListContainerLabel:SetText(" Select a Player")
	playerListContainerLabel:SetFont("pogcp_navigationItem")
	playerListContainerLabel:SetTextColor(Color(0, 0, 0, 255))
	playerListContainerLabel.Paint = function(self, w, h)
		draw.RoundedBox( 0, 0, 0, w, h, pogcp_themeColorBlack )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, pogcp_themeColorPrimary)
	end
	local playerListContainer = vgui.Create("DScrollPanel", playerManagementContainer);
	playerListContainer:SetSize( playerListContainerWidth, height - playerListContainerLabelHeight)
	playerListContainer:SetPos( 0, playerListContainerLabelHeight )
	playerListContainer:SetPaintBackground( true )
	playerListContainer:SetBackgroundColor( pogcp_themeColorSecondary )

	local playerList = vgui.Create("DListLayout", playerListContainer);
	playerList:SetSize( playerListContainerWidth, height - playerListContainerLabelHeight)
	playerList:SetPos( 0, 0 )

	for k, v in SortedPairs(player.GetAll()) do
		playerList:Add(createPlayerItem(v, width, 24))
	end
	playerList:SizeToContents()

	--Player Details Container
	local playerDetailsContainerWidth = width - playerListContainerWidth
	playerDetailsContainer = vgui.Create("DPanel", playerManagementContainer);
	playerDetailsContainer:SetPos(playerListContainerWidth, 0);
	playerDetailsContainer:SetSize(playerDetailsContainerWidth, height);
	playerDetailsContainer.Paint = function(self, w, h)
		draw.RoundedBox( 0, 0, 0, w, h, pogcp_themeColorBlack)
		draw.RoundedBox( 0, 1, 1, w-2, h-2, pogcp_themeColorWhite)
	end

		//Profile Info Container
		local titleLabelHeight = playerListContainerLabelHeight;
		playerDetailsContainer.TitleLabel = vgui.Create("DLabel", playerDetailsContainer);
		playerDetailsContainer.TitleLabel:SetPos(0, 0)
		playerDetailsContainer.TitleLabel:SetSize(playerDetailsContainerWidth, titleLabelHeight);
		playerDetailsContainer.TitleLabel:SetText(" Player Information")
		playerDetailsContainer.TitleLabel:SetFont("pogcp_navigationItem")
		playerDetailsContainer.TitleLabel:SetTextColor(Color(0, 0, 0, 255))
		playerDetailsContainer.TitleLabel.Paint = function(self, w, h)
			draw.RoundedBox( 0, 0, 0, w, h, pogcp_themeColorBlack )
			draw.RoundedBox( 0, 1, 1, w-2, h-2, pogcp_themeColorPrimary)
		end

		local profileContainerHeight = (height - (titleLabelHeight*2)) / 2;
		playerDetailsContainer.ProfileContainer = vgui.Create("DScrollPanel", playerDetailsContainer);
		playerDetailsContainer.ProfileContainer:SetPos(0, titleLabelHeight);
		playerDetailsContainer.ProfileContainer:SetSize(playerDetailsContainerWidth, profileContainerHeight);
		playerDetailsContainer.ProfileContainer.Paint = function(self, w, h)
			draw.RoundedBox( 0, 0, 0, w, h, pogcp_themeColorBlack )
			draw.RoundedBox( 0, 1, 0, w-2, h, pogcp_themeColorSecondary )
		end

		playerDetailsContainer.profileListItems = vgui.Create("DListLayout", playerDetailsContainer.ProfileContainer);
		playerDetailsContainer.profileListItems:SetSize( playerDetailsContainerWidth, profileContainerHeight)
		playerDetailsContainer.profileListItems:SetPos( 0, 0 )

		//Commands Sub-Container
		playerDetailsContainer.CommandLabel = vgui.Create("DLabel", playerDetailsContainer);
		playerDetailsContainer.CommandLabel:SetPos(0, profileContainerHeight + titleLabelHeight)
		playerDetailsContainer.CommandLabel:SetSize(playerDetailsContainerWidth, titleLabelHeight);
		playerDetailsContainer.CommandLabel:SetText(" Commands")
		playerDetailsContainer.CommandLabel:SetFont("pogcp_navigationItem")
		playerDetailsContainer.CommandLabel:SetTextColor(Color(0, 0, 0, 255))
		playerDetailsContainer.CommandLabel.Paint = function(self, w, h)
			draw.RoundedBox( 0, 0, 0, w, h, pogcp_themeColorBlack )
			draw.RoundedBox( 0, 1, 1, w-2, h-2, pogcp_themeColorPrimary)
		end

		playerDetailsContainer.CommandContainer = vgui.Create("DScrollPanel", playerDetailsContainer);
		playerDetailsContainer.CommandContainer:SetPos(0, profileContainerHeight + (titleLabelHeight * 2));
		playerDetailsContainer.CommandContainer:SetSize(playerDetailsContainerWidth, profileContainerHeight);
		playerDetailsContainer.CommandContainer.Paint = function(self, w, h)
			draw.RoundedBox( 0, 0, 0, w, h, pogcp_themeColorBlack )
			draw.RoundedBox( 0, 1, 0, w-2, h, pogcp_themeColorSecondary )
		end

		playerDetailsContainer.commandListItems = vgui.Create("DListLayout", playerDetailsContainer.CommandContainer);
		playerDetailsContainer.commandListItems:SetSize( playerDetailsContainerWidth, profileContainerHeight)
		playerDetailsContainer.commandListItems:SetPos( 0, 0 )

end

local function addban()
	local menu = DermaMenu()
	menu:AddOption("Add Ban", function()
		Derma_StringRequest("SteamID to ban", 
		"Enter the SteamID you wish to ban", 
		"",
		function(steamid)

		Derma_StringRequest("Ban Length", 
		"Length to ban " .. steamid, 
		"",
		function(time)

		Derma_StringRequest("Ban Reason",
		"Reason to ban " .. steamid,
		"",
		function(reason)

		Derma_StringRequest("Name of the SteamID", 
		"What is the name of " .. steamid, 
		"", 
		function(name)

		net.Start("sm_AddBan")
			net.WriteString(steamid)
			net.WriteUInt(time, 32)
			net.WriteString(reason)
			net.WriteString(name)
		net.SendToServer()
		end)
		end)
		end)
		end)
	end)
	menu:AddOption("Unban", function()
		Derma_StringRequest("SteamID to Unban",
		"Enter the SteamID you want to unban",
		"",
		function(steamid)

		Derma_StringRequest("Reason to Unban",
		"Why do you want to unban " .. steamid,
		"",
		function(reason)

		net.Start("sm_Unban")
			net.WriteString(steamid)
			net.WriteString(reason)
		net.SendToServer()
		end)
		end)
	end)
	menu:AddOption("Close", function() end)
	menu:Open()
end

local function sourcebans_gui_CreateMainMenu()
	local mainContainerWidth, mainContainerHeight;

  	local mainContainer = vgui.Create( "DFrame" )
  	mainContainer:SetSize( 800, 500 )
  	mainContainer:SetTitle( "SourceBans Admin Menu" )
  	mainContainer:SetVisible( true )
  	mainContainer:ShowCloseButton( false )
  	mainContainer:SetDraggable( true )
	mainContainer:Center()
  	mainContainer:MakePopup()
  	mainContainer.Paint = function(self, w, h)
		draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
	end

	mainContainerWidth = mainContainer:GetWide()
	mainContainerHeight = mainContainer:GetTall()

	--Top right close button
	local closeButton = vgui.Create("DButton", mainContainer)
	closeButton:SetText( "X" )
	closeButton:SetTextColor( Color( 255, 255, 255, 255 ) )
	closeButton:SetPos( mainContainerWidth-15, 5)
	closeButton:SetSize( 10, 10 )
	closeButton.Paint = function() end
	closeButton.DoClick = function() mainContainer:Close(); end

	local mainContainerTopOffset = 25;
	local sideBarContainerWidth = 200;
	local sideBarContainerHeight = mainContainerHeight - mainContainerTopOffset;

	--Side Navigation Bar
	local sideBarContainer = vgui.Create("DPanel", mainContainer)
	sideBarContainer:SetPos( 0, mainContainerTopOffset) -- Set the position of the panel
	sideBarContainer:SetSize( sideBarContainerWidth, sideBarContainerHeight ) -- Set the size of the panel

		--Navigation Item Container
		local navigationContainer = vgui.Create( "DListLayout", sideBarContainer )
		navigationContainer:SetSize( sideBarContainerWidth, sideBarContainerHeight)
		navigationContainer:SetPos( 0, 0 )

		navigationContainer:SetPaintBackground( true )
		navigationContainer:SetBackgroundColor( Color( 0, 100, 100 ) )
		navigationContainer:MakeDroppable( "navigationContainerDroppable" ) -- Allows us to rearrange children
		navigationContainer:Add(createNavigationItem("Player Management", sideBarContainerWidth, 45, showPlayerManagement, false))
		navigationContainer:Add(createNavigationItem("Ban Management", sideBarContainerWidth, 45, addban, true))

	--Main Content Container
	mainContentContainer = vgui.Create("DPanel", mainContainer)
	mainContentContainer:SetPos(sideBarContainerWidth + 5, mainContainerTopOffset)
	mainContentContainer:SetSize(mainContainerWidth - sideBarContainerWidth - 5, sideBarContainerHeight);

	--Show player management by default
	showPlayerManagement();

end

net.Receive("sm_AdminMenu", function(length, Player)
	sourcebans_gui_CreateMainMenu()
end)
