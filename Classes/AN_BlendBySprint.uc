/*******************************************************************************
	AN_BlendBySprint

	Creation date: 09/05/2013 01:35
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AN_BlendBySprint extends UDKAnimBlendBase;

simulated function SetSprint(bool sprint) 
{
	if (sprint)
		SetActiveChild(1, BlendTime);
	else 
		SetActiveChild(0, BlendTime);
}

defaultproperties
{
	Children(0)=(Name="Walk")
	Children(1)=(Name="Sprint")
	bFixNumChildren=True
}