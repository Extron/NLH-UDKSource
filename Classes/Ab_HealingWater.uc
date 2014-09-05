/*******************************************************************************
	Ab_HealingWater

	Creation date: 29/08/2014 09:16
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * A short range ability that can target allies or the player, healing them with a specified amount of health.
 */
class Ab_HealingWater extends ArenaAbility;

/**
 * The range of the ability.
 */
var float Range;

/**
 * The percent of the target's current health to heal them by.
 */
var float HealingPercent;

simulated function ProcessInstantHit(byte mode, ImpactInfo impact, optional int numHits)
{
	local ArenaPawn pawn;
	
	super.ProcessInstantHit(mode, impact, numHits);
	
	if (ArenaPawn(impact.HitActor) != None)
	{
		pawn = ArenaPawn(impact.HitActor);
		
		if (pawn.PlayerReplicationInfo != None && pawn.PlayerReplicationInfo.Team != None)
		{
			if (pawn.PlayerReplicationInfo.Team.TeamIndex != ArenaPawn(Instigator).PlayerReplicationInfo.Team.TeamIndex)
				Instigator.TakeDamage(0, Instigator.Controller, vect(0, 0, 0), vect(0, 0, 0), InstantHitDamageTypes[0]);
		}
		else
		{
			Instigator.TakeDamage(0, Instigator.Controller, vect(0, 0, 0), vect(0, 0, 0), InstantHitDamageTypes[0]);
		}
	}
	else
	{
		Instigator.TakeDamage(0, Instigator.Controller, vect(0, 0, 0), vect(0, 0, 0), InstantHitDamageTypes[0]);
	}
}

defaultproperties
{
	WeaponFireTypes[0]=EWFT_InstantHit
	InstantHitDamageTypes[0]=class'Arena.Dmg_Healing'
	InstantHitMomentum[0]=+0.0
	
	//FireStartAnim=ShockStart
	//FireEndAnim=ShockEnd
	
	//FireSound=SoundCue'ArenaAbilities.Audio.ShockSC'
	
	//IHBeamTemplate=ParticleSystem'ArenaParticles.Particles.ShockBeam'
	//DLClass=class'Arena.L_ShockLight'
	//SLClass=class'Arena.L_ShockLight'
	
	CanHold=false
	IsPassive=false
	CanCharge=false
	
	BaseDamage=0
	WeaponRange=512
	CoolDown=5
	EnergyCost=300
	AbilityName="Healing Water"
	//AbilityIcon="ArenaAbilities.Icons.ShockShort"
	AbilityDescription=""
	UnlockPoints=5
}