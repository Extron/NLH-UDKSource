/*******************************************************************************
	Ab_ShockShort

	Creation date: 25/08/2012 02:21
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_ShockShort extends Ab_Shock;

defaultproperties
{
	BaseDamage=500
	WeaponRange=500
	CoolDown=5
	EnergyCost=300
	AbilityName="Short-Range Shock"
	AbilityIcon="ArenaAbilities.Icons.ShockShort"
	AbilityDescription="A short range version of Shock, this ability releases a burst of electricity and has a small range but deals a massive amount of damage.  A short cooldown and low cost, this ability is great for dealing with a wide variety of enemies in close to mid range situations.  Shock can also be used on metallic objects in the environment, which can electrocute anything that touches them, and is enhanced by interacting with water."
	UnlockPoints=5
}