/*******************************************************************************
	GRI_BotBattle

	Creation date: 12/05/2013 23:34
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GRI_BotBattle extends ArenaGRI;

var int CurrentWave;

replication
{
	if (bNetDirty)
		CurrentWave;
}