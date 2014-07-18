/*******************************************************************************
	ArenaGameInfo

	Creation date: 30/06/2012 16:51
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This forms the base for all Arena gametypes.  
 */
class ArenaGameInfo extends UDKGame;


/** The teams for the game. */
var array<ArenaTeamInfo> Teams;

/** The class of the team info to use for the teams. */
var class<ArenaTeamInfo> TeamInfoClass;

/**
 * The settings to use for the game.  These are generally piped in from the UI or a server.
 */
var GISettings GameSettings;

/**
 * The class of the settings to use for this game type.
 */
var class<GISettings> SettingsClass;

/** The respawn time for all players during this gametype. */
var float RespawnTime;

/**
 * The amount of time allotted for the initial intermission.
 */
var float InitialIntermissionTime;

/** Indicates that the player can fast respawn (spawn immidiately) during this gametype. */
var bool AllowFastRespawn;

/** Indicates that dead players can respawn. */
var bool CanRespawn;

/** Forces the player to respawn after the respawn timer ends. */
var bool ForceRespawn;

/** Indicates that the server manages team balance. */
var bool AutoBalance;

/**
 * Indicates that the game starts with an initial intermission, allowing players the chance to choose characters and weapons before the game begins.
 */
var bool InitialIntermission;

/**
 * Indicates that we are currently in the initial intermission.
 */
var bool InInitialIntermission;

/** The maximum number of teams allowed for the game. */
var int MaxTeams;

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	SetGameReplicationInfo();
	
	if (InitialIntermission)
	{
		InInitialIntermission = true;
		DefaultPawnClass = class'Arena.AP_Specter';
		HUDType = class'Arena.ArenaHUD';
		SetTimer(InitialIntermissionTime, false, 'StartGame');
	}
}

simulated event InitGame(string options, out string errorMessage)
{
    local string settings;
    super.InitGame(options, errorMessage);

    settings = ParseOption(Options, "settings");
	
    if (settings != "")
    {
		GameSettings = new SettingsClass;
		GameSettings.Deserialize(settings);
	}
}

