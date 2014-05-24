/*******************************************************************************
	Door

	Creation date: 15/03/2014 01:51
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Door extends SkeletalMeshActor
	abstract;

/**
 * The sound to play when the door opens.
 */
var(Door) SoundCue OpenSound;

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
}

simulated function OpenDoor()
{
	if (!Open)
	{
		if (ToggleAnimNode != None)
			ToggleAnimNode.Toggle();
		
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
	}
}