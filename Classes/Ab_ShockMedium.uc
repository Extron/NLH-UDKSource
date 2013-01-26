/*******************************************************************************
	Ab_ShockMedium

	Creation date: 25/08/2012 02:31
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_ShockMedium extends Ab_Shock;

defaultproperties
{
	InstantHitDamage(0)=300
	WeaponRange=2000
	CoolDown=10
	EnergyCost=300
	SourceOffset=(X=5,Y=5,Z=0)
	AbilityName="Medium-Range Shock"
}