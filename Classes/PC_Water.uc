/*******************************************************************************
	PC_Water

	Creation date: 24/09/2012 15:09
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PC_Water extends PlayerClass
	dependson(PlayerStats);

defaultproperties
{
	ClassName="Water"
	
	Begin Object Class=PlayerStatModifier Name=NewMod
		ValueMods[PSVEnergyRegenRate]=1.1
		ValueMods[PSVMobility]=1.1
		ValueMods[PSVAbilityCooldownFactor]=0.85
	End Object
	Mod=NewMod
}
