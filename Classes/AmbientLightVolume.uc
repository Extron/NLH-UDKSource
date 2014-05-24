/*******************************************************************************
	AmbientLightVolume

	Creation date: 29/04/2014 09:08
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * Allows ambient light to be confined to a volume.  Due to limitations with Unreal, the way this works is it turns on a skylight when a pawn is
 * inside the volume, and turns it off when the pawn leaves.
 */
class AmbientLightVolume extends PhysicsVolume implements(IToggleableObject);

/**
 * Since PawnEnteredVolume can be called before a pawn's controller is set, we will retest these pawns again.
 */
var array<Pawn> PendingPawns;

/**
 * The ambient light for this volume.
 */
var(Light) SkylightComponent AmbientLight;

/**
 * The number of players that are inside the volume.
 */
var int PlayerCount;

/**
 * Indicates whether the ambient light is on.
 */
var(Light) bool On;


simulated function Toggle()
{
	On = !On;

	AmbientLight.SetEnabled(On);
}

event PawnEnteredVolume(Pawn Other)
{
	`log(self @ Other @ Other.Owner);
	
	if (Other.Controller == None)
	{
		PendingPawns.AddItem(Other);
		return;
	}
	
	if (Other.Controller.IsLocalPlayerController())
		PlayerCount = PlayerCount + 1;

	if (PlayerCount > 0)
		AmbientLight.SetEnabled(On);
}

event PawnLeavingVolume(Pawn Other)
{
	if (Other.Controller.IsLocalPlayerController())
		PlayerCount = PlayerCount - 1;
		
	if (PlayerCount < 0)
		PlayerCount = 0;
		
	if (PlayerCount == 0)
		AmbientLight.SetEnabled(false);
}

defaultproperties
{
	Begin Object Class=SkyLightComponent Name=SkyLightComponent
		UseDirectLightMap=TRUE
		bCanAffectDynamicPrimitivesOutsideDynamicChannel=TRUE
	End Object
	AmbientLight=SkylightComponent
	Components.Add(SkyLightComponent)
	
	On=true
}