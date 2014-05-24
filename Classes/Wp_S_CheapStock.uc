/*******************************************************************************
	CheapStock

	Creation date: 07/07/2012 14:29
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_S_CheapStock extends Wp_Stock;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'CheapStock.Meshes.CheapStock1'
	End Object
	
	Begin Object Name=NewStatMod
		ValueMods[WSVRecoil]=0.85
		ValueMods[WSVStability]=0.85
		ValueMods[WSVAccuracy]=0.85
		ValueMods[WSVMobility]=1.75
	End Object
	
	CompatibleTypes[0]=WTRifle
	CompatibleTypes[1]=WTShotgun
	CompatibleTypes[2]=WTHardLightRifle
	CompatibleTypes[3]=WTGrenadeLauncher
	CompatibleTypes[4]=WTPlasmaRifle
	
	CompatibleSizes[0]=WSSmall
	CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge
	
	AttachSock=AttachmentSocket
	ComponentName="Cheap Stock"
	ComponentDescription="Nothing more than a flimsy bit of metal, this stock offers drastic improvement in mobility while suffering in accuracy, stability, and recoil reduction."
	Weight=4
}