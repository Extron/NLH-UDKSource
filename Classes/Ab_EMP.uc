/*******************************************************************************
	Ab_EMP

	Creation date: 05/10/2012 15:11
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_EMP extends ArenaAbility;

/**
 * The radius of the EMP burst.
 */
var float Radius;


simulated function CustomFire()
{
	EMPBlast();
}

/**
 * Fires an EMP burst, affecting all players in the burst's radius.
 */
simulated function EMPBlast()
{
	local ArenaPawn iter;
	
	if (ArenaPawn(Instigator) != None)
	{
		foreach Instigator.WorldInfo.AllPawns(class'ArenaPawn', iter, Instigator.Location, Radius)
		{
			iter.RebootElectronics(ArenaPawn(Instigator));
		}
	}
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	AbilityName="EMP"
	CoolDown=5
	EnergyCost=350
	Radius=150
	
	CanHold=false
	IsPassive=false
	CanCharge=false
}