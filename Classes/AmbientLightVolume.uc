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
var array<ArenaPawn> PendingPawns;

/**
 * The pawns that have just entered the volume whose ambient parameters are still changing.
 */
var array<ArenaPawn> EnteringPawns;

/**
 * The pawns that have just left the volume whose ambient parameters are still changing.
 */
var array<ArenaPawn> LeavingPawns;

/**
 * All of the pawns that are inside the volume.
 */
var array<ArenaPawn> ContainedPawns;

/**
 * The color of the ambient light within the volume when turned on.
 */
var(Light) color OnAmbienceColor;

/**
 * The brightness of the ambient light within the volume when turned on.
 */
var(Light) float OnAmbienceBrightness;

/**
 * The color of the ambient light within the volume when turned off.
 */
var(Light) color OffAmbienceColor;

/**
 * The brightness of the ambient light within the volume when turned off.
 */
var(Light) float OffAmbienceBrightness;

/**
 * The amount of mixing between the global outdoor ambience and this volume's ambience that is needed to form the final ambient light.
 * A 1 means the volume's light dominates, A 0 means the global ambience dominates.  This helps simulate more dynamic lighting, and
 * can be used to change indoor ambience when windows are open versus closed.
 */
var(Light) float AmbienceParameter;

/**
 * When pawns enter or leave the volume, this indicates how fast the new ambient light they see reaches its final mixed value of global light
 * and volume light.
 */
var(Light) float TransitionTime;

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
	local ArenaPawn iter;
	On = !On;
	
	foreach ContainedPawns(iter)
		UpdateAmbienceParameters(iter);
}

simulated function Tick(float dt)
{
	local int i;
	
	super.Tick(dt);
	
	for (i = 0; i < EnteringPawns.Length; i++)
	{
		if (EnteringPawns[i].Ambience.Parameter < AmbienceParameter)
		{
			EnteringPawns[i].Ambience.SetParameter(EnteringPawns[i].Ambience.Parameter + dt * AmbienceParameter / TransitionTime);
		}
		else
		{
			EnteringPawns[i].Ambience.SetParameter(AmbienceParameter);
			EnteringPawns.Remove(i, 1);
			i--;
		}
	}
	
	for (i = 0; i < LeavingPawns.Length; i++)
	{
		if (LeavingPawns[i].Ambience.Parameter > 0)
		{
			LeavingPawns[i].Ambience.SetParameter(LeavingPawns[i].Ambience.Parameter - dt * AmbienceParameter / TransitionTime);
		}
		else
		{
			LeavingPawns[i].Ambience.SetParameter(0);
			LeavingPawns.Remove(i, 1);
			i--;
		}
	}
}

event PawnEnteredVolume(Pawn Other)
{
	if (ArenaPawn(Other) != None)
	{
		EnteringPawns.AddItem(ArenaPawn(Other));
		UpdateAmbienceParameters(ArenaPawn(Other));
		ContainedPawns.AddItem(ArenaPawn(Other));
	}
}

event PawnLeavingVolume(Pawn Other)
{
	if (ArenaPawn(Other) != None)
	{
		LeavingPawns.AddItem(ArenaPawn(Other));
		ContainedPawns.RemoveItem(ArenaPawn(Other));
	}
}

function UpdateAmbienceParameters(ArenaPawn newPawn)
{
	if (On)
		newPawn.Ambience.SetOverlayProperties(OnAmbienceColor, OnAmbienceBrightness);
	else
		newPawn.Ambience.SetOverlayProperties(OffAmbienceColor, OffAmbienceBrightness);
}

defaultproperties
{
	On=true
	bStatic=false
	AmbienceParameter=1
	TransitionTime=0.15
}