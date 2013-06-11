/******************************************************************************
	Ab_PortableShield
	
	Creation date: 19/05/2013 20:36
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_PortableShield extends Ab_RockWall;

/**
 * The class to use for the boulder.  This can be overridden in subclasses to change what kind of wall is generated.
 */
var class<Ab_PortableShieldBoulder> WallClass;

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	CoolDown=10
	EnergyCost=78
	AbilityName="Portable Shield"
	
	WallClass=class'Arena.Ab_PortableShieldBoulder'
}