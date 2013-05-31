/*******************************************************************************
	Optics

	Creation date: 07/07/2012 14:57
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_Optics extends ArenaWeaponComponent;

function vector GetOpticsOffset(vector l, rotator r)
{
	local vector socketLoc;
	local vector v;
	local rotator socketRot;

	if (SkeletalMeshComponent(Mesh) != None && SkeletalMeshComponent(Mesh).GetSocketByName('SightSocket') != None)
	{
		if (SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation('SightSocket', socketLoc, socketRot, 0))
		{
			v = (socketLoc - l) << r;	
			v.x = 0;
			//v.y -= 0.7;
			v.z += 1.65;
		}
	}
	
	return v;
}

defaultproperties
{
	Subclasses[0]=class'Arena.Wp_O_CheapIronSights'
}