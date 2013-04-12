/*******************************************************************************
	Optics

	Creation date: 07/07/2012 14:57
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_Optics extends ArenaWeaponComponent;

/**
 * The degree of zoom that the optics component carries.
 */
var float ZoomLevel;

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
		}
	}
	
	return v;
}

defaultproperties
{
	ZoomLevel = 1;
}