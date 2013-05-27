/*******************************************************************************
	Ab_Sand

	Creation date: 14/05/2013 07:15
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_Sand extends ArenaAbility;

defaultproperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	InstantHitDamageTypes(0)=class'Arena.ADT_Sand'
	InstantHitMomentum(0)=+0.0
	
	IHBeamTemplate=ParticleSystem'ArenaAbilities.Particles.SandStreamPS'
	
	InstantHitDamage(0)=0
	WeaponRange=128
	CoolDown=10
	EnergyCost=200
	AbilityName="Sand"
	
	CanHold=false
	IsPassive=false
	CanCharge=false
}