/*******************************************************************************
	TestGRI

	Creation date: 15/08/2012 20:03
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaGRI extends GameReplicationInfo;

var GlobalGameConstants Constants;

replication
{
	if (bNetInitial)
		Constants;
}

defaultproperties
{
	Begin Object Class=GlobalGameConstants Name=NewConstants
	End Object
	Constants=NewConstants
}