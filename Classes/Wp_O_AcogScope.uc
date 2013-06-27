/*******************************************************************************
	Wp_O_AcogScope

	Creation date: 12/06/2013 00:42
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_O_AcogScope extends Wp_O_Scope;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'AcogScope.Meshes.AcogScopeMesh'
	End Object
	
	Begin Object Name=NewStatMod
		ValueMods[WSVZoom]=4
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
	
	ScopeZoom=4
	Weight=2
	ComponentName="ACOG 4x Scope"
	ComponentDescription="A telescopic sight designed to enhance accuracy, the Advanced Combat Optical Gunsight provides a 4x magnification.  Though ideal for long range shooting, quick target tracking is difficult at close range."
}