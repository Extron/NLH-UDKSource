/*******************************************************************************
	BTAction_Turn

	Creation date: 24/08/2013 03:09
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * Turns the bot to face the current focus.
 */
class BTAction_Turn extends BTAction;

simulated function Reset()
{
	if (Controller.IsInState('FinishRotationState') || Controller.IsInState('Idle'))
	{
		Controller.StopLatentExecution();
		Controller.GotoState('Idle');
	}
	
	super.Reset();
}

state Running
{
Begin:
	//We don't want to short circuit any states that may be running latent code, so if we are not in the default state, don't attempt to 
	//change the state.
	if (Controller.IsInState('Idle'))
	{
		Controller.GotoState('FinishRotationState');
		
		while (!Controller.IsInState('Idle'))
			Sleep(0.0);
			
		GotoState('Succeeded');
	}
	else
	{
		GotoState('Failed');
	}
}

state Succeeded
{
Begin:
	if (Controller.IsInState('FinishRotationState') || Controller.IsInState('Idle'))
	{
		Controller.StopLatentExecution();
		Controller.GotoState('Idle');
	}
}

state Failed
{
Begin:
	if (Controller.IsInState('FinishRotationState') || Controller.IsInState('Idle'))
	{
		Controller.StopLatentExecution();
		Controller.GotoState('Idle');
	}
}