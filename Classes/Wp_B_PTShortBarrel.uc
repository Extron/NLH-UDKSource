/*******************************************************************************
	Wp_B_PTShortBarrel

	Creation date: 04/04/2014 11:16
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_B_PTShortBarrel extends Wp_Barrel;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'PlasmaTorch.Meshes.PTShortBarrel'
	End Object
	
	Begin Object Name=NewStatMod
	End Object
	
	//MuzzleFlashTemplate=ParticleSystem'BasicRifleBarrel.Particles.MuzzleFlashPS'
	//MFLClass=class'Arena.L_RifleMuzzleFlash'
	
	CompatibleTypes[0]=WTPlasmaRifle
	
	//CompatibleSizes[0]=WSSmall
	//CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge
	
	SightsOffset=(Z=0.4)
	Weight=3.5
	Cost=20
	ComponentName="Short Plasma Barrel"
	ComponentDescription="A basic focuser and collecter for the super heated plasma fired by the plasma torch, this barrel is prone to spontaneous melting."
}