/*******************************************************************************
	Wp_M_RifleSilencer

	Creation date: 06/06/2013 01:25
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_M_RifleSilencer extends Wp_Muzzle;


simulated function bool OverrideDefaultMuzzleFlash()
{
	return true;
}

simulated function bool OverrideDefaultFireSound()
{
	return true;
}

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RifleMuzzles.Meshes.Silencer'
	End Object
	
	Begin Object Name=NewStatMod
		ValueMods[WSVAccuracy]=1.1
		ValueMods[WSVMobility]=1.05
		ValueMods[WSVDamageOutput]=0.95
		ValueMods[WSVRecoil]=0.9
	End Object
	
	MuzzleFlashTemplate=ParticleSystem'RifleMuzzles.Particles.MuzzleFlashPS'
	FireSound=SoundCue'RifleMuzzles.Audio.GunshotSC'
	
	CompatibleTypes[0]=WTRifle
	
	CompatibleSizes[0]=WSHand
	CompatibleSizes[1]=WSSmall
	CompatibleSizes[2]=WSRegular
	CompatibleSizes[3]=WSLarge
	
	AttachSock=AttachmentSocket
	ComponentName="Rifle Silencer"
	ComponentDescription="Common to elite soldier squads, rifle silencers can dampen the sounds of a rifle, assuming it has been constructed properly.  Its added weight lowers mobility, but increases accuracy and reduces recoil."
	Weight=1
	Cost=10
}