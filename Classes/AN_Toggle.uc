/*******************************************************************************
	AN_Toggle

	Creation date: 15/03/2014 15:36
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This animation node takes an animation as a child and uses it to toggle between two states, on and off, which the
 * child animation tranisitions between the two.
 */
class AN_Toggle extends AnimNodeBlendBase;

/**
 * Indicates the current state of the node, and can either be 0 or 1.
 */
var int CurrentState;

simulated function Toggle()
{
	local float startTime;

	CurrentState = 1 - CurrentState;
	
	if (AnimNodeSequence(Children[0].Anim) != None)
	{
		if (CurrentState < 1)
			startTime = AnimNodeSequence(Children[0].Anim).GetAnimPlaybackLength() - AnimNodeSequence(Children[0].Anim).CurrentTime;
		else
			startTime = AnimNodeSequence(Children[0].Anim).CurrentTime;
			
		PlayAnim(false, 2 * CurrentState - 1, startTime);
	}
}

defaultproperties
{
	Children[0]=(Name="Transition",Weight=1.0)
	bFixNumChildren=true
}