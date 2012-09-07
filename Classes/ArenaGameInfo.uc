/*******************************************************************************
	ArenaGameInfo

	Creation date: 30/06/2012 16:51
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaGameInfo extends UDKGame;

defaultproperties
{
	PlayerControllerClass=class'Arena.ArenaPlayerController'
	DefaultPawnClass=class'Arena.ArenaPawn'
	HUDType=class'Arena.ArenaHUD'
	GameReplicationInfoClass=class'Arena.ArenaGRI'
}