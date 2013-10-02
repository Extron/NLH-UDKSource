/******************************************************************************
	Ab_StoneFlesh
	
	Creation date: 07/03/2013 19:59
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_StoneFlesh extends ArenaAbility;

/* How long it lasts */
var float Duration;

/* The 50% fire damage reduction. */
var float FireDamageReduction;

/* The 25% damage reduction. */
var float DamageReduction;

/* The stat modifier */
var PlayerStatModifier playerStatMod;

simulated function CustomFire()
{
	playerStatMod.SetTypeDamageInputMod(class 'Arena.Dmg_Fire', DamageReduction);
	// TODO: Does not extend to extended classes?
	playerStatMod.SetTypeDamageInputMod(class 'DamageType', FireDamageReduction);

	if (ArenaPawn(Instigator) != None)
		ArenaPawn(Instigator).Stats.AddModifier(PlayerStatMod);
	
	SetTimer(Duration, false, 'DestroyRockSkin');
}

simulated function DestroyRockSkin()
{
	if (ArenaPawn(Instigator) != None)
		ArenaPawn(Instigator).Stats.RemoveModifier(PlayerStatMod);
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	Begin Object Class=PlayerStatModifier Name=NewMod
	End Object
	playerStatMod=NewMod
	
	CoolDown =  90
	EnergyCost = 600
	AbilityName = "Stone Flesh"
	
	CanHold = false
	IsPassive = false
	CanCharge = false
	
	DamageReduction = 0.75
	// I belive they are multiplied not added; .5 = .75 * .6666666666, needs to be tested
	FireDamageReduction = 0.6666666666
	Duration = 45
}