/*******************************************************************************
	Bullet

	Creation date: 10/07/2012 20:37
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class RifleBullet extends ArenaProjectile;

defaultproperties
{
	ProjTemplate=ParticleSystem'ArenaParticles.Particles.RifleBulletTest'
	SparksTemplate=ParticleSystem'ArenaParticles.Particles.BulletImpactSparks'
	
	MyDamageType=class'Arena.Dmg_RifleBullet'
	
	Speed=17500
	MaxSpeed=20000
	AccelRate=10000
	
	Damage=100
	DamageRadius=0
	MomentumTransfer=0
}