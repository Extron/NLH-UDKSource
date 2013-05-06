/*******************************************************************************
	Ab_Shock

	Creation date: 25/08/2012 02:17
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_Shock extends ArenaAbility
	abstract;

defaultproperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	InstantHitDamageTypes(0)=class'Arena.Dmg_Shock'
	InstantHitMomentum(0)=+0.0
	
	IHBeamTemplate=ParticleSystem'ArenaParticles.Particles.ShockBeam'
	
	CanHold=false
	IsPassive=false
	CanCharge=false
}