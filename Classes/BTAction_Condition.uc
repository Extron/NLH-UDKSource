/*******************************************************************************
	BTAction_Condition

	Creation date: 28/08/2013 08:41
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A simple condition, this node succeeds if the its Condition variable is set to true, and failed when it is not.
 */
class BTAction_Condition extends BTAction;

/**
 * The condition value.
 */
var bool Condition;


state Running
{
	simulated function BeginState(name prev)
	{
		OnRunning(self);
		
		if (Condition)
			GotoState('Succeeded');
		else
			GotoState('Failed');
	}
}
