/*******************************************************************************
	ArmorSchematic

	Creation date: 10/02/2014 13:23
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class ArmorSchematic extends Object;

var array<class<ArmorComponent> > Components;

defaultproperties
{
	Components[0]=class'Arena.AC_RANude'
	Components[1]=class'Arena.AC_LARobotForearm'
	Components[2]=class'Arena.AC_RLNude'
	Components[3]=class'Arena.AC_LLNude'
	Components[4]=class'Arena.AC_TNude'
	Components[5]=class'Arena.AC_ThermalVisionOptics'
	Components[6]=class'Arena.ACS_TatteredShirt'
	Components[7]=class'Arena.ACP_TatteredPants'
}
