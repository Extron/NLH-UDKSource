/*******************************************************************************
	Proj_ShotgunPellet

	Creation date: 10/06/2013 10:16
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Proj_ShotgunPellet extends ArenaProjectile;

defaultproperties
{
	ProjTemplate=ParticleSystem'ArenaParticles.Particles.ShotgunPelletPS'
	//SparksTemplate=ParticleSystem'ArenaParticles.Particles.BulletImpactSparks'
	
	MyDamageType=class'Arena.Dmg_ShotgunPellet'
	
	LifeSpan=0.1
	Speed=17500
	MaxSpeed=20000
	AccelRate=10000
	DecalWidth=25
	DecalHeight=25
	
	Damage=30
	DamageRadius=0
	MomentumTransfer=0
}