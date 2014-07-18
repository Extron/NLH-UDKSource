/*******************************************************************************
	Door

	Creation date: 15/03/2014 01:51
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Door extends SkeletalMeshActorMAT
	abstract;

/**
 * The sound to play when the door opens.
 */
var(Door) SoundCue OpenSound;

/**
 * The sound to play when the door closes.
 */
var(Door) SoundCue CloseSound;

/**
 * The toggle animation node used to control the door animations.
 */
var AN_Toggle ToggleAnimNode;

/**
 * Indicates that the door is open.
 */
var bool Open;


simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);

	ToggleAnimNode = AN_Toggle(SkelComp.FindAnimNode('Toggle'));
	
	//`log(self @ "Toggle node" @ ToggleAnimNode);
}

simulated function OpenDoor()
{
	if (!Open)
	{
		//`log(self @ "toggle node" @ ToggleAnimNode);
		if (ToggleAnimNode != None)
		{
			ToggleAnimNode.Toggle();
			//`log(self @ "toggling animation");
		}
		
		Open = true;
		
		if (OpenSound != None)
			PlaySound(OpenSound);
	}
}

simulated function CloseDoor()
{
	if (Open)
	{
		if (ToggleAnimNode != None)
			ToggleAnimNode.Toggle();
			
		Open = false;
		
		if (CloseSound != None)
			PlaySound(CloseSound);
	}
}

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
	
	CollisionComponent=SkeletalMeshComponent0
	bCollideActors=true
	bBlockActors=true
	CollisionType=COLLIDE_BlockAll
}