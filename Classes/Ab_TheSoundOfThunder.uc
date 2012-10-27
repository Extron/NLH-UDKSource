/*******************************************************************************
	Ab_TheSoundOfThunder

	Creation date: 24/09/2012 10:05
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_TheSoundOfThunder extends Ab_ThunderRush;

var float StunRange;

simulated function ProcessHitPawn(ArenaPawn pawn)
{
	super.ProcessHitPawn(pawn);
	
	if (pawn == Target)
	{
		foreach VisibleCollidingActors(class'ArenaPawn', target, StunRange, Location)
		{
			//TODO: Stun actors here.
		}
	}
}


defaultproperties
{
	AbilityName="The Sound of Thunder"
}

