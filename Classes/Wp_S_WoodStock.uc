/*******************************************************************************
	Wp_S_WoodStock

	Creation date: 31/05/2013 20:46
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_S_WoodStock extends Wp_Stock;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WoodStock.Meshes.WoodStockMesh_1P'
	End Object
	
	Begin Object Name=NewStatMod
		ValueMods[WSVRecoil]=1.35
		ValueMods[WSVStability]=1.25
		ValueMods[WSVMobility]=0.65
	End Object
	
	CompatibleTypes[0]=WTRifle
	CompatibleTypes[1]=WTShotgun
	CompatibleTypes[2]=WTHardLightRifle
	CompatibleTypes[3]=WTGrenadeLauncher
	
	CompatibleSizes[0]=WSSmall
	CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge
	
	AttachSock=AttachmentSocket
	ComponentName="Wood Stock"
	ComponentDescription="Made of solid oak wood, this stock is a bit more uncommon, though still frequent enough to be used be the common soldier.  Not as mobile, but grants good stability and less recoil."
	Weight=4
}