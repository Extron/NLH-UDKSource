/*******************************************************************************
	Wp_B_ShortRailedBarrel

	Creation date: 07/06/2013 23:35
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_B_ShortRailedBarrel extends Wp_Barrel;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'ShortRailedBarrel.Meshes.ShortRailedBarrelMesh'
	End Object
	
	Begin Object Name=NewStatMod
		ValueMods[WSVMobility]=1.1
	End Object
	
	MuzzleFlashTemplate=ParticleSystem'BasicRifleBarrel.Particles.MuzzleFlashPS'
	MFLClass=class'Arena.L_RifleMuzzleFlash'
	
	CompatibleTypes[0]=WTRifle
	
	CompatibleSizes[0]=WSSmall
	CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge
	
	SightsOffset=(Z=0.4)
	Weight=3.5
	Cost=20
	ComponentName="Short Railed Barrel"
	ComponentDescription="A bit more advanced than the basic rifle barrel, this barrel is perfect for constructing carbines to be used in small spaces.  The addition of railing allows various attachments to be added."
}