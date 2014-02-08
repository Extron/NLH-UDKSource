/*******************************************************************************
	GFx_InitialIntermission

	Creation date: 18/10/2013 11:01
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_InitialIntermission extends GFx_Menu;

var AP_Specter Pawn;

var float Duration;

function bool Start(optional bool StartPaused = false)
{
	super.Start(StartPaused);
	Advance(0);
	
	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
	}
	
	BuildCharacterList();
	
	return true;
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

function SetTime(float time)
{
	ActionScriptVoid("_root.SetTime");
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.InitialIntermission'
	
	bCaptureInput=true
}