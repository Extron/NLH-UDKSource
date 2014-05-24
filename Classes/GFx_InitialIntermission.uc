/*******************************************************************************
	GFx_InitialIntermission

	Creation date: 18/10/2013 11:01
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_InitialIntermission extends GFx_Menu;

/**
 * The pawn that is currently viewing the menu.
 */
var AP_Specter Pawn;

/**
 * The backtrop for the intermission menu.
 */
var IntermissionBackdrop Backdrop;
 
/**
 * The figure used to draw the players' loadouts to the screen.
 */
var PlayerFigure LoadoutFigure;

/**
 * The position offset of the figure from the pawn's position.
 */
var vector FigureDisplacement;

/**
 * The relative rotation of the figure.
 */
var rotator FigureRotation;

/**
 * The length of time the menu is being displayed.
 */
var float Duration;

/**
 * The index of the currently selected index.
 */
var int SelectedLoadoutIndex;

function bool Start(optional bool StartPaused = false)
{
	local vector playerViewLoc;
	local rotator playerViewRot;
	
	super.Start(StartPaused);
	
	Advance(0);
	
	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
	}
	
	BuildCharacterList();
	
	Pawn.Controller.GetPlayerViewPoint(playerViewLoc, playerViewRot);
	
	LoadoutFigure = Pawn.Spawn(class'Arena.PlayerFigure', , , Pawn.Location + (FigureDisplacement >> Pawn.Controller.Rotation), RTransform(FigureRotation, playerViewRot), , true);
	LoadoutFigure.LoadFigure(ArenaPlayerController(Pawn.Controller).SaveData.Loadouts[SelectedLoadoutIndex], ArenaPlayerController(Pawn.Controller));
	
	Backdrop = Pawn.Spawn(class'Arena.IntermissionBackdrop', , , Pawn.Location + (FigureDisplacement + vect(32, 0, 16) >> Pawn.Controller.Rotation), playerViewRot, , true);
	
	return true;
}

function OnClose()
{
	LoadoutFigure.Destroy();
	Backdrop.Destroy();
}

event bool WidgetInitialized(name widgetName, name widgetPath, GFxObject widget)
{
	local GFxClikWidget list;
	
	switch (widgetName)
	{
	case 'scrollingList':
		list = GFxClikWidget(GetVariableObject(string(widgetPath), class'GFxClikWidget'));
		if (list == None)
		{
			`log("Failed to initialize clik widget" @ widgetName);
			return false;
		}
		
		list.AddEventListener('CLIK_itemClick', OnItemClicked);
		return true;
	}
}

function Update(float dt)
{
	Duration -= dt;
	
	SetTime(Duration);
}

function BuildCharacterList()
{
	SetCharacters(ArenaPlayerController(Pawn.Controller).GetCharacters());
}

function SetCharacters(array<string> characters)
{
	ActionScriptVoid("_root.SetCharacters");
}

function string GetSelectedCharacter()
{
	return ActionScriptString("_root.GetSelectedCharacter");
}

function OnItemClicked(GFxClikWidget.EventData ev)
{
	SelectedLoadoutIndex = ev._this.GetInt("index");
	LoadoutFigure.LoadFigure(ArenaPlayerController(Pawn.Controller).SaveData.Loadouts[SelectedLoadoutIndex], ArenaPlayerController(Pawn.Controller));
}

function SetTime(float time)
{
	ActionScriptVoid("_root.SetTime");
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.InitialIntermission'
	
	FigureDisplacement=(X=128,Y=24, Z=-32)
	FigureRotation=(Yaw=40960)
	bCaptureInput=true
}