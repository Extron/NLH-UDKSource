/*******************************************************************************
	BotKillDisplay

	Creation date: 22/06/2013 22:20
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A bot kill display is a billboard type actor that text is drawn to to describe a kill when a bot is killed.
 */
class BotKillDisplay extends DynamicSMActor;


/**
 * The render target to use to display the kill display.
 */
var TextureRenderTarget2D RenderTarget;

/**
 * The Scaleform display to use to display kill info.
 */
var GFx_BotKillDisplay KillDisplay;

/**
 * The class of the kill display to use.
 */
var class<GFx_BotKillDisplay> KillDisplayClass;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	KillDisplay = new KillDisplayClass;
	
	if (KillDisplay != None && RenderTarget != None)
	{
		KillDisplay.Parent = self;
		KillDisplay.RenderTexture = RenderTarget;
		KillDisplay.SetTimingMode(TM_Real);
		KillDisplay.Init();
	}
}

simulated function Tick(float dt)
{
	local ArenaPlayerController iter;
	
	super.Tick(dt);
	
	foreach LocalPlayerControllers(class'Arena.ArenaPlayerController', iter)
		break;
		
	if (iter != None)
		StaticMeshComponent.SetRotation(iter.Rotation);
}

simulated function RemoveDisplay()
{
	Destroy();
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'ArenaObjects.Meshes.KillDisplayMesh'
		Scale=1.5
		Scale3D=(X=0.75)
	End Object
	
	RenderTarget=TextureRenderTarget2D'ArenaObjects.Textures.KillDisplayGFxTarget'
	KillDisplayClass=class'GFx_BotKillDisplay'
}