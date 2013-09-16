/*******************************************************************************
	SeqCond_IsRaining

	Creation date: 15/09/2013 19:02
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SeqCond_IsRaining extends SequenceCondition;

event Activated()
{
	local WorldInfo WorldInfo;
	
	WorldInfo = GetWorldInfo();

	if (ArenaGRI(WorldInfo.GRI) != None)
	{
		if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Raining)
			OutputLinks[0].bHasImpulse = true;
		else
			OutputLinks[1].bHasImpulse = true;
	}
}

defaultproperties
{
	ObjName="Is Raining"
	ObjCategory="Weather"

	OutputLinks(0)=(LinkDesc="True")
	OutputLinks(1)=(LinkDesc="False")
}