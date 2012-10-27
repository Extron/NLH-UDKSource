/*******************************************************************************
	Electricity

	Creation date: 24/09/2012 15:00
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PC_Electricity extends PlayerClass
	dependson(PlayerStats);

defaultproperties
{
	ClassName="Electricity"
	
	Begin Object Class=PlayerStatModifier Name=NewMod
		ValueMods[PSVAccuracy]=1.1
		ValueMods[PSVMobility]=1.1
		ValueMods[PSVMovement]=1.05
	End Object
	Mod=NewMod
}