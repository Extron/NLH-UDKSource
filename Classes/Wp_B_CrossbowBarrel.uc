/*******************************************************************************
	Wp_B_CrossbowBarrel

	Creation date: 10/05/2014 01:31
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class Wp_B_CrossbowBarrel extends Wp_Barrel;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RailGun.Meshes.CrossbowBarrel'
		AnimSets[0]=AnimSet'RailGun.Animations.CBAnimations'
		AnimTreeTemplate=AnimTree'RailGun.Animations.CBAnimationTree'
	End Object
	
	Begin Object Name=NewStatMod
	End Object
	
	//MuzzleFlashTemplate=ParticleSystem'BasicRifleBarrel.Particles.MuzzleFlashPS'
	//MFLClass=class'Arena.L_RifleMuzzleFlash'
	
	FireAnim=Fire
	CompatibleTypes[0]=WTRailGun
	
	//CompatibleSizes[0]=WSSmall
	//CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge
	
	SightsOffset=(Z=0.4)
	Weight=3.5
	Cost=20
	ComponentName="Rail Gun Crossbow Barrel"
	ComponentDescription="A standard rail gun barrel, this component helps accelerate the metal slug fired to nearly the speed of light."
}