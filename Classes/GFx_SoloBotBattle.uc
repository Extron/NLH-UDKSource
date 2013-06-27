/*******************************************************************************
	GFx_SoloBotBattle

	Creation date: 24/06/2013 02:54
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This menu is where the user chooses the setting for a solo bot battle game.
 */
class GFx_SoloBotBattle extends GFx_Menu;

const NativeWidth = 1600;
const NativeHeight = 900;

/**
 * The Dek cube to use to help display the menu.
 */
var SkeletalMeshComponent Cube;

/**
 * The local pawn that is viewing the menu.
 */
var AP_Specter Pawn;

/**
 * The current overlay of the menu.
 */
var GFx_Menu Overlay;

/**
 * The menu container for the weapon stats.
 */
var GFxObject Cursor;

/**
 * The panel buttons.
 */
var GFx_PanelButton StartBtn, Map, Gametype, Options;

/**
 * The original material of the Dek cube.
 */
var MaterialInterface OrigMat;

/**
 * The current map selected.
 */
var ArenaMapInfo CurrentMap;

/**
 * When closing, this is the destination menu.
 */
var string Destination;

/**
 * Stores the name of the current cube panel that the mouse is hovering over.
 */
var name CurrentPanel;

/**
 * Indicates that the menu is open.
 */
var bool Open;

/**
 * The delegate to call when the menu closes.
 */
delegate OnClose();


function bool Start(optional bool StartPaused = false)
{
	local SkeletalMeshActor iter;
	local MaterialInstanceConstant newMat;
	
	super.Start(StartPaused);
	
	StartBtn = new class'Arena.GFx_PanelButton';
	StartBtn.RenderTexture = TextureRenderTarget2D'ArenaUI.Textures.StartGFxTarget';
	StartBtn.SetTimingMode(TM_Real);
	StartBtn.Init();
	StartBtn.Start();
	
	Map = new class'Arena.GFx_PanelButton';
	Map.RenderTexture = TextureRenderTarget2D'ArenaUI.Textures.MapGFxTarget';
	Map.SetTimingMode(TM_Real);
	Map.Init();
	Map.Start();
	
	Gametype = new class'Arena.GFx_PanelButton';
	Gametype.RenderTexture = TextureRenderTarget2D'ArenaUI.Textures.GametypeGFxTarget';
	Gametype.SetTimingMode(TM_Real);
	Gametype.Init();
	Gametype.Start();
	
	Options = new class'Arena.GFx_PanelButton';
	Options.RenderTexture = TextureRenderTarget2D'ArenaUI.Textures.OptionsGFxTarget';
	Options.SetTimingMode(TM_Real);
	Options.Init();
	Options.Start();
	
	Advance(0);

	Cursor = GetVariableObject("_root.cursor");
	
	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
	}
	
	foreach Pawn.AllActors(class'SkeletalMeshActor', iter)
	{
		if (iter.Tag == 'DekCube')
		{
			Cube = iter.SkeletalMeshComponent;
			break;
		}
	}
	
	newMat = new class'MaterialInstanceConstant';
	newMat.SetParent(Material'ArenaUI.Materials.DekCubeSBBMat');
	
	OrigMat = Cube.GetMaterial(0);
	Cube.SetMaterial(0, newMat);
	
	CurrentMap = new class'Arena.ArenaMapInfo';
	
	CurrentMap.MapName = "AlphaTesting";
	CurrentMap.DisplayName = "Alpha Testing";
	CurrentMap.GameType = "Bot Battle";
		
	return true;
}

function Update(float dt)
{
	local float x, y, a1, a2;
	
	StartBtn.SetLabel("Start");
	Map.SetLabel("Map");
	Options.SetLabel("Options");
	Gametype.SetLabel("Game type");
	
	if (Open)
	{
		x = Cursor.GetFloat("x");
		y = Cursor.GetFloat("y");
		
		a1 = FClamp((x - NativeWidth / 2) / (NativeWidth / 16), -1.0, 1.0);
		a1 *= 1 - FClamp(Abs((y - NativeHeight / 2) / (NativeHeight / 8)), 0.0, 1.0);
		
		a2 = FClamp((y - NativeHeight / 2) / (NativeHeight / 16), -1.0, 1.0);
		a2 *= 1 - FClamp(Abs((x - NativeWidth / 2) / (NativeWidth / 8)), 0.0, 1.0);
		
		Cube.Owner.SetRotation(RLerp(RLerp(rot(0, -16384, 0), rot(0, -16384, 8192), a2), rot(0, -8192, 0), a1));
	}
}

