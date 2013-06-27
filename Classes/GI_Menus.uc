/*******************************************************************************
	GI_Menus

	Creation date: 02/04/2013 10:57
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A utility game info class for use with the menu system.
 */
class GI_Menus extends ArenaGameInfo;

defaultproperties
{
	PlayerControllerClass=class'Arena.ArenaPlayerController'
	DefaultPawnClass=class'Arena.AP_Specter'
	HUDType=class'Arena.MenuHUD'
	GameReplicationInfoClass=class'Arena.ArenaGRI'
	PlayerReplicationInfoClass=class'Arena.ArenaPRI'
	//bDelayedStart=true
	
	RespawnTime=3
	AllowFastRespawn=false
	CanRespawn=true
	ForceRespawn=true
}