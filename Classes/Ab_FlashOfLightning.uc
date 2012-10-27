/*******************************************************************************
	Ab_FlashOfLightning

	Creation date: 24/09/2012 13:38
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_FlashOfLightning extends Ab_ShotsOfHaste;

simulated function ProcessHitPawn(ArenaPawn pawn)
{
	super.ProcessHitPawn(pawn);
	
	if (pawn == Target)
	{
		//TODO: Flash the target
	}
}


defaultproperties
{
	AbilityName="Flash of Lightning"
}