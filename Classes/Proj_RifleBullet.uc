/*******************************************************************************
	Bullet

	Creation date: 10/07/2012 20:37
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Proj_RifleBullet extends ArenaProjectile;

simulated function Emit()
{
	local vector l;
	local rotator r;
	
	super.Emit();
	
	if (WorldInfo.NetMode != NM_DedicatedServer && ProjTemplate != None && ArenaWeaponBase(Weapon) != None)
	{
		if (SkeletalMeshComponent(ArenaWeaponBase(Weapon).WeaponComponents[WCBarrel].Mesh).GetSocketByName(ArenaWeaponBase(Weapon).Sockets[WCBarrel]) != None)
			SkeletalMeshComponent(ArenaWeaponBase(Weapon).WeaponComponents[WCBarrel].Mesh).GetSocketWorldLocationAndRotation(ArenaWeaponBase(Weapon).Sockets[WCBarrel], l, r, 0);
	}
	
	//Projectile.SetVectorParameter('TracerOrigin', l);
}

defaultproperties
{
	ProjTemplate=ParticleSystem'ArenaParticles.Particles.RifleBulletTest'
	//SparksTemplate=ParticleSystem'ArenaParticles.Particles.BulletImpactSparks'
	
	MyDamageType=class'Arena.Dmg_RifleBullet'
	
	Speed=17500
	MaxSpeed=20000
	AccelRate=10000
	DecalWidth=25
	DecalHeight=25
	
	Damage=100
	DamageRadius=0
	MomentumTransfer=0
}