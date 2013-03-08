/******************************************************************************
	Ab_StoneFlesh
	
	Creation date: 07/03/2013 19:59
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_StoneFlesh extends ArenaAbility;

/* How long it last */
var float StoneFleshDuration;

/* The 50% fire damage reduction. */
var float FireDamageReduction;

/* The 25% damage reduction. */
var float DamageReduction;

/* The stat modifier */
var PlayerStatModifier playerStatMod;

simulated function CustomFire()
{
	if (ArenaPawn(Instigator) != None)
	{
		playerStatMod.SetTypeDamageInputMod(class 'Arena.Dmg_Fire', DamageReduction);
		// TODO: Does not extend to extended classes?
		playerStatMod.SetTypeDamageInputMod(class 'DamageType', DamageReduction);
		// Test...
		// playerStatMod.SetTypeDamageInputMod(class 'Arena.Dmg_LightBeam', DamageReduction);
		
		ArenaPawn(Instigator).Stats.AddModifier(PlayerStatMod);
	}
	
	SetTimer(StoneFleshDuration, false, 'DestroyRockSkin');
}

// TODO: Call DestoryRockSkin when used get hit by water (easy)

simulated function DestroyRockSkin()
{
	if (ArenaPawn(Instigator) != None)
	{
		ArenaPawn(Instigator).Stats.RemoveModifier(PlayerStatMod);
	}
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	CoolDown =  90
	EnergyCost = 600
	AbilityName = "Stone Flesh"
	
	CanHold = false
	IsPassive = false
	CanCharge = false
	
	Begin Object Class=PlayerStatModifier Name=NewMod
	End Object
	playerStatMod=NewMod
	
	DamageReduction = 0.75
	// I belive they are multiplied not added; .5 = .75 * .6666666666, needs to be tested
	FireDamageReduction = 0.6666666666
	StoneFleshDuration = 45
}