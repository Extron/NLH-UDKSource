/*******************************************************************************
	Wp_O_VIronSights

	Creation date: 23/03/2014 00:51
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_O_VIronSights extends Wp_Optics;

/**
 * Allows weapon optics to modify things like depth of field when the player aims down sights.
 */
simulated function BlurADS(UberPostProcessEffect effect)
{
	effect.FocusDistance = 192;
	effect.FocusInnerRadius = 128;
	effect.MaxNearBlurAmount = 0.85;
}

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'IronSights.Meshes.VIronSightsRear'
	End Object
	
	Begin Object Name=PostMesh
		SkeletalMesh=SkeletalMesh'IronSights.Meshes.VIronSightsPost'
	End Object
	
	Begin Object Name=NewStatMod
		ValueMods[WSVZoom]=1.25
		ValueMods[WSVADSAccuracy]=1.5
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
	ComponentName="V-shape Iron Sights"
	ComponentDescription="These iron sights offer the basic aim down sights ability, but with little additional enhancements like zoom and the tendancy to be misaligned, they provide little else."
	LineUpPost=true
	OnlyZoomWeapon=false
}