event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local NavigationPoint StartSpot;
	local PlayerController NewPlayer;
	local string InName, InCharacter/*, InAdminName*/, InPassword;
	local byte InTeam;
	local bool bSpectator, bAdmin, bPerfTesting;
	local rotator SpawnRotation;
	local UniqueNetId ZeroId;

	bAdmin = false;

	if (bUsingArbitration && bHasArbitratedHandshakeBegun)
	{
		ErrorMessage = PathName(WorldInfo.Game.GameMessageClass) $ ".ArbitrationMessage";
		return None;
	}

	if ( BaseMutator != None )
		BaseMutator.ModifyLogin(Portal, Options);

	bPerfTesting = ParseOption(Options, "AutomatedPerfTesting") ~= "1";
	bSpectator = bPerfTesting || (ParseOption(Options, "SpectatorOnly") ~= "1");

	InName = Left(ParseOption ( Options, "Name"), 20);
	InTeam = GetIntOption( Options, "Team", 255 );
	InPassword = ParseOption ( Options, "Password" );

	if (AccessControl != None)
		bAdmin = AccessControl.ParseAdminOptions(Options);

	if (!bAdmin && AtCapacity(bSpectator))
	{
		ErrorMessage = PathName(WorldInfo.Game.GameMessageClass) $ ".MaxedOutMessage";
		return None;
	}

	if(( WorldInfo.Game.AccessControl != none ) && (WorldInfo.Game.AccessControl.IsIDBanned(UniqueId)))
	{
		`Log(InName @ "is banned, rejecting...");
		ErrorMessage = "Engine.AccessControl.SessionBanned";
		return None;
	}

	if (bAdmin && AtCapacity(false))
		bSpectator = true;
		
	InTeam = PickTeam(InTeam,None);
	StartSpot = FindPlayerStart( None, InTeam, Portal );

	if (StartSpot == None)
	{
		ErrorMessage = PathName(WorldInfo.Game.GameMessageClass) $ ".FailedPlaceMessage";
		return None;
	}


	SpawnRotation.Yaw = StartSpot.Rotation.Yaw;
		
	NewPlayer = SpawnPlayerController(StartSpot.Location, SpawnRotation);

	if (NewPlayer == None)
	{
		`log("Couldn't spawn player controller of class "$PlayerControllerClass);
		ErrorMessage = PathName(WorldInfo.Game.GameMessageClass) $ ".FailedSpawnMessage";
		return None;
	}
	
	if (InInitialIntermission && InitialWindow(StartSpot) != None && ArenaPlayerController(NewPlayer) != None)
		ArenaPlayerController(NewPlayer).SetLookAt(InitialWindow(StartSpot).LookAt);
		
	NewPlayer.StartSpot = StartSpot;
	NewPlayer.PlayerReplicationInfo.PlayerID = GetNextPlayerID();

	if (AccessControl == none || !AccessControl.IsPendingAuth(UniqueId))
		NewPlayer.PlayerReplicationInfo.SetUniqueId(UniqueId);

	if (OnlineSub != None && OnlineSub.GameInterface != None && UniqueId != ZeroId)
		WorldInfo.Game.OnlineSub.GameInterface.RegisterPlayer(PlayerReplicationInfoClass.default.SessionName, UniqueId, HasOption(Options, "bIsFromInvite"));
		
	RecalculateSkillRating();

	if(InName=="")
		InName=DefaultPlayerName$NewPlayer.PlayerReplicationInfo.PlayerID;

	ChangeName( NewPlayer, InName, false );

	InCharacter = ParseOption(Options, "Character");
	NewPlayer.SetCharacter(InCharacter);

	if ( bSpectator || NewPlayer.PlayerReplicationInfo.bOnlySpectator || !ChangeTeam(newPlayer, InTeam, false) )
	{
		NewPlayer.GotoState('Spectating');
		NewPlayer.PlayerReplicationInfo.bOnlySpectator = true;
		NewPlayer.PlayerReplicationInfo.bIsSpectator = true;
		NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
		return NewPlayer;
	}

	if (AccessControl != None && AccessControl.AdminLogin(NewPlayer, InPassword))
		AccessControl.AdminEntered(NewPlayer);

	if (bDelayedStart)
	{
		NewPlayer.GotoState('PlayerWaiting');
		return NewPlayer;
	}

	return newPlayer;
}

event PostLogin( PlayerController NewPlayer )
{
	local string Address, StatGuid;
	local int pos, i;
	local Sequence GameSeq;
	local array<SequenceObject> AllInterpActions;

	if (NewPlayer.PlayerReplicationInfo.bOnlySpectator)
		NumSpectators++;
	else if (WorldInfo.IsInSeamlessTravel() || NewPlayer.HasClientLoadedCurrentWorld())
		NumPlayers++;
	else
		NumTravellingPlayers++;

	UpdateGameSettingsCounts();

	Address = NewPlayer.GetPlayerNetworkAddress();
	pos = InStr(Address,":");
	NewPlayer.PlayerReplicationInfo.SavedNetworkAddress = (pos > 0) ? left(Address,pos) : Address;

	FindInactivePRI(NewPlayer);

	if ( !bDelayedStart )
	{
		bRestartLevel = false;
		
		if (bWaitingToStartMatch)
			StartMatch();
		else
			RestartPlayer(newPlayer);
			
		bRestartLevel = Default.bRestartLevel;
	}

	if (NewPlayer.Pawn != None)
		NewPlayer.Pawn.ClientSetRotation(NewPlayer.Pawn.Rotation);

	NewPlayer.ClientCapBandwidth(NewPlayer.Player.CurrentNetSpeed);
	UpdateNetSpeeds();

	GenericPlayerInitialization(NewPlayer);

	if (ArenaPlayerController(NewPlayer) != None && ArenaHUD(ArenaPlayerController(NewPlayer).MyHUD) != None)
	{
		ArenaHUD(ArenaPlayerController(NewPlayer).MyHUD).DisplayOverlayMenu(class'Arena.GFx_InitialIntermission', false);
		GFx_InitialIntermission(ArenaHUD(ArenaPlayerController(NewPlayer).MyHUD).OverlayMenu).Duration = InitialIntermissionTime;
	}
	
	if (GameReplicationInfo.bMatchHasBegun && OnlineSub != None && OnlineSub.StatsInterface != None)
	{
		StatGuid = OnlineSub.StatsInterface.GetHostStatGuid();
		
		if (StatGuid != "")
			NewPlayer.ClientRegisterHostStatGuid(StatGuid);
	}

	if (bRequiresPushToTalk)
		NewPlayer.ClientStopNetworkedVoice();
	else
		NewPlayer.ClientStartNetworkedVoice();

	if (NewPlayer.PlayerReplicationInfo.bOnlySpectator)
		NewPlayer.ClientGotoState('Spectating');

	GameSeq = WorldInfo.GetGameSequence();
	
	if (GameSeq != None)
	{
		GameSeq.FindSeqObjectsByClass(class'SeqAct_Interp', true, AllInterpActions);
		
		for (i = 0; i < AllInterpActions.Length; i++)
			SeqAct_Interp(AllInterpActions[i]).AddPlayerToDirectorTracks(NewPlayer);
	}

	if (InInitialIntermission)
		NewPlayer.SetCinematicMode(true, true, false, true, true, true);
}

