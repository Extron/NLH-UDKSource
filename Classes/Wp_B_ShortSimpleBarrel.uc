/*******************************************************************************
	Wp_B_ShortSimpleBarrel

	Creation date: 23/03/2014 00:50
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_B_ShortSimpleBarrel extends Wp_Barrel;

/**
 * This barrel has no railing to allow attachments.
 */
simulated function bool CanEquipUnderAttachment(Wp_UnderAttachment attachment)
{
	return Wp_UA_NoUnderAttachment(attachment) != None;
}


/**
 * This barrel has no railing to allow attachments.
 */
simulated function bool CanEquipSideAttachment(Wp_SideAttachment attachment)
{
	return Wp_SA_NoSideAttachment(attachment) != None;
}

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RifleBarrels.Meshes.ShortSimpleBarrel'
	End Object
	
	Begin Object Name=NewStatMod
		ValueMods[WSVAccuracy]=0.95
		ValueMods[WSVMobility]=1.1
	End Object
	
	MuzzleFlashTemplate=ParticleSystem'BasicRifleBarrel.Particles.MuzzleFlashPS'
	MFLClass=class'Arena.L_RifleMuzzleFlash'
	
	CompatibleTypes[0]=WTRifle
	CompatibleTypes[1]=WTHardLightRifle
	
	CompatibleSizes[0]=WSSmall
	CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge

	SightsOffset=(Z=0.5)
	Weight=3
	ComponentName="Short Simple Rifle Barrel"
	ComponentDescription="A simple rifled barrel made out of iron metal, it can be attached to a wide variety of projectile-based weapons, though its cheap design often leads to rust or corrosion."
}