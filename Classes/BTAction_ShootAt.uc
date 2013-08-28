/*******************************************************************************
	BTAction_ShootAt

	Creation date: 23/08/2013 00:18
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This node dictates a bot to shoot its currently equipped weapon.
 */
class BTAction_ShootAt extends BTAction;

state Running
{
	simulated function BeginState(name prev)
	{
		Controller.Pawn.StartFire(0);
		Controller.Pawn.StopFire(0);
		GotoState('Succeeded');
	}
}