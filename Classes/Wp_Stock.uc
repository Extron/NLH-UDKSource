/*******************************************************************************
	Stock

	Creation date: 26/06/2012 19:56
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_Stock extends ArenaWeaponComponent;

simulated function bool CanAttachToBase(ArenaWeaponBase baseWeap)
{
	return super.CanAttachToBase(baseWeap) && baseWeap.CanEquipStock(self);
}

defaultproperties
{
	Subclasses[0]=class'Arena.Wp_S_NoStock'
	Subclasses[1]=class'Arena.Wp_S_CheapStock'
	Subclasses[2]=class'Arena.Wp_S_WoodStock'
}