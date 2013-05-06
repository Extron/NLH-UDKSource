/*******************************************************************************
	Ab_RangedEMP

	Creation date: 21/04/2013 20:38
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_RangedEMP extends ArenaAbility;

/**
 * The range at which the EMP projectile will detonate.
 */
var float Range;

defaultproperties
{
	WeaponFireTypes[0]=EWFT_Projectile
	InstantHitDamageTypes[0]=None
	WeaponProjectiles[0]=class'Arena.Proj_EMP'
	
	AbilityName="Ranged EMP"
	CoolDown=5
	EnergyCost=350
	Range=1500
	
	CanHold=false
	IsPassive=false
	CanCharge=false
}