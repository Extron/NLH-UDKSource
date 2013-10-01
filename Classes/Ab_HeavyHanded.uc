/******************************************************************************
	Ab_HeavyHanded
	
	Creation date: 20/04/2013 21:49
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_HeavyHanded extends ArenaAbility;

/* Melee damage increase % */
var float MeleeDamageIncrease;

simulated function PostBeginPlay()
{
	if (ArenaPawn(Instigator) != None)
	{
		ArenaPawn(Instigator).Stats.SetMeleeDamage(MeleeDamageIncrease);
	}
}

defaultproperties
{
	AbilityName="Heavy Handed"

	MeleeDamageIncrease = 1.1
	
	IsPassive=true
}