function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string IncomingName)
{
	local array<InitialWindow> windows;
	local InitialWindow iter;
	
	if (InInitialIntermission)
	{
		//`log("Finding initial window");
		
		foreach WorldInfo.AllNavigationPoints(class'Arena.InitialWindow', iter)
		{
			//`log("Found" @ iter);

			windows.AddItem(iter);
		}
		
		if (windows.length == 0)
			return super.FindPlayerStart(Player, InTeam, IncomingName);
		else
			return windows[Rand(windows.length)];
	}
	else
	{
		return super.FindPlayerStart(Player, InTeam, IncomingName);
	}
}

/**
 * This sets the GRI variables to be consistent with the game info variables every tick.
 */
function SetGameReplicationInfo()
{
	if (ArenaGRI(GameReplicationInfo) != None)
	{
		ArenaGRI(GameReplicationInfo).RespawnTime = RespawnTime;
		ArenaGRI(GameReplicationInfo).AllowFastRespawn = AllowFastRespawn;
		ArenaGRI(GameReplicationInfo).CanRespawn = CanRespawn;
		ArenaGRI(GameReplicationInfo).ForceRespawn = ForceRespawn;
		ArenaGRI(GameReplicationInfo).GameSettings = GameSettings;
	}
}

function CreateTeam(string tName)
{
	local ArenaTeamInfo team;
	
	if (Teams.Length < MaxTeams)
	{
		team = spawn(TeamInfoClass);
		//team.TeamName = tName;
		
		Teams.AddItem(team);
	}
}

simulated function StartGame()
{
	local PlayerController P;
	
	`log("Starting game");
	
	DefaultPawnClass = class'Arena.AP_Player';
	HUDType = class'Arena.ArenaHUD';
	InInitialIntermission = false;
	

	foreach WorldInfo.AllControllers(class'PlayerController', P)
	{
		if (ArenaPlayerController(P) != None)
			ArenaPlayerController(P).ClearLookAt();
			
		P.SetCinematicMode(false, true, false, true, true, true);
		//P.ClientSetHUD(HudType);
		P.Pawn.Destroy();
		
		if (ArenaHUD(P.MyHUD) != None)
		{
			if (GFx_InitialIntermission(ArenaHUD(P.MyHUD).OverlayMenu) != None && ArenaPlayerController(P) != None)
				ArenaPlayerController(P).SetCurrentLoadout(GFx_InitialIntermission(ArenaHUD(P.MyHUD).OverlayMenu).GetSelectedCharacter());
				
			ArenaHUD(P.MyHUD).CloseOverlayMenu();
		}
		
		RestartPlayer(P);
	}
}

defaultproperties
{
	PlayerControllerClass=class'Arena.ArenaPlayerController'
	DefaultPawnClass=class'Arena.AP_Player'
	HUDType=class'Arena.ArenaHUD'
	GameReplicationInfoClass=class'Arena.ArenaGRI'
	PlayerReplicationInfoClass=class'Arena.ArenaPRI'

	SettingsClass=class'Arena.GISettings'
	RespawnTime=3
	AllowFastRespawn=false
	CanRespawn=true
	ForceRespawn=true
}