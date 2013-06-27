/******************************************************************************
	Ab_WallLaunch
	
	Creation date: 09/01/2013 16:39
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_WallLaunch extends Ab_PortableShield;

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	CoolDown=10
	EnergyCost=78
	AbilityName="Launchable Wall"
	
	WallClass=class'Arena.Ab_WallLaunchBoulder'
}