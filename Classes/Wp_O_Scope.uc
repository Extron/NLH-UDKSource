/*******************************************************************************
	Wp_O_Scope

	Creation date: 12/06/2013 03:15
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_O_Scope extends Wp_Optics;

var SceneCapture2DComponent SceneCapturer;

var float ScopeZoom;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	AttachSceneCapturer();
}

simulated function AttachSceneCapturer()
{
	SkeletalMeshComponent(Mesh).AttachComponentToSocket(SceneCapturer,'ScopeSocket');

	SceneCapturer.SetCaptureParameters(TextureRenderTarget2D'ArenaMaterials.Textures.ScopeRenderTarget', 30 / ScopeZoom, 10, 156000);
	SceneCapturer.bEnablePostProcess = true;
	SceneCapturer.bEnableFog = true;
	SceneCapturer.ViewMode = SceneCapView_Lit;
}

/**
 * Allows weapon optics to modify things like depth of field when the player aims down sights.
 */
simulated function BlurADS(UberPostProcessEffect effect)
{
	effect.FocusDistance = 192;
	effect.FocusInnerRadius = 128;
	effect.MaxFarBlurAmount = 1;
}


defaultproperties
{
	Begin Object Class=SceneCapture2DComponent Name=SC
	End Object
	SceneCapturer=SC
	
	Components.Add(SC)
	
	OnlyZoomWeapon=true
}