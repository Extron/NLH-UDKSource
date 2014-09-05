/*******************************************************************************
	AC_LLNude

	Creation date: 10/02/2014 13:15
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BPC_LeftLegNude extends BodyPartComponent;

defaultproperties
{
	Begin Object Name=Mesh
		SkeletalMesh=SkeletalMesh'Leg_Nude.Meshes.NudeL'
	End Object
	
	Type=BPTLeftLeg
	ComponentName="Organic Leg"
	ComponentDescription="A fully organic leg, with no special modifications."
	EnergyCost=0
	Cost=0;
}