/*******************************************************************************
	Proj_WaterDroplet

	Creation date: 25/08/2014 18:05
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class Proj_WaterDroplet extends ArenaProjectile;

simulated function Tick(float dt)
{
	super.Tick(dt);
	
	Acceleration.Z = WorldInfo.GetGravityZ() * CustomGravityScaling;
}

defaultproperties
{
	ProjTemplate=ParticleSystem'Lamentia.Particles.WaterDropletPS'
	//SparksTemplate=ParticleSystem'PlasmaTorch.Particles.PlasmaSplattersPS'
	
	MyDamageType=class'Arena.Dmg_Water'
	
	//ProjectileDecal=MaterialInstanceTimeVarying'PlasmaTorch.Materials.PlasmaDecalMat'
	//ImpactSound=SoundCue'PlasmaTorch.Audio.ImpactSC'
	
	Speed=2000
	MaxSpeed=2000
	DecalWidth=50
	DecalHeight=50
	LifeSpan=0
	Damage=0
	DamageRadius=5
	MomentumTransfer=0
	CustomGravityScaling=1
	//Physics=PHYS_Falling
	bCollideWorld=true
	
	ProjectileTag="WaterDroplet"
}