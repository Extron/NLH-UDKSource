/******************************************************************************
	Ab_DustCloud
	
	Creation date: 09/06/2013 17:28
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

// Dust Cloud is basically a new ability to so no need to extend Ab_Sand (?)
class Ab_DustCloud extends ArenaAbility;

/* The cloud that the ability generates. */
var Ab_DustCloudCloud Cloud;

/**
 * The class to use for the boulder.  This can be overridden in subclasses to change what kind of wall is generated.
 */
var class<Ab_DustCloudCloud> CloudClass;

simulated function FireAmmunition()
{
	Cloud = Spawn(CloudClass, None, , Instigator.Location, Instigator.Rotation);
	
	super.FireAmmunition();
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	CoolDown=10
	EnergyCost=78
	AbilityName="Dust Cloud"
	
	CloudClass=class'Arena.Ab_DustCloudCloud'
	
	CanHold = false
	IsPassive = false
	CanCharge = true
}