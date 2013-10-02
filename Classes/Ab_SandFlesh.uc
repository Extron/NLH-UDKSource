/******************************************************************************
	Ab_SandFlesh
	
	Creation date: 07/03/2013 19:59
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_SandFlesh extends Ab_StoneFlesh;

/* Electticity reduction. */
var float ElectricityDamageReduction;

simulated function PostBeginPlay()
{
	playerStatMod.SetTypeDamageInputMod(class 'Arena.Dmg_Fire', FireDamageReduction );
	playerStatMod.SetTypeDamageInputMod(class 'Arena.Dmg_Electricity', ElectricityDamageReduction);

	if (ArenaPawn(Instigator) != None)
		ArenaPawn(Instigator).Stats.AddModifier(PlayerStatMod);

}

simulated function CustomFire()
{
	`log("CustomFire called for a passive ability.");
}

simulated function RegainPassive()
{
	if (ArenaPawn(Instigator) != None)
		ArenaPawn(Instigator).Stats.AddModifier(PlayerStatMod);
}

// Problem: This is being called on the ability, not the instigator
simulated event TakeDamage (int Damage, Controller InstigatedBy, Object.Vector HitLocation, Object.Vector Momentum, class<DamageType> DamageType, optional Actor.TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (DamageType == class 'Arena.Dmg_Electricity')
	{
		ArenaPawn(Instigator).Stats.RemoveModifier(PlayerStatMod);
		SetTimer(Duration, false, 'RegainPassive');
	}
		
	
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

defaultproperties
{
	AbilityName="Sand Flesh"

	IsPassive=true
	
	Duration = 10.0 // This variable will now be used to determine how long the passive is removed
					// When the user is hit by water
	
	DamageReduction = 1 // No plain damage reduction for this
	FireDamageReduction = 0.75
	ElectricityDamageReduction = 0.5
}