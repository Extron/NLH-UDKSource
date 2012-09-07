/*******************************************************************************
	CheapIronSights

	Creation date: 10/07/2012 21:15
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_O_CheapIronSights extends Wp_Optics;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'CheapIronSights.Mesh.CheapIronSightsMesh_1P'
		FOV=85.0
	End Object
	
	Begin Object Name=NewStatMod
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
	ComponentName="Cheap Iron Sights"
	OpticsOffset=(X=0, Y=10, Z=-2);
}