/******************************************************************************
	Ab_HeavyHanded
	
	Creation date: 20/04/2013 21:49
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_HeavyHanded extends ArenaAbility;

/**
 * The modifier to use to alter player stats.
 */
var PlayerStatModifier Mod;

/* Melee damage increase */
var float MeleeDamageIncrease;

simulated function PostBeginPlay()
{
	if (ArenaPawn(Instigator) != None)
	{
		Mod.ValueMods[PSVMeleeDamage] = MeleeDamageIncrease;
		
		//Probably don't want to edit the player stats directly, it makes it hard to reset them in game if we need to.  Use PlayerStatModifiers
		ArenaPawn(Instigator).Stats.AddModifier(Mod);
	}
}

defaultproperties
{
	AbilityName="Heavy Handed"

	MeleeDamageIncrease = 1.1
	
	Begin Object Class=PlayerStatModifier Name=PSM
	End Object
	
	IsPassive=true
}