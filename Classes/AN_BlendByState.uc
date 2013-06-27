/*******************************************************************************
	AN_BlendByState

	Creation date: 24/06/2013 17:31
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AN_BlendByState extends UDKAnimBlendBase;

var(States) array<string> States;

simulated function SetState(string newState)
{
	local int index;
	
	index = States.Find(newState);
	
	if (index > -1 && index < Children.Length)
		SetActiveChild(index, BlendTime);
}

defaultproperties
{
	bFixNumChildren=false
}