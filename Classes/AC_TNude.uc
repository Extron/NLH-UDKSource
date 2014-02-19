/*******************************************************************************
	AC_TNude

	Creation date: 10/02/2014 13:15
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AC_TNude extends ArmorComponent;

defaultproperties
{
	Begin Object Name=Mesh
		SkeletalMesh=SkeletalMesh'Torso_Nude.Meshes.NudeTorso'
	End Object
	
	Type=ACTTorso
}