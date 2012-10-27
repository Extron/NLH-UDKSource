/*******************************************************************************
	Optics

	Creation date: 07/07/2012 14:57
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_Optics extends ArenaWeaponComponent;

/* The offset of the optics. */
var vector OpticsOffset;

function vector GetOpticsOffset(vector location, rotator rotation)
{
	local vector opticLoc;
	local vector socketLoc;
	local vector v;
	local rotator socketRot;

	if (SkeletalMeshComponent(Mesh) != None && SkeletalMeshComponent(Mesh).GetSocketByName('OpticsOffsetSocket') != None)
	{
		if (SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation('OpticsOffsetSocket', socketLoc, socketRot, 0))
		{
			v = socketLoc - location;
			
			
		}
	}
}