/*******************************************************************************
	Ab_Wash

	Creation date: 25/08/2014 18:00
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class Ab_Wash extends ArenaAbility;

defaultproperties
{
	WeaponFireTypes[0]=EWFT_Projectile
	InstantHitDamageTypes[0]=None
	WeaponProjectiles[0]=class'Arena.Proj_WaterDroplet'
	
	AbilityName="Wash"
	CoolDown=5
	EnergyCost=350
	
	CanHold=false
	IsPassive=false
	CanCharge=false
}