/*******************************************************************************
	Wp_O_SimpleReflex

	Creation date: 10/06/2014 00:41
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class Wp_O_SimpleReflex extends Wp_Optics;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'ReflexSights.Meshes.SimpleReflex'
	End Object
	
	Begin Object Name=NewStatMod
		ValueMods[WSVZoom]=1.75
		ValueMods[WSVADSAccuracy]=2
	End Object
	
	CompatibleTypes[0]=WTRifle
	CompatibleTypes[1]=WTShotgun
	CompatibleTypes[2]=WTHardLightRifle
	CompatibleTypes[3]=WTGrenadeLauncher
	CompatibleTypes[4]=WTBeamRifle
	CompatibleTypes[5]=WTPlasmaRifle
	
	CompatibleSizes[0]=WSSmall
	CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge
	CompatibleSizes[3]=WSHeavy
	
	Weight=1
	ComponentName="Simple Reflex Sights"
	ComponentDescription=""
	OnlyZoomWeapon=false
}