function PostRender()
{
	local vector2D mousePos;
	local vector origin, direction;
	local vector traceLoc, traceNorm;
	local TraceHitInfo info;
	local name highlightedPanel;

	highlightedPanel = '';
	
	mousePos.x = Cursor.GetFloat("x") * GetPC().MyHUD.SizeX / NativeWidth;
	mousePos.y = Cursor.GetFloat("y") * GetPC().MyHUD.SizeY / NativeHeight;
	
	GetPC().MyHUD.Canvas.DeProject(mousePos, origin, direction);
	
	if (GetPC().TraceComponent(traceLoc, traceNorm, Cube, origin + direction * 512, origin , , info, true))
		highlightedPanel = info.BoneName;
	
	if (highlightedPanel != CurrentPanel)
	{
		switch (CurrentPanel)
		{
		case 'Top':
			StartBtn.Leave();
			break;
			
		case 'Bottom':
			Options.Leave();
			break;
			
		case 'Front':
			Map.Leave();
			break;
			
		case 'Back':
			Gametype.Leave();
			break;
		}
		
		CurrentPanel = highlightedPanel;
		
		switch (CurrentPanel)
		{
		case 'Top':
			`log("Highlighting top panel");
			StartBtn.Hover();
			break;
			
		case 'Bottom':
			Options.Hover();
			break;
			
		case 'Front':
			Map.Hover();
			break;
			
		case 'Back':
			Gametype.Hover();
			break;
		}
	}
}

function OnMouseDown()
{
	switch (CurrentPanel)
	{
	case 'Top':
		StartBtn.Press();
		break;
		
	case 'Bottom':
		Options.Press();
		break;
		
	case 'Front':
		Map.Press();
		break;
		
	case 'Back':
		Gametype.Press();
		break;
	}
}

function OnMouseClick()
{
	switch (CurrentPanel)
	{
	case 'Top':
		StartBtn.Release();
		StartGame();
		break;
		
	case 'Bottom':
		Options.Release();
		break;
		
	case 'Front':
		Map.Release();
		OpenMapList();
		break;
		
	case 'Back':
		Gametype.Release();
		break;
	}
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function PlayOpenAnimation()
{
	local AN_BlendByState node;
	
	foreach Cube.AllAnimNodes(class'AN_BlendByState', node)
		node.SetState("SoloBotBattle");
		
	PlayCubeAnimation('ToBotBattleAnimation');
	
	Open = false;
}

function PlayCloseAnimation()
{
	local AN_BlendByState node;
	
	if (Destination == "Main Menu")
	{		
		foreach Cube.AllAnimNodes(class'AN_BlendByState', node)
			node.SetState("MainMenu");
			
		PlayCubeAnimation('FromBotBattleAnimation');
	}
	
	StartBtn.PlayClose();
	Options.PlayClose();
	Map.PlayClose();
	Gametype.PlayClose();
}

function CloseAnimCompleted()
{
	OnClose();
}

function OpenAnimCompleted()
{
	Open = true;
}

simulated function PlayCubeAnimation(name sequence)
{
	local AnimNodePlayCustomAnim node;

	node = AnimNodePlayCustomAnim(AnimTree(Cube.Animations).Children[0].Anim);

	node.PlayCustomAnim(sequence, 1.0, , , false);
}

function ButtonClicked(string label)
{
	if (label == "Back")
		OnBackButtonClicked();
}

function OnBackButtonClicked()
{
	OnClose = GotoMainMenu;
	Destination = "Main Menu";
	
	PlayCloseAnimation();
	Open = false;
	CloseMenu();
}

function GotoMainMenu()
{
	local GFx_MainMenu menu;
	
	menu = new class'Arena.GFx_MainMenu';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);

	Cube.Owner.SetRotation(rot(0, -16384, 0));
	Cube.Owner.SetPhysics(PHYS_Rotating);
	Cube.SetMaterial(0, OrigMat);
	
	menu.Start();
	menu.PlayOpenAnimation();
	
	Pawn.SetMenu(menu);

	StartBtn.Close();
	Map.Close();
	Options.Close();
	Gametype.Close();
	
	Close();
}

function StartGame()
{
	if (CurrentMap != None)
	{
		ConsoleCommand("open" @ CurrentMap.MapName $ "?listen?GoalScore=0?TimeLimit=0?Game=Arena.GI_BotBattle -log");
	}
}

function OpenMapList()
{
	local GFx_SBBMapList menu;
	
	menu = new class'Arena.GFx_SBBMapList';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);
	
	menu.Parent = self;
	
	menu.Start();
	menu.PlayOpenAnimation();
	
	Pawn.SetMenu(menu);

	Overlay = menu;
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.SoloBotBattleMenu'
}