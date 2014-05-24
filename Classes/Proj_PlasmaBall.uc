/*******************************************************************************
	Proj_PlasmaBall

	Creation date: 04/04/2014 11:09
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Proj_PlasmaBall extends ArenaProjectile;

defaultproperties
{
	ProjTemplate=ParticleSystem'PlasmaTorch.Particles.ProjectilePS'
	SparksTemplate=ParticleSystem'PlasmaTorch.Particles.PlasmaSplattersPS'
	
	MyDamageType=class'Arena.Dmg_RifleBullet'
	
	Begin Object Class=PointLightComponent Name=ProjectileLight
		Brightness=32
		Radius=256
		LightColor=(R=255,G=128,B=64,A=255)
	End Object
	Components.Add(ProjectileLight)
	
	ProjectileDecal=MaterialInstanceTimeVarying'PlasmaTorch.Materials.PlasmaDecalMat'
	ImpactSound=SoundCue'PlasmaTorch.Audio.ImpactSC'
	
	Speed=1750
	MaxSpeed=2000
	AccelRate=10000
	DecalWidth=50
	DecalHeight=50
	
	Damage=400
	DamageRadius=5
	MomentumTransfer=0
	
	ProjectileTag="PlasmaBall"
}