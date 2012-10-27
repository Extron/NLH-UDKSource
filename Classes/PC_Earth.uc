/*******************************************************************************
	PC_Earth

	Creation date: 24/09/2012 15:14
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PC_Earth extends PlayerClass;

defaultproperties
{
	ClassName="Earth"
	
	Begin Object Class=PlayerStatModifier Name=NewMod
		ValueMods[PSVMaxStamina]=1.05
		ValueMods[PSVGlobalDamageInput]=0.95
		ValueMods[PSVStability]=1.1
		ValueMods[PSVStaminaRegenRate]=1.05
	End Object
	Mod=NewMod
}