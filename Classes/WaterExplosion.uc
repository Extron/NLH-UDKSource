/*******************************************************************************
	WaterExplosion

	Creation date: 03/09/2014 09:32
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class WaterExplosion extends AbilityExplosion;

defaultproperties
{
	DamageType=class'Arena.Dmg_Water'
	Radius=512
	BaseDamage=50
	BaseMomentum=500
	
	ExplosionTemplate=ParticleSystem'ArenaAbilities.Particles.ElectricExplosion'
	
	//Begin Object Name=Audio
		//SoundCue=SoundCue'ArenaAbilities.Audio.ElectricExplosionSC'
	//End Object
	
	DisplayName="Splash of Water"
}