/*******************************************************************************
	BTAction_UseAbility

	Creation date: 23/08/2013 00:23
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This node dictates a bot to use its currently equipped ability.
 */
class BTAction_UseAbility extends BTAction;

state Running
{
	simulated function BeginState(name prev)
	{
		//local float a;
		
		ArenaPawn(Controller.Pawn).StartFireAbility();
		//CanUseAbility = false;
		//CanFire = false;
		
		ArenaPawn(Controller.Pawn).StopFireAbility();
		
		//a = FRand();
		
		//SetTimer(UseAbIntervalMin * (1 - a) + UseAbIntervalMax * a, false, 'ReactivateAbility');
		//SetTimer(FireIntervalMin * (1 - a) + FireIntervalMax * a, false, 'ReactivateFire');
		GotoState('Succeeded');
	}